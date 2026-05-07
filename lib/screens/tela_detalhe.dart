import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../providers/tarefa_provider.dart';
import '../rotas.dart';
import '../widgets/info_card.dart';
import '../widgets/status_badge.dart';

class TelaDetalhe extends StatefulWidget {
  const TelaDetalhe({super.key});

  @override
  State<TelaDetalhe> createState() => _TelaDetalheState();
}

class _TelaDetalheState extends State<TelaDetalhe> {
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
    final provider = context.read<TarefaProvider>();
    await provider.alternarRealizada(_tarefa);
    if (!mounted) return;
    final atualizada = provider.tarefas
            .where((t) => t.id == _tarefa.id)
            .firstOrNull ??
        _tarefa.copyWith(realizada: !_tarefa.realizada);
    setState(() => _tarefa = atualizada);
  }

  Future<void> _editarTarefa() async {
    await Navigator.pushNamed(context, Rotas.formulario, arguments: _tarefa);
    if (!mounted) return;
    final provider = context.read<TarefaProvider>();
    await provider.carregar();
    if (!mounted) return;
    final atualizada =
        provider.tarefas.where((t) => t.id == _tarefa.id).firstOrNull;
    if (atualizada != null) setState(() => _tarefa = atualizada);
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
      await context.read<TarefaProvider>().deletar(_tarefa.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  String _formatarEstimativa(double horas) {
    if (horas < 1) return '${(horas * 60).round()} minutos';
    if (horas == horas.roundToDouble()) return '${horas.toInt()} hora(s)';
    return '${horas.toStringAsFixed(1)} horas';
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
            // ── Cabeçalho (ID + Título) ───────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: #${_tarefa.id}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
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
                              color:
                                  _tarefa.realizada ? Colors.grey : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Descrição ─────────────────────────────────────────────────
            InfoCard(
              icon: Icons.description,
              titulo: 'Descrição',
              conteudo: _tarefa.descricao,
            ),
            const SizedBox(height: 12),

            // ── Data prevista ─────────────────────────────────────────────
            InfoCard(
              icon: Icons.calendar_today,
              iconColor: atrasada ? Colors.red : null,
              titulo: 'Data prevista',
              conteudo: dataFormatada + (atrasada ? '  ⚠️ Atrasada!' : ''),
              conteudoColor: atrasada ? Colors.red : null,
            ),
            const SizedBox(height: 12),

            // ── Estimativa de tempo ───────────────────────────────────────
            InfoCard(
              icon: Icons.timer_outlined,
              titulo: 'Estimativa de tempo',
              conteudo: _formatarEstimativa(_tarefa.estimativaHoras),
            ),
            const SizedBox(height: 12),

            // ── Badges de status ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: StatusBadge(
                    icon: Icons.star,
                    label: 'Importante',
                    ativo: _tarefa.importante,
                    corAtivo: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatusBadge(
                    icon: Icons.check_circle,
                    label: 'Realizada',
                    ativo: _tarefa.realizada,
                    corAtivo: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Botão realizar (somente aqui!) ────────────────────────────
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
