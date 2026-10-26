// lib/models/school_class.dart

// "class" is a reserved word in Dart, so the model is called SchoolClass.
class SchoolClass {
  final int id;
  final String name; // for example 'CS-7A'
  final int semester;
  final int facultyId;
  final String department;

  const SchoolClass({
    required this.id,
    required this.name,
    required this.semester,
    required this.facultyId,
    required this.department,
  });
}
