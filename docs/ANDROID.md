# Android — preparación y validación pendiente

Proyecto landscape, Godot 4.6.3/GDScript, renderizador Mobile por defecto,
perfiles ALTO/BAJO y preset Android inicial sin permiso de Internet. No hay SDK,
APK firmado, controles táctiles ni teléfonos validados en esta entrega.
**La demo actual necesita teclado/ratón**; para playtest móvil primero se debe
implementar el adaptador táctil de comandos. Un preset no equivale a un APK probado.

## Exportar localmente (herramientas gratuitas)

1. Instalar Godot 4.6.3 estándar y sus export templates de la misma versión desde
   Editor → Manage Export Templates. No mezclar templates de otra versión.
2. Seguir [Exporting for Android, documentación Godot 4.6](https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html):
   OpenJDK 17, Android SDK y paquetes requeridos por esa versión del motor.
3. Configurar Java SDK Path / Android SDK Path en Editor Settings → Export →
   Android. Generar/seleccionar keystore de depuración local según la guía;
   nunca subir claves o `.godot/export_credentials.cfg`.
4. Project → Export → Android. Revisar identificador provisional
   `cl.openweb.arenaidolos.prototype`, arquitecturas ARM y nombre. Exportar **debug**
   a `builds/arena-idolos-debug.apk` (ignorado por Git). Sin export release/tienda.
5. Probar con `adb install -r builds/arena-idolos-debug.apk` en equipo propio. Para
   equipos sin Vulkan, cambiar proyecto a Compatibility y reexportar. Los perfiles
   del menú cambian sombras/VFX/escala, no cambian el renderizador en caliente.

No requiere Play Store ni hosting. No contratar servicios. Mantener TLS, firmas y
checksums de herramientas. Exportar solo la raíz `game/`, nunca datos internos.

## Gate antes de afirmar 60 FPS

Tres teléfonos acordados (gama baja/media/alta), resolución/aspecto y versión
Android registrados. Medir por separado Mobile y Compatibility soportados:
frame time p50/p95/p99, CPU/GPU, draw calls, triángulos, memoria, calentamiento y
batería, tras 10 minutos de combate. Meta inicial 60 FPS / 16,7 ms; perfil bajo
para reducir sombras/escala/VFX. Evaluar también seis actores antes de 3v3.
F3 informa contadores locales; fixed-fps/headless/cloud no certifica rendimiento.

Validar dos sticks multitáctiles, botones simultáneos, safe areas, pausa/background,
restauración, legibilidad de proyectiles y vida, y latencia táctil. Nada de esto
se declara aprobado sin hardware real y controles implementados.
