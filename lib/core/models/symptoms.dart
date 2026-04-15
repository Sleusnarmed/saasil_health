class Symptoms {
  final int? id;
  final String symptomName;
  final int severity; 
  final DateTime timestamp;
  final String notes;

  Symptoms({
    this.id,
    required this.symptomName,
    required this.severity,
    required this.timestamp,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symptom_name': symptomName,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory Symptoms.fromMap(Map<String, dynamic> map) {
    return Symptoms(
      id: map['id'],
      symptomName: map['symptom_name'],
      severity: map['severity'],
      timestamp: DateTime.parse(map['timestamp']),
      notes: map['notes'],
    );
  }
}