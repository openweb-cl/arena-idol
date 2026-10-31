"""Retratos de selección (busto, fondo transparente) para el panel de ídolos.

Uso: python art/lib/render_portraits.py [id ...]   (por defecto, los cuatro héroes con modelo)
Salida: game/assets/ui/retratos/<id>.png, 256×256 RGBA, Cycles CPU.
Renders del propio modelo provisional de cada héroe: no son arte final ni capturas.
"""
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
HEROES = [a for a in sys.argv[1:] if not a.endswith(".py")] or ["turbo", "rey", "principe", "pitbull"]
OUT = ROOT / "game" / "assets" / "ui" / "retratos"


def render(hero):
    bpy.ops.wm.open_mainfile(filepath=str(ROOT / "art" / hero / f"{hero}.blend"))
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device = "CPU"
    scene.cycles.samples = 32
    scene.cycles.use_denoising = False
    scene.render.resolution_x = scene.render.resolution_y = 256
    scene.render.film_transparent = True
    scene.view_settings.view_transform = "Standard"
    world = bpy.data.worlds.new("Retrato")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.35, 0.4, 0.55, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.6
    scene.world = world
    for name, energy, color, rot in (("Clave", 3.2, (1.0, 0.94, 0.85), (40, 0, -30)),
                                     ("Contra", 2.0, (0.6, 0.8, 1.0), (60, 0, 160))):
        light = bpy.data.lights.new(name, "SUN")
        light.energy = energy
        light.color = color
        obj = bpy.data.objects.new(name, light)
        obj.rotation_euler = [math.radians(a) for a in rot]
        scene.collection.objects.link(obj)
    cam_data = bpy.data.cameras.new("Retrato")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = 0.95
    cam = bpy.data.objects.new("Retrato", cam_data)
    scene.collection.objects.link(cam)
    scene.camera = cam
    target = Vector((0, 0, 1.6))
    cam.location = target + Vector((math.sin(math.radians(20)), math.cos(math.radians(20)), 0.12)) * 6
    cam.rotation_euler = (target - cam.location).to_track_quat("-Z", "Y").to_euler()
    OUT.mkdir(parents=True, exist_ok=True)
    scene.render.filepath = str(OUT / f"{hero}.png")
    bpy.ops.render.render(write_still=True)
    print("PORTRAIT", hero, OUT / f"{hero}.png")


for hero_id in HEROES:
    render(hero_id)
