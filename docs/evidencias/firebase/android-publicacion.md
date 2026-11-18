# Evidencia de compilación firmada

Fecha: 18 de noviembre de 2026. Se generaron APK y AAB de la versión 1.0.0 con la configuración del proyecto Firebase del alumno y una clave de publicación privada. `apksigner verify` verificó la firma APK v2; `jarsigner -verify` verificó la firma del AAB. El APK se instaló y abrió en un emulador Android 15 y mostró la pantalla de acceso.

La firma usa un certificado autofirmado, habitual para distribución Android. No se ha verificado la recepción de notificaciones FCM ni el flujo completo de la interfaz Android contra Firebase alojado. La clave privada no se incluye en el repositorio.
