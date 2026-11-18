Aprendí que una pantalla privada puede permanecer en la pila cuando cambia la sesión (INC-001).
La prueba de widget `test/widget/flows_test.dart` habría detectado ese error antes de integrar Firebase.
Comprobé con `flutter analyze` que un paréntesis ausente impedía compilar la interfaz (INC-003).
La salida fallida y la suite posterior permiten distinguir una corrección de una suposición.
También observé que una excepción de FCM podía impedir el arranque (INC-002).
En mi siguiente proyecto probaré primero los cambios de sesión y aislaré servicios externos con fakes.

Borrador generado a partir de las incidencias registradas; revisar y ajustar con la experiencia propia.
