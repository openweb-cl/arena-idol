# El Pitbull — #17

**Jugable: comportamiento vigente, no rebalanceado aquí.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Defensor / contención**. PV: **6400**; velocidad: **5.8 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/pitbull/README.md).

## Básico ofensivo — Impacto Corto

Golpe defensivo corto, sin desplazamiento automático del actor.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 900 |
| `range_m` | 2.2 |
| `interval_s` | 0.62 |

## Habilidad — Guardia de Hierro

Escudo personal de capacidad finita; puede seguir combatiendo.

| Parámetro | Valor |
|---|---|
| `shield_hp` | 1000 |
| `duration_s` | 2 |
| `cooldown_s` | 7 |
| `move_multiplier` | 0.9 |

- No es invulnerabilidad: gastar el escudo o esperar su fin permite daño normal.

## Súper — Zona de Contención

Pulso inicial y zona lenta fija donde activa para frenar avances.

| Parámetro | Valor |
|---|---|
| `damage_once` | 800 |
| `radius_m` | 3 |
| `warning_s` | 0.45 |
| `duration_s` | 4 |
| `slow_pct` | 20 |
| `push_m_s` | 6 |

- Un pulso por enemigo; ralentización solo dentro y sin bloquear acciones. Cobertura corta los efectos.

## Respuesta rival y bot

Mantener distancia, atacar desde ángulos y salir del área. Tiene menos alcance y velocidad que Rey.

Bot: Proteger un pasillo; escudo al recibir presión, sin conocer disparos futuros.

## Producción y aceptación

Animación propuesta: Tackle bajo del kick existente como golpe normal; guardia firme, carrera corta y celebración de salto.

Módulos que necesita: `melee`, `finite_shield`, `zone`, `slow`, `radial_push`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
