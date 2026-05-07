import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';

class TarefaProvider extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<Tarefa> _tarefas = [];
  bool _carregando = false;

  List<Tarefa> get tarefas => _tarefas;
  bool get carregando => _carregando;

  Tarefa? get proximaTarefa {
    final pendentes = _tarefas.where((t) => !t.realizada).toList();
    if (pendentes.isEmpty) return null;
    pendentes.sort((a, b) => a.dataPrevista.compareTo(b.dataPrevista));
    return pendentes.first;
  }

  List<Tarefa> get importantes =>
      _tarefas.where((t) => t.importante).toList();
  List<Tarefa> get naoImportantes =>
      _tarefas.where((t) => !t.importante).toList();
  List<Tarefa> get realizadas =>
      _tarefas.where((t) => t.realizada).toList();
  List<Tarefa> get naoRealizadas =>
      _tarefas.where((t) => !t.realizada).toList();
  List<Tarefa> get atrasadas => _tarefas
      .where((t) => !t.realizada && t.dataPrevista.isBefore(DateTime.now()))
      .toList();
  List<Tarefa> get naoAtrasadas => _tarefas
      .where((t) => t.realizada || !t.dataPrevista.isBefore(DateTime.now()))
      .toList();

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _tarefas = await _db.listarTodas();
    if (kDebugMode) print('[Provider] carregar() → ${_tarefas.length} tarefas');

    _carregando = false;
    notifyListeners();
  }

  Future<void> inserir(Tarefa tarefa) async {
    final id = await _db.inserir(tarefa);
    if (kDebugMode) print('[Provider] inserir() → id=$id');
    await carregar();
  }

  Future<void> atualizar(Tarefa tarefa) async {
    await _db.atualizar(tarefa);
    await carregar();
  }

  Future<void> alternarRealizada(Tarefa tarefa) async {
    await _db.alternarRealizada(tarefa.id!, !tarefa.realizada);
    await carregar();
  }

  Future<void> deletar(int id) async {
    await _db.deletar(id);
    await carregar();
  }
}
