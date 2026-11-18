# Guía de evidencias manuales

1. Instala Flutter y Android Studio con Android SDK; crea un emulador API 33 o superior o conecta un Android. Ejecuta `flutter doctor` y acepta las licencias Android.
2. Crea un proyecto Firebase propio, habilita Auth por correo/contraseña, Firestore y Cloud Messaging. Instala Firebase CLI y FlutterFire CLI; inicia sesión y ejecuta `flutterfire configure` en la raíz. Añade el `google-services.json` generado en `android/app/` sin subirlo a Git. La app Android utiliza la configuración nativa; el archivo `lib/firebase_options.dart` generado permanece ignorado.
3. Ejecuta `firebase deploy --only firestore:rules` tras asociar el proyecto con Firebase CLI. Crea `prueba1@test.com` y `prueba2@test.com` con contraseñas de prueba. No uses información real.
4. Ejecuta `flutter pub get`, `flutter analyze`, `flutter test` y `flutter test integration_test/app_flow_test.dart -d <id-dispositivo>`. Guarda las salidas reales; completa las celdas pendientes de análisis y los resultados.
5. Ejecuta la app con `flutter run`. Captura inicio, acceso válido, pantallas y botón atrás como `capturas-aplicacion/CP-01-inicio.png`, `CP-02-login-valido.png`, `CP-05-pantallas.png` y `CP-06-atras.png`.
6. Crea «Comprar café», descripción «Dos libras»; verifica lista y consola. Guarda `capturas-aplicacion/CP-07-crear-tarea.png` y `firebase/CP-07-documento-creado.png`. Crea una segunda tarea y captura el orden en `capturas-aplicacion/CP-08-lista.png`.
7. Edita la tarea y captura `capturas-aplicacion/CP-09-editar-tarea.png` y `firebase/CP-09-documento-modificado.png`. Elimínala con confirmación y captura `capturas-aplicacion/CP-10-eliminar-tarea.png` y `firebase/CP-10-documento-eliminado.png`.
8. En el simulador de reglas Firestore, usa el UID del usuario A para intentar leer `users/<uid-B>/tasks/<id>`; comprueba la denegación y guarda `firebase/CP-11-regla-rechazo.png`.
9. Concede permiso de notificaciones; verifica el token guardado en `users/<uid>` y guarda `notificaciones-fcm/CP-14-token-oculto.png`. En Firebase Console → Messaging, crea un mensaje de prueba dirigido al token y añade datos personalizados `route=/detalle` e `id=<id-tarea>`. Comprueba primer plano, segundo plano y app cerrada; guarda `CP-15-primer-plano.png`, `CP-16-segundo-plano.png` y `CP-17-app-cerrada.png` en `notificaciones-fcm/` (o un video de máximo 2 minutos). Si la consola no permite combinar datos y prueba con token, usa un envío FCM HTTP v1 autorizado desde un entorno seguro.
10. Cierra sesión, reinicia la app y verifica persistencia, pila privada y flujo completo. Guarda `capturas-aplicacion/CP-18-cerrar-sesion.png`, `CP-19-persistencia.png`, `CP-20-flujo.png` y `flujo-principal.mp4` (máximo 2 minutos).
11. Para aprobar cada caso, confirma que coinciden resultados, no hay excepciones sin controlar, existe evidencia y se repite igual tras reiniciar. Completa «Resultado obtenido», «Estado» y «Reinicio» en `03-plantilla-pruebas.md` y recalcula el porcentaje.
12. Tapa tokens FCM, correos reales y claves API en todas las capturas. Agrega las evidencias y haz commit `docs: evidencias manuales y resultados de ejecución`.

Las rutas de captura anteriores son relativas a `docs/evidencias/`. No marques como aprobado un caso que no ejecutaste.

El intento de integración en Windows quedó registrado en `pruebas-y-analisis/flutter-integration-windows.txt`: se necesita activar el modo de desarrollador para permitir enlaces simbólicos. El mismo recorrido sí pasó como prueba de widget con fakes; aún falta ejecutarlo en dispositivo.

En un segundo intento se construyó correctamente la copia Windows usando enlaces de directorio en el espacio temporal, pero una política de control de aplicaciones bloqueó el ejecutable. El resultado completo está en `pruebas-y-analisis/flutter-integration-windows-segundo-intento.txt`; no constituye una prueba de integración aprobada.

## Repetir la integración en Edge con fakes

En una copia temporal del repositorio ejecuta `flutter create --platforms web .`. Descarga el EdgeDriver oficial que coincida con la versión de Edge. En terminales separadas inicia `msedgedriver --port=4444` y `node tools/edge_webdriver_proxy.cjs`. El adaptador local corrige las capacidades que Flutter 3.50 envía a EdgeDriver; escucha solo en `127.0.0.1:4445`. Después ejecuta:

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_flow_test.dart -d web-server --browser-name=edge --driver-port=4445 --headless
```

Al finalizar detén EdgeDriver y el adaptador. Este ensayo utiliza fakes y no sustituye Android, Firebase real ni las capturas. Los tokens efímeros de depuración deben ocultarse antes de compartir la salida.

## Repetir el flujo con Auth y Firestore emulados

Con Node.js y Java 21, ejecuta `npm ci` en `rules_tests/`. Desde esa carpeta inicia `npx firebase --config ../firebase-emulators.json emulators:start --only auth,firestore --project demo-semana16`. Los emuladores escuchan únicamente en el equipo local, en los puertos 9099 y 8094; la prueba usa `10.0.2.2` para llegar al host desde el emulador Android y `127.0.0.1` desde web; en web usa una configuración ficticia; en Android utiliza la configuración local de la aplicación, pero dirige Authentication y Firestore a los emuladores.

En una copia temporal con plataforma web, inicia EdgeDriver y el adaptador como en la sección anterior y ejecuta:

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/firebase_emulator_flow_test.dart -d web-server --browser-name=edge --driver-port=4445 --headless
```

El test registra una cuenta `@test.com`, crea, edita y elimina una tarea, comprueba una lista ordenada de tres tareas, prueba contraseña incorrecta, reingresa y comprueba la tarea tras reconstruir la interfaz. Detén emuladores y controladores al finalizar. Esta prueba no envía notificaciones ni sustituye Firebase alojado o Android. Para `flutter test integration_test`, inicia primero estos emuladores, ya que la carpeta incluye el escenario que los requiere.
