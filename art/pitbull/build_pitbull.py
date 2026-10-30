"""El Pitbull — generador reproducible del modelo, rig y clips (muestra V0).

MUESTRA PROVISIONAL: solo arte. Sin gameplay ni ficha aprobada (Codex) y sin
dorsal hasta que el propietario lo decida. No es arte final.
Diseño original del defensor: compacto y bajo, de centro de gravedad bajo, camiseta
blanca con franja celeste horizontal al centro, collar con tachas (sello propio),
vendas blancas en las muñecas, guardia defensiva y visor ámbar de marca personal.
Sin escudos, patrocinadores, logos ni rostro de personas reales.

Uso: python art/pitbull/build_pitbull.py
Salidas: art/pitbull/pitbull.blend y game/assets/models/pitbull/pitbull.glb.
"""
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hero_kit import P, Vector, build_hero, celebrate_keys, hit_keys, make_bones, mirror, run_pose  # noqa: E402

PALETTE = {
    "M_Pitbull_Blanco": ("f4f5f2", 0.80, 0.0, None),   # camiseta, vendas, medias
    "M_Pitbull_Celeste": ("5ec8f2", 0.70, 0.0, None),  # franja central, ribetes
    "M_Pitbull_Marino": ("1d2f6f", 0.70, 0.0, None),   # short, botas
    "M_Pitbull_Piel": ("b9805c", 0.85, 0.0, None),     # piel
    "M_Pitbull_Collar": ("23232a", 0.55, 0.0, None),   # collar, pelo, guantes, suelas
    "M_Pitbull_Tacha": ("c9ced8", 0.35, 0.0, None),    # tachas del collar
    "M_Pitbull_Visor": ("ffb03b", 0.40, 0.0, 1.3),     # visor ámbar (emisivo)
}
W, C, M, S, K, T, G = PALETTE
BONES = make_bones(shoulder_x=0.32, hip_x=0.15, arm_drop=0.05, hip_z=0.72, chest_top=1.32)


def build_mesh(b):
    for side, sx in (("L", -1), ("R", 1)):
        x = 0.15 * sx
        # Botas marino robustas.
        b.box(M, f"foot.{side}", (x, 0.05, 0.085), (0.2, 0.36, 0.15), bevel=0.05, segments=3, taper_top=0.9, taper_depth=0.82)
        b.box(K, f"foot.{side}", (x, 0.05, 0.018), (0.21, 0.37, 0.036), bevel=0.012, segments=1)
        b.box(C, f"foot.{side}", (x + 0.1 * sx, 0.05, 0.09), (0.012, 0.2, 0.05), smooth=False)
        # Medias blancas con ribete celeste; piernas cortas y gruesas.
        b.limb(W, f"shin.{side}", (x, 0, 0.14), (x, 0, 0.43), 0.08, 0.092)
        b.limb(C, f"shin.{side}", (x, 0, 0.39), (x, 0, 0.43), 0.095, 0.095)
        b.sphere(S, f"shin.{side}", (x, 0.0, 0.47), (0.082, 0.082, 0.082), u=10, v=6)
        b.limb(S, f"thigh.{side}", (x, 0, 0.49), (x, 0, 0.64), 0.095, 0.11)
        # Brazos fuertes, manga blanca, vendas blancas y guantes oscuros.
        sh = Vector((0.32 * sx, 0, 1.22))
        el = Vector((0.38 * sx, 0, 0.97))
        wr = Vector((0.41 * sx, 0, 0.76))
        b.sphere(W, f"upper_arm.{side}", sh + Vector((0.01 * sx, 0, -0.03)), (0.115, 0.11, 0.105), u=10, v=6)
        b.limb(W, f"upper_arm.{side}", sh, sh.lerp(el, 0.42), 0.104, 0.095)
        b.limb(C, f"upper_arm.{side}", sh.lerp(el, 0.38), sh.lerp(el, 0.48), 0.098, 0.096)
        b.limb(S, f"upper_arm.{side}", sh.lerp(el, 0.45), el, 0.075, 0.068, segments=8)
        b.sphere(S, f"forearm.{side}", el, (0.07, 0.07, 0.07), u=8, v=6)
        b.limb(S, f"forearm.{side}", el, wr, 0.068, 0.072, segments=8)
        for t in (0.62, 0.76, 0.9):
            b.limb(W, f"forearm.{side}", el.lerp(wr, t), el.lerp(wr, t + 0.12), 0.078, 0.08, segments=8)
        b.sphere(K, f"hand.{side}", wr + Vector((0.01 * sx, 0.01, -0.075)), (0.1, 0.105, 0.11), u=10, v=7)
    # Short marino con franja celeste.
    b.box(M, "hips", (0, 0, 0.68), (0.44, 0.29, 0.2), bevel=0.06, segments=2, taper_top=1.02)
    for sx in (-1, 1):
        b.box(C, "hips", (0.218 * sx, 0, 0.66), (0.012, 0.08, 0.16), smooth=False)
    # Torso compacto blanco con franja celeste horizontal al centro (adelante y atrás).
    b.box(W, "spine", (0, 0, 0.9), (0.44, 0.31, 0.28), bevel=0.07, segments=2, taper_top=1.08)
    b.box(W, "chest", (0, 0, 1.15), (0.52, 0.32, 0.27), bevel=0.09, segments=2, taper_top=1.14, taper_depth=0.95)
    b.box(C, "chest", (0, 0, 1.075), (0.555, 0.33, 0.1), bevel=0.03, segments=2)
    b.box(C, "chest", (0, 0, 1.31), (0.2, 0.25, 0.02), smooth=False)
    # Cuello ancho con collar de tachas (sello del Pitbull).
    b.limb(S, "chest", (0, 0, 1.27), (0, 0, 1.4), 0.105, 0.1, segments=10)
    b.limb(K, "chest", (0, 0, 1.3), (0, 0, 1.36), 0.122, 0.118, segments=14)
    for i in range(10):
        ang = math.radians(i * 36)
        base = Vector((math.cos(ang) * 0.12, math.sin(ang) * 0.12, 1.33))
        b.spike(T, "chest", base, (math.cos(ang), math.sin(ang), 0), 0.018, 0.04, segments=4)
    # Cabeza ancha, mandíbula fuerte, ceño y visor ámbar.
    hc = Vector((0, 0.02, 1.6))
    b.sphere(S, "head", hc, (0.27, 0.25, 0.25), u=18, v=12)
    b.box(S, "head", hc + Vector((0, 0.04, -0.13)), (0.42, 0.3, 0.15), bevel=0.06, segments=2)
    for sx in (-1, 1):
        b.sphere(S, "head", hc + Vector((0.27 * sx, -0.01, -0.01)), (0.045, 0.06, 0.065), u=8, v=5)
        b.box(K, "head", hc + Vector((0.08 * sx, 0.235, 0.065)), (0.13, 0.03, 0.035), bevel=0.01, segments=1, rot=(0, -14 * sx, 0))
    b.sphere(S, "head", hc + Vector((0, 0.255, -0.05)), (0.05, 0.04, 0.04), u=8, v=5)
    b.box(K, "head", hc + Vector((0, 0.25, -0.16)), (0.15, 0.02, 0.025), bevel=0.008, segments=1)
    b.arc_band(G, "head", hc + Vector((0, 0, 0.0)), 0.262, 0.05, 30, 150, 0.02, segments=14, scale=(1.03, 1.0, 1))
    # Pelo rapado oscuro.
    b.sphere(K, "head", hc + Vector((0, -0.02, 0.07)), (0.265, 0.255, 0.21), u=16, v=8)


