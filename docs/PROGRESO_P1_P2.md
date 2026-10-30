# Seguimiento: recarga y variantes de cobertura

Solicitud del propietario: ejecutar P1 y P2 y marcar lo realizado. Esta bitácora
separa implementación técnica y validación humana del equilibrio.

| Parte | Estado técnico | Evidencia / siguiente paso |
|---|---|---|
| P0 referencia | Disponible | Menú REGLAS permite comparar con #3 sin recarga; informes locales |
| P1 recarga | Implementada y verificada | 30 pruebas específicas; suite completa 152 comprobaciones |
| P1 capturas | Revisadas en runtime | Véase capturas/recarga abajo |
| P1 playtest | Pendiente del propietario | Repetir con Turbo y Rey en arena A |
| P2 mapas A/B | Pendiente | Se implementará después del paquete de recarga |
| P2 pruebas y capturas | Pendiente | Colisión, navegación y paridad A/B |
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

Incluye esquema, configuración (recarga/referencia), mapa A, versión de motor,
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
