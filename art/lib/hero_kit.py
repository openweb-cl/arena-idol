"""Kit común para generar héroes de Arena de Ídolos con bpy (Blender 5.2).

Geometría rígida por hueso, rig estándar del contrato, dígitos geométricos
propios, poses en ejes de personaje, clips base y exportación GLB/.blend.
Cada héroe vive en art/<id>/build_<id>.py y solo define forma, paleta y matices.
Ejes Blender: Z arriba, el personaje mira +Y (glTF lo convierte en -Z de Godot).
"""
import math
from pathlib import Path

import bpy  # antes que bmesh: necesario con el módulo bpy de PyPI
import bmesh
from mathutils import Euler, Matrix, Vector

ROOT = Path(__file__).resolve().parents[2]
FPS = 30


def srgb_to_linear(hex_color):
    out = []
    for i in (0, 2, 4):
        c = int(hex_color[i:i + 2], 16) / 255
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return (*out, 1.0)


def make_materials(palette):
    """`palette`: {nombre: (hex sRGB, rugosidad, metálico, emisión o None)}."""
    mats = []
    for name, (color, rough, metal, emit) in palette.items():
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Base Color"].default_value = srgb_to_linear(color)
        bsdf.inputs["Roughness"].default_value = rough
        bsdf.inputs["Metallic"].default_value = metal
        if emit:
            bsdf.inputs["Emission Color"].default_value = srgb_to_linear(color)
            bsdf.inputs["Emission Strength"].default_value = emit
        mat.diffuse_color = srgb_to_linear(color)
        mats.append(mat)
    return mats


def make_bones(shoulder_x=0.27, hip_x=0.12, arm_drop=0.0, hip_z=0.80, chest_top=1.33):
    """Rig estándar de 17 huesos; las proporciones cambian solo posiciones."""
    sx, hx = shoulder_x, hip_x
    elbow, wrist, hand = (sx + 0.06, 1.02 - arm_drop), (sx + 0.09, 0.81 - arm_drop), (sx + 0.10, 0.69 - arm_drop)
    bones = [
        ("root", (0, 0, 0), (0, 0.25, 0), None),
        ("hips", (0, 0, hip_z), (0, 0, hip_z + 0.14), "root"),
        ("spine", (0, 0, hip_z + 0.14), (0, 0, 1.12), "hips"),
        ("chest", (0, 0, 1.12), (0, 0, chest_top), "spine"),
        ("head", (0, 0, chest_top), (0, 0, chest_top + 0.47), "chest"),
    ]
    for side, s in (("L", -1), ("R", 1)):
        bones += [
            (f"upper_arm.{side}", (s * sx, 0, 1.25), (s * elbow[0], 0, elbow[1]), "chest"),
            (f"forearm.{side}", (s * elbow[0], 0, elbow[1]), (s * wrist[0], 0, wrist[1]), f"upper_arm.{side}"),
            (f"hand.{side}", (s * wrist[0], 0, wrist[1]), (s * hand[0], 0, hand[1]), f"forearm.{side}"),
        ]
    for side, s in (("L", -1), ("R", 1)):
        bones += [
            (f"thigh.{side}", (s * hx, 0, hip_z), (s * hx, 0, 0.48), "hips"),
            (f"shin.{side}", (s * hx, 0, 0.48), (s * hx, 0, 0.15), f"thigh.{side}"),
            (f"foot.{side}", (s * hx, 0, 0.15), (s * hx, 0.17, 0.07), f"shin.{side}"),
        ]
    return bones


