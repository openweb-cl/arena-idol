# El Pirata — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Creativo / trayectorias y agarre**. PV: **4600**; velocidad: **6.5 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/pirata/README.md).

## Básico ofensivo — Pelotazo Corsario

Proyectil con curva lateral fija máxima de 0,8 m, no homing.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 850 |
| `range_m` | 9 |
| `interval_s` | 0.7 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.7 |
| `projectile_speed_m_s` | 18 |
| `projectile_radius_m` | 0.16 |

- Barrido por segmentos y alcance por longitud real de trayectoria; no atajar el arco al consultar colisiones.

## Habilidad — Garfio de Impulso

Se engancha a cobertura visible para recolocarse sin atravesarla.

| Parámetro | Valor |
|---|---|
| `anchor_range_m` | 6 |
| `max_travel_m` | 3.5 |
| `stop_before_wall_m` | 1 |
| `cooldown_s` | 7 |

- Previsualizar anclaje válido. No consumir cooldown si no existe; no usa al rival como ancla de la activa.

## Súper — Abordaje

Garfio anunciado daña y acerca al primer enemigo golpeado.

| Parámetro | Valor |
|---|---|
| `damage` | 1000 |
| `range_m` | 7 |
| `speed_m_s` | 20 |
| `radius_m` | 0.2 |
| `warning_s` | 0.35 |
| `max_pull_m` | 2 |

- Detener en cobertura o primer enemigo. Pull con barrido, sin stun y con separación mínima de cuerpos; puede atacar/usar habilidad mientras lo arrastran.

## Respuesta rival y bot

Romper línea del gancho, esquivarlo y castigar su cooldown. El garfio no atraviesa muros.

Bot: Usar anclas válidas de la geometría actual; apuntar a posiciones observables, sin predecir entradas.

## Producción y aceptación

Animación propuesta: Lanzamiento de brazo y tirón del torso; pies no se deslizan artificialmente por root motion.

Módulos que necesita: `curved_projectile`, `terrain_anchor`, `pull`, `windup`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
