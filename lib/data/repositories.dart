import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

abstract class TaskRepository {
  Stream<List<Task>> watchTasks();
  Future<void> save(Task task);
  Future<void> delete(String id);
}

class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository(this.uid);
  final String uid;
  CollectionReference<Map<String, dynamic>> get _tasks => FirebaseFirestore.instance.collection('users').doc(uid).collection('tasks');
  @override
  Stream<List<Task>> watchTasks() => _tasks.orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList()).handleError((Object _) { throw const AppException('No se pudieron cargar las tareas. Revisa tu conexión.'); });
  @override
  Future<void> save(Task task) async {
    try {
      if (task.id.isEmpty) { await _tasks.add(task.toMap()); } else { await _tasks.doc(task.id).update(task.toMap()); }
    } on FirebaseException { throw const AppException('No se pudo guardar la tarea. Revisa tu conexión.'); }
  }
  @override
  Future<void> delete(String id) async {
    try { await _tasks.doc(id).delete(); } on FirebaseException { throw const AppException('No se pudo eliminar la tarea.'); }
  }
}

abstract class AuthRepository {
  Stream<String?> authState();
  Future<void> signIn(String email, String password, {required bool register});
  Future<void> signOut();
}
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Stream<String?> authState() => _auth.authStateChanges().map((user) => user?.uid);
  @override
  Future<void> signIn(String email, String password, {required bool register}) async {
    try {
      if (register) { await _auth.createUserWithEmailAndPassword(email: email, password: password); }
      else { await _auth.signInWithEmailAndPassword(email: email, password: password); }
    } on FirebaseAuthException { throw const AppException('No se pudo iniciar la sesión o registrar la cuenta. Revisa los datos.'); }
  }
  @override
  Future<void> signOut() async {
    try { await _auth.signOut(); } on FirebaseAuthException { throw const AppException('No se pudo cerrar la sesión.'); }
  }
}
