# Reglas compartidas para las fichas propuestas

Batalla arcade 3D: todos, incluidos apoyos, tienen básico con daño. No hay goles,
posesión, pases ni balón obligatorio. Un pelotazo es proyectil ofensivo. Dos héroes
jugables hoy; 3v3 es objetivo futuro, no implementación de este paquete.

- AUTO apunta a blanco válido; el jugador inicia el disparo. Mantener respeta
  cargas/cadencia. Manual permite anticipar. No fuego autónomo por defecto.
- Humano y bot comparten ataques, recursos, cooldown, cobertura, protección y
  alcance. El bot no ve posiciones ocultas ni inventa proyectiles.
- Daño, colisiones y estados viven en gameplay; animación/VFX solo representan
  eventos. Origen/plano de combate fijo; los saltos visuales no esquivan por altura.
- Cada ataque aceptado tiene emisor, equipo, ID, tick/dirección y parámetros
  capturados. Evitar doble daño por frame/hitbox. En ráfagas, un máximo de 25 de
  súper por ataque básico con daño válido es propuesta, no 25 por subproyectil.
- Una súper no genera otra súper. No sumar multiplicadores indiscriminadamente;
  fijar prioridad, duración, limpieza en KO/respawn, pausa y fin de partida.
- Empujes, arrastres y dashes consultan colisiones; nunca atraviesan paredes. Los
  avisos permiten esquivar y la cobertura bloquea lo indicado en cada ficha.
- Sin invulnerabilidad, aturdimientos encadenados o inversión de controles nuevos
  por accidente. Conservar la protección vigente del Rey y aparición.
- Apoyos tienen valor individual y extensión futura a aliados explícita. Escudos
  temporales no cambian la vida máxima ni se acumulan sin límite.
- Cobertura dinámica requiere reconciliar geometría, navegación y aparición antes
  de habilitarse. Un muro no puede atrapar actores o cerrar todas las rutas.
- Ilusiones, reflectores y curvas requieren pruebas propias: rango recorrido,
  crédito de daño, AUTO, bloqueo, caducidad y limpieza. No basta recolorear básicos.

Los números de 14 fichas son hipótesis de ensayo. Aprobar kit, implementar uno,
probarlo y registrar partidas antes del siguiente. No cambiar Turbo/Rey para
hacer que una propuesta parezca equilibrada ni tratar DPS como tasa de victoria.
