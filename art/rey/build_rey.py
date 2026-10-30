"""El Rey / King #23 — generador reproducible del modelo, rig y clips (muestra V0).

MUESTRA PROVISIONAL: primera forma para revisión del propietario; no es arte final.
Diseño original: tanque ancho en blanco y negro con sello propio — corona dorada,
banda de puntas de corona en el pecho, hombreras negras y capa corta violeta.
Sin escudos, patrocinadores, logos ni rostro de personas reales.

Uso: python art/rey/build_rey.py  (o blender --background --python ...)
Salidas: art/rey/rey.blend y game/assets/models/rey/rey.glb.
"""
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hero_kit import P, Vector, build_hero, celebrate_keys, hit_keys, make_bones, number, run_pose, stance  # noqa: E402

PALETTE = {
    "M_Rey_Blanco": ("f2f2ef", 0.80, 0.0, None),   # camiseta, medias
    "M_Rey_Negro": ("18181c", 0.70, 0.0, None),    # short, botas, hombreras, banda corona
    "M_Rey_Oro": ("f2b632", 0.50, 0.0, None),      # corona, ribetes, punteras
    "M_Rey_Violeta": ("5b2a86", 0.75, 0.0, None),  # capa corta (enlace con la Onda Real)
    "M_Rey_Piel": ("a8724f", 0.85, 0.0, None),     # piel caricaturesca
    "M_Rey_Brillo": ("ffc94d", 0.40, 0.0, 1.3),    # visor ámbar (emisivo)
}
W, K, O, V, S, G = PALETTE
BONES = make_bones(shoulder_x=0.36, hip_x=0.15, arm_drop=0.04, hip_z=0.76, chest_top=1.36)


def build_mesh(b):
    for side, sx in (("L", -1), ("R", 1)):
        x = 0.15 * sx
        # Botas negras grandes con puntera dorada.
        b.box(K, f"foot.{side}", (x, 0.05, 0.09), (0.21, 0.38, 0.16), bevel=0.05, segments=3, taper_top=0.88, taper_depth=0.82)
        b.box(K, f"foot.{side}", (x, 0.05, 0.018), (0.22, 0.39, 0.036), bevel=0.012, segments=1)
        b.box(O, f"foot.{side}", (x, 0.2, 0.065), (0.17, 0.08, 0.09), bevel=0.03, segments=2)
        # Medias blancas con banda negra; piernas gruesas.
        b.limb(W, f"shin.{side}", (x, 0, 0.15), (x, 0, 0.44), 0.085, 0.097)
        b.limb(K, f"shin.{side}", (x, 0, 0.39), (x, 0, 0.45), 0.1, 0.1)
        b.sphere(S, f"shin.{side}", (x, 0.0, 0.48), (0.085, 0.085, 0.085), u=10, v=6)
        b.limb(S, f"thigh.{side}", (x, 0, 0.5), (x, 0, 0.68), 0.095, 0.115)
        # Brazos: manga blanca, puño negro, piel y guante negro con nudillera dorada.
        sh = Vector((0.36 * sx, 0, 1.25))
        el = Vector((0.42 * sx, 0, 0.98))
        wr = Vector((0.45 * sx, 0, 0.77))
        b.sphere(W, f"upper_arm.{side}", sh + Vector((0.01 * sx, 0, -0.03)), (0.125, 0.12, 0.115), u=10, v=6)
        b.limb(W, f"upper_arm.{side}", sh, sh.lerp(el, 0.45), 0.112, 0.1)
        b.limb(K, f"upper_arm.{side}", sh.lerp(el, 0.42), sh.lerp(el, 0.52), 0.104, 0.102)
        b.limb(S, f"upper_arm.{side}", sh.lerp(el, 0.5), el, 0.078, 0.072, segments=8)
        b.sphere(S, f"forearm.{side}", el, (0.074, 0.074, 0.074), u=8, v=6)
        b.limb(S, f"forearm.{side}", el, wr, 0.072, 0.078, segments=8)
        b.limb(K, f"forearm.{side}", el.lerp(wr, 0.8), el.lerp(wr, 0.98), 0.085, 0.087, segments=8)
        b.sphere(K, f"hand.{side}", wr + Vector((0.01 * sx, 0.01, -0.08)), (0.11, 0.115, 0.12), u=10, v=7)
        b.box(O, f"hand.{side}", wr + Vector((0.01 * sx, 0.1, -0.06)), (0.13, 0.04, 0.05), bevel=0.015, segments=1)
        # Hombreras negras: silueta de bloque protector.
        b.box(K, "chest", (0.33 * sx, 0, 1.33), (0.2, 0.3, 0.1), bevel=0.04, segments=2, rot=(0, -18 * sx, 0))
        b.box(O, "chest", (0.33 * sx, 0, 1.285), (0.21, 0.31, 0.02), bevel=0.006, segments=1, rot=(0, -18 * sx, 0))
    # Short negro con franja blanca.
    b.box(K, "hips", (0, 0, 0.72), (0.46, 0.3, 0.2), bevel=0.06, segments=2, taper_top=1.02)
    for sx in (-1, 1):
        b.box(W, "hips", (0.228 * sx, 0, 0.7), (0.012, 0.09, 0.16), smooth=False)
    # Torso ancho blanco.
    b.box(W, "spine", (0, 0, 0.94), (0.46, 0.32, 0.3), bevel=0.07, segments=2, taper_top=1.1)
    b.box(W, "chest", (0, 0, 1.2), (0.56, 0.34, 0.28), bevel=0.09, segments=2, taper_top=1.2, taper_depth=0.95)
    # Banda de corona en el pecho: franja negra con tres puntas (motivo propio).
    front = 0.172
    b.box(K, "spine", (0, front - 0.004, 1.07), (0.5, 0.012, 0.07), smooth=False)
    for dx, h in ((-0.15, 0.11), (0.0, 0.15), (0.15, 0.11)):
        b.spike(K, "chest", (dx, front - 0.002, 1.09), (0, 0, 1), 0.06, h, segments=3, flat=0.12, roll=math.pi / 2)
    b.box(O, "spine", (0, front + 0.002, 1.035), (0.5, 0.012, 0.016), smooth=False)
    number(b, K, "chest", "23", (-0.13, front + 0.004, 1.27), 0.08, "front")
    # Espalda: capa corta violeta con ribete y dorsal 23 dorados (sello del King).
    b.box(V, "chest", (0, -0.215, 1.1), (0.56, 0.035, 0.44), bevel=0.012, segments=1, taper_top=0.82)
    b.box(O, "chest", (0, -0.218, 0.885), (0.58, 0.042, 0.03), bevel=0.008, segments=1)
    number(b, O, "chest", "23", (0, -0.236, 1.1), 0.2, "back")
    # Cuello grueso y cabeza de mandíbula cuadrada.
    b.limb(S, "chest", (0, 0, 1.32), (0, 0, 1.42), 0.1, 0.095, segments=10)
    b.limb(K, "chest", (0, 0, 1.33), (0, 0, 1.37), 0.14, 0.12, segments=12)
    hc = Vector((0, 0.01, 1.64))
    b.sphere(S, "head", hc, (0.27, 0.26, 0.26), u=18, v=12)
    b.box(S, "head", hc + Vector((0, 0.03, -0.14)), (0.4, 0.3, 0.14), bevel=0.06, segments=2)
    for sx in (-1, 1):
        b.sphere(S, "head", hc + Vector((0.265 * sx, -0.01, -0.02)), (0.04, 0.06, 0.07), u=8, v=5)
        b.box(K, "head", hc + Vector((0.085 * sx, 0.24, 0.085)), (0.12, 0.03, 0.03), bevel=0.01, segments=1, rot=(0, 10 * sx, 0))
    b.sphere(S, "head", hc + Vector((0, 0.265, -0.04)), (0.045, 0.04, 0.04), u=8, v=5)
    b.box(K, "head", hc + Vector((0, 0.245, -0.15)), (0.13, 0.02, 0.03), bevel=0.01, segments=1, rot=(-10, 0, 0))
    b.arc_band(G, "head", hc + Vector((0, 0, 0.02)), 0.272, 0.075, 20, 160, 0.02, segments=14, scale=(1.02, 1.0, 1))
    # Pelo corto negro y corona dorada de cinco puntas con gema violeta.
    b.sphere(K, "head", hc + Vector((0, -0.02, 0.07)), (0.272, 0.265, 0.21), u=16, v=8)
    crown_z = hc.z + 0.2
    b.arc_band(O, "head", Vector((0, -0.01, crown_z)), 0.19, 0.08, 0, 360, 0.025, segments=20)
    for i in range(5):
        ang = math.radians(90 + i * 72)
        base = Vector((math.cos(ang) * 0.19, math.sin(ang) * 0.19 - 0.01, crown_z + 0.03))
        b.spike(O, "head", base, (math.cos(ang) * 0.25, math.sin(ang) * 0.25, 1), 0.045, 0.13, segments=4)
    b.sphere(V, "head", Vector((0, 0.2, crown_z)), (0.03, 0.02, 0.035), u=8, v=5)


