# Efectos visuales de combate — V1 y prueba de APK

Estado: **VFX V1 provisionales**, originales y pendientes de revisión del
propietario. No son arte final. No cambian reglas: solo representan eventos que
emite gameplay.

## Archivos

| Archivo | Responsable | Cambio |
|---|---|---|
| `game/scripts/vfx/vfx_kit.gd` | Claude | Nuevo: materiales y formas comunes (arcos, rayos, destellos, chispas) |
| `game/scripts/vfx/ability_effect.gd` | Claude | Reescrito: un efecto distinto por evento |
| `game/scripts/vfx/projectile_visual.gd` | Claude | Nuevo: aspecto del proyectil de Turbo |
| `game/scripts/modes/arena.gd` | **Codex (handoff)** | Ganchos mínimos: nombre del evento, `follow`, `radius`, escudo, cobertura, eliminación |
| `game/scripts/combat/projectile.gd` | **Codex (handoff)** | Delega su aspecto a `ProjectileVisual`; collider, velocidad y daño intactos |
| `art/lib/capture_vfx.gd`, `art/lib/render_icon.py` | Claude | Capturas de VFX e ícono provisional |
| `game/assets/ui/icono_provisional.png` | Claude | Ícono 512×512 original (busto de Turbo), sin enlazar |

Los ganchos en archivos de Codex están en un commit separado para que los revise.
No tocan daño, vida, recarga, movimiento, colisiones ni puntuación.

## Efectos por evento

| Evento (`kind`) | Cuándo | Lectura visual | Vida |
|---|---|---|---|
| `shot` | Disparo básico de Turbo | Destello amarillo y azul a la altura del socket `Muzzle`, chispas hacia el frente; se dibuja por encima del cuerpo | 0,2 s |
| proyectil | Vuelo del disparo | Núcleo amarillo claro siempre visible, halo azul más pequeño detrás (cabeza de cometa), anillo horizontal giratorio y estela en rayo zigzag | vuelo |
| proyectil súper | Bombazo Turbo | Núcleo doble de tamaño, dos anillos horizontales (amarillo y rojo) por fuera de su silueta y estela gruesa | vuelo |
| `turbo_sprint` | Turbo Sprint | Estelas de velocidad azul y amarilla que siguen al héroe, rayo vivo y anillo eléctrico en el punto de partida | 0,45 s |
| `turbo_super` | Lanzar Bombazo | Anillos de carga, rayos verticales, destello grande y abanico de esquirlas | 0,5 s |
| `melee` | Golpe de Rey | Arco dorado que barre de derecha a izquierda y polvo | 0,3 s |
| `rey_charge` | Embestida Real | Escudo ámbar frontal que acompaña al Rey y polvo en el arranque | 0,4 s |
| `rey_super` | Dominio Real | Onda violeta y dorada que crece **exactamente hasta `super_radius`** (4,5 m), corona de cinco puntas que emerge y grietas | 0,65 s |
| `hit` | Daño recibido | Estrella blanca con borde naranja por encima del cuerpo y chispas | 0,3 s |
| `shield` | Golpe bloqueado por protección | Burbuja translúcida breve (la única transparencia) | 0,35 s |
| `impact_cover` | Proyectil contra cobertura | Estallido ámbar y chispas en el punto de choque | 0,25 s |
| `elimination` | Eliminación | Columna blanca, anillo y esquirlas con el color del héroe | 0,7 s |

Los alias heredados `sprint` y `charge` siguen funcionando. Las formas y los
colores combinan con los héroes (`docs/arte/HEROES.md`): Turbo eléctrico
amarillo, azul y rojo; Rey dorado, ámbar y violeta.

## Corrección tras la revisión técnica: visibilidad del núcleo del proyectil

En la revisión del PR #11 se detectó que el halo azul de `ProjectileVisual` envolvía
y ocultaba el núcleo amarillo, sobre todo en la súper. Causas:

