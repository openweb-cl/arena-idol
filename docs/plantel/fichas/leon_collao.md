# El León de Collao — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Tanque / ruptura de formación**. PV: **6500**; velocidad: **5.7 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/leon_collao/README.md).

## Básico ofensivo — Zarpazo

Arco de garra de energía sin heridas o sangre.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 1050 |
| `range_m` | 2.5 |
| `interval_s` | 0.8 |

## Habilidad — Salto de Asalto

Dash con salto solo visual y primer contacto dañino.

| Parámetro | Valor |
|---|---|
| `distance_m` | 3 |
| `duration_s` | 0.3 |
| `contact_damage_once` | 450 |
| `cooldown_s` | 7.5 |

- Collider se queda en XZ, frena con paredes y primer rival; no invulnerabilidad.

## Súper — Rugido de Ruptura

Cono anunciado que empuja y reduce brevemente la presión rival.

| Parámetro | Valor |
|---|---|
| `damage_once` | 1400 |
| `range_m` | 5 |
| `angle_deg` | 100 |
| `warning_s` | 0.4 |
| `push_m_s` | 9 |
| `enemy_basic_damage_reduction_pct` | 15 |
| `debuff_duration_s` | 2 |

- No miedo automático, stun ni inversión de controles. Cobertura corta efectos; ataca por detrás del cono.

## Respuesta rival y bot

Atacar por flancos o desde distancia, salir del aviso del rugido y castigar salto fallido.

Bot: Romper una formación visible sin conocer posiciones ocultas; mismas reglas de cono y pared.

## Producción y aceptación

Animación propuesta: Melena secundaria simple, zarpazo amplio y rugido de pecho; puños humanos expresivos, sin simular pelo físico.

Módulos que necesita: `melee`, `dash`, `cone_damage`, `push`, `basic_damage_debuff`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
