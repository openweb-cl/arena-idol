# Decisiones vigentes — combate arcade 3D

## Corrección prioritaria aprobada durante el desarrollo

Esta decisión es posterior y prevalece sobre la orientación deportiva y el
vertical slice 2D de v0.4. **Arena de Ídolos es combate arcade 3D estilizado; no es
un simulador de fútbol ni un juego deportivo tradicional.** El universo del
fútbol chileno aporta inspiración conceptual, sin licencias ni identidades reales.

- Primera prioridad: **Batalla de Ídolos**, combate por eliminaciones. Objetivo de
  modo 3v3; primera demo técnica local de un jugador contra un bot.
- Movimiento libre en XZ, cámara superior inclinada, apuntado independiente,
  pelotazos de combate, golpes caricaturescos, esquiva, cobertura, vida, daño,
  eliminación temporal, reaparición, habilidades y súper.
- El balón no es centro obligatorio. No hay porterías, posesión o goles en la
  visión vigente; tampoco pases. Un proyectil con forma de balón es un ataque.
- Godot 4 estable, GDScript, 3D real. Mobile por defecto, Compatibility evaluable
  para hardware menos potente. Android es objetivo; PC permite desarrollo.
- Meta artística: 3D caricaturesco comercial. Recursos geométricos iniciales se
  identifican como provisionales; no equivalen a arte final ni validación de FPS.
- Meta de rendimiento: 60 FPS en dispositivos compatibles, con perfiles escalables;
  requiere mediciones Android reales, no extrapolación de cloud.

## Plantel e identidad conservados

### Aclaración prioritaria del propietario — 30 octubre 2026

Todos los personajes tienen ataques básicos ofensivos. Daño, tanque, asistente/
apoyo y controlador son roles de batalla: el apoyo también combate, y puede
potenciar daño/poder, proteger o facilitar movimientos aliados. Especiales y
súpers pueden desplazar enemigos, controlar zonas o modificar temporalmente la
arena/cobertura, con señales claras y respuesta para el rival. Cada poder necesita
su ficha; estos ejemplos no significan sistemas ya implementados o kits aprobados.

El roster conserva personajes y conceptos, pero sus antiguos «pases», «goles» y
roles deportivos no son requisitos jugables. Esta aclaración prevalece también
sobre la primera propuesta del Príncipe: su ficha debe definir ataques, apoyo y
control de arena, no acciones futbolísticas.

Se conserva el plantel conceptual canónico de 16 en `ROSTER_CANONICO_V0_4.md`.
Primeros: El Turbo #11 (proyectiles eléctricos, velocidad, remate especial) y
El Rey #23 (corto alcance, Embestida Real y onda de choque). Los kits de combate
actuales prevalecen sobre nombres/ataques deportivos de tablas anteriores.
Clubes y futbolistas del roster son referencias internas; no van al runtime.
Nombres provisionales no implican aprobación comercial ni disponibilidad de marca.
Sin logos, uniformes, rostros, voces, tatuajes o parecidos reconocibles sin permiso.

## Modos y alcance vigente

1. Batalla de Ídolos: combate 3v3 por eliminaciones.
2. Balón de Gloria: antecedente de modo con objetivo, pendiente de redefinir bajo
   la aclaración de combate; no implementar la antigua descripción deportiva.
3. Rey de la Arena: control territorial.
4. Último Ídolo: supervivencia individual.
5. Duelo de Leyendas: combate 1v1.

## Producción y alcance

Codex: arquitectura, reglas, física, movimiento, IA, combate, futura red y
optimización. Claude Code: arte, modelos, animaciones, materiales, VFX y apoyo UI.
Ramas y PR independientes, sin edición simultánea de los mismos archivos;
`CONTRATO_ARTE_3D.md` y `COORDINACION_AGENTES.md` definen interfaces y propiedad.
No desarrollar en main ni fusionar sin aprobación explícita del propietario.

Herramientas gratuitas, sin servicios de pago ni backend en este hito. No copiar
código, UI, recursos o personajes de juegos comerciales. Red competitiva posterior
con servidor autoritativo; no afirmar que existe multijugador en la demo local.
Monetización futura solo cosmética; revisión legal y de menores antes de beta.