- El halo era una esfera opaca 1,25 veces más grande que el núcleo y casi concéntrica.
- Los anillos giraban en un plano vertical, así que su arco superior cruzaba el
  núcleo como una franja.
- El pulso del núcleo lo encogía hasta un 12 %.

Corrección, solo visual:

- El halo ahora mide 0,62 veces el núcleo y va detrás de él (a 1,35 radios).
- Los anillos giran en horizontal con radio de 1,75 y 2,1 núcleos, por fuera de la
  silueta del núcleo vista desde la cámara inclinada.
- El pulso solo agranda el núcleo (entre ×1,00 y ×1,08), así que nunca se ve menor
  que el radio del collider.

`projectile.gd` no cambia: collider, velocidad, daño y alcance quedan intactos.

Verificación medible `art/lib/check_projectile_core.gd`: dispara desde la arena A,
proyecta el centro del proyectil a la cámara de juego y cuenta los píxeles con color
de núcleo dentro del 85 % de su disco proyectado. Exige al menos un 75 %.

| Caso | Antes | Después (Mobile) | Después (Compatibility) |
|---|---|---|---|
| Básico, ALTO | 50 % (FALLA) | 100 % | 100 % |
| Súper, ALTO | **0 %** (FALLA) | 100 % | 100 % |
| Básico, BAJO | 36 % (FALLA) | 100 % | 100 % |
| Súper, BAJO | **0 %** (FALLA) | 100 % | 100 % |

Capturas: [antes y después, recortes ×4](../captures/vfx-v1/proyectil-antes-despues.png) ·
arena completa con [básico ALTO](../captures/vfx-v1/mobile-arena-proyectil-basico-alto.png),
[súper ALTO](../captures/vfx-v1/mobile-arena-proyectil-super-alto.png) y
[súper BAJO](../captures/vfx-v1/mobile-arena-proyectil-super-bajo.png).

```bash
xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --audio-driver Dummy --fixed-fps 60 \
  --script ../art/lib/check_projectile_core.gd -- --output=/tmp/nucleo [--low]
```

## Efectos preparados para el Príncipe #20 (sin gameplay todavía)

Según `docs/PRINCIPE_KIT.md` (propuesta pendiente de aprobación). Codex los llamará
al implementar `codex/principe-gameplay`; hoy no se usan en partida.

| `kind` | Uso | Lectura visual |
|---|---|---|
| `principe_shot` | Pulso Certero | Destello rojo y claro, estrecho, por encima del cuerpo |
| proyectil | Vuelo del básico | Núcleo claro visible, halo rojo menor detrás, retícula fina y estela **recta** |
| `principe_buff` | Impulso Táctico | Anillo rojo, chevrones que suben a los costados y texto **«PODER +20 %»**; sigue al héroe |
| `principe_field_warning` | Aviso de 0,6 s | Contorno del radio real, anillo que se cierra como cuenta atrás, marcador central y flechas hacia adentro |
| `principe_field` | Campo de Dominio, 3 s | Pulso hasta el radio, zona opaca a ras de suelo y marcas de lentitud que giran |

Contrato para Codex:
- Los campos se colocan en el **centro del área**, no en el actor (por ejemplo,
  con `spawn_effect_at`). Hay que pasar `radius` (3 m) y `duration` (0,6 s y 3 s).
- La mejora usa `follow` y puede recibir `duration`.
- `ProjectileVisual` elige el estilo según el `definition.id` de quien dispara y
  toma el tamaño del radio real del collider, sin valores fijos de Turbo.

Captura: [ficha del Príncipe](../captures/vfx-v1/mobile-01b-efectos-principe.png).

## Presupuesto y perfiles

- Sin luces dinámicas, sombras ni texturas. Materiales sin iluminación, compartidos
  y opacos. El desvanecimiento se hace con escala, salvo la burbuja de escudo.
- Chispas con `CPUParticles3D` (mismo comportamiento en Mobile y Compatibility).
- **Perfil BAJO** (`GraphicsSettings.low`): un tercio de las partículas, sin rayos
  animados ni grietas, y estela del proyectil sin parpadeo.

