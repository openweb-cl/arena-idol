# Arena de Ídolos — instrucciones permanentes para Codex

- Leer completamente `CLAUDE.md`, `docs/DECISIONES_Y_ALCANCE.md`, `docs/ROSTER_CANONICO_V0_4.md`, `docs/GDD.md`, `docs/MECANICAS.md`, `docs/DIRECCION_VISUAL_UI.md`, `docs/ROADMAP.md`, `docs/ARQUITECTURA.md`, `docs/ESTILO_3D.md`, `docs/VERTICAL_SLICE_3D.md` y los documentos legales antes de modificar gameplay. La corrección vigente de combate 3D en DECISIONES_Y_ALCANCE prevalece; v0.4 conserva el plantel conceptual.
- Idioma de comunicación y UI: español. Godot 4, GDScript, 3D real, renderizador Mobile con alternativa Compatibility, Android primero y PC para desarrollo.
- Nunca desarrollar en `main`. Actualizar `origin/main`, crear una rama `codex/<tarea>` y trabajar en hitos pequeños con commits verificables. Publicar la rama y abrir PR a `main`; nunca fusionar sin aprobación explícita del usuario.
- Cada tarea cloud ya está aislada: utilizar el checkout existente; no crear worktrees salvo petición explícita.
- Mantener gameplay, datos y UI separados. Extender el catálogo mediante Resources; preparar 16 plazas sin fingir que los personajes pendientes funcionan.
- Priorizar juego local y bots antes de backend, ranking o red. No incorporar servicios ni dependencias comerciales durante prototipado.
- Crear recursos originales o CC0 con procedencia comprobada en `game/assets/README.md`. Los mockups son referencias, nunca assets de runtime. Identificar modelos de entrenamiento como provisionales, no arte final. No afirmar 60 FPS ni calidad comercial sin mediciones en hardware objetivo. No incorporar nombres reales, rostros, clubes, escudos ni referencias internas al build. El Turbo 11 y El Rey 23 son nombres provisionales autorizados para este prototipo; no implican autorización comercial.
- No subir claves, credenciales, keystores ni datos privados. Mantener exportación del juego dentro de `game/`; no empaquetar `data/` de la raíz ni `design/`.
- Ejecutar importación headless y `game/tests/run_tests.gd` con Godot; comprobar arranque de escenas. Registrar resultados reales, limitaciones y versión del motor. No inventar pruebas visuales, Android ni multijugador.
- Mantener README, controles y checklist manual al día. No declarar completados los gates de playtest o hardware del ROADMAP sin evidencia.

## Corrección prioritaria: combate arcade 3D

- El juego NO es un simulador de fútbol. Priorizar Batalla de Ídolos: ataques
  apuntados, proyectiles, melee, vida/daño, eliminación y respawn. Sin goles,
  porterías, posesión ni pases. Un proyectil con forma de balón sigue siendo
  un ataque de combate. Esta decisión prevalece sobre documentos deportivos previos.
- Aclaración más reciente del propietario (30 octubre 2026): todos los héroes,
  incluidos asistentes/apoyos, tienen un ataque básico que causa daño. Los roles
  se diferencian por daño, resistencia, movilidad, mejoras de poder, protección o
  control/desplazamiento en la arena. Sus especiales/súpers pueden ayudar aliados
  y alterar zonas o cobertura; requieren ficha y pruebas antes de implementarlos.
  No convertir el apoyo en pases de pelota ni importar nombres deportivos del
  roster histórico como especificación de gameplay. Mantener el plantel de 16.
- Primera demo técnica local 1 humano contra bot; 3v3 es meta posterior y no debe
  afirmarse implementado. Turbo #11 eléctrico a distancia; Rey #23 corto alcance,
  Embestida Real y Onda Real. Plantel v0.4 conservado.
- Leer también `docs/CONTRATO_ARTE_3D.md` y `docs/COORDINACION_AGENTES.md`.
- Codex: sistemas y pruebas. Claude Code: arte, integración GLB, animación,
  materiales, VFX y apoyo UI. No editar simultáneamente los mismos archivos;
  acordar handoff antes de cruzar propiedad. No actuar como si Claude hubiera
  revisado o producido algo sin su participación real.
- Rama de fundación: `codex/game-foundation`; corrección de apuntado: `codex/fix-projectile-aim`, desde `origin/main` actualizado.
  Exponer parámetros en Resources editables desde inspector, sin valores mágicos
  que obliguen al propietario a programar para balancear.

- Regresión de apuntado: ejecutar también `game/tests/test_projectiles.gd`. Cursor
  al torso y espacio vacío comparten altura con proyectil; no ocultar fallos con
  cambios de daño/vida. Evidencia vigente en docs/APUNTADO_Y_PROYECTILES.md.

- AUTO selecciona y apunta; el propietario inicia el disparo. No añadir fuego
  autónomo como valor por defecto. Ejecutar tests/test_auto_target.gd y conservar
  manual, cadencia, cobertura y señales de protección. APUNTADO_AUTOMATICO.md
  registra el alcance aprobado y evidencia.

## Dirección visual y continuidad — 31 octubre 2026 UTC

Leer `docs/CONTEXTO_DE_CONTINUIDAD.md`, `docs/plantel/README.md` y
`docs/plantel/VISUAL.md` antes de proponer nuevos personajes o pantallas.
El propietario eligió caricaturas deportivas como las primeras imágenes de
`design/referencias/propietario_2026-10-31/`; la última orienta composición UI,
no realismo de rostros. No cambiar la identidad en cada generación. Las nuevas
exploraciones no son diseños aprobados. Primero Turbo V2 (vistas y expresiones),
revisión del propietario, luego Blender/GLB refinado. Conservar historial V0/V1
y separar referencia, boceto, modelo provisional y candidato final por héroe.

Prioridad de la siguiente etapa: mejora visual en PC; pruebas de teléfono
aplazadas por el propietario, conservando preparación Android. Mantener 16
héroes y solo los dorsales 11/23/20/17 ya decididos. Las 14 fichas pendientes
son propuestas, no permiso para programarlas ni balance validado. Príncipe
requiere aprobar `docs/PRINCIPE_KIT.md`; Pitbull espera su prueba.