class Builder:
    """Acumula piezas en un único bmesh; cada pieza pesa 1.0 sobre un hueso."""

    def __init__(self, material_names, bone_names):
        self.mats = list(material_names)
        self.bone_names = list(bone_names)
        self.bm = bmesh.new()
        self.deform = self.bm.verts.layers.deform.verify()

    def merge(self, tmp, mat, bone, smooth):
        tmp.verts.index_update()
        new_verts = [self.bm.verts.new(v.co) for v in tmp.verts]
        for f in tmp.faces:
            nf = self.bm.faces.new([new_verts[v.index] for v in f.verts])
            nf.material_index = self.mats.index(mat)
            nf.smooth = smooth
        group = self.bone_names.index(bone)
        for v in new_verts:
            v[self.deform][group] = 1.0
        tmp.free()

    def sphere(self, mat, bone, center, radii, u=12, v=8, smooth=True, rot=(0, 0, 0)):
        tmp = bmesh.new()
        bmesh.ops.create_uvsphere(tmp, u_segments=u, v_segments=v, radius=1.0)
        m = Matrix.Translation(center) @ Euler([math.radians(a) for a in rot]).to_matrix().to_4x4() @ Matrix.Diagonal((*radii, 1))
        bmesh.ops.transform(tmp, matrix=m, verts=tmp.verts)
        self.merge(tmp, mat, bone, smooth)

    def limb(self, mat, bone, a, b, r1, r2, segments=10, smooth=True):
        """Cono truncado de a hacia b (radio r1 en a)."""
        a, b = Vector(a), Vector(b)
        axis = b - a
        tmp = bmesh.new()
        bmesh.ops.create_cone(tmp, cap_ends=True, cap_tris=False, segments=segments,
                              radius1=r1, radius2=r2, depth=axis.length)
        rot = Vector((0, 0, 1)).rotation_difference(axis.normalized()).to_matrix().to_4x4()
        bmesh.ops.transform(tmp, matrix=Matrix.Translation((a + b) / 2) @ rot, verts=tmp.verts)
        self.merge(tmp, mat, bone, smooth)

    def spike(self, mat, bone, base, direction, radius, length, segments=5, flat=1.0, roll=0.0):
        """Púa/aleta: cono con punta. `flat` < 1 lo aplana en su eje X local."""
        d = Vector(direction).normalized()
        tmp = bmesh.new()
        bmesh.ops.create_cone(tmp, cap_ends=True, cap_tris=True, segments=segments,
                              radius1=radius, radius2=0.0, depth=length)
        bmesh.ops.translate(tmp, vec=(0, 0, length / 2), verts=tmp.verts)
        bmesh.ops.scale(tmp, vec=(flat, 1, 1), verts=tmp.verts)
        bmesh.ops.rotate(tmp, cent=(0, 0, 0), matrix=Matrix.Rotation(roll, 3, "Z"), verts=tmp.verts)
        rot = Vector((0, 0, 1)).rotation_difference(d).to_matrix().to_4x4()
        bmesh.ops.transform(tmp, matrix=Matrix.Translation(base) @ rot, verts=tmp.verts)
        self.merge(tmp, mat, bone, smooth=False)

    def box(self, mat, bone, center, size, bevel=0.0, segments=2, taper_top=1.0,
            taper_depth=1.0, rot=(0, 0, 0), smooth=None, matrix=None):
        tmp = bmesh.new()
        bmesh.ops.create_cube(tmp, size=1.0)
        for v in tmp.verts:
            if v.co.z > 0:
                v.co.x *= taper_top
                v.co.y *= taper_depth
            v.co.x *= size[0]
            v.co.y *= size[1]
            v.co.z *= size[2]
        if bevel > 0:
            bmesh.ops.bevel(tmp, geom=list(tmp.edges) + list(tmp.verts), offset=bevel,
                            offset_type="OFFSET", segments=segments, profile=0.5,
                            affect="EDGES", clamp_overlap=True)
        if matrix is None:
            matrix = Matrix.Translation(center) @ Euler([math.radians(a) for a in rot]).to_matrix().to_4x4()
        bmesh.ops.transform(tmp, matrix=matrix, verts=tmp.verts)
        self.merge(tmp, mat, bone, smooth if smooth is not None else bevel > 0)

    def arc_band(self, mat, bone, center, radius, height, start_deg, end_deg, thickness, segments=14, scale=(1, 1, 1)):
        """Banda curva (visor) alrededor del eje Z, ángulos medidos desde +X."""
        tmp = bmesh.new()
        ring_lo, ring_hi = [], []
        for i in range(segments + 1):
            t = math.radians(start_deg + (end_deg - start_deg) * i / segments)
            x, y = math.cos(t) * radius, math.sin(t) * radius
            ring_lo.append(tmp.verts.new((x, y, -height / 2)))
            ring_hi.append(tmp.verts.new((x, y, height / 2)))
        for i in range(segments):
            tmp.faces.new((ring_lo[i], ring_lo[i + 1], ring_hi[i + 1], ring_hi[i]))
        bmesh.ops.solidify(tmp, geom=list(tmp.faces), thickness=thickness)
        bmesh.ops.transform(tmp, matrix=Matrix.Translation(center) @ Matrix.Diagonal((*scale, 1)), verts=tmp.verts)
        self.merge(tmp, mat, bone, smooth=True)

    # --- Tatuajes / calcomanías sobre extremidades cónicas --------------------
    @staticmethod
    def _limb_frame(a, b, t, radius, angle_deg):
        a, b = Vector(a), Vector(b)
        d = (b - a).normalized()
        ref = Vector((0, 1, 0)) if abs(d.y) < 0.9 else Vector((1, 0, 0))
        u = d.cross(ref).normalized()
        v = d.cross(u).normalized()
        ang = math.radians(angle_deg)
        normal = (u * math.cos(ang) + v * math.sin(ang)).normalized()
        center = a.lerp(b, t) + normal * radius
        x_axis = normal.cross(d).normalized()
        m = Matrix((x_axis, normal, d)).transposed().to_4x4()
        m.translation = center
        return m

    def decal(self, mat, bone, a, b, t, radius, angle_deg, size, spin=0.0):
        """Pieza fina pegada a la superficie de un cono (tatuaje, insignia)."""
        m = self._limb_frame(a, b, t, radius + 0.003, angle_deg) @ Matrix.Rotation(math.radians(spin), 4, "Y")
        self.box(mat, bone, None, (size[0], 0.006, size[1]), smooth=False, matrix=m)

    def zigzag_band(self, mat, bone, a, b, t, radius, amplitude=0.012, width=0.012, teeth=8):
        """Brazalete tatuado en zigzag alrededor de la extremidad."""
        a, b = Vector(a), Vector(b)
        d = (b - a).normalized()
        steps = teeth * 2
        for i in range(steps):
            ang0, ang1 = 360 * i / steps, 360 * (i + 1) / steps
            off0 = amplitude if i % 2 == 0 else -amplitude
            p0 = self._limb_frame(a, b, t, radius + 0.003, ang0).translation + d * off0
            p1 = self._limb_frame(a, b, t, radius + 0.003, ang1).translation - d * off0
            seg = p1 - p0
            normal = (p0 + p1) / 2 - a.lerp(b, t)
            normal = (normal - d * normal.dot(d)).normalized()
            x_axis = seg.normalized()
            z_axis = x_axis.cross(normal).normalized()
            m = Matrix((x_axis, normal, z_axis)).transposed().to_4x4()
            m.translation = (p0 + p1) / 2
            self.box(mat, bone, None, (seg.length + width * 0.6, 0.006, width), smooth=False, matrix=m)


