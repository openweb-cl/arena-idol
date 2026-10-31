---
name: coordinacion-agentes
description: Propiedad de archivos entre Claude Code y Codex en Arena de Ídolos. Usar antes de tocar scripts de gameplay, UI compartida, project.godot o data/.
---

# Coordinación de agentes

Fuente: `docs/COORDINACION_AGENTES.md`.

- **Claude Code:** Blender/GLB, modelos, animaciones, materiales, VFX
  (`scripts/vfx`, `scripts/art`), apoyo de UI, `docs/ESTILO_3D.md`,
  `CONTRATO_ARTE_3D.md`, manifest de assets.
- **Codex:** arquitectura, `project.godot`, movimiento, combate, IA, modos, pruebas,
  `docs/ARQUITECTURA.md`, `MECANICAS.md`.
- **Compartido con bloqueo:** `scripts/ui`, `scenes/menu`. Acordar responsable en
  el PR antes de editar.
- `data/characters`: Claude solo cambia campos de arte (`model_scene`) salvo que el
  propietario le asigne el gameplay de forma explícita.
- No editar los mismos archivos a la vez. Antes de tocar archivos ajenos, revisar
  ramas/PR abiertos (`gh pr list`) y dejar el handoff escrito en el PR.
- Si el propietario asigna gameplay a Claude en local, registrarlo en el PR y en
  `docs/COORDINACION_AGENTES.md`.
