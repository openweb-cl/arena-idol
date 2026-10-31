---
name: evidencia-y-reporte
description: Cómo verificar y reportar avances en Arena de Ídolos sin exagerar. Usar al cerrar un hito, escribir un PR, actualizar docs o informar resultados.
---

# Evidencia y reporte

- No declarar pruebas, calidad comercial, 60 FPS, Android ni multijugador sin
  evidencia medida.
- Reportar la versión real de las herramientas (p. ej. Godot 4.7.2, Blender/bpy
  5.2.3) y los comandos ejecutados con su resultado (aprobadas/fallos).
- Verificación habitual:
  - `python tools/verify.py --godot <godot>` (pruebas de juego).
  - `godot --headless --path game --script ../art/lib/check_hero_contract.gd -- --hero=<id>`.
  - `python tools/render_roster_design.py --check` si se tocan fichas del plantel.
- Cambios visuales: adjuntar capturas reales del build (selección y arena) en
  `docs/captures/<hito>/`; indicar si una imagen es render de Blender o lámina.
- Informar triángulos, materiales y costes de render; registrar incidencias y
  límites pendientes en vez de ocultarlos.
- Actualizar el documento de estado afectado (`docs/arte/*.md`, `CONTEXTO_DE_CONTINUIDAD.md`).
