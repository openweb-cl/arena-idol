# P3 / tarea A — adaptador táctil y handoff de UI

Estado: implementado y verificado con entradas simuladas; APK debug exportado,
teléfono real pendiente. Rama `codex/touch-controls`, sin merge automático.
Príncipe #20 sigue sin gameplay hasta aprobación explícita de su ficha.

## Comportamiento

Stick izquierdo analógico con zona muerta y diagonal limitada al máximo de teclado.
En AUTO, mantener ATACAR solicita básicos; AUTO solo selecciona/apunta al rival
visible dentro de alcance. Sin blanco válido no consume cargas. Soltar fuera del
botón detiene ataques. La UI no aplica daño ni evita las reglas de ArenaPlayer.

Cambiar a MANUAL cancela el ataque anterior y conserva el stick de movimiento.
Arrastrar ATACAR elige dirección y solicita disparos; el centro no dispara. La
dirección se normaliza, incluso en una deflexión pequeña. La guía usa física real
para cobertura/alcance. HABILIDAD y SÚPER se solicitan una vez por pulsación.

PAUSA deja visible el overlay normal y sus botones táctiles. KO, pausa, resultado,
pérdida de foco/background, resize y eventos canceled limpian contactos. Reanudar
o reaparecer requiere pulsaciones nuevas. Un dedo solo posee un control y cada
control un dueño; deslizar sobre otro no transfiere acciones. No cambian daño,
vida, cargas, IA, colliders, mapas o navegación.

## Estructura y entrada

| Archivo | Función |
|---|---|
| `scripts/ui/touch_input_state.gd` | Contactos por índice, ejes, zona muerta y acciones pendientes |
| `scripts/ui/touch_controls.gd` | ScreenTouch/ScreenDrag, dibujo provisional y señales |
| `scripts/ui/touch_safe_area.gd` | Pantalla→canvas con escala/barras y márgenes del menú |
| `scripts/ui/touch_hud_layout.gd` | Reubicación funcional separada del estilo |
| `scripts/modes/arena.gd` | Traducción a PlayerCommand; sin autoridad de daño en UI |

Se activan en Android/dispositivo táctil. En PC se pueden visualizar con
`godot --path game -- --touch-controls` o `force_touch_controls` en el inspector
de la arena. El flag no convierte ratón en dos dedos; para multitáctil se usa
hardware táctil o eventos preparados. Teclado/ratón siguen disponibles.

`emulate_mouse_from_touch=true` permite tocar botones GUI. La arena descarta el
ratón con `DEVICE_ID_EMULATION` como entrada de combate para no duplicar tiros o
apuntar con el dedo de movimiento. GUI conserva su recepción normal. Los ejes
manuales se convierten al XZ de la cámara, sin desvío vertical.

Safe areas usan `DisplayServer.get_display_safe_area()` y la inversa del
`Viewport.get_screen_transform()`: incluye escala, ventana y letterboxing.
Tamaños base en 1280×720: ataque 140, habilidad 100, súper 104 y pausa 96 px de
diámetro lógico; modo 175×96. Tamaño físico/legibilidad requieren teléfono.

## Contrato con el refresh de Claude

`menu.gd`: dos líneas agregan márgenes seguros. `hud.gd`: expone cinco referencias
existentes, sin rediseño. TouchHUDLayout usa `top`, `pause_button`, `keyboard_hints`,
`footer`, `ammo_panel` y las anteriores `status`, `message`, `metrics`,
`diagnostics`, `overlay`.

El refresh de Claude espera la fusión del PR táctil: conservar esas referencias
o adaptar TouchHUDLayout en su PR, y mantener tamaño/hitboxes/recepción de toques.
Claude reserva `scripts/art/`, `assets/models/arena/`, `scripts/vfx/` y solo la
presentación de `modes/pitch.gd`. Este hito no edita esos archivos. Física/Rect2/
apariciones/navegación siguen siendo autoridad de gameplay y se revisan en el PR.

## Pruebas y evidencia

`tests/test_touch_controls.gd`: **51 comprobaciones** de estado y eventos reales
en el árbol, usando Input para la emulación GUI. El harness distingue píxeles de
pantalla de coordenadas lógicas, incluido el viewport headless de 64×64.

- Dedos independientes, zona muerta, intensidad, diagonal, segundo dedo,
  liberaciones fuera, cancelación, modo y acciones únicas.
- Safe areas con notch simulado, pantalla ancha/4:3, ventana desplazada y barras.
- AUTO sin fuego autónomo, multitáctil movimiento/ataque y sin doble canal emulado.
- Cargas/cadencia/impactos, ataque sostenido durante recarga y manual preciso.
- Deflexión manual pequeña: regresión reproducida antes de normalizar dirección.
- Habilidad/súper con reglas actuales, prioridad de súper y rechazo sin medidor.
- Pausa/CONTINUAR por toque, background, KO/respawn, resultado y menú táctil.

`python3 tools/verify.py --godot /ruta/Godot_4.7.2 --pack`: **243 comprobaciones**
(192 anteriores + 51), importación/parseo, exportación PCK y arranque de menú,
campo de tiro, A/B y arena táctil, también desde PCK.

Capturas reales Godot 4.7.2, Compatibility/OpenGL llvmpipe, Xorg 1280×720:
[AUTO](captures/touch/01-auto.png), [MANUAL](captures/touch/03-manual.png),
[safe area simulada](captures/touch/04-safe-area-simulated.png) y
[pausa](captures/touch/05-pause.png). Entradas y posiciones preparadas, sin retoque;
no son capturas Android ni benchmark. Reproducir con display mediante
`tests/capture_touch_controls.gd -- --output=/ruta`. Instalación: [ANDROID.md](ANDROID.md).
