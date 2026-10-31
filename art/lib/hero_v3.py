"""Cuerpo V3 común de los héroes: proporciones, atlas pintado, rig y clips.

Patrón nacido con Turbo V3 (referencia V2 aceptada por el propietario). Cada héroe
vive en art/<id>/build_<id>.py y solo aporta un `spec`: proporciones, colores,
mechones de pelo, rasgos de la cara, diseño de camiseta, tatuajes y extras.
Todo se dibuja con formas propias (Pillow): sin fuentes, logos ni imágenes externas.
Cuerpo continuo (tubos con pesos suaves) y un único material con atlas 1024.
"""
from pathlib import Path

from PIL import Image, ImageDraw

from hero_kit import P, Vector, build_hero, celebrate_keys, hit_keys, mirror, run_pose, tube_fractions

SIZE = 1024
SS = 2  # supermuestreo para bordes suaves

REGIONS = {  # x0, y0, x1, y1 en píxeles del atlas
    "camiseta": (0, 0, 1024, 448),
    "cara": (0, 448, 384, 832),
    "brazo": (384, 448, 704, 704),
    "short_R": (704, 448, 1024, 544),
    "short_L": (704, 544, 1024, 640),
}
SWATCH_ORDER = ["base", "base_oscuro", "acento", "blanco", "piel", "piel_sombra", "pelo", "pelo_sombra",
                "tinta", "gris", "short", "media", "banda", "puno", "suela", "detalle", "barba"]
