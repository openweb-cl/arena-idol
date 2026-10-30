# Estructura y hitos de la vertical slice 3D

Cambio técnico solicitado: primera entrega 3D real, Android y Godot 4 estable.
El prototipo 2D inicial no será la base del runtime.

1. **Fundación 3D**: arquitectura, guía artística, comandos de entrada, Resources,
   escenas 3D y fuente Blender reproducible.
2. **Duelo local verificable**: selección Turbo #11 / Rey #23, cancha con obstáculos,
   cámara inclinada, movimiento acelerado, conducción, tiro/pase, rebotes, daño,
   respawn, dos habilidades y dos súpers, bot, goles, resultado y revancha.
3. **Validación y entrega**: pruebas headless de lógica e integración, inspección de
   capturas renderizadas cuando el entorno lo permita, instrucciones Windows/PC,
   perfiles gráficos y receta Android, commits y PR sin fusionar.

## Alcance de arte

Los GLB de entrenamiento son modelos provisionales creados en Blender mediante
un generador propio. Tienen siluetas distintas, visor abstracto, dorsal y pivotes
animables; no son arte final. Animaciones procedurales de espera, carrera, golpe,
impacto y celebración; pendiente rig esquelético, skinning, animaciones de artista,
VFX y audio final. No se deduce aprobación de nombres o licencias comerciales.

## Criterios comprobables

- Proyecto abre y ejecuta menú, selección, arena y resultado en Godot 4.
- Cada héroe cambia modelo/dorsal y atributos; las otras 14 plazas no son jugables.
- Colisiones, posesión exclusiva, pase/tiro, rebote, goles en ambos arcos y reinicio.
- Bot busca balón, disputa y remata. Cooldowns y súper no se saltan con spam.
- Pausa detiene partido; revancha limpia marcador, reloj y estado de actores.
- Controles de teclado primero; comandos preparados para táctil, sin declarar
  validación móvil hasta exportar y probar Android.

## Fuera del hito

3v3, matchmaking, backend, tienda, ranking persistente, 16 héroes completos,
calidad comercial, 60 FPS Android certificados y pruebas con 20 jugadores.
