import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';
import '../rotas.dart';

class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  final _db = DatabaseHelper.instance;
  List<Tarefa> _tarefas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    setState(() => _carregando = true);
    final lista = await _db.listarTodas();
    setState(() {
      _tarefas = lista;
      _carregando = false;
    });
  }

  Future<void> _toggleRealizada(Tarefa tarefa) async {
    await _db.alternarRealizada(tarefa.id!, !tarefa.realizada);
    await _carregarTarefas();
  }

  Future<void> _deletarTarefa(Tarefa tarefa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _db.deletar(tarefa.id!);
      await _carregarTarefas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarefa "${tarefa.titulo}" excluída.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _abrirFormulario({Tarefa? tarefa}) async {
    await Navigator.pushNamed(
      context,
      Rotas.formulario,
      arguments: tarefa,
    );
    await _carregarTarefas();
  }

  Future<void> _abrirDetalhe(Tarefa tarefa) async {
    await Navigator.pushNamed(
      context,
      Rotas.detalhe,
      arguments: tarefa,
    );
    await _carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregarTarefas,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _tarefas.isEmpty
              ? _buildEmptyState()
              : _buildLista(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa cadastrada!',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "Nova tarefa" para começar.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildLista() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: _tarefas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final tarefa = _tarefas[index];
        return _TarefaCard(
          tarefa: tarefa,
          onTap: () => _abrirDetalhe(tarefa),
          onToggle: () => _toggleRealizada(tarefa),
          onEditar: () => _abrirFormulario(tarefa: tarefa),
          onDeletar: () => _deletarTarefa(tarefa),
        );
      },
    );
  }
}

// ── Card individual da tarefa ─────────────────────────────────────────────────

class _TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  const _TarefaCard({
    required this.tarefa,
    required this.onTap,
    required this.onToggle,
    required this.onEditar,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    final dataFormatada =
        DateFormat('dd/MM/yyyy').format(tarefa.dataPrevista);
    final atrasada = !tarefa.realizada &&
        tarefa.dataPrevista.isBefore(DateTime.now());

    return Card(
      elevation: tarefa.realizada ? 0 : 2,
      color: tarefa.realizada ? Colors.grey.shade100 : null,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: tarefa.realizada,
          onChanged: (_) => onToggle(),
          activeColor: Colors.green,
        ),
        title: Row(
          children: [
            if (tarefa.importante)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.star, color: Colors.amber, size: 16),
              ),
            Expanded(
              child: Text(
                tarefa.titulo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration:
                      tarefa.realizada ? TextDecoration.lineThrough : null,
                  color: tarefa.realizada ? Colors.grey : null,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 12,
              color: atrasada ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              dataFormatada,
              style: TextStyle(
                fontSize: 12,
                color: atrasada ? Colors.red : Colors.grey.shade600,
                fontWeight:
                    atrasada ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (atrasada) ...[
              const SizedBox(width: 4),
              const Text(
                '(atrasada)',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'editar') onEditar();
            if (value == 'deletar') onDeletar();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'editar',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'deletar',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title:
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
