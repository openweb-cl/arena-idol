# El Guardián — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Protector / escudos**. PV: **6000**; velocidad: **5.5 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/guardian/README.md).

## Básico ofensivo — Pulso Defensivo

Pulso corto, ancho y lento; el protector también causa daño.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 700 |
| `range_m` | 7 |
| `interval_s` | 0.7 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.5 |
| `projectile_speed_m_s` | 15 |
| `projectile_radius_m` | 0.22 |

## Habilidad — Paso de Rescate

Paso lateral corto con escudo personal finito.

| Parámetro | Valor |
|---|---|
| `distance_m` | 2.4 |
| `shield_hp` | 700 |
| `shield_duration_s` | 1.3 |
| `cooldown_s` | 7.5 |

- La dirección sigue movimiento o lateral del frente; sin invulnerabilidad ni atravesar muros.

## Súper — Fortaleza

Otorga un escudo finito al propio actor y, en equipos, a aliados cercanos.

| Parámetro | Valor |
|---|---|
| `shield_hp_per_actor` | 1400 |
| `radius_m` | 3 |
| `duration_s` | 3.5 |
| `damage` | 0 |

- Se seleccionan beneficiarios al activar. En 1v1 protege al dueño. Escudos no se suman y no recuperan vida.

## Respuesta rival y bot

Poca velocidad y alcance; agotar o esperar escudos. No puede proteger permanentemente el mapa.

Bot: Usar escudo ante presión visible; cuando existan equipos, proteger aliados vivos dentro del radio sin privilegios.

## Producción y aceptación

Animación propuesta: Carrera de pasos firmes, apertura de brazos al escudar y ataque de palma; nada de animar una atajada o pase.

Módulos que necesita: `straight_projectile`, `dash`, `finite_shield`, `team_effect_query`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
