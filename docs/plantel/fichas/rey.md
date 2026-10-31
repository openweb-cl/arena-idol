# El Rey — #23

**Jugable: comportamiento vigente, no rebalanceado aquí.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Tanque / presión cercana**. PV: **6200**; velocidad: **6.0 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/rey/README.md).

## Básico ofensivo — Golpe frontal

Básico melee actual, condicionado por alcance, orientación y cobertura.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 1100 |
| `range_m` | 2.7 |
| `interval_s` | 0.65 |

## Habilidad — Embestida Real

Avance corto actual con protección y un contacto dañino.

| Parámetro | Valor |
|---|---|
| `cooldown_s` | 6 |
| `duration_s` | 0.34 |
| `speed_multiplier` | 2 |
| `shield_seconds` | 0.7 |
| `contact_damage` | 1100 |

- Un contacto por activación; no ampliar daño o inmunidad desde el diseño visual.

## Súper — Onda Real

Daño radial actual con empuje y onda violeta.

| Parámetro | Valor |
|---|---|
| `damage` | 1900 |
| `radius_m` | 4.5 |

- VFX no decide a quién daña. Conservar la línea de cobertura del código.

## Respuesta rival y bot

Alcance corto y menos velocidad. Cambiar de dirección, administrar distancia y aprovechar su cooldown.

Bot: Acercarse por cobertura, usar embestida para cerrar distancia, mismas reglas que el humano.

## Producción y aceptación

Animación propuesta: Carrera pesada ágil de lectura, gancho en kick, amortiguar golpes y celebración amplia sin root motion.

Módulos que necesita: `melee`, `dash`, `spawn_protection`, `radial_damage`, `push`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
