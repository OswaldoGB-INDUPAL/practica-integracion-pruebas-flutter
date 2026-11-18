# Plantilla de pruebas

Las pruebas simuladas comprueban UI y lógica, no sustituyen Firebase ni Android. Reinicio y evidencia visual requieren ejecución manual.

| ID | Módulo | Flujo | Tipo | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Reinicio (mismo resultado) | Evidencia |
|---|---|---|---|---|---|---|---|---|---|---|
| CP-01 | Arranque | FC-01 | Positivo | Iniciar app | Firebase configurado | Lista o acceso sin errores | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/capturas-aplicacion/CP-01-inicio.png |
| CP-02 | Auth | FC-01 | Positivo | Inicio real | prueba1@test.com, contraseña de prueba | Lista del usuario autenticado | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/capturas-aplicacion/CP-02-login-valido.png |
| CP-03 | Auth | FC-01 | Negativo | Rechazo simulado | prueba1@test.com, incorrecta | Mensaje de credenciales inválidas | Mensaje de credenciales inválidas con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/widget/flows_test.dart |
| CP-04 | Validación | FC-02 | Negativo | Formulario vacío | título vacío | Mensaje sin escritura | Mensaje sin escritura con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/widget/task_page_test.dart |
| CP-05 | Navegación | FC-02 | Positivo | Recorrer pantallas | acceso, lista, formulario, detalle | Pantallas accesibles | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/capturas-aplicacion/CP-05-pantallas.png |
| CP-06 | Navegación | FC-02 | Positivo | Volver desde formulario | botón atrás | Lista visible | Lista visible con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/widget/flows_test.dart |
| CP-07 | Datos | FC-02 | Positivo | Crear en Firebase | Comprar café; Dos libras | Tarea visible y documento creado | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/firebase/CP-07-documento-creado.png |
| CP-08 | Datos | FC-02 | Positivo | Orden de lista | dos tareas con fechas distintas | Más reciente primero | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/capturas-aplicacion/CP-08-lista.png |
| CP-09 | Datos | FC-03 | Positivo | Actualizar en Firebase | Café → Comprar café | Documento y pantalla actualizados | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/firebase/CP-09-documento-modificado.png |
| CP-10 | Datos | FC-03 | Positivo | Eliminar en Firebase | tarea Comprar café | Desaparece tras confirmar | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/firebase/CP-10-documento-eliminado.png |
| CP-11 | Seguridad | FC-03 | Negativo | Rechazar datos ajenos | usuario A solicita tarea de B | Permiso denegado | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/firebase/CP-11-regla-rechazo.png |
| CP-12 | Estados | FC-02 | Negativo | Vacío y error simulado | lista vacía; error de lectura | Estado vacío y mensaje de error | Estado vacío y mensaje de error con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/widget/task_page_test.dart |
| CP-13 | Storage | FC-02 | Positivo | Subir archivo | archivo de ejemplo | Archivo visible | No aplica: la app no usa Storage. | No ejecutado | No aplica | No aplica |
| CP-14 | FCM | FC-04 | Positivo | Token generado y guardado | dispositivo Android autorizado | Token guardado para usuario | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/notificaciones-fcm/CP-14-token-oculto.png |
| CP-15 | FCM | FC-04 | Positivo | Mensaje en primer plano | route=/detalle, id de tarea | Aviso en pantalla | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/notificaciones-fcm/CP-15-primer-plano.png |
| CP-16 | FCM | FC-04 | Positivo | Abrir desde segundo plano | route=/detalle, id de tarea | Abre detalle | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/notificaciones-fcm/CP-16-segundo-plano.png |
| CP-17 | FCM | FC-04 | Positivo | Abrir desde app cerrada | route=/detalle, id de tarea | Abre detalle tras sesión | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/notificaciones-fcm/CP-17-app-cerrada.png |
| CP-18 | Sesión | FC-05 | Positivo | Cerrar sesión real | usuario autenticado | Acceso visible sin datos privados | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/capturas-aplicacion/CP-18-cerrar-sesion.png |
| CP-19 | Persistencia | FC-02 | Positivo | Reabrir app | tarea guardada previamente | Tarea sigue visible | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/capturas-aplicacion/CP-19-persistencia.png |
| CP-20 | Integración | FC-01/FC-02 | Positivo | Flujo completo en dispositivo | prueba1@test.com; Comprar café | Acceso, creación y cierre correctos | PENDIENTE — ejecutar en dispositivo/emulador. | Pendiente | Pendiente manual | evidencias/capturas-aplicacion/CP-20-flujo.png |
| CP-21 | Edición | FC-03 | Positivo | Guardar sin cambios con fake | Comprar café sin editar | Regresa sin escritura | Regresa sin escritura con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/widget/unchanged_test.dart |
| CP-22 | Validación | FC-02 | Negativo | Límites de título | vacío, espacios, 2 y 81 caracteres | Todos rechazados | Todos rechazados con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/unit/validators_test.dart |
| CP-23 | Validación | FC-02 | Positivo | Título válido | Comprar café | Validador devuelve null | Validador devuelve null con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/unit/validators_test.dart |
| CP-24 | Validación | FC-02 | Negativo | Descripción demasiado larga | 501 caracteres | Mensaje de límite | Mensaje de límite con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/unit/validators_test.dart |
| CP-25 | Modelo | FC-02 | Positivo | Conversión de modelo | Café, hecha, fecha UTC | Campos conservados en ida y vuelta | Campos conservados en ida y vuelta con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/unit/task_model_test.dart |
| CP-26 | Modelo | FC-02 | Negativo | Campos ausentes | mapa vacío | Texto vacío y hecha=false | Texto vacío y hecha=false con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/unit/task_model_test.dart |
| CP-27 | Sesión | FC-05 | Negativo | Caducidad con detalle abierto | usuario1 → sin sesión | Acceso visible; detalle privado ausente | Acceso visible; detalle privado ausente con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/widget/flows_test.dart |
| CP-28 | Eliminación | FC-03 | Negativo | Cancelar eliminación con fake | tarea Café; Cancelar | No se invoca eliminación | No se invoca eliminación con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/widget/flows_test.dart |
| CP-29 | Edición | FC-03 | Positivo | Editar con fake | Café → Comprar café | Se guarda el título y conserva el id | Se guarda el título y conserva el id con fake o prueba unitaria. | Aprobado | Pendiente manual | ../test/widget/flows_test.dart |
| CP-30 | Integración | FC-01/FC-02/FC-05 | Positivo | Flujo completo con fakes | prueba1@test.com; Comprar café | Acceso, creación y cierre correctos | Flujo completo aprobado con fakes en prueba de widget. | Aprobado | Pendiente manual | ../test/widget/full_flow_test.dart |

