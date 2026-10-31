# El Ilusionista — dorsal pendiente

**Ficha propuesta; gameplay sin implementar ni aprobar.** Esta ficha es preproducción; no habilita personajes en el juego.
La implementación vigente está en los Resources de `game/`, no en este JSON.

Rol: **Técnico / geometría de disparo**. PV: **3900**; velocidad: **6.9 m/s**.
Para héroes nuevos todos los números son valores de ensayo pendientes de revisión.

[Carpeta visual y evolución](../../../design/personajes/ilusionista/README.md).

## Básico ofensivo — Disparo de Efecto

Pulso recto que gira solo visualmente; no es el proyectil curvo del Pirata.

| Parámetro | Valor |
|---|---|
| `damage_per_attack` | 700 |
| `range_m` | 10.5 |
| `interval_s` | 0.55 |
| `ammo_capacity` | 3 |
| `recharge_per_charge_s` | 1.5 |
| `projectile_speed_m_s` | 20 |
| `projectile_radius_m` | 0.16 |

## Habilidad — Finta de Cristal

Paso lateral con una posimagen breve puramente visual.

| Parámetro | Valor |
|---|---|
| `distance_m` | 2.5 |
| `duration_s` | 0.22 |
| `afterimage_s` | 0.5 |
| `cooldown_s` | 6.5 |

- Posimagen sin collider/objetivo; no invisibilidad ni inmunidad.

## Súper — Prisma Resonante

Un prisma temporal permite un rebote legible de básicos propios y absorbe tiros rivales.

| Parámetro | Valor |
|---|---|
| `cast_range_m` | 5 |
| `duration_s` | 4 |
| `enemy_damage_budget` | 1200 |
| `max_bounces` | 1 |
| `damage` | 0 |

- Orientación ±45 grados según dirección lateral de colocación, guía de rebote. Los actores lo atraviesan. Preservar daño, emisor y alcance restante; no contar dos cargas de súper por el mismo ataque. Sin rebotes en cadena.

## Respuesta rival y bot

Moverse fuera de la trayectoria anunciada, entrar en melee o romper el prisma. No convierte todo el mapa en un laberinto.

Bot: Usar la guía y reglas de reflexión; no leer hitboxes ocultas para realizar tiros perfectos.

## Producción y aceptación

Animación propuesta: Gesto corto de muñeca, desplazamiento teatral contenido y plantado preciso del prisma; evitar magia que tape la batalla.

Módulos que necesita: `straight_projectile`, `dash`, `projectile_reflector`, `attack_id`.
Una lista no prueba que esos sistemas existan; varios requieren extender combate,
equipos, navegación o estados antes de implementar al héroe.

- [ ] Revisar kit con el propietario antes de programar.
- [ ] Probar básico, cobertura, cadencia, alcance, KO/respawn y paridad bot/humano.
- [ ] Probar habilidad/súper y cada límite indicado; efectos no aplican daño por sí mismos.
- [ ] Revisar contrajuego, ventanas y partidas humanas; no afirmar balance por cifras.
- [ ] Conservar versiones de Resources y comparar una variable por iteración.

[Reglas comunes](../REGLAS_COMBATE.md) · [Secuencia y módulos](../PRODUCCION.md).
