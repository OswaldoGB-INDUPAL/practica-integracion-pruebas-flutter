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
