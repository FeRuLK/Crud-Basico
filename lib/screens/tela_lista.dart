import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../providers/tarefa_provider.dart';
import '../rotas.dart';
import '../widgets/tarefa_card.dart';

class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _abas = const [
    Tab(icon: Icon(Icons.list), text: 'Todas'),
    Tab(icon: Icon(Icons.star), text: 'Importantes'),
    Tab(icon: Icon(Icons.check_circle), text: 'Realizadas'),
    Tab(icon: Icon(Icons.warning), text: 'Atrasadas'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _abas.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TarefaProvider>().carregar();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmarDeletar(
      BuildContext context, TarefaProvider provider, Tarefa tarefa) async {
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
      await provider.deletar(tarefa.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarefa "${tarefa.titulo}" excluída.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
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
            onPressed: () => context.read<TarefaProvider>().carregar(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _abas,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: Consumer<TarefaProvider>(
        builder: (context, provider, _) {
          if (provider.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _ListaFiltrada(
                tarefas: provider.tarefas,
                onToggle: provider.alternarRealizada,
                onDeletar: (t) => _confirmarDeletar(context, provider, t),
              ),
              _ListaFiltrada(
                tarefas: provider.importantes,
                emptyMsg: 'Nenhuma tarefa importante.',
                onToggle: provider.alternarRealizada,
                onDeletar: (t) => _confirmarDeletar(context, provider, t),
              ),
              _ListaFiltrada(
                tarefas: provider.realizadas,
                emptyMsg: 'Nenhuma tarefa realizada.',
                onToggle: provider.alternarRealizada,
                onDeletar: (t) => _confirmarDeletar(context, provider, t),
              ),
              _ListaFiltrada(
                tarefas: provider.atrasadas,
                emptyMsg: 'Nenhuma tarefa atrasada. 🎉',
                onToggle: provider.alternarRealizada,
                onDeletar: (t) => _confirmarDeletar(context, provider, t),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, Rotas.formulario);
          // ignore: use_build_context_synchronously
          context.read<TarefaProvider>().carregar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
    );
  }
}

// ── Lista filtrada reutilizável ───────────────────────────────────────────────

class _ListaFiltrada extends StatelessWidget {
  final List<Tarefa> tarefas;
  final String emptyMsg;
  final Future<void> Function(Tarefa) onToggle;
  final void Function(Tarefa) onDeletar;

  const _ListaFiltrada({
    required this.tarefas,
    this.emptyMsg = 'Nenhuma tarefa cadastrada.',
    required this.onToggle,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    if (tarefas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(emptyMsg,
                style:
                    TextStyle(fontSize: 16, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: tarefas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final tarefa = tarefas[index];
        return TarefaCard(
          tarefa: tarefa,
          onTap: () async {
            await Navigator.pushNamed(
              context,
              Rotas.detalhe,
              arguments: tarefa,
            );
            if (context.mounted) {
              context.read<TarefaProvider>().carregar();
            }
          },
          onToggle: () => onToggle(tarefa),
          onEditar: () async {
            await Navigator.pushNamed(
              context,
              Rotas.formulario,
              arguments: tarefa,
            );
            if (context.mounted) {
              context.read<TarefaProvider>().carregar();
            }
          },
          onDeletar: () => onDeletar(tarefa),
        );
      },
    );
  }
}
