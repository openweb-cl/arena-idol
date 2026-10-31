# Guía visual — evolución controlada de los héroes

## Decisión más reciente del propietario

**Futbolistas caricaturescos de arena:** conservar la personalidad, silueta,
energía y expresividad de las primeras tres [referencias aportadas](../../design/referencias/propietario_2026-10-31/README.md).
Usar la composición de la última para las pantallas, con personajes más
caricaturescos. El propietario señaló que las exploraciones nuevas volvieron a
cambiar los personajes: **no son reemplazos aprobados**. La continuidad de cara,
peinado, proporciones y ropa entre láminas es un requisito del siguiente hito.

No se promete una cantidad fija de intentos hasta lograr el final. Se proponen
cinco estados de producción; dentro de cada estado puede haber varias revisiones.
Cada versión se compara con la anterior y con la referencia elegida.

## Etapas y puertas de revisión

| Estado | Qué existe / entregar | Condición para avanzar |
|---|---|---|
| V0 — prueba técnica | Turbo/Rey geométricos, evidencia histórica | Movimiento y combate verificables; no arte |
| V1 — modelo provisional | Turbo, Rey, Príncipe y Pitbull en GLB | Pipeline y clips importan; no define el aspecto final |
| V2 — diseño definido | Frente, perfil, espalda, rostro, expresiones, paleta, pose de combate | Propietario aprueba una lámina coherente; primero Turbo |
| V3 — modelo refinado | Blender, GLB, rig/pesos, cinco clips, retrato, materiales | Misma identidad que V2; revisión en selección y cámara de arena |
| Candidato final | Pulido de transiciones, iluminación, VFX, lectura y optimización | Pruebas reales, correcciones y aprobación explícita |

No todos parten con V0/V1: doce solo tienen referencia. No fabricar un historial
para llenar etapas. Las versiones internas existentes (Turbo V1.1, Rey V0) se
conservan en el historial; esta tabla agrupa estados, no renombra sus archivos.

## Próximo hito concreto: llevar Turbo V2 a Blender

Ya existe una [primera propuesta de lámina V2](../../design/personajes/turbo/bocetos/turbo-v2-propuesta-01.png),
**aceptada por el propietario**: «Ese turbo esta muy bueno». Es la referencia
para modelado: conservar cara, pelo, proporciones y equipación. Reconciliar
tatuajes/costuras entre vistas sin rediseñar su identidad. No es todavía un GLB
refinado ni arte final aprobado en juego.

1. Poner lado a lado la tarjeta original, el modelo actual y la propuesta V2.
2. Conservar azul/rojo, pelo blanco, dorsal 11 y tatuajes geométricos propios,
   decisiones posteriores que prevalecen sobre el pelo azul/dorsal de la referencia.
3. Definir cara humana expresiva propia, botas, manos y volumen de pelo. Una
   cabeza frontal aprobada debe repetirse en perfil, espalda y poses; no volver
   a inventarla al pedir la pantalla de selección.
4. La proporción dibujada en la lámina aceptada es la guía para Blender;
   medirla antes de modelar. La estimación anterior de 4–4,5 cabezas no obliga
   a alterar el dibujo. Comprobar tamaño real en arena sin añadir microdetalle.
5. Marcar qué se conserva/cambia y anotar la decisión antes del nuevo Blender.
6. Con Turbo aprobado, adaptar Rey y luego Príncipe/Pitbull; conservar variedad
   de ancho, postura, edad ficticia y expresión. No producir 16 caras idénticas.

Las dos [láminas deportivas exploratorias](../../design/plantel/bocetos_deportivos_v1/README.md)
no son turnarounds ni V2 aprobado. Las cuatro propuestas de fantasía anteriores
están [rechazadas](../../design/plantel/rechazado_fantasia_2026-10-30/README.md).

## Forma, materiales y cámara

Base de ropa deportiva: camiseta, short, medias y botines. Siluetas por cuerpo,
postura y peinado; accesorios temáticos pequeños y propios, por revisar. Evitar
que una armadura o un disfraz medieval reemplace al futbolista caricaturesco.
Pitbull sigue humano; la metáfora animal de Zorro/León no aprueba mascotas nuevas.
Rostros originales con ojos/cejas/boca expresivos, sin buscar un retrato real.

Materiales estilizados con masas limpias y rugosidad amplia. Opaque primero;
separar camiseta/piel/pelo/tinta, evitar poros/fototexturas y microdetalle que no
se ve en arena. Luces sencillas con principal cálida, relleno frío y sombra
escalable; comprobar Mobile y Compatibility. No depender de un shader caro para
entender la silueta. Presupuestos del [contrato 3D](../CONTRATO_ARTE_3D.md) vigentes.

La cámara de combate sigue superior inclinada con encuadre controlado. El modelado
se revisa desde esa cámara y a escala real; una ilustración cercana no certifica
legibilidad. Collider/origen de ataque no cambian para acomodar una pose.
Selección usa encuadre destacado que no corta cabeza/botas ni cubre rostro con UI.

## Animación y efectos

Refinar idle, run, kick (ataque), hit y celebrate; carrera con aceleración, frenado
y giro, impactos cortos y celebración expresiva. Pesos suaves donde haga falta,
sin root motion. Las poses amplias deben conservar lectura sin alterar colisiones.

Básico = efecto breve; habilidad = gesto y señal propios; súper = anticipación,
acción y remate identificables. Separar intensidad de selección de intensidad en
arena. Con seis actores el efecto no puede tapar al rival, cobertura o avisos.
Color más forma: rayo para Turbo, arco de embestida y anillo para Rey; apoyos con
señales de mejora/protección, no pases. VFX escucha eventos, nunca decide daño.

## Pantallas

[Composición de referencia](../../design/referencias/propietario_2026-10-31/05-composicion-seleccion.jpg):
retratos laterales, escenario con héroe destacado, nombre/rol, tres acciones
(básico/habilidad/súper), modo y botón amarillo JUGAR abajo a la derecha. El
segundo héroe solo aparece como rival cuando la selección lo explica, no como
multijugador inexistente. Sin monedas/gemas, tienda o progreso inventados.

16 plazas; dos jugables. Pendientes con estado explícito. Barras de perfil son
orientativas y deben derivarse de datos, no prometer balance; mostrar PV/cargas
reales al revisar cifras. En 1280×720 permitir scroll en el catálogo antes que
hacer 16 retratos ilegibles. Escalar paneles y texto sin pegarlos a los bordes.
En arena priorizar PV, cargas, cooldown, súper, eliminaciones y tiempo.

[Propuesta nueva de selección](../../design/ui/seleccion_evolucion/README.md):
**exploración pendiente**, no captura Godot, no UI implementada. El propietario
señaló cambios de cara/proporción; no modelar desde ella sin su revisión.

## Qué se guarda y dónde

Aquí pueden prepararse láminas y especificaciones; Claude puede convertir la
versión aprobada a Blender/GLB e integrarla localmente. La imagen guía no genera
por sí sola un modelo, rig o animación. Conservar referencias intactas, fuentes,
exports, capturas reales y decisiones en las carpetas de cada personaje. No
sobrescribir el único original ni depender del contexto de un chat.
