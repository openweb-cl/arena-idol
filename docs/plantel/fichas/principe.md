# El Príncipe — #20

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Estratega / precisión y apoyo**. PV: **4400**; velocidad: **6.6 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/principe/README.md).

[Ficha extensa del Príncipe — prevalece sobre este resumen](../../PRINCIPE_KIT.md). La aprobación y gameplay siguen pendientes. Eventos VFX: `principe_shot`, `principe_buff`, `principe_field_warning`, `principe_field`.

## Básico ofensivo — Pulso Certero

Proyectil preciso con anticipación de 0,12 s; no es un pase.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 750 |
| `range_m` | 12 |
| `interval_s` | 0.6 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.6 |
| `projectile_speed_m_s` | 22 |
| `projectile_radius_m` | 0.12 |

- Dirección fijada al aceptar; normalizar siempre el apuntado.

## Habilidad — Impulso Táctico

Aumenta temporalmente daño básico propio; extensión a aliados al probar equipos.

| Parámetro | Valor |
|---|---|
| `damage_bonus_pct` | 20 |
| `duration_s` | 3 |
| `cooldown_s` | 8 |
| `future_ally_radius_m` | 2.5 |

- En 1v1 tiene utilidad sobre sí mismo. No acelera recarga ni mejora la súper.

## Súper — Campo de Dominio

Anuncia una zona; pulso de daño/empuje y ralentización dentro del campo.

| Parámetro | Valor |
|---|---|
| `damage_once` | 900 |
| `cast_range_m` | 8 |
| `radius_m` | 3 |
| `warning_s` | 0.6 |
| `duration_s` | 3 |
| `slow_pct` | 25 |
| `push_m_s` | 10 |

- No sigue al rival. Cobertura y protección cortan efectos; no mueve muros.

## Respuesta rival y bot

Menor presión sostenida y sin sprint. Salir del aviso, forzarle a recolocarse y acercarse entre coberturas.

Bot: Preparar poder con munición; colocar el campo sobre una posición visible, sin conocer entradas futuras.

## Producción y aceptación

Animación propuesta: Manos medidas y carrera controlada; ataque de precisión reinterpretando kick; reverencia de celebrate existente.

Módulos que necesita: `straight_projectile`, `windup`, `damage_buff`, `zone`, `radial_push`, `slow`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