# --- V3: cuerpo continuo con pesos suaves y atlas de textura -----------------
def tube_fractions(rings):
    """Fracción de longitud (0..1) de cada anillo dentro del tramo etiquetado "uv".

    Comparte el cálculo entre el mallado y el pintado del atlas, para que los
    detalles pintados caigan a la altura prevista del modelo.
    """
    pts = [Vector(r[0]) for r in rings]
    acc = [0.0]
    for i in range(1, len(pts)):
        acc.append(acc[-1] + (pts[i] - pts[i - 1]).length)
    uv_segs = [i for i in range(len(rings) - 1) if rings[i][3] == "uv"]
    if not uv_segs:
        return [0.0] * len(rings)
    a, b = acc[uv_segs[0]], acc[uv_segs[-1] + 1]
    return [(s - a) / max(b - a, 1e-6) for s in acc]


class AtlasBuilder(Builder):
    """Un único material con atlas: cada pieza usa una muestra de color o una región.

    `swatches`: {nombre: (x, y)} centro en píxeles; `size`: lado del atlas.
    Los primitivos heredados aceptan el nombre de muestra donde antes iba el material.
    """

    def __init__(self, size, swatches, bone_names):
        super().__init__([], bone_names)
        self.size = size
        self.swatches = swatches
        self.uv = self.bm.loops.layers.uv.verify()

    def px(self, x, y):
        return (x / self.size, 1.0 - y / self.size)

    def swatch_uv(self, name):
        return self.px(*self.swatches[name])

    def add(self, coords, faces, face_uvs, weights, smooth=True):
        """Añade vértices con pesos {hueso: w} y caras con UV por esquina."""
        verts = [self.bm.verts.new(c) for c in coords]
        for v, w in zip(verts, weights):
            total = sum(w.values())
            for bone, value in w.items():
                if value > 0:
                    v[self.deform][self.bone_names.index(bone)] = value / total
        for idx, uvs in zip(faces, face_uvs):
            f = self.bm.faces.new([verts[i] for i in idx])
            f.material_index = 0
            f.smooth = smooth
            for loop, uv in zip(f.loops, uvs):
                loop[self.uv].uv = uv
        return verts

    def merge(self, tmp, mat, bone, smooth):
        tmp.verts.index_update()
        uv = self.swatch_uv(mat)
        faces = [[v.index for v in f.verts] for f in tmp.faces]
        self.add([v.co.copy() for v in tmp.verts], faces, [[uv] * len(f) for f in faces],
                 [{bone: 1.0}] * len(tmp.verts), smooth)
        tmp.free()

    def tube(self, rings, segments=12, region=None, cap_start=None, cap_end=None, smooth=True):
        """Tubo elíptico por anillos ordenados de arriba abajo.

        Anillo: (centro, rx, ry, etiqueta, {hueso: peso}). La etiqueta del anillo i
        pinta el tramo i→i+1: nombre de muestra o "uv" (desenvuelto cilíndrico en
        `region` = (x0, y0, x1, y1)). Ángulo 0 = +X (derecha del personaje), 90° = frente.
        """
        pts = [Vector(r[0]) for r in rings]
        frac = tube_fractions(rings)
        coords, weights = [], []
        for i, (c, rx, ry, _tag, w) in enumerate(rings):
            t = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
            fwd = Vector((0, 1, 0)) - t * t.y
            fwd = fwd.normalized() if fwd.length > 1e-4 else Vector((0, 0, 1))
            side = t.cross(fwd).normalized()
            for j in range(segments):
                a = 2 * math.pi * j / segments
                coords.append(pts[i] + side * math.cos(a) * rx + fwd * math.sin(a) * ry)
                weights.append(w)
        faces, uvs = [], []
        for i in range(len(rings) - 1):
            tag = rings[i][3]
            for j in range(segments):
                k = (j + 1) % segments
                faces.append([i * segments + j, (i + 1) * segments + j, (i + 1) * segments + k, i * segments + k])
                if tag == "uv":
                    x0, y0, x1, y1 = region
                    def at(u, f):
                        return self.px(x0 + u * (x1 - x0), y0 + min(max(f, 0.0), 1.0) * (y1 - y0))
                    u0, u1 = j / segments, (j + 1) / segments
                    uvs.append([at(u0, frac[i]), at(u0, frac[i + 1]), at(u1, frac[i + 1]), at(u1, frac[i])])
                else:
                    uvs.append([self.swatch_uv(tag)] * 4)
        last = len(rings) - 1
        for ring, name in ((0, cap_start), (last, cap_end)):
            if name:
                idx = [ring * segments + j for j in range(segments)]
                faces.append(idx if ring else idx[::-1])
                uvs.append([self.swatch_uv(name)] * segments)
        self.add(coords, faces, uvs, weights, smooth)

    def horn(self, mat, bone, base, direction, length, radius, bend=(0, 0, 0), rings=6, segments=6, flat=1.0):
        """Mechón/púa curva que se afila hasta la punta (pelo caricaturesco)."""
        base, d, bend = Vector(base), Vector(direction).normalized(), Vector(bend)
        spec = []
        for i in range(rings + 1):
            t = i / rings
            c = base + d * length * t + bend * length * t * t
            r = max(radius * (1 - t) ** 0.85, 0.003)
            spec.append((c, r, r * flat, mat, {bone: 1.0}))
        self.tube(spec, segments=segments, cap_start=mat, cap_end=mat, smooth=True)

    def textured_ellipsoid(self, bone, center, radii, region, fallback, u=24, v=16, deform=None, front=0.25):
        """Elipsoide con proyección frontal en `region` (cara) y muestra lisa detrás.

        La imagen se lee como vista de frente: su izquierda es la derecha (+X) del personaje.
        """
        tmp = bmesh.new()
        bmesh.ops.create_uvsphere(tmp, u_segments=u, v_segments=v, radius=1.0)
        cx, cy, cz = center
        rx, ry, rz = radii
        for vert in tmp.verts:
            p = Vector((vert.co.x * rx, vert.co.y * ry, vert.co.z * rz))
            if deform:
                p = deform(p)
            vert.co = p + Vector(center)
        tmp.verts.index_update()
        x0, y0, x1, y1 = region
        faces, uvs = [], []
        flat = self.swatch_uv(fallback)
        for f in tmp.faces:
            faces.append([vv.index for vv in f.verts])
            mid = f.calc_center_median() - Vector(center)
            if mid.y / ry > front:
                uvs.append([self.px(x0 + (0.5 - (vv.co.x - cx) / (2 * rx)) * (x1 - x0),
                                    y0 + (0.5 - (vv.co.z - cz) / (2 * rz)) * (y1 - y0)) for vv in f.verts])
            else:
                uvs.append([flat] * len(f.verts))
        self.add([vv.co.copy() for vv in tmp.verts], faces, uvs, [{bone: 1.0}] * len(tmp.verts))
        tmp.free()

    def mark(self):
        self.bm.verts.ensure_lookup_table()
        return len(self.bm.verts)

    def scale_since(self, mark, pivot, factor):
        """Escala desde `pivot` lo añadido tras `mark` (p. ej. cabeza más caricaturesca)."""
        self.bm.verts.ensure_lookup_table()
        pivot = Vector(pivot)
        for v in self.bm.verts[mark:]:
            v.co = pivot + (v.co - pivot) * factor

    def partial_sphere(self, mat, bone, center, radii, keep, u=20, v=12):
        """Elipsoide del que solo quedan las caras cuyo centro cumple `keep(p)` (p. ej. casquete de pelo)."""
        tmp = bmesh.new()
        bmesh.ops.create_uvsphere(tmp, u_segments=u, v_segments=v, radius=1.0)
        bmesh.ops.transform(tmp, matrix=Matrix.Translation(center) @ Matrix.Diagonal((*radii, 1)), verts=tmp.verts)
        doomed = [f for f in tmp.faces if not keep(f.calc_center_median())]
        bmesh.ops.delete(tmp, geom=doomed, context="FACES")
        self.merge(tmp, mat, bone, smooth=True)


