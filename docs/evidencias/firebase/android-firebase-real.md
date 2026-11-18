# Prueba Android con Firebase alojado y FCM

Fecha: 18 de noviembre de 2026. En un emulador Android 15 con Google APIs se ejecutó una prueba Flutter de integración con la compilación de depuración y el proyecto Firebase real `mis-tareas-semana-16`.

Resultado: **1 prueba aprobada**. La interfaz inició sesión con una cuenta temporal, creó una tarea, la editó y la eliminó; las comprobaciones consultaron Firestore alojado. La aplicación registró un token FCM, el envío mediante la API HTTP v1 devolvió 200 y la notificación apareció en primer plano. La tarea, el documento de usuario, el token y la cuenta temporal se eliminaron al finalizar.

El APK firmado de publicación se instaló y abrió por separado. Esta prueba FCM no cubre recepción en segundo plano o con la aplicación cerrada, ni demuestra la limpieza automática del token en todos los escenarios de desconexión o caducidad de sesión (INC-006).