| CP-31 | FCM | FC-04 | Positivo | Abrir detalle simulado | route=/detalle, id=t1; usuario u1 | Se muestra Comprar café | El detalle se mostró con repositorio fake. | Aprobado | Pendiente manual | ../test/widget/notification_navigation_test.dart |
| CP-32 | FCM | FC-04 | Negativo | Rechazar ruta no permitida | route=/administracion, id=t1 | No se consulta la tarea | No se consultó el repositorio fake. | Aprobado | Pendiente manual | ../test/widget/notification_navigation_test.dart |
| CP-33 | FCM | FC-04 | Negativo | Cambiar sesión durante lectura | usuario u1 → sin sesión, id=t1 | No se abre el detalle | El detalle no se abrió con el repositorio fake. | Aprobado | Pendiente manual | ../test/widget/notification_navigation_test.dart |

## Análisis de resultados

Total: 33; aplicables: 32; ejecutados: 17; aprobados: 17; fallidos: 0; no ejecutados: 1; pendientes: 15.

Aprobación de flujos críticos = casos aprobados de flujos críticos / casos aplicables de flujos críticos × 100. **PENDIENTE:** completar ejecución real y reinicio antes de calcular el porcentaje final.

Análisis inicial: 1 error, 0 advertencias y 5 observaciones informativas. Análisis final: 0 errores, 0 advertencias y 0 observaciones; `flutter analyze` terminó con código 0 tras adoptar `material_ui`. `flutter test`: 18 pruebas aprobadas de 18. Los fallos detectados se concentraron en navegación, inicialización y sintaxis. Las comprobaciones de servicios reales aún no se han ejecutado.