def clips():
    neutral = stance(0, arm_out=22, leg_out=6, lean=-2)
    return {
        "idle": [(0, neutral), (24, stance(1, arm_out=22, leg_out=6, lean=-2)), (48, neutral)],
        "run": [(f, run_pose(f, lean=-10, arm_swing=0.7, arm_out=22, bob=0.04)) for f in (0, 4, 8, 12, 16)],
        # Golpe real: gancho de derecha con paso; impacto en el cuadro 4 (0,13 s).
        "kick": [
            (0, neutral),
            (2, {**neutral, **P(spine=(4, 0, 22), chest=(0, 0, 10), upper_arm_R=(-35, -55, 0), forearm_R=(100, 0, 0),
                                upper_arm_L=(25, 30, 0), forearm_L=(70, 0, 0), thigh_L=(18, 6, 0), shin_L=(-25, 0, 0))}),
            (4, {**neutral, **P(spine=(-12, 0, -24), chest=(-6, 0, -12), head=(6, 0, 0), upper_arm_R=(85, -18, 0), forearm_R=(12, 0, 0),
                                upper_arm_L=(-30, 32, 0), forearm_L=(80, 0, 0), thigh_L=(26, 6, 0), shin_L=(-32, 0, 0),
                                thigh_R=(-12, -6, 0), shin_R=(-8, 0, 0))}),
            (6, {**neutral, **P(spine=(-10, 0, -18), upper_arm_R=(75, -20, 0), forearm_R=(20, 0, 0), upper_arm_L=(-20, 30, 0),
                                thigh_L=(22, 6, 0), shin_L=(-28, 0, 0))}),
            (12, neutral),
        ],
        "hit": hit_keys(neutral, arm_out=40),
        "celebrate": celebrate_keys(jump=0.18, arm_up=125),
    }


if __name__ == "__main__":
    build_hero("rey", PALETTE, BONES, build_mesh, clips(),
               [("Muzzle", "chest", (0.0, 0.5, 1.05)), ("VFXOrigin", "chest", (0.0, 0.0, 1.1))])
