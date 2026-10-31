# El Elegante — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Defensor técnico / contraataque**. PV: **4500**; velocidad: **6.8 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/elegante/README.md).

## Básico ofensivo — Golpe Preciso

Creciente de energía recto de daño moderado.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 750 |
| `range_m` | 9 |
| `interval_s` | 0.58 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.6 |
| `projectile_speed_m_s` | 22 |
| `projectile_radius_m` | 0.15 |

## Habilidad — Anticipación

Ventana breve que disipa el siguiente proyectil frontal; premia lectura, no reflejos perfectos automáticos.

| Parámetro | Valor |
|---|---|
| `window_s` | 0.8 |
| `front_angle_deg` | 100 |
| `cooldown_s` | 7 |
| `prepared_bonus_damage` | 300 |
| `prepared_window_s` | 2 |

- Solo tras bloqueo válido prepara un básico potenciado. No devuelve proyectiles, no cura; melee puede castigarlo.

## Súper — Cúpula del Viento

Burbuja de posición que absorbe proyectiles enemigos al cruzar su borde.

| Parámetro | Valor |
|---|---|
| `radius_m` | 2.5 |
| `duration_s` | 3 |
| `shared_health` | 1400 |
| `damage` | 0 |

- Los actores cruzan libremente; ataques lanzados dentro y melee no cruzan borde y no se bloquean. Presupuesto compartido, no escudo infinito.

## Respuesta rival y bot

Entrar en la cúpula o forzar el parry antes de atacar. No tiene escape acelerado.

Bot: Reaccionar a proyectiles visibles dentro de la ventana, sin adivinar entradas. Colocar cúpula para sostener posición.

## Producción y aceptación

Animación propuesta: Desvío pequeño de mano con anticipación propia; ataques ligeros y suaves, victoria con saludo lateral.

Módulos que necesita: `straight_projectile`, `parry`, `prepared_attack`, `projectile_barrier`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
