import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const _dbName = 'tarefas.db';
  static const _dbVersion = 1;
  static const _tableName = 'tarefas';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo    TEXT    NOT NULL,
        descricao TEXT    NOT NULL,
        dataPrevista TEXT NOT NULL,
        importante INTEGER NOT NULL DEFAULT 0,
        realizada  INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ── CREATE ──────────────────────────────────────────────────────────────────

  Future<int> inserir(Tarefa tarefa) async {
    final db = await database;
    return await db.insert(
      _tableName,
      tarefa.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── READ ────────────────────────────────────────────────────────────────────

  Future<List<Tarefa>> listarTodas() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'dataPrevista ASC',
    );
    return maps.map((m) => Tarefa.fromMap(m)).toList();
  }

  Future<Tarefa?> buscarPorId(int id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Tarefa.fromMap(maps.first);
  }

  // ── UPDATE ──────────────────────────────────────────────────────────────────

  Future<int> atualizar(Tarefa tarefa) async {
    final db = await database;
    return await db.update(
      _tableName,
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  // Atualiza só o campo "realizada" (toggle rápido na lista)
  Future<int> alternarRealizada(int id, bool realizada) async {
    final db = await database;
    return await db.update(
      _tableName,
      {'realizada': realizada ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── DELETE ──────────────────────────────────────────────────────────────────

  Future<int> deletar(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