def make_atlas_material(name, png_path, rough=0.8):
    """Material único con el atlas empaquetado en el GLB (sRGB, opaco)."""
    img = bpy.data.images.load(str(png_path))
    img.pack()
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes["Principled BSDF"]
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.interpolation = "Linear"
    links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = 0.0
    return mat


# --- Dígitos geométricos propios (sin fuentes tipográficas) -----------------
SEGMENTS = {  # a arriba, b arriba-der, c abajo-der, d abajo, e abajo-izq, f arriba-izq, g centro
    "0": "abcdef", "2": "abged", "3": "abgcd", "4": "fgbc", "5": "afgcd",
    "6": "afgedc", "7": "abc", "8": "abcdefg", "9": "abcdfg",
}


def glyph(b, mat, bone, char, origin, height, axis_sign, depth=0.014):
    """Dibuja un dígito mirando hacia +Y (axis_sign=-1, pecho) o -Y (+1, espalda).

    `axis_sign` es la dirección X hacia la derecha del lector.
    """
    ox, oy, oz = origin
    t = height * (0.17 if char == "1" else 0.14)
    if char == "1":
        b.box(mat, bone, (ox, oy, oz), (t * 1.15, depth, height), smooth=False)
        b.box(mat, bone, (ox - t * 1.05 * axis_sign, oy, oz + height * 0.36), (t * 1.4, depth, t),
              rot=(0, 35 * axis_sign, 0), smooth=False)
        return
    w = height * 0.6
    half_w, half_h = w / 2, height / 2
    horiz = {"a": half_h - t / 2, "g": 0.0, "d": -half_h + t / 2}
    vert = {"b": (1, 0.25), "c": (1, -0.25), "e": (-1, -0.25), "f": (-1, 0.25)}
    for seg in SEGMENTS[char]:
        if seg in horiz:
            b.box(mat, bone, (ox, oy, oz + horiz[seg]), (w, depth, t), smooth=False)
        else:
            side, zf = vert[seg]
            x = ox + side * (half_w - t / 2) * axis_sign
            b.box(mat, bone, (x, oy, oz + zf * height), (t, depth, half_h + t / 2), smooth=False)


