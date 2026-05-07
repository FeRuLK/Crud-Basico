import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tarefa_provider.dart';
import '../rotas.dart';

class TelaBoasVindas extends StatefulWidget {
  const TelaBoasVindas({super.key});

  @override
  State<TelaBoasVindas> createState() => _TelaBoasVindasState();
}

class _TelaBoasVindasState extends State<TelaBoasVindas> {
  @override
  void initState() {
    super.initState();
    // Carrega tarefas para mostrar a mais próxima
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TarefaProvider>().carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TarefaProvider>();
    final proxima = provider.proximaTarefa;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // ── Logo / saudação ────────────────────────────────────────
                const Icon(Icons.task_alt, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Bem-vindo!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize suas tarefas com facilidade.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),

                const SizedBox(height: 40),

                // ── Card tarefa mais próxima ────────────────────────────────
                if (provider.carregando)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (proxima != null)
                  _ProximaTarefaCard(proxima: proxima)
                else
                  Card(
                    color: Colors.white.withValues(alpha: 0.15),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Nenhuma tarefa pendente. \nAproveite o dia! 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5),
                      ),
                    ),
                  ),

                const Spacer(),

                // ── Botão entrar ───────────────────────────────────────────
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, Rotas.lista),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Ver todas as tarefas',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProximaTarefaCard extends StatelessWidget {
  final dynamic proxima;
  const _ProximaTarefaCard({required this.proxima});

  @override
  Widget build(BuildContext context) {
    final atrasada =
        proxima.dataPrevista.isBefore(DateTime.now());
    final dataFormatada =
        DateFormat('dd/MM/yyyy').format(proxima.dataPrevista);

    return Card(
      color: Colors.white.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time_filled,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  atrasada
                      ? '⚠️ Tarefa mais urgente'
                      : '📌 Próxima tarefa a vencer',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              proxima.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  dataFormatada,
                  style: TextStyle(
                    color: atrasada ? Colors.redAccent.shade100 : Colors.white70,
                    fontWeight:
                        atrasada ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (atrasada) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ATRASADA',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
