# Claude Code — Arena de Ídolos

## Leer primero y prioridad

Leer `docs/DECISIONES_Y_ALCANCE.md`, `docs/GDD.md`, `docs/MECANICAS.md`,
`docs/ARQUITECTURA.md`, `docs/ROSTER_CANONICO_V0_4.md`, `docs/ESTILO_3D.md`,
`docs/CONTRATO_ARTE_3D.md`, `docs/COORDINACION_AGENTES.md` y documentos legales.
La corrección más reciente manda: **combate arcade 3D, no simulador de fútbol**.
Batalla de Ídolos es prioridad; sin goles, porterías, posesión ni pases. Los
proyectiles pueden tener forma de balón, pero causan daño en combate.
Plantel canónico v0.4 de 16 se conserva; Turbo #11 y Rey #23 son los iniciales.

Aclaración del propietario (30 octubre 2026): todos los héroes atacan con un básico,
incluso los asistentes/apoyos. Diferenciar daño, resistencia, movilidad, mejoras
de poder, protección y control de zonas/desplazamientos. Los especiales pueden
ayudar aliados o alterar la arena. Mostrarlo en VFX y animación sin introducir
lógica de daño en el arte. El clip `kick` es una animación de ataque; no implica
una mecánica de pase. Los nombres deportivos del roster histórico no fijan kits.

## Responsabilidad y coordinación

Claude Code: herramientas de producción artística, Blender/GLB, modelos,
animaciones, materiales, VFX y apoyo UI. Codex: arquitectura y gameplay,
movimiento/física, combate, IA, futura red y optimización. No editar archivos
simultáneamente. Antes de tocar scripts técnicos o UI compartida, acordar un
handoff en el issue/PR. Propiedad detallada en COORDINACION_AGENTES.

Nunca trabajar en main. Actualizar main remoto y crear rama `claude/<hito>`.
Hitos pequeños, commits, pruebas y PR a main; no fusionar sin aprobación explícita.
No rebase, reset o force-push sobre ramas ajenas. Cada tarea cloud ya está aislada;
no crear worktrees salvo petición del propietario.

## Reglas permanentes

Godot 4 estable/GDScript/3D real, cámara superior inclinada, Android primero.
Blender gratuito, GLB exportado explícitamente; Godot no debe necesitar Blender
para abrir el proyecto. Materiales escalables Mobile/Compatibility, objetivo 60
FPS sujeto a hardware real. Parámetros en Resources; cumplir contrato de escala,
pivote, frente, clips y sockets. Placeholder marcado como tal, nunca arte final.

UI y comunicación en español. Modelos, código, recursos, escenarios y poderes
originales. No copiar recursos de Brawl Stars. No incorporar nombres/rostros/
escudos/kits de clubes ni personas reales sin permisos; cambiar nombre no elimina
riesgos. Referencias internas y mockups no se importan al build. Nombres actuales
son provisionales, no autorización comercial. Mantener manifest de assets/licencias.

Herramientas gratuitas, sin servicios de pago ni backend antes del hito aprobado.
No subir secretos, credenciales o keystores. No declarar pruebas, calidad comercial,
60 FPS, Android o multijugador sin evidencia. Reportar versión y comandos reales,
capturas de build, costes de render e incidencias; conservar límites explícitos.
