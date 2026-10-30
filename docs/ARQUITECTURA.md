# Arquitectura técnica — vertical slice 3D

Decisión vigente: **Godot 4 estable, GDScript y 3D real**. Sustituye el pipeline
2D de la arquitectura v0.1. Validación inicial con Godot 4.6.3 estable, versión
instalada en cloud; 4.7.2 citado por documentos antiguos no se presupone instalado.

## Objetivo y límites del primer hito

Menú → selección con vista 3D → duelo local de 180 segundos contra bot → resultado
→ revancha. El Turbo #11 y El Rey #23. Dos goles terminan antes; al agotarse el
reloj, gana el mayor marcador; empate sin prórroga en este hito.
No es todavía 3v3 ni calidad comercial validada. Los modelos de entrenamiento son
provisionales, originales y reemplazables; no se usan las imágenes de `design/`
como texturas. Véase `ESTILO_3D.md` y `VERTICAL_SLICE_3D.md`.

## Escena y responsabilidades

```
game/
  project.godot                    # Mobile por defecto, landscape, física 60 Hz
  scenes/menu/main.tscn            # menú y selección; visor 3D independiente
  scenes/arena/arena.tscn          # composición de partido
  scenes/actors/player.tscn       # CharacterBody3D + colisión + vista
  scenes/ball/ball.tscn           # CharacterBody3D, trayectoria controlada
  scripts/core/                   # catálogo, datos, sesión, comandos de entrada
  scripts/actors/                 # movimiento, vida, habilidades, vista animada
  scripts/ball/                   # única autoridad de posesión y rebotes
  scripts/modes/                  # reloj, goles, bot, geometría y orquestación
  scripts/ui/                     # menú/HUD: no deciden goles ni daño
  scripts/vfx/                    # efectos efímeros sin autoridad de gameplay
  data/characters/*.tres          # parámetros y recurso GLB por héroe
  assets/models/                  # GLB original, estado documentado
  art/                            # fuente Blender y generador reproducible
  tests/                          # reglas y escenarios de integración headless
```

Coordenadas de cancha: X horizontal, Y altura, Z profundidad; metros Godot.
Movimiento y balón se resuelven sobre XZ a 60 ticks físicos. Un nodo de reglas
resuelve marcador/tiempo/fin. El balón es dueño de la posesión; ni UI ni actor
incrementan goles. El detector exige balón completo fuera de la línea del arco.
La cámara ortográfica inclinada encuadra la cancha y ajusta tamaño según aspecto.

## Sistemas intercambiables

- `CharacterDefinition`: estadísticas, dorsal, color, habilidad y PackedScene GLB.
  Catálogo de 16 plazas; solo dos implementadas. No leer referencias internas.
- `PlayerCommand`: movimiento y acciones independientes de teclado/bot. Punto de
  integración para joystick táctil y futuros comandos de red.
- `ArenaPlayer`: aceleración, frenado, colisión, vida, cooldown y respawn.
- `CharacterVisual`: carga GLB, pivotes de animación procedural (idle/run/kick/hit/
  celebrate). Sustituible por rig y AnimationTree sin cambiar reglas.
- `ArenaBall`: libre/poseído/disparo, pase de menor potencia y rebotes. Sin física
  libre de RigidBody que comprometa la conducción; no prometer determinismo entre
  máquinas con CharacterBody3D.
- `AbilityDefinition`: configuración de Turbo Sprint y Embestida Real; súpers
  diferenciadas por forma/color/alcance y reglas separadas del VFX.
- `MatchRules`: marcador, 180 s, victoria y cierre idempotente.

## Android y renderizado

Mobile (Vulkan) por defecto; Compatibility se selecciona al arrancar con
`--rendering-method gl_compatibility` o desde el editor antes de exportar.
Perfiles ALTO/BAJO ajustan sombras, escala 3D y VFX. Cambiar renderizador requiere
reinicio/reexport; el selector gráfico no finge cambiar de backend en caliente.
Materiales opacos, luz direccional única, ambientación simple; sin GI, SSR ni
texturas pesadas. Objetivo 60 FPS en dispositivos compatibles; requiere perfilado
en teléfonos reales y no constituye resultado de este hito. `ANDROID.md` detalla
requisitos gratuitos, exportación y matriz de pruebas pendiente.

## Preparación competitiva sin servidores

Separar comandos de entrada, estado de partido y presentación. El partido local
es hoy la autoridad única. No hay sockets, cuentas ni ranking. En el siguiente
hito de red el servidor deberá validar movimiento/posesión/gol/daño, versionar
comandos y producir snapshots. Harán falta predicción, reconciliación,
interpolación y pruebas de latencia. No sincronizar transformaciones como solución
final ni confiar resultados al cliente. GitHub Pages no aloja partidas.

## Recursos y privacidad

Blender → glTF/GLB explícito, sin dependencia de Blender al abrir el juego.
Solo `game/` es raíz exportable. `data/` y `design/` del repositorio quedan fuera.
Sin servicios externos, secretos, keystores, pagos ni logos licenciados.
