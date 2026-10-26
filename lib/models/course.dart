// lib/models/course.dart

class Course {
  final int id;
  final String code;
  final String name;
  final int lecturerId; // the user id of the lecturer
  final int classId;
  final String schedule;
  final String room;
  final String description;
  final int credits;

  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.lecturerId,
    required this.classId,
    required this.schedule,
    required this.room,
    required this.description,
    required this.credits,
  });
}
