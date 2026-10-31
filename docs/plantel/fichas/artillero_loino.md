# El Artillero Loíno — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Artillero / presión preparada**. PV: **4200**; velocidad: **5.9 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/artillero_loino/README.md).

## Básico ofensivo — Disparo Naranja

Proyectil lento y fuerte; anticipación 0,20 s.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 1050 |
| `range_m` | 13.5 |
| `interval_s` | 0.9 |
| `ammo_capacity` | 2 |
| `recharge_per_charge_s` | 2.0 |
| `projectile_speed_m_s` | 16 |
| `projectile_radius_m` | 0.18 |

## Habilidad — Anclaje de Precisión

Prepara un siguiente básico más rápido y largo, sacrificando movilidad durante la ventana.

| Parámetro | Valor |
|---|---|
| `window_s` | 2 |
| `projectile_speed_bonus_pct` | 25 |
| `range_bonus_m` | 2 |
| `move_multiplier` | 0.5 |
| `cooldown_s` | 8 |

- No añade daño; se consume al aceptar un básico o expira. No permite atravesar cobertura.

## Súper — Cañonazo Naranja

Área fija muy anunciada para castigar a quien no sale.

| Parámetro | Valor |
|---|---|
| `damage_once` | 1800 |
| `cast_range_m` | 10 |
| `radius_m` | 3 |
| `warning_s` | 0.85 |
| `push_m_s` | 6 |

- Centro visible y válido; cobertura entre centro y víctima corta daño. El arco aéreo es solo VFX, no un sistema de altura jugable.

## Respuesta rival y bot

Acercarse durante preparación o cambiar de dirección para esquivar el proyectil lento. Dos cargas lo obligan a elegir.

Bot: Conservar distancia, no disparar áreas sobre posiciones futuras que no puede percibir.

## Producción y aceptación

Animación propuesta: Carga del brazo y retroceso visual, sin mover collider; no introducir root motion al apuntar.

Módulos que necesita: `straight_projectile`, `windup`, `prepared_attack`, `delayed_aoe`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
