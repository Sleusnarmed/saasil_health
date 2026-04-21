class RegGlucosa {
  final int? idGlucosa;
  final int valor;
  final String momentoDia;
  final DateTime fechaHora;
  final String? notas;

  RegGlucosa({
    this.idGlucosa,
    required this.valor,
    required this.momentoDia,
    required this.fechaHora,
    this.notas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_glucosa': idGlucosa,
      'valor': valor,
      'momento_dia': momentoDia,
      'fecha_hora': fechaHora.toIso8601String(),
      'notas': notas,
    };
  }

  factory RegGlucosa.fromMap(Map<String, dynamic> map) {
    return RegGlucosa(
      idGlucosa: map['id_glucosa'],
      valor: map['valor'],
      momentoDia: map['momento_dia'],
      fechaHora: DateTime.parse(map['fecha_hora']),
      notas: map['notas'],
    );
  }
}