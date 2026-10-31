# El Príncipe #20 — combate, apoyo y control de arena

**Estado: APROBADA por el propietario e IMPLEMENTADA (valores de ensayo).**
El 31 octubre 2026 el propietario pidió «Príncipe y Pitbull, visual y jugable»,
lo que aprueba esta ficha, y asignó el gameplay a Claude Code en local. Rama
`novedad/principe-jugable`. El balance sigue pendiente de playtest. Pitbull #17
va después. Detalles de implementación y límites al final de este documento.

## Dirección vigente

El propietario reiteró el 30 octubre 2026: son batallas; todos tienen básicos
ofensivos, incluidos los asistentes. Los especiales pueden dar poder, apoyar y
alterar movimientos o zonas del mapa. Sin goles, porterías, posesión ni pases.

El Príncipe es un **estratega de precisión, apoyo y control**: dispara para causar
daño, activa una mejora temporal de poder y usa su súper para desplazar enemigos
y condicionar una zona. Conserva el personaje y dorsal canónicos; los nombres
ofensivos de esta ficha sustituyen los términos deportivos del roster histórico.

## Valores de ensayo

No aprobados como balance; no cambian a Turbo ni Rey.

| Parámetro | Propuesta |
|---|---|
| Vida / velocidad | 4400 PV / 6,6 m/s |
| Aceleración / frenado / giro | 38 / 48 / 14, respuesta base |
| Munición | 3 cargas; recupera una cada 1,6 s, disparar no reinicia el ciclo |
| Básico | 750 daño, 12 m, velocidad 22 m/s, radio 0,12 m |
| Cadencia / anticipación básica | 0,60 s / 0,12 s |
| Activa | +20 % daño básico durante 3 s; cooldown 8 s |
| Súper | Zona radio 3 m, colocación hasta 8 m, aviso 0,60 s |
| Efectos de la súper | Pulso inicial de 900 daño y empuje radial; zona lenta durante 3 s |
| Carga de súper | 25 por básico con daño válido; cuatro impactos |

## Básico — Pulso Certero

Proyectil de combate preciso que daña al primer rival o se bloquea con cobertura.
Sin homing, rebotes, pases, críticos o penetración. La forma puede ser una esfera
de energía o un pelotazo de combate; no hay receptor aliado ni circulación de balón.

Consume una carga al aceptar el ataque y fija entonces la dirección. Tras 0,12 s
sale del origen de combate actualizado. Puede caminar durante la anticipación;
no encola ataques. Si queda KO antes de disparar, se cancela sin devolver carga.
La cadencia de 0,60 s comienza al aceptar; pausa congela anticipación y cooldown.

AUTO mantiene blanco visible y no garantiza impactos; MANUAL permite anticipar
movimientos. El jugador inicia el disparo, mantener pulsado respeta cargas y
cadencia. La súper tiene prioridad si ambas acciones llegan en el mismo comando.

## Activa — Impulso Táctico

Mejora de poder activada con E/Shift: **+20 % de daño básico durante 3 s**, cooldown
**8 s** desde aceptar la activación. No consume munición, no dispara y no mejora
la súper, efectos de zona, recarga o duración de otros poderes.

- En la demo 1v1 afecta al propio Príncipe: sus básicos pasan de 750 a **900**.
  Tiene utilidad aunque no haya aliados; sigue siendo un combatiente.
- Diseño de equipo: también beneficiará a aliados vivos a **2,5 m al activar**,
  durante los mismos 3 s aunque luego se separen. Esa extensión exige probar
  varios actores/equipos; no se declara implementada ni obliga a crear 3v3 ahora.
- La mejora se captura al aceptar cada básico. Si el proyectil llega después de
  expirar, conserva el daño asignado; no se modifica el Resource del héroe.
- No acumula multiplicadores: igual potencia refresca duración; una más débil no
  sustituye ni prolonga una más fuerte. El efecto y su tiempo se muestran en HUD.
- KO/respawn limpia la mejora del afectado; pausa la congela. No da escudo, sprint
  o invulnerabilidad. El crédito de daño y carga de súper sigue siendo del atacante.

## Súper — Campo de Dominio

**Control espacial de la batalla**, no otro disparo básico más fuerte. Coloca un
campo temporal en el terreno para separar enemigos, abrir una retirada o negar
un acceso durante unos segundos.

1. Elegir un centro hasta **8 m**, con línea de visión. MANUAL coloca con el cursor
   y muestra área válida; AUTO usa un rival visible dentro de ese alcance al
   aceptar. Sin centro válido no consume carga. MANUAL permite elegir un área
   vacía para controlar una ruta; fuera de alcance/cobertura se muestra inválida.
2. Consume **100 de súper**, no munición básica. Fija el centro en el mundo y avisa
   **0,60 s** con contorno y cuenta visual. El área no sigue al adversario. Durante
   la preparación camina al 50 % y no acepta otro ataque/activa. Si lo eliminan
   antes de activar, cancela sin devolver carga; pausa congela la preparación.
3. Al activarse, un pulso aplica **900 daño una vez por enemigo**, dentro de radio
   **3 m**, y un impulso radial de **10 m/s** desde el centro. La distancia final
   depende del frenado y las colisiones: no es un teletransporte ni atraviesa muros.
   Si un actor coincide con el centro, usar la dirección fijada al activar como
   salida determinista. Aliados y dueño no reciben daño ni empuje.
4. El campo dura **3 s**: enemigos dentro se mueven un **25 % más lento**; al salir
   desaparece ese modificador. No hace daño continuo ni repite empujes; tampoco
   inmoviliza, desactiva habilidades o impide atacar. El sprint/embestida usa la velocidad ya
   reducida; el impulso físico no se multiplica por la ralentización.

Cobertura corta el pulso, empuje y ralentización: consultar línea del centro de
combate del campo al afectado, además del radio. La protección de aparición/
embestida bloquea el daño/efectos mientras esté activa. No hay efectos a aliados.
La súper no recarga otra súper. Solo un campo activo por emisor; uno nuevo sustituye
al anterior. Un campo ya activado persiste sus 3 s aunque su dueño quede KO; al
terminar partida/revancha se limpia. Pausa congela duración y efectos.

Los campos lentos no suman porcentajes; prevalece el más fuerte entre fuentes
que realmente afecten al actor. Al perder todas las fuentes se restaura su
velocidad base. No se heredan ralentizaciones tras KO/respawn.

Este poder **desplaza adversarios y cambia rutas útiles** mediante una zona de
amenaza; no mueve la geometría de los muros. Barreras móviles, cobertura temporal
y cambios físicos de terreno son opciones de otros kits/hitos, que requerirían
actualizar colliders y navegación. No se añaden todos esos sistemas a este héroe.

## Respuestas y roles

Turbo tiene más velocidad y presión sostenida; puede salir del campo con sprint,
esquivar y presionar cuando termina la mejora de poder. Rey usa cobertura,
protección y embestida para acercarse; si llega a melee, el Príncipe carece de
sprint/escudo para escapar. El aviso permite abandonar la zona antes del pulso.

La precisión aporta daño; el apoyo aporta poder; la súper aporta posicionamiento.
Ninguna parte depende de objetivos deportivos. Todo se prueba en ambos sentidos:
Príncipe humano contra Turbo/Rey y Príncipe bot contra ambos humanos.

## GLB, señales y bot

El futuro `game/data/characters/principe.tres` tendrá `id="principe"`,
`display_name="El Príncipe"`, `number=20`, `role="ESTRATEGA"` y
**`res://assets/models/principe/principe.glb` en `model_scene`**. Mantener collider
base radio 0,42/altura 1,6, y origen de ataque Y=0,85; no los decide el mesh.

Reutilizar `idle`, `run`, `kick`, `hit`, `celebrate`: `kick` representa un ataque,
no un pase. El AnimationPlayer no aplica daño. Básico con estela roja/clara;
mejora con icono y texto «PODER +20 %»; campo con borde, aviso, pulso y marcas de
movimiento lento. Los colores no son la única señal. VFX/UI provisionales,
legibles sin tapar cabezas ni sumar luces por ataque. Claude conserva GLB/fuentes;
coordinar cambios de clips/arte por PR, sin edición simultánea.

