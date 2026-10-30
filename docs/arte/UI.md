# Refresh visual de UI — menú, selección, HUD y controles táctiles (V2)

Estado: **V2 provisional**, original y pendiente de revisión del propietario. Solo
presentación: no cambia reglas, entradas, zonas de toque ni textos que usan las pruebas.
Base: PR #13 de Codex (controles multitáctiles), según el contrato de
`docs/CONTROLES_TACTILES.md`.

## Archivos

| Archivo | Responsable | Cambio |
|---|---|---|
| `game/scripts/ui/style.gd` | Claude | Negrita (variación de la fuente incluida en Godot), paneles y botones inclinados con sombra y canto, barras y chips |
| `game/scripts/ui/menu_backdrop.gd` | Claude | Nuevo: fondo vectorial (degradado, franjas diagonales, hexágonos Prisma) |
| `game/scripts/ui/menu.gd` | Claude (tras #13) | Título, retrato enmarcado con el color del héroe y tarjetas por héroe |
| `game/scripts/ui/hud.gd` | Claude (tras #13) | Contorno de textos, barras de vida y súper, cargas en píldoras, overlay |
| `game/scripts/ui/touch_skin.gd` | Claude | Nuevo: aspecto de los controles táctiles |
| `game/scripts/ui/touch_controls.gd` | **Codex (handoff)** | Expone cinco valores numéricos y delega `_draw` a `TouchSkin` |

## Qué cambia

- **Menú:** fondo propio, «DOMINA LA ARENA.» en negrita, botones inclinados (el
  principal en dorado) y retrato 3D enmarcado con el color del héroe elegido.
- **Selección:** cada héroe tiene una tarjeta con el canto de su color, y la elegida
  se enciende en dorado. **El Príncipe #20 y el Pitbull #17 aparecen «EN DESARROLLO»**
  y siguen deshabilitados (14 plazas bloqueadas, como exige la prueba).
- **HUD:**
  - Marcador en negrita sobre panel con borde dorado.
  - El mensaje de arena y los textos llevan contorno oscuro, así se leen sobre el público.
  - Barra de vida (azul; roja por debajo del 30 %) y barra de súper (dorada; menta
    al 100 %) como hijas de `status`, para que sigan su posición también en el
    layout táctil.
  - Cargas en píldoras inclinadas y recarga en barra menta.
  - Overlay de pausa y resultado renovado.
- **Controles táctiles:**
  - MOVER: perilla azul con marcas.
  - ATACAR: retícula y segmentos de cargas en el anillo, con progreso de recarga.
  - HABILIDAD: doble chevrón con barrido de recarga.
  - SÚPER: estrella con anillo que se llena y brilla al 100 %.
  - PAUSA: ícono.
  - Modo AUTO/MANUAL: panel inclinado con la explicación.
  - Centros, radios y zonas de toque no cambian.

## Conservado para las pruebas y el adaptador

Textos «ARENA A/B», «REGLAS:», «ELEGIR ÍDOLO» y «CARGAS n/m», las 14 plazas
deshabilitadas, `menu.preview`, y las referencias del HUD que usa
`TouchHUDLayout` (`top`, `pause_button`, `keyboard_hints`, `footer`, `ammo_panel`,
`status`, `message`, `metrics`, `diagnostics`, `overlay`, `assist_status`,
`ammo_cells`, `ammo_title`, `resume`).

## Pruebas

`python3 tools/verify.py --godot Godot_4.7.2 --pack`: **243/243** (192 + 51 táctiles),
parseo, exportación PCK y arranque de escenas.

Capturas reales de Godot 4.7.2 (Forward Mobile en lavapipe; dos en Compatibility).
Son entradas preparadas, no teléfono:

- [Menú](../captures/ui-v2/mobile-01-menu.png) · [Menú (Compatibility)](../captures/ui-v2/compat-01-menu.png)
- [Selección Turbo](../captures/ui-v2/mobile-02-selection-turbo.png) · [Selección Rey](../captures/ui-v2/mobile-03-selection-rey.png)
- [HUD escritorio](../captures/ui-v2/mobile-04-arena.png) · [Pausa](../captures/ui-v2/mobile-05-pause.png) · [Resultado](../captures/ui-v2/mobile-06-result.png)
- Táctil: [AUTO](../captures/ui-v2/mobile-01-auto.png) · [mover y atacar](../captures/ui-v2/mobile-02-move-and-attack.png) · [MANUAL](../captures/ui-v2/mobile-03-manual.png) · [safe area](../captures/ui-v2/mobile-04-safe-area-simulated.png) · [Compatibility](../captures/ui-v2/compat-02-move-and-attack.png)

## APK de prueba de esta rama

APK debug exportado directamente desde esta rama, sin copias modificadas. Usa los
ajustes de `project.godot` del PR #13 (ETC2/ASTC e ícono provisional).

- 59.447.530 bytes, firma v2/v3 verificada con `apksigner`.
- SHA-256 `ab28203765aa7fe6e112d33a2fff7649887f8fcbd21f3a9b81088439d50cff6c`.
- Firmado con una clave de depuración local del entorno cloud, distinta de la de
  Codex. Si ya instalaste el APK de Codex, desinstálalo antes de instalar este.
- Build-tools 29.0.3 de Ubuntu (Codex usó los oficiales 36). No se instaló en ningún
  teléfono: rendimiento, multitáctil real y legibilidad física siguen pendientes.
  El APK no se versiona.

## Pendientes

- Probar en el teléfono del propietario: tamaño físico de botones y textos, y FPS.
- Los íconos de HABILIDAD y SÚPER son genéricos; cuando haya más héroes, darles un
  ícono por kit (embestida de Rey, campo del Príncipe).
- Fuente propia con licencia libre (OFL) si se aprueba; hoy se usa la de Godot.
