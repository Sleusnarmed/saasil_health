import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const tableCatTipoInsulina = 'cat_tipo_insulina';
  static const tableCatSintomas = 'cat_sintomas';
  static const tableRegGlucosa = 'registros_glucosa';
  static const tableRegInsulina = 'registros_insulina';
  static const tableRegSintomas = 'registros_sintomas';
  static const tableRelSintomasDetalle = 'rel_sintomas_detalle';
  static const tableHistorialChat = 'historial_chat_ia';
  static const tableConfigRecordatorios = 'config_recordatorios';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('saasil_health_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableCatTipoInsulina (
      id_tipo_insu INTEGER PRIMARY KEY AUTOINCREMENT,
      categoria TEXT NOT NULL,
      subtipo TEXT NOT NULL,
      UNIQUE(categoria, subtipo)
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableCatSintomas (
      id_cat_sintoma INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre_sintoma TEXT NOT NULL UNIQUE
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableRegGlucosa (
      id_glucosa INTEGER PRIMARY KEY AUTOINCREMENT,
      valor INTEGER NOT NULL,
      momento_dia TEXT NOT NULL,
      fecha_hora TEXT DEFAULT CURRENT_TIMESTAMP,
      notas TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableRegInsulina (
      id_insulina INTEGER PRIMARY KEY AUTOINCREMENT,
      unidades INTEGER NOT NULL,
      id_tipo_insu INTEGER NOT NULL,
      fecha_hora TEXT DEFAULT CURRENT_TIMESTAMP,
      notas TEXT,
      FOREIGN KEY (id_tipo_insu) REFERENCES $tableCatTipoInsulina (id_tipo_insu)
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableRegSintomas (
      id_reg_sintoma INTEGER PRIMARY KEY AUTOINCREMENT,
      severidad TEXT NOT NULL,
      fecha_hora TEXT DEFAULT CURRENT_TIMESTAMP,
      notas TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableRelSintomasDetalle (
      id_detalle INTEGER PRIMARY KEY AUTOINCREMENT,
      id_reg_sintoma INTEGER NOT NULL,
      id_cat_sintoma INTEGER NOT NULL,
      FOREIGN KEY (id_reg_sintoma) REFERENCES $tableRegSintomas (id_reg_sintoma) ON DELETE CASCADE,
      FOREIGN KEY (id_cat_sintoma) REFERENCES $tableCatSintomas (id_cat_sintoma)
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableHistorialChat (
      id_chat INTEGER PRIMARY KEY AUTOINCREMENT,
      pregunta TEXT NOT NULL,
      respuesta TEXT NOT NULL,
      fecha_hora TEXT DEFAULT CURRENT_TIMESTAMP
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableConfigRecordatorios (
      id_recordatorio INTEGER PRIMARY KEY AUTOINCREMENT,
      titulo TEXT NOT NULL,
      hora TEXT NOT NULL,
      frecuencia TEXT NOT NULL, -- NUEVO CAMPO AGREGADO
      activo INTEGER DEFAULT 1
    )
    ''');

    await _insertDefaultCatalogs(db);
    await _insertDummyData(db);
  }

  Future _insertDefaultCatalogs(Database db) async {
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Acción Rápida',
      'subtipo': 'Aspart',
    });
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Acción Rápida',
      'subtipo': 'Lispro',
    });
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Acción Rápida',
      'subtipo': 'Glusilina',
    });
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Acción Corta',
      'subtipo': 'Regular',
    });
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Acción Intermedia',
      'subtipo': 'NPH',
    });
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Acción Prolongada',
      'subtipo': 'Glargina',
    });
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Acción Prolongada',
      'subtipo': 'Detemir',
    });
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Acción Prolongada',
      'subtipo': 'Degludec',
    });
    await db.insert(tableCatTipoInsulina, {
      'categoria': 'Inhalada',
      'subtipo': 'Polvo de insulina humana',
    });

    final sintomasComunes = [
      'Mareo',
      'Sudoración',
      'Visión Borrosa',
      'Sed Extrema',
      'Fatiga',
    ];
    for (String sintoma in sintomasComunes) {
      await db.insert(tableCatSintomas, {'nombre_sintoma': sintoma});
    }
  }

  Future _insertDummyData(Database db) async {
    final now = DateTime.now();

    // 1. Insertar 7 registros de glucosa simulando los últimos 7 días
    // Valores elegidos para mostrar alertas (rojos) y normales (verdes/blancos)
    final valoresGlucosa = [
      95,  // Día 1
      110, // Día 2
      65,  // Día 3 (Alerta baja)
      120, // Día 4
      160, // Día 5 (Alerta alta)
      105, // Día 6
      108, // Hoy (Día 7)
    ];

    for (int i = 0; i < valoresGlucosa.length; i++) {
      // Restamos días para que parezca un historial real
      final fecha = now.subtract(Duration(days: 6 - i)).toIso8601String();
      
      await db.insert(tableRegGlucosa, {
        'valor': valoresGlucosa[i],
        'momento_dia': 'Ayunas',
        'fecha_hora': fecha,
        'notas': 'Dato de prueba autogenerado',
      });
    }

    // 2. Insertar registros de Insulina para calcular el promedio
    final registrosInsulina = [
      {'unidades': 12, 'diasAtras': 2},
      {'unidades': 10, 'diasAtras': 1},
      {'unidades': 11, 'diasAtras': 0},
    ];

    for (var reg in registrosInsulina) {
      final fecha = now.subtract(Duration(days: reg['diasAtras'] as int)).toIso8601String();
      await db.insert(tableRegInsulina, {
        'unidades': reg['unidades'],
        'id_tipo_insu': 1, // 'Acción Rápida - Aspart' según tus catálogos
        'fecha_hora': fecha,
        'notas': 'Dato de prueba autogenerado',
      });
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