def number(b, mat, bone, text, center, height, facing):
    """Número centrado. facing='front' (mira +Y) o 'back' (mira -Y)."""
    axis_sign = -1 if facing == "front" else 1
    advance = height * 0.72
    start = -(len(text) - 1) * advance / 2
    for i, ch in enumerate(text):
        x = center[0] + (start + i * advance) * axis_sign
        glyph(b, mat, bone, ch, (x, center[1], center[2]), height, axis_sign)


# --- Rig, sockets y animación ----------------------------------------------
def build_armature(bones, name="Armature"):
    arm_data = bpy.data.armatures.new(name + "_Data")
    arm = bpy.data.objects.new(name, arm_data)
    bpy.context.scene.collection.objects.link(arm)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    edit = {}
    for bone_name, head, tail, parent in bones:
        eb = arm_data.edit_bones.new(bone_name)
        eb.head, eb.tail, eb.roll = head, tail, 0.0
        if parent:
            eb.parent = edit[parent]
            eb.use_connect = False
        edit[bone_name] = eb
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm


def add_socket(arm, name, bone, world_pos):
    empty = bpy.data.objects.new(name, None)
    empty.empty_display_size = 0.08
    bpy.context.scene.collection.objects.link(empty)
    empty.parent = arm
    empty.parent_type = "BONE"
    empty.parent_bone = bone
    pb = arm.pose.bones[bone]
    bone_tail = arm.matrix_world @ pb.bone.matrix_local @ Matrix.Translation((0, pb.bone.length, 0))
    empty.matrix_parent_inverse = bone_tail.inverted()
    empty.location = world_pos


