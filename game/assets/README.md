# Manifest de recursos y estado

| Recurso | Procedencia | Estado | Reemplazo previsto |
|---|---|---|---|
| Turbo #11 — `models/turbo/turbo.glb` | Original, Claude Code, 2026-10-30. Generado con `art/turbo/build_turbo.py` + `art/lib/hero_kit.py` (Blender 5.2.3/bpy, GPL; el resultado es obra propia). Atlas `art/turbo/turbo_atlas.png` pintado por `art/turbo/paint_turbo_atlas.py` (Pillow, formas propias, sin fuentes). Fuente `art/turbo/turbo.blend`. Rostro y tatuajes de diseño propio, desde la referencia V2 aceptada | **Modelo V3 provisional**, pendiente de revisión; no es arte final | Iteración tras la revisión (docs/arte/HEROES.md) |
| Rey/King #23 — `models/rey/rey.glb` | Original, Claude Code, 2026-10-30. `art/rey/build_rey.py` + kit común. Fuente `art/rey/rey.blend` | **Muestra V0 provisional**, primera forma | Iteración tras la revisión |
| Príncipe — `models/principe/principe.glb` | Original, Claude Code, 2026-10-31. `art/principe/build_principe.py` + cuerpo común `art/lib/hero_v3.py`. Atlas `art/principe/principe_atlas.png` (Pillow, formas propias). Fuente `.blend` en `art/principe/` | **Modelo V3 provisional**, dorsal 20, jugable; pendiente de revisión | Revisión del propietario en partida |
| Pitbull — `models/pitbull/pitbull.glb` | Original, Claude Code, 2026-10-30. `art/pitbull/build_pitbull.py` + kit común. Fuente `.blend` en `art/pitbull/` | **Muestra V0 solo arte**, dorsal 17; sin `.tres` ni gameplay | Ficha C2 (Codex) |
| Clips idle/run/kick/hit/celebrate de los cuatro | Keyframes originales en los generadores; bucles en los `.glb.import` | Provisionales | Ajuste tras playtest |
| Materiales `M_Turbo_Atlas` y `M_Principe_Atlas` (1 cada uno, textura 1024 extraída por Godot del GLB, importada sin compresión de GPU), `M_Rey_*`, `M_Pitbull_*` (6 + 7) | Atlas originales de Turbo y Príncipe; los demás, colores planos sin texturas | Provisionales | — |
| Arena Prisma A/B | Original, Claude Code, 2026-10-30: `scripts/art/arena_dressing.gd` (geometría procedural y MultiMesh de Godot, sin texturas); colliders en `pitch.gd` | **V2 visual provisional**, pendiente de revisión | Ajuste tras playtest (docs/arte/ARENA.md) |
| VFX de combate (disparo, proyectil, sprint, súper, golpe, embestida, onda, impacto, escudo, cobertura, eliminación) | Originales, Claude Code, 2026-10-30, en `scripts/vfx/` (geometría y partículas de Godot, sin texturas) | **VFX V1 provisionales**, pendientes de revisión | Ajuste tras playtest (docs/arte/VFX.md) |
| Ícono `ui/icono_provisional.png` | Original, render Cycles del busto de Turbo (`art/lib/render_icon.py`) | Provisional, sin enlazar | Identidad de app definitiva |
| UI (menú, selección, HUD, controles táctiles) | Original: lógica táctil de Codex; aspecto V2 de Claude Code, 2026-10-30, en `scripts/ui/style.gd`, `menu_backdrop.gd`, `touch_skin.gd`, `hud.gd` y `menu.gd` (dibujo vectorial, sin texturas) | **UI V2 provisional**, pendiente de revisión | Ajuste tras prueba en teléfono (docs/arte/UI.md) |
| Tipografía de fallback | Fuente predeterminada de Godot (Noto Sans); la negrita es una `FontVariation` de esa misma fuente | Incluida por el motor | Revisar licencias si se añade otra fuente |
| Audio | Ninguno | Pendiente | Original o CC0 con licencia verificada |

No se incorporan modelos, texturas ni audio externos. Godot distribuye Noto Sans
bajo SIL Open Font License; no se ha descargado una fuente adicional. Las nuevas
fuentes/recursos de terceros deberán incluir archivo de licencia y procedencia.
Las figuras geométricas actuales NO representan el resultado artístico final.

Los GLB de los héroes (`assets/models/`) tienen sus fuentes en `art/`, en la raíz y
fuera del export. Licencia del arte: obra original del proyecto, con la misma
titularidad pendiente que el código. Sin recursos de terceros, fuentes tipográficas ni texturas. No es necesario
Blender para abrir el juego. Contrato: `docs/CONTRATO_ARTE_3D.md` en el repositorio.

Solo `game/` se exporta. Las referencias internas en `data/` y las imágenes de
`design/` de raíz no se cargan ni empaquetan. Los nombres de héroes son provisionales
para el prototipo, no autorización comercial; rigen `LICENSE-NOTE.md` y los textos
legales. La titularidad/licencia del código sigue pendiente según esos documentos.
