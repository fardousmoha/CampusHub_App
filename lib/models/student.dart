// lib/models/student.dart

class Student {
  final int id;
  final int userId; // the login account (foreign key to users)
  final int classId; // the class of the student (foreign key to classes)

  const Student({
    required this.id,
    required this.userId,
    required this.classId,
  });
}
