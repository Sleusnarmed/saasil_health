class GlucoseLog {
  final int? id;
  final double level;
  final DateTime timestamp;
  final String notes;

  GlucoseLog({
    this.id,
    required this.level,
    required this.timestamp,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory GlucoseLog.fromMap(Map<String, dynamic> map) {
    return GlucoseLog(
      id: map['id'],
      level: map['level'],
      timestamp: DateTime.parse(map['timestamp']),
      notes: map['notes'],
    );
  }
}