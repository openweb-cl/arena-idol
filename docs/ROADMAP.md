# Hoja de ruta — comenzar 30-oct-2026
**Horizontes tentativos y condicionados a dedicación del equipo; no son compromisos de entrega.**

## M0 · Semana 1 — Fundación
- [ ] Crear repo privado `arena-de-idolos` e importar ZIP
- [ ] Definir 1 responsable de diseño, 1 de código y 1 de arte (pueden coincidir)
- [ ] Acordar que los futbolistas reales son referencias internas, no assets publicables
- [ ] Abrir proyecto en GitHub: Backlog / En curso / QA / Hecho
- [ ] 10 entrevistas a jugadores potenciales; ver si prefieren 3v3 con balón o 1v1
- [ ] Instalar Godot 4.7.2 y crear proyecto 2D vacío

## M1 · Semanas 2-3 — Graybox jugable
- [ ] Mapa simple simétrico con obstáculos
- [ ] Movimiento teclado y stick virtual
- [ ] Balón, posesión, pase/tiro, porterías y marcador
- [ ] Un héroe con daño, vida, respawn y súper
- [ ] Bot básico que busca balón y remata
**Exit gate:** una partida completa local sin errores bloqueantes.

## M2 · Semanas 4-5 — Sensación y móvil
- [ ] Arte temporal coherente, cámara, sacudida leve, audio de impactos
- [ ] Tres héroes distintos, equilibrio provisional
- [ ] Export Android con controles táctiles
- [ ] Pruebas en 3 teléfonos de distinta potencia
**Exit gate:** 20 pruebas de usuarios y ≥60% desea repetir.

## M3 · Semanas 6-9 — Primera red
- [ ] Prototipo online 1v1 con servidor autoritativo
- [ ] Sincronización de pelota, daño, goles, reloj y resultados
- [ ] Telemetría mínima, reconexión y manejo de latencia
- [ ] Pruebas con pérdida de paquetes y abuso básico
**Exit gate:** 1v1 estable en conexiones reales; decidir costo hosting.

## M4 · Semanas 10-14 — 3v3 y comunidad cerrada
- [ ] 3v3 con lobby, invitación, asignación de equipos y bots de reemplazo
- [ ] Perfil, avatar, ranking personal (solo resultados verificados)
- [ ] 6 héroes y 2 arenas; roster total previsto 16
- [ ] Moderación básica sin chat libre
**Exit gate:** 50-100 jugadores invitados, métricas de partidas terminadas y regreso.

## M5 · Después — Beta pública
- [ ] 16 héroes progresivamente, temporadas, más modos
- [ ] Revisar licencias oficiales, marcas, audio, legal y tienda
- [ ] Antitrampas, protección de menores, hosting escalable, soporte
- [ ] Monetización cosmética tras medir retención real

## Los primeros 12 issues para GitHub
1. Inicializar Godot y control de versiones
2. Escena de arena graybox
3. Control CharacterBody2D
4. Cámara y límites
5. Balón y colisiones
6. Pase/remate y posesión
7. Portería y detector de gol
8. Temporizador, marcador y fin de ronda
9. Bot perseguir balón y atacar
10. Vida/daño/respawn
11. Habilidad especial prototipo
12. Export y test Android

**No intentar simultáneamente** 12 personajes, 3v3 online, clasificación y tienda antes de validar la diversión local.
