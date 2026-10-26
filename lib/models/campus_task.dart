// lib/models/campus_task.dart

enum TaskStatus {
  pending('Pending'),
  submitted('Submitted'),
  completed('Completed');

  final String label;

  const TaskStatus(this.label);
}

enum TaskType {
  assignment('Assignment'),
  quiz('Quiz'),
  project('Project'),
  lab('Lab');

  final String label;

  const TaskType(this.label);
}

class CampusTask {
  final int id;
  final int courseId;
  final String courseName;
  final int studentId; // the user the task is assigned to
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final TaskType type;
  final bool canSubmit;

  const CampusTask({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.studentId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.status = TaskStatus.pending,
    this.type = TaskType.assignment,
    this.canSubmit = true,
  });

  bool get isOverdue =>
      status == TaskStatus.pending && dueDate.isBefore(DateTime.now());

  // Tasks created from one lecturer assignment share this key.
  String get assignmentKey =>
      '$courseId|$title|${dueDate.toIso8601String()}';

  CampusTask copyWith({
    int? id,
    int? courseId,
    String? courseName,
    int? studentId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    TaskType? type,
    bool? canSubmit,
  }) {
    return CampusTask(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      type: type ?? this.type,
      canSubmit: canSubmit ?? this.canSubmit,
    );
  }
}
