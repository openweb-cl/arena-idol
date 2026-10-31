# Contexto de continuidad — 31 octubre 2026 UTC

## Estado comprobado al preparar este paquete

Base: main `d88adc5`, PR #12 fusionado. Dos personajes jugables (Turbo #11 y Rey
#23), recarga y coberturas A/B. Cuatro GLB provisionales: también Príncipe #20 y
Pitbull #17, todavía sin gameplay. Plantel canónico: 16, sin reemplazos.

PR #13 (`codex/touch-controls`) y #14 (refresh UI de Claude, sobre #13) estaban
abiertos durante la revisión. Comprobar GitHub antes de retomar: este documento
es una instantánea, no un contador vivo. No fusionarlos ni forzar ramas ajenas.

## Decisiones más recientes

- Mejora visual en PC primero; el propietario aplazó pruebas de teléfono.
  Conservar preparación Android y la solución Compatibility en Windows.
- Personajes caricaturescos como las primeras imágenes adjuntas; composición de
  pantallas como la última, con retratos, personaje destacado y JUGAR visible.
- El propietario señaló que nuevas láminas cambiaban los personajes. Son
  exploraciones pendientes, no versiones finales ni reemplazos autorizados.
- Turbo V2 propuesta 01 fue aceptada como referencia visual: «Ese turbo esta muy
  bueno». Conservar cara/pelo/proporciones/equipación al llevarla a Blender.
- Evolución por estados V0/V1/V2/V3/candidato final, con revisión dentro de cada
  uno. Primero un **Turbo V2 coherente** como patrón; no intentar 16 finales a la vez.
- Aquí se pueden preparar láminas y especificaciones; el trabajo local con Claude
  las convierte en Blender/GLB, animaciones y UI. El repo conserva el contexto.
- Todos los héroes atacan, incluidos apoyos; habilidades pueden mejorar, proteger,
  desplazar o controlar zonas. Sin goles, pases o posesión obligatoria.
- AUTO apunta; el jugador dispara. No cambiar recarga/daño/vida para el arte.
- Príncipe: [ficha](PRINCIPE_KIT.md) pendiente de aprobación antes de gameplay.
  Pitbull espera su prueba. Los otros 12 dorsales aún no están definidos.

## Dónde continuar

1. Leer [biblioteca del plantel](plantel/README.md), [guía visual](plantel/VISUAL.md)
   y [referencias aportadas](../design/referencias/propietario_2026-10-31/README.md).
2. Revisar la carpeta [Turbo](../design/personajes/turbo/README.md): referencia,
   modelo actual y exploraciones están separados. Ya hay una primera propuesta V2
   con frente/perfil/espalda/expresiones, aceptada como referencia visual.
   Conservar la identidad y reconciliar diferencias técnicas entre vistas.
3. La referencia visual ya fue aceptada: refinar modelo/rig/clips; revisar en Godot con
   evidencia de selección y arena antes de extender el patrón al resto.
4. Mantener UI/gameplay en ramas separadas y acordar propiedad de archivos.
   No editar scripts reservados por Claude simultáneamente.

## Verificación de este paquete

`python3 tools/render_roster_design.py --check` valida 16 IDs canónicos, cuatro
dorsales, básicos ofensivos, archivos generados, hashes de referencias y enlaces.
El PR es de diseño y documentación: no modifica el juego. Las láminas generadas
no son capturas Godot. No se acredita calidad comercial, FPS, balance, Android
ni disponibilidad jugable de los otros 14 personajes.
