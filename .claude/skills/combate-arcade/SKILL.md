---
name: combate-arcade
description: Dirección de juego de Arena de Ídolos (combate arcade 3D, no fútbol). Usar al diseñar o implementar héroes, habilidades, modos, VFX o textos de juego.
---

# Combate arcade 3D, no simulador de fútbol

Fuentes: `docs/DECISIONES_Y_ALCANCE.md`, `docs/GDD.md`, `docs/MECANICAS.md`,
`docs/plantel/REGLAS_COMBATE.md`.

- Batalla de Ídolos es la prioridad. **Sin goles, porterías, posesión ni pases.**
- Los proyectiles pueden tener forma de balón, pero causan daño de combate.
- **Todos los héroes atacan con un básico ofensivo**, incluidos apoyos y asistentes.
- Diferenciar por daño, resistencia, movilidad, mejoras de poder, protección y
  control de zonas o desplazamientos. Los especiales pueden ayudar a aliados o
  alterar la arena.
- El clip `kick` es una animación de ataque, nunca una mecánica de pase.
- AUTO apunta; el jugador dispara.
- No cambiar recarga, daño ni vida por motivos de arte. Los parámetros viven en
  Resources (`game/data/`), no en el arte ni en los VFX.
- Plantel canónico v0.4: 16 héroes, sin reemplazos. Turbo #11 y Rey #23 son los
  iniciales. Dorsales decididos: 11, 23, 20 (Príncipe), 17 (Pitbull); el resto
  está pendiente.
- Las fichas de los 14 pendientes son propuestas, no permiso para programarlas ni
  balance validado. El Príncipe necesita aprobar `docs/PRINCIPE_KIT.md`; el Pitbull
  va después de probar al Príncipe.
- Los nombres deportivos del roster histórico no fijan kits.
