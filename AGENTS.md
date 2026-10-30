# Arena de Ídolos — instrucciones permanentes para Codex

- Leer completamente `CLAUDE.md`, `docs/DECISIONES_Y_ALCANCE.md`, `docs/ROSTER_CANONICO_V0_4.md`, `docs/GDD.md`, `docs/MECANICAS.md`, `docs/DIRECCION_VISUAL_UI.md`, `docs/ROADMAP.md`, `docs/ARQUITECTURA.md`, `docs/ESTILO_3D.md`, `docs/VERTICAL_SLICE_3D.md` y los documentos legales antes de modificar gameplay. Las decisiones v0.4 prevalecen.
- Idioma de comunicación y UI: español. Godot 4, GDScript, 3D real, renderizador Mobile con alternativa Compatibility, Android primero y PC para desarrollo.
- Nunca desarrollar en `main`. Actualizar `origin/main`, crear una rama `codex/<tarea>` y trabajar en hitos pequeños con commits verificables. Publicar la rama y abrir PR a `main`; nunca fusionar sin aprobación explícita del usuario.
- Cada tarea cloud ya está aislada: utilizar el checkout existente; no crear worktrees salvo petición explícita.
- Mantener gameplay, datos y UI separados. Extender el catálogo mediante Resources; preparar 16 plazas sin fingir que los personajes pendientes funcionan.
- Priorizar juego local y bots antes de backend, ranking o red. No incorporar servicios ni dependencias comerciales durante prototipado.
- Crear recursos originales o CC0 con procedencia comprobada en `game/assets/README.md`. Los mockups son referencias, nunca assets de runtime. Identificar modelos de entrenamiento como provisionales, no arte final. No afirmar 60 FPS ni calidad comercial sin mediciones en hardware objetivo. No incorporar nombres reales, rostros, clubes, escudos ni referencias internas al build. El Turbo 11 y El Rey 23 son nombres provisionales autorizados para este prototipo; no implican autorización comercial.
- No subir claves, credenciales, keystores ni datos privados. Mantener exportación del juego dentro de `game/`; no empaquetar `data/` de la raíz ni `design/`.
- Ejecutar importación headless y `game/tests/run_tests.gd` con Godot; comprobar arranque de escenas. Registrar resultados reales, limitaciones y versión del motor. No inventar pruebas visuales, Android ni multijugador.
- Mantener README, controles y checklist manual al día. No declarar completados los gates de playtest o hardware del ROADMAP sin evidencia.
