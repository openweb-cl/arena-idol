"""Atlas 1024 del Turbo V3: rostro, camiseta, tatuajes, short y muestras de color.

Todo se dibuja con formas propias (Pillow), sin fuentes ni imágenes externas.
Las posiciones salen de los mismos anillos que el mallado (tube_fractions), así
que dorsal, franjas y tatuajes caen a la altura del modelo. Paleta de la lámina
V2 aceptada. Diseño original: sin escudos, logos, patrocinadores ni rostros reales.
"""
import math

from PIL import Image, ImageDraw

from hero_kit import Vector, tube_fractions

SIZE = 1024
SS = 2  # supermuestreo para bordes suaves

REGIONS = {  # x0, y0, x1, y1 en píxeles del atlas
    "camiseta": (0, 0, 1024, 448),
    "cara": (0, 448, 384, 832),
    "brazo": (384, 448, 704, 704),
    "short_R": (704, 448, 1024, 544),
    "short_L": (704, 544, 1024, 640),
}

COLORS = {
    "azul": "#1f3fbf", "azul_oscuro": "#132a8f", "rojo": "#e0282f", "blanco": "#f7f7f7",
    "piel": "#d4925e", "piel_sombra": "#b37548", "pelo": "#e6e6f0", "pelo_sombra": "#b9bccf",
    "tinta": "#2a2a2a", "gris": "#c9ccd6", "iris": "#7a4a24", "iris_claro": "#a8703a",
    "boca": "#6b2f24",
}
SWATCH_ORDER = ["azul", "azul_oscuro", "rojo", "blanco", "piel", "piel_sombra", "pelo",
                "pelo_sombra", "tinta", "gris"]