def set_pose(arm, pose):
    """`pose`: {hueso: (rot_xyz_grados, desplazamiento_xyz)} en ejes de personaje."""
    for pb in arm.pose.bones:
        rot, loc = pose.get(pb.name, ((0, 0, 0), (0, 0, 0)))
        m = pb.bone.matrix_local.to_3x3().normalized()
        r_world = Euler([math.radians(a) for a in rot], "XYZ").to_matrix()
        pb.rotation_mode = "QUATERNION"
        pb.rotation_quaternion = (m.inverted() @ r_world @ m).to_quaternion()
        pb.location = m.inverted() @ Vector(loc)


def key_pose(arm, frame, pose):
    set_pose(arm, pose)
    for pb in arm.pose.bones:
        pb.keyframe_insert("rotation_quaternion", frame=frame, group=pb.name)
        pb.keyframe_insert("location", frame=frame, group=pb.name)


def mirror(pose_l):
    """Copia valores del lado L al R reflejando el eje X."""
    out = dict(pose_l)
    for name, (rot, loc) in pose_l.items():
        if name.endswith(".L"):
            out[name[:-2] + ".R"] = ((rot[0], -rot[1], -rot[2]), (-loc[0], loc[1], loc[2]))
    return out


def P(**kw):
    """Atajo: P(spine=(-4,0,0), hips=((0,0,0),(0,0,-0.01)), upper_arm_L=(...))."""
    pose = {}
    for k, v in kw.items():
        name = k.replace("_L", ".L").replace("_R", ".R")
        pose[name] = v if isinstance(v[0], tuple) else (v, (0, 0, 0))
    return pose


