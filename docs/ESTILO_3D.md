# Guía de estilo 3D — dirección artística y estado inicial

## Identidad

Arena de entrenamiento «Prisma»: suelo jade, arquitectura
azul tinta, líneas menta, acentos ámbar y coral. Formas deportivas abstractas,
sin patrocinadores, escudos ni rasgos de personas reales. Las imágenes de
`design/` sirven para estudiar energía, jerarquía y claridad, no para calcar UI.

## Personajes

Meta: caricatura de 3,5–4 cabezas, manos/botas grandes y torso legible desde cámara.
Turbo: silueta estrecha con aletas laterales y líneas de velocidad; azul con
detalles rojos, pelo blanco y tatuajes de diseño propio, dorsal 11. Rey: hombros
anchos, silueta de bloque protector, blanco y negro con oro y violeta (corona y capa),
dorsal 23. Visores abstractos; diseñar rostros originales solo tras exploración de
artista. No copiar rostros, tatuajes, escudos, kits ni poses de futbolistas reales
(decisión de paleta del propietario del 2026-10-30 en `docs/arte/HEROES.md`). El dorsal
es un elemento legible, no un logo.

## Materiales y presupuesto inicial (objetivos)

Albedo plano o atlas pequeño; roughness 0,65–0,9, metallic 0 salvo acentos.
Geometría opaca, normales limpias, bordes suaves, contraste entre piel/traje/fondo.
Meta inicial: <= 8.000 triángulos por héroe y <= 8 materiales; medir antes de
escalar a seis jugadores. Compartir materiales/meshes estáticos e instanciar
repeticiones. Nada de transparencia sobre toda la cancha ni GI dinámica.
Los modelos provisionales deben poder regenerarse sin paquetes comerciales. En la fundación se generan con meshes de Godot, no son GLB entregados por artista.

## Blender → Godot

Unidades métricas, escala aplicada, pies en origen, eje vertical Blender Z.
GLB exporta al sistema Y-up de Godot. Frente del modelo: -Z en Godot.
Pivotes: Body, Head, ArmL/R, LegL/R. En la fundación son pivotes procedurales de Godot,
no un GLB ni rig final; `CharacterVisual` aplica movimiento procedural a esos pivotes.
Futuro: Armature única, clips `idle`, `run`, `kick`, `hit`, `celebrate` y blendspace
mediante AnimationTree, root motion desactivado para física autoritativa.
No exportar cámaras o luces desde modelos. Conservar generador y `.blend` como
fuentes; GLB versionado permite abrir Godot sin Blender instalado.

## Iluminación y cámara

Luz principal cálida desde arriba/izquierda; relleno ambiental frío y sombras
suaves limitadas a una direccional en ALTO. En BAJO: sombras apagadas y escala 3D
reducida. Cámara ortográfica elevada, inclinación aproximada de 50 grados,
sin rotación libre ni seguimiento brusco. Mantener límites y cobertura visibles; adaptar
encuadre al aspecto y reservar zonas seguras para HUD. Selección: cámara de retrato
3D y giro lento; UI original, sin monedas o tienda falsas.

## Animaciones y VFX

Espera: respiración suave; carrera: braceo y paso alternado según velocidad real;
remate: anticipación breve y golpe de pierna; impacto: squash y retroceso visual;
celebración: salto y brazos elevados. No desplazar el collider con el mesh.
Sprint: estelas azul y amarilla con rayo; Embestida: escudo ámbar frontal; Súper Turbo:
proyectil eléctrico grande con anillos y estela; Súper Rey: onda violeta hasta su radio
real con corona dorada. Detalle y presupuesto de cada efecto en `docs/arte/VFX.md`.
Señales por forma y texto además de color. Duración 0,2–0,7 s, objetos liberados,
no tapar proyectiles ni indicadores de vida, ni sumar luces por efecto. Audio queda pendiente.

## Estado y aceptación

Turbo #11 (V1.1) y Rey/King #23 (V0) tienen **muestras provisionales** en Blender/GLB
(rig, cinco clips y métricas en `docs/arte/HEROES.md`), pendientes de revisión del propietario.
Decisión del propietario (2026-10-30): Turbo en azul con detalles rojos, pelo blanco
y tatuajes visibles; Rey en blanco y negro con corona dorada y capa violeta. Los
tatuajes son diseños propios; sigue prohibido copiar tatuajes, rostros, escudos o kits reales.

Geometría procedural, escenario y animaciones del primer hito: **provisionales de mecánicas**.
Ninguna figura de entrenamiento se presenta como resultado artístico final.
Antes de calidad comercial: revisión de silueta por artista, rig y clips finales,
pruebas de legibilidad en pantallas de 6 pulgadas, licencias, capturas de build y
perfilado en tres teléfonos. Meta 60 FPS / 16,7 ms, no garantía medida.


## Actualización de referencia y evolución — 31 octubre 2026 UTC

El propietario eligió las primeras imágenes de caricaturas deportivas y la
composición de la última pantalla adjunta. Ver [guía visual del plantel](plantel/VISUAL.md)
y [referencias conservadas](../design/referencias/propietario_2026-10-31/README.md).
Las exploraciones recientes cambiaron cara/proporción: no son reemplazos aprobados.
Primero fijar Turbo V2 con vistas y expresiones; después refinar Blender/GLB.
Los actuales visores/pesos rígidos y accesorios siguen siendo provisionales.
Conservar etapas, aprobar muestras y comprobarlas en juego antes de llamarlas finales.