Draw calls medidos con `RenderingServer` (conteo, no tiempo; CPU sin GPU real):

| Escena | Forward Mobile (lavapipe) | Compatibility (llvmpipe) | Mobile, perfil BAJO |
|---|---|---|---|
| Arena A en reposo | 127 | 258 | 127 |
| + disparo en vuelo | 135 | 266 | 133 |
| + Dominio Real | 160 | 296 | 152 |
| Ficha aislada más cara (`turbo_super`) | 29 | 41 | 10 |

**No acreditan FPS ni rendimiento Android.** Falta medirlo en teléfonos reales.

## Evidencia (Godot 4.7.2, Xvfb 1280×720, `--fixed-fps 60`)

- [Ficha de los diez efectos, Mobile](../captures/vfx-v1/mobile-01-efectos.png) · [perfil BAJO](../captures/vfx-v1/mobile-05-efectos-perfil-bajo.png) · [Compatibility](../captures/vfx-v1/compat-01-efectos.png)
- Arena A: [disparo en vuelo](../captures/vfx-v1/mobile-02-arena-disparo.png) · [súper Turbo](../captures/vfx-v1/mobile-03-arena-super-turbo.png) · [súper Rey con su radio real](../captures/vfx-v1/mobile-04-arena-super-rey.png) · [súper Turbo en Compatibility](../captures/vfx-v1/compat-03-arena-super-turbo.png)

```bash
xvfb-run -a -s "-screen 0 1280x720x24" godot --path game --audio-driver Dummy --fixed-fps 60 \
  --script ../art/lib/capture_vfx.gd -- --output=/tmp/vfx [--low]
python3 tools/verify.py --godot godot --pack   # 192/192 con los VFX activos
```

## Prueba de exportación Android (APK debug)

Resultado del 2026-10-30, en el entorno cloud y sin teléfono:

- **Se generó un APK debug** con Godot 4.7.2 y sus export templates oficiales. Pesa
  58 MB, está firmado con esquemas v2/v3 usando una clave de depuración local (no
  versionada) y `apksigner verify` lo valida. Paquete `cl.openweb.arenaidolos.prototype`,
  minSdk 24 (Android 7.0), targetSdk 36. Incluye los cuatro modelos y los VFX.
- SDK: el SDK de Google no era accesible desde la red, así que se usaron los
  paquetes de Ubuntu (`android-sdk`, build-tools 29.0.3) y OpenJDK 21. Godot avisa
  que esos build-tools no coinciden con el target SDK; aun así firmó el APK.
- **Bloqueo en el repo:** la exportación falla mientras `project.godot` no active
  `rendering/textures/vram_compression/import_etc2_astc=true`. El APK de prueba se
  generó desde una copia temporal con ese ajuste; el repo no se modificó porque
  `project.godot` es de Codex.
- Aviso: no hay ícono de proyecto. Se ofrece `game/assets/ui/icono_provisional.png`
  para que Codex lo enlace en `application/config/icon`.

### Por qué todavía no sirve para jugar en el celular

1. **No hay controles táctiles** (hito P3 de Codex): la partida necesita teclado y mouse.
2. `pointing/emulate_mouse_from_touch=false`: los toques ni siquiera activan los
   botones del menú, así que el APK abre pero se queda en el menú.
3. Nada de esto se probó en un teléfono: ni instalación, ni renderizador Mobile en
   GPU real, ni rendimiento.

### Handoff a Codex para el primer APK jugable

1. Activar `import_etc2_astc` y enlazar el ícono (`project.godot`).
2. Adaptador táctil (P3): stick de movimiento, AUTO/manual, ataque, habilidad y súper.
3. Revisar `emulate_mouse_from_touch` o hacer que la UI reciba toques.
4. Decidir el renderizador por defecto o el respaldo a Compatibility (pantalla
   negra en el PC del propietario con Vulkan). Con eso, exportar el APK debug y
   probarlo en el teléfono del propietario.
