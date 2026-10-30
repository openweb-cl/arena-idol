# Arena «Prisma» A y B — refresh visual V2

Estado: **V2 provisional**, original y pendiente de revisión del propietario. Solo
presentación: colliders, `Rect2` de cobertura, apariciones y navegación no cambian.

## Archivos

| Archivo | Responsable | Cambio |
|---|---|---|
| `game/scripts/art/arena_dressing.gd` | Claude | Nuevo: vestido visual completo, construido desde `ArenaDefinition` |
| `game/scripts/modes/pitch.gd` | **Codex (handoff)** | Colliders idénticos; con `dressed = true` (por defecto) añade `ArenaDressing` y omite el graybox. Con `false` vuelve el graybox anterior |
| `art/lib/check_arena_dressing.gd` | Claude | Verifica que nada visual elevado invada la cancha fuera de la cobertura |
| `art/lib/capture_arena.gd` | Claude | Capturas y métricas de A y B |

## Dirección

Identidad de ESTILO_3D: suelo jade, arquitectura azul tinta, líneas menta y acentos
ámbar y coral. Formas abstractas, sin patrocinadores, escudos, textos ni marcas.

- **Suelo:** franjas jade, borde menta, línea media discontinua, emblema hexagonal
  «Prisma» en el centro y chevrones que apuntan al centro en cada mitad.
- **Apariciones:** hexágono con contorno luminoso y flecha hacia el centro, azul para
  el jugador y coral para el bot.
- **Muros perimetrales:** mismas medidas que sus colliders, con remate, nervios,
  franja de luz menta y cantoneras ámbar en las esquinas. Todo queda al ras de la
  cara interior, sin invadir la cancha.
- **Cobertura:** cuerpo **exacto** al `Rect2` y 1,5 m de alto (igual que el
  collider), base oscura, franja media, cantoneras ámbar y remate claro con líneas
  de luz. El color base sigue siendo `wall_color` de cada mapa.
- **Gradas:** tres niveles con barandas luminosas, público con colores variados
  (MultiMesh), muro trasero con pancartas abstractas y torres de luz decorativas
  sin luces dinámicas.

## Rendimiento (conteos medidos, no FPS)

La geometría se agrupa en **tres mallas con color por vértice** (suelo, estructura
y líneas de luz) más dos MultiMesh para el público. Frame completo de la arena con
Turbo, Rey y HUD (Godot 4.7.2, Xvfb, CPU sin GPU real):

| | Antes (graybox) | V2 ALTO | V2 BAJO |
|---|---|---|---|
| Draw calls Forward Mobile | 123 (A) / 127 (B) | **24 / 24** | 24 / 24 |
| Draw calls Compatibility | 253 (A) / 261 (B) | **51 / 51** | — |
| Primitivas | ≈15.100 | ≈31.300 / 32.600 | ≈18.400 / 18.500 |

Más polígonos (sobre todo el público) pero muchos menos draw calls, que suelen ser
el cuello de botella en móvil. En BAJO solo queda la primera fila de público y el
vestido no proyecta sombras. **No acredita FPS ni rendimiento Android.**

## Verificaciones

- `art/lib/check_arena_dressing.gd`: **8/0**. Para A y B comprueba el dressing
  presente, todos los colliders de cobertura intactos, ningún vértice visual
  elevado dentro de la cancha fuera de un `Rect2` (tolerancia 2 cm) y las cuatro
  esquinas superiores exactas de cada `Rect2`. En su primera ejecución detectó
  cantoneras y nervios que invadían 11 y 2,5 cm; se corrigieron antes del commit.
- `tools/verify.py --pack`: 192/192, incluidas las 40 pruebas de mapas (física y
  navegación por `Rect2`).

## Evidencia

- A: [antes](../captures/arena-v2/antes-mobile-prisma-a.png) · [V2 Mobile](../captures/arena-v2/mobile-prisma-a.png) · [ampliación](../captures/arena-v2/mobile-prisma-a-zoom.png) · [BAJO](../captures/arena-v2/mobile-prisma-a-bajo.png) · [Compatibility](../captures/arena-v2/compat-prisma-a.png)
- B: [antes](../captures/arena-v2/antes-mobile-prisma-b.png) · [V2 Mobile](../captures/arena-v2/mobile-prisma-b.png) · [ampliación](../captures/arena-v2/mobile-prisma-b-zoom.png) · [BAJO](../captures/arena-v2/mobile-prisma-b-bajo.png) · [Compatibility](../captures/arena-v2/compat-prisma-b.png)

```bash
godot --headless --path game --script ../art/lib/check_arena_dressing.gd
xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --audio-driver Dummy --fixed-fps 60 \
  --script ../art/lib/capture_arena.gd -- --output=/tmp/arena [--low]
```

## Pendientes

- La fila superior del público queda detrás del mensaje de arena del HUD (UI de
  Codex). En ALTO compite con el texto; en BAJO se lee limpio. Se revisará en el
  refresh de HUD.
- Animar al público (balanceo) se dejó fuera por coste; evaluar en hardware real.
- El campo de tiro usa la arena A y hereda el vestido.
