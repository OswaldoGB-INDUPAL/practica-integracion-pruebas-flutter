# Prueba de integración en Android

Fecha: 18 de noviembre de 2026. Dispositivo virtual Android 15, API 35, x86_64, Google APIs. El APK de depuración con la configuración local de Firebase compiló, se instaló y abrió la pantalla de acceso; se guardó `../capturas-aplicacion/android-inicio.png`.

`flutter test integration_test/firebase_emulator_flow_test.dart -d emulator-5554`: **1 prueba aprobada**. El flujo registró un usuario, creó, editó y eliminó tareas, comprobó el orden, la contraseña incorrecta y el reingreso, utilizando emuladores locales de Authentication y Firestore. La prueba no valida FCM ni el flujo de la interfaz conectado a Firebase alojado.

`flutter analyze`: sin observaciones. Para conectar Android a los emuladores se permite HTTP únicamente hacia `10.0.2.2` en la configuración de depuración.
