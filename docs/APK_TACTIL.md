# APK táctil debug — reporte de tarea A

Fecha: 30 octubre 2026 (America/Santiago). Rama `codex/touch-controls`.
Código exportado: **`8d1102664645215724e3fecfcdb231689987d58e`**, basado en
`0bb326e` (main con #11 fusionado). Los commits posteriores de esta entrega
solo añaden documentación/capturas, sin alterar el código empaquetado.

## Artefacto generado

- Archivo: `builds/arena-idolos-debug.apk`, **59,422,455 bytes**
  (56.67 MiB). Ignorado por Git; no viene en un pull.
- SHA-256: `ef6080bd841d7a35dae865f47668d4d75a53fd5c9d388a136d936ba64b0aaa1a`.
- Paquete: `cl.openweb.arenaidolos.prototype`, versión 0.1.0, código 1.
- APK debug: `android:debuggable=true`. Firma v2 y v3 verificadas.
- Android mínimo API 24 (7.0), target/compile API 36.
- Bibliotecas ARMv7 (`armeabi-v7a`) y ARM64 (`arm64-v8a`).
- Landscape, ícono provisional enlazado. Sin permiso de Internet.
- Godot Mobile en Android; override Windows Compatibility conservado.

Godot **4.7.2 estable oficial**, template Android de esa misma versión. Archivo
oficial de templates validado con SHA512; command-line tools de Google validadas
contra su checksum oficial. OpenJDK 21, SDK Platform 36, Build Tools 36.0.0 y
Platform Tools de Google. No se usó la copia temporal alterada del primer APK
experimental de Claude: ETC2/ASTC y controles están en esta rama.

## Verificación realizada

- `python3 tools/verify.py --godot /ruta/Godot_4.7.2 --pack`: **243/243**, sin errores;
  importación/parseo, PCK y arranque de todas las escenas, incluida arena táctil.
- Exportación debug Android completada con código cero y verificación del exportador.
- `apksigner verify --verbose`: firma v2/v3 válida; `zipalign -c -P 16 4`: aprobado.
- `aapt2 dump badging` y `apkanalyzer manifest`: paquete, SDK, ABIs, launcher y
  `debuggable` comprobados. Ícono normal referenciado por el manifest y XML presente.
- ZIP revisado: sin keystore, credenciales de exportación o documentos de raíz.
- Capturas del adaptador revisadas en Compatibility/OpenGL llvmpipe sobre Xorg.
  Son PC con entradas simuladas, no capturas Android.

Observaciones del entorno: el sondeo ADB automático del editor no puede crear
su directorio en el home de solo lectura del cloud; no hubo instalación en un
teléfono. Esto sucede después de firmar/verificar; el APK fue comprobado además
con las herramientas independientes anteriores. `aapt2` avisa de una entrada
`themed_icon` del template sin archivo: no la referencia el ícono normal del
manifest, que sí está incluido. No se da por validado el launcher real sin probarlo.

## Entrega e instalación

La clave de depuración queda fuera del repo. No se suben SDK, templates,
credenciales, keystores ni APK al historial Git. El archivo queda en el workspace
como artefacto descargable de esta entrega; para otro entorno se puede reexportar
con la [guía Android](ANDROID.md). El hash identifica este APK: una nueva firma/
exportación puede generar otro hash.

```sh
adb devices
adb install -r builds/arena-idolos-debug.apk
```

Alternativa: copiar al teléfono e instalar desde Archivos. Abrir desde el ícono.
[Controles, casos de prueba e instrucciones completas](ANDROID.md).

## Pendientes que requieren teléfono

- [ ] Instalar y abrir en el modelo/Android del propietario.
- [ ] Comprobar GPU/Mobile, menú, multitáctil real, safe areas y latencia.
- [ ] Jugar con Turbo/Rey en A/B, recarga, protección, pausa, background y revancha.
- [ ] Medir FPS/frame times/temperatura en hardware; no afirmar 60 FPS todavía.

Tarea B del Príncipe permanece pendiente de A y de aprobación explícita de
`PRINCIPE_KIT.md`. Ningún merge automático.
