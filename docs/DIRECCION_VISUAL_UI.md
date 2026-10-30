# Dirección visual y pantallas — guía para implementar

## Estilo visual
Hero-brawler futbolero original con perspectiva cenital/3-4 y estética 2.5D legible en Android. Contornos y siluetas fuertes, colores saturados, efectos impactantes, jerarquía clara, UI en español primero. Referencias visuales en `design/referencias/` son **conceptuales, no capturas ni assets definitivos**; texto y nombres de esas ilustraciones pueden tener errores generativos y no deben copiarse como interfaz definitiva.

## Pantallas (orden propuesto)
1. Splash y advertencia de conexión/privacidad.
2. Inicio: personaje 3D/2.5D grande al centro, arriba moneda cosmética y perfil, abajo modo elegido y botón JUGAR.
3. Selección de ídolos: cuadrícula de 16 avatares (concepto), clases y disponibilidad; ficha con ataque/activa/súper/debilidad; los de prototipo están desbloqueados.
4. Modos: Balón de Gloria 3v3 prioritario, luego Duelo Total individual, Rey de la Cancha y Copa Relámpago.
5. Emparejamiento: cola, latencia, región, cancelar.
6. Pantalla de juego apaisada: joystick izq., botones contextuales de ataque/pase/tiro, habilidad y súper derecha; HUD marcador 0-0, cronómetro 3:00, indicador posesión, vida y carga súper.
7. Resultado: goles, asistencias, jugadas, puntuación personal; rematch.
8. Perfil/ranking: progreso individual, historial y personajes favoritos; club es identidad optativa, NO requisito para equipos 3v3.
9. Torneos/creadores: invitaciones, sala privada, calendario y reglas; futuro.
10. Ajustes: audio, sensibilidad, gráficos bajos/altos, accesibilidad, privacidad, reportes.

## Design tokens provisionales (ajustables)
Fondo #101A33; panel #202D4F; amarillo acción #F5C542; azul aliado #2F83F7; coral enemigo #FF6464; verde éxito #35C78A; texto #F8FAFF. Botones táctiles grandes y contrastados. Interfaz en español prioritario, localización inglés a futuro.

## Entregables de arte
Por personaje: concepto frontal/lateral/espalda, silueta, paleta, 8 direcciones 2D si se usa animación orientada, idle, correr, atacar, habilidad, súper, recibir golpe, KO, pose de selección. Arte conceptual no implica derechos para usar escudos y rostros.

## Calidad
HUD legible en móvil económico; señales visuales de ataque antes del golpe; no efectos que tapen balón o arcos. Considerar controles, vibración y tamaño seguro en distintos Android.
