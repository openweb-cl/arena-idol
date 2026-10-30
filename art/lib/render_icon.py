"""Ícono provisional de la app (original): busto de un héroe sobre fondo de la paleta.

Uso: python art/lib/render_icon.py turbo game/assets/ui/icono_provisional.png
Render Cycles CPU 512×512. PROVISIONAL: no es identidad comercial ni arte final.
"""
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
ARGS = [a for a in sys.argv[1:] if not a.endswith(".py")]
HERO = ARGS[0] if ARGS else "turbo"
OUT = Path(ARGS[1]) if len(ARGS) > 1 else ROOT / "game" / "assets" / "ui" / "icono_provisional.png"

bpy.ops.wm.open_mainfile(filepath=str(ROOT / "art" / HERO / f"{HERO}.blend"))
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 48
scene.cycles.use_denoising = False
scene.render.resolution_x = scene.render.resolution_y = 512
scene.view_settings.view_transform = "Standard"
world = bpy.data.worlds.new("Icono")
world.use_nodes = True
world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.012, 0.03, 0.12, 1)
scene.world = world
for name, energy, color, rot in (("Clave", 3.5, (1.0, 0.94, 0.85), (40, 0, -30)), ("Relleno", 1.5, (0.6, 0.75, 1.0), (60, 0, 150))):
    light = bpy.data.lights.new(name, "SUN")
    light.energy = energy
    light.color = color
    obj = bpy.data.objects.new(name, light)
    obj.rotation_euler = [math.radians(a) for a in rot]
    scene.collection.objects.link(obj)
cam_data = bpy.data.cameras.new("Icono")
cam_data.type = "ORTHO"
cam_data.ortho_scale = 1.15
cam = bpy.data.objects.new("Icono", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
target = Vector((0, 0, 1.52))
cam.location = target + Vector((math.sin(math.radians(25)), math.cos(math.radians(25)), 0.25)) * 6
cam.rotation_euler = (target - cam.location).to_track_quat("-Z", "Y").to_euler()
OUT.parent.mkdir(parents=True, exist_ok=True)
scene.render.filepath = str(OUT)
bpy.ops.render.render(write_still=True)
print("ICON", OUT)