def stance(breath=0.0, arm_out=14, leg_out=4, lean=-4):
    return mirror(P(
        hips=((0, 0, 0), (0, 0, -0.012 * breath)),
        spine=(lean + 3 * breath, 0, 0), chest=(-2 + 3 * breath, 0, 0), head=(3 - 3 * breath, 0, 2 * breath),
        upper_arm_L=(8 + 4 * breath, arm_out - 4 * breath, 0), forearm_L=(32 + 4 * breath, 0, 0),
        thigh_L=(6, leg_out, 0), shin_L=(-10, 0, 0), foot_L=(4, 0, 0),
    ))


def run_pose(f, lean=-16, arm_swing=1.0, arm_out=14, bob=0.05, stride=1.0):
    """Ciclo de 16 cuadros; pierna L adelantada en f=0. `stride` amplía el giro de muslos."""
    legs = {0: (45, -15, 10), 4: (5, -25, 0), 8: (-35, -30, -30), 12: (20, -105, -10), 16: (45, -15, 10)}
    arms = {0: -40, 4: 0, 8: 50, 12: 0, 16: -40}
    l_thigh, l_shin, l_foot = legs[f]
    r_thigh, r_shin, r_foot = legs[(f + 8) % 16]
    l_thigh, r_thigh = l_thigh * stride, r_thigh * stride
    up = bob if f % 8 == 4 else 0.0
    twist = 6 if f in (0, 16) else (-6 if f == 8 else 0)
    return P(
        hips=((0, 0, twist), (0, 0, up)), spine=(lean, 0, -twist), chest=(-6, 0, -twist * 0.5), head=(-lean * 0.85, 0, 0),
        thigh_L=(l_thigh, 3, 0), shin_L=(l_shin, 0, 0), foot_L=(l_foot, 0, 0),
        thigh_R=(r_thigh, -3, 0), shin_R=(r_shin, 0, 0), foot_R=(r_foot, 0, 0),
        upper_arm_L=(arms[f] * arm_swing, arm_out, 0), forearm_L=(85, 0, 0),
        upper_arm_R=(arms[(f + 8) % 16] * arm_swing, -arm_out, 0), forearm_R=(85, 0, 0),
    )


def hit_keys(neutral, arm_out=48):
    return [
        (0, neutral),
        (2, {**neutral, **mirror(P(hips=((0, 0, 0), (0, 0, -0.03)), spine=(18, 0, 6), chest=(10, 0, 0), head=(22, 0, -8),
                                   upper_arm_L=(-10, arm_out, 0), forearm_L=(12, 0, 0), thigh_L=(-6, 6, 0), shin_L=(-6, 0, 0)))}),
        (5, {**neutral, **mirror(P(spine=(10, 0, 3), chest=(5, 0, 0), head=(10, 0, -3), upper_arm_L=(0, 30, 0), forearm_L=(20, 0, 0)))}),
        (12, neutral),
    ]


