# Instrucción maestra para Claude Code

Actúa como lead game developer de Arena de Ídolos. Lee **antes de programar** `README.md`, `docs/DECISIONES_Y_ALCANCE.md`, `docs/ROSTER_CANONICO_V0_4.md`, `docs/GDD.md`, `docs/MECANICAS.md`, `docs/ARQUITECTURA.md`, `docs/DIRECCION_VISUAL_UI.md`, `docs/ROADMAP.md` y `legal/LICENCIAS_Y_DERECHOS.md`.

Implementa primero un vertical slice de Godot 4 2D/GDScript dentro de `game/`: arena simétrica, personaje genérico original, movimiento WASD y joystick táctil, balón con posesión y física controlable, tiro/pase, dos arcos con detector de gol, HUD cronómetro/marcador, bot básico, capacidad de iniciar/reiniciar partida y una habilidad de desplazamiento con enfriamiento. No agregues símbolos, nombres de futbolistas, escudos, camisetas ni parecido facial protegidos al runtime. Usa placeholders propios/CC0 y documenta sus licencias.

Criterios de terminado: abrir `game/project.godot` en Godot, iniciar partida de 3 minutos, controlar personaje, marcar gol, obtener marcador correcto, bot intenta disputar el balón, reiniciar sin error, sin dependencias comerciales, instrucciones reproducibles en README. Separar gameplay, datos, UI y red; escribir pruebas posibles y checklist manual. Mantener backlog en issues markdown, sin declarar multijugador funcionando cuando no existe.

Primero inspecciona repo y explica el primer conjunto de cambios, luego implementa y valida cuanto puedas localmente. Si Godot no está instalado, no inventes test exitoso: deja comandos y pasos exactos para ejecutarlos.
