"""El Turbo #11 — generador reproducible del modelo, rig y clips (V3 provisional).

MODELO PROVISIONAL V3: traduce la referencia visual V2 aceptada por el propietario
(design/personajes/turbo/bocetos/turbo-v2-propuesta-01.png) a un GLB jugable.
Pendiente de revisión; no es arte final. Diseño original: equipación azul con
detalles rojos, pelo blanco en punta, rostro caricaturesco propio y tatuajes
tribales de diseño propio. Sin escudos, patrocinadores, logos ni rostros reales.

Cuerpo continuo (tubos con pesos suaves en codos, rodillas y cintura) y un único
material con atlas 1024 pintado por art/turbo/paint_turbo_atlas.py.

Uso (Blender 5.2 o módulo bpy 5.2 de PyPI, ambos gratuitos):
    python art/turbo/build_turbo.py            # con `pip install bpy==5.2.3 pillow`
Salidas: art/turbo/turbo_atlas.png, art/turbo/turbo.blend y game/assets/models/turbo/turbo.glb.
"""
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "lib"))
sys.path.insert(0, str(HERE))
from hero_kit import P, Vector, build_hero, celebrate_keys, hit_keys, mirror, run_pose  # noqa: E402
import paint_turbo_atlas as atlas  # noqa: E402

PALETTE = {"M_Turbo_Atlas": 0.78}

BONES = [
    ("root", (0, 0, 0), (0, 0.25, 0), None),
    ("hips", (0, 0, 0.84), (0, 0, 0.98), "root"),
    ("spine", (0, 0, 0.98), (0, 0, 1.15), "hips"),
    ("chest", (0, 0, 1.15), (0, 0, 1.40), "spine"),
    ("head", (0, 0, 1.40), (0, 0, 1.86), "chest"),
]
for _side, _s in (("L", -1), ("R", 1)):
    BONES += [
        (f"upper_arm.{_side}", (_s * 0.26, 0, 1.32), (_s * 0.33, 0, 1.06), "chest"),
        (f"forearm.{_side}", (_s * 0.33, 0, 1.06), (_s * 0.37, 0.02, 0.80), f"upper_arm.{_side}"),
        (f"hand.{_side}", (_s * 0.37, 0.02, 0.80), (_s * 0.38, 0.03, 0.66), f"forearm.{_side}"),
    ]
for _side, _s in (("L", -1), ("R", 1)):
    BONES += [
        (f"thigh.{_side}", (_s * 0.12, 0, 0.84), (_s * 0.145, 0, 0.50), "hips"),
        (f"shin.{_side}", (_s * 0.145, 0, 0.50), (_s * 0.16, 0, 0.15), f"thigh.{_side}"),
        (f"foot.{_side}", (_s * 0.16, 0, 0.15), (_s * 0.17, 0.17, 0.06), f"shin.{_side}"),
    ]

HEAD_C = (0.0, 0.015, 1.63)
HEAD_R = (0.175, 0.17, 0.2)
HEAD_SCALE = 1.12


def torso_rings():
    """Camiseta: anillos de arriba abajo (z, rx, ry, desplazamiento y)."""
    spec = [
        (1.445, 0.082, 0.078, 0.0), (1.41, 0.15, 0.11, 0.0), (1.375, 0.232, 0.138, 0.0),
        (1.325, 0.262, 0.152, 0.005), (1.245, 0.266, 0.16, 0.012), (1.145, 0.252, 0.156, 0.012),
        (1.045, 0.236, 0.146, 0.008), (0.965, 0.236, 0.146, 0.004), (0.885, 0.246, 0.152, 0.0),
        (0.845, 0.252, 0.156, 0.0),
    ]
    rings = []
    for z, rx, ry, dy in spec:
        w = {"chest": 1.0} if z > 1.2 else ({"chest": 0.5, "spine": 0.5} if z > 1.1 else
                                            ({"spine": 1.0} if z > 0.99 else {"spine": 0.5, "hips": 0.5}))
        if z < 0.9:
            w = {"hips": 0.8, "spine": 0.2}
        rings.append(((0, dy, z), rx, ry, "uv", w))
    return rings


