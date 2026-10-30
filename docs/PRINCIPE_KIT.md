# El Príncipe #20 — ficha C1 para revisión

**Estado: PROPUESTA, pendiente de aprobación del propietario. No implementada.**
Rama `codex/principe-kit`, solo documentación. `codex/principe-gameplay` comienza
después de revisar esta ficha. Pitbull #17 queda después de probar al Príncipe.

## Identidad y decisión que ofrece

Estratega de precisión: busca un pasillo, acierta un tiro preparado para frenar
brevemente al rival y aprovecha ese segundo para cambiar de posición o rematar.
Menor potencia sostenida que Turbo y sin su sprint; vulnerable si Rey llega al
cuerpo a cuerpo. El control exige impactos: fallar consume recursos sin ventaja.

Se conserva el concepto canónico de pase preciso, Visión de Juego y Pase Maestro,
adaptado a combate, sin balón obligatorio, pases aliados ni objetivos deportivos.
«Visión» nombra la preparación táctica: no revela rivales tras muros ni añade un
sistema de visión. Sin curación, trampas, invisibilidad, críticos o daño aleatorio.

## Valores iniciales propuestos

Son hipótesis editables desde Resources, no balance aprobado. No cambian las
estadísticas actuales de Turbo ni Rey.

| Parámetro | Príncipe | Propósito |
|---|---|---|
| Vida | 4400 PV | Algo más de margen que Turbo, lejos de la resistencia de Rey |
| Velocidad | 6,6 m/s | Reposiciona caminando, sin escape acelerado |
| Aceleración / frenado / giro | 38 / 48 / 14 | Reutiliza la respuesta base |
| Cargas básicas | 3 | Misma lectura de munición que Turbo |
| Recuperación | Una cada 1,6 s, secuencial | Disparar no reinicia el ciclo |
| Cadencia mínima | 0,60 s desde aceptar el ataque | Menos presión continua que Turbo |
| Empuje básico / súper | 1 / 2 m/s | El control viene de ralentizar, no de alejar al melee a golpes |
| Carga de súper | 25 por básico con daño válido | Cuatro impactos; fallos/protección no cargan |

## Básico — Pase de Precisión

- Pelotazo recto, sin homing, rebotes ni penetración. Radio **0,12 m**, velocidad
  **22 m/s**, alcance **12 m**, daño **750**. Impacta al primer rival o cobertura.
- Anticipación **0,12 s**, alineada con el pase de interior del clip `kick`.
  Puede moverse normalmente durante ella. Dirección capturada al aceptar el tiro;
  el proyectil sale del origen de combate actualizado al terminar la anticipación.
- Consume una carga al aceptar, no otra al aparecer el proyectil. Si queda
  eliminado antes de soltarlo, se cancela; no hay devolución de carga. Pausa congela
  la anticipación. No encola varios ataques durante ella.
- AUTO conserva rival cercano visible y apuntado al centro; no predice ni asegura
  impactos. MANUAL permite anticipar el movimiento. El propietario inicia el
  ataque; mantener pulsado respeta cargas, anticipación y cadencia.
- Comparación orientativa sin habilidades: 750/1,6 ≈ **469 daño/s** sostenido a
  largo plazo, frente a 850/1,5 ≈ **567** de Turbo si todos los tiros impactan.
  No son DPS medidos en partida ni incluyen la ráfaga inicial o la cobertura.

## Activa — Visión de Juego

Preparar **un siguiente básico** durante hasta **3 s**; cooldown **7 s**, desde
activar E/Shift. No es un ataque automático ni consume munición al activarse.

- Ese básico conserva daño, radio, alcance y anticipación, viaja a **27,5 m/s** y,
  si causa daño válido, ralentiza **25 % durante 1 s** al adversario.
- El preparado se consume al aceptar ese básico, incluso si luego falla, encuentra
  un muro o un rival protegido. El efecto queda en el proyectil hasta resolverse,
  aunque termine la ventana de 3 s mientras vuela.
- Sin cargas puede activarse, pero debe recuperar y disparar antes de que expire.
  La súper no consume ni recibe el preparado. No acumula dos preparados.
- Sin escudo, inmunidad, sprint o daño extra. Dejar pasar la ventana pierde el
  efecto; el cooldown continúa. Pausa congela ventana y cooldown.

## Súper — Pase Maestro

Pelotazo de control de pasillo, recto y anunciado: **1600 de daño**, radio **0,20 m**,
velocidad **26 m/s**, alcance **12 m**. Un impacto válido ralentiza **35 % durante
1,5 s**. No atraviesa obstáculos, aliados ni el primer adversario.

- Requiere y consume **100 de carga**, sin gastar munición básica. La súper no
  carga otra súper. No incorpora el preparado de Visión de Juego.
- Anticipación **0,35 s** con corredor visible para ambos bandos. Dirección fija al
  aceptar la acción; el origen de la guía sigue al emisor durante la preparación.
  El disparo sale de ese origen al completarse. Sin giro automático posterior.
- Durante la anticipación camina al **50 %** de su velocidad efectiva. No puede
  aceptar otro ataque o activar la activa. Eliminarlo cancela el disparo; pausa
  congela la preparación. No devuelve la carga consumida.
