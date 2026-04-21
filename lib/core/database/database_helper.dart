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
    _database = await _initDB('saasil_health.db');
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
      activo INTEGER DEFAULT 1
    )
    ''');

    await _insertDefaultCatalogs(db);
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
