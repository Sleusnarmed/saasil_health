class RegSintomas {
  final int? idRegSintoma;
  final String severidad;
  final DateTime fechaHora;
  final String? notas;

  RegSintomas({
    this.idRegSintoma,
    required this.severidad,
    required this.fechaHora,
    this.notas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_reg_sintoma': idRegSintoma,
      'severidad': severidad,
      'fecha_hora': fechaHora.toIso8601String(),
      'notas': notas,
    };
  }

  factory RegSintomas.fromMap(Map<String, dynamic> map) {
    return RegSintomas(
      idRegSintoma: map['id_reg_sintoma'],
      severidad: map['severidad'],
      fechaHora: DateTime.parse(map['fecha_hora']),
      notas: map['notas'],
    );
  }
}