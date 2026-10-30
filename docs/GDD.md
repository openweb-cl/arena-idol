# GDD vigente — Arena de Ídolos / combate 3D

## Visión y prioridad

Juego de combate arcade 3D estilizado con personajes ficticios inspirados
conceptualmente en el universo del fútbol chileno. Encuentros rápidos, apuntado
claro, poderes expresivos y cooperación. No es fútbol tradicional ni simulación.
La corrección de combate en `DECISIONES_Y_ALCANCE.md` prevalece sobre v0.4.

## Pilares

- Respuesta: aceleración/frenado ágiles y apuntado independiente de movimiento.
- Combate legible: vida, cobertura, pelotazos como proyectiles, impactos no
  violentos, telegraph de habilidades, siluetas y efectos distinguibles.
- Decisiones: atacar, esquivar, buscar cobertura, gestionar cooldown y súper.
- Roles de combate: daño, tanque, apoyo y control; todos tienen básicos ofensivos.
  Los especiales pueden mejorar daño/poder, proteger aliados, desplazar adversarios
  o controlar/modificar zonas de la arena. El apoyo sigue atacando.
- Identidad original: héroes ficticios, estética intensa, arenas diseñadas para
  combatir; sin goles, porterías, posesión ni pases. El balón puede ser la forma
  visual de un proyectil de daño, no un objetivo deportivo.
- Android primero, PC de desarrollo; objetivo 60 FPS sujeto a perfilado real.

## Modos

Batalla de Ídolos (prioridad): equipos 3v3 por eliminaciones. Rey de la Arena:
control territorial. Último Ídolo: supervivencia individual. Duelo de Leyendas:
combate 1v1. Balón de Gloria queda como antecedente pendiente de redefinición de
combate; su antigua descripción deportiva no es una tarea vigente.

## Primera demo / gate de fundación

Batalla de entrenamiento local: **un jugador contra bot**, selección Turbo #11 o
Rey #23, arena 3D con cobertura, ataques, vida/daño, eliminación temporal y
reaparición, habilidad y súper. 180 segundos o 5 eliminaciones; empate al agotar
reloj con mismo marcador. Resultado y revancha. Sin balón ni goles. No confundir
este duelo técnico con implementación completa del modo 3v3 o del multijugador.

Turbo: pelotazos eléctricos a distancia, Turbo Sprint, Remate Relámpago.
Rey: golpe frontal de corto alcance, Embestida Real, Onda Real radial.
Mismos comandos para humano y bot. Bot persigue, ataca y evade proyectiles.

## Arte y validación

Modelos originales provisionales de entrenamiento, cámara inclinada y luz simple.
Vista 3D de selección; animaciones de espera, carrera, ataque, impacto y victoria.
Las referencias de `design/` fijan ambición, no acreditan assets terminados.
Se exige revisión visual de builds y medición en hardware antes de calidad
comercial. `ESTILO_3D.md` y `CONTRATO_ARTE_3D.md` guían el relevo artístico.

Playtest posterior con adultos: entender controles, tiempo hasta primer impacto,
uso de cobertura, deseo de repetir y bloqueos. No afirmar diversión, balance o
retención a partir de pruebas automatizadas. Objetivos anteriores de 20 usuarios
siguen pendientes. Clasificación, progresión y cosméticos se posponen a gameplay
validado; sin ventajas de pago ni datos de personas reales en el cliente.