SWATCHES = {name: (32 + 64 * (i % 16), 864 + 64 * (i // 16)) for i, name in enumerate(SWATCH_ORDER)}
BASE_COLORS = {
    "blanco": "#f7f7f7", "gris": "#c9ccd6", "tinta": "#2a2a2a", "iris": "#7a4a24", "iris_claro": "#a8703a",
    "boca": "#6b2f24", "barba": "#2b211c", "detalle": "#ffe873",
}
PROPORTIONS = {"chest": 1.0, "waist": 1.0, "arm": 1.0, "leg": 1.0, "shoulder": 1.0, "head_scale": 1.12}
HEAD_C = (0.0, 0.015, 1.63)
HEAD_R = (0.175, 0.17, 0.2)


def colors_for(spec):
    colors = dict(BASE_COLORS)
    colors.update(spec["colors"])
    for name, fallback in (("short", "base"), ("media", "base"), ("banda", "acento"), ("puno", "acento"),
                           ("suela", "base"), ("base_oscuro", "base")):
        colors.setdefault(name, colors[fallback])
    return colors


def prop(spec):
    out = dict(PROPORTIONS)
    out.update(spec.get("proportions", {}))
    return out


# --- Esqueleto y anillos del cuerpo --------------------------------------------
def bones(spec):
    k = prop(spec)["shoulder"]
    out = [
        ("root", (0, 0, 0), (0, 0.25, 0), None),
        ("hips", (0, 0, 0.84), (0, 0, 0.98), "root"),
        ("spine", (0, 0, 0.98), (0, 0, 1.15), "hips"),
        ("chest", (0, 0, 1.15), (0, 0, 1.40), "spine"),
        ("head", (0, 0, 1.40), (0, 0, 1.86), "chest"),
    ]
    for side, s in (("L", -1), ("R", 1)):
        out += [
            (f"upper_arm.{side}", (s * 0.26 * k, 0, 1.32), (s * 0.33 * k, 0, 1.06), "chest"),
            (f"forearm.{side}", (s * 0.33 * k, 0, 1.06), (s * 0.37 * k, 0.02, 0.80), f"upper_arm.{side}"),
            (f"hand.{side}", (s * 0.37 * k, 0.02, 0.80), (s * 0.38 * k, 0.03, 0.66), f"forearm.{side}"),
        ]
    for side, s in (("L", -1), ("R", 1)):
        out += [
            (f"thigh.{side}", (s * 0.12, 0, 0.84), (s * 0.145, 0, 0.50), "hips"),
            (f"shin.{side}", (s * 0.145, 0, 0.50), (s * 0.16, 0, 0.15), f"thigh.{side}"),
            (f"foot.{side}", (s * 0.16, 0, 0.15), (s * 0.17, 0.17, 0.06), f"shin.{side}"),
        ]
    return out


def torso_rings(spec):
    """Camiseta: anillos de arriba abajo (z, rx, ry, desplazamiento y)."""
    k = prop(spec)
    rows = [
        (1.445, 0.082, 0.078, 0.0), (1.41, 0.15, 0.11, 0.0), (1.375, 0.232, 0.138, 0.0),
        (1.325, 0.262, 0.152, 0.005), (1.245, 0.266, 0.16, 0.012), (1.145, 0.252, 0.156, 0.012),
        (1.045, 0.236, 0.146, 0.008), (0.965, 0.236, 0.146, 0.004), (0.885, 0.25, 0.155, 0.0),
        (0.845, 0.262, 0.165, 0.0),
    ]
    rings = []
    for z, rx, ry, dy in rows:
        f = k["chest"] if z > 1.1 else k["waist"]
        if z > 1.39:
            f = 1.0
        w = {"chest": 1.0} if z > 1.2 else ({"chest": 0.5, "spine": 0.5} if z > 1.1 else
                                            ({"spine": 1.0} if z > 0.99 else {"spine": 0.5, "hips": 0.5}))
        if z < 0.9:
            w = {"hips": 0.8, "spine": 0.2}
        rings.append(((0, dy, z), rx * f * (k["shoulder"] if 1.2 < z < 1.39 else 1.0), ry * f, "uv", w))
    return rings


def arm_rings(spec, s):
    """Brazo de hombro a muñeca: manga, puño y piel (atlas, para tatuajes o muñequeras)."""
    k = prop(spec)
    a, sh = k["arm"], k["shoulder"]
    up, fo, ha = (f"{n}.{'R' if s > 0 else 'L'}" for n in ("upper_arm", "forearm", "hand"))
    rows = [
        (0.17, 0, 1.335, 0.085, 0.085, "base", {"chest": 1.0}, 1.0),
        (0.25, 0, 1.335, 0.097, 0.095, "base", {"chest": 0.5, up: 0.5}, 1.0),
        (0.295, 0, 1.255, 0.093, 0.09, "base", {up: 1.0}, 1.0),
        (0.31, 0, 1.175, 0.089, 0.087, "puno", {up: 1.0}, 1.0),
        (0.315, 0, 1.14, 0.088, 0.086, "puno", {up: 1.0}, 1.0),
        (0.316, 0, 1.138, 0.074, 0.072, "uv", {up: 1.0}, a),
        (0.322, 0, 1.10, 0.076, 0.073, "uv", {up: 0.9, fo: 0.1}, a),
        (0.33, 0, 1.06, 0.064, 0.062, "uv", {up: 0.5, fo: 0.5}, a),
        (0.343, 0.008, 0.985, 0.075, 0.072, "uv", {fo: 0.85, up: 0.15}, a),
        (0.355, 0.016, 0.89, 0.066, 0.063, "uv", {fo: 1.0}, a),
        (0.368, 0.02, 0.805, 0.054, 0.052, "piel", {fo: 0.7, ha: 0.3}, a),
        (0.372, 0.022, 0.77, 0.046, 0.044, "piel", {fo: 0.3, ha: 0.7}, a),
    ]
    sleeve = max(a, sh)
    return [((s * x * sh, y, z), rx * (f if f != 1.0 else sleeve), ry * (f if f != 1.0 else sleeve), tag, w)
            for x, y, z, rx, ry, tag, w, f in rows]


def leg_rings(spec, s):
    """Pierna de cadera a tobillo: muslo, rodilla, media con banda."""
    g = prop(spec)["leg"]
    th, sh, ft = (f"{n}.{'R' if s > 0 else 'L'}" for n in ("thigh", "shin", "foot"))
    rows = [
        (0.115, 0, 0.80, 0.092, "piel", {"hips": 0.4, th: 0.6}),
        (0.13, 0.004, 0.68, 0.102, "piel", {th: 1.0}),
        (0.14, 0.006, 0.585, 0.092, "piel", {th: 1.0}),
        (0.145, 0.01, 0.50, 0.077, "piel", {th: 0.5, sh: 0.5}),
        (0.147, 0.006, 0.472, 0.078, "banda", {th: 0.3, sh: 0.7}),
        (0.147, 0.006, 0.47, 0.089, "banda", {th: 0.3, sh: 0.7}),
        (0.149, 0.004, 0.405, 0.089, "media", {sh: 1.0}),
        (0.152, -0.004, 0.33, 0.086, "media", {sh: 1.0}),
        (0.157, 0.0, 0.24, 0.07, "media", {sh: 1.0}),
        (0.16, 0.004, 0.155, 0.059, "media", {sh: 0.7, ft: 0.3}),
    ]
    return [((s * x, y, z), r * g, r * g * 0.98, tag, w) for x, y, z, r, tag, w in rows]


def short_leg_rings(spec, s):
    g = prop(spec)["waist"]  # el short sigue a la cintura para quedar bajo la camiseta
    th = f"thigh.{'R' if s > 0 else 'L'}"
    return [
        ((s * 0.105, 0, 0.815), 0.12 * g, 0.12 * g, "uv", {"hips": 1.0}),  # nace bajo el borde de la camiseta
        ((s * 0.125, 0.004, 0.70), 0.135 * g, 0.132 * g, "uv", {"hips": 0.45, th: 0.55}),
        ((s * 0.138, 0.006, 0.605), 0.128 * g, 0.124 * g, "uv", {"hips": 0.15, th: 0.85}),
    ]


def short_waist_rings(spec):
    g = prop(spec)["waist"]
    # Mismos pesos que la camiseta a esa altura: al inclinarse no la atraviesa.
    return [((0, 0, z), rx * g, ry * g, "short", w) for z, rx, ry, w in
            ((0.93, 0.22, 0.138, {"spine": 0.5, "hips": 0.5}), (0.84, 0.24, 0.152, {"hips": 0.8, "spine": 0.2}),
             (0.76, 0.235, 0.15, {"hips": 1.0}))]


def head_shape(jaw=0.22):
    """Mandíbula algo más estrecha y mentón marcado, sin rasgos de una persona real."""
    def shape(p):
        t = max(0.0, -p.z / HEAD_R[2])
        p.x *= 1 - jaw * t * t
        if p.y > 0:
            p.y *= 1 - 0.12 * t
        return p
    return shape


def hand(b, spec, side, s):
    """Mano grande y abierta (palma hacia el muslo), dedos algo flexionados."""
    bone = f"hand.{side}"
    k = prop(spec)
    wx = s * 0.375 * k["shoulder"]
    a = max(1.0, k["arm"] * 0.9)
    b.box("piel", bone, (wx, 0.03, 0.725), (0.06 * a, 0.1 * a, 0.1 * a), bevel=0.025, segments=2)
    for i, dy in enumerate((-0.03, -0.006, 0.018, 0.042)):
        length = 0.06 if i in (1, 2) else 0.052
        b.box("piel", bone, (wx - s * 0.006, (dy + 0.004) * a, 0.66 - (0.004 if i in (1, 2) else 0)),
              (0.04 * a, 0.022 * a, length * a), bevel=0.01, segments=1, rot=(0, -s * 12, 0))
    b.box("piel", bone, (wx - s * 0.02, 0.08 * a, 0.735), (0.032 * a, 0.026 * a, 0.06 * a), bevel=0.011, segments=1, rot=(30, s * 20, 0))


def boot(b, side, s):
    """Botín blanco con talón y franja de acento, suela y cordones."""
    bone, x = f"foot.{side}", s * 0.16
    b.box("blanco", bone, (x, 0.035, 0.095), (0.15, 0.27, 0.13), bevel=0.05, segments=2, taper_top=0.82, taper_depth=0.75)
    b.sphere("blanco", bone, (x, 0.15, 0.062), (0.074, 0.085, 0.058), u=12, v=8)
    b.box("acento", bone, (x, 0.04, 0.045), (0.158, 0.31, 0.03), bevel=0.012, segments=1)
    b.sphere("acento", bone, (x, 0.17, 0.045), (0.07, 0.07, 0.02), u=10, v=4)
    b.box("acento", bone, (x, -0.085, 0.1), (0.135, 0.06, 0.11), bevel=0.025, segments=1)
    b.box("suela", bone, (x, 0.04, 0.015), (0.162, 0.335, 0.03), bevel=0.012, segments=1)
    for i in range(3):
        b.box("gris", bone, (x, 0.05 + i * 0.033, 0.158 - i * 0.016), (0.07, 0.012, 0.01), rot=(-25, 0, 0), smooth=False)
    b.box("suela", bone, (x + s * 0.077, 0.03, 0.09), (0.008, 0.13, 0.022), rot=(-18, 0, 0), smooth=False)
    b.limb("blanco", bone, (x, 0.0, 0.14), (x, 0.0, 0.2), 0.072, 0.07, segments=12)


def build_mesh(spec):
    def build(b):
        b.tube(torso_rings(spec), segments=18, region=REGIONS["camiseta"], cap_end="base_oscuro")
        b.tube(short_waist_rings(spec), segments=16, cap_end="base_oscuro")
        b.tube([((0, 0, 1.37), 0.068, 0.066, "piel", {"chest": 1.0}),
                ((0, 0.005, 1.45), 0.066, 0.064, "piel", {"chest": 0.5, "head": 0.5}),
                ((0, 0.01, 1.53), 0.062, 0.06, "piel", {"head": 1.0})], segments=10)
        for side, s in (("L", -1), ("R", 1)):
            b.tube(arm_rings(spec, s), segments=12, region=REGIONS["brazo"], cap_end="piel")
            b.tube(leg_rings(spec, s), segments=12)
            b.tube(short_leg_rings(spec, s), segments=14, region=REGIONS["short_" + side])
            hand(b, spec, side, s)
            boot(b, side, s)
        if spec.get("body_extras"):
            spec["body_extras"](b)
        # Cabeza caricaturesca (escalada desde el cuello) con rostro pintado en el atlas.
        head_start = b.mark()
        for s in (-1, 1):
            b.sphere("piel", "head", (s * 0.168, 0.0, 1.615), (0.028, 0.042, 0.058), u=8, v=6)
        b.textured_ellipsoid("head", HEAD_C, HEAD_R, REGIONS["cara"], "piel", u=24, v=16,
                             deform=head_shape(spec.get("face", {}).get("jaw", 0.22)))
        b.sphere("piel", "head", (0, 0.178, 1.598), (0.019, 0.015, 0.016), u=8, v=6)
        cx, cy, cz = HEAD_C
        cap = spec.get("hair_cap", {})
        front_z = cap.get("front_z", 1.745)
        b.partial_sphere("pelo", "head", (cx, cy - 0.012, cap.get("z", 1.65)), cap.get("radii", (0.188, 0.188, 0.215)),
                         keep=lambda p: p.z > front_z - 0.09 * min(1.0, abs(p.x) / 0.17) or (p.y < cy - 0.03 and p.z > cap.get("nape", 1.47)),
                         u=20, v=14)
        for base, direction, length, radius, bend, swatch in spec["hair"]:
            b.horn(swatch, "head", base, direction, length, radius, bend=bend, flat=spec.get("hair_flat", 0.62))
        if spec.get("head_extras"):
            spec["head_extras"](b)
        b.scale_since(head_start, (0, 0, 1.46), prop(spec)["head_scale"])
    return build


# --- Pintado del atlas ------------------------------------------------------------
def level(rings, z):
    """Fracción (0..1) del tramo uv a la altura z (anillos de arriba abajo)."""
    frac = tube_fractions(rings)
    zs = [r[0][2] for r in rings]
    for i in range(len(zs) - 1):
        if zs[i] >= z >= zs[i + 1]:
            t = (zs[i] - z) / max(zs[i] - zs[i + 1], 1e-6)
            return frac[i] + t * (frac[i + 1] - frac[i])
    return frac[0] if z > zs[0] else frac[-1]


class Canvas:
    def __init__(self, colors):
        self.colors = colors
        self.img = Image.new("RGB", (SIZE * SS, SIZE * SS), colors["base_oscuro"])
        self.d = ImageDraw.Draw(self.img)

    def c(self, color):
        return self.colors.get(color, color)

    def poly(self, pts, color):
        self.d.polygon([(x * SS, y * SS) for x, y in pts], fill=self.c(color))

    def rect(self, x0, y0, x1, y1, color):
        self.d.rectangle([x0 * SS, y0 * SS, x1 * SS - 1, y1 * SS - 1], fill=self.c(color))

    def ellipse(self, cx, cy, rx, ry, color):
        self.d.ellipse([(cx - rx) * SS, (cy - ry) * SS, (cx + rx) * SS, (cy + ry) * SS], fill=self.c(color))

    def line(self, pts, color, width):
        self.d.line([(x * SS, y * SS) for x, y in pts], fill=self.c(color), width=int(width * SS), joint="curve")
        for x, y in (pts[0], pts[-1]):
            self.ellipse(x, y, width / 2, width / 2, color)

    def band(self, region, u0, v0, u1, v1, width, color):
        """Franja recta en coordenadas de región (u, v en 0..1)."""
        x0, y0, x1, y1 = region
        self.line([(x0 + u0 * (x1 - x0), y0 + v0 * (y1 - y0)), (x0 + u1 * (x1 - x0), y0 + v1 * (y1 - y0))], color, width)

    def save(self, path):
        self.img.resize((SIZE, SIZE), Image.LANCZOS).save(path, optimize=True)


SLANT = 0.08
SEGMENTS = {"0": "abcdef", "2": "abged", "3": "abgcd", "4": "fgbc", "5": "afgcd",
            "6": "afgedc", "7": "abc", "8": "abcdefg", "9": "abcdfg"}


def digit(c, ch, cx, top, h, w, color):
    """Dígito deportivo propio inclinado; `w` = px por unidad de altura en X."""
    def put(pts):
        c.poly([(cx + (x + SLANT * y) * w, top + (1.0 - y) * h) for x, y in pts], color)
    if ch == "1":
        put([(-0.12, 0.0), (0.12, 0.0), (0.12, 1.0), (-0.12, 1.0)])
        put([(-0.12, 1.0), (-0.38, 0.8), (-0.36, 0.64), (-0.1, 0.8)])
        return
    t, hw = 0.17, 0.29
    segs = {"a": (-hw, 1 - t, hw, 1), "g": (-hw, 0.5 - t / 2, hw, 0.5 + t / 2), "d": (-hw, 0, hw, t),
            "b": (hw - t, 0.5, hw, 1), "c": (hw - t, 0, hw, 0.5), "e": (-hw, 0, -hw + t, 0.5), "f": (-hw, 0.5, -hw + t, 1)}
    for s in SEGMENTS[ch]:
        x0, y0, x1, y1 = segs[s]
        put([(x0, y0), (x1, y0), (x1, y1), (x0, y1)])


def number(c, text, cx, top, h, w, color):
    advance = 0.6 if text.count("1") == len(text) else 0.7
    start = -(len(text) - 1) * advance / 2
    for i, ch in enumerate(text):
        digit(c, ch, cx + (start + i * advance) * w, top, h, w, color)


def paint_face(c, face):
    """Rostro caricaturesco frontal. `face`: eye_dx, eye_y, eye_scale, lid (0..1 entornado),
    brow ("decidida"|"recta"|"fruncida"), mouth ("sonrisa"|"atento"|"gruñido"), stubble."""
    x0, y0, x1, y1 = REGIONS["cara"]
    c.rect(x0, y0, x1, y1, "piel")
    s = (x1 - x0) / 384

    def P(x, y):
        return (x0 + x * s, y0 + y * s)

    k = face.get("eye_scale", 1.0)
    lid = face.get("lid", 0.0)
    if face.get("stubble"):  # sombra de barba propia en mandíbula y mentón
        c.poly([P(70, 250), P(110, 300), P(150, 330), P(192, 344), P(234, 330), P(274, 300), P(314, 250),
                P(330, 330), P(300, 384), P(84, 384), P(54, 330)], "barba")
        c.ellipse(*P(192, 300), 58 * s, 26 * s, "piel")
    for side in (-1, 1):  # side -1 = izquierda de la imagen = derecha del personaje
        ex, ey = 192 + side * face.get("eye_dx", 74), face.get("eye_y", 184)
        top = ey - 33 * k * (1 - lid * 0.55)
        c.poly([P(ex - 42 * k, ey + 6 * k), P(ex - 34 * k, ey - 22 * k * (1 - lid * 0.5)), P(ex, top),
                P(ex + 34 * k, ey - 22 * k * (1 - lid * 0.5)), P(ex + 42 * k, ey + 3 * k),
                P(ex + 28 * k, ey + 28 * k), P(ex, ey + 34 * k), P(ex - 28 * k, ey + 28 * k)], "blanco")
        ix = ex - side * 4
        c.ellipse(*P(ix, ey + 2 * k), 24 * k * s, 31 * k * s, "iris")
        c.ellipse(*P(ix, ey + 12 * k), 16 * k * s, 16 * k * s, "iris_claro")
        c.ellipse(*P(ix, ey + 2 * k), 11 * k * s, 15 * k * s, "tinta")
        c.ellipse(*P(ix + 9 * k, ey - 11 * k), 7 * k * s, 7 * k * s, "blanco")
        c.ellipse(*P(ix - 8 * k, ey + 14 * k), 4 * k * s, 4 * k * s, "blanco")
        if lid:  # párpado superior entornado (mirada dura)
            c.poly([P(ex - 46 * k, ey - 40 * k), P(ex + 46 * k, ey - 40 * k), P(ex + 46 * k, ey - 30 * k + 24 * lid * k),
                    P(ex - 46 * k, ey - 30 * k + 24 * lid * k)], "piel")
        lash = ey - 38 * k + 24 * lid * k
        c.poly([P(ex - side * 44 * k, ey + 4 * k), P(ex - side * 34 * k, lash + 12 * k), P(ex, lash),
                P(ex + side * 34 * k, lash + 10 * k), P(ex + side * 48 * k, ey - 8 * k + lid * 10 * k),
                P(ex + side * 56 * k, ey - 18 * k + lid * 10 * k), P(ex + side * 40 * k, lash + 17 * k),
                P(ex, lash + 10 * k), P(ex - side * 30 * k, lash + 19 * k)], "tinta")
        c.line([P(ex - side * 24 * k, ey + 31 * k), P(ex + side * 4 * k, ey + 36 * k), P(ex + side * 28 * k, ey + 28 * k)], "piel_sombra", 3 * s)
        brow = face.get("brow", "decidida")
        by = ey - 52 * k + (8 * lid * k)
        if brow == "recta":
            c.poly([P(ex - side * 46, by - 10), P(ex + side * 46, by - 16), P(ex + side * 46, by - 4), P(ex - side * 44, by + 4)], "tinta")
        elif brow == "fruncida":
            c.poly([P(ex - side * 50, by + 6), P(ex - side * 4, by - 14), P(ex + side * 48, by - 22), P(ex + side * 50, by - 8),
                    P(ex + side * 2, by - 2), P(ex - side * 44, by + 18)], "tinta")
        else:
            c.poly([P(ex - side * 48, by), P(ex + side * 2, by - 22), P(ex + side * 48, by - 18), P(ex + side * 50, by - 5),
                    P(ex + side * 4, by - 7), P(ex - side * 42, by + 13)], "tinta")
    c.line([P(184, 238), P(192, 246), P(203, 240)], "piel_sombra", 5 * s)
    mouth = face.get("mouth", "sonrisa")
    if mouth == "atento":
        c.line([P(166, 292), P(192, 298), P(220, 292)], "boca", 6 * s)
        c.line([P(220, 292), P(226, 286)], "boca", 4 * s)
    elif mouth == "gruñido":
        c.poly([P(158, 286), P(226, 286), P(220, 304), P(164, 304)], "boca")
        c.rect(P(164, 288)[0], P(164, 288)[1], P(220, 296)[0], P(220, 296)[1], "blanco")
        c.line([P(150, 296), P(158, 286)], "boca", 4 * s)
        c.line([P(234, 296), P(226, 286)], "boca", 4 * s)
    else:
        c.line([P(156, 288), P(176, 298), P(200, 300), P(222, 294), P(236, 280)], "boca", 6 * s)
        c.line([P(236, 280), P(242, 272)], "boca", 4 * s)
    c.line([P(178, 316), P(206, 318)], "piel_sombra", 3 * s)


def paint_shirt(c, spec, rings):
    """Base, cuello, bajo y dorsales; el diseño propio llega en spec["shirt"](c, reg, v, px_u)."""
    reg = REGIONS["camiseta"]
    x0, y0, x1, y1 = reg
    c.rect(x0, y0, x1, y1, "base")
    w_px, h_px = x1 - x0, y1 - y0
    length = sum((Vector(rings[i + 1][0]) - Vector(rings[i][0])).length for i in range(len(rings) - 1))
    px_v = h_px / length
    px_u = (w_px / (2 * 3.14159265)) / 0.266

    def v(z):
        return level(rings, z)
    c.rect(x0, y0, x1, y0 + v(1.405) * h_px, spec.get("collar", "acento"))
    if spec.get("v_neck", True):
        c.poly([(x0 + 0.205 * w_px, y0), (x0 + 0.295 * w_px, y0), (x0 + 0.25 * w_px, y0 + v(1.315) * h_px)], spec.get("collar", "acento"))
        c.poly([(x0 + 0.222 * w_px, y0), (x0 + 0.278 * w_px, y0), (x0 + 0.25 * w_px, y0 + v(1.345) * h_px)], "base_oscuro")
    if spec.get("shirt"):
        spec["shirt"](c, reg, v, px_u)
    c.rect(x0, y0 + v(0.865) * h_px, x1, y1, "base_oscuro")
    ink = spec.get("number_color", "blanco")
    number(c, spec["number"], x0 + 0.185 * w_px, y0 + v(1.285) * h_px, 0.11 * px_v, 0.11 * px_u, ink)
    number(c, spec["number"], x0 + 0.75 * w_px, y0 + v(1.29) * h_px, 0.22 * px_v, 0.22 * px_u, ink)


def paint_arm(c, spec, rings):
    reg = REGIONS["brazo"]
    x0, y0, x1, y1 = reg
    c.rect(x0, y0, x1, y1, "piel")

    def v(z):
        return y0 + level(rings, z) * (y1 - y0)
    if spec.get("arm"):
        spec["arm"](c, reg, v)


def paint_short(c, spec, side):
    """Pierna del short: franja en el lateral exterior; dorsal en la izquierda del personaje."""
    reg = REGIONS["short_" + side]
    x0, y0, x1, y1 = reg
    c.rect(x0, y0, x1, y1, "short")
    w_px, h_px = x1 - x0, y1 - y0
    stripe, ink = 0.05, spec.get("short_stripe", "acento")
    if side == "R":  # exterior = ángulo 0 (bordes del desenvuelto)
        c.rect(x0, y0, x0 + stripe * w_px, y1, ink)
        c.rect(x1 - stripe * w_px, y0, x1, y1, ink)
    else:  # exterior = ángulo 180° (centro)
        c.rect(x0 + (0.5 - stripe) * w_px, y0, x0 + (0.5 + stripe) * w_px, y1, ink)
        number(c, spec["number"], x0 + 0.27 * w_px, y0 + 0.42 * h_px, 0.42 * h_px, 0.075 * w_px, spec.get("short_number_color", "blanco"))
    c.rect(x0, y1 - 6, x1, y1, "base_oscuro")


def paint(path, spec):
    c = Canvas(colors_for(spec))
    for name, (x, y) in SWATCHES.items():
        c.rect(x - 32, y - 32, x + 32, y + 32, name)
    paint_shirt(c, spec, torso_rings(spec))
    paint_face(c, spec.get("face", {}))
    paint_arm(c, spec, arm_rings(spec, 1))
    paint_short(c, spec, "R")
    paint_short(c, spec, "L")
    c.save(path)
    return path


# --- Clips ------------------------------------------------------------------------
def combat_stance(breath, arm_out=22, crouch=1.0):
    """Guardia: piernas abiertas, rodillas flexionadas, manos listas."""
    return mirror(P(
        hips=((0, 0, 0), (0, 0, (-0.04 - 0.012 * breath) * crouch)),
        spine=(-8 + 3 * breath, 0, 0), chest=(-2 + 3 * breath, 0, 0), head=(6 - 3 * breath, 0, 2 * breath),
        upper_arm_L=(10 + 4 * breath, arm_out - 4 * breath, 0), forearm_L=(38 + 4 * breath, 0, 0), hand_L=(0, 0, 10),
        thigh_L=(18 * crouch, 6, 0), shin_L=(-30 * crouch, 0, 0), foot_L=(12 * crouch, 0, 0),
    ))


def attack_keys(neutral):
    """Ataque (clip `kick`): disparo con todo el cuerpo; golpe en el cuadro 4."""
    return [
        (0, neutral),
        (2, {**neutral, **P(hips=((0, 0, -12), (0, 0, -0.02)), spine=(8, 0, 14), chest=(4, 0, 8),
                            thigh_R=(-30, -6, 0), shin_R=(-70, 0, 0), thigh_L=(16, 6, 0), shin_L=(-24, 0, 0),
                            upper_arm_R=(-40, -30, 0), forearm_R=(60, 0, 0), upper_arm_L=(30, 40, 0), forearm_L=(40, 0, 0))}),
        (4, {**neutral, **P(hips=((0, 0, 10), (0, 0, -0.03)), spine=(-14, 0, -14), chest=(-6, 0, -8), head=(10, 0, 0),
                            thigh_R=(85, -4, 0), shin_R=(-6, 0, 0), foot_R=(-25, 0, 0), thigh_L=(14, 4, 0), shin_L=(-22, 0, 0),
                            upper_arm_R=(70, -20, 0), forearm_R=(10, 0, 0), upper_arm_L=(-40, 45, 0), forearm_L=(50, 0, 0))}),
        (6, {**neutral, **P(spine=(-10, 0, -10), thigh_R=(70, -4, 0), shin_R=(-20, 0, 0), foot_R=(-15, 0, 0),
                            thigh_L=(12, 4, 0), shin_L=(-20, 0, 0), upper_arm_R=(55, -20, 0), upper_arm_L=(-30, 38, 0))}),
        (12, neutral),
    ]


def default_clips(spec):
    stance = spec.get("stance", {})
    neutral = combat_stance(0, **stance)
    return {
        "idle": [(0, combat_stance(0, **stance)), (24, combat_stance(1, **stance)), (48, combat_stance(0, **stance))],
        "run": [(f, run_pose(f, **spec.get("run", {}))) for f in (0, 4, 8, 12, 16)],
        "kick": spec["attack"](neutral) if spec.get("attack") else attack_keys(neutral),
        "hit": hit_keys(neutral),
        "celebrate": celebrate_keys(),
    }


def build(spec, here):
    """Pinta el atlas y genera art/<id>/<id>.blend y el GLB del héroe."""
    hero_id = spec["id"]
    png = paint(Path(here) / f"{hero_id}_atlas.png", spec)
    build_hero(hero_id, {f"M_{hero_id.capitalize()}_Atlas": 0.78}, bones(spec), build_mesh(spec), default_clips(spec),
               [("Muzzle", "chest", (0.0, 0.45, 1.05)), ("VFXOrigin", "chest", (0.0, 0.0, 1.1))],
               atlas=(png, SIZE, SWATCHES))
