# Mecánicas v0.1 (hipótesis ajustables)

| Parámetro | Valor para prototipo |
|---|---|
| Partida principal | 150 segundos, 3v3 |
| Victoria | 2 goles o mayor marcador al terminar |
| Movimiento | 8 direcciones/analógico |
| Cámara | cenital con ligero ángulo simulado 2.5D |
| Controles | stick + ataque/pase + súper |
| Vida base | 4000-6500 según rol |
| Respawn | 4 s |
| Energía súper | se carga por acciones activas, límite por balance |
| Balón | único, en terreno; posesión y liberación determinísticas |
| Fair play | sin friendly fire, sin ventajas de pago |

## Estados
IDLE -> MOVING -> ATTACKING / DASHING -> STUNNED -> RESPAWN. El balón: FREE -> CARRIED(player) -> SHOT/PASS -> FREE/GOAL. Colisiones y línea de gol deben resolverse **en un solo lugar**.

## Interacciones
- Ataque básico: daño a rivales y, según configuración, golpe al balón sin posesión.
- Botón contextual: si posees balón, pasa o remata según carga y dirección; sin balón, ataque.
- Súper: habilidad distintiva con telegraph legible, daño/CC con límites.
- Posición y cobertura importan más que spam.

## Balance
Cada arquetipo tiene fortalezas y debilidades; medir pick rate, win rate y tiempo de posesión. No copiar atributos/ataques de personajes comerciales.

## Red futura
Servidor autoritativo controla gol, daño, posesión, temporizador y resultados. Cliente predice movimiento local y reconcilia. Anticheat ligero, logs y métricas desde la prueba online.
