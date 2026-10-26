// lib/models/announcement.dart

enum AnnouncementCategory {
  academic('Academic'),
  campus('Campus'),
  reminder('Reminder'),
  opportunity('Opportunity');

  final String label;

  const AnnouncementCategory(this.label);

  static AnnouncementCategory fromName(String value) {
    final name = value.trim().toLowerCase();
    for (final category in AnnouncementCategory.values) {
      if (category.name == name) return category;
    }
    return AnnouncementCategory.campus;
  }
}

class Announcement {
  final int id;
  final String title;
  final String message;
  final DateTime publishedAt;
  final String author;
  final AnnouncementCategory category;
  final bool isImportant;

  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.publishedAt,
    required this.author,
    required this.category,
    this.isImportant = false,
  });

  String get preview {
    const limit = 120;
    if (message.length <= limit) return message;
    return '${message.substring(0, limit).trimRight()}...';
  }

  Announcement copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? publishedAt,
    String? author,
    AnnouncementCategory? category,
    bool? isImportant,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      publishedAt: publishedAt ?? this.publishedAt,
      author: author ?? this.author,
      category: category ?? this.category,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
