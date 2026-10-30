"""El Príncipe — generador reproducible del modelo, rig y clips (muestra V0).

MUESTRA PROVISIONAL: solo arte. Sin gameplay ni ficha aprobada (C1, Codex).
Dorsal 20 decidido por el propietario el 2026-10-30. No es arte final.
Diseño original del estratega: azul con detalles rojos (mismo equipo que Turbo),
silueta esbelta y elegante, banda real roja cruzada, una charretera roja y visor
táctico oscuro con lente roja de precisión. Peinado oscuro peinado hacia un lado.
Sin escudos, patrocinadores, logos ni rostro de personas reales.

Uso: python art/principe/build_principe.py
Salidas: art/principe/principe.blend y game/assets/models/principe/principe.glb.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hero_kit import P, Vector, build_hero, hit_keys, make_bones, number, run_pose, stance  # noqa: E402

PALETTE = {
    "M_Principe_Azul": ("1a37a8", 0.70, 0.0, None),    # camiseta, short, medias
    "M_Principe_Rojo": ("d92332", 0.65, 0.0, None),    # banda, charretera, ribetes
    "M_Principe_Blanco": ("f1f3f7", 0.80, 0.0, None),  # botas, flecos, puños
    "M_Principe_Piel": ("d9a07c", 0.85, 0.0, None),    # piel
    "M_Principe_Noche": ("191b2b", 0.60, 0.0, None),   # pelo, visor, guantes, suelas
    "M_Principe_Lente": ("ff4d4d", 0.35, 0.0, 1.6),    # lente de precisión (emisivo)
}
A, R, W, S, N, L = PALETTE
BONES = make_bones(shoulder_x=0.26, hip_x=0.115, hip_z=0.82, chest_top=1.34)


def build_mesh(b):
    for side, sx in (("L", -1), ("R", 1)):
        x = 0.115 * sx
        # Botas blancas estilizadas con talón rojo.
        b.box(W, f"foot.{side}", (x, 0.05, 0.08), (0.16, 0.34, 0.14), bevel=0.05, segments=3, taper_top=0.85, taper_depth=0.78)
        b.box(N, f"foot.{side}", (x, 0.05, 0.016), (0.17, 0.35, 0.032), bevel=0.01, segments=1)
        b.box(R, f"foot.{side}", (x, -0.1, 0.07), (0.15, 0.06, 0.1), bevel=0.025, segments=2)
        # Medias azules largas con doble ribete rojo.
        b.limb(A, f"shin.{side}", (x, 0, 0.14), (x, 0, 0.46), 0.062, 0.075)
        b.limb(R, f"shin.{side}", (x, 0, 0.41), (x, 0, 0.43), 0.078, 0.078)
        b.limb(R, f"shin.{side}", (x, 0, 0.445), (x, 0, 0.465), 0.078, 0.078)
        b.sphere(S, f"shin.{side}", (x, 0.0, 0.49), (0.065, 0.065, 0.065), u=10, v=6)
        b.limb(S, f"thigh.{side}", (x, 0, 0.5), (x, 0, 0.74), 0.07, 0.088)
        # Brazos esbeltos: manga azul con puño rojo, guante oscuro.
        sh = Vector((0.26 * sx, 0, 1.25))
        el = Vector((0.32 * sx, 0, 1.02))
        wr = Vector((0.35 * sx, 0, 0.81))
        b.sphere(A, f"upper_arm.{side}", sh + Vector((0.01 * sx, 0, -0.03)), (0.092, 0.092, 0.09), u=10, v=6)
        b.limb(A, f"upper_arm.{side}", sh, sh.lerp(el, 0.5), 0.086, 0.075)
        b.limb(R, f"upper_arm.{side}", sh.lerp(el, 0.47), sh.lerp(el, 0.56), 0.078, 0.076)
        b.limb(S, f"upper_arm.{side}", sh.lerp(el, 0.55), el, 0.055, 0.05, segments=8)
        b.sphere(S, f"forearm.{side}", el, (0.053, 0.053, 0.053), u=8, v=6)
        b.limb(S, f"forearm.{side}", el, wr, 0.05, 0.055, segments=8)
        b.limb(W, f"forearm.{side}", el.lerp(wr, 0.8), el.lerp(wr, 0.97), 0.062, 0.064, segments=8)
        b.sphere(N, f"hand.{side}", wr + Vector((0.01 * sx, 0.01, -0.065)), (0.075, 0.08, 0.09), u=10, v=7)
    # Charretera roja con flecos blancos en el hombro izquierdo (sello del Príncipe).
    b.box(R, "chest", (-0.27, 0, 1.33), (0.18, 0.24, 0.05), bevel=0.02, segments=2, rot=(0, 16, 0))
    for i in range(5):
        b.box(W, "chest", (-0.355, -0.08 + i * 0.04, 1.285), (0.018, 0.018, 0.07), smooth=False, rot=(0, 16, 0))
    # Short azul con franja roja.
    b.box(A, "hips", (0, 0, 0.77), (0.36, 0.24, 0.2), bevel=0.06, segments=2, taper_top=1.02)
    for sx in (-1, 1):
        b.box(R, "hips", (0.178 * sx, 0, 0.75), (0.012, 0.07, 0.16), smooth=False)
    # Torso esbelto azul y banda real roja cruzada (hombro derecho → cadera izquierda).
    b.box(A, "spine", (0, 0, 0.99), (0.36, 0.25, 0.27), bevel=0.06, segments=2, taper_top=1.06)
    b.box(A, "chest", (0, 0, 1.2), (0.4, 0.27, 0.24), bevel=0.08, segments=2, taper_top=1.15, taper_depth=0.95)
    b.box(R, "chest", (0.0, 0.137, 1.12), (0.07, 0.014, 0.5), smooth=False, rot=(0, -38, 0))
    b.box(W, "chest", (0.0, 0.14, 1.13), (0.035, 0.012, 0.035), smooth=False, rot=(0, 45, 0))
    # Dorsal 20 (decisión del propietario): pequeño en el pecho, grande en la espalda.
    number(b, W, "chest", "20", (-0.1, 0.142, 1.24), 0.075, "front")
    number(b, W, "chest", "20", (0.0, -0.142, 1.15), 0.19, "back")
    # Cuello alto de camiseta.
    b.limb(S, "chest", (0, 0, 1.3), (0, 0, 1.4), 0.07, 0.065, segments=8)
    b.limb(R, "chest", (0, 0, 1.3), (0, 0, 1.37), 0.105, 0.085, segments=12)
    # Cabeza: rostro abstracto con visor táctico y lente roja en el ojo derecho.
    hc = Vector((0, 0.01, 1.62))
    b.sphere(S, "head", hc, (0.25, 0.24, 0.265), u=18, v=12)
    for sx in (-1, 1):
        b.sphere(S, "head", hc + Vector((0.245 * sx, -0.01, -0.02)), (0.038, 0.055, 0.065), u=8, v=5)
    b.sphere(S, "head", hc + Vector((0, 0.245, -0.04)), (0.035, 0.035, 0.035), u=8, v=5)
    b.box(N, "head", hc + Vector((0.02, 0.228, -0.13)), (0.07, 0.02, 0.02), bevel=0.007, segments=1, rot=(-15, 0, 8))
    b.arc_band(N, "head", hc + Vector((0, 0, 0.02)), 0.252, 0.06, 25, 155, 0.02, segments=14, scale=(1.02, 1.0, 1))
    b.sphere(L, "head", hc + Vector((0.085, 0.247, 0.02)), (0.045, 0.02, 0.04), u=10, v=6)
    # Peinado oscuro, volumen barrido hacia el lado izquierdo con mechón frontal.
    b.sphere(N, "head", hc + Vector((0, -0.02, 0.09)), (0.258, 0.255, 0.2), u=16, v=8)
    b.sphere(N, "head", hc + Vector((-0.07, 0.12, 0.2)), (0.2, 0.13, 0.08), u=12, v=6, rot=(10, 0, -18))
    b.spike(N, "head", hc + Vector((-0.17, 0.12, 0.2)), (-1, 0.25, -0.35), 0.06, 0.16, segments=4)
    b.spike(N, "head", hc + Vector((0.0, -0.2, 0.17)), (0, -1, -0.2), 0.08, 0.12, segments=5)


def clips():
    neutral = stance(0, arm_out=12, leg_out=3, lean=-3)
    bow = {**neutral, **P(spine=(-38, 0, 0), chest=(-10, 0, 0), head=(-8, 0, 0),
                           upper_arm_R=(45, -8, 0), forearm_R=(95, 0, 0), upper_arm_L=(-20, 40, 0), forearm_L=(15, 0, 0),
                           thigh_L=(8, 3, 0), thigh_R=(-6, -3, 0), shin_R=(-10, 0, 0))}
    return {
        "idle": [(0, neutral), (24, stance(1, arm_out=12, leg_out=3, lean=-3)), (48, neutral)],
        "run": [(f, run_pose(f, lean=-14, arm_swing=0.9, arm_out=12)) for f in (0, 4, 8, 12, 16)],
        # Pase de precisión con el interior del pie; contacto en el cuadro 4 (0,13 s).
        "kick": [
            (0, neutral),
            (2, {**neutral, **P(spine=(4, 0, 12), thigh_R=(-25, -15, 0), shin_R=(-40, 0, 0), foot_R=(0, 0, 25),
                                upper_arm_L=(20, 40, 0), upper_arm_R=(-20, -25, 0), thigh_L=(10, 3, 0), shin_L=(-16, 0, 0))}),
            (4, {**neutral, **P(spine=(-8, 0, -10), head=(10, 0, 0), thigh_R=(50, 10, 0), shin_R=(-12, 0, 0), foot_R=(0, 0, 35),
                                thigh_L=(10, 3, 0), shin_L=(-16, 0, 0), upper_arm_L=(-15, 45, 0), upper_arm_R=(25, -38, 0))}),
            (6, {**neutral, **P(spine=(-6, 0, -8), thigh_R=(42, 8, 0), shin_R=(-15, 0, 0), foot_R=(0, 0, 25),
                                upper_arm_L=(-10, 40, 0), upper_arm_R=(20, -35, 0))}),
            (12, neutral),
        ],
        "hit": hit_keys(neutral, arm_out=44),
        # Reverencia real y saludo: bucle de 1,2 s.
        "celebrate": [
            (0, neutral), (10, bow), (20, bow),
            (28, {**neutral, **P(spine=(2, 0, 0), head=(-8, 0, 0), upper_arm_R=(0, -150, 0), forearm_R=(-10, 0, 0))}),
            (31, {**neutral, **P(spine=(2, 0, 0), head=(-8, 0, 0), upper_arm_R=(0, -140, 18), forearm_R=(-30, 0, 0))}),
            (36, neutral),
        ],
    }


if __name__ == "__main__":
    build_hero("principe", PALETTE, BONES, build_mesh, clips(),
               [("Muzzle", "chest", (0.0, 0.45, 1.05)), ("VFXOrigin", "chest", (0.0, 0.0, 1.1))])
