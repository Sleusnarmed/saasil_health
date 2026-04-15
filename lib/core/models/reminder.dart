class Reminder {
  final int? id;
  final String title;
  final String reminderType;
  final String? insulinType; 
  final String timeScheduled; 
  final bool isActive;
  final DateTime createdAt;

  Reminder({
    this.id,
    required this.title,
    required this.reminderType,
    this.insulinType,
    required this.timeScheduled,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'reminder_type': reminderType,
      'insulin_type': insulinType,
      'time_scheduled': timeScheduled,
      'is_active': isActive ? 1 : 0, 
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      reminderType: map['reminder_type'],
      insulinType: map['insulin_type'],
      timeScheduled: map['time_scheduled'],
      isActive: map['is_active'] == 1, 
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}