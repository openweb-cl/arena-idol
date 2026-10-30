# Próxima iteración: recarga, cobertura, arte y plantel

Estado: **P1/P2 fusionados, muestras GLB integradas y C1 en diseño**. Se distinguen
implementación técnica, pruebas automatizadas y playtest humano. La aprobación
inicial del propietario no equivale a certificar equilibrio general.

## Seguimiento de ejecución

- [x] Rama de P1 creada desde main actualizado con las dependencias #3/#4 conservadas.
- [x] Recarga del Turbo implementada; referencia sin recarga y HUD disponibles.
- [x] Pruebas de P1 y revisión de capturas completadas (152 comprobaciones; PROGRESO_P1_P2.md).
- [x] PR de P1 publicado y fusionado por el propietario: #5.
- [x] Dos mapas A/B implementados con geometría y navegación compartidas.
- [x] Pruebas de P2 y revisión de capturas completadas (40 de mapas; 192 comprobaciones totales).
- [x] PR de P2 publicado y fusionado por el propietario: #6.
- [x] Prueba inicial del propietario: ambas arenas bien y recarga percibida como justa.
- [ ] Serie de playtest del propietario con ambos héroes y ambos mapas.
- [x] Muestras Blender/GLB de Turbo, Rey, Príncipe #20 y Pitbull #17: PR #8 fusionado.
- [ ] Completar V1/V2: revisión artística, VFX/audio, arena y HUD; hay muestras, no arte final.
- [x] Ficha C1 del Príncipe #20 redactada: [PRINCIPE_KIT.md](PRINCIPE_KIT.md).
- [ ] Aprobación del propietario antes de programar `codex/principe-gameplay`.
- [ ] Probar al Príncipe antes de empezar el gameplay del Pitbull #17.

P2 conserva A y ofrece B como variante; el propietario ya probó ambas y la recarga.
Sigue pendiente la serie comparativa con marcadores y duración. Las pruebas de bot
no sustituyen esa evidencia.
Sustenta el combate arcade 3D aprobado: Godot 4/GDScript, cámara inclinada,
Android como objetivo, herramientas gratuitas, recursos e identidad originales.
No es simulación deportiva; Batalla de Ídolos es el primer modo. La selección AUTO
apunta y el propietario inicia el disparo, según la elección vigente.

**Aclaración más reciente del propietario (30 octubre 2026):** todos tienen
ataques básicos ofensivos, incluidos asistentes/apoyos. Los roles se diferencian
por daño, resistencia, movilidad, mejoras de poder, protección y control de
zonas/desplazamientos en la arena. Especiales y súpers pueden cambiar posiciones
o sectores del mapa. Sin goles, porterías, posesión ni pases; los nombres
deportivos del roster histórico no fijan mecánicas. Cada kit sigue sujeto a revisión.

## Punto de partida y dependencia

En el playtest del propietario, Turbo ganó 5–0 bajo control humano y el bot Turbo
venció 5–3 al Rey humano. Son observaciones iniciales que justifican experimentar;
no certifican por sí solas equilibrio ni tasas de victoria generales.

La versión jugable está en `main`: fundación, apuntado/AUTO, recarga, A/B y muestras
GLB, con PR #8 de Claude integrado. El PR #9 (`codex/visual-handoff`) propone los
ajustes de Windows, azul de Turbo, etiquetas y selección; se revisa por separado.
Las ramas nuevas parten de main actualizado y ningún PR se fusiona automáticamente.
`codex/principe-kit` solo contiene diseño; todavía no hay gameplay del Príncipe.

## Secuencia y reparto

| Hito | Resultado verificable | Responsable | Dependencia |
|---|---|---|---|
| P0 | Referencia de pruebas y configuración actual congelada | Codex + propietario | Build de #3 disponible |
| P1 | Turbo con cargas, recarga y HUD legible | Codex | P0 |
| P2 | Dos variantes de arena comparables y navegables | Codex | P1 probado en mapa actual |
| V1 | Primera muestra artística 3D completa de Turbo | Claude Code | Contrato de arte de fundación |
| V2 | Rey, arena y HUD con estilo consistente | Claude Code + integración Codex | V1 revisado; geometría de P2 acordada |
| C1 | Tercer héroe: El Príncipe #20, estratega | Codex + Claude Code | Ficha aprobada antes de programar |
| P3 | Pruebas Android y presupuesto de render real | Codex + Claude Code | V2; adaptador táctil |
| C2 | Expansión gradual a 6 y luego 16 | Ambos | Cada héroe anterior probado |