- La cobertura puede cortar el corredor: la guía muestra el primer bloqueo real,
  no promete atravesarlo. Los rivales pueden salir lateralmente o cubrirse.

## Reglas compartidas del control

Único estado nuevo: ralentización temporal modular, independiente de arte y UI.
Se aplica solo si `take_damage` acepta el impacto; no afecta aliados, KO ni rivales
invulnerables. No impide apuntar, atacar, usar habilidades o cambiar de dirección.

No se suman porcentajes: prevalece el más fuerte. Un efecto igual refresca su
duración; uno más débil no rebaja ni prolonga el fuerte. Al expirar se recupera
la velocidad base, sin modificar el Resource. El sprint/embestida multiplica la
velocidad ya reducida; el empuje recibido se mantiene independiente.

Cooldowns, recarga, carga de súper y animaciones no se ralentizan. Pausa congela
el temporizador; KO, respawn y revancha limpian estados y anticipaciones pendientes.
La aparición conserva los actuales 4 s de espera y 1 s de protección. Bot y humano
usan exactamente la misma autoridad, velocidades de proyectil y tiempos.

## Lectura visual y modelo existente

El futuro `game/data/characters/principe.tres` deberá tener `id="principe"`,
`display_name="El Príncipe"`, `number=20`, `role="ESTRATEGA"` y asignar
**`res://assets/models/principe/principe.glb` a `model_scene`**. No duplicar el
modelo ni reemplazarlo por geometría. Mantener collider base radio 0,42/altura 1,6;
el modelo no determina el origen, el alcance o el daño del ataque.

Usar los cinco clips existentes: `idle`, `run`, `kick`, `hit`, `celebrate`. La
anticipación de la súper puede sostener visualmente la preparación de `kick`
desde el adaptador; el AnimationPlayer no decide cuándo se aplica daño.

- Básico: pelota clara con estela roja fina, distinguible de la eléctrica de Turbo.
- Preparado: retícula doble y texto/contador «VISIÓN LISTA», visible para el
  propietario; destello breve sobre el modelo como aviso al rival.
- Súper: corredor discontinuo con puntas y anticipación, proyectil con doble
  estela. El corredor avisa, no hace daño por sí mismo.
- Ralentización: marcas bajo los pies y texto «LENTO» con duración. Nada de elevar
  una etiqueta sobre la cara, ocultar siluetas o añadir luces por proyectil.

VFX/UI de esta primera integración serán provisionales e identificados. Claude
conserva modelos, fuentes Blender y materiales; cualquier ajuste de clips o nuevo
recurso artístico se coordina por PR, sin edición simultánea.

## Respuestas de los rivales y uso del bot

Turbo puede esquivar lateralmente, usar el sprint para salir del corredor y
presionar mientras el Príncipe recarga. Rey puede avanzar entre coberturas,
reservar su protección para el tiro preparado y castigar la falta de escape al
alcanzar melee. El Príncipe debe controlar distancia y acertar, no encadenar una
inmovilización permanente.

El bot busca línea libre entre 6 y 9 m, prepara Visión con munición y línea de
tiro; usa la súper con blanco visible, sin conocer entradas futuras del humano.
No hereda «activa de ranged = esquiva con sprint»: debe evaluar el tipo de habilidad
por configuración. Puede reaccionar al corredor visible y a proyectiles mediante
reglas compartidas, sin privilegios de alcance, cargas o impactos garantizados.

## Plan de implementación y aceptación, después de aprobar

1. Recursos para héroe/munición/activa y perfiles de ataque; anticipación,
   preparación y ralentización como estados genéricos, sin ramas por dorsal/nombre.
2. Enlazar GLB, anticipación/VFX/HUD y estado de preparado. Mantener autoridad de
   daño separada. Selector de rival para poder probar los tres enfrentamientos
   sin introducir red ni cambiar el campo de tiro histórico Turbo/Rey.
3. Pruebas de consumo/cadencia, cancelación de anticipaciones, origen Y=0,85,
   trayectorias estrechas, cobertura, protección, cargas de súper y efectos no
   acumulativos. Pausa/KO/respawn/revancha, AUTO/MANUAL, bot/humano y GLB/clips.
4. Ejecutar las 192 regresiones actuales, importar/exportar PCK y revisar render
   con los tres héroes en selección y arenas A/B. Android y seis actores aún
   requieren un hito propio; este duelo no acredita 3v3 o red.
5. Playtest Príncipe↔Turbo y Príncipe↔Rey en A/B, intercambiando héroe del humano.
   Registrar marcadores, duración, impactos/intentos, uso de preparados/súper,
   tiempo lento y oportunidades de llegar a melee. Los informes actuales deben
   ampliarse con esos datos; no se presume que ya existan.

Salida: el propietario entiende preparación/control, percibe respuesta ante la
súper y puede ganar o perder por decisiones; revisar cifras de una en una si las
partidas muestran problemas. Las simulaciones no aprueban diversión o equilibrio.

## Gate actual

- [x] GLB y dorsal #20 disponibles en main por PR #8.
- [x] Ficha de combate redactada para mostrar al propietario.
- [ ] Propietario revisa/aprueba ficha y valores iniciales.
- [ ] Rama/implementación `codex/principe-gameplay` y pruebas.
- [ ] Playtest del Príncipe; decidir cambios antes del Pitbull #17.
