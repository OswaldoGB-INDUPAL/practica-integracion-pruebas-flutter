import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  const Task({required this.id, required this.title, required this.description, required this.done, required this.createdAt});
  final String id;
  final String title;
  final String description;
  final bool done;
  final DateTime createdAt;
  factory Task.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return Task(id: id, title: map['title'] as String? ?? '', description: map['description'] as String? ?? '', done: map['done'] as bool? ?? false, createdAt: created is Timestamp ? created.toDate() : created is DateTime ? created : DateTime.fromMillisecondsSinceEpoch(0));
  }
  Map<String, dynamic> toMap() => {'title': title, 'description': description, 'done': done, 'createdAt': createdAt};
}
