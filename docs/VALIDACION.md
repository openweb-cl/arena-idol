# Evidencia de validación — combate 3D

Tarea A / táctil: **243 comprobaciones aprobadas** en Godot 4.7.2 (192 anteriores
y 51 táctiles), PCK y arranque de escenas con controles. APK debug firmado,
alineado y analizado, aún sin teléfono real. [Reporte APK](APK_TACTIL.md),
[controles/evidencia](CONTROLES_TACTILES.md) e [instalación](ANDROID.md).

P1/P2: **192 comprobaciones aprobadas** en Godot 4.7.2; recarga, mapas A/B,
PCK y capturas. [Seguimiento vigente](PROGRESO_P1_P2.md). Playtest de equilibrio
del propietario pendiente. Los informes siguientes conservan evidencia anterior.

Actualización de selección AUTO y contacto: **122 verificaciones aprobadas** en
Godot 4.7.2, con fuego iniciado por el jugador. Ver
[APUNTADO_AUTOMATICO.md](APUNTADO_AUTOMATICO.md).

Actualización de apuntado en Godot 4.7.2: **50 + 41 verificaciones aprobadas**,
campo de tiro, exportación PCK y capturas de resultados físicos. Ver
[APUNTADO_Y_PROYECTILES.md](APUNTADO_Y_PROYECTILES.md) para evidencia vigente.
El informe siguiente conserva el contexto histórico de la fundación.

## Validación de la fundación (anterior a la corrección de apuntado)

Godot **4.6.3.stable.official.7d41c59c4**, Linux x86_64. Rama de implementación
`codex/game-foundation`, basada en `dea890d` de main. Sin cambios directos en main.

Comando reproducible desde raíz: `python3 tools/verify.py --pack`.
Resultado final: **50 verificaciones aprobadas, 0 fallos**, sin errores de script.
El verificador preserva código de salida y rechaza mensajes `SCRIPT ERROR`/`ERROR`
porque un arranque de Godot puede devolver cero incluso con fallos GDScript.

| Verificación ejecutada | Resultado |
|---|---|
| Importación headless de proyecto y parseo de todos los scripts | Aprobado |
| Catálogo, dorsales, 14 plazas bloqueadas y selección/menú | Aprobado |
| Eventos simulados de teclado, ratón y clic pasando por entrada/viewport | Aprobado |
| Movimiento acelerado, frenado y colisión con pared/cobertura | Aprobado |
| Proyectil, daño, exclusión del emisor y bloqueo por obstáculos | Aprobado |
| Disparo pegado a pared no salta la cobertura | Aprobado |
| Cadencia, carga de súper por impacto, consumo y cooldown | Aprobado |
| Melee, daño radial de Onda Real y Embestida con un impacto por uso | Aprobado |
| Eliminación, punto único, respawn y protección temporal | Aprobado |
| Pausa detiene reloj, cooldown, proyectiles y daño | Aprobado |
| Bot evade trayectoria entrante, navega y elimina al jugador | Aprobado |
| Partida simulada completa hasta victoria del bot por 5 eliminaciones | Aprobado |
| Empate/derrota por tiempo y cierre único de reglas | Aprobado |
| Botones reales de escena: iniciar, revancha y volver al menú | Aprobado por emisión de sus señales |
| Exportación PCK Linux con GDScript compilado y arranque de menú/arena | Aprobado headless |
| `git diff --check` | Aprobado |

La física se ejecutó a tiempo fijo acelerado; no es una medición de FPS ni un
playtest humano. Las pruebas simulan entrada/escenarios y verifican resultados de
física; no certifican diversión, equilibrio ni respuesta táctil.

## Inspección visual real, alcance limitado

Se ejecutó Godot con display X11 virtual y **Compatibility/OpenGL 4.5, Mesa
llvmpipe (software)**. Se renderizaron seis estados a 1280×720 y se revisaron
menú, selección, arena y resultado. Se corrigieron texto fuera de pantalla y
etiquetas de vida demasiado pequeñas. Única advertencia de render: el driver
virtual no permite cambiar VSync. No se midió rendimiento utilizable de GPU.

Las capturas son del runtime Godot, sin retoque. El script prepara posiciones y
resultado para revisar UI; **no son capturas de una partida humana ni prueba de
haber ganado**. El resultado fue verificado además por la suite de reglas.

- [Menú](captures/01-menu.png)
- [Selección de El Rey #23](captures/03-selection-rey.png)
- [Arena de combate y cobertura](captures/04-arena.png)
- [Resultado y revancha](captures/06-result.png)

Para regenerar con un display disponible:

```sh
godot --path game --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 60 --script res://tests/capture.gd -- --output=/tmp/arena-captures
```

Estas capturas se generaron desde el proyecto. El PCK se comprobó por separado
headless; no hay ejecutable nativo ni APK distribuido en este PR.

## Estado artístico y pendientes

Personajes, escenario, animaciones y VFX son **provisionales de mecánicas** con
geometría propia; no se ha entregado arte comercial, rig o GLB de artista. Hay
adaptador y contrato de integración para Claude Code, sin fingir participación
o revisión de ese agente. El objetivo visual conceptual sigue pendiente.

Sin validar: Mobile/Vulkan, Android físico, APK, 60 FPS, perfiles en teléfonos,
multitáctil, accesibilidad móvil, modelos GLB externos, rig/clips finales, audio,
3v3, red o comportamiento de múltiples equipos. No hay servidores ni servicios
de pago. Revisar ANDROID, COORDINACION_AGENTES y roadmap antes de ampliar alcance.

## Checklist del próximo playtest humano

- Abrir proyecto en Windows con la versión indicada; F5, elegir ambos héroes.
- Comprobar apuntado mientras se mueve, disparar desde cobertura y esquivar.
- Probar cada habilidad/súper, morir/reaparecer, pausa y pérdida de foco.
- Completar partida, revancha y regreso al menú. Registrar fallos y sensación de
  respuesta; no dar balance por aprobado sin observaciones.
- Revisar capturas con el propietario y entregar a Claude la producción de arte.
