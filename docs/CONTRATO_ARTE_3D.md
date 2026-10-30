# Contrato de integración artística v1

Estado: API inicial para la fundación, no arte final entregado. Coordinar cambios
con Codex mediante PR antes de editar `character_visual.gd` o UI compartida.

## Entrega Claude Code

`game/assets/models/<id>/<id>.glb`, wrapper opcional `<id>_visual.tscn`, materiales
y texturas dentro de `game/assets/`. Fuentes `.blend` en `art/` de raíz para que no
se empaqueten. Manifest con autor, licencia, procedencia, fecha y estado de cada
recurso; no insertar referencias de personas/clubes ni mockups de design en build.
Blender gratuito → export GLB explícito. Godot no depende de Blender al arrancar.

## Transformaciones y nombres

Unidades métricas, pies centrados en (0,0,0). Altura aproximada 2 m, collider de
gameplay independiente (radio 0,42, altura 1,6). Y arriba, frente -Z en Godot;
Blender Z arriba se convierte al exportar glTF. Aplicar transformaciones. Sin
cámaras, luces, scripts, física o lógica de daño embebidos en GLB.
Raíz Node3D, opcional Armature/Skeleton3D. Sockets futuros `Muzzle` (ataque) y
`VFXOrigin`; su incorporación requiere ajustar el adaptador con prueba. En esta
fundación el origen del ataque lo calcula gameplay, no depende de sockets.

## Animación

`AnimationPlayer` descendiente llamado exactamente así, clips `idle`, `run`,
`kick`, `hit`, `celebrate`. Clips loop: idle/run/celebrate. Ataque/hit no loop.
Sin root motion: únicamente mesh/skeleton. El adaptador usa velocidad normalizada
para estado, `trigger("kick"/"hit")` para eventos y `celebration` para resultado.
Si se usan bibliotecas de animación con prefijos, entregar wrapper que remapee a
estos nombres. Clips faltantes no deben romper gameplay; registrar advertencia y
comprobarlos antes de aprobar integración. Para animación más rica, reemplazar el
adaptador por AnimationTree conservando la interfaz pública.

## Enlace sin tocar reglas

Abrir `game/data/characters/turbo.tres` o `rey.tres` en inspector. Asignar GLB/wrapper
a `model_scene`, ajustar `model_scale` y `model_rotation_degrees` si es necesario.
`CharacterVisual` carga ese recurso. Con `model_scene` vacío se usa placeholder
procedural, marcado expresamente en UI y manifest. No editar movimiento, collider,
vida o ataque para corregir proporciones del mesh. Estadísticas pertenecen a Codex/
propietario. Identificadores estables `turbo`/`rey`, dorsales 11/23.

## Presupuesto y aceptación

Objetivo inicial <=8k triángulos/héroe, <=8 materiales, texturas preferiblemente
atlas <=1024, opacos. Cifras son presupuestos, no mediciones de assets futuros.
Material StandardMaterial3D o shader compatible con Mobile y Compatibility.
Sin plugins comerciales. Revisar escala/frente/dorsal, cinco clips, sombra, ataques
sin mover collider, 3D de selección y arena, perfil bajo. Registrar capturas reales
y métricas. Quality gate comercial pendiente de arte final, legal, hardware y
playtests; no aceptarlo automáticamente al importar un GLB.
