# Caballero Cruzado — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Asaltante / precisión de impacto**. PV: **4800**; velocidad: **6.8 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/caballero_cruzado/README.md).

## Básico ofensivo — Disparo Cruzado

Pulso de combate desde el golpeo del personaje; vestuario deportivo, sin espada.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 1000 |
| `range_m` | 8.5 |
| `interval_s` | 0.7 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.8 |
| `projectile_speed_m_s` | 20 |
| `projectile_radius_m` | 0.16 |

## Habilidad — Salto del Alba

Desplazamiento corto con salto solo visual; el collider sigue en XZ.

| Parámetro | Valor |
|---|---|
| `distance_m` | 3 |
| `duration_s` | 0.25 |
| `cooldown_s` | 6.5 |

- No atraviesa cobertura ni concede inmunidad. Debe detenerse con colisión barrida.

## Súper — Impacto Cruzado

Proyectil estrecho de impacto fuerte con preparación visible.

| Parámetro | Valor |
|---|---|
| `damage` | 1800 |
| `range_m` | 10 |
| `speed_m_s` | 25 |
| `radius_m` | 0.22 |
| `warning_s` | 0.55 |
| `push_m_s` | 5 |

- Dirección fija, primer rival o cobertura. Sin penetración ni autoimpacto.

## Respuesta rival y bot

Esquivar lateralmente la preparación y castigarlo tras gastar el salto. No igualar al tanque en vida.

Bot: Cerrar hasta distancia media usando el salto como colocación, sin saltarse muros.

## Producción y aceptación

Animación propuesta: Salto visual corto con rodillas y aterrizaje; ataque de pierna en kick, postura noble pero flexible.

Módulos que necesita: `straight_projectile`, `dash`, `windup`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