def guard(breath=0.0):
    """Guardia defensiva baja: rodillas flexionadas y puños arriba."""
    return mirror(P(
        hips=((0, 0, 0), (0, 0, -0.04 - 0.012 * breath)),
        spine=(-10 + 3 * breath, 0, 0), chest=(-2 + 3 * breath, 0, 0), head=(8 - 3 * breath, 0, 0),
        upper_arm_L=(28 + 4 * breath, 24, 0), forearm_L=(105, 0, 0),
        thigh_L=(18, 8, 0), shin_L=(-30, 0, 0), foot_L=(12, 0, 0),
    ))


def clips():
    neutral = guard(0)
    return {
        "idle": [(0, neutral), (24, guard(1)), (48, neutral)],
        "run": [(f, run_pose(f, lean=-18, arm_swing=0.8, arm_out=22, bob=0.04)) for f in (0, 4, 8, 12, 16)],
        # Tackle corto: estocada baja con pierna barrida; contacto en el cuadro 4.
        "kick": [
            (0, neutral),
            (2, {**neutral, **P(hips=((0, 0, 0), (0, 0, -0.08)), spine=(-18, 0, 15), thigh_R=(-30, -10, 0), shin_R=(-50, 0, 0),
                                thigh_L=(30, 8, 0), shin_L=(-45, 0, 0))}),
            (4, {**neutral, **P(hips=((0, 0, 0), (0, 0, -0.16)), spine=(-28, 0, -12), head=(18, 0, 0),
                                thigh_R=(75, -12, 0), shin_R=(-8, 0, 0), foot_R=(-20, 0, 0), thigh_L=(-15, 8, 0), shin_L=(-75, 0, 0),
                                upper_arm_L=(-30, 50, 0), forearm_L=(40, 0, 0), upper_arm_R=(40, -45, 0), forearm_R=(40, 0, 0))}),
            (6, {**neutral, **P(hips=((0, 0, 0), (0, 0, -0.14)), spine=(-24, 0, -8), thigh_R=(65, -10, 0), shin_R=(-15, 0, 0),
                                thigh_L=(-10, 8, 0), shin_L=(-65, 0, 0), upper_arm_L=(-20, 45, 0), upper_arm_R=(30, -40, 0))}),
            (12, neutral),
        ],
        "hit": hit_keys(neutral, arm_out=36),
        "celebrate": celebrate_keys(jump=0.14, arm_up=110),
    }


if __name__ == "__main__":
    build_hero("pitbull", PALETTE, BONES, build_mesh, clips(),
               [("Muzzle", "chest", (0.0, 0.45, 1.0)), ("VFXOrigin", "chest", (0.0, 0.0, 1.05))])