def arm_rings(s):
    """Brazo de hombro a muñeca: manga azul, puño rojo, piel tatuada (atlas)."""
    up, fo, ha = (f"{n}.{'R' if s > 0 else 'L'}" for n in ("upper_arm", "forearm", "hand"))
    return [
        ((s * 0.17, 0, 1.335), 0.085, 0.085, "azul", {"chest": 1.0}),
        ((s * 0.25, 0, 1.335), 0.097, 0.095, "azul", {"chest": 0.5, up: 0.5}),
        ((s * 0.295, 0, 1.255), 0.093, 0.09, "azul", {up: 1.0}),
        ((s * 0.31, 0, 1.175), 0.089, 0.087, "rojo", {up: 1.0}),
        ((s * 0.315, 0, 1.14), 0.088, 0.086, "rojo", {up: 1.0}),
        ((s * 0.316, 0, 1.138), 0.074, 0.072, "uv", {up: 1.0}),
        ((s * 0.322, 0, 1.10), 0.076, 0.073, "uv", {up: 0.9, fo: 0.1}),
        ((s * 0.33, 0, 1.06), 0.064, 0.062, "uv", {up: 0.5, fo: 0.5}),
        ((s * 0.343, 0.008, 0.985), 0.075, 0.072, "uv", {fo: 0.85, up: 0.15}),
        ((s * 0.355, 0.016, 0.89), 0.066, 0.063, "uv", {fo: 1.0}),
        ((s * 0.368, 0.02, 0.805), 0.054, 0.052, "piel", {fo: 0.7, ha: 0.3}),
        ((s * 0.372, 0.022, 0.77), 0.046, 0.044, "piel", {fo: 0.3, ha: 0.7}),
    ]


def leg_rings(s):
    """Pierna de cadera a tobillo: muslo, rodilla, media azul con banda roja."""
    th, sh, ft = (f"{n}.{'R' if s > 0 else 'L'}" for n in ("thigh", "shin", "foot"))
    return [
        ((s * 0.115, 0, 0.80), 0.092, 0.092, "piel", {"hips": 0.4, th: 0.6}),
        ((s * 0.13, 0.004, 0.68), 0.104, 0.1, "piel", {th: 1.0}),
        ((s * 0.14, 0.006, 0.585), 0.094, 0.09, "piel", {th: 1.0}),
        ((s * 0.145, 0.01, 0.50), 0.078, 0.076, "piel", {th: 0.5, sh: 0.5}),
        ((s * 0.147, 0.006, 0.472), 0.079, 0.077, "rojo", {th: 0.3, sh: 0.7}),
        ((s * 0.147, 0.006, 0.47), 0.09, 0.088, "rojo", {th: 0.3, sh: 0.7}),
        ((s * 0.149, 0.004, 0.405), 0.09, 0.088, "azul", {sh: 1.0}),
        ((s * 0.152, -0.004, 0.33), 0.087, 0.086, "azul", {sh: 1.0}),
        ((s * 0.157, 0.0, 0.24), 0.07, 0.07, "azul", {sh: 1.0}),
        ((s * 0.16, 0.004, 0.155), 0.058, 0.06, "azul", {sh: 0.7, ft: 0.3}),
    ]


def short_leg_rings(s):
    th = f"thigh.{'R' if s > 0 else 'L'}"
    return [
        ((s * 0.105, 0, 0.84), 0.13, 0.13, "uv", {"hips": 0.7, th: 0.3}),
        ((s * 0.125, 0.004, 0.70), 0.135, 0.132, "uv", {"hips": 0.3, th: 0.7}),
        ((s * 0.138, 0.006, 0.605), 0.128, 0.124, "uv", {"hips": 0.15, th: 0.85}),
    ]


def short_waist_rings():
    return [((0, 0, z), rx, ry, "azul", {"hips": 1.0}) for z, rx, ry in
            ((0.93, 0.232, 0.146), (0.84, 0.245, 0.155), (0.76, 0.235, 0.15))]


def head_shape(p):
    """Mandíbula algo más estrecha y mentón marcado, sin rasgos de una persona real."""
    t = max(0.0, -p.z / HEAD_R[2])
    p.x *= 1 - 0.22 * t * t
    if p.y > 0:
        p.y *= 1 - 0.12 * t
    return p


def hand(b, side, s):
    """Mano grande y abierta (palma hacia el muslo), dedos algo flexionados."""
    bone = f"hand.{side}"
    wx = s * 0.375
    b.box("piel", bone, (wx, 0.03, 0.725), (0.06, 0.1, 0.1), bevel=0.025, segments=2)
    for i, dy in enumerate((-0.03, -0.006, 0.018, 0.042)):
        length = 0.06 if i in (1, 2) else 0.052
        b.box("piel", bone, (wx - s * 0.006, dy + 0.004, 0.66 - (0.004 if i in (1, 2) else 0)),
              (0.04, 0.022, length), bevel=0.01, segments=1, rot=(0, -s * 12, 0))
    b.box("piel", bone, (wx - s * 0.02, 0.08, 0.735), (0.032, 0.026, 0.06), bevel=0.011, segments=1, rot=(30, s * 20, 0))