SWATCHES = {name: (32 + 64 * (i % 16), 864 + 64 * (i // 16)) for i, name in enumerate(SWATCH_ORDER)}


def _level(rings, z):
    """Fracción (0..1) del tramo uv a la altura z (anillos de arriba abajo)."""
    frac = tube_fractions(rings)
    zs = [r[0][2] for r in rings]
    for i in range(len(zs) - 1):
        if zs[i] >= z >= zs[i + 1]:
            t = (zs[i] - z) / max(zs[i] - zs[i + 1], 1e-6)
            return frac[i] + t * (frac[i + 1] - frac[i])
    return frac[0] if z > zs[0] else frac[-1]


class Canvas:
    def __init__(self):
        self.img = Image.new("RGB", (SIZE * SS, SIZE * SS), COLORS["azul_oscuro"])
        self.d = ImageDraw.Draw(self.img)

    def poly(self, pts, color):
        self.d.polygon([(x * SS, y * SS) for x, y in pts], fill=COLORS.get(color, color))

    def rect(self, x0, y0, x1, y1, color):
        self.d.rectangle([x0 * SS, y0 * SS, x1 * SS - 1, y1 * SS - 1], fill=COLORS.get(color, color))

    def ellipse(self, cx, cy, rx, ry, color):
        self.d.ellipse([(cx - rx) * SS, (cy - ry) * SS, (cx + rx) * SS, (cy + ry) * SS], fill=COLORS.get(color, color))

    def line(self, pts, color, width):
        self.d.line([(x * SS, y * SS) for x, y in pts], fill=COLORS.get(color, color), width=int(width * SS), joint="curve")
        for x, y in (pts[0], pts[-1]):
            self.ellipse(x, y, width / 2, width / 2, color)

    def band(self, region, u0, v0, u1, v1, width, color):
        """Franja recta en coordenadas de región (u, v en 0..1)."""
        x0, y0, x1, y1 = region
        self.line([(x0 + u0 * (x1 - x0), y0 + v0 * (y1 - y0)), (x0 + u1 * (x1 - x0), y0 + v1 * (y1 - y0))], color, width)

    def save(self, path):
        self.img.resize((SIZE, SIZE), Image.LANCZOS).save(path, optimize=True)


def digit_one(c, cx, top, h, w, color):
    """Dígito 1 deportivo propio: asta inclinada y bandera. `w` = px por unidad de altura en X."""
    pts_stem = [(-0.12, 0.0), (0.12, 0.0), (0.2, 1.0), (-0.04, 1.0)]
    pts_flag = [(-0.04, 1.0), (-0.3, 0.8), (-0.28, 0.64), (-0.02, 0.8)]
    for pts in (pts_stem, pts_flag):
        c.poly([(cx + x * w, top + (1.0 - y) * h) for x, y in pts], color)


def number_11(c, cx, top, h, w, color):
    for off in (-0.3, 0.3):
        digit_one(c, cx + off * w, top, h, w, color)


def paint_face(c):
    x0, y0, x1, y1 = REGIONS["cara"]
    c.rect(x0, y0, x1, y1, "piel")
    s = (x1 - x0) / 384
    def P(x, y):  # coordenadas de un rostro de 384 px
        return (x0 + x * s, y0 + y * s)
    for side in (-1, 1):  # side -1 = izquierda de la imagen = derecha del personaje
        ex, ey = 192 + side * 74, 184
        # Ojo grande caricaturesco: esclerótica, iris con brillo, línea superior gruesa.
        c.poly([P(ex - 42, ey + 6), P(ex - 34, ey - 22), P(ex, ey - 33), P(ex + 34, ey - 22), P(ex + 42, ey + 3),
                P(ex + 28, ey + 28), P(ex, ey + 34), P(ex - 28, ey + 28)], "blanco")
        ix = ex - side * 4
        c.ellipse(*P(ix, ey + 2), 24 * s, 31 * s, "iris")
        c.ellipse(*P(ix, ey + 12), 16 * s, 16 * s, "iris_claro")
        c.ellipse(*P(ix, ey + 2), 11 * s, 15 * s, "tinta")
        c.ellipse(*P(ix + 9, ey - 11), 7 * s, 7 * s, "blanco")
        c.ellipse(*P(ix - 8, ey + 14), 4 * s, 4 * s, "blanco")
        c.poly([P(ex - side * 44, ey + 4), P(ex - side * 34, ey - 26), P(ex, ey - 38), P(ex + side * 34, ey - 28),
                P(ex + side * 48, ey - 8), P(ex + side * 56, ey - 18), P(ex + side * 40, ey - 21), P(ex, ey - 28),
                P(ex - side * 30, ey - 19)], "tinta")
        c.line([P(ex - side * 24, ey + 31), P(ex + side * 4, ey + 36), P(ex + side * 28, ey + 28)], "piel_sombra", 3 * s)
        # Ceja gruesa y decidida, más baja hacia el centro.
        c.poly([P(ex - side * 48, ey - 52), P(ex + side * 2, ey - 74), P(ex + side * 48, ey - 70), P(ex + side * 50, ey - 57),
                P(ex + side * 4, ey - 59), P(ex - side * 42, ey - 39)], "tinta")
    # Nariz (sombra) y sonrisa confiada, ligeramente ladeada.
    c.line([P(184, 238), P(192, 246), P(203, 240)], "piel_sombra", 5 * s)
    c.line([P(156, 288), P(176, 298), P(200, 300), P(222, 294), P(236, 280)], "boca", 6 * s)
    c.line([P(236, 280), P(242, 272)], "boca", 4 * s)
    c.line([P(178, 316), P(206, 318)], "piel_sombra", 3 * s)


def paint_shirt(c, rings):
    reg = REGIONS["camiseta"]
    x0, y0, x1, y1 = reg
    c.rect(x0, y0, x1, y1, "azul")
    w_px, h_px = x1 - x0, y1 - y0
    length = sum((Vector(rings[i + 1][0]) - Vector(rings[i][0])).length
                 for i in range(len(rings) - 1))
    px_v = h_px / length                  # px por metro en vertical
    px_u = (w_px / (2 * math.pi)) / 0.266  # px por metro en el frente (radio X del pecho)
    v = lambda z: _level(rings, z)  # noqa: E731
    # Cuello redondo rojo y escote en V delantero.
    c.rect(x0, y0, x1, y0 + v(1.405) * h_px, "rojo")
    c.poly([(x0 + 0.205 * w_px, y0), (x0 + 0.295 * w_px, y0), (x0 + 0.25 * w_px, y0 + v(1.315) * h_px)], "rojo")
    c.poly([(x0 + 0.222 * w_px, y0), (x0 + 0.278 * w_px, y0), (x0 + 0.25 * w_px, y0 + v(1.345) * h_px)], "azul_oscuro")
    # Franja diagonal roja propia (del hombro izquierdo a la cadera derecha) y trazo paralelo.
    c.band(reg, 0.43, v(1.33), 0.10, v(0.93), 0.032 * px_u, "rojo")
    c.band(reg, 0.45, v(1.21), 0.36, v(1.10), 0.014 * px_u, "rojo")
    # Espalda: dos trazos rojos sobre los omóplatos.
    c.band(reg, 0.60, v(1.36), 0.90, v(1.27), 0.024 * px_u, "rojo")
    c.band(reg, 0.62, v(1.31), 0.70, v(1.285), 0.012 * px_u, "rojo")
    # Bajo de la camiseta más oscuro.
    c.rect(x0, y0 + v(0.865) * h_px, x1, y1, "azul_oscuro")
    # Dorsal 11 blanco: pecho derecho del personaje (izquierda vista de frente) y espalda.
    number_11(c, x0 + 0.185 * w_px, y0 + v(1.285) * h_px, 0.11 * px_v, 0.11 * px_u, "blanco")
    number_11(c, x0 + 0.75 * w_px, y0 + v(1.29) * h_px, 0.22 * px_v, 0.22 * px_u, "blanco")


def paint_arm(c, rings):
    """Piel con dos brazaletes tribales propios: dientes bajo la manga y banda ancha en el antebrazo."""
    reg = REGIONS["brazo"]
    x0, y0, x1, y1 = reg
    c.rect(x0, y0, x1, y1, "piel")
    w_px, h_px = x1 - x0, y1 - y0
    v = lambda z: y0 + _level(rings, z) * h_px  # noqa: E731
    # Brazalete superior: dos líneas y dientes de sierra.
    top, bot = v(1.12), v(1.075)
    c.rect(x0, top, x1, top + 4, "tinta")
    c.rect(x0, bot - 4, x1, bot, "tinta")
    teeth = 10
    for i in range(teeth):
        a = x0 + w_px * i / teeth
        b = x0 + w_px * (i + 1) / teeth
        c.poly([(a, bot - 4), ((a + b) / 2, top + 5), (b, bot - 4)], "tinta")
    # Brazalete del antebrazo: bandas, zigzag y rombos.
    top, bot = v(0.995), v(0.905)
    c.rect(x0, top, x1, top + 5, "tinta")
    c.rect(x0, bot - 5, x1, bot, "tinta")
    zig = 12
    pts = [(x0 + w_px * i / zig, (top + 9) if i % 2 == 0 else (bot - 9)) for i in range(zig + 1)]
    c.line(pts, "tinta", 4)
    for i in range(zig):
        cx = x0 + w_px * (i + 0.5) / zig
        cy = (top + 13) if i % 2 else (bot - 13)
        c.poly([(cx, cy - 6), (cx + 6, cy), (cx, cy + 6), (cx - 6, cy)], "tinta")


def paint_short(c, side, rings):
    """Pierna del short: franja roja en el lateral exterior; 11 en la izquierda del personaje."""
    reg = REGIONS["short_" + side]
    x0, y0, x1, y1 = reg
    c.rect(x0, y0, x1, y1, "azul")
    w_px, h_px = x1 - x0, y1 - y0
    stripe = 0.05
    if side == "R":  # exterior = ángulo 0 (bordes del desenvuelto)
        c.rect(x0, y0, x0 + stripe * w_px, y1, "rojo")
        c.rect(x1 - stripe * w_px, y0, x1, y1, "rojo")
    else:  # exterior = ángulo 180° (centro)
        c.rect(x0 + (0.5 - stripe) * w_px, y0, x0 + (0.5 + stripe) * w_px, y1, "rojo")
        number_11(c, x0 + 0.27 * w_px, y0 + 0.42 * h_px, 0.42 * h_px, 0.075 * w_px, "blanco")
    c.rect(x0, y1 - 6, x1, y1, "azul_oscuro")


def paint(path, torso, arm, short_leg):
    c = Canvas()
    for name, (x, y) in SWATCHES.items():
        c.rect(x - 32, y - 32, x + 32, y + 32, name)
    paint_shirt(c, torso)
    paint_face(c)
    paint_arm(c, arm)
    paint_short(c, "R", short_leg)
    paint_short(c, "L", short_leg)
    c.save(path)
    return path
