# Registro de incidencias

## INC-001 — La sesión podía cambiar con una pantalla privada abierta

- **Caso:** CP-27. **Severidad:** Alta. **Prioridad:** P1. **Origen:** Navegación.
- **Pasos:** 1. Iniciar sesión. 2. Abrir detalle de una tarea. 3. Provocar la caducidad de la sesión.
- **Esperado:** volver al acceso sin mostrar el detalle. **Observado por revisión:** la ruta de detalle permanecía encima de la pantalla principal al cambiar el estado de autenticación.
- **Causa:** cambiar el contenido de la ruta raíz no eliminaba las rutas superiores.
- **Corrección:** `lib/main.dart` vacía las rutas superiores cuando cambia el usuario; commit `192dca4` (`fix: INC-001 proteger navegación al cambiar de sesión`).
- **Regresión:** `test/widget/flows_test.dart`, caso INC-001; pasó después de la corrección; salida `evidencias/pruebas-y-analisis/flutter-test-regresion-INC-001.txt`.
- **Estado:** Corregida y verificada con fake; pendiente confirmación en dispositivo real. Después del fix se reconstruyó el código anterior `fbcd492` en una copia, corrigiendo únicamente el paréntesis de INC-003 para permitir compilar: la prueba falló porque no apareció el acceso. La salida está en `evidencias/pruebas-y-analisis/flutter-test-inicial-INC-001.txt`. No existe el commit de prueba anterior al fix que pedía el handoff.

### Método de cinco pasos
1. **Reproducir:** escenario de caducidad descrito; reproducido con fake en una copia del código anterior después de corregir.
2. **Leer:** la revisión de `MyApp` mostró que el cambio de sesión reemplazaba el contenido raíz sin cerrar rutas encima.
3. **Hipótesis:** el detalle previo permanecería visible tras perder la sesión.
4. **Comprobar:** la prueba ejecutada posteriormente sobre la reconstrucción anterior falló al no encontrar el acceso.
5. **Corregir y proteger:** cierre de rutas al cambiar usuario y prueba de widget posterior, ejecutada satisfactoriamente.

## INC-002 — Un fallo de FCM podía impedir el arranque

- **Caso:** CP-01. **Severidad:** Alta. **Prioridad:** P1. **Origen:** FCM.
- **Pasos:** 1. Provocar una excepción al iniciar mensajería. 2. Abrir la app.
- **Esperado:** iniciar la interfaz y registrar el fallo. **Observado por revisión:** la excepción de `notifications.start()` se propagaba antes de `runApp`.
- **Causa:** la inicialización de notificaciones se esperaba sin captura de errores.
- **Corrección:** captura y registro en `lib/main.dart`; commit `b4ac250` (`fix: INC-002 permitir arranque si falla FCM`).
- **Regresión:** pendiente de simular la excepción en dispositivo. **Estado:** Corregida; no verificada.

## INC-003 — El formulario de acceso no compilaba

- **Caso:** CP-01. **Severidad:** Crítica. **Prioridad:** P1. **Origen:** UI.
- **Pasos:** 1. Ejecutar `flutter analyze`. 2. Ejecutar `flutter test test/widget/task_page_test.dart`.
- **Esperado:** compilar la pantalla y cargar los tests. **Obtenido:** `Expected to find ')'` y fallo de compilación al cargar la prueba.
- **Causa:** faltaba un paréntesis para cerrar el `Scaffold` del formulario de acceso.
- **Corrección:** cierre del árbol de widgets en `lib/main.dart`; commit `d4cc7be` (`fix: INC-003 cerrar el árbol de widgets de acceso`).
- **Regresión:** la suite `flutter test` terminó en verde; salidas inicial y final en `evidencias/pruebas-y-analisis/`. **Estado:** Verificada con pruebas automatizadas; dispositivo real pendiente.

## INC-004 — La API Material anterior producía avisos en Flutter 3.50

- **Caso:** análisis estático. **Severidad:** Baja. **Prioridad:** P3. **Origen:** Configuración.
- **Pasos:** 1. Ejecutar `flutter analyze` con Flutter 3.50. 2. Revisar los imports de Material.
- **Esperado:** análisis sin observaciones. **Obtenido:** seis observaciones de obsolescencia y código de salida 1.
- **Causa:** el proyecto importaba `package:flutter/material.dart`, marcado como obsoleto por el SDK instalado.
- **Corrección:** se adoptó `material_ui` como en la plantilla del SDK y se actualizaron los imports; commit `3a9b7cb` (`fix: INC-004 migrar Material y eliminar avisos del análisis`).
- **Regresión:** `flutter analyze` terminó con «No issues found» y código 0; `flutter test` pasó 15/15. Salidas en `evidencias/pruebas-y-analisis/`.
- **Estado:** Verificada con análisis y pruebas automatizadas; compilación Android pendiente.

## INC-005 — El token FCM se imprimía también en compilaciones de distribución

- **Caso:** CP-14. **Severidad:** Media. **Prioridad:** P2. **Origen:** FCM.
- **Pasos:** 1. Iniciar sesión con un token FCM. 2. Revisar la salida de `saveToken` en una compilación de distribución.
- **Esperado:** el token solo aparece en el registro de depuración para recoger la evidencia. **Observado por revisión:** la llamada a `debugPrint` era incondicional.
- **Causa:** el mensaje no comprobaba el modo de compilación.
- **Corrección:** `lib/data/notification_service.dart` registra el token solamente si `kDebugMode` es verdadero; commit `2597e0f` (`fix: INC-005 limitar registro de token a depuración`).
- **Regresión:** `flutter analyze` sin observaciones y `flutter test` 15/15; pendiente de comprobar registros en compilaciones Android de depuración y distribución.
- **Estado:** Corregida; verificación Android pendiente.

**Resumen:** 1 crítica, 2 altas, 1 media y 1 baja; orígenes: UI 1, navegación 1, FCM 2, configuración 1. La apertura inicial diferida de una notificación también se ajustó en `192dca4`, pero no se contabiliza como incidencia verificada sin ejecución real.