def boot(b, side, s):
    """Botín blanco con talón y franja rojos, suela azul y cordones."""
    bone, x = f"foot.{side}", s * 0.16
    b.box("blanco", bone, (x, 0.035, 0.095), (0.15, 0.27, 0.13), bevel=0.05, segments=2, taper_top=0.82, taper_depth=0.75)
    b.sphere("blanco", bone, (x, 0.15, 0.062), (0.074, 0.085, 0.058), u=12, v=8)
    b.box("rojo", bone, (x, 0.04, 0.045), (0.158, 0.31, 0.03), bevel=0.012, segments=1)
    b.sphere("rojo", bone, (x, 0.17, 0.045), (0.07, 0.07, 0.02), u=10, v=4)
    b.box("rojo", bone, (x, -0.085, 0.1), (0.135, 0.06, 0.11), bevel=0.025, segments=1)
    b.box("azul", bone, (x, 0.04, 0.015), (0.162, 0.335, 0.03), bevel=0.012, segments=1)
    for i in range(3):
        b.box("gris", bone, (x, 0.05 + i * 0.033, 0.158 - i * 0.016), (0.07, 0.012, 0.01), rot=(-25, 0, 0), smooth=False)
    b.box("azul", bone, (x + s * 0.077, 0.03, 0.09), (0.008, 0.13, 0.022), rot=(-18, 0, 0), smooth=False)
    b.limb("blanco", bone, (x, 0.0, 0.14), (x, 0.0, 0.2), 0.072, 0.07, segments=12)


HAIR = [  # base, dirección, longitud, radio, curvatura, muestra: mechones barridos hacia arriba y atrás
    ((0.0, 0.06, 1.84), (0, -0.1, 1), 0.2, 0.08, (0, -0.35, 0), "pelo"),
    ((0.08, 0.02, 1.83), (0.35, -0.25, 1), 0.19, 0.075, (0.1, -0.3, 0), "pelo_sombra"),
    ((-0.08, 0.02, 1.83), (-0.35, -0.25, 1), 0.19, 0.075, (-0.1, -0.3, 0), "pelo"),
    ((0.04, 0.11, 1.81), (0.15, 0.35, 1), 0.18, 0.07, (0, -0.25, 0), "pelo"),
    ((-0.06, 0.1, 1.81), (-0.25, 0.3, 1), 0.16, 0.065, (0, -0.25, 0), "pelo_sombra"),
    ((0.14, 0.04, 1.78), (0.75, -0.1, 0.75), 0.17, 0.065, (0, -0.2, 0.05), "pelo"),
    ((-0.14, 0.04, 1.78), (-0.75, -0.1, 0.75), 0.17, 0.065, (0, -0.2, 0.05), "pelo"),
    ((0.0, -0.1, 1.80), (0, -0.8, 0.7), 0.2, 0.08, (0, 0, 0.1), "pelo_sombra"),
    ((0.1, -0.09, 1.77), (0.4, -0.8, 0.5), 0.19, 0.07, (0, 0, 0.08), "pelo"),
    ((-0.1, -0.09, 1.77), (-0.4, -0.8, 0.5), 0.19, 0.07, (0, 0, 0.08), "pelo_sombra"),
    ((0.0, -0.16, 1.70), (0, -1, 0.15), 0.16, 0.07, (0, 0, 0.05), "pelo"),
    ((0.1, -0.14, 1.68), (0.5, -0.9, 0.0), 0.14, 0.06, (0, 0, 0.04), "pelo"),
    ((-0.1, -0.14, 1.68), (-0.5, -0.9, 0.0), 0.14, 0.06, (0, 0, 0.04), "pelo"),
    ((0.0, -0.165, 1.58), (0, -0.8, -0.5), 0.1, 0.05, (0, 0, 0), "pelo_sombra"),
    ((0.09, -0.145, 1.57), (0.4, -0.8, -0.5), 0.09, 0.045, (0, 0, 0), "pelo"),
    ((-0.09, -0.145, 1.57), (-0.4, -0.8, -0.5), 0.09, 0.045, (0, 0, 0), "pelo"),
    ((0.17, 0.0, 1.74), (1, -0.3, 0.3), 0.14, 0.055, (0, -0.1, 0.05), "pelo"),
    ((-0.17, 0.0, 1.74), (-1, -0.3, 0.3), 0.14, 0.055, (0, -0.1, 0.05), "pelo_sombra"),
    ((0.165, 0.05, 1.68), (0.6, 0.1, -0.8), 0.09, 0.04, (0, 0, 0), "pelo"),
    ((-0.165, 0.05, 1.68), (-0.6, 0.1, -0.8), 0.09, 0.04, (0, 0, 0), "pelo"),
    # Flequillo: pocos mechones en punta, barridos hacia la derecha del personaje; cejas visibles.
    ((0.04, 0.16, 1.79), (0.5, 0.55, -0.65), 0.14, 0.055, (0.04, 0, 0), "pelo"),
    ((-0.05, 0.165, 1.785), (0.15, 0.6, -0.8), 0.11, 0.05, (0, 0, 0), "pelo_sombra"),
    ((-0.13, 0.12, 1.77), (-0.6, 0.5, -0.5), 0.1, 0.045, (0, 0, 0), "pelo"),
    ((0.13, 0.12, 1.775), (0.8, 0.4, -0.4), 0.11, 0.048, (0, 0, 0), "pelo"),
]


