# El Turbo — #11

**Jugable: comportamiento vigente, no rebalanceado aquí.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Velocista / daño a distancia**. PV: **4000**; velocidad: **7.8 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/turbo/README.md).

## Básico ofensivo — Pelotazo eléctrico

Básico actual recto, físico y bloqueado por cobertura.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 850 |
| `range_m` | 13 |
| `interval_s` | 0.42 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.5 |
| `projectile_speed_m_s` | 19 |
| `projectile_radius_m` | 0.16 |

## Habilidad — Turbo Sprint

Aceleración actual dirigida por movimiento o frente.

| Parámetro | Valor |
|---|---|
| `cooldown_s` | 4.5 |
| `duration_s` | 0.3 |
| `speed_multiplier` | 2.7 |

- Sin daño de contacto ni inmunidad añadida. El collider conserva XZ.

## Súper — Remate Relámpago

Proyectil eléctrico grande actual.

| Parámetro | Valor |
|---|---|
| `damage` | 2300 |
| `range_m` | 16.9 |
| `speed_m_s` | 27.55 |
| `radius_m` | 0.32 |

- Conservar reglas de carga del código vigente; no rebalancear desde una lámina.

## Respuesta rival y bot

Baja vida; castigar sus ventanas sin cargas y cubrirse de líneas rectas. No debilitar arbitrariamente al Rey.

Bot: Mantener distancia y esquivar con el mismo sprint, cargas y cadencia que el humano.

## Producción y aceptación

Animación propuesta: Carrera con inclinación y cambios de dirección fluidos; ataque corto de pierna/brazo coherente con kick; celebrar con impulso y brazos abiertos.

Módulos que necesita: `straight_projectile`, `dash`, `ammo`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
