# Android — primer APK debug con controles táctiles

Tarea A, rama `codex/touch-controls`, basada en main con PR #11 fusionado.
Godot **4.7.2 estándar/GDScript**. Exportación desde el repositorio con ETC2/ASTC
activado e ícono provisional. Prototipo local 1 contra bot, sin permiso de Internet,
compras o cuentas. No es una publicación en Play Store.

## Controles

- Stick izquierdo de movimiento. Mantener ATACAR en AUTO solicita disparos;
  AUTO apunta al rival libre más cercano, sin disparar por sí solo.
- Botón AUTO cambia a MANUAL: **arrastra ATACAR** para orientar y disparar;
  mantener la dirección repite respetando cargas/cadencia. El centro no dispara.
- HABILIDAD, SÚPER y PAUSA independientes, con dedos distintos.
- Menú, selección, pausa, revancha y regreso al menú responden a toques.
- Pausa/background, KO, resultado y resize cancelan contactos anteriores.
- Safe areas y botones grandes. Arte y UI siguen siendo provisionales.

Implementación y pruebas: [CONTROLES_TACTILES.md](CONTROLES_TACTILES.md).

## Instalar el APK entregado

Archivo generado: `builds/arena-idolos-debug.apk` en el workspace de esta entrega.
Los binarios no se versionan: hacer pull descarga código, no el APK. Descarga el
archivo entregado o expórtalo localmente. [Reporte de build](APK_TACTIL.md).

Instalación directa: copia el APK al teléfono, ábrelo desde Archivos y, si Android
lo solicita, autoriza instalar desde esa app. Abre «Arena de Ídolos». Requiere
Android **7.0/API 24 o superior**, CPU ARMv7/ARM64 y GPU compatible con el renderer.
Instalar no equivale a validar render ni rendimiento.

Por USB: activa depuración USB, conecta el teléfono y autoriza ese computador.
Desde la raíz del repo:

```sh
adb devices
adb install -r builds/arena-idolos-debug.apk
```

`adb devices` debe mostrar `device`; si aparece `unauthorized`, acepta en el
teléfono. Si sale `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, hay otra clave de firma:
reexporta con la misma clave o decide desinstalar la anterior. Desinstalar borra
informes/ajustes locales; nunca se hace automáticamente.

## Exportar localmente con herramientas gratuitas

1. Instala Godot **4.7.2 estándar** y sus export templates de la misma versión:
   Editor → Manage Export Templates. No mezcles versiones.
2. Instala OpenJDK y Android SDK según la
   [guía oficial de Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html).
   Cloud usó OpenJDK 21, SDK Platform 36, Build Tools 36.0.0 y Platform Tools
   oficiales. No se necesita Gradle custom ni Android Studio para jugar.
3. Configura Java SDK Path / Android SDK Path en Editor Settings → Export → Android.
   Genera/selecciona una clave de depuración local y consérvala para actualizar la
   app. No subas keystores, contraseñas o `.godot/export_credentials.cfg`.
4. Importa `game/project.godot` y espera. ETC2/ASTC e ícono ya están configurados.
5. Project → Export → Android → Export Project con **Export With Debug**.
   Guarda en `builds/arena-idolos-debug.apk` (fuera de `game/`, ignorado por Git).
   Identificador `cl.openweb.arenaidolos.prototype`; ARMv7 y ARM64.

Con SDK, Java y clave configurados, crea `builds/` y ejecuta desde la raíz:

```sh
godot --headless --path game --editor --import
godot --headless --path game --export-debug Android ../builds/arena-idolos-debug.apk
```

Sustituye `godot` por tu ejecutable. Exportar solo `game/` excluye referencias
privadas y fuentes Blender de la raíz. Sin servicios de pago ni publicación release.

## Primera prueba en teléfono pendiente

Firma/estructura verificadas; **no se certifican instalación, jugabilidad, latencia
multitáctil, safe areas ni FPS en un teléfono real** a partir de entradas de PC.

1. Anota modelo, versión Android y GPU si se conoce. Prueba menú y ambos héroes.
2. En A/B: mueve con un dedo, ataca con otro y usa habilidad/súper con un tercero.
3. Mantén ATACAR durante recarga y suelta fuera del botón: debe detenerse.
4. Alterna AUTO/MANUAL y comprueba dirección, impactos y cobertura.
5. Pausa, continúa, ve a background y vuelve: sin movimiento/disparo enganchado.
6. Completa KO/respawn y revancha. Revisa botones, vida/cargas y recortes de pantalla.

Android conserva **Mobile**; Windows su override **Compatibility**. Ante pantalla
negra/Vulkan incompatible en un teléfono, registrar equipo/log y evaluar una
variante Compatibility. No cambiar todos los Android desde un solo incidente.
BAJO/ALTO no cambia backend en caliente.

## Gate de rendimiento

Medir en tres teléfonos acordados (gama baja/media/alta), tras 10 minutos: frame
time p50/p95/p99, CPU/GPU, draw calls, memoria y calentamiento. Registrar hardware,
resolución y Android. Meta 60 FPS/16,7 ms, no garantía. Evaluar seis actores antes
de afirmar 3v3. Fixed-fps/headless/cloud o firma de APK no acreditan FPS.
