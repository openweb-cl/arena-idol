# Guía de estilo 3D — dirección artística y estado inicial

## Identidad

Estadio de entrenamiento nocturno «Cancha Prisma»: césped jade, arquitectura
azul tinta, líneas menta, acentos ámbar y coral. Formas deportivas abstractas,
sin patrocinadores, escudos ni rasgos de personas reales. Las imágenes de
`design/` sirven para estudiar energía, jerarquía y claridad, no para calcar UI.

## Personajes

Meta: caricatura de 3,5–4 cabezas, manos/botas grandes y torso legible desde cámara.
Turbo: silueta estrecha con aletas laterales y líneas de velocidad; cian/índigo,
dorsal 11. Rey: hombros anchos, silueta de bloque protector, ámbar/violeta, dorsal
23. Cascos y visores abstractos en los placeholders; diseñar rostros originales
solo tras exploración de artista. Evitar peinados, tatuajes, kits o poses
reconocibles de futbolistas. El dorsal es un elemento legible, no un logo.

## Materiales y presupuesto inicial (objetivos)

Albedo plano o atlas pequeño; roughness 0,65–0,9, metallic 0 salvo acentos.
Geometría opaca, normales limpias, bordes suaves, contraste entre piel/traje/fondo.
Meta inicial: <= 8.000 triángulos por héroe y <= 8 materiales; medir antes de
escalar a seis jugadores. Compartir materiales/meshes estáticos e instanciar
repeticiones. Nada de transparencia sobre toda la cancha ni GI dinámica.
Los modelos provisionales deben poder regenerarse sin paquetes comerciales.

## Blender → Godot

Unidades métricas, escala aplicada, pies en origen, eje vertical Blender Z.
GLB exporta al sistema Y-up de Godot. Frente del modelo: -Z en Godot.
Pivotes: Body, Head, ArmL/R, LegL/R. En esta entrega son piezas independientes,
no rig final; `CharacterVisual` aplica movimiento procedural a esos pivotes.
Futuro: Armature única, clips `idle`, `run`, `kick`, `hit`, `celebrate` y blendspace
mediante AnimationTree, root motion desactivado para física autoritativa.
No exportar cámaras o luces desde modelos. Conservar generador y `.blend` como
fuentes; GLB versionado permite abrir Godot sin Blender instalado.

## Iluminación y cámara

Luz principal cálida desde arriba/izquierda; relleno ambiental frío y sombras
suaves limitadas a una direccional en ALTO. En BAJO: sombras apagadas y escala 3D
reducida. Cámara ortográfica elevada, inclinación aproximada de 50 grados,
sin rotación libre ni seguimiento brusco. Mantener ambos arcos visibles; adaptar
encuadre al aspecto y reservar zonas seguras para HUD. Selección: cámara de retrato
3D y giro lento; UI original, sin monedas o tienda falsas.

## Animaciones y VFX

Espera: respiración suave; carrera: braceo y paso alternado según velocidad real;
remate: anticipación breve y golpe de pierna; impacto: squash y retroceso visual;
celebración: salto y brazos elevados. No desplazar el collider con el mesh.
Sprint: estela cian en punta; Embestida: arco ámbar frontal; Súper Turbo: abanico
cian y tiro potente; Súper Rey: anillo violeta expansivo y quite de área.
Señales por forma y texto además de color. Duración 0,2–0,7 s, objetos liberados,
no tapar el balón ni sumar luces por efecto. Audio queda pendiente.

## Estado y aceptación

GLB, escenario y animaciones del primer hito: **provisionales de mecánicas**.
Ninguna figura de entrenamiento se presenta como resultado artístico final.
Antes de calidad comercial: revisión de silueta por artista, rig y clips finales,
pruebas de legibilidad en pantallas de 6 pulgadas, licencias, capturas de build y
perfilado en tres teléfonos. Meta 60 FPS / 16,7 ms, no garantía medida.
