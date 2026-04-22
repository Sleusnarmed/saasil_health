class ConfigRecordatorios {
  final int? idRecordatorio;
  final String titulo;
  final String hora;
  final String frecuencia;
  final bool activo;

  ConfigRecordatorios({
    this.idRecordatorio,
    required this.titulo,
    required this.hora,
    required this.frecuencia,
    this.activo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_recordatorio': idRecordatorio,
      'titulo': titulo,
      'hora': hora,
      'frecuencia': frecuencia,
      'activo': activo ? 1 : 0,
    };
  }

  factory ConfigRecordatorios.fromMap(Map<String, dynamic> map) {
    return ConfigRecordatorios(
      idRecordatorio: map['id_recordatorio'],
      titulo: map['titulo'],
      hora: map['hora'],
      frecuencia: map['frecuencia'],
      activo: map['activo'] == 1,
    );
  }
}
