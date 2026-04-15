class InsulinLog {
  final int? id;
  final int units;
  final String type; 
  final DateTime timestamp;
  final String notes;

  InsulinLog({
    this.id,
    required this.units,
    required this.type,
    required this.timestamp,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'units': units,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory InsulinLog.fromMap(Map<String, dynamic> map) {
    return InsulinLog(
      id: map['id'],
      units: map['units'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
      notes: map['notes'],
    );
  }
}