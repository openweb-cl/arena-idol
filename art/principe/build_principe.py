"""El Príncipe #20 — generador reproducible del modelo, rig y clips (V3 provisional).

MODELO PROVISIONAL V3 con el patrón visual de Turbo V3 (referencia V2 aceptada).
Pendiente de revisión del propietario; no es arte final. Diseño original del
estratega: mismo equipo azul/rojo que Turbo, pero silueta más esbelta y erguida,
pelo oscuro peinado hacia un lado, banda diagonal roja ancha con filos blancos
(en sentido contrario a la franja de Turbo), short blanco, puños y muñequeras
blancos y mirada atenta. Sin capa, escudos, patrocinadores, logos ni rostros reales.

Cuerpo, atlas y clips comunes en art/lib/hero_v3.py; aquí solo lo propio del Príncipe.

Uso: python art/principe/build_principe.py   (bpy 5.2.3 + pillow)
Salidas: art/principe/principe_atlas.png, art/principe/principe.blend y
game/assets/models/principe/principe.glb.
"""
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "lib"))
import hero_v3  # noqa: E402

HAIR = [  # mechones anchos peinados hacia la derecha del personaje y hacia atrás (raya a su izquierda)
    ((-0.06, 0.15, 1.80), (0.6, 0.2, 0.45), 0.17, 0.075, (0, -0.25, -0.05), "pelo"),
    ((0.02, 0.15, 1.81), (0.7, 0.0, 0.35), 0.16, 0.07, (0, -0.3, -0.05), "pelo_sombra"),
    ((0.09, 0.12, 1.80), (0.85, -0.2, 0.1), 0.13, 0.06, (0, -0.2, -0.08), "pelo"),
    ((-0.1, 0.1, 1.81), (0.3, -0.2, 0.6), 0.18, 0.075, (0, -0.3, 0), "pelo"),
    ((0.0, 0.03, 1.86), (0.2, -0.9, 0.35), 0.2, 0.085, (0, 0, -0.1), "pelo_sombra"),
    ((0.1, 0.0, 1.84), (0.5, -0.85, 0.1), 0.18, 0.075, (0, 0, -0.1), "pelo"),
    ((-0.1, 0.0, 1.84), (-0.3, -0.9, 0.1), 0.18, 0.075, (0, 0, -0.1), "pelo"),
    ((0.0, -0.12, 1.78), (0, -0.9, -0.4), 0.14, 0.07, (0, 0, -0.05), "pelo_sombra"),
    ((0.15, 0.02, 1.74), (0.6, -0.6, -0.4), 0.12, 0.05, (0, 0, 0), "pelo"),
    ((-0.15, 0.02, 1.74), (-0.6, -0.6, -0.4), 0.12, 0.05, (0, 0, 0), "pelo"),
    ((-0.15, 0.1, 1.75), (-0.4, 0.3, -0.6), 0.08, 0.04, (0, 0, 0), "pelo_sombra"),
]


def shirt(c, reg, v, px_u):
    """Banda diagonal ancha con filos blancos: del hombro derecho a la cadera izquierda, y su vuelta por la espalda."""
    for u0, v0, u1, v1 in ((0.07, 1.36, 0.46, 0.93), (0.54, 0.93, 0.93, 1.36)):
        c.band(reg, u0, v(v0), u1, v(v1), 0.075 * px_u, "blanco")
        c.band(reg, u0, v(v0), u1, v(v1), 0.058 * px_u, "acento")


def arm(c, reg, v):
    """Muñequera blanca con filo rojo; sin tatuajes."""
    x0, y0, x1, y1 = reg
    top, bot = v(0.875), v(0.815)
    c.rect(x0, top, x1, bot, "blanco")
    c.rect(x0, top, x1, top + 4, "acento")


SPEC = {
    "id": "principe",
    "number": "20",
    "colors": {"base": "#1a37a8", "base_oscuro": "#10247a", "acento": "#d92332", "piel": "#c98a5c",
               "piel_sombra": "#a86f45", "pelo": "#1f1b26", "pelo_sombra": "#3b3448", "short": "#eef0f5",
               "banda": "#eef0f5", "puno": "#eef0f5", "suela": "#d92332", "iris": "#4a2c18", "iris_claro": "#6e4426"},
    "short_number_color": "base",
    "proportions": {"chest": 0.95, "waist": 0.94, "arm": 0.9, "shoulder": 0.97, "head_scale": 1.1},
    "face": {"brow": "recta", "mouth": "atento", "eye_scale": 0.95, "jaw": 0.26},
    "hair": HAIR,
    "hair_flat": 0.5,
    "hair_cap": {"front_z": 1.77, "z": 1.655, "radii": (0.19, 0.19, 0.215)},
    "shirt": shirt,
    "arm": arm,
    "stance": {"arm_out": 18, "crouch": 0.6},
    # Zancada algo más larga que la base; run_clip_speed = 3.6 m/s en principe.tres.
    "run": {"lean": -14, "arm_out": 14, "bob": 0.06, "stride": 1.1},
}

if __name__ == "__main__":
    hero_v3.build(SPEC, HERE)
