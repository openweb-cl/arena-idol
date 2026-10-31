# Producción por hitos verificables

## Prioridad actual

Mejorar visualmente el juego en PC. Pruebas en teléfono aplazadas por el
propietario; conservar Android/Mobile y Compatibility sin dedicar este hito a APK.
No contratar servicios. No incorporar nuevas dependencias de pago.

| Hito | Entrega | Estado / siguiente puerta |
|---|---|---|
| Biblioteca | 16 referencias individuales, carpetas, evolución y fichas | Preparada en este PR; propuestas por revisar |
| Turbo V2 | Una lámina consistente con vistas y expresiones | Propuesta 01 aceptada como referencia visual; no sustituir por el mockup UI |
| Turbo V3 | Modelo refinado y cinco clips en selección/arena | Siguiente: conservar V2 aceptada; medir y comparar |
| Rey V2/V3 | Adaptación al mismo lenguaje, silueta ancha propia | Tras patrón Turbo; revisión propia |
| Príncipe/Pitbull visual | Refinar los GLB existentes usando patrón aprobado | No implica activar gameplay |
| Refresh UI | Composición de la última referencia con personajes aprobados | Hito aparte; acordar handoff con rama UI existente |
| Príncipe jugable | Kit, Resource, estados y VFX | Solo tras aprobación de PRINCIPE_KIT.md |
| Pitbull jugable | Escudo/ataque y pruebas | Después de probar al Príncipe |
| Resto | Diseños/modelos/combate por tandas | Cada entrega con revisión, no los 16 modelos a la vez |

## Tandas de combate propuestas, no autorizaciones de código

0. Conservar Turbo/Rey, recarga y mapas A/B como referencia.
1. Príncipe y luego Pitbull, con sus puertas de aprobación/playtest.
2. Cruzado y Artillero: precisión/anticipación, ataques básicos y área anunciada.
3. Porteño, Guardián, Elegante, Bati: fuerza direccional, escudos/parry, golpe preparado.
4. Cacique, Zorro, Pirata, Ilusionista, Tricolor, León: cobertura dinámica,
   señuelos, proyectiles curvos, reflectores y modificadores; mayor coste técnico.

El orden no altera el plantel canónico. Las fichas no se importan al motor. Varias
necesitan resolver contratos comunes antes de implementar; el CharacterDefinition
actual no representa automáticamente todos estos sistemas.

## Sistemas que desarrollar cuando corresponda

- Ataques: comando/ID, emisor/equipo, eventos de lanzamiento/impacto, proyectiles
  rectos/curvos/ráfaga y área; datos editables en Resources, estado por actor.
- Modificadores: daño, movimiento, escudo, prioridad y caducidad; limpieza en
  respawn/pausa/revancha, sin escribir estados temporales al Resource compartido.
- Zonas: aviso previo, validación de posición/cobertura, vida útil, pertenencia y
  efectos una vez o continuos según ficha, con salida/restauración determinista.
- Movimiento forzado: desplazamiento con colisiones, sin teletransporte a través
  de obstáculos ni superioridad de la IA. Geometría única para dibujo y navegación.
- Futuros equipos: filtrado aliado/rival, daño amistoso explícito, seis actores y
  pruebas locales antes de red autoritativa. No desarrollar servidores ahora.
- Arte: clips/sockets del contrato y adaptador; eventos con identidad del héroe.
  Príncipe usa `principe_shot`, `principe_buff`, `principe_field_warning`, `principe_field`.

## Reparto y verificación

Codex mantiene reglas y contratos técnicos; Claude arte, Blender, animaciones,
materiales, VFX e interfaces. No editar a la vez los mismos archivos. Este paquete
no toma archivos de `game/`, `art/` ni los reservados por el refresh visual.

Por modelo: contrato de arte, importación, render/capturas reales en selección y
arena, revisión de clips. Por gameplay: pruebas de colisiones/estados y paridad,
verify.py y partidas humanas. Por rendimiento: métricas de hardware objetivo,
no un render de Blender o ejecución headless. Por documentación: verificador del
catálogo, enlaces, hashes, dorsales y estados. Ramas independientes, PR a main,
commits pequeños y ninguna fusión automática.
