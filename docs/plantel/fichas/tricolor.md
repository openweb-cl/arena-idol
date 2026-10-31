# El Tricolor — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Apoyo / poder y movilidad**. PV: **4200**; velocidad: **6.4 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/tricolor/README.md).

## Básico ofensivo — Ráfaga Tricolor

Tres microproyectiles de 240 en abanico estrecho; daño máximo 720 por ataque.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 720 |
| `range_m` | 8.5 |
| `interval_s` | 0.65 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.8 |
| `projectile_speed_m_s` | 19 |
| `projectile_radius_m` | 0.1 |

- Una carga y máximo 25 de súper por ataque con daño real, no por fragmento.

## Habilidad — Escudo Solidario

Escudo personal y, al probar equipos, de un aliado cercano.

| Parámetro | Valor |
|---|---|
| `self_shield_hp` | 800 |
| `future_ally_shield_hp` | 800 |
| `future_ally_range_m` | 4 |
| `duration_s` | 2 |
| `cooldown_s` | 7 |

- No cura, escudos no se suman. En duelo sigue teniendo utilidad propia.

## Súper — Convergencia

Zona fija que recompensa combatir juntos sin quitar ataques normales.

| Parámetro | Valor |
|---|---|
| `radius_m` | 3.5 |
| `duration_s` | 4 |
| `basic_damage_bonus_pct` | 15 |
| `move_bonus_pct` | 15 |
| `damage` | 0 |

- Afecta dueño y aliados dentro; salir quita el beneficio. Con otros buffs se toma máximo por atributo, no se multiplican. No acelera recarga ni súper.

## Respuesta rival y bot

Separar al equipo del círculo, esperar su expiración y atacar desde fuera del alcance medio.

Bot: Mantener básicos y escoger posición útil; la ausencia de compañeros no elimina su ataque o beneficio propio.

## Producción y aceptación

Animación propuesta: Movimiento abierto y estable, puño triple en kick, señal de mejora con mano; posimagen de aliados nunca reemplaza gameplay.

Módulos que necesita: `multi_projectile`, `finite_shield`, `zone`, `damage_buff`, `move_buff`, `team_effect_query`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
