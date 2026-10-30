"""Lámina de revisión de un héroe (muestra provisional, no arte final).

Renderiza vistas de giro y una pose por clip con Cycles en CPU (sin GPU) desde
art/<id>/<id>.blend y compone una lámina JPG. Uso:
    python art/lib/render_sheet.py <turbo|rey> [carpeta_salida]   # por defecto, temporal
Requiere bpy 5.2 (o Blender 5.2 --background --python) y Pillow para componer.
Las imágenes son renders de Blender, no capturas del juego.
"""
import math
import sys
import tempfile
import time
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
ARGS = [a for a in sys.argv[1:] if not a.endswith(".py")]
HERO = ARGS[0] if ARGS else "turbo"
OUT = Path(ARGS[1]) if len(ARGS) > 1 else Path(tempfile.gettempdir()) / f"{HERO}-renders"
TITLES = {"turbo": "EL TURBO #11", "rey": "EL KING #23"}
SAMPLES = 24
SIZE = (420, 560)

VIEWS = [  # nombre, azimut (0 = frente del personaje, +Y), elevación
    ("frente", 0, 8), ("tres_cuartos", 40, 12), ("perfil", 90, 5), ("espalda", 180, 10),
    ("camara_juego", 25, 52),
]
POSES = [("idle", 0), ("run", 0), ("kick", 4), ("hit", 2), ("celebrate", 11)]


def setup():
    bpy.ops.wm.open_mainfile(filepath=str(ROOT / "art" / HERO / f"{HERO}.blend"))
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = SAMPLES
    scene.cycles.use_denoising = False
    scene.render.resolution_x, scene.render.resolution_y = SIZE
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "Standard"
    world = bpy.data.worlds.new("Revision")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.03, 0.045, 0.09, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 1.0
    scene.world = world
    # Luz cálida principal arriba/izquierda y relleno frío, como ESTILO_3D.
    for name, energy, color, rot in (("Clave", 3.5, (1.0, 0.93, 0.82), (50, 0, -35)),
                                     ("Relleno", 1.2, (0.65, 0.8, 1.0), (60, 0, 150))):
        light = bpy.data.lights.new(name, "SUN")
        light.energy = energy
        light.color = color
        obj = bpy.data.objects.new(name, light)
        obj.rotation_euler = [math.radians(a) for a in rot]
        scene.collection.objects.link(obj)
    floor_mesh = bpy.data.meshes.new("Suelo")
    floor_mesh.from_pydata([(-30, -30, 0), (30, -30, 0), (30, 30, 0), (-30, 30, 0)], [], [(0, 1, 2, 3)])
    floor = bpy.data.objects.new("Suelo", floor_mesh)
    mat = bpy.data.materials.new("Suelo_Jade")
    mat.use_nodes = True
    mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.12, 0.42, 0.33, 1)
    floor_mesh.materials.append(mat)
    scene.collection.objects.link(floor)
    cam_data = bpy.data.cameras.new("Revision")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = 2.6
    cam = bpy.data.objects.new("Revision", cam_data)
    scene.collection.objects.link(cam)
    scene.camera = cam
    return scene, cam


def aim(cam, azimuth, elevation, target=Vector((0, 0, 1.0)), dist=6.0):
    az, el = math.radians(azimuth), math.radians(elevation)
    cam.location = target + Vector((math.sin(az), math.cos(az), 0)) * math.cos(el) * dist + Vector((0, 0, math.sin(el) * dist))
    cam.rotation_euler = (target - cam.location).to_track_quat("-Z", "Y").to_euler()


def render(scene, path):
    scene.render.filepath = str(path)
    start = time.perf_counter()
    bpy.ops.render.render(write_still=True)
    return time.perf_counter() - start


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    scene, cam = setup()
    arm = bpy.data.objects["Armature"]
    times = {}
    for name, az, el in VIEWS:
        aim(cam, az, el)
        times[name] = render(scene, OUT / f"render_{name}.png")
    aim(cam, 35, 14)
    for clip, frame in POSES:
        arm.animation_data.action = bpy.data.actions[clip]
        if arm.animation_data.action_slot is None and arm.animation_data.action.slots:
            arm.animation_data.action_slot = arm.animation_data.action.slots[0]
        scene.frame_set(frame)
        cam_target = Vector((0, 0, 1.15 if clip == "celebrate" else 1.0))
        aim(cam, 35, 14, target=cam_target)
        times[f"pose_{clip}"] = render(scene, OUT / f"render_pose_{clip}.png")
    total = sum(times.values())
    print("RENDER_TIMES", {k: round(v, 2) for k, v in times.items()}, "TOTAL", round(total, 1), "s",
          f"Cycles CPU {SAMPLES} muestras {SIZE[0]}x{SIZE[1]} hilos={scene.render.threads}")
    compose([n for n, _, _ in VIEWS], [c for c, _ in POSES])


def linear_to_hex(color):
    out = ""
    for c in color[:3]:
        c = 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
        out += f"{round(max(0, min(1, c)) * 255):02x}"
    return out


def compose(views, poses):
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("Pillow no disponible: renders sueltos sin lámina")
        return
    w, h = SIZE
    sheet = Image.new("RGB", (w * 5, h * 2 + 150), (12, 18, 38))
    draw = ImageDraw.Draw(sheet)
    for row, (names, prefix) in enumerate(((views, "render_"), (poses, "render_pose_"))):
        for col, name in enumerate(names):
            img = Image.open(OUT / f"{prefix}{name}.png").convert("RGB")
            sheet.paste(img, (col * w, 70 + row * h))
            draw.rectangle((col * w, 70 + row * h, col * w + 150, 92 + row * h), fill=(12, 18, 38))
            draw.text((col * w + 8, 75 + row * h), name.replace("_", " ").upper(), fill=(230, 240, 255))
    draw.text((12, 12), f"{TITLES.get(HERO, HERO.upper())} - MUESTRA PROVISIONAL (render Blender Cycles CPU, no captura de juego)", fill=(124, 255, 228))
    draw.text((12, 36), "Fila 1: giro y vista de camara de juego. Fila 2: idle / run / kick / hit / celebrate.", fill=(200, 210, 230))
    swatches = [(linear_to_hex(m.diffuse_color), m.name.split("_")[-1]) for m in bpy.data.materials if m.name.startswith("M_")]
    for i, (hex_color, label) in enumerate(swatches):
        x = 12 + i * 170
        y = 80 + h * 2
        color = tuple(int(hex_color[j:j + 2], 16) for j in (0, 2, 4))
        draw.rectangle((x, y, x + 50, y + 50), fill=color, outline=(255, 255, 255))
        draw.text((x + 58, y + 10), f"{label}\n#{hex_color}", fill=(230, 240, 255))
    sheet.save(OUT / f"lamina_{HERO}.jpg", quality=88)
    print("SHEET", OUT / f"lamina_{HERO}.jpg")


if __name__ == "__main__":
    main()
