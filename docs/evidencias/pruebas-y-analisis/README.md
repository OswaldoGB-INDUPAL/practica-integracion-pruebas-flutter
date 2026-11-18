# Evidencias

Archivos previstos o generados:

- `flutter-analyze-inicial.txt`
- `flutter-analyze-final.txt`
- `flutter-test.txt`
- `flutter-test-regresion-INC-001.txt`
- `flutter-test-inicial-INC-003.txt`

Las imágenes y el video se agregan después de ejecutarlos; no son evidencia hasta que existan.

Otros registros reales: `flutter-test-inicial-INC-001.txt`, `flutter-test-inicial-INC-003.txt`, `flutter-test-flujo-fake.txt` y `flutter-integration-windows.txt`. El intento Windows falló por falta de permiso para enlaces simbólicos.

El segundo intento quedó registrado completo en `flutter-integration-windows-segundo-intento.txt`: compilación Windows exitosa, ejecución bloqueada por la política de seguridad del equipo.

`firestore-rules-test.txt` contiene la ejecución real de cuatro pruebas contra el emulador de Firestore, sin proyecto ni datos reales.

Las salidas `flutter-test-inicial-INC-006.txt` y `flutter-test-regresion-INC-006.txt` documentan la prueba de orden y tolerancia a fallos del cierre, no una validación real de FCM.

Las salidas `flutter-test-caducidad-inicial.txt` y `flutter-test-caducidad-regresion.txt` muestran la regresión de coordinación simulada al cambiar la sesión; no comprueban FCM real.

`flutter-test-token-firestore-fake.txt` muestra tres pruebas de borrado selectivo con Firestore simulado; no prueba FCM ni condiciones reales de red.

`flutter-integration-web-inicial.txt` registra el fallo de compilación inicial y `flutter-integration-web-final.txt` la ejecución exitosa en Edge con fakes; los tokens locales efímeros se ocultaron. `flutter-build-apk-intento.txt` registra que falta Android SDK.

`flutter-integration-firebase-emuladores.txt` registra el flujo en Edge con los repositorios Firebase y emuladores locales; los tokens efímeros del depurador están ocultos. No comprueba FCM ni Firebase alojado.

`flutter-integration-firebase-reingreso.txt` registra el flujo ampliado con credenciales inválidas, reingreso válido y reconstrucción de interfaz. No demuestra reinicio de proceso ni Firebase alojado.
