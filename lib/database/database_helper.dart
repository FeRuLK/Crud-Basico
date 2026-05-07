import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const _dbName = 'tarefas.db';
  static const _dbVersion = 2;
  static const _tableName = 'tarefas';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    if (kDebugMode) print('[DB] abrindo banco em: $path');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    if (kDebugMode) print('[DB] onCreate() criando tabela...');
    await db.execute('''
      CREATE TABLE $_tableName (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo          TEXT    NOT NULL,
        descricao       TEXT    NOT NULL,
        dataPrevista    TEXT    NOT NULL,
        importante      INTEGER NOT NULL DEFAULT 0,
        realizada       INTEGER NOT NULL DEFAULT 0,
        estimativaHoras REAL    NOT NULL DEFAULT 1.0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) print('[DB] onUpgrade() $oldVersion → $newVersion');
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_tableName ADD COLUMN estimativaHoras REAL NOT NULL DEFAULT 1.0',
      );
    }
  }

  Future<int> inserir(Tarefa tarefa) async {
    final db = await database;
    final map = tarefa.toMap()..remove('id');
    if (kDebugMode) print('[DB] inserir() map=$map');
    final id = await db.insert(
      _tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (kDebugMode) print('[DB] inserir() → id gerado=$id');
    return id;
  }

  Future<List<Tarefa>> listarTodas() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'dataPrevista ASC');
    if (kDebugMode) print('[DB] listarTodas() → ${maps.length} registros');
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

  Future<int> atualizar(Tarefa tarefa) async {
    final db = await database;
    return await db.update(
      _tableName,
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<int> alternarRealizada(int id, bool realizada) async {
    final db = await database;
    return await db.update(
      _tableName,
      {'realizada': realizada ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
