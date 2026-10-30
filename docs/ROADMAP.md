# Hoja de ruta vigente — combate arcade 3D

La corrección de combate posterior a v0.4 sustituye los hitos deportivos previos.
Hitos por resultados verificables, sin fechas de compromiso.

## M0 — Fundación técnica y colaboración (esta entrega)

Godot 4 estable y GDScript, arena 3D real, cámara superior inclinada, menú y
selección Turbo #11 / Rey #23, parámetros en inspector. AGENTS y CLAUDE alineados,
contrato de arte, ramas separadas, PR sin merge. Pruebas ejecutadas y límites
explícitos. Geometría provisional no equivale a arte final.

## M1 — Combate local (demo inicial)

Batalla de entrenamiento: 1 humano y bot, proyectiles, melee, cobertura, apuntado,
vida, daño, eliminación, respawn, Turbo Sprint, Embestida Real, dos súpers,
resultado y revancha. Bot persigue/ataca/evade. Gate: ciclo completo sin bloqueo,
pruebas de reglas/colisiones y playtest manual. No declarar diversión o balance
solo con tests. Primer PR puede incluir base funcional de estos sistemas.

## M2 — Producción artística y Android

Claude Code integra modelos Blender/GLB originales, rig, clips, materiales, VFX,
UI y audio con licencias. Codex integra táctil, accesibilidad y perfiles de
rendimiento. Export APK gratuito de pruebas; medir CPU/GPU y frame times en tres
dispositivos. Gate: 60 FPS objetivo en hardware acordado y ajustes para gama baja,
20 playtests con adultos y resultados de legibilidad/deseo de repetir.

## M3 — Equipos y primera red

Primero validar combate local 3v3, luego prueba 1v1 autoritativa con comandos y
snapshots. Predicción, reconciliación, interpolación, latencia, desconexiones y
abuso. No instalar servidores ni contratar servicios en M0/M1.

## M4 — Batalla de Ídolos 3v3 online y expansión

Salas privadas, equipos, validación de resultados y bots de reemplazo. Agregar
personajes gradualmente hasta los 16 del roster v0.4. Balón de Gloria, Rey de la
Arena, Último Ídolo y Duelo de Leyendas como modos separados, después del combate.

## M5 — Beta y calidad comercial

Arte final revisado, licencias/marca/derechos, menores/privacidad/moderación,
optimización real, pruebas de accesibilidad, hosting y tiendas. Cosméticos sin
ventajas de pago. Gate comercial no se satisface con placeholders o capturas.

Backlog técnico y reparto siguiente: `issues/FOUNDATION.md` y
`COORDINACION_AGENTES.md`. Casillas solo con evidencia en `VALIDACION.md`.
