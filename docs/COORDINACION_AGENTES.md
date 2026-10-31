# Codex y Claude Code — trabajo sobre GitHub

## Protocolo

Ramas independientes desde main actualizado, una por avance, con categoría y
descripción (regla del propietario, 30 octubre 2026): `novedad/<descripcion>`,
`cambio/<descripcion>` o `correccion/<descripcion>`. Sustituye a los prefijos
`codex/` y `claude/`; las ramas antiguas conservan su nombre.
Commits por hitos, PR hacia main y revisión del propietario. Ningún merge automático.
No editar los mismos archivos simultáneamente; no reset/force-push sobre rama ajena.
No se presupone que Claude haya trabajado o revisado esta entrega.

## Propiedad inicial

| Área | Responsable | Regla para el otro agente |
|---|---|---|
| project.godot, scenes/arena, scenes/actors/player.tscn | Codex | Proponer cambios en issue/PR |
| scripts/core, actors/player.gd, combat, modes, tests | Codex | No editar sin handoff |
| scripts/actors/character_visual.gd | Codex inicialmente | Transferir a Claude al integrar rig; congelar edición Codex |
| assets/models, materials, animations, art/ | Claude | Codex usa API del contrato, no remodela assets |
| scripts/vfx | Claude tras fundación | Codex emite eventos, no decide estilo final |
| scripts/ui, scenes/menu | Compartida con bloqueo | Acordar PR y responsable antes de editar |
| data/characters, data/abilities | Codex/propietario | Claude cambia solo campos de arte mediante PR acordado |
| docs/ESTILO_3D, CONTRATO_ARTE_3D, assets/README | Claude tras fundación | Cambios de API se revisan por ambos |
| docs/ARQUITECTURA, MECANICAS, pruebas | Codex | Revisión abierta, escritura coordinada |

Bloqueo ligero: el issue/PR debe listar archivos tomados, responsable y condición de
entrega. Si no está claro quién los está editando, revisar ramas/PR antes de mutar;
no resolver conflictos sobre cambios ajenos a ciegas. Revisión cruzada por PR no
autoriza merge. Cambios de contrato requieren actualización y prueba de ambos lados.

## Siguiente trabajo de Codex

### Reserva vigente: primer APK táctil

Codex toma `codex/touch-controls`: archivos propios `scripts/ui/touch_*`, pruebas
y exportación/configuración Android; integración mínima en arena/HUD/menú.
Claude reserva `scripts/art/*`, `assets/models/arena/`, `scripts/vfx/` y solo
presentación de `pitch.gd`. No cambian colliders, Rect2, apariciones o navegación;
Codex revisa ese diff. No editar simultáneamente esos archivos.

El refresh de style/menú/selección/HUD de Claude espera la fusión del PR táctil.
[CONTROLES_TACTILES.md](CONTROLES_TACTILES.md) documenta las referencias del HUD y
safe areas que deben conservarse. Esta reserva prevalece sobre el backlog siguiente.

Tarea B: `codex/principe-gameplay` después de A y de aprobación explícita de
`PRINCIPE_KIT.md`. Usar GLB existente y dorsal 20. Emitir `principe_shot`,
`principe_buff`, `principe_field_warning`, `principe_field` mediante `spawn_effect`;
Claude dibuja esos VFX. Pitbull #17 queda tras probar al Príncipe.

### Backlog técnico

1. Playtest y corregir apuntado/cobertura/IA con observaciones del propietario.
2. Añadir pruebas de equipo local 3v3 sin red y separar resolución por modo.
3. Adaptador táctil de dos sticks, botones y accesibilidad; probar Android real.
4. Perfilar CPU/GPU, draw calls y frame times en tres teléfonos; fijar presupuestos.
5. Tras gate de combate: diseño de comandos/snapshots y prueba autoritativa 1v1.

## Siguiente trabajo de Claude Code

1. Leer contrato y guía, crear exploración de siluetas originales Turbo/Rey; pedir
   revisión artística antes de tratarla como arte final.
2. Blender → GLB con escala/pivotes acordados; rig y cinco clips. Fuentes versionadas.
3. Wrapper visual y manifest de licencias; integrar mediante model_scene, comprobar
   ambos renderizadores y no cambiar colliders o valores de daño.
4. Sustituir VFX provisionales por poderes legibles, UI y arena coherentes; informar
   triángulos/materiales/draw calls y no prometer presupuesto sin medición.
5. Revisar capturas de build con el propietario, colaborar en perfilado móvil.
