# Vertical slice vigente — Batalla de Ídolos

La corrección más reciente elimina balón y porterías de la primera demo. Combate
arcade 3D, no simulador. Objetivo posterior 3v3; entrenamiento técnico inicial
1 humano contra bot con Turbo #11 y Rey #23.

1. Fundación: arquitectura 3D, instrucciones de ambos agentes, Resources editables,
   contrato GLB, menú/selección con vista 3D, cámara inclinada y controlador.
2. Combate: apuntado, proyectiles/ataque corto, cobertura, vida/daño, eliminación,
   respawn, Turbo Sprint, Embestida Real, dos súpers, IA y revancha.
3. Verificación: importación, pruebas headless, revisión de render cuando sea
   posible, instrucciones PC/Android, estado honesto de recursos y PR sin merge.

Criterios: proyecto abre sin errores, personajes difieren en parámetros, colisiones
bloquean ataques, vida y marcador correctos, cooldown no permite spam, bot mueve/
ataca/evade, pausa congela y revancha limpia estado. No equiparar tests con playtest
humano, arte comercial o rendimiento Android. Arte, rig, texturas, audio y VFX
finales, táctil, equipos 3v3 y red quedan para hitos siguientes.
