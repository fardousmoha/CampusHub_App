// lib/models/user.dart

enum Role {
  admin('Admin'),
  lecturer('Lecturer'),
  student('Student');

  final String label;

  const Role(this.label);

  // Used when a user arrives from the PHP API as text.
  static Role fromName(String value) {
    final name = value.trim().toLowerCase();
    for (final role in Role.values) {
      if (role.name == name) return role;
    }
    return Role.student;
  }
}

class User {
  final int id;
  final String universityId;
  final String fullName;
  final String email;

  // Demonstration data only. A real backend must store a password hash,
  // never this plain value.
  final String password;

  final Role role;
  final String department;
  final bool isActive;

  const User({
    required this.id,
    required this.universityId,
    required this.fullName,
    required this.email,
    required this.role,
    this.password = '',
    this.department = '',
    this.isActive = true,
  });

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  User copyWith({
    int? id,
    String? universityId,
    String? fullName,
    String? email,
    String? password,
    Role? role,
    String? department,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawActive = json['is_active'] ?? json['isActive'];
    return User(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      universityId: '${json['university_id'] ?? json['universityId'] ?? ''}',
      fullName: '${json['full_name'] ?? json['fullName'] ?? ''}',
      email: '${json['email'] ?? ''}',
      role: Role.fromName('${json['role'] ?? 'student'}'),
      department: '${json['department'] ?? ''}',
      isActive: rawActive == null
          ? true
          : rawActive == true || rawActive == 1 || rawActive == '1',
    );
  }

  // Passwords are deliberately not sent back to the API through this map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'full_name': fullName,
      'email': email,
      'role': role.name,
      'department': department,
      'is_active': isActive,
    };
  }
}
