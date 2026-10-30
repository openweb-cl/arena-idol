# Manifest de recursos y estado

| Recurso | Procedencia | Estado | Reemplazo previsto |
|---|---|---|---|
| Turbo #11 y Rey #23 | Meshes originales creados en `character_visual.gd` | Provisional de mecánicas, sin rig/GLB | Claude Code: Blender/GLB original y rig |
| Idle/run/kick/hit/celebrate | Animación procedural original en `character_visual.gd` | Provisional | Clips de artista según contrato |
| Arena Prisma | Geometría original en `pitch.gd` | Graybox 3D provisional | Escena artística con colisiones compatibles |
| Proyectiles/estelas/anillos | Geometría original en `projectile.gd` y `ability_effect.gd` | VFX provisional | VFX escalables Mobile/Compatibility |
| UI | Controles Godot, diseño original en `scripts/ui/` | Interfaz funcional provisional | Producción artística coordinada |
| Tipografía de fallback | Fuente predeterminada de Godot (Noto Sans) | Incluida por el motor | Revisar licencias si se añade otra fuente |
| Audio | Ninguno | Pendiente | Original o CC0 con licencia verificada |

No se incorporan modelos, texturas ni audio externos. Godot distribuye Noto Sans
bajo SIL Open Font License; no se ha descargado una fuente adicional. Las nuevas
fuentes/recursos de terceros deberán incluir archivo de licencia y procedencia.
Las figuras geométricas actuales NO representan el resultado artístico final.

No hay `.blend`/GLB producidos por Claude en esta entrega. El destino de modelos
es `assets/models/`; las fuentes artísticas irán en `art/` de raíz. No es necesario
Blender para abrir el juego. Contrato: `docs/CONTRATO_ARTE_3D.md` en el repositorio.

Solo `game/` se exporta. Las referencias internas en `data/` y las imágenes de
`design/` de raíz no se cargan ni empaquetan. Los nombres de héroes son provisionales
para el prototipo, no autorización comercial; rigen `LICENSE-NOTE.md` y los textos
legales. La titularidad/licencia del código sigue pendiente según esos documentos.
