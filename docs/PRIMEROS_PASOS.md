# Guía para mañana: primeros 60 minutos
1. Descarga el ZIP e inspecciona README y ROADMAP.
2. En GitHub crea repositorio **privado** `arena-de-idolos` sin plantilla si subirás los archivos localmente.
3. En Windows descomprime ZIP y abre esa carpeta con VS Code.
4. Ejecuta: `git init`, `git add .`, `git commit -m "docs: preproduccion inicial"`, `git branch -M main`, `git remote add origin https://github.com/TU_USUARIO/arena-de-idolos.git`, `git push -u origin main`. Alternativa: subir archivos desde interfaz web de GitHub.
5. Crea proyecto tipo Kanban (Backlog/En progreso/Pruebas/Completado); carga las 12 tareas de ROADMAP como issues.
6. Descarga Godot desde sitio oficial. Crea proyecto 2D en subcarpeta `game/` y guarda escena `arena.tscn`.
7. Primer commit de código: mover círculo/personaje con WASD en mapa vacío. No instalar Supabase ni iniciar login aún.
8. En la siguiente sesión implementar balón y primera portería.

**Mensaje para asistente de programación:**
> Eres líder técnico Godot 4.7.2/GDScript. Lee README.md, docs/GDD.md, docs/MECANICAS.md, docs/ROADMAP.md y docs/ARQUITECTURA.md. Implementa solo M1 con escenas y scripts claros, código ejecutable, commits pequeños y pruebas. Elige placeholder art original y evita toda marca/personaje/asset protegido. Empieza por inicializar `game/project.godot`, una escena `arena.tscn`, jugador con CharacterBody2D y balón. Documenta controles y pasos de ejecución. No afirmar que 3v3 online funciona hasta que haya pruebas reales.
