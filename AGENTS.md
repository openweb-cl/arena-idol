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
  apuntados, proyectiles, melee, vida/daño, eliminación y respawn; balón opcional
  de un modo futuro. Esta decisión prevalece sobre documentos deportivos previos.
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
