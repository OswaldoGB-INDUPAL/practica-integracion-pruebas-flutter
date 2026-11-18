# Compilación firmada para Android

La versión de publicación requiere `android/app/google-services.json` del proyecto Firebase registrado para el identificador `com.example.practica_integracion_pruebas_flutter` y una clave de firma privada. La clave y su contraseña no deben subirse al repositorio. Conserva una copia segura: las actualizaciones necesitan la misma clave.

En PowerShell, configura las variables en la sesión con las rutas correspondientes y compila:

```powershell
$env:MIS_TAREAS_KEYSTORE = 'C:\ruta\privada\mis-tareas-release.jks'
$env:MIS_TAREAS_KEY_PASSWORD = Read-Host 'Contraseña de firma'
flutter build apk --release
flutter build appbundle --release
Remove-Item Env:MIS_TAREAS_KEY_PASSWORD
```

El APK sirve para instalación directa y el AAB para preparar una distribución en Google Play. La publicación en Play requiere una cuenta de desarrollador y cumplir los requisitos vigentes de Google; generar el AAB no publica la aplicación. Android no permite actualizar una instalación firmada con otra clave, como la versión de depuración.