P0/P1 y V1 pueden avanzar en paralelo en archivos distintos. No se agregan
recarga, mapa nuevo y nuevo kit en una única prueba de balance.

## P0 — Referencia medible

- Conservar una configuración de combate actual para comparar, sin sobrescribirla.
- Registrar personaje del humano/bot, modo AUTO/MANUAL, mapa, marcador, duración,
  impactos/tiros, veces sin munición y oportunidades de alcanzar distancia melee.
- Inicialmente repetir seis partidas por héroe con el mismo probador, alternando
  orden y punto de aparición cuando el entorno de prueba lo permita. Otro adulto
  puede repetir la serie por separado; no se presupone multijugador local o red.
- Distinguir balance de kits, errores de IA y familiaridad del jugador. No pedir
  un 50 % de victorias exacto a partir de una muestra pequeña.
- Verificar que ambos bots respeten las mismas reglas que el jugador. Mantener
  apuntado, daño, vida y física constantes durante la primera comparación.

**Salida:** configuración identificable y registro que permita comparar el mismo
escenario. No dar por aprobada la diversión con una simulación automatizada.

## P1 — Cargas y recarga de Turbo

### Hipótesis inicial para probar

- Tres cargas máximas para el ataque básico. Cada ataque aceptado consume una.
- Recuperar una carga cada **1,5 segundos**, mientras falte alguna. El ciclo empieza
  al primer consumo; disparar otra carga no reinicia ni acelera ese ciclo.
- Con el depósito lleno se detiene el temporizador. Con cero cargas no sale un
  proyectil ni se activa una animación de ataque falsa; el HUD indica RECARGANDO.
- Mantener clic/Espacio reintenta a la cadencia existente y solo dispara cuando
  hay una carga. No hay disparo autónomo sin entrada del jugador.
- La súper mantiene su medidor y coste propios, independiente de las tres cargas.
  No consume una carga básica. La habilidad de sprint tampoco consume munición.
- Aparición y reaparición: tres cargas y ciclo de recarga limpio. Pausa detiene el
  temporizador; reiniciar reconstruye estado. Manual y AUTO usan el mismo sistema.
- El bot Turbo utiliza las mismas cargas, recarga y cadencia. Rey no recibe una
  restricción de munición de proyectiles por heredar componentes compartidos.

**Tres cargas y 1,5 s son valores de ensayo**, no equilibrio aprobado. Mantener
primero daño 850, PV 4000/6200, alcance, velocidad, protección y cooldown de los
héroes actuales. Ajustar un parámetro de recarga por prueba si la evidencia lo pide.
No reducir daño o aumentar vida simultáneamente para forzar un resultado deseado.

### Implementación prevista

- Resource de parámetros editable en inspector: sistema habilitado, capacidad y
  segundos por carga. Configuración por héroe, no por dueño humano/bot.
- Estado de munición en actor/componente de gameplay, independiente de UI y VFX.
- Consumir dentro de la validación de ataque, no en entrada ni al dibujar el HUD.
  Rechazo por cooldown, eliminación o ausencia de blanco válido en AUTO no consume cargas. En MANUAL, un tiro
  válido al espacio vacío sí consume munición.
- HUD propio: tres segmentos y progreso de la siguiente carga, sin calcar recursos
  o interfaz comercial. Mostrar disponibilidad junto al personaje seleccionado.
- Campo de tiro con recarga activada para practicar. Un ajuste de laboratorio
  explícito permite aislar regresiones de proyectiles sin cambiar el modo normal.

### Pruebas y salida

Pruebas de consumo, capacidad máxima, cadencia, recuperación temporal exacta,
súper independiente, pausa, eliminación, reaparición, reinicio, clic/Space sostenido
y paridad bot/humano. Con cero cargas nunca puede aparecer un ataque básico.

Playtest en el **mapa actual**: comprobar si se entienden las cargas, si Rey puede
aprovechar las pausas y si Turbo conserva oportunidades mediante movilidad y
administración de recursos. Conservar marcadores y tiempos, no prometer equilibrio
con una cifra de victorias automática.

**PR:** `codex/turbo-reload`. Se revisa y prueba antes de introducir otra geometría.

