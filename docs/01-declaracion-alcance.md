# Declaración de alcance

| Módulo / servicio | ¿Aplica? | Observación |
|---|---|---|
| Autenticación | ☑ | Firebase Auth con correo y contraseña. |
| Base de datos | ☑ | Cloud Firestore, tareas por usuario. |
| Almacenamiento | ☐ | No se adjuntan archivos. |
| Notificaciones push | ☑ | Firebase Cloud Messaging en Android. |
| API REST externa | ☐ | No hay API externa. |
| Otros | ☐ | No se incluyen servicios adicionales. |

La verificación de ejecución en Android, el acceso real a Firebase y las capturas requieren configuración y dispositivo; siguen pendientes hasta realizarse. Plataforma prevista: Android API 33 o superior.

Pantallas previstas: acceso y registro, lista, formulario y detalle.

## Estado mínimo

- ☐ Compilación y ejecución en Android: pendiente de SDK, configuración Firebase y dispositivo.
- ☑ Cuatro pantallas implementadas.
- ☑ Auth y Firestore integrados en código; conexión real pendiente.
- ☑ Repositorio Git local con rama `semana16-integracion`; publicación pendiente.
