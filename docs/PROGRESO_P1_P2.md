# Seguimiento: recarga y variantes de cobertura

Solicitud del propietario: ejecutar P1 y P2 y marcar lo realizado. Esta bitácora
separa implementación técnica y validación humana del equilibrio.

| Parte | Estado técnico | Evidencia / siguiente paso |
|---|---|---|
| P0 referencia | Disponible | Menú REGLAS permite comparar con #3 sin recarga; informes locales |
| P1 recarga | Implementada y verificada | 30 pruebas específicas; suite completa 152 comprobaciones |
| P1 capturas | Revisadas en runtime | Véase capturas/recarga abajo |
| P1 playtest | Pendiente del propietario | Repetir con Turbo y Rey en arena A |
| P2 mapas A/B | Implementados | Selector del menú y Resource compartido; A original, B experimental |
| P2 pruebas y capturas | Verificadas | 40 pruebas de mapas; suite total 192 y capturas A/B |
| Equilibrio aprobado | Pendiente | No se deduce de pruebas automatizadas |
| Refresh visual y nuevos héroes | No iniciado | Fuera de los puntos 1/2 de esta entrega |

## P1 — Funcionamiento

Godot 4.7.2. Turbo usa tres cargas y recupera una cada 1,5 segundos. El reloj de
recarga comienza al primer consumo y disparar otra carga no lo reinicia. Al llenar
el depósito se detiene. Básico sin munición no crea proyectil ni reinicia animación.
Súper y sprint son independientes. Rey mantiene su ataque sin recurso de munición.

Reglas y estado son los mismos para bot/humano. Pausa detiene recuperación;
aparición/reaparición restaura cargas. Mantener clic/Space reintenta sin saltarse
ni cargas ni cadencia. AUTO sin objetivo válido no consume; un tiro manual al
espacio vacío sí lo hace. No cambian daño, PV, alcance, velocidad ni IA.

En el menú, **REGLAS: RECARGA** activa el ensayo; pulsar alterna a
**REFERENCIA SIN RECARGA**, que conserva el ataque ilimitado del PR #3 para ambos
controladores. La selección se aplica al iniciar/reiniciar; no se guarda entre
sesiones. HUD con segmentos y progreso, y cargas/recarga visibles sobre Turbo.

En CAMPO DE TIRO, **L** alterna el override de munición libre para aislar errores de
proyectiles cuando se usan reglas de recarga. No está disponible en combate normal;
no modifica el Resource compartido. En modo REFERENCIA el depósito ya es ilimitado.

Parámetros: `game/data/ammo/turbo.tres`, editables en el inspector. Otros héroes
pueden tener un recurso distinto o ninguno. Estado por actor, no en el Resource.

## Registro de partidas

Al finalizar combate normal se guarda automáticamente JSON en
`user://playtests/`. En el editor Godot, Project → Open User Data Folder permite
abrir esa carpeta. No hay envío a red ni datos personales.

Incluye esquema, configuración de munición (recarga/referencia), mapa A/B, geometría,
revisión de navegación, versión de motor,
modo de apuntado al finalizar, duración, marcador, héroe de humano/bot, ataques
aceptados, eventos de daño, tiempo/periodos sin cargas y tiempo en distancia melee
con trayectoria libre. Son datos de prueba, no estadísticas de servidor o ranking.
El archivo se guarda tras resolver la última acción para incluir el golpe final.

Para comparaciones, conservar el mismo modo de apuntado durante cada partida.
La referencia histórica del propietario sigue siendo 5–0 con Turbo y 5–3 a favor
del bot Turbo. Queda pendiente una serie nueva con recarga; no se inventan resultados.

## Verificación P1

`python3 tools/verify.py --godot /ruta/Godot_4.7.2 --pack`:

- 122 verificaciones anteriores y 30 nuevas de munición aprobadas.
- Consumo, límite, recuperación exacta, pasos grandes, ausencia de consumo por
  rechazos, independencia de súper/sprint, pausa/respawn, HUD, informes JSON,
  bot Turbo, disparo sostenido durante recarga, AUTO sin blanco y modo laboratorio.
- Importación/parseo, exportación PCK y arranque de menú/combate/campo de tiro.
- `git diff --check` sin incidencias.

Capturas reales, Compatibility/Mesa llvmpipe/X11 virtual; escenarios preparados,
cargas y daño resueltos por gameplay, sin retoque ni prueba de rendimiento Android:

- [Menú y referencia](captures/reload/01-menu-reload-rules.png)
- [Depósito vacío / recargando](captures/reload/03-empty-reloading.png)
- [Una carga recuperada](captures/reload/04-one-charge-restored.png)

## Playtest pendiente

1. Elegir Turbo, REGLAS RECARGA, arena A y jugar sin alternar AUTO/MANUAL durante
   esa partida. Registrar qué tan legible es el depósito y cuándo faltan cargas.
2. Repetir con Rey. Evaluar si se puede aprovechar la pausa para cerrar distancia.
3. Comparar con REFERENCIA SIN RECARGA, sin modificar otros parámetros.
4. Tras incorporar P2, comparar A/B con reglas idénticas. No cambiar a la vez daño,
   vida, velocidad, recarga y geometría para atribuir mejoras a una sola causa.

## P2 — Variantes comparables

El menú añade **ARENA A / ARENA B**. A es la distribución original exacta. B cambia
cobertura, no armas: siete bloques simétricos, dos protecciones intermedias en la
ruta frontal, cuatro coberturas hacia los extremos y una central. Tiene corredores
de al menos 2,4 m entre bloques y bordes. Se conserva la cancha común de 26 x 14 m.
No hay paredes destructibles, arbustos, cambios de altura de tiro o nuevos héroes.

Los Resources `res://data/maps/prisma_a.tres` / `prisma_b.tres` contienen Rect2 XZ,
apariciones y color provisional. `ArenaDefinition` alimenta a la vez visual,
colliders y rejilla del bot. Guardar y reiniciar partida tras editar el inspector.
Se puede asignar `arena_override` en una escena; `prisma_b.tscn` sirve para probar B
con F6 y para verificar su arranque dentro del PCK.

El bot ahora verifica espacio para su cuerpo al aproximarse a esquinas y usa el
barrido del ataque para comprobar si puede disparar. Es una corrección de
navegación/colisión necesaria en ambos mapas, no un cambio de daño, velocidad o
cadencia. La opción REFERENCIA conserva ataques sin recarga; ya incluye estas
correcciones de navegación en P2, por lo que no es una copia binaria íntegra de #3.

El campo de tiro permanece en A para conservar sus distancias/regresiones. Combate
normal usa el mapa elegido; revancha lo mantiene. HUD e informes identifican A/B.
Las reglas RECARGA/REFERENCIA son independientes del selector del mapa.

### Verificación de P2

Godot 4.7.2: 152 comprobaciones previas + **40 de mapas**, todas aprobadas. Se
comprobó geometría original A, simetría, apariciones libres, collider y celda de
navegación de cada bloque, conexión entre todas las celdas transitables, rutas en
ambos sentidos, movimiento contra muros, tiros pegados y bloqueo de AUTO.

Bots de ambos kits navegan y emiten ataques en A/B en escenarios de 15 s simulados
con diana quieta protegida; no son duelos competitivos ni certifican equilibrio.
Selector, independencia de reglas, iniciar B, revancha y regreso al menú probados.
Exportación PCK y arranque de A y B verificados. No se mide rendimiento con tiempo
fijo ni se declara completado el playtest humano.

Capturas renderizadas reales (posiciones preparadas) en Compatibility/software:

- [Selector A/B y reglas](captures/maps/01-menu-map-selector.png)
- [Arena A original](captures/maps/02-prisma-a.png)
- [Arena B experimental](captures/maps/02-prisma-b.png)

### Cómo comparar ahora

1. En el menú elegir héroe y REGLAS RECARGA, probar **ARENA A**.
2. Repetir con **ARENA B**, manteniendo héroe, modo AUTO/MANUAL y reglas.
3. Repetir la pareja de mapas con el otro héroe. Registrar sensación al cerrar
   distancia, retirada, bloqueo visual, munición y cualquier atasco.
4. Para aislar recarga, comparar RECARGA/REFERENCIA en **el mismo mapa**.
5. Conservar los JSON locales: reflejan mapa y geometría utilizados. El equilibrio
   y qué arena resulta más divertida siguen pendientes del propietario.

Estado de revisión: P1 en PR #5; P2 se publica en un PR separado con #5 como base
funcional. No se ha fusionado ningún PR en main. Refresh visual y personajes
siguientes siguen sin iniciar según el alcance aprobado (puntos 1 y 2).
