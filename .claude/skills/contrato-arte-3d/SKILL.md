---
name: contrato-arte-3d
description: Contrato técnico Blender → GLB → Godot de Arena de Ídolos. Usar al crear, modificar, exportar o integrar modelos, animaciones, materiales o VFX.
---

# Contrato de arte 3D

Fuente completa: `docs/CONTRATO_ARTE_3D.md`, `docs/ESTILO_3D.md`, `docs/arte/HEROES.md`.

## Entrega

- Fuente `.blend` y script de construcción en `art/<id>/` (fuera de `game/`).
- Export GLB explícito a `game/assets/models/<id>/<id>.glb`. Godot nunca necesita
  Blender para abrir el proyecto.
- Herramienta: Blender como módulo `bpy` (PyPI, gratuito) en `.venv-bpy`; kit común
  en `art/lib/hero_kit.py`.

## Transformaciones

- Métrico, pies en (0,0,0), altura ≈ 2 m, frente -Z en Godot, transformaciones
  aplicadas. Sin cámaras, luces, scripts, física ni daño en el GLB.
- El collider es de gameplay (radio 0,42, altura 1,6); no se ajusta al mesh.

## Animación

- `AnimationPlayer` con clips `idle`, `run`, `kick`, `hit`, `celebrate`.
  Loop: idle/run/celebrate. Sin root motion.
- Sockets futuros `Muzzle` y `VFXOrigin`.

## Presupuesto y aceptación

- ≤ 8k triángulos y ≤ 8 materiales por héroe; texturas atlas ≤ 1024, opacas.
- Materiales compatibles con Mobile y Compatibility; objetivo 60 FPS sujeto a
  hardware real.
- Verificar con `art/lib/check_hero_contract.gd` y capturas reales de selección y
  arena (`art/lib/capture_heroes.gd`). Un render de Blender no es una captura de juego.
- Enlazar solo por `model_scene` del `.tres`; no tocar estadísticas para corregir
  proporciones.
