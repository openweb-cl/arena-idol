# El Turbo #11 — muestra visual V1

Estado: **MUESTRA V1 PROVISIONAL, pendiente de revisión del propietario.** No es
arte final ni calidad comercial. Sirve para validar el pipeline Blender → GLB →
Godot antes de usarlo como patrón para Rey y el resto del plantel.

## Archivos tomados en este hito (Claude Code)

| Archivo | Cambio | Propiedad |
|---|---|---|
| `art/turbo/build_turbo.py` | Generador bpy del modelo, rig y clips | Claude |
| `art/turbo/turbo.blend` | Fuente Blender (no se exporta con el juego) | Claude |
| `art/turbo/render_turbo_sheet.py` | Lámina de revisión en Cycles CPU | Claude |
| `art/turbo/check_turbo_contract.gd` | Verificación del contrato fuera de `game/` | Claude |
| `art/turbo/capture_turbo_v1.gd` | Capturas reales de selección, arenas y clips | Claude |
| `game/assets/models/turbo/turbo.glb` (+ `.import`) | GLB y bucles de clips | Claude |
| `game/data/characters/turbo.tres` | **Solo** `model_scene` (campo de arte) | Codex/propietario; cambio de arte pedido por el propietario para V1 |
| `game/assets/README.md`, `docs/ESTILO_3D.md`, este documento | Manifest y estado | Claude |

**Sin cambios:** `character_visual.gd`, `player.gd`, UI, VFX, tests, colliders,
daño, vida, recarga, movimiento y ataques. El adaptador actual de Codex carga el
GLB tal como está. Rey #23 sigue con placeholder.

## Lámina: dirección y decisiones

- **Concepto:** velocista eléctrico original. Lectura principal desde la cámara
  cenital: cresta en punta barrida hacia atrás (índigo con puntas cian), visor
  eléctrico menta que envuelve la cara, torso cian estrecho y botas blancas grandes.
- **Proporciones:** ≈3,6 cabezas, 2,09 m con cresta (≈1,95 m sin ella), cabeza de
  0,54 m de alto, torso en V estrecho (0,42 m de hombros), manos y botas grandes.
  La silueta es estrecha frente a la de Rey (ancha y de bloque), como pide ESTILO_3D.
- **Siluetas de velocidad:** aletas en la cresta y en los tobillos, rayos geométricos
  en el pecho, las medias y los brazaletes, y un módulo turbo dorsal con dos rejillas.
- **Rostro:** abstracto (visor, nariz y boca simples). No hay un rostro detallado
  porque ESTILO_3D lo reserva para una exploración de artista posterior.
- **Dorsal 11:** glifos geométricos propios, sin fuente tipográfica: pequeño en el
  pecho y grande en un panel blanco en la espalda.
- **Lo que no tiene:** escudos, patrocinadores, marcas, logos, tatuajes, peinados
  ni kits de clubes o personas reales. Las imágenes de `design/` solo se usaron
  para estudiar energía y jerarquía de color; no se importaron ni se calcaron.

### Paleta y materiales (6 de 8 permitidos, todos opacos)

| Material | sRGB | Rugosidad | Uso |
|---|---|---|---|
| `M_Turbo_Cian` | `#2eb8ff` | 0,70 | Camiseta, medias, puntas de la cresta |
| `M_Turbo_Indigo` | `#27318f` | 0,75 | Cresta, short, guantes, módulo |
| `M_Turbo_Blanco` | `#eef7ff` | 0,80 | Botas, ribetes, panel dorsal |
| `M_Turbo_Piel` | `#c98a66` | 0,85 | Piel neutra caricaturesca |
| `M_Turbo_Noche` | `#141b3d` | 0,60 | Dorsal, suelas, boca |
| `M_Turbo_Chispa` | `#7cffe4` emisivo 1,6 | 0,40 | Visor, rayos y brazaletes |

Colores planos sin texturas. Metallic 0. El importador los convierte en
StandardMaterial3D, compatible con Mobile y Compatibility.

## Contrato técnico

- Unidades métricas, pies en (0,0,0), Y arriba, frente -Z en Godot (en Blender el
  modelo mira +Y y el exportador glTF lo convierte).
- Armature única de 17 huesos con pesos rígidos (1,0 por pieza, estilo figura de
  acción, sin deformación suave): `root`, `hips`, `spine`, `chest`, `head` y brazos/piernas L/R.
- `AnimationPlayer` con `idle` (1,6 s, loop), `run` (0,53 s, loop), `kick` (0,4 s),
  `hit` (0,4 s) y `celebrate` (1,2 s, loop). Bucles fijados en `turbo.glb.import`.
- Sin root motion: el hueso `root` no se mueve. El salto de `celebrate` y el
  balanceo de `run` solo desplazan `hips` dentro del esqueleto. El collider de
  gameplay (radio 0,42, altura 1,6) no cambia.
- `kick` golpea en el cuadro 4 (0,13 s) para coincidir con la salida del proyectil,
  que lanza gameplay al aceptar el ataque. Anticipación corta: 2 cuadros.
- Sockets `Muzzle` (pecho, 0,45 m al frente) y `VFXOrigin` (pecho) como nodos
  hijos de `chest`. Gameplay todavía no los usa (contrato: requiere handoff).
- Sin cámaras, luces, scripts ni física dentro del GLB.