def celebrate_keys(jump=0.32, arm_up=145):
    crouch = mirror(P(hips=((0, 0, 0), (0, 0, -0.11)), spine=(-14, 0, 0), head=(6, 0, 0),
                      thigh_L=(40, 4, 0), shin_L=(-70, 0, 0), foot_L=(30, 0, 0), upper_arm_L=(-25, 12, 0), forearm_L=(30, 0, 0)))
    return [
        (0, crouch),
        (6, mirror(P(hips=((0, 0, 0), (0, 0, 0.1)), spine=(-2, 0, 0), thigh_L=(-4, 4, 0), shin_L=(-4, 0, 0), foot_L=(-25, 0, 0),
                     upper_arm_L=(10, 95, 0), forearm_L=(10, 0, 0)))),
        (11, mirror(P(hips=((0, 0, 0), (0, 0, jump)), spine=(4, 0, 0), head=(-12, 0, 0), thigh_L=(30, 6, 0), shin_L=(-55, 0, 0),
                      foot_L=(-10, 0, 0), upper_arm_L=(0, arm_up, 0), forearm_L=(-15, 0, 0)))),
        (16, mirror(P(head=(-8, 0, 0), thigh_L=(4, 4, 0), shin_L=(-6, 0, 0), upper_arm_L=(0, arm_up - 10, 0), forearm_L=(-10, 0, 0)))),
        (20, mirror(P(hips=((0, 0, 0), (0, 0, -0.06)), spine=(-8, 0, 0), thigh_L=(25, 4, 0), shin_L=(-45, 0, 0), foot_L=(20, 0, 0),
                      upper_arm_L=(20, 95, 0), forearm_L=(110, 0, 0)))),
        (26, mirror(P(spine=(2, 0, 0), head=(-10, 0, 0), thigh_L=(2, 4, 0), shin_L=(-4, 0, 0), upper_arm_L=(0, arm_up, 0), forearm_L=(-15, 0, 0)))),
        (36, crouch),
    ]


def build_actions(arm, clips):
    """`clips`: {nombre: [(cuadro, pose), ...]}. Cada clip queda en una pista NLA."""
    arm.animation_data_create()
    for name, keys in clips.items():
        act = bpy.data.actions.new(name)
        act.use_fake_user = True
        arm.animation_data.action = act
        for frame, pose in keys:
            key_pose(arm, frame, pose)
        track = arm.animation_data.nla_tracks.new()
        track.name = name
        strip = track.strips.new(name, 0, act)
        strip.name = name
        track.mute = True
    arm.animation_data.action = None
    set_pose(arm, {})


def build_hero(hero_id, palette, bones, build_mesh, clips, sockets, atlas=None):
    """Genera art/<id>/<id>.blend y game/assets/models/<id>/<id>.glb.

    Con `atlas` = (png, tamaño, muestras) se usa un único material texturizado y
    AtlasBuilder; `palette` es entonces {nombre_material: rugosidad}.
    """
    blend = ROOT / "art" / hero_id / f"{hero_id}.blend"
    glb = ROOT / "game" / "assets" / "models" / hero_id / f"{hero_id}.glb"
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps = FPS
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0
    if atlas:
        png, size, swatches = atlas
        (mat_name, rough), = palette.items()
        mats = [make_atlas_material(mat_name, png, rough)]
    else:
        mats = make_materials(palette)
    bone_names = [b[0] for b in bones]
    arm = build_armature(bones)
    me = bpy.data.meshes.new(f"{hero_id.capitalize()}_Mesh")
    body = bpy.data.objects.new(f"{hero_id.capitalize()}_Body", me)
    scene.collection.objects.link(body)
    for name in bone_names:
        body.vertex_groups.new(name=name)
    for mat in mats:
        me.materials.append(mat)
    builder = AtlasBuilder(size, swatches, bone_names) if atlas else Builder(palette.keys(), bone_names)
    build_mesh(builder)
    bmesh.ops.recalc_face_normals(builder.bm, faces=builder.bm.faces)
    builder.bm.to_mesh(me)
    builder.bm.free()
    me.validate()
    body.parent = arm
    mod = body.modifiers.new("Armature", "ARMATURE")
    mod.object = arm
    for name, bone, pos in sockets:
        add_socket(arm, name, bone, pos)
    build_actions(arm, clips)
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    print(f"{hero_id.upper()}_METRICS triangles={tris} vertices={len(me.vertices)} materials={len(me.materials)} "
          f"bones={len(arm.data.bones)} clips={list(clips)}")
    blend.parent.mkdir(parents=True, exist_ok=True)
    glb.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(blend), compress=True)
    bpy.ops.export_scene.gltf(
        filepath=str(glb), export_format="GLB", export_yup=True, export_apply=True,
        export_animations=True, export_animation_mode="ACTIONS", export_skins=True,
        export_cameras=False, export_lights=False, export_extras=False,
        export_force_sampling=True, export_frame_range=False,
    )
    print(f"{hero_id.upper()}_EXPORT", glb)
