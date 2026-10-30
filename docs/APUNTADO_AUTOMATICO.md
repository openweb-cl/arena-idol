# Apuntado automático y combate cercano

Petición del propietario: seleccionar al rival más cercano; **solo apuntar**, el
jugador inicia el disparo. No se añade fuego autónomo. La observación original
se hizo con clics separados, por lo que no se atribuye el problema a mantener
pulsado ni se afirma haber reproducido una pérdida de colisión al acercarse.

## Controles

- Combate normal comienza con **AUTO**: selecciona el rival válido más cercano
  dentro del alcance del ataque básico y con trayectoria libre de cobertura.
- El anillo y texto **OBJETIVO** muestran la selección. El HUD muestra nombre y
  dorsal, o explica que no hay rival libre dentro de alcance.
- Clic izquierdo o Espacio inicia un ataque. Mantener cualquiera de ellos repite
  ataques a la cadencia existente. Soltar detiene repetición. Sin entrada no hay
  disparos, aunque haya un rival seleccionado.
- WASD permite retroceder/esquivar mientras la selección sigue al rival. E mantiene
  la habilidad del héroe; el sprint del Turbo sigue la dirección de movimiento.
- **T** alterna AUTO/MANUAL. Manual usa el ratón y mantiene la corrección del plano
  de combate del PR anterior. Cambiar modo cancela el disparo sostenido.
- **F2** conserva la línea y el indicador de alcance opcionales.
- Pausa, pérdida de foco, eliminación y fin cancelan controles sostenidos. Hay
  que iniciar de nuevo el disparo al volver. Clic durante eliminación no queda
  armado para la reaparición. Soltar sobre el HUD también se detecta.

El campo de tiro abre en MANUAL para conservar los ejercicios del ratón. Pulsar T
permite practicar AUTO con la diana inmóvil. Cambiar modo no modifica estadísticas.

## Selección y límites

`TargetSelector` recibe el actor y los candidatos registrados en su arena. Excluye
al propio emisor, aliados, eliminados, actores inactivos y referencias liberadas.
Compara distancia XZ al centro y aplica el alcance ya configurado. Un barrido de
esfera contra terreno verifica cobertura, incluido el radio del ataque básico.
No hay selección a través de obstáculos ni aumento de alcance/collider.

La selección recalcula dirección cada tick. Una vez lanzado, el proyectil sigue
recto: **no es teledirigido** ni impacta automáticamente. Un rival móvil puede
esquivar. Aliados pueden interceptar proyectiles según las reglas existentes;
la demo de combate sigue siendo un humano contra un bot, no 3v3 implementado.

Rey conserva la protección breve de Embestida Real. Si está protegido, el HUD
muestra **PROTEGIDO** y los tiros que colisionan sin quitar vida lo indican; cuando
termina la protección, los impactos vuelven a aplicar daño. La selección no omite
ese rival para simular aciertos. Estadísticas, IA, evasión y física no cambian.

## Comprobaciones ejecutadas

Godot **4.7.2.stable.official.ed1daf0bf**, Linux x86_64:

```sh
python3 tools/verify.py --godot /ruta/Godot_4.7.2 --pack
```

50 verificaciones originales + 41 de proyectiles + **31 nuevas**, todas aprobadas.
Las nuevas cubren selección entre dos rivales, filtros, cobertura, alcance,
referencias liberadas, ausencia de fuego autónomo, clic y Espacio sostenidos,
liberación sobre HUD, pausa, eliminación, cambio a manual y prioridad de súper
lista frente al básico sostenido.

Se verificaron clics separados a **0,86 m** en ocho direcciones con daño original
(850), sin alterar colliders. No se reprodujo fallo de colisión en ese escenario.
También se comprobó bloqueo por protección temporal, recuperación del daño cuando
termina y retroceso con teclado mientras se dispara al rival. Eso no sustituye
el playtest del propietario con el Rey activo ni certifica balance/diversión.

Importación/parseo, exportación PCK y arranque de menú, arena y campo de tiro
completados. `git diff --check` sin incidencias. Resources de balance sin cambios.

Capturas reales en Compatibility/OpenGL con Mesa llvmpipe/X11 virtual. Escenarios
preparados por script; el cursor está lejos del Rey y los resultados se resuelven
por entrada y física, sin sustituir daño por animaciones:

- [Rival seleccionado](captures/auto-target/01-target-selected.png)
- [Impacto por apuntado automático](captures/auto-target/02-auto-aim-impact.png)
- [Protección visible y colisión sin daño](captures/auto-target/03-protected-target.png)

No son un benchmark de GPU o Android. Arte provisional y validaciones móviles,
3v3 y red pendientes. Capturas regenerables con display disponible:

```sh
godot --path game --rendering-method gl_compatibility --audio-driver Dummy --fixed-fps 60 --script res://tests/capture_auto_target.gd
```

## Git

Rama `codex/auto-target`, creada desde main actualizado y con el PR #2 como
requisito previo porque main sigue sin juego. Conserva los commits originales de
los PR #1/#2; no modifica sus ramas ni fusiona PR alguno. El diff específico es
`codex/fix-projectile-aim...codex/auto-target`.