def build_mesh(b):
    b.tube(torso_rings(), segments=18, region=atlas.REGIONS["camiseta"], cap_end="azul_oscuro")
    b.tube(short_waist_rings(), segments=16, cap_end="azul_oscuro")
    b.tube([((0, 0, 1.37), 0.068, 0.066, "piel", {"chest": 1.0}), ((0, 0.005, 1.45), 0.066, 0.064, "piel", {"chest": 0.5, "head": 0.5}),
            ((0, 0.01, 1.53), 0.062, 0.06, "piel", {"head": 1.0})], segments=10)
    for side, s in (("L", -1), ("R", 1)):
        b.tube(arm_rings(s), segments=12, region=atlas.REGIONS["brazo"], cap_end="piel")
        b.tube(leg_rings(s), segments=12)
        b.tube(short_leg_rings(s), segments=14, region=atlas.REGIONS["short_" + side])
        hand(b, side, s)
        boot(b, side, s)
    # Cabeza caricaturesca (escalada desde el cuello) con rostro pintado en el atlas.
    head_start = b.mark()
    for s in (-1, 1):
        b.sphere("piel", "head", (s * 0.168, 0.0, 1.615), (0.028, 0.042, 0.058), u=8, v=6)
    b.textured_ellipsoid("head", HEAD_C, HEAD_R, atlas.REGIONS["cara"], "piel", u=24, v=16, deform=head_shape)
    b.sphere("piel", "head", (0, 0.178, 1.598), (0.019, 0.015, 0.016), u=8, v=6)
    # Pelo blanco: casquete hasta la nuca que deja libre la frente, y mechones curvos.
    cx, cy, cz = HEAD_C
    b.partial_sphere("pelo", "head", (cx, cy - 0.012, 1.65), (0.188, 0.188, 0.215),
                     keep=lambda p: p.z > 1.745 - 0.09 * min(1.0, abs(p.x) / 0.17) or (p.y < cy - 0.03 and p.z > 1.47),
                     u=20, v=14)
    for base, direction, length, radius, bend, swatch in HAIR:
        b.horn(swatch, "head", base, direction, length, radius, bend=bend, flat=0.62)
    b.scale_since(head_start, (0, 0, 1.46), HEAD_SCALE)


def attack_keys(neutral):
    """Ataque (clip `kick`): disparo eléctrico con todo el cuerpo; golpe en el cuadro 4."""
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


def combat_stance(breath):
    """Guardia de la lámina V2: piernas abiertas, rodillas flexionadas, manos listas."""
    return mirror(P(
        hips=((0, 0, 0), (0, 0, -0.04 - 0.012 * breath)),
        spine=(-8 + 3 * breath, 0, 0), chest=(-2 + 3 * breath, 0, 0), head=(6 - 3 * breath, 0, 2 * breath),
        upper_arm_L=(10 + 4 * breath, 22 - 4 * breath, 0), forearm_L=(38 + 4 * breath, 0, 0), hand_L=(0, 0, 10),
        thigh_L=(18, 6, 0), shin_L=(-30, 0, 0), foot_L=(12, 0, 0),
    ))


def clips():
    neutral = combat_stance(0)
    return {
        "idle": [(0, combat_stance(0)), (24, combat_stance(1)), (48, combat_stance(0))],
        # Zancada larga de velocista con fase aérea; run_clip_speed = 3.9 m/s en turbo.tres.
        "run": [(f, run_pose(f, lean=-18, arm_swing=1.25, arm_out=16, bob=0.08, stride=1.25)) for f in (0, 4, 8, 12, 16)],
        "kick": attack_keys(neutral),
        "hit": hit_keys(neutral),
        "celebrate": celebrate_keys(),
    }


if __name__ == "__main__":
    png = atlas.paint(HERE / "turbo_atlas.png", torso_rings(), arm_rings(1), short_leg_rings(1))
    build_hero("turbo", PALETTE, BONES, build_mesh, clips(),
               [("Muzzle", "chest", (0.0, 0.45, 1.05)), ("VFXOrigin", "chest", (0.0, 0.0, 1.1))],
               atlas=(png, atlas.SIZE, atlas.SWATCHES))
