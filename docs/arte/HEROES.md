# Héroes 3D — Turbo #11 (V1.1) y King/Rey #23 (V0)

Estado: **MUESTRAS PROVISIONALES pendientes de revisión del propietario.** No son
arte final ni calidad comercial. Validan el pipeline Blender → GLB → Godot y la
dirección pedida por el propietario el 2026-10-30.

## Historial

- **Turbo V1** (PR #7, fusionado): primera muestra cian/índigo con visor.
- **Turbo V1.1** (este hito): equipación azul con detalles rojos, pelo blanco y
  tatuajes visibles, a pedido del propietario.
- **Rey/King V0** (este hito): primera forma en blanco y negro con sello propio.

## Archivos tomados (Claude Code)

| Archivo | Cambio |
|---|---|
| `art/lib/hero_kit.py` | Kit común: geometría rígida, tatuajes, dígitos, rig, clips base y export |
| `art/lib/render_sheet.py` | Lámina de revisión por héroe (Cycles CPU) |
| `art/lib/check_hero_contract.gd` | Verificación del contrato por héroe, fuera de `game/` |
| `art/lib/capture_heroes.gd` | Capturas reales de menú, selección, arenas y clips |
| `art/turbo/build_turbo.py`, `art/turbo/turbo.blend` | Fuente de Turbo |
| `art/rey/build_rey.py`, `art/rey/rey.blend` | Fuente de Rey |
| `game/assets/models/{turbo,rey}/*.glb` (+ `.import`) | GLB y bucles de clips |
| `game/data/characters/{turbo,rey}.tres` | **Solo** `model_scene` (campo de arte) |
| `game/assets/README.md`, `docs/ESTILO_3D.md`, este documento | Manifest y estado |

**Sin cambios:** `character_visual.gd`, `player.gd`, UI, VFX, tests, colliders,
daño, vida, recarga, movimiento, ataques y el campo `color` de los recursos (lo usa
la UI y es de Codex).

## Decisiones del propietario (2026-10-30)

1. Turbo: ropa **azul con detalles rojos** (no celeste), **pelo blanco** y
   **tatuajes visibles**.
2. Rey («el King»): **blanco y negro** con el 23, parecido a las referencias pero
   con algo que lo distinga.
3. El propietario pidió además que Turbo se pareciera a un futbolista real según
   fotos. **No se modela ningún rostro, tatuaje, escudo, patrocinador ni kit real.**
   Los tatuajes son diseños propios: bandas en zigzag, rombos, una estrella y un rayo.
   Advertencia: la combinación azul-rojo, el 11, el pelo claro y los tatuajes acerca
   el personaje a esa referencia. Antes de cualquier uso comercial hace falta revisión
   legal o una autorización escrita. Los nombres siguen siendo provisionales (AGENTS.md).

## Turbo #11 — V1.1

- **Silueta:** estrecha de velocista, ≈3,6 cabezas, cresta de pelo **blanco** en
  punta barrida hacia atrás, visor eléctrico y botas grandes.
- **Equipación:** camiseta, short y medias **azules**. Detalles **rojos**: cuello,
  canesú, paneles laterales, puños, franjas del short, bandas de las medias,
  punteras, aletas de tobillo y trazos del pecho. Dorsal 11 blanco en pecho y espalda.
- **Tatuajes (diseño propio, tinta azul noche):** mangas en ambos brazos con bandas
  en zigzag y rombos; estrella de ocho puntas en el brazo izquierdo, rayo en el
  derecho y marcas en ambos lados del cuello.
- **Rostro:** abstracto (visor amarillo eléctrico). El rostro detallado queda para
  una exploración de artista.

| Material | sRGB | Uso |
|---|---|---|
| `M_Turbo_Azul` | `#1f3fbf` | Camiseta, short, medias |
| `M_Turbo_Rojo` | `#e0262f` | Detalles |
| `M_Turbo_Blanco` | `#f1f3f7` | Pelo, botas, dorsal |
| `M_Turbo_Piel` | `#c98a66` | Piel |
| `M_Turbo_Tinta` | `#141b3d` | Tatuajes, guantes, suelas |
| `M_Turbo_Chispa` | `#ffe873` emisivo | Visor y rayos |

## Rey / King #23 — V0

- **Silueta:** tanque ancho (hombros a 0,72 m de punta a punta con hombreras),
  piernas más cortas, cabeza de mandíbula cuadrada y guantes grandes.
- **Blanco y negro:** camiseta blanca, short negro, medias blancas con banda negra
  y botas negras.
- **Lo que lo distingue:** corona dorada de cinco puntas con gema violeta. En el
  pecho, una banda negra con tres puntas de corona en lugar de franjas. Hombreras
  negras con ribete dorado y **capa corta violeta** con el **23 dorado** en la
  espalda. El violeta lo enlaza con su súper (Onda Real).
- **Rostro:** abstracto (visor ámbar), cejas marcadas y sonrisa. No lleva barba,
  cresta mohicana ni tatuajes, para no evocar a una persona real.
- **Ataque (`kick`):** gancho de derecha con paso; el impacto llega a los 0,13 s.

| Material | sRGB | Uso |
|---|---|---|
| `M_Rey_Blanco` | `#f2f2ef` | Camiseta, medias |
| `M_Rey_Negro` | `#18181c` | Short, botas, hombreras, banda, pelo |
| `M_Rey_Oro` | `#f2b632` | Corona, ribetes, punteras, 23 de la capa |
| `M_Rey_Violeta` | `#5b2a86` | Capa, gema |
| `M_Rey_Piel` | `#a8724f` | Piel |
| `M_Rey_Brillo` | `#ffc94d` emisivo | Visor |

## Contrato técnico (ambos)

- Pies en el origen, frente -Z en Godot y unidades métricas. Sin cámaras, luces,
  scripts ni física.
- Rig de 17 huesos con pesos rígidos (estilo figura de acción). Clips `idle`, `run`
  y `celebrate` en loop; `kick` y `hit` sin loop. Sin root motion.
- Sockets `Muzzle` y `VFXOrigin` en `chest` (gameplay todavía no los usa).
- Colores planos sin texturas, 6 materiales opacos StandardMaterial3D, compatibles
  con Mobile y Compatibility.

## Métricas medidas

| Métrica | Turbo V1.1 | Rey V0 | Presupuesto |
|---|---|---|---|
| Triángulos | 5.378 | 4.634 | ≤ 8.000 |
| Materiales | 6 | 6 | ≤ 8 |
| Huesos / clips | 17 / 5 | 17 / 5 | — |
| Altura (con pelo o corona) | 2,09 m | 2,00 m | ≈ 2 m |
| GLB | 335.944 B | 235.132 B | — |
| `.blend` | 199.905 B | 187.996 B | — |
| Lámina (10 vistas, Cycles CPU, 4 hilos) | 32,8 s | 32,2 s | — |

Draw calls de un frame completo en la arena A, con ambos héroes en GLB frente a
ambos placeholders: **123 frente a 159** en Forward Mobile (Vulkan, lavapipe) y
**253 frente a 301** en Compatibility (llvmpipe). Son conteos en CPU sin GPU real;
**no** acreditan FPS ni rendimiento Android.

## Evidencia

Capturas reales de Godot 4.7.2 (Xvfb 1280×720, sin retoque). Forward Mobile
(Vulkan lavapipe):

- [Selección Turbo](../captures/heroes-v1-1/mobile-01-seleccion-turbo.png) · [Selección Rey](../captures/heroes-v1-1/mobile-02-seleccion-rey.png)
- [Arena A (Turbo humano, Rey bot)](../captures/heroes-v1-1/mobile-03-arena-a.png): ampliaciones ×3 de [Turbo](../captures/heroes-v1-1/mobile-03-arena-a-zoom-turbo.png) y [Rey](../captures/heroes-v1-1/mobile-03-arena-a-zoom-rey.png)
- [Arena B (Rey humano, Turbo bot)](../captures/heroes-v1-1/mobile-04-arena-b.png): ampliaciones ×3 de [Rey](../captures/heroes-v1-1/mobile-04-arena-b-zoom-rey.png) y [Turbo](../captures/heroes-v1-1/mobile-04-arena-b-zoom-turbo.png)
- Clips importados: [Turbo](../captures/heroes-v1-1/mobile-05-clips-turbo.png) · [Rey](../captures/heroes-v1-1/mobile-06-clips-rey.png)
- Referencia con placeholders anteriores: [Turbo](../captures/heroes-v1-1/mobile-90-referencia-placeholders-zoom-turbo.png) · [Rey](../captures/heroes-v1-1/mobile-90-referencia-placeholders-zoom-rey.png)
- Compatibility (OpenGL llvmpipe): [Arena A](../captures/heroes-v1-1/compat-03-arena-a.png)

Renders de Blender (no son capturas de juego): [lámina Turbo](../captures/heroes-v1-1/lamina_turbo.jpg) · [lámina Rey](../captures/heroes-v1-1/lamina_rey.jpg).

## Comandos reproducibles

Blender 5.2.3 LTS como módulo `bpy` de PyPI (GPL, gratuito) y Godot 4.7.2 estable.

```bash
python3 -m venv .venv-bpy && .venv-bpy/bin/pip install bpy==5.2.3 pillow
.venv-bpy/bin/python art/turbo/build_turbo.py
.venv-bpy/bin/python art/rey/build_rey.py
.venv-bpy/bin/python art/lib/render_sheet.py turbo /tmp/laminas
.venv-bpy/bin/python art/lib/render_sheet.py rey /tmp/laminas
godot --headless --path game --editor --import
godot --headless --path game --script ../art/lib/check_hero_contract.gd -- --hero=turbo
godot --headless --path game --script ../art/lib/check_hero_contract.gd -- --hero=rey
xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --audio-driver Dummy \
  --script ../art/lib/capture_heroes.gd -- --output=/tmp/heroes
python3 tools/verify.py --godot godot --pack
```

Resultados: contrato **Turbo 40/0 y Rey 40/0** (aprobadas/fallos). `verify.py
--pack` pasa completo con las 192 comprobaciones de Codex, la exportación PCK y el
arranque de las escenas.

## Incidencia del propietario: pantalla negra en Godot 4.7

Al pasar de 4.6 a 4.7, en el PC del propietario (Windows) el proyecto se veía
negro con el renderizador Mobile (Vulkan) y se vio bien con
`--rendering-method gl_compatibility`. En este entorno, 4.7.2 renderiza bien con
Mobile sobre lavapipe, así que apunta al driver Vulkan de ese equipo. Pendiente:
actualizar el driver de la GPU, y que Codex decida si conviene un aviso o un
cambio de renderizador en `project.godot`. El proyecto, además, está dentro de
OneDrive; se recomienda clonarlo fuera de carpetas sincronizadas.

## Pendientes

1. La etiqueta `#nº · PV / CARGAS` tapa la cabeza en la cámara de juego (UI de Codex).
2. El campo `color` de `turbo.tres` (anillo y textos) sigue cian. Proponer a Codex
   cambiarlo a azul/rojo para que coincida con la equipación.
3. El pie de selección de `menu.gd` todavía dice «Integración artística GLB pendiente».
4. No producido: VFX y audio nuevos, outline o toon, AnimationTree, rostros detallados
   y pruebas en GPU real o Android.
5. Los pesos rígidos se mantienen; si la revisión pide deformación orgánica, hay que
   pasar a pesos suaves.
