# El Cacique — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Guerrero / cobertura táctica**. PV: **5900**; velocidad: **6.2 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/cacique/README.md).

## Básico ofensivo — Choque Firme

Arco frontal corto; cada activación golpea una vez por rival.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 1000 |
| `range_m` | 2.5 |
| `interval_s` | 0.75 |

## Habilidad — Guardia de Bronce

Escudo frontal que exige orientar el cuerpo; no permite atacar mientras bloquea.

| Parámetro | Valor |
|---|---|
| `shield_hp` | 1500 |
| `duration_s` | 2 |
| `cooldown_s` | 8 |
| `front_angle_deg` | 120 |
| `move_multiplier` | 0.6 |

- Acabar o romper guardia devuelve ataques; no reembolsa cooldown. Flancos y espalda quedan expuestos.

## Súper — Bastión Solar

Coloca cobertura corta temporal, afecta rutas y bloquea disparos de ambos equipos.

| Parámetro | Valor |
|---|---|
| `cast_range_m` | 6 |
| `length_m` | 3 |
| `thickness_m` | 0.4 |
| `duration_s` | 4 |
| `health` | 1800 |
| `warning_s` | 0.6 |
| `damage` | 0 |

- Rechazar colocaciones sobre actores, muros, aparición o que eliminen todas las rutas. No consumir súper si es inválida. Actualizar física y navegación desde la misma entidad temporal.

## Respuesta rival y bot

Flanquear la guardia, rodear o romper el bastión. Su muro también corta sus disparos y desplazamientos.

Bot: Validar conectividad antes de colocar cobertura; jamás usar conocimiento oculto para encerrar al humano.

## Producción y aceptación

Animación propuesta: Guardia plantada con brazo extendido; impacto de puño, colocación de bastión con golpe al suelo; no rig de plumas o adornos pequeños.

Módulos que necesita: `melee`, `directional_guard`, `temporary_cover`, `dynamic_navigation`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
