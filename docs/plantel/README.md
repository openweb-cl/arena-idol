# Plantel — biblioteca de diseño y evolución

**16 héroes canónicos; dos jugables; cuatro GLB provisionales.** Este paquete
organiza referencias y propuestas para continuar en local. No implementa nuevos
personajes ni sustituye el diseño aprobado por una imagen recién generada.

- [Visión visual y etapas V0 → candidato final](VISUAL.md).
- [Referencias elegidas por el propietario](../../design/referencias/propietario_2026-10-31/README.md).
- [Carpetas visuales de cada personaje](../../design/personajes/README.md).
- [Reglas de combate](REGLAS_COMBATE.md) y [producción por hitos](PRODUCCION.md).
- [Contexto de continuidad](../CONTEXTO_DE_CONTINUIDAD.md).
- [Verificación y límites de esta entrega](VERIFICACION.md).

La línea elegida es caricaturesca como las primeras láminas aportadas; la última
orienta composición de pantallas, no realismo de rostros. Nuevas exploraciones
son propuestas pendientes. Primero aprobar **Turbo V2** y usarlo como patrón.
Los kits de los 14 pendientes son hipótesis, con ataque básico ofensivo en todos.
El Príncipe mantiene prioridad y necesita aprobación de su ficha antes del código;
Pitbull espera su prueba. Los otros 12 dorsales permanecen sin definir.

| ID | Personaje | Dorsal | Rol propuesto | Arte existente | Combate |
|---|---|---|---|---|---|
| UCH-01 | [El Turbo](../../design/personajes/turbo/README.md) | #11 | Velocista / daño a distancia | GLB provisional | [Ficha](fichas/turbo.md) |
| UCH-02 | [El Príncipe](../../design/personajes/principe/README.md) | #20 | Estratega / precisión y apoyo | GLB provisional | [Ficha](fichas/principe.md) |
| COL-01 | [El Rey](../../design/personajes/rey/README.md) | #23 | Tanque / presión cercana | GLB provisional | [Ficha](fichas/rey.md) |
| COL-02 | [El Cacique](../../design/personajes/cacique/README.md) | dorsal pendiente | Guerrero / cobertura táctica | Referencia 2D | [Ficha](fichas/cacique.md) |
| CAT-01 | [Caballero Cruzado](../../design/personajes/caballero_cruzado/README.md) | dorsal pendiente | Asaltante / precisión de impacto | Referencia 2D | [Ficha](fichas/caballero_cruzado.md) |
| CAT-02 | [El Pitbull](../../design/personajes/pitbull/README.md) | #17 | Defensor / contención | GLB provisional | [Ficha](fichas/pitbull.md) |
| SWA-01 | [El Elegante](../../design/personajes/elegante/README.md) | dorsal pendiente | Defensor técnico / contraataque | Referencia 2D | [Ficha](fichas/elegante.md) |
| SWA-02 | [El Porteño](../../design/personajes/porteno/README.md) | dorsal pendiente | Defensor / desplazamiento | Referencia 2D | [Ficha](fichas/porteno.md) |
| COB-01 | [El Artillero Loíno](../../design/personajes/artillero_loino/README.md) | dorsal pendiente | Artillero / presión preparada | Referencia 2D | [Ficha](fichas/artillero_loino.md) |
| COB-02 | [El Zorro del Desierto](../../design/personajes/zorro_desierto/README.md) | dorsal pendiente | Evasor / distracción | Referencia 2D | [Ficha](fichas/zorro_desierto.md) |
| COQ-01 | [El Guardián](../../design/personajes/guardian/README.md) | dorsal pendiente | Protector / escudos | Referencia 2D | [Ficha](fichas/guardian.md) |
| COQ-02 | [El Pirata](../../design/personajes/pirata/README.md) | dorsal pendiente | Creativo / trayectorias y agarre | Referencia 2D | [Ficha](fichas/pirata.md) |
| PAL-01 | [El Ilusionista](../../design/personajes/ilusionista/README.md) | dorsal pendiente | Técnico / geometría de disparo | Referencia 2D | [Ficha](fichas/ilusionista.md) |
| PAL-02 | [El Tricolor](../../design/personajes/tricolor/README.md) | dorsal pendiente | Apoyo / poder y movilidad | Referencia 2D | [Ficha](fichas/tricolor.md) |
| CON-01 | [El Bati](../../design/personajes/bati/README.md) | dorsal pendiente | Asaltante / impacto preparado | Referencia 2D | [Ficha](fichas/bati.md) |
| CON-02 | [El León de Collao](../../design/personajes/leon_collao/README.md) | dorsal pendiente | Tanque / ruptura de formación | Referencia 2D | [Ficha](fichas/leon_collao.md) |

Las fichas y carpetas se generan desde [roster_v1.json](roster_v1.json):

```sh
python3 tools/render_roster_design.py
python3 tools/render_roster_design.py --check
```

Ejecutar desde la raíz. El catálogo vive fuera de `game/`; no es un Resource de
Godot ni una promesa de sistemas implementados. No editar a mano los archivos
generados sin actualizar catálogo/renderizador. Referencias/manifest preservan
procedencia y hashes; los originales adjuntos permanecen intactos.