Bot: conserva líneas de tiro y rutas válidas, activa poder con munición y blanco
alcanzable, y coloca el campo en una posición visible para separar o controlar.
Debe evaluar tipos de habilidad, no tratar toda activa ranged como un sprint.
Reacciona a zonas anunciadas mediante percepción compartida, sin conocer entradas
futuras del humano ni recibir inmunidad a campos o privilegios de daño.

## Implementación y pruebas, después de revisar la ficha

1. Resources de ataques, mejora de poder y zona; estados modulares con filtros de
   equipo. Separar lógica de daño, VFX y UI; nada de ramas por dorsal/nombre.
2. GLB en selección y selector de rival para probar los tres héroes. Mantener
   el campo de tiro histórico Turbo/Rey y sus reglas como referencia.
3. Verificar básico, munición/cadencia, cancelaciones y origen; mejora sin
   acumulación, daño capturado y expiración; selección de centro por rayo al mundo,
   alcance/cobertura, pulso único por actor, empuje físico y entrada/salida de zona.
   Probar centro exacto, obstáculos, inmunidad, equipos, pausa/KO/respawn/revancha
   y paridad bot/humano. No introducir daño aliado ni movimientos a través de muros.
4. Ejecutar las 192 regresiones actuales, importar/exportar PCK y revisar selección
   y A/B. No declarar 3v3, red, apoyo aliado o Android probado a partir del duelo.
5. Playtest Príncipe↔Turbo/Rey en A/B: marcadores, duración, tiros/impactos, tiempo
   potenciado, colocación/eficacia del campo y oportunidades melee. Ampliar informes
   locales con esos datos; no se presume que ya los registren.

## Seguimiento

- [x] GLB y dorsal #20 disponibles por PR #8.
- [x] Ficha alineada con la aclaración de batallas, apoyo y control del propietario.
- [x] Aprobación del kit y sus valores iniciales (31 octubre 2026).
- [x] Gameplay, bot, VFX, selección y pruebas (`tests/test_principe.gd`, 50 comprobaciones).
- [ ] Playtest del propietario Príncipe↔Turbo/Rey en A/B y ajuste de valores.
- [ ] Pitbull #17 (siguiente PR).

## Implementación (rama `novedad/principe-jugable`)

- `data/characters/principe.tres`, `data/abilities/principe.tres` (`kind = "Power"`)
  y `data/ammo/principe.tres`. Todo editable en el inspector.
- `CharacterDefinition`: `attack_windup` (anticipación) y grupo «Súper» con
  `super_kind = "Field"`, `super_reach`, `field_warning`, `field_duration`,
  `field_slow` y `field_push`; el radio usa `super_radius` y el pulso `super_damage`.
  Turbo y Rey usan los valores por defecto y no cambian.
- `ArenaPlayer`: estados por actor (`power_time`, `slow`, `channel_time`,
  `windup_time`) y dirección y mejora capturadas al aceptar el ataque. Nunca escribe
  en el Resource. Reaparecer limpia todos los estados; la pausa los congela.
- `scripts/combat/zone_field.gd` (`ZoneField`): aviso, pulso único con empuje radial,
  campo lento. La cobertura bloquea los tres efectos, igual que la protección. Un
  campo por emisor; las lentitudes no se suman (prevalece la más fuerte).
- Arena: centro AUTO sobre el rival visible a ≤ 8 m; en MANUAL, el punto del cursor
  si es válido. El pulso de la súper no recarga la súper. Rival del bot elegible en
  el menú (`RIVAL:`); el campo de tiro conserva a Rey como referencia.
- Bot: activa la mejora con munición y blanco visible, coloca el campo sobre el
  rival a su alcance y sale de zonas anunciadas del rival.
- Etiqueta sobre la cabeza: «PODER +20 % · s» y «LENTO −25 %».

Límites: el collider del proyectil sigue en 0,16 m (la ficha proponía 0,12) para no
cambiar el proyectil compartido. La mejora a aliados a 2,5 m no se implementa
porque no hay equipos. En táctil y modo manual sin cursor, la súper usa el rival
visible. Balance sin validar.
