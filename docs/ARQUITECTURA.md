# Arquitectura técnica v0.1
## Motor
Godot 4.7.2 estable, GDScript y pipeline 2D. La imagen generada es referencia de estilo; priorizar sombras, luces y sprites para look 2.5D sin exigir 3D complejo. Evitar dependencias de pago al inicio.

## Carpetas futuras del juego
```
game/
  project.godot
  scenes/{boot,menu,arena,actors,ball,ui}/
  scripts/{core,actors,combat,ball,modes,net}/
  assets/{sprites,sfx,music,fonts,tiles}/
  data/{characters,maps,balance}/
  tests/
```
Se crean estas carpetas al iniciar la implementación en Godot; el paquete actual es preproducción, no proyecto Godot ejecutable.

## Orden de subsistemas
1 input -> movimiento -> cámara -> colisión -> balón -> arco/gol -> HUD -> bot -> habilidades -> menús -> telemetría -> red -> matchmaking.

## Multijugador
Fase local offline (un jugador + bots); después prototipo online 1v1 con servidor autoritativo. El salto a 3v3 requiere reconciliación, interpolación, validación de goles, desconexiones, emparejamiento y pruebas de latencia desde regiones chilenas. **GitHub Pages no aloja servidores de partidas.**

## Backend
No instalar backend hasta tener vertical slice. Para cuentas/clasificación evaluar Supabase Free únicamente después de revisar límites y políticas vigentes. No alojar claves con permisos de servidor dentro del cliente. Puntuación solo la firma el servidor.

## Entornos
PC Windows como estación de desarrollo; export Android para pruebas táctiles; web como demo secundaria previa validación de soporte y rendimiento. CI con GitHub Actions solo cuando proyecto exportable.

## Privacidad y seguridad
Nombre público distinto al dato real, sin geolocalización precisa, chat cerrado al principio, bloquear/reportar cuando exista interacción social; protección especial a menores. Logs minimizados y política privacidad.
