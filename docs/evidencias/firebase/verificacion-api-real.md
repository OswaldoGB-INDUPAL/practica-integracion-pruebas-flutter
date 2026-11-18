# Verificación de Firebase alojado

Fecha: 18 de noviembre de 2026.
Proyecto: `mis-tareas-semana-16`, plan Spark. Firestore se creó en `us-central1` y se publicaron las reglas del repositorio. Authentication quedó habilitado con correo y contraseña.

Se probaron las API reales con una cuenta temporal: registro (200), creación de tarea (200), lectura (200), eliminación de tarea (200), rechazo de lectura sin sesión (403) y eliminación de la cuenta temporal (200). La tarea y la cuenta se eliminaron al terminar. Esta comprobación no ejecuta la interfaz de la aplicación ni valida notificaciones FCM o funcionamiento en Android.