## Métricas medidas

| Métrica | Valor | Presupuesto |
|---|---|---|
| Triángulos | 4.146 | ≤ 8.000 |
| Materiales / superficies | 6 | ≤ 8 |
| Huesos | 17 | — |
| Vértices (Blender) | 2.235 | — |
| GLB | 222.892 bytes | — |
| `.blend` (comprimido) | 182.126 bytes | — |
| Draw calls, arena A, frame completo (Turbo GLB vs. placeholder) | 277 vs. 301 | ver nota |
| Draw calls, arena B con GLB | 285 | ver nota |
| Render de la lámina (10 vistas, Cycles CPU, 24 muestras, 420×560, 4 hilos) | ≈35 s en total, 3,1–3,7 s por vista | — |

Los draw calls se contaron con `RenderingServer.get_rendering_info` en
Compatibility sobre Mesa llvmpipe (CPU) con X11 virtual. Incluyen todo el frame
(arena, sombras, Rey, HUD 3D). **Son conteos, no tiempos**, y no acreditan FPS,
GPU ni Android. El GLB usa 6 superficies frente a unas 25 piezas del placeholder,
de ahí la reducción.

## Evidencia

Capturas reales de Godot 4.7.2 (Compatibility, llvmpipe, Xvfb 1280×720), sin retoque:

- [Selección con Turbo 3D](../captures/turbo-v1/01-seleccion-turbo.png)
- [Arena A](../captures/turbo-v1/02-arena-a-turbo.png) · [ampliación ×3](../captures/turbo-v1/02-arena-a-turbo-zoom.png)
- [Arena B](../captures/turbo-v1/03-arena-b-turbo.png) · [ampliación ×3](../captures/turbo-v1/03-arena-b-turbo-zoom.png)
- [Turbo como bot en B (humano Rey)](../captures/turbo-v1/05-arena-b-turbo-bot-zoom.png)
- [Referencia: placeholder anterior, ampliación ×3](../captures/turbo-v1/90-referencia-placeholder-zoom.png)
- [Cinco clips importados en Godot](../captures/turbo-v1/04-clips-godot.png)

Render de Blender (no es captura de juego): [lámina V1](../captures/turbo-v1/lamina_turbo_v1.jpg).

## Comandos reproducibles

Herramientas: Blender 5.2.3 LTS como módulo `bpy` de PyPI (GPL, gratuito) y
Godot 4.7.2 estable oficial. blender.org estaba bloqueado por la red del entorno
cloud, y el binario de Blender 5.2 da el mismo resultado con
`blender --background --python ...`.

```bash
python3 -m venv .venv-bpy && .venv-bpy/bin/pip install bpy==5.2.3 pillow
.venv-bpy/bin/python art/turbo/build_turbo.py          # .blend + GLB
.venv-bpy/bin/python art/turbo/render_turbo_sheet.py /tmp/turbo-renders
godot --headless --path game --editor --import
godot --headless --path game --script ../art/turbo/check_turbo_contract.gd
xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --rendering-method gl_compatibility \
  --audio-driver Dummy --script ../art/turbo/capture_turbo_v1.gd -- --output=/tmp/turbo-v1
python3 tools/verify.py --godot godot --pack
```

Resultados de esta entrega: contrato **41 aprobadas, 0 fallos**. `verify.py --pack`
pasa completo, con las 192 comprobaciones de Codex (50 + 41 + 31 + 30 + 40), la
exportación PCK y el arranque de menú, arenas y campo de tiro.

## Observaciones y pendientes

1. **Lectura en cámara de juego:** el héroe mide ≈35 px de alto a 1280×720. Se
   distinguen la cresta índigo, el torso cian y las botas blancas, pero la etiqueta
   `#11 · PV / CARGAS` tapa la cresta. Mover la etiqueta o escalar el modelo es una
   decisión de UI/escala compartida: queda propuesta para Codex y el propietario,
   no aplicada.
2. **Color en Godot:** con el tonemapper Filmic y la luz de la arena, la piel y el
   cian se ven más claros que en Blender. Ajustar después de revisar con el
   propietario en un dispositivo real.
3. **Pie de selección:** `menu.gd` (UI compartida) todavía muestra «Integración
   artística GLB pendiente». Sigue siendo cierto para Rey; cambiar el texto requiere
   handoff de UI.
4. **No producido en V1:** VFX y audio nuevos de ataque y habilidad (siguen los
   provisionales de Codex), outline o shader toon, AnimationTree o blendspace, rostro
   detallado, pruebas en el renderizador Mobile/Vulkan (no hay GPU en el entorno) y
   en Android. Pendiente de hardware real.
5. **Pesos rígidos:** se eligieron por robustez y legibilidad caricaturesca. Si la
   revisión pide deformación orgánica, hay que pasar a pesos suaves en hombros y
   caderas.
6. **Decisión del propietario pendiente:** pidió que Turbo «se parezca» a un
   futbolista real a partir de fotos. No se aplicó: las reglas del proyecto prohíben
   rostros, peinados, tatuajes y kits reconocibles de personas reales sin permiso,
   y parecerse sin ser idéntico conserva el riesgo de derechos de imagen. Hace falta
   una autorización escrita (derechos de imagen y licencia del club) antes de
   cualquier variante basada en una persona real, en un PR separado.
