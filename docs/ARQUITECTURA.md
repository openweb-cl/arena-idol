# Arquitectura vigente — combate arcade 3D

Godot 4 estable, GDScript, 3D real; cámara superior inclinada. La corrección más
reciente de combate prevalece sobre v0.4 y sobre la primera propuesta 2D. No es
simulación de fútbol. Primera demo: entrenamiento de Batalla de Ídolos 1 humano
contra bot; equipos 3v3 y red son hitos posteriores.

## Toolchain y render

Fundación validada con Godot 4.6.3; corrección de apuntado y campo de tiro
validados con Godot 4.7.2 estable oficial. Mobile por defecto; arranque alternativo
`--rendering-method gl_compatibility` para equipos sin Vulkan. Perfiles BAJO/ALTO:
escala 3D, sombras y VFX; cambiar backend exige reinicio/exportación. Sin GI ni SSR.
Meta 60 FPS Android no medida hasta prueba en hardware. Véase `ANDROID.md`.

## Estructura común

```
game/
  project.godot                 # raíz exclusiva exportable, landscape, física 60 Hz
  scenes/menu/main.tscn         # menú/selección con SubViewport de retrato 3D
  scenes/arena/arena.tscn        # composición de partido, MatchConfig exportado
  scenes/actors/player.tscn     # CharacterBody3D; presentación intercambiable
  scripts/core/                # catálogo, Resources, sesión, PlayerCommand
  scripts/actors/              # movimiento, vida, habilidades, adaptador visual
  scripts/combat/              # proyectiles y resolución de ataques
  scripts/modes/               # reglas de eliminaciones, arena, bot, cobertura
  scripts/ui/                  # controles/presentación sin autoridad de daño
  scripts/vfx/                 # efectos provisionales desacoplados
  data/characters/*.tres       # estadísticas + modelo GLB opcional
  data/abilities/*.tres        # duración, fuerza, cooldown y color provisional
  data/match.tres              # duración, objetivo, respawn
  assets/models/               # destino de GLB de Claude (pendiente)
  tests/                      # pruebas de reglas e integración headless
```

## Responsabilidades y flujo

Teclado/ratón o bot → `PlayerCommand` → `ArenaPlayer` (movimiento/acciones) →
resolución de combate → vida/eliminación → `MatchRules` → HUD. La visual recibe
velocidad/estado/eventos, nunca decide daño. XZ es terreno, Y altura, unidades
métricas. Física a 60 Hz, aceleración/frenado, dirección de apuntado independiente,
colisión con obstáculos. Capas 1 terreno, 2 actores. Los proyectiles excluyen emisor.

`CharacterDefinition` exporta velocidad, aceleración, frenado, giro, vida, ataque,
alcance, cadencia, empuje, parámetros de súper y habilidad; además PackedScene
opcional y corrección de escala/rotación visual. No contiene referencias internas.
`AbilityDefinition` configura Turbo Sprint y Embestida Real. Los Resources son la
interfaz del propietario en el inspector, no requieren editar scripts para balance.
Catálogo de 16 plazas, solo dos disponibles.

`MatchRules` es la autoridad única del reloj/marcador/cierre. Cada eliminación
válida concede un punto al equipo contrario. Demo: 180 s o 5 eliminaciones,
respawn 4 s, empate por tiempo posible. Pausa detiene reloj, proyectiles y respawn;
revancha reconstruye estado. Los modos futuros son módulos de objetivos de combate;
sin lógica de goles, porterías, posesión ni pases. Balón de Gloria requiere una
redefinición de combate antes de planificar implementación.

Extensión de roles (diseño): todos conservan el comando de ataque básico. Mejoras
de poder, efectos de zona y desplazamientos se resuelven en gameplay, con filtros
de equipo y colisiones; arte/UI solo los representan. Modificar cobertura exige
mantener física y navegación coherentes. La ficha del Príncipe sigue pendiente de
aprobación; ni esos efectos nuevos ni terreno dinámico están implementados.

## Frontera artística

`CharacterVisual` acepta `model_scene` GLB/wrapper y clips `idle/run/kick/hit/
celebrate`. En ausencia de modelo usa **geometría provisional de entrenamiento**
con animación procedural; no son GLB finales ni arte comercial. Fuentes Blender,
rig y clips serán responsabilidad de Claude Code según `CONTRATO_ARTE_3D.md`.
Escenario y VFX actuales también provisionales. La UI es funcional, pendiente de
producción artística. `COORDINACION_AGENTES.md` evita ediciones simultáneas.

## Preparación competitiva

Comandos separados de presentación y estado; autoridad única local. No hay sockets,
servidores, cuentas, ranking ni persistencia de resultados. Para red: servidor
valida movimiento, daño y score; comandos secuenciados, snapshots, predicción y
reconciliación. `CharacterBody3D` no garantiza determinismo entre máquinas.
Primero combate local y equipos; después ensayo autoritativo 1v1 antes de 3v3.
No usar sincronización de transforms como solución final ni confiar score al cliente.

## Seguridad y coste

Solo `game/` es raíz exportable, excluye referencias privadas en `data/` y `design/`
de raíz. Sin servicios comerciales ni backend en este hito, sin recursos externos
copiados. Modelos actuales propios/provisionales. No subir claves ni keystores.

## Apuntado y diagnóstico

CombatAim comparte el plano Y=0,85 entre ratón y origen del disparo. Cursor sobre
collider de actor apunta a su centro; espacio vacío se proyecta al mismo plano.
CombatProjectile limita distancia, barre contra terreno/actores y emite resolución
para diagnóstico sin cambiar la autoridad de daño. Campo de tiro sin IA en
`scenes/training/projectile_range.tscn`; guía opcional F2. Detalles y evidencia
en APUNTADO_Y_PROYECTILES.md. Misma física/datos para humano y bot.

## Selección asistida

TargetSelector filtra candidatos registrados en la arena, compara distancia XZ y
barre esfera contra terreno antes de seleccionar. AUTO rellena PlayerCommand.aim;
MANUAL mantiene CombatAim. Ambos usan los mismos ataques y física. Los controles
sostenidos pertenecen al adaptador de entrada, no alteran cooldown ni activan
fuego autónomo. Indicador de selección y protección visible en HUD. Detalles y
validación en APUNTADO_AUTOMATICO.md.

## P1/P2: munición y mapas

AmmoDefinition es configuración compartida y AmmoState es estado por actor. Turbo
consume una de tres cargas en ataque básico aceptado y recupera una cada 1,5 s;
súper/sprint independientes. GameSession permite referencia sin recarga para
comparar. MatchReport guarda resultados locales, geometría y revisión de navegación.

ArenaDefinition alimenta visual, colisión, apariciones y navegación de A/B. El bot
usa espacio del cuerpo para decidir ruta y barrido del ataque para línea de tiro.
La arena original queda en prisma_a.tres; B experimental en prisma_b.tres. El
campo de tiro fija A para conservar regresiones. Recursos editables requieren
reiniciar escena. Evidencia y pendientes: PROGRESO_P1_P2.md.