## P2 — Cobertura que permita acercarse y flanquear

Probar cambios de distribución y acceso, no simplemente sumar muros.

- Conservar arena actual como A. Crear B con cobertura intermedia escalonada y
  rutas laterales; simetría entre puntos de aparición y varios accesos al centro.
- Evitar pasillos largos sin protección, esquinas que encierren al melee y
  corredores que obliguen al ranged a combatir siempre a contacto.
- Objetivo inicial: pasillos de al menos 2,4 m para el collider actual y zonas de
  giro cómodas. Revisarlo por movimiento real, no solo por medidas de plano.
- Muros sólidos primero: sin destrucción, alturas de tiro múltiples o arbustos
  con ocultación en esta etapa. Esos sistemas cambiarían más variables.
- Definir geometría en un Resource/escena compartida: colisión, navegación del bot,
  aparición y diseño visible deben derivar de la misma configuración. La lista
  de obstáculos estática de la IA actual no debe quedar desactualizada.
- La selección AUTO y la guía seguirán consultando colisiones reales. No seleccionar
  enemigos a través de la nueva cobertura. No crear apariciones bloqueadas.

### Comparación y salida

Usar la **misma recarga y estadísticas** en A/B. Pruebas de tiro pegado al muro,
bordes, alcance, cobertura, trayectos de bot y accesibilidad entre apariciones.
Comparar tiempo que tarda Rey en entrar a melee, posibilidades de retirada de
Turbo y puntos donde alguno queda atascado. Recorrer ambos sentidos de la arena.

**Salida:** dos mapas jugables, bot navega sin encallarse y ninguna configuración
crea tiros que atraviesen cobertura o una ventaja permanente de aparición.
**PR:** `codex/arena-cover-variants`.

## V1 — Empezar el refresh visual con una muestra completa

Responsable: Claude Code. Codex mantiene gameplay y la integración técnica.

1. Revisar las referencias de `design/` para energía, siluetas, color y jerarquía;
   no importarlas como recursos ni replicar identidades reales.
2. Definir una lámina breve: proporciones, paleta, materiales, cámara y escala.
   Turbo: ágil/azul con rojo; Rey: ancho/blanco-negro, oro y violeta. Mantener
   dorsales 11 y 23; decisión posterior en `arte/HEROES.md`.
3. Crear primero **un Turbo original en Blender**, exportar GLB y conservar fuente.
   Revisar escala y silueta en la cámara de juego antes de producir todo el plantel.
4. Incorporar rig y clips del contrato: idle, run, kick (ataque), hit y celebrate;
   sin mover el collider con la animación. El giro y disparo deben leerse con AUTO.
5. Completar materiales, un ataque y una habilidad con VFX/audio provisional
   coherente y procedencia documentada. No sumar luces o partículas sin presupuesto.
6. Verificar selección y arena en un build. Revisar con el propietario esa muestra
   antes de usarla como patrón para los demás personajes.

Objetivos iniciales existentes: <=8.000 triángulos y <=8 materiales por héroe,
texturas moderadas y materiales opacos. Son presupuestos por comprobar, no métricas
ya logradas. Arte provisional debe seguir identificado durante esta transición.

**Salida:** un héroe con pipeline completo y capturas de build, importable por
model_scene sin cambiar reglas de daño/colisión. No se declara calidad comercial.
**PR:** `claude/turbo-visual-slice`.

## V2 — Extender el estilo a Rey, arena y HUD

- Rey conserva silueta distinta, lectura de embestida, protección visible y onda
  radial distinguible. Los modelos no imitan rostros, kits o escudos de personas.
- Vestir la arena B elegida con muros y suelo coherentes, respetando exactamente
  la cobertura y rutas acordadas. No cambiar colisiones para acomodar decoración.
- Refresh de menú/selección y HUD: vida, cargas/recarga, objetivo AUTO/MANUAL,
  habilidad y súper claros. Botones y señales propios; evitar ruido sobre actores.
- Audio breve de ataque, impacto, recarga y protección: original/CC0 con manifest.
- Revisar contraste, lectura de proyectiles, animaciones y estados a tamaño de
  pantalla pequeño y en ambos perfiles gráficos. Materiales compatibles con los
  backends previstos; no medir solo una captura estática del editor.

