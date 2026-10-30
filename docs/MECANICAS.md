# Mecánicas vigentes — combate arcade 3D

La decisión de combate posterior a v0.4 prevalece. Plano XZ y cámara inclinada.
No posesión, tiros a portería, árbitros o reglas de fútbol en la primera demo.

## Bucle de la demo

Un jugador frente a un bot. Mover/apuntar → atacar → cubrirse/esquivar → cargar
súper → eliminar/reaparecer. Gana quien alcance 5 eliminaciones o tenga mayor
marcador a los 180 segundos. Empate posible; sin prórroga. Respawn 4 s con 1 s de
protección. El futuro modo Batalla de Ídolos será 3v3, no implementado aquí.

## Controles iniciales

WASD/flechas mueven. AUTO selecciona al rival cercano en alcance y sin cobertura;
T cambia a MANUAL. El jugador inicia el disparo, no hay fuego autónomo. Ratón apunta en el plano de combate a la altura del disparo (Y=0,85).
Si atraviesa el cuerpo de un actor, apunta al centro de combate. Clic izquierdo o Espacio
atacan. E o Shift: habilidad. Q o clic derecho: súper con carga completa. Esc:
pausa; pérdida de foco pausa automáticamente. Menú de resultado ofrece revancha.
Si no se ha apuntado con ratón, se usa la última dirección de movimiento.
Comandos independientes permiten añadir táctil posteriormente.

## Personajes

- Turbo #11: velocista, 4000 PV, pelotazo eléctrico de alcance limitado con
  colisión en obstáculos. Turbo Sprint aumenta velocidad brevemente. Remate
  Relámpago dispara un proyectil mayor, más rápido y potente.
- Rey #23: tanque, 6200 PV, golpe frontal de corto alcance. Embestida Real avanza,
  empuja y daña una sola vez por activación; protección breve. Onda Real afecta
  rivales en un radio y empuja; no depende de dirección de disparo.

Valores de prototipo editables en `game/data/characters/*.tres`,
`game/data/abilities/*.tres` y `game/data/match.tres`; no son balance final.
Carga súper solo por impactos válidos, no por apretar botones. Vida nunca negativa;
eliminado no ataca ni colisiona; cooldown impide spam. Sin daño aliado.

## Autoridad y colisiones

Capa 1: obstáculos/paredes. Capa 2: actores. Los proyectiles consultan ambas y
excluyen al emisor. Vida y eliminaciones se resuelven en gameplay, VFX y UI solo
representan resultados. Reglas cierran una única vez; marcador no sigue subiendo
tras resultado. Pausa congela física de combate, respawn y reloj.

## Futuro

Adaptador táctil, equipos de tres, objetivos por modo y red autoritativa después
de validar combate. La física local no se declara determinista entre máquinas.
Pruebas de red, latencia, reconexión y prevención de abuso siguen pendientes.

F2 alterna la guía del ataque básico. Campo de tiro desde el menú: 1/2/3 distancias,
4 cobertura, 5 fuera de alcance; Rey inmóvil sin IA. No modifica balance.
Ver APUNTADO_Y_PROYECTILES para reglas y diagnóstico.

Mantener clic/Espacio repite ataques respetando la cadencia. Soltar, pausa,
eliminación o cambio de modo cancela la repetición. Ver APUNTADO_AUTOMATICO.md
para pruebas de contacto y selección; no se cambió daño/vida ni IA.
