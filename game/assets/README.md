# Manifest de recursos y estado

| Recurso | Procedencia | Estado | Reemplazo previsto |
|---|---|---|---|
| Turbo #11 — `models/turbo/turbo.glb` | Original, Claude Code, 2026-10-30. Generado con `art/turbo/build_turbo.py` + `art/lib/hero_kit.py` (Blender 5.2.3/bpy, GPL; el resultado es obra propia). Fuente `art/turbo/turbo.blend`. Tatuajes de diseño propio | **Muestra V1.1 provisional**, pendiente de revisión; no es arte final | Iteración tras la revisión (docs/arte/HEROES.md) |
| Rey/King #23 — `models/rey/rey.glb` | Original, Claude Code, 2026-10-30. `art/rey/build_rey.py` + kit común. Fuente `art/rey/rey.blend` | **Muestra V0 provisional**, primera forma | Iteración tras la revisión |
| Clips idle/run/kick/hit/celebrate de ambos | Keyframes originales en los generadores; bucles en los `.glb.import` | Provisionales | Ajuste tras playtest |
| Materiales `M_Turbo_*` y `M_Rey_*` (6 + 6) | Colores planos originales dentro de cada GLB, sin texturas | Provisionales | — |
| Arena Prisma | Geometría original en `pitch.gd` | Graybox 3D provisional | Escena artística con colisiones compatibles |
| Proyectiles/estelas/anillos | Geometría original en `projectile.gd` y `ability_effect.gd` | VFX provisional | VFX escalables Mobile/Compatibility |
| UI | Controles Godot, diseño original en `scripts/ui/` | Interfaz funcional provisional | Producción artística coordinada |
| Tipografía de fallback | Fuente predeterminada de Godot (Noto Sans) | Incluida por el motor | Revisar licencias si se añade otra fuente |
| Audio | Ninguno | Pendiente | Original o CC0 con licencia verificada |

No se incorporan modelos, texturas ni audio externos. Godot distribuye Noto Sans
bajo SIL Open Font License; no se ha descargado una fuente adicional. Las nuevas
fuentes/recursos de terceros deberán incluir archivo de licencia y procedencia.
Las figuras geométricas actuales NO representan el resultado artístico final.

Los GLB de Turbo y Rey (`assets/models/`) tienen sus fuentes en `art/`, en la raíz y
fuera del export. Licencia del arte: obra original del proyecto, con la misma
titularidad pendiente que el código. Sin recursos de terceros, fuentes tipográficas ni texturas. No es necesario
Blender para abrir el juego. Contrato: `docs/CONTRATO_ARTE_3D.md` en el repositorio.

Solo `game/` se exporta. Las referencias internas en `data/` y las imágenes de
`design/` de raíz no se cargan ni empaquetan. Los nombres de héroes son provisionales
para el prototipo, no autorización comercial; rigen `LICENSE-NOTE.md` y los textos
legales. La titularidad/licencia del código sigue pendiente según esos documentos.
