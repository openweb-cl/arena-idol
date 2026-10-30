# Manifest de recursos y estado

| Recurso | Procedencia | Estado | Reemplazo previsto |
|---|---|---|---|
| Turbo #11 — `models/turbo/turbo.glb` | Original, Claude Code, 2026-10-30. Generado con `art/turbo/build_turbo.py` (Blender 5.2.3 / bpy, GPL; el resultado es obra propia). Fuente `art/turbo/turbo.blend` | **Muestra V1 provisional**, pendiente de revisión del propietario; no es arte final | Iteración tras la revisión (docs/arte/TURBO_V1.md) |
| Clips de Turbo idle/run/kick/hit/celebrate | Keyframes originales en el mismo generador; bucles en `turbo.glb.import` | Muestra V1 provisional | Ajuste tras playtest |
| Materiales de Turbo (6, `M_Turbo_*`) | Colores planos originales dentro del GLB, sin texturas | Muestra V1 provisional | — |
| Rey #23 | Meshes originales creados en `character_visual.gd` | Provisional de mecánicas, sin rig/GLB | Claude Code: V2 |
| Idle/run/kick/hit/celebrate de Rey | Animación procedural original en `character_visual.gd` | Provisional | Clips según contrato (V2) |
| Arena Prisma | Geometría original en `pitch.gd` | Graybox 3D provisional | Escena artística con colisiones compatibles |
| Proyectiles/estelas/anillos | Geometría original en `projectile.gd` y `ability_effect.gd` | VFX provisional | VFX escalables Mobile/Compatibility |
| UI | Controles Godot, diseño original en `scripts/ui/` | Interfaz funcional provisional | Producción artística coordinada |
| Tipografía de fallback | Fuente predeterminada de Godot (Noto Sans) | Incluida por el motor | Revisar licencias si se añade otra fuente |
| Audio | Ninguno | Pendiente | Original o CC0 con licencia verificada |

No se incorporan modelos, texturas ni audio externos. Godot distribuye Noto Sans
bajo SIL Open Font License; no se ha descargado una fuente adicional. Las nuevas
fuentes/recursos de terceros deberán incluir archivo de licencia y procedencia.
Las figuras geométricas actuales NO representan el resultado artístico final.

El primer GLB producido por Claude es Turbo V1 (`assets/models/turbo/`), y su fuente está en
`art/turbo/`, en la raíz y fuera del export. Licencia del arte: obra original del proyecto, con la misma
titularidad pendiente que el código. Sin recursos de terceros, fuentes tipográficas ni texturas. No es necesario
Blender para abrir el juego. Contrato: `docs/CONTRATO_ARTE_3D.md` en el repositorio.

Solo `game/` se exporta. Las referencias internas en `data/` y las imágenes de
`design/` de raíz no se cargan ni empaquetan. Los nombres de héroes son provisionales
para el prototipo, no autorización comercial; rigen `LICENSE-NOTE.md` y los textos
legales. La titularidad/licencia del código sigue pendiente según esos documentos.
