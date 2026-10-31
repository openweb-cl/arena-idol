"""El Rey / King #23 — generador reproducible del modelo, rig y clips (V3 provisional).

MODELO PROVISIONAL V3 con el patrón visual de Turbo V3. Pendiente de revisión del
propietario; no es arte final. Conserva la identidad decidida en V0: tanque ancho
en blanco y negro con el 23 y sello propio, corona dorada de cinco puntas con gema
violeta, banda negra con filos dorados al pecho y hombreras negras.
Sin barba, cresta ni tatuajes, para no evocar a una persona real.
Sin escudos, patrocinadores, logos ni rostros reales.

Cuerpo, atlas y clips comunes en art/lib/hero_v3.py; aquí solo lo propio del Rey.

Uso: python art/rey/build_rey.py   (bpy 5.2.3 + pillow)
Salidas: art/rey/rey_atlas.png, art/rey/rey.blend y game/assets/models/rey/rey.glb.
"""
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "lib"))
import hero_v3  # noqa: E402
from hero_kit import Vector  # noqa: E402

HAIR = [  # pelo corto y peinado hacia atrás bajo la corona
    ((0.0, 0.13, 1.80), (0, 0.3, 1), 0.07, 0.06, (0, -0.4, 0), "pelo"),
    ((0.08, 0.1, 1.79), (0.4, 0.2, 1), 0.06, 0.05, (0, -0.3, 0), "pelo_sombra"),
    ((-0.08, 0.1, 1.79), (-0.4, 0.2, 1), 0.06, 0.05, (0, -0.3, 0), "pelo"),
    ((0.0, -0.12, 1.76), (0, -1, 0.1), 0.08, 0.06, (0, 0, -0.05), "pelo_sombra"),
]


def shirt(c, reg, v, px_u):
    """Banda negra al pecho con filos dorados (sello propio del Rey)."""
    x0, y0, x1, y1 = reg
    h = y1 - y0
    top, bot = y0 + v(1.25) * h, y0 + v(1.15) * h
    c.rect(x0, top - 4, x1, bot + 4, "detalle")
    c.rect(x0, top, x1, bot, "short")


def shoulders(b):
    """Hombreras negras sobre la manga."""
    for side, s in (("L", -1), ("R", 1)):
        bone = f"upper_arm.{side}"
        b.sphere("short", bone, (s * 0.315, 0, 1.345), (0.155, 0.145, 0.1), u=12, v=6)


def crown(b):
    """Corona dorada de cinco puntas con gema violeta al frente."""
    c = Vector((0.0, -0.01, 1.765))
    b.arc_band("detalle", "head", c, 0.192, 0.045, 0, 360, 0.02, segments=20, scale=(1.0, 1.0, 1))
    for i, ang in enumerate((90, 30, 150, -30, 210)):
        a = math.radians(ang)
        base = c + Vector((math.cos(a) * 0.192, math.sin(a) * 0.192, 0.02))
        b.spike("detalle", "head", base, (math.cos(a) * 0.25, math.sin(a) * 0.25, 1), 0.035, 0.1 if i == 0 else 0.08, segments=4)
    b.sphere("gema", "head", c + Vector((0, 0.208, 0.0)), (0.024, 0.014, 0.024), u=8, v=6)


SPEC = {
    "id": "rey",
    "number": "23",
    "colors": {"base": "#f2f2ef", "base_oscuro": "#d4d6db", "acento": "#18181c", "piel": "#a8724f",
               "piel_sombra": "#875a3c", "pelo": "#1c1a1e", "pelo_sombra": "#34303a", "short": "#18181c",
               "media": "#f2f2ef", "banda": "#18181c", "puno": "#18181c", "suela": "#18181c",
               "detalle": "#f2b632", "iris": "#3c2414", "iris_claro": "#5e3a20", "gema": "#5b2a86"},
    "collar": "short",
    "number_color": "detalle",
    "short_stripe": "detalle",
    "short_number_color": "detalle",
    "proportions": {"chest": 1.25, "waist": 1.15, "arm": 1.3, "leg": 1.1, "shoulder": 1.2, "head_scale": 1.08},
    "face": {"brow": "decidida", "mouth": "sonrisa", "eye_scale": 0.9, "jaw": 0.05},
    "hair": HAIR,
    "hair_flat": 0.7,
    "hair_cap": {"front_z": 1.76, "z": 1.645, "radii": (0.186, 0.186, 0.205), "nape": 1.5},
    "shirt": shirt,
    "body_extras": shoulders,
    "head_extras": crown,
    "stance": {"arm_out": 30, "crouch": 1.2},
    "run": {"lean": -12, "arm_out": 22, "bob": 0.05, "stride": 1.0},
}

if __name__ == "__main__":
    hero_v3.build(SPEC, HERE)
