// lib/models/campus_event.dart

enum EventCategory {
  academic('Academic'),
  campus('Campus'),
  sports('Sports'),
  cultural('Cultural'),
  career('Career');

  final String label;

  const EventCategory(this.label);

  static EventCategory fromName(String value) {
    final name = value.trim().toLowerCase();
    for (final category in EventCategory.values) {
      if (category.name == name) return category;
    }
    return EventCategory.campus;
  }
}

class CampusEvent {
  final int id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String location;
  final EventCategory category;
  final String organizer;

  const CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.location,
    required this.category,
    required this.organizer,
  });

  bool get isUpcoming => end.isAfter(DateTime.now());

  CampusEvent copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    String? location,
    EventCategory? category,
    String? organizer,
  }) {
    return CampusEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      location: location ?? this.location,
      category: category ?? this.category,
      organizer: organizer ?? this.organizer,
    );
  }
}
