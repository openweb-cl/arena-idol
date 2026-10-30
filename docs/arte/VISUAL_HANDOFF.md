# Handoff visual de Codex — 30 octubre 2026

Base: `main` con PR #8 de Claude fusionado. Rama `codex/visual-handoff`.
Handoff autorizado por el propietario: configuración de render, color de Turbo,
etiqueta del actor y pie de selección. Los GLB, Blender y animaciones no se editan.

## Realizado

- [x] Windows usa Compatibility desde el inicio, incluido el editor, mediante
  `rendering/renderer/rendering_method.windows="gl_compatibility"`.
- [x] Android mantiene Mobile mediante el valor base y el override `.mobile`.
  Linux/macOS conservan el valor base Mobile. No se cambia el preset Android.
- [x] `turbo.tres` usa el azul de la ropa `#1f3fbf`. Los nombres en menú se aclaran
  para contrastar con las tarjetas; el modelo conserva sus materiales originales.
- [x] PV/cargas tienen alineación inferior: el texto crece hacia arriba, con
  menor tamaño físico y ancla a 3,1 m. `status_label_height` queda en el inspector
  de `ArenaPlayer`; no se cambia el collider ni el tamaño del modelo.
- [x] Selección dice «MODELOS 3D PROVISIONALES · Arte en revisión».
- [ ] Confirmación del arranque por defecto en el PC Windows del propietario.
- [ ] Validación Mobile en Android real, GPU real y rendimiento.

## Decisión del renderizador

Se elige un valor seguro específico de Windows: el propietario ya confirmó que
Compatibility funciona allí. Un aviso depende de que el juego llegue a dibujar;
no resuelve un frame negro si Vulkan inicializa sin error. Un reinicio automático
de proceso no puede detectar de forma fiable esa incidencia y no se añade.
El fallback que trae Godot para una API ausente no cubre necesariamente un driver
que inicializa pero muestra negro.

Para probar otra vez Mobile tras revisar el driver de la GPU, desde la raíz:

```sh
godot --path game --rendering-method mobile
# Alternativa explícita, también para otros sistemas:
godot --path game --rendering-method gl_compatibility
```

Sustituir `godot` por el ejecutable local. La opción de consola vale solo para
ese arranque. Cambiar BAJO/ALTO no cambia backend. Para una futura variante Android
de gama baja, evaluar Compatibility en otro perfil/build y hardware antes de
cambiar `.mobile`. No se promete un APK ni 60 FPS a partir de estos ajustes.

## Evidencia

Godot **4.7.2 estable oficial** en Linux, importación sin Blender instalado:

- `python3 tools/verify.py --godot /ruta/Godot_4.7.2 --pack`: **192 comprobaciones**
  aprobadas (50 reglas/física, 41 proyectiles, 31 AUTO, 30 munición, 40 mapas),
  parseo, exportación PCK y arranque de menú, campo de tiro y ambas arenas.
- Resolución de feature overrides comprobada con un proyecto mínimo que copia
  `[rendering]` y exporta PCK Linux con etiquetas custom `windows`, `android,mobile`
  y sin etiquetas extra. `ProjectSettings.get_setting_with_override` devuelve,
  respectivamente, `gl_compatibility`, `mobile`, `mobile`. Es una prueba de
  selección de configuración, no de ejecución nativa en Windows/Android.
- Capturas reales 1280×720 con Compatibility/OpenGL llvmpipe, Xorg dummy:
  [selección](../captures/visual-handoff/01-selection.png),
  [arena A](../captures/visual-handoff/02-arena-a.png) y
  [recargando](../captures/visual-handoff/03-reloading.png).
  Se revisaron también Rey y arena B. Son escenas preparadas y entradas simuladas,
  sin retoque, no un playtest humano ni una medición de GPU.
- Reproducción visual: `art/lib/capture_heroes.gd -- --output=/ruta` y
  `game/tests/capture_reload.gd`, con display y `--rendering-method gl_compatibility`.
- El intento gráfico Mobile de esta ejecución no encontró `VK_KHR_surface` y
  Godot cayó a OpenGL. Sus capturas no se atribuyen a Mobile. La evidencia anterior
  de Claude permanece en `HEROES.md`; no sustituye verificar el PC afectado.

## Siguiente hito

Príncipe **#20** tiene GLB, no gameplay. La ficha C1 se prepara por separado en
`codex/principe-kit`; se presenta al propietario antes de crear el `.tres` o
programar `codex/principe-gameplay`. Pitbull **#17** queda después del playtest
del Príncipe. No se modifica combate ni se habilitan nuevos héroes en este PR.
