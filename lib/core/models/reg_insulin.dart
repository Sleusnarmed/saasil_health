class RegInsulina {
  final int? idInsulina;
  final int unidades;
  final int idTipoInsu; 
  final DateTime fechaHora;
  final String? notas;

  RegInsulina({
    this.idInsulina,
    required this.unidades,
    required this.idTipoInsu,
    required this.fechaHora,
    this.notas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_insulina': idInsulina,
      'unidades': unidades,
      'id_tipo_insu': idTipoInsu,
      'fecha_hora': fechaHora.toIso8601String(),
      'notas': notas,
    };
  }

  factory RegInsulina.fromMap(Map<String, dynamic> map) {
    return RegInsulina(
      idInsulina: map['id_insulina'],
      unidades: map['unidades'],
      idTipoInsu: map['id_tipo_insu'],
      fechaHora: DateTime.parse(map['fecha_hora']),
      notas: map['notas'],
    );
  }
}