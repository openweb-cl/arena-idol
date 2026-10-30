"""El Turbo #11 — generador reproducible del modelo, rig y clips (muestra V1).

MUESTRA V1 PROVISIONAL: pendiente de revisión del propietario; no es arte final.
Diseño original de Arena de Ídolos. Sin escudos, kits, rostros ni marcas reales.

Uso (Blender 5.2 o módulo bpy 5.2 de PyPI, ambos gratuitos):
    blender --background --python art/turbo/build_turbo.py
    python art/turbo/build_turbo.py            # con `pip install bpy`

Salidas: art/turbo/turbo.blend (fuente) y game/assets/models/turbo/turbo.glb.
Contrato: docs/CONTRATO_ARTE_3D.md. Ejes Blender: Z arriba, el personaje mira
+Y, que el exportador glTF convierte en -Z de Godot. Pies en el origen.
"""
import math
from pathlib import Path

import bpy  # antes que bmesh: necesario con el módulo bpy de PyPI
import bmesh
from mathutils import Euler, Matrix, Vector

ROOT = Path(__file__).resolve().parents[2]
BLEND = ROOT / "art" / "turbo" / "turbo.blend"
GLB = ROOT / "game" / "assets" / "models" / "turbo" / "turbo.glb"
FPS = 30

# --- Paleta (sRGB) -----------------------------------------------------------
PALETTE = {
    "M_Turbo_Cian": ("2eb8ff", 0.70, 0.0, None),       # camiseta, medias
    "M_Turbo_Indigo": ("27318f", 0.75, 0.0, None),     # cresta, short, guantes
    "M_Turbo_Blanco": ("eef7ff", 0.80, 0.0, None),     # botas, ribetes, panel dorsal
    "M_Turbo_Piel": ("c98a66", 0.85, 0.0, None),       # piel caricaturesca neutra
    "M_Turbo_Noche": ("141b3d", 0.60, 0.0, None),      # dorsal, suelas, boca
    "M_Turbo_Chispa": ("7cffe4", 0.40, 0.0, 1.6),      # visor y rayos (emisivo)
}
MATS = list(PALETTE)

BONES = [
    # nombre, cabeza, cola, padre
    ("root", (0, 0, 0), (0, 0.25, 0), None),
    ("hips", (0, 0, 0.80), (0, 0, 0.94), "root"),
    ("spine", (0, 0, 0.94), (0, 0, 1.12), "hips"),
    ("chest", (0, 0, 1.12), (0, 0, 1.33), "spine"),
    ("head", (0, 0, 1.33), (0, 0, 1.80), "chest"),
    ("upper_arm.L", (-0.27, 0, 1.25), (-0.33, 0, 1.02), "chest"),
    ("forearm.L", (-0.33, 0, 1.02), (-0.36, 0, 0.81), "upper_arm.L"),
    ("hand.L", (-0.36, 0, 0.81), (-0.37, 0, 0.69), "forearm.L"),
    ("upper_arm.R", (0.27, 0, 1.25), (0.33, 0, 1.02), "chest"),
    ("forearm.R", (0.33, 0, 1.02), (0.36, 0, 0.81), "upper_arm.R"),
    ("hand.R", (0.36, 0, 0.81), (0.37, 0, 0.69), "forearm.R"),
    ("thigh.L", (-0.12, 0, 0.80), (-0.12, 0, 0.48), "hips"),
    ("shin.L", (-0.12, 0, 0.48), (-0.12, 0, 0.15), "thigh.L"),
    ("foot.L", (-0.12, 0, 0.15), (-0.12, 0.17, 0.07), "shin.L"),
    ("thigh.R", (0.12, 0, 0.80), (0.12, 0, 0.48), "hips"),
    ("shin.R", (0.12, 0, 0.48), (0.12, 0, 0.15), "thigh.R"),
    ("foot.R", (0.12, 0, 0.15), (0.12, 0.17, 0.07), "shin.R"),
]
BONE_NAMES = [b[0] for b in BONES]


def srgb_to_linear(hex_color):
    out = []
    for i in (0, 2, 4):
        c = int(hex_color[i:i + 2], 16) / 255
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return (*out, 1.0)


def make_materials():
    mats = []
    for name, (color, rough, metal, emit) in PALETTE.items():
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


# --- Construcción de geometría rígida por hueso ------------------------------
class Builder:
    """Acumula piezas en un único bmesh; cada pieza pesa 1.0 sobre un hueso."""

    def __init__(self):
        self.bm = bmesh.new()
        self.deform = self.bm.verts.layers.deform.verify()

    def merge(self, tmp, mat, bone, smooth):
        tmp.verts.index_update()
        new_verts = [self.bm.verts.new(v.co) for v in tmp.verts]
        for f in tmp.faces:
            nf = self.bm.faces.new([new_verts[v.index] for v in f.verts])
            nf.material_index = MATS.index(mat)
            nf.smooth = smooth
        group = BONE_NAMES.index(bone)
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
        m = Matrix.Translation((a + b) / 2) @ rot
        bmesh.ops.transform(tmp, matrix=m, verts=tmp.verts)
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
            taper_depth=1.0, rot=(0, 0, 0), smooth=None):
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
        m = Matrix.Translation(center) @ Euler([math.radians(a) for a in rot]).to_matrix().to_4x4()
        bmesh.ops.transform(tmp, matrix=m, verts=tmp.verts)
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


def glyph_one(b, mat, bone, origin, height, axis_sign, depth=0.014):
    """Dígito «1» geométrico propio (sin fuente tipográfica). Mira hacia ±Y."""
    w = height * 0.2
    ox, oy, oz = origin
    b.box(mat, bone, (ox, oy, oz), (w, depth, height), smooth=False)
    # Bandera superior inclinada hacia el lado izquierdo del lector.
    flag_x = ox - w * 0.9 * axis_sign
    b.box(mat, bone, (flag_x, oy, oz + height * 0.36), (w * 1.2, depth, w * 0.9),
          rot=(0, 35 * axis_sign, 0), smooth=False)


def build_mesh():
    b = Builder()
    C, I, W, S, N, G = MATS
    for side, sx in (("L", -1), ("R", 1)):
        x = 0.12 * sx
        # Botas grandes: caricatura legible desde cámara cenital.
        b.box(W, f"foot.{side}", (x, 0.05, 0.085), (0.18, 0.36, 0.15), bevel=0.05, segments=3, taper_top=0.85, taper_depth=0.8)
        b.box(N, f"foot.{side}", (x, 0.05, 0.018), (0.19, 0.37, 0.036), bevel=0.012, segments=1)
        b.box(C, f"foot.{side}", (x, 0.19, 0.06), (0.15, 0.09, 0.09), bevel=0.03, segments=2)
        # Aleta de tobillo (silueta de velocidad).
        b.spike(I, f"shin.{side}", (x + 0.07 * sx, -0.02, 0.2), (0.35 * sx, -1, 0.45), 0.06, 0.2, segments=3, flat=0.25)
        # Media cian con banda blanca y rayo.
        b.limb(C, f"shin.{side}", (x, 0, 0.14), (x, 0, 0.44), 0.068, 0.08)
        b.limb(W, f"shin.{side}", (x, 0, 0.40), (x, 0, 0.45), 0.083, 0.083)
        b.box(G, f"shin.{side}", (x + 0.074 * sx, 0.0, 0.31), (0.012, 0.03, 0.09), rot=(25, 0, 0), smooth=False)
        b.box(G, f"shin.{side}", (x + 0.074 * sx, 0.0, 0.23), (0.012, 0.03, 0.09), rot=(-25, 0, 0), smooth=False)
        b.sphere(S, f"shin.{side}", (x, 0.0, 0.485), (0.07, 0.07, 0.07), u=10, v=6)
        b.limb(S, f"thigh.{side}", (x, 0, 0.5), (x, 0, 0.72), 0.075, 0.095)
        # Brazos: manga, piel, brazalete eléctrico y guante grande.
        sh = Vector((0.27 * sx, 0, 1.25))
        el = Vector((0.33 * sx, 0, 1.02))
        wr = Vector((0.36 * sx, 0, 0.81))
        b.sphere(C, f"upper_arm.{side}", sh + Vector((0.01 * sx, 0, -0.03)), (0.1, 0.1, 0.095), u=10, v=6)
        b.limb(C, f"upper_arm.{side}", sh, sh.lerp(el, 0.45), 0.092, 0.08)
        b.limb(W, f"upper_arm.{side}", sh.lerp(el, 0.42), sh.lerp(el, 0.52), 0.083, 0.081)
        b.limb(S, f"upper_arm.{side}", sh.lerp(el, 0.5), el, 0.06, 0.055, segments=8)
        b.sphere(S, f"forearm.{side}", el, (0.058, 0.058, 0.058), u=8, v=6)
        b.limb(S, f"forearm.{side}", el, wr, 0.055, 0.06, segments=8)
        b.limb(G, f"forearm.{side}", el.lerp(wr, 0.7), el.lerp(wr, 0.95), 0.07, 0.072, segments=8)
        b.sphere(I, f"hand.{side}", wr + Vector((0.01 * sx, 0.01, -0.07)), (0.085, 0.09, 0.1), u=10, v=7)
        b.sphere(I, f"hand.{side}", wr + Vector((-0.02 * sx, 0.07, -0.04)), (0.035, 0.035, 0.045), u=6, v=4)
    # Short índigo con franja cian.
    b.box(I, "hips", (0, 0, 0.75), (0.38, 0.25, 0.2), bevel=0.06, segments=2, taper_top=1.02)
    for sx in (-1, 1):
        b.box(C, "hips", (0.188 * sx, 0, 0.73), (0.012, 0.08, 0.16), smooth=False)
    # Torso en V: cintura estrecha, hombros algo más anchos (silueta estrecha de velocista).
    b.box(C, "spine", (0, 0, 0.975), (0.38, 0.26, 0.27), bevel=0.06, segments=2, taper_top=1.08)
    b.box(C, "chest", (0, 0, 1.2), (0.42, 0.28, 0.24), bevel=0.08, segments=2, taper_top=1.18, taper_depth=0.95)
    for sx in (-1, 1):
        b.box(I, "spine", (0.19 * sx, 0, 1.03), (0.025, 0.2, 0.22), bevel=0.01, segments=1, rot=(0, 6 * sx, 0))
    # Cuello y collar.
    b.limb(S, "chest", (0, 0, 1.3), (0, 0, 1.4), 0.075, 0.07, segments=8)
    b.limb(W, "chest", (0, 0, 1.3), (0, 0, 1.34), 0.12, 0.1, segments=12)
    # Rayo diagonal en el pecho (gráfico propio) y dorsal 11 delantero pequeño.
    front = 0.142
    for i, (dx, dz, r) in enumerate(((-0.09, 1.25, -35), (-0.04, 1.18, 30), (0.02, 1.11, -35))):
        b.box(G, "chest" if i < 2 else "spine", (dx, front, dz), (0.03, 0.012, 0.09), rot=(0, r, 0), smooth=False)
    glyph_one(b, N, "chest", (0.07, front, 1.2), 0.1, -1)
    glyph_one(b, N, "chest", (0.12, front, 1.2), 0.1, -1)
    # Espalda: panel blanco con dorsal 11 grande (mira -Y).
    back = -0.145
    b.box(W, "chest", (0, back + 0.004, 1.16), (0.26, 0.012, 0.25), bevel=0.004, segments=1)
    glyph_one(b, N, "chest", (0.055, back - 0.004, 1.16), 0.19, 1)
    glyph_one(b, N, "chest", (-0.055, back - 0.004, 1.16), 0.19, 1)
    # Módulo turbo dorsal: lectura cenital del héroe eléctrico.
    b.box(I, "chest", (0, -0.2, 1.31), (0.2, 0.08, 0.1), bevel=0.03, segments=2)
    for sx in (-1, 1):
        b.box(G, "chest", (0.055 * sx, -0.245, 1.31), (0.035, 0.012, 0.06), smooth=False)
    # Cabeza grande (≈3,6 cabezas de alto total).
    hc = Vector((0, 0.01, 1.62))
    b.sphere(S, "head", hc, (0.26, 0.25, 0.27), u=18, v=12)
    for sx in (-1, 1):
        b.sphere(S, "head", hc + Vector((0.255 * sx, -0.01, -0.02)), (0.04, 0.06, 0.07), u=8, v=5)
    b.sphere(S, "head", hc + Vector((0, 0.255, -0.04)), (0.04, 0.035, 0.035), u=8, v=5)
    b.box(N, "head", hc + Vector((0, 0.235, -0.13)), (0.09, 0.02, 0.025), bevel=0.008, segments=1, rot=(-15, 0, 0))
    # Visor eléctrico envolvente (sustituye ojos: rostro abstracto hasta exploración de artista).
    b.arc_band(G, "head", hc + Vector((0, 0, 0.02)), 0.262, 0.085, 20, 160, 0.02, segments=14, scale=(1.02, 1.0, 1))
    b.arc_band(N, "head", hc + Vector((0, -0.005, 0.072)), 0.262, 0.02, 15, 165, 0.025, segments=14, scale=(1.03, 1.0, 1))
    # Cresta en punta barrida hacia atrás (índigo con puntas cian) y aletas laterales.
    crest = [
        ((0.0, 0.12, 1.84), (0, 0.45, 1), 0.09, 0.2, I),
        ((0.0, 0.0, 1.87), (0, -0.55, 1), 0.1, 0.25, I),
        ((0.09, 0.05, 1.83), (0.4, -0.35, 1), 0.08, 0.2, I),
        ((-0.09, 0.05, 1.83), (-0.4, -0.35, 1), 0.08, 0.2, I),
        ((0.0, -0.12, 1.81), (0, -1, 0.45), 0.1, 0.25, I),
        ((0.11, -0.1, 1.76), (0.45, -1, 0.3), 0.08, 0.2, I),
        ((-0.11, -0.1, 1.76), (-0.45, -1, 0.3), 0.08, 0.2, I),
        ((0.05, 0.16, 1.81), (0.2, 0.7, 0.8), 0.05, 0.13, C),
        ((-0.05, 0.16, 1.81), (-0.2, 0.7, 0.8), 0.05, 0.13, C),
    ]
    b.sphere(I, "head", hc + Vector((0, -0.02, 0.08)), (0.265, 0.26, 0.22), u=16, v=8)
    for base, direction, radius, length, mat in crest:
        b.spike(mat, "head", base, direction, radius, length, segments=5)
    for sx in (-1, 1):
        b.spike(C, "head", hc + Vector((0.24 * sx, -0.06, 0.08)), (0.35 * sx, -1, 0.35), 0.07, 0.2, segments=3, flat=0.3, roll=math.pi / 2)
    return b


def build_armature():
    arm_data = bpy.data.armatures.new("Turbo_Armature")
    arm = bpy.data.objects.new("Armature", arm_data)
    bpy.context.scene.collection.objects.link(arm)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    edit = {}
    for name, head, tail, parent in BONES:
        eb = arm_data.edit_bones.new(name)
        eb.head, eb.tail, eb.roll = head, tail, 0.0
        if parent:
            eb.parent = edit[parent]
            eb.use_connect = False
        edit[name] = eb
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
    # Con padre de hueso, la ubicación es relativa a la cola del hueso.
    bone_tail = arm.matrix_world @ pb.bone.matrix_local @ Matrix.Translation((0, pb.bone.length, 0))
    empty.matrix_parent_inverse = bone_tail.inverted()
    empty.location = world_pos


# --- Animación: rotaciones en ejes de personaje (X derecha, Y frente, Z arriba)
REST_KEYS = {}


def set_pose(arm, pose):
    """`pose`: {hueso: (rot_xyz_grados, desplazamiento_xyz)} relativo al reposo."""
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
    """Duplica valores de lado L hacia R reflejando el eje X."""
    out = dict(pose_l)
    for name, (rot, loc) in pose_l.items():
        if name.endswith(".L"):
            out[name[:-2] + ".R"] = ((rot[0], -rot[1], -rot[2]), (-loc[0], loc[1], loc[2]))
    return out


def P(**kw):
    """Atajo: P(spine=(-4,0,0), hips=((0,0,0),(0,0,-0.01)))."""
    pose = {}
    for k, v in kw.items():
        name = k.replace("_L", ".L").replace("_R", ".R")
        pose[name] = v if isinstance(v[0], tuple) else (v, (0, 0, 0))
    return pose


def stance(breath=0.0):
    return mirror(P(
        hips=((0, 0, 0), (0, 0, -0.012 * breath)),
        spine=(-4 + 3 * breath, 0, 0), chest=(-2 + 3 * breath, 0, 0), head=(3 - 3 * breath, 0, 2 * breath),
        upper_arm_L=(8 + 4 * breath, 14 - 4 * breath, 0), forearm_L=(32 + 4 * breath, 0, 0),
        thigh_L=(6, 4, 0), shin_L=(-10, 0, 0), foot_L=(4, 0, 0),
    ))


def run_pose(f):
    """Ciclo de sprint de 16 cuadros; pierna L adelantada en f=0."""
    legs = {  # cuadro: (muslo, espinilla, pie)
        0: (45, -15, 10), 4: (5, -25, 0), 8: (-35, -30, -30), 12: (20, -105, -10), 16: (45, -15, 10)}
    arms = {0: -40, 4: 0, 8: 50, 12: 0, 16: -40}
    l_thigh, l_shin, l_foot = legs[f]
    r_thigh, r_shin, r_foot = legs[(f + 8) % 16]
    bob = 0.05 if f % 8 == 4 else 0.0
    twist = 6 if f in (0, 16) else (-6 if f == 8 else 0)
    return P(
        hips=((0, 0, twist), (0, 0, bob)), spine=(-16, 0, -twist), chest=(-6, 0, -twist * 0.5), head=(14, 0, 0),
        thigh_L=(l_thigh, 3, 0), shin_L=(l_shin, 0, 0), foot_L=(l_foot, 0, 0),
        thigh_R=(r_thigh, -3, 0), shin_R=(r_shin, 0, 0), foot_R=(r_foot, 0, 0),
        upper_arm_L=(arms[f], 14, 0), forearm_L=(85, 0, 0),
        upper_arm_R=(arms[(f + 8) % 16], -14, 0), forearm_R=(85, 0, 0),
    )


def build_actions(arm):
    arm.animation_data_create()
    clips = {}

    def clip(name, keys):
        act = bpy.data.actions.new(name)
        act.use_fake_user = True
        arm.animation_data.action = act
        for frame, pose in keys:
            key_pose(arm, frame, pose)
        clips[name] = (act, keys[-1][0])

    clip("idle", [(0, stance(0)), (24, stance(1)), (48, stance(0))])
    clip("run", [(f, run_pose(f)) for f in (0, 4, 8, 12, 16)])
    neutral = stance(0)
    clip("kick", [
        (0, neutral),
        (2, {**neutral, **P(spine=(8, 0, 10), chest=(4, 0, 0), thigh_R=(-35, -6, 0), shin_R=(-75, 0, 0),
                            upper_arm_L=(30, 35, 0), upper_arm_R=(-35, -20, 0), thigh_L=(14, 4, 0), shin_L=(-22, 0, 0))}),
        (4, {**neutral, **P(spine=(-12, 0, -12), chest=(-6, 0, -6), head=(8, 0, 0), thigh_R=(88, -4, 0), shin_R=(-4, 0, 0),
                            foot_R=(-25, 0, 0), thigh_L=(12, 4, 0), shin_L=(-20, 0, 0), foot_L=(6, 0, 0),
                            upper_arm_L=(-45, 38, 0), forearm_L=(40, 0, 0), upper_arm_R=(45, -32, 0), forearm_R=(30, 0, 0))}),
        (6, {**neutral, **P(spine=(-10, 0, -10), thigh_R=(72, -4, 0), shin_R=(-18, 0, 0), foot_R=(-15, 0, 0),
                            thigh_L=(12, 4, 0), shin_L=(-20, 0, 0), upper_arm_L=(-35, 32, 0), upper_arm_R=(35, -28, 0))}),
        (12, neutral),
    ])
    clip("hit", [
        (0, neutral),
        (2, {**neutral, **mirror(P(hips=((0, 0, 0), (0, 0, -0.03)), spine=(18, 0, 6), chest=(10, 0, 0), head=(22, 0, -8),
                                   upper_arm_L=(-10, 48, 0), forearm_L=(12, 0, 0), thigh_L=(-6, 6, 0), shin_L=(-6, 0, 0)))}),
        (5, {**neutral, **mirror(P(spine=(10, 0, 3), chest=(5, 0, 0), head=(10, 0, -3), upper_arm_L=(0, 30, 0), forearm_L=(20, 0, 0)))}),
        (12, neutral),
    ])
    crouch = mirror(P(hips=((0, 0, 0), (0, 0, -0.11)), spine=(-14, 0, 0), head=(6, 0, 0),
                      thigh_L=(40, 4, 0), shin_L=(-70, 0, 0), foot_L=(30, 0, 0), upper_arm_L=(-25, 12, 0), forearm_L=(30, 0, 0)))
    clip("celebrate", [
        (0, crouch),
        (6, mirror(P(hips=((0, 0, 0), (0, 0, 0.1)), spine=(-2, 0, 0), thigh_L=(-4, 4, 0), shin_L=(-4, 0, 0), foot_L=(-25, 0, 0),
                     upper_arm_L=(10, 95, 0), forearm_L=(10, 0, 0)))),
        (11, mirror(P(hips=((0, 0, 0), (0, 0, 0.32)), spine=(4, 0, 0), head=(-12, 0, 0), thigh_L=(30, 6, 0), shin_L=(-55, 0, 0),
                      foot_L=(-10, 0, 0), upper_arm_L=(0, 145, 0), forearm_L=(-15, 0, 0)))),
        (16, mirror(P(spine=(0, 0, 0), head=(-8, 0, 0), thigh_L=(4, 4, 0), shin_L=(-6, 0, 0), upper_arm_L=(0, 135, 0), forearm_L=(-10, 0, 0)))),
        (20, mirror(P(hips=((0, 0, 0), (0, 0, -0.06)), spine=(-8, 0, 0), thigh_L=(25, 4, 0), shin_L=(-45, 0, 0), foot_L=(20, 0, 0),
                      upper_arm_L=(20, 95, 0), forearm_L=(110, 0, 0)))),
        (26, mirror(P(spine=(2, 0, 0), head=(-10, 0, 0), thigh_L=(2, 4, 0), shin_L=(-4, 0, 0), upper_arm_L=(0, 145, 0), forearm_L=(-15, 0, 0)))),
        (36, crouch),
    ])
    # Cada clip queda en una pista NLA silenciada para que el exportador los encuentre.
    for name, (act, end) in clips.items():
        track = arm.animation_data.nla_tracks.new()
        track.name = name
        strip = track.strips.new(name, 0, act)
        strip.name = name
        track.mute = True
    arm.animation_data.action = None
    set_pose(arm, {})
    return clips


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.fps = FPS
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0
    mats = make_materials()
    arm = build_armature()
    me = bpy.data.meshes.new("Turbo_Mesh")
    body = bpy.data.objects.new("Turbo_Body", me)
    scene.collection.objects.link(body)
    for name in BONE_NAMES:
        body.vertex_groups.new(name=name)
    for mat in mats:
        me.materials.append(mat)
    builder = build_mesh()
    bmesh.ops.recalc_face_normals(builder.bm, faces=builder.bm.faces)
    builder.bm.to_mesh(me)
    builder.bm.free()
    me.validate()
    body.parent = arm
    mod = body.modifiers.new("Armature", "ARMATURE")
    mod.object = arm
    add_socket(arm, "Muzzle", "chest", (0.0, 0.45, 1.05))
    add_socket(arm, "VFXOrigin", "chest", (0.0, 0.0, 1.1))
    clips = build_actions(arm)
    tris = sum(len(p.vertices) - 2 for p in me.polygons)
    print(f"TURBO_METRICS triangles={tris} vertices={len(me.vertices)} materials={len(me.materials)} bones={len(arm.data.bones)} clips={list(clips)}")
    BLEND.parent.mkdir(parents=True, exist_ok=True)
    GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND), compress=True)
    bpy.ops.export_scene.gltf(
        filepath=str(GLB), export_format="GLB", export_yup=True, export_apply=True,
        export_animations=True, export_animation_mode="ACTIONS", export_skins=True,
        export_cameras=False, export_lights=False, export_extras=False,
        export_force_sampling=True, export_frame_range=False,
    )
    print("TURBO_EXPORT", GLB)


if __name__ == "__main__":
    main()
