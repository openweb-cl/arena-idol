"""El Turbo #11 — generador reproducible del modelo, rig y clips (V3 provisional).

MODELO PROVISIONAL V3: traduce la referencia visual V2 aceptada por el propietario
(design/personajes/turbo/bocetos/turbo-v2-propuesta-01.png) a un GLB jugable.
Pendiente de revisión; no es arte final. Diseño original: equipación azul con
detalles rojos, pelo blanco en punta, rostro caricaturesco propio y tatuajes
tribales de diseño propio. Sin escudos, patrocinadores, logos ni rostros reales.

Cuerpo, atlas y clips comunes en art/lib/hero_v3.py; aquí solo lo propio de Turbo.

Uso (Blender 5.2 o módulo bpy 5.2 de PyPI, ambos gratuitos):
    python art/turbo/build_turbo.py            # con `pip install bpy==5.2.3 pillow`
Salidas: art/turbo/turbo_atlas.png, art/turbo/turbo.blend y game/assets/models/turbo/turbo.glb.
"""
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "lib"))
import hero_v3  # noqa: E402

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


def shirt(c, reg, v, px_u):
    """Franja diagonal roja propia (del hombro izquierdo a la cadera derecha) y trazos de espalda."""
    c.band(reg, 0.43, v(1.33), 0.10, v(0.93), 0.032 * px_u, "acento")
    c.band(reg, 0.45, v(1.21), 0.36, v(1.10), 0.014 * px_u, "acento")
    c.band(reg, 0.60, v(1.36), 0.90, v(1.27), 0.024 * px_u, "acento")
    c.band(reg, 0.62, v(1.31), 0.70, v(1.285), 0.012 * px_u, "acento")


def arm(c, reg, v):
    """Dos brazaletes tribales propios: dientes bajo la manga y banda ancha en el antebrazo."""
    x0, y0, x1, y1 = reg
    w_px = x1 - x0
    top, bot = v(1.12), v(1.075)
    c.rect(x0, top, x1, top + 4, "tinta")
    c.rect(x0, bot - 4, x1, bot, "tinta")
    for i in range(10):
        a, b = x0 + w_px * i / 10, x0 + w_px * (i + 1) / 10
        c.poly([(a, bot - 4), ((a + b) / 2, top + 5), (b, bot - 4)], "tinta")
    top, bot = v(0.995), v(0.905)
    c.rect(x0, top, x1, top + 5, "tinta")
    c.rect(x0, bot - 5, x1, bot, "tinta")
    c.line([(x0 + w_px * i / 12, (top + 9) if i % 2 == 0 else (bot - 9)) for i in range(13)], "tinta", 4)
    for i in range(12):
        cx = x0 + w_px * (i + 0.5) / 12
        cy = (top + 13) if i % 2 else (bot - 13)
        c.poly([(cx, cy - 6), (cx + 6, cy), (cx, cy + 6), (cx - 6, cy)], "tinta")


SPEC = {
    "id": "turbo",
    "number": "11",
    # Paleta de la lámina V2; piel algo más oscura para que no se vea pálida con la luz del juego.
    "colors": {"base": "#1f3fbf", "base_oscuro": "#132a8f", "acento": "#e0282f", "piel": "#d4925e",
               "piel_sombra": "#b37548", "pelo": "#e6e6f0", "pelo_sombra": "#b9bccf"},
    "face": {"brow": "decidida", "mouth": "sonrisa"},
    "hair": HAIR,
    "shirt": shirt,
    "arm": arm,
    # Zancada larga de velocista con fase aérea; run_clip_speed = 3.9 m/s en turbo.tres.
    "run": {"lean": -18, "arm_swing": 1.25, "arm_out": 16, "bob": 0.08, "stride": 1.25},
}

if __name__ == "__main__":
    hero_v3.build(SPEC, HERE)
