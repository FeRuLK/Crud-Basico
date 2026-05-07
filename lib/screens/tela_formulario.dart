import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tarefa.dart';
import '../providers/tarefa_provider.dart';

class TelaFormulario extends StatefulWidget {
  const TelaFormulario({super.key});

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  DateTime _dataPrevista = DateTime.now().add(const Duration(days: 1));
  bool _importante = false;
  double _estimativaHoras = 1.0;

  Tarefa? _tarefaEdicao;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _tarefaEdicao =
          ModalRoute.of(context)?.settings.arguments as Tarefa?;
      if (_tarefaEdicao != null) {
        _tituloController.text = _tarefaEdicao!.titulo;
        _descricaoController.text = _tarefaEdicao!.descricao;
        _dataPrevista = _tarefaEdicao!.dataPrevista;
        _importante = _tarefaEdicao!.importante;
        _estimativaHoras = _tarefaEdicao!.estimativaHoras;
      }
      _inicializado = true;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataPrevista,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) setState(() => _dataPrevista = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TarefaProvider>();

    if (_tarefaEdicao == null) {
      await provider.inserir(Tarefa(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        dataPrevista: _dataPrevista,
        importante: _importante,
        estimativaHoras: _estimativaHoras,
      ));
    } else {
      await provider.atualizar(_tarefaEdicao!.copyWith(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        dataPrevista: _dataPrevista,
        importante: _importante,
        estimativaHoras: _estimativaHoras,
        // realizada NÃO é editável aqui — somente na tela de detalhes
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  String _formatarEstimativa(double horas) {
    if (horas < 1) {
      return '${(horas * 60).round()} min';
    } else if (horas == horas.roundToDouble()) {
      return '${horas.toInt()}h';
    } else {
      return '${horas.toStringAsFixed(1)}h';
    }
  }

  @override
  Widget build(BuildContext context) {
    final edicao = _tarefaEdicao != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(edicao ? 'Editar Tarefa' : 'Nova Tarefa'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Título ──────────────────────────────────────────────────
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ex: Comprar mantimentos',
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'O título é obrigatório.';
                  }
                  if (v.trim().length < 3) {
                    return 'O título deve ter ao menos 3 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Descrição ────────────────────────────────────────────────
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  hintText: 'Descreva a tarefa com detalhes...',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'A descrição é obrigatória.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Data Prevista ────────────────────────────────────────────
              InkWell(
                onTap: _selecionarData,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data prevista *',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_dataPrevista),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Estimativa de tempo ──────────────────────────────────────
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 20, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          const Text(
                            'Estimativa de tempo',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatarEstimativa(_estimativaHoras),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _estimativaHoras,
                        min: 0.5,
                        max: 24,
                        divisions: 47,
                        label: _formatarEstimativa(_estimativaHoras),
                        onChanged: (v) =>
                            setState(() => _estimativaHoras = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('30 min',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          Text('24h',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Importante ───────────────────────────────────────────────
              Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Marcar como importante'),
                  subtitle: const Text('A tarefa ficará destacada na lista'),
                  secondary: Icon(
                    _importante ? Icons.star : Icons.star_border,
                    color: _importante ? Colors.amber : Colors.grey,
                  ),
                  value: _importante,
                  onChanged: (v) => setState(() => _importante = v),
                ),
              ),
              const SizedBox(height: 24),

              // ── Botões ───────────────────────────────────────────────────
              FilledButton.icon(
                onPressed: _salvar,
                icon: Icon(edicao ? Icons.save : Icons.add_task),
                label: Text(
                  edicao ? 'Salvar alterações' : 'Criar tarefa',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
