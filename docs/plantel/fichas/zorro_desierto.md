# El Zorro del Desierto — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Evasor / distracción**. PV: **3600**; velocidad: **8.2 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/zorro_desierto/README.md).

## Básico ofensivo — Agujas de Arena

Dos agujas de 250, abanico ±6 grados; un ataque consume una carga.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 500 |
| `range_m` | 9 |
| `interval_s` | 0.36 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.3 |
| `projectile_speed_m_s` | 23 |
| `projectile_radius_m` | 0.1 |

- Máximo 25 de súper por ataque aceptado con daño, no 25 por cada aguja.

## Habilidad — Evasión

Dash de huida corto con polvo de arena.

| Parámetro | Valor |
|---|---|
| `distance_m` | 3.2 |
| `duration_s` | 0.2 |
| `cooldown_s` | 5.5 |

- Sin inmunidad ni cruce de muros.

## Súper — Espejismo

Deja un señuelo y se desplaza para romper una línea de ataque.

| Parámetro | Valor |
|---|---|
| `decoy_life_s` | 2.5 |
| `decoy_health` | 1 |
| `escape_m` | 3.5 |
| `damage` | 0 |

- Un señuelo por dueño; targeteable por AUTO/bot según las mismas reglas, absorbe un impacto, no puntúa ni da carga de súper. Destello periódico permite reconocerlo. No ataca ni duplica habilidades.

## Respuesta rival y bot

Poca vida y daño por ataque. Leer el destello del señuelo y cubrir el final del dash.

Bot: No identificar señuelos mediante datos secretos; mismos filtros y señales que el humano.

## Producción y aceptación

Animación propuesta: Carrera elástica corta, cambios de dirección nítidos y clon de pose simple, sin simular ropa compleja.

Módulos que necesita: `multi_projectile`, `dash`, `decoy_target`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
