# Arena de Ídolos — fundación de combate 3D

Videojuego de **combate arcade 3D estilizado**, inspirado conceptualmente en el
universo del fútbol chileno. No es simulador de fútbol. La decisión vigente está
en [DECISIONES_Y_ALCANCE](docs/DECISIONES_Y_ALCANCE.md) y prevalece sobre propuestas
anteriores. Plantel conceptual de 16 conservado; solo dos héroes implementados.

## Demo ejecutable actual

Batalla de entrenamiento local: **un jugador contra un bot**, sin red ni objetivos
deportivos. El Turbo #11: pelotazos eléctricos, Turbo Sprint y Remate Relámpago.
El Rey #23: golpe frontal, Embestida Real y Onda Real. Arena 3D con cobertura,
cámara superior inclinada, apuntado, vida, daño, eliminación, respawn, marcador,
resultado y revancha. 180 segundos o 5 eliminaciones; empate posible por tiempo.
El modo completo Batalla de Ídolos 3v3 es un hito posterior.

**Arte provisional:** personajes, arena, VFX y animaciones son recursos originales
de entrenamiento, no modelos finales ni calidad comercial verificada. No se han
validado 60 FPS en Android, export APK, táctil, GLB de artista ni multijugador.
No se importan imágenes de `design/`, escudos o rostros al juego.

## Ejecutar en tu computador (Windows, Linux o macOS)

1. Instala **Godot 4.7.2 estable, edición estándar** (GDScript, no requiere .NET),
   desde [Godot](https://godotengine.org/download/). Esta corrección se validó con 4.7.2; la fundación anterior se probó con 4.6.3. No necesita Blender,
   plugins, Python, cuentas ni servicios de pago para jugar.
2. Descarga la rama del PR o clona y cambia a ella:

   ```sh
   git clone https://github.com/openweb-cl/arena-idol.git
   cd arena-idol
   git switch codex/fix-projectile-aim
   ```

3. En el administrador de Godot pulsa **Importar**, selecciona `game/project.godot`
   y abre el editor. Espera la importación inicial. Pulsa **F6** solo si quieres
   probar una escena específica; para el juego completo pulsa **F5**.
4. Elige ídolo y pulsa JUGAR. Si Vulkan no funciona, cambia el renderizador en la
   esquina superior derecha a **Compatibility**, acepta el reinicio y pulsa F5.
   El menú permite perfiles ALTO/BAJO (sombras/VFX/escala 3D); ese selector no cambia
   el backend. Para volver a Mobile se debe reiniciar el editor/exportación.

Por terminal, desde la raíz (sustituye `godot` por la ruta de tu ejecutable):

```sh
godot --path game
# Alternativa sin Vulkan:
godot --path game --rendering-method gl_compatibility
```

### Controles

| Entrada | Acción |
|---|---|
| WASD / flechas | Mover con aceleración y frenado |
| Ratón | Apuntar sobre el terreno, independiente del movimiento |
| Clic izquierdo / Espacio | Ataque básico; cada pulsación dispara |
| E / Shift | Turbo Sprint o Embestida Real |
| Q / clic derecho | Súper con 100% de carga (se carga con impactos) |
| Esc | Pausa / continuar |
| F2 | Alternar línea de apuntado y alcance básico |
| F3 | FPS y contadores locales de render, no benchmark Android |
| Botones de resultado | Revancha o regreso al menú |

Sin movimiento previo del ratón, se apunta en la última dirección de movimiento.
La pérdida de foco pausa el combate. El eliminado reaparece a los 4 s con 1 s de
protección. Teclado/ratón primero; táctil queda pendiente.

## Campo de tiro y apuntado corregido

En el menú elige **CAMPO DE TIRO**. Turbo dispara al Rey inmóvil y sin ataques.
Teclas **1/2/3**: 3/7/12 metros; **4**: cobertura; **5**: fuera de alcance (14 m).
Apunta al torso y haz clic. El panel muestra impactos, bloqueos y expiraciones.
**F2** alterna línea de apuntado e indicador de alcance, también en combate normal.
No se cambiaron daño, vida, alcance ni evasión del bot.

[Explicación, regresión, instrucciones y capturas](docs/APUNTADO_Y_PROYECTILES.md).

## Ajustar valores sin programar

En el panel FileSystem de Godot abre `game/data/characters/turbo.tres` o `rey.tres`:
velocidad, aceleración, frenado, giro, PV, daño, cadencia, alcance, proyectil,
empuje y súper son campos del Inspector. Abre `game/data/abilities/*.tres` para
cooldown, duración, multiplicador, escudo y daño de contacto. `game/data/match.tres`
controla duración, eliminaciones objetivo y respawn. Guarda y reinicia partida
para comprobar los cambios. Recursos compartidos: cambiar un héroe cambia todas
sus instancias, no los dos arquetipos. No se guardan ajustes del menú entre sesiones.

Para incorporar arte usa `model_scene` y el [contrato GLB](docs/CONTRATO_ARTE_3D.md).
No hace falta modificar colisiones o scripts de daño. Las otras 14 plazas son
marcadores deshabilitados, no héroes jugables.

## Verificaciones

Con Godot en PATH:

```sh
godot --headless --path game --editor --import
godot --headless --path game --fixed-fps 60 --script res://tests/run_tests.gd
```

Con Python 3 opcional, el verificador también detecta errores de script aunque el
motor devuelva código cero y prueba exportación/arranque de PCK:

```sh
python tools/verify.py --pack
# Windows: python tools/verify.py --godot "C:/ruta/Godot_v4.7.2-stable_win64.exe" --pack
```

La suite ejerce reglas, escenas y física de combate; el tiempo fijo acelera
simulación, no mide FPS reales. Evidencias, capturas y pendientes en
[VALIDACION](docs/VALIDACION.md). Android: [guía de exportación](docs/ANDROID.md).

## Coordinación y próximos hitos

- [AGENTS.md](AGENTS.md): reglas de Codex. [CLAUDE.md](CLAUDE.md): reglas de Claude Code.
- [Arquitectura](docs/ARQUITECTURA.md), [GDD](docs/GDD.md), [mecánicas](docs/MECANICAS.md)
  y [roadmap](docs/ROADMAP.md).
- [Reparto y siguiente trabajo](docs/COORDINACION_AGENTES.md),
  [contrato artístico](docs/CONTRATO_ARTE_3D.md), [estilo 3D](docs/ESTILO_3D.md).
- [Plantel conceptual v0.4](docs/ROSTER_CANONICO_V0_4.md),
  [backlog](docs/issues/FOUNDATION.md), [derechos](legal/LICENCIAS_Y_DERECHOS.md).

Nunca desarrollar en main; ramas independientes y PR, sin merge sin aprobación.
Sin costes obligatorios de herramientas durante prototipado. La publicación
comercial, licencias, tiendas y servidores reales requieren revisión posterior.
