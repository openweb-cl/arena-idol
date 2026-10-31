"""El Pitbull #17 — generador reproducible del modelo, rig y clips (V3 provisional).

MODELO PROVISIONAL V3 con el patrón visual de Turbo V3. Pendiente de revisión del
propietario; no es arte final. Diseño original del defensor: compacto y de piernas
fuertes, camiseta blanca con banda celeste propia al pecho, short marino, medias
blancas, pelo corto oscuro con cresta baja, sombra de barba, mirada firme pero
simpática, tatuajes geométricos propios y vendas blancas en las muñecas.
Sin cabeza de perro, guanteletes, armadura, escudos, logos ni rostros reales.

Cuerpo, atlas y clips comunes en art/lib/hero_v3.py; aquí solo lo propio del Pitbull.

Uso: python art/pitbull/build_pitbull.py   (bpy 5.2.3 + pillow)
Salidas: art/pitbull/pitbull_atlas.png, art/pitbull/pitbull.blend y
game/assets/models/pitbull/pitbull.glb.
"""
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "lib"))
import hero_v3  # noqa: E402

HAIR = [  # pelo corto: cresta baja de mechones cortos hacia atrás y laterales rapados (casquete)
    ((0.0, 0.12, 1.83), (0, 0.2, 1), 0.08, 0.05, (0, -0.3, 0), "pelo"),
    ((0.0, 0.05, 1.86), (0, -0.2, 1), 0.09, 0.055, (0, -0.35, 0), "pelo_sombra"),
    ((0.0, -0.03, 1.86), (0, -0.6, 0.8), 0.09, 0.055, (0, -0.2, 0), "pelo"),
    ((0.0, -0.11, 1.82), (0, -0.9, 0.4), 0.08, 0.05, (0, 0, 0), "pelo_sombra"),
    ((0.05, 0.08, 1.84), (0.3, 0, 1), 0.06, 0.04, (0, -0.3, 0), "pelo"),
    ((-0.05, 0.08, 1.84), (-0.3, 0, 1), 0.06, 0.04, (0, -0.3, 0), "pelo"),
]


def shirt(c, reg, v, px_u):
    """Banda celeste horizontal al pecho con filos marinos, por delante y por detrás."""
    x0, y0, x1, y1 = reg
    h = y1 - y0
    top, bot = y0 + v(1.27) * h, y0 + v(1.12) * h
    c.rect(x0, top - 5, x1, bot + 5, "short")
    c.rect(x0, top, x1, bot, "detalle")


def arm(c, reg, v):
    """Tatuaje geométrico propio en el antebrazo y venda blanca en la muñeca."""
    x0, y0, x1, y1 = reg
    w_px = x1 - x0
    top, bot = v(1.0), v(0.9)
    for i in range(8):
        a = x0 + w_px * i / 8
        b = x0 + w_px * (i + 1) / 8
        c.poly([(a, top), (b, top), ((a + b) / 2, bot)], "tinta")
        c.poly([((a + b) / 2, top + 6), (b - 6, (top + bot) / 2), ((a + b) / 2, bot - 4), (a + 6, (top + bot) / 2)], "piel")
    c.rect(x0, v(1.11), x1, v(1.095), "tinta")
    wrap_top, wrap_bot = v(0.885), v(0.81)
    c.rect(x0, wrap_top, x1, wrap_bot, "blanco")
    for i in range(6):
        y = wrap_top + (wrap_bot - wrap_top) * (i + 0.5) / 6
        c.line([(x0, y - 3), (x1, y + 3)], "gris", 2)


SPEC = {
    "id": "pitbull",
    "number": "17",
    "colors": {"base": "#f4f4ef", "base_oscuro": "#d6dbe2", "acento": "#5ec8f2", "piel": "#c58658",
               "piel_sombra": "#a06a43", "pelo": "#2a211c", "pelo_sombra": "#45372e", "short": "#1d2f6f",
               "media": "#f4f4ef", "banda": "#5ec8f2", "puno": "#5ec8f2", "suela": "#1d2f6f",
               "detalle": "#5ec8f2", "iris": "#4a2e1a", "iris_claro": "#6a4426"},
    "collar": "short",
    "number_color": "short",
    "short_stripe": "acento",
    "proportions": {"chest": 1.15, "waist": 1.1, "arm": 1.25, "leg": 1.15, "shoulder": 1.1, "head_scale": 1.1},
    "face": {"brow": "fruncida", "mouth": "atento", "eye_scale": 0.88, "lid": 0.3, "jaw": 0.12, "stubble": True},
    "hair": HAIR,
    "hair_flat": 0.7,
    "hair_cap": {"front_z": 1.75, "z": 1.64, "radii": (0.185, 0.185, 0.21), "nape": 1.5},
    "shirt": shirt,
    "arm": arm,
    "stance": {"arm_out": 28, "crouch": 1.3},
    # Zancada corta y potente; run_clip_speed = 3.1 m/s en pitbull.tres.
    "run": {"lean": -10, "arm_out": 20, "bob": 0.05, "stride": 0.95},
}

if __name__ == "__main__":
    hero_v3.build(SPEC, HERE)
