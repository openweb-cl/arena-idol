# Corrección de apuntado y campo de tiro

## Causa reproducida

El rayo del cursor se intersectaba con el suelo Y=0, pero el proyectil salía y
viajaba a Y=0,85. Con cámara inclinada, apuntar al torso desplazaba la posición XZ
calculada. Las pruebas anteriores usaban el origen a los pies: no detectaban el
paralaje visible. Se añadió primero una regresión que falla en la fundación:
Turbo en (-10,0,-2), Rey quieto en (2,0,-2), cursor sobre el torso (Y=1).
Tras la corrección ese mismo disparo resta exactamente 850 PV.

## Solución

`CombatAim` comparte altura de combate (0,85 m) entre proyección y origen. El rayo
sale de Camera3D mediante `project_ray_origin`/`project_ray_normal`. Si atraviesa
un collider de actor, excluyendo al emisor, se apunta a su centro de combate.
En espacio vacío se intersecta el plano de combate, no el suelo. No hay selección
por proximidad ni ampliación de colliders; cobertura sigue bloqueando el disparo.
Rayos paralelos o detrás del plano no sustituyen la dirección válida anterior.

El proyectil normaliza su dirección en XZ, conserva Y, excluye el cuerpo emisor y
barre una esfera con `move_and_collide` contra capas 1 (terreno) y 2 (actores).
La esfera básica conserva radio 0,16 y la súper 0,32. Se crea en el centro de combate
del emisor: evita generar el disparo al otro lado de una pared pegada. El paso se
limita a la distancia restante, sin sobrepasar el alcance; tiene además tiempo
máximo de seguridad (alcance/velocidad + 0,25 s), congelado durante pausa.
Núcleo sin sombreado y estela hacen el pelotazo legible sin cambiar su collider.

**Sin cambios de balance:** Turbo mantiene daño 850, velocidad del proyectil
19 m/s, alcance 13 m, cadencia 0,42 s, PV 4000; Rey mantiene PV 6200. No se cambian
estadísticas, evasión del bot ni IA para hacer que el jugador gane.

La guía opcional usa la misma altura y un barrido de esfera con el radio básico.
Se detiene en el primer collider o en el alcance (el anillo marca el alcance total).
Representa ataque básico, no la mayor potencia/alcance de la súper. Color naranja
significa que hay un collider en el camino, no garantiza daño. Solo el resultado
real del proyectil confirma impacto, protección o cobertura.

## Probar en tu computador

```sh
git fetch origin
git switch --track origin/codex/fix-projectile-aim
# Si la rama ya existe: git switch codex/fix-projectile-aim && git pull --ff-only
```

Importar `game/project.godot` con Godot **4.7.2 estándar**, pulsar F5 y elegir
**CAMPO DE TIRO**. También se puede abrir
`game/scenes/training/projectile_range.tscn` y pulsar F6.

- 1: corta distancia, 3 m.
- 2: media distancia, 7 m.
- 3: larga distancia, 12 m.
- 4: Rey detrás de cobertura.
- 5: Rey a 14 m, fuera del alcance del ataque básico.
- F2: alternar línea y anillo de alcance. También disponible en combate normal.
- Ratón al torso + clic: disparar. WASD sigue disponible para cambiar el ángulo.
- Esc: pausa; desde allí reiniciar el campo o volver al menú.

El Rey no se desplaza ni ataca en este modo; el daño, collider, proyectil y
cadencia son los de combate normal. Se fija su posición para inspeccionar impactos
sin que el empuje lo mueva. Cada tecla de ejercicio restaura vida y quita protección
inicial de la diana. Tras eliminación reaparece con la protección normal. No hay
límite de tiempo, victoria, score ni derrota por 5 eliminaciones en el campo.

Etiquetas de resultado: verde IMPACTO (pierde vida), naranja COBERTURA, violeta
ALCANCE/TIEMPO, PROTEGIDO si hubo colisión sin daño por invulnerabilidad. El panel
muestra contadores, último resultado, distancia recorrida y edad del proyectil.
Se conservan los últimos 20 eventos de la sesión en memoria, sin archivos ni red.
Reiniciar limpia contadores; cambiar ejercicio conserva contadores y limpia tiros
en vuelo. No se marca como impacto una protección de reaparición.

## Validación ejecutada

Motor oficial **4.7.2.stable.official.ed1daf0bf**, Linux x86_64. Descarga desde el
release oficial de Godot, ZIP verificado contra su SHA512-SUMS.txt antes de ejecutar.

```sh
python3 tools/verify.py --godot /ruta/al/Godot_4.7.2 --pack
```

- 50 verificaciones originales aprobadas.
- 41 nuevas verificaciones aprobadas de apuntado/proyectiles: ejercicios 3/7/12 m,
  ocho direcciones en pasillos reales, cámara inclinada alternativa, cursor al
  torso, rayos paralelos, daño original, cobertura, alcance, normalización XZ,
  exclusión del emisor, cadencia y un emisor bot usando el mismo sistema.
- Importación y parseo sin errores; arranque de menú, combate y campo de tiro.
- Exportación PCK y arranque headless de las tres escenas.
- `git diff --check` sin incidencias. Sin cambios en los Resources de balance.

Se revisaron capturas renderizadas en Godot 4.7.2, Compatibility/OpenGL mediante
Mesa llvmpipe en X11 virtual. Posiciones/clics preparados por script; impactos,
vida y expiraciones se resuelven por física, no se dibuja un resultado inventado:

- [Pelotazo en vuelo](captures/projectiles/01-projectile-in-flight.png)
- [Impacto a larga distancia: Rey baja de 6200 a 5350](captures/projectiles/02-impact.png)
- [Bloqueo por cobertura: Rey conserva 6200](captures/projectiles/03-cover.png)
- [Expiración a 13,00 m: Rey conserva 6200](captures/projectiles/04-range-expired.png)

Regenerar con display disponible:

```sh
godot --path game --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 60 --script res://tests/capture_projectiles.gd -- --output=/tmp/arena-projectiles
```

No acredita rendimiento de GPU, Android, Mobile/Vulkan, calidad comercial ni
balance final. El bot activo aún puede esquivar; la corrección garantiza apuntado
coherente y colisión, no que todo disparo contra una diana móvil deba acertar.

## Rama y dependencia de revisión

Rama `codex/fix-projectile-aim` creada desde `origin/main` actualizado (`dea890d`).
Como main aún contiene solo documentación y el PR #1 de fundación sigue abierto,
se incorporaron sus seis commits como requisito previo. El PR de corrección hacia
main incluye por ello la fundación; el diff específico se puede comparar contra
`codex/game-foundation`. No se fusionó ni modificó main ni la rama del PR #1.
