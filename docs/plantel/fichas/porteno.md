# El Porteño — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Defensor / desplazamiento**. PV: **5800**; velocidad: **6.1 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/porteno/README.md).

## Básico ofensivo — Impacto de Marea

Arco frontal amplio pero lento; no daña a través de cobertura.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 950 |
| `range_m` | 2.8 |
| `interval_s` | 0.8 |

## Habilidad — Corriente Ascendente

Onda corta empuja enemigos visibles frente al actor.

| Parámetro | Valor |
|---|---|
| `damage` | 450 |
| `length_m` | 6 |
| `width_m` | 2 |
| `warning_s` | 0.18 |
| `push_m_s` | 7 |
| `cooldown_s` | 8 |

- Un impacto por enemigo; no hay física de agua ni movimiento vertical.

## Súper — Marea Cambiante

Corridor de corriente fija que desplaza enemigos y cambia rutas útiles.

| Parámetro | Valor |
|---|---|
| `length_m` | 8 |
| `width_m` | 2.8 |
| `duration_s` | 4 |
| `warning_s` | 0.6 |
| `damage_once` | 650 |
| `force_m_s` | 2 |

- Dirección fijada y flechas visibles; no daño por rozar muros ni empujes que los atraviesen. El enemigo puede atacar y salir lateralmente.

## Respuesta rival y bot

Abandonar el corredor por un costado y usar distancia. La corriente no impide disparar ni cambia controles.

Bot: Colocar corrientes para separar o retirar; no bloquear todas las salidas con conocimiento oculto.

## Producción y aceptación

Animación propuesta: Pasos pesados con hombros móviles; golpe de palma, gesto de barrido para marea, sin capas que tapen PV.

Módulos que necesita: `melee`, `directed_wave`, `force_zone`, `push`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
