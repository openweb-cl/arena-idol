"""El Turbo #11 — generador reproducible del modelo, rig y clips (muestra V1.1).

MUESTRA PROVISIONAL: pendiente de revisión del propietario; no es arte final.
Diseño original: equipación azul con detalles rojos, pelo blanco y tatuajes de
diseño propio (rayos, estrellas, bandas). Sin escudos, patrocinadores, logos ni
rostro de personas reales.

Uso (Blender 5.2 o módulo bpy 5.2 de PyPI, ambos gratuitos):
    blender --background --python art/turbo/build_turbo.py
    python art/turbo/build_turbo.py            # con `pip install bpy`
Salidas: art/turbo/turbo.blend y game/assets/models/turbo/turbo.glb.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
from hero_kit import P, Vector, build_hero, celebrate_keys, hit_keys, make_bones, number, run_pose, stance  # noqa: E402

PALETTE = {
    "M_Turbo_Azul": ("1f3fbf", 0.70, 0.0, None),     # camiseta, short, medias
    "M_Turbo_Rojo": ("e0262f", 0.65, 0.0, None),     # ribetes, paneles, detalles
    "M_Turbo_Blanco": ("f1f3f7", 0.80, 0.0, None),   # pelo, botas, dorsal
    "M_Turbo_Piel": ("c98a66", 0.85, 0.0, None),     # piel caricaturesca neutra
    "M_Turbo_Tinta": ("141b3d", 0.60, 0.0, None),    # tatuajes, guantes, suelas, boca
    "M_Turbo_Chispa": ("ffe873", 0.40, 0.0, 1.4),    # visor y rayos eléctricos (emisivo)
}
A, R, W, S, T, G = PALETTE
BONES = make_bones()


def arm_tattoos(b, side, sx, sh, el, wr):
    """Mangas tatuadas originales: bandas en zigzag, rombos, estrella o rayo."""
    outer = 0 if sx > 0 else 180
    front = 270
    up_a, up_b = sh.lerp(el, 0.5), el
    b.zigzag_band(T, f"upper_arm.{side}", up_a, up_b, 0.3, 0.059, amplitude=0.01, width=0.011, teeth=7)
    b.zigzag_band(T, f"forearm.{side}", el, wr, 0.12, 0.057, amplitude=0.01, width=0.011, teeth=7)
    b.zigzag_band(T, f"forearm.{side}", el, wr, 0.6, 0.059, amplitude=0.008, width=0.01, teeth=7)
    for ang in (outer, front, outer + 90):
        b.decal(T, f"forearm.{side}", el, wr, 0.36, 0.058, ang, (0.026, 0.026), spin=45)
    if side == "L":  # estrella de ocho puntas en el brazo
        for spin in (0, 45, 90, 135):
            b.decal(T, f"upper_arm.{side}", up_a, up_b, 0.68, 0.057, outer, (0.012, 0.06), spin=spin)
    else:  # rayo en zigzag en el brazo
        b.decal(T, f"upper_arm.{side}", up_a, up_b, 0.6, 0.057, outer, (0.014, 0.05), spin=28)
        b.decal(T, f"upper_arm.{side}", up_a, up_b, 0.82, 0.057, outer, (0.014, 0.05), spin=-28)
        b.decal(T, f"upper_arm.{side}", up_a, up_b, 0.6, 0.057, front, (0.014, 0.05), spin=28)


def build_mesh(b):
    for side, sx in (("L", -1), ("R", 1)):
        x = 0.12 * sx
        # Botas grandes blancas con puntera roja.
        b.box(W, f"foot.{side}", (x, 0.05, 0.085), (0.18, 0.36, 0.15), bevel=0.05, segments=3, taper_top=0.85, taper_depth=0.8)
        b.box(T, f"foot.{side}", (x, 0.05, 0.018), (0.19, 0.37, 0.036), bevel=0.012, segments=1)
        b.box(R, f"foot.{side}", (x, 0.19, 0.06), (0.15, 0.09, 0.09), bevel=0.03, segments=2)
        b.spike(R, f"shin.{side}", (x + 0.07 * sx, -0.02, 0.2), (0.35 * sx, -1, 0.45), 0.06, 0.2, segments=3, flat=0.25)
        # Medias azules con banda roja y rayo.
        b.limb(A, f"shin.{side}", (x, 0, 0.14), (x, 0, 0.44), 0.068, 0.08)
        b.limb(R, f"shin.{side}", (x, 0, 0.40), (x, 0, 0.45), 0.083, 0.083)
        b.box(G, f"shin.{side}", (x + 0.074 * sx, 0.0, 0.31), (0.012, 0.03, 0.09), rot=(25, 0, 0), smooth=False)
        b.box(G, f"shin.{side}", (x + 0.074 * sx, 0.0, 0.23), (0.012, 0.03, 0.09), rot=(-25, 0, 0), smooth=False)
        b.sphere(S, f"shin.{side}", (x, 0.0, 0.485), (0.07, 0.07, 0.07), u=10, v=6)
        b.limb(S, f"thigh.{side}", (x, 0, 0.5), (x, 0, 0.72), 0.075, 0.095)
        # Brazos: manga azul, puño rojo, piel tatuada, brazalete eléctrico y guante.
        sh = Vector((0.27 * sx, 0, 1.25))
        el = Vector((0.33 * sx, 0, 1.02))
        wr = Vector((0.36 * sx, 0, 0.81))
        b.sphere(A, f"upper_arm.{side}", sh + Vector((0.01 * sx, 0, -0.03)), (0.1, 0.1, 0.095), u=10, v=6)
        b.limb(A, f"upper_arm.{side}", sh, sh.lerp(el, 0.45), 0.092, 0.08)
        b.limb(R, f"upper_arm.{side}", sh.lerp(el, 0.42), sh.lerp(el, 0.52), 0.083, 0.081)
        b.limb(S, f"upper_arm.{side}", sh.lerp(el, 0.5), el, 0.06, 0.055, segments=8)
        b.sphere(S, f"forearm.{side}", el, (0.058, 0.058, 0.058), u=8, v=6)
        b.limb(S, f"forearm.{side}", el, wr, 0.055, 0.06, segments=8)
        b.limb(G, f"forearm.{side}", el.lerp(wr, 0.78), el.lerp(wr, 0.97), 0.068, 0.07, segments=8)
        arm_tattoos(b, side, sx, sh, el, wr)
        b.sphere(T, f"hand.{side}", wr + Vector((0.01 * sx, 0.01, -0.07)), (0.085, 0.09, 0.1), u=10, v=7)
        b.sphere(T, f"hand.{side}", wr + Vector((-0.02 * sx, 0.07, -0.04)), (0.035, 0.035, 0.045), u=6, v=4)
    # Short azul con franja roja lateral.
    b.box(A, "hips", (0, 0, 0.75), (0.38, 0.25, 0.2), bevel=0.06, segments=2, taper_top=1.02)
    for sx in (-1, 1):
        b.box(R, "hips", (0.188 * sx, 0, 0.73), (0.012, 0.08, 0.16), smooth=False)
    # Torso azul en V con paneles laterales rojos.
    b.box(A, "spine", (0, 0, 0.975), (0.38, 0.26, 0.27), bevel=0.06, segments=2, taper_top=1.08)
    b.box(A, "chest", (0, 0, 1.2), (0.42, 0.28, 0.24), bevel=0.08, segments=2, taper_top=1.18, taper_depth=0.95)
    for sx in (-1, 1):
        b.box(R, "spine", (0.19 * sx, 0, 1.03), (0.025, 0.2, 0.22), bevel=0.01, segments=1, rot=(0, 6 * sx, 0))
        b.box(R, "chest", (0.17 * sx, 0, 1.3), (0.1, 0.24, 0.025), bevel=0.008, segments=1, rot=(0, -14 * sx, 0))
    # Cuello con tatuaje lateral y cuello de camiseta rojo.
    b.limb(S, "chest", (0, 0, 1.3), (0, 0, 1.4), 0.075, 0.07, segments=8)
    b.decal(T, "chest", (0, 0, 1.3), (0, 0, 1.4), 0.72, 0.072, 0, (0.03, 0.03), spin=45)
    b.decal(T, "chest", (0, 0, 1.3), (0, 0, 1.4), 0.72, 0.072, 180, (0.012, 0.045), spin=20)
    b.limb(R, "chest", (0, 0, 1.3), (0, 0, 1.34), 0.12, 0.1, segments=12)
    # Trazos rojos en el pecho (gráfico propio) y dorsal 11 blanco.
    front = 0.142
    for i, (dx, dz, r) in enumerate(((-0.09, 1.25, -35), (-0.04, 1.18, 30), (0.02, 1.11, -35))):
        b.box(R, "chest" if i < 2 else "spine", (dx, front, dz), (0.03, 0.012, 0.09), rot=(0, r, 0), smooth=False)
    number(b, W, "chest", "11", (0.095, front, 1.2), 0.1, "front")
    number(b, W, "chest", "11", (0.0, -0.148, 1.15), 0.2, "back")
    # Módulo turbo dorsal con rejillas eléctricas.
    b.box(T, "chest", (0, -0.2, 1.31), (0.2, 0.08, 0.1), bevel=0.03, segments=2)
    for sx in (-1, 1):
        b.box(G, "chest", (0.055 * sx, -0.245, 1.31), (0.035, 0.012, 0.06), smooth=False)
    # Cabeza grande con visor eléctrico (rostro abstracto).
    hc = Vector((0, 0.01, 1.62))
    b.sphere(S, "head", hc, (0.26, 0.25, 0.27), u=18, v=12)
    for sx in (-1, 1):
        b.sphere(S, "head", hc + Vector((0.255 * sx, -0.01, -0.02)), (0.04, 0.06, 0.07), u=8, v=5)
    b.sphere(S, "head", hc + Vector((0, 0.255, -0.04)), (0.04, 0.035, 0.035), u=8, v=5)
    b.box(T, "head", hc + Vector((0, 0.235, -0.13)), (0.09, 0.02, 0.025), bevel=0.008, segments=1, rot=(-15, 0, 0))
    b.arc_band(G, "head", hc + Vector((0, 0, 0.02)), 0.262, 0.085, 20, 160, 0.02, segments=14, scale=(1.02, 1.0, 1))
    b.arc_band(T, "head", hc + Vector((0, -0.005, 0.072)), 0.262, 0.02, 15, 165, 0.025, segments=14, scale=(1.03, 1.0, 1))
    # Pelo blanco en punta barrido hacia atrás.
    b.sphere(W, "head", hc + Vector((0, -0.02, 0.08)), (0.265, 0.26, 0.22), u=16, v=8)
    crest = [
        ((0.0, 0.12, 1.84), (0, 0.45, 1), 0.09, 0.2), ((0.0, 0.0, 1.87), (0, -0.55, 1), 0.1, 0.25),
        ((0.09, 0.05, 1.83), (0.4, -0.35, 1), 0.08, 0.2), ((-0.09, 0.05, 1.83), (-0.4, -0.35, 1), 0.08, 0.2),
        ((0.0, -0.12, 1.81), (0, -1, 0.45), 0.1, 0.25), ((0.11, -0.1, 1.76), (0.45, -1, 0.3), 0.08, 0.2),
        ((-0.11, -0.1, 1.76), (-0.45, -1, 0.3), 0.08, 0.2), ((0.05, 0.16, 1.81), (0.2, 0.7, 0.8), 0.05, 0.13),
        ((-0.05, 0.16, 1.81), (-0.2, 0.7, 0.8), 0.05, 0.13),
    ]
    for base, direction, radius, length in crest:
        b.spike(W, "head", base, direction, radius, length, segments=5)
    for sx in (-1, 1):
        b.spike(W, "head", hc + Vector((0.24 * sx, -0.06, 0.08)), (0.35 * sx, -1, 0.35), 0.07, 0.2, segments=3, flat=0.3, roll=1.5708)


def clips():
    neutral = stance(0)
    return {
        "idle": [(0, stance(0)), (24, stance(1)), (48, stance(0))],
        "run": [(f, run_pose(f)) for f in (0, 4, 8, 12, 16)],
        # Chute eléctrico: golpe en el cuadro 4 (0,13 s) para coincidir con el proyectil.
        "kick": [
            (0, neutral),
            (2, {**neutral, **P(spine=(8, 0, 10), chest=(4, 0, 0), thigh_R=(-35, -6, 0), shin_R=(-75, 0, 0),
                                upper_arm_L=(30, 35, 0), upper_arm_R=(-35, -20, 0), thigh_L=(14, 4, 0), shin_L=(-22, 0, 0))}),
            (4, {**neutral, **P(spine=(-12, 0, -12), chest=(-6, 0, -6), head=(8, 0, 0), thigh_R=(88, -4, 0), shin_R=(-4, 0, 0),
                                foot_R=(-25, 0, 0), thigh_L=(12, 4, 0), shin_L=(-20, 0, 0), foot_L=(6, 0, 0),
                                upper_arm_L=(-45, 38, 0), forearm_L=(40, 0, 0), upper_arm_R=(45, -32, 0), forearm_R=(30, 0, 0))}),
            (6, {**neutral, **P(spine=(-10, 0, -10), thigh_R=(72, -4, 0), shin_R=(-18, 0, 0), foot_R=(-15, 0, 0),
                                thigh_L=(12, 4, 0), shin_L=(-20, 0, 0), upper_arm_L=(-35, 32, 0), upper_arm_R=(35, -28, 0))}),
            (12, neutral),
        ],
        "hit": hit_keys(neutral),
        "celebrate": celebrate_keys(),
    }


if __name__ == "__main__":
    build_hero("turbo", PALETTE, BONES, build_mesh, clips(),
               [("Muzzle", "chest", (0.0, 0.45, 1.05)), ("VFXOrigin", "chest", (0.0, 0.0, 1.1))])