**Salida:** Turbo y Rey con presentación coherente y acciones legibles en build.
Codex verifica que cambiar modelo/animación no cambie balance. No editar UI,
character_visual o scripts/VFX simultáneamente: acordar responsable y entrega.
**PR:** `claude/rey-arena-ui-refresh`, acotable en varios PR por recurso.

## C1/C2 — Incorporar personajes sin producir los 16 de golpe

Se conserva el plantel v0.4. Nombres e identidad comercial continúan provisionales.

**Tercero propuesto: El Príncipe #20 (UCH-02), estratega.** Amplía el triángulo de roles:
Turbo movilidad/distancia, Rey presión/cercanía y Príncipe precisión/control. Antes
de programarlo, definir una ficha de combate (ataque/activa/súper/debilidad) que
defina combate, apoyo y control de la arena. [PRINCIPE_KIT.md](PRINCIPE_KIT.md)
propone Pulso Certero (básico de daño), Impulso Táctico (mejora temporal de poder)
y Campo de Dominio (pulso que desplaza enemigos y zona lenta temporal). La ficha
está pendiente de aprobación; no hay pases ni objetivos deportivos. Su GLB
ya existe en `res://assets/models/principe/principe.glb`, para usar por `model_scene`.
El dorsal #20 y el #17 del Pitbull fueron decididos por el propietario en el hito
artístico de Claude. El Pitbull sigue solo como arte hasta probar al Príncipe.

Proceso por héroe:

1. Ficha y señal visual de sus acciones, con forma de responder a cada habilidad.
2. Resource y lógica con placeholder identificado; pruebas de ataque, daño,
   cooldown, munición si corresponde, AUTO, eliminación y reaparición.
3. Bot que use esas mismas reglas; probar cada enfrentamiento en ambos sentidos.
4. Modelo/rig/clips/materiales/VFX mediante el pipeline V1; mantener collider estable.
5. Capturas, métricas de render y playtest antes de desbloquearlo en selección.

Después de tres héroes probados, proponer una tanda hasta seis del roster vigente,
con roles complementarios. Ejemplos para evaluar: El Pitbull (defensor), El
Ilusionista (técnico) y El Zorro del Desierto (evasión). No aprobar seis kits de
combate o dorsales nuevos por inferencia de este listado. El resto de los 16 queda
planificado hasta superar los gates de combate, arte y rendimiento.

**PR de diseño:** `codex/principe-kit`. **Implementación:** `codex/principe-gameplay`.
**Arte:** `claude/principe-art`. Solo empezar integración al estar acordada la ficha.

## P3 — Android y preparación para ampliar jugadores

- Añadir el adaptador táctil con movimiento, selección AUTO/manual y ataque
  iniciado por el jugador. Mantener accesibilidad y botones simultáneos.
- Export APK debug con herramientas gratuitas; no implica publicación en tienda.
- Medir frame times, draw calls, CPU/GPU y memoria en teléfonos de baja/media/alta
  capacidad acordados, incluyendo sesión sostenida, fondo/pausa y safe areas.
- Meta 60 FPS donde el hardware lo soporte; perfiles bajos y Compatibility se
  evalúan en los dispositivos. Un test headless o --fixed-fps no acredita FPS.
- Probar coste y legibilidad de seis actores locales antes de declarar capacidad
  para Batalla de Ídolos 3v3. Red autoritativa permanece en otro hito.

## Coordinación y reglas de aprobación

Codex: estados/cargas, reglas, datos, físicas, navegación, pruebas y optimización.
Claude Code: Blender/GLB, rig, clips, materiales, VFX/audio y propuesta visual/UI.
El propietario revisa muestras, sensaciones y prioridades. Las tareas aquí asignadas
no afirman que Claude ya haya trabajado en ellas ni envían mensajes a otro servicio.

Las implementaciones deberán leer AGENTS.md, CLAUDE.md, el contrato artístico y
la coordinación presentes en la fundación aprobada. Propiedad compartida de HUD,
Resources y adaptador visual requiere handoff explícito por archivo. Commits
pequeños, pruebas relevantes y PR independientes; nunca desarrollar en main o
fusionar PR sin aprobación. Sin servicios de pago ni recursos protegidos copiados.

**Paquete actual:** revisar el handoff visual #9 y la ficha C1 en PR independientes.
Tras la aprobación de la ficha, implementar `codex/principe-gameplay`, probarlo y
recién evaluar Pitbull #17. Este documento por sí solo no implementa ni valida
esas funciones futuras.
