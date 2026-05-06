import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';
import '../rotas.dart';

class TelaDetalhe extends StatefulWidget {
  const TelaDetalhe({super.key});

  @override
  State<TelaDetalhe> createState() => _TelaDetalheState();
}

class _TelaDetalheState extends State<TelaDetalhe> {
  final _db = DatabaseHelper.instance;
  late Tarefa _tarefa;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _tarefa = ModalRoute.of(context)!.settings.arguments as Tarefa;
      _inicializado = true;
    }
  }

  Future<void> _toggleRealizada() async {
    await _db.alternarRealizada(_tarefa.id!, !_tarefa.realizada);
    setState(() => _tarefa = _tarefa.copyWith(realizada: !_tarefa.realizada));
  }

  Future<void> _editarTarefa() async {
    await Navigator.pushNamed(
      context,
      Rotas.formulario,
      arguments: _tarefa,
    );
    // Recarrega a tarefa do banco após edição
    final atualizada = await _db.buscarPorId(_tarefa.id!);
    if (atualizada != null && mounted) {
      setState(() => _tarefa = atualizada);
    }
  }

  Future<void> _deletarTarefa() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${_tarefa.titulo}"?'),
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
    if (confirmar == true && mounted) {
      await _db.deletar(_tarefa.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataFormatada =
        DateFormat('dd/MM/yyyy').format(_tarefa.dataPrevista);
    final atrasada =
        !_tarefa.realizada && _tarefa.dataPrevista.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da Tarefa'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: _editarTarefa,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Excluir',
            onPressed: _deletarTarefa,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cabeçalho ────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_tarefa.importante)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Icon(Icons.star,
                                color: Colors.amber, size: 20),
                          ),
                        Expanded(
                          child: Text(
                            _tarefa.titulo,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: _tarefa.realizada
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: _tarefa.realizada
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: #${_tarefa.id}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Descrição ─────────────────────────────────────────────────
            _InfoCard(
              icon: Icons.description,
              titulo: 'Descrição',
              conteudo: _tarefa.descricao,
            ),
            const SizedBox(height: 12),

            // ── Data prevista ─────────────────────────────────────────────
            _InfoCard(
              icon: Icons.calendar_today,
              iconColor: atrasada ? Colors.red : null,
              titulo: 'Data prevista',
              conteudo: dataFormatada +
                  (atrasada ? '  ⚠️ Atrasada!' : ''),
              conteudoColor: atrasada ? Colors.red : null,
            ),
            const SizedBox(height: 12),

            // ── Badges de status ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatusBadge(
                    icon: Icons.star,
                    label: 'Importante',
                    ativo: _tarefa.importante,
                    corAtivo: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusBadge(
                    icon: Icons.check_circle,
                    label: 'Realizada',
                    ativo: _tarefa.realizada,
                    corAtivo: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Botão de toggle realizada ─────────────────────────────────
            FilledButton.icon(
              onPressed: _toggleRealizada,
              icon: Icon(
                _tarefa.realizada
                    ? Icons.undo
                    : Icons.check_circle_outline,
              ),
              label: Text(
                _tarefa.realizada
                    ? 'Marcar como não realizada'
                    : 'Marcar como realizada',
                style: const TextStyle(fontSize: 15),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    _tarefa.realizada ? Colors.orange : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String titulo;
  final String conteudo;
  final Color? conteudoColor;

  const _InfoCard({
    required this.icon,
    this.iconColor,
    required this.titulo,
    required this.conteudo,
    this.conteudoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor ?? Colors.grey.shade600, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13,
                          color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    conteudo,
                    style: TextStyle(fontSize: 15, color: conteudoColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool ativo;
  final Color corAtivo;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.ativo,
    required this.corAtivo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ativo ? corAtivo.withAlpha(30) : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: ativo ? corAtivo : Colors.grey, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ativo ? corAtivo : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
