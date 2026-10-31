# El Bati — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Asaltante / impacto preparado**. PV: **5000**; velocidad: **6.2 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/bati/README.md).

## Básico ofensivo — Golpe Violeta

Golpe corto, contundente y más lento que Rey.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 1050 |
| `range_m` | 2.4 |
| `interval_s` | 0.8 |

## Habilidad — Carga de Impacto

Prepara el próximo básico tras una anticipación que expone al actor.

| Parámetro | Valor |
|---|---|
| `warning_s` | 0.4 |
| `prepared_window_s` | 2 |
| `bonus_damage` | 500 |
| `push_m_s` | 8 |
| `move_during_warning` | 0.6 |
| `cooldown_s` | 7 |

- Se consume al aceptar el siguiente básico; KO cancela sin reembolso. No inmunidad.

## Súper — Ruptura Frontal

Dash corto anunciado que termina al primer enemigo o muro.

| Parámetro | Valor |
|---|---|
| `damage_once` | 1800 |
| `distance_m` | 4 |
| `warning_s` | 0.45 |
| `push_m_s` | 10 |

- Sin penetración ni invulnerabilidad; barrido continuo, una víctima por carga.

## Respuesta rival y bot

Esquivar la línea preparada y aprovechar su lentitud entre golpes. No puede perseguir indefinidamente.

Bot: Reservar carga si no tiene línea; no iniciar contra un muro que debería percibir.

## Producción y aceptación

Animación propuesta: Acumulación en hombro y mano, descarga corta y recuperación; ataque animado no mueve collider por sí mismo.

Módulos que necesita: `melee`, `prepared_attack`, `dash`, `windup`, `push`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
