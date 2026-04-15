import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const tableGlucose = 'glucose_logs';
  static const tableInsulin = 'insulin_logs';
  static const tableSymptoms = 'symptoms_logs';
  static const tableReminders = 'reminders';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('saasil_health.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Por si se añaden más tablas o columnas
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL'; 
  
    await db.execute('''
    CREATE TABLE $tableGlucose (
      id $idType,
      level $realType,          /* Ej: 110.0 mg/dL */
      timestamp $textType,      /* Fecha y hora exacta (ISO8601) */
      notes TEXT                /* Opcional: "Después de comer", etc. */
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableInsulin (
      id $idType,
      units $integerType,       /* Ej: 12 unidades */
      type $textType,           /* 'Bolo' (Rápida) o 'Basal' (Lenta) */
      timestamp $textType,      /* Fecha y hora exacta (ISO8601) */
      notes TEXT                /* Opcional */
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableSymptoms (
      id $idType,
      symptom_name $textType,   /* Ej: 'Mareo', 'Sudoración' */
      severity $integerType,    /* Ej: 1 al 5 (qué tan fuerte es) */
      timestamp $textType,      /* Fecha y hora exacta (ISO8601) */
      notes TEXT                /* Opcional */
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableReminders (
      id $idType,
      title $textType,          /* Ej: 'Control Pre-almuerzo' */
      reminder_type $textType,  /* 'Glucosa', 'Insulina', 'Otro' */
      insulin_type TEXT,        /* 'Bolo' o 'Basal' (solo si es de insulina) */
      time_scheduled $textType, /* Hora a la que debe sonar */
      is_active $integerType,   /* 1 (Activo) o 0 (Inactivo) */
      created_at $textType      /* Cuándo se creó el recordatorio */
    )
    ''');
  }

  Future<int> insertGlucose(double level, {String? notes}) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String(); 

    return await db.insert(tableGlucose, {
      'level': level,
      'timestamp': now,
      'notes': notes ?? '', 
    });
  }

  Future<int> insertInsulin(int units, String type, {String? notes}) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();

    return await db.insert(tableInsulin, {
      'units': units,
      'type': type, 
      'timestamp': now,
      'notes': notes ?? '',
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}