import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/tarefa.dart';

class TelaFormulario extends StatefulWidget {
  const TelaFormulario({super.key});

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  DateTime _dataPrevista = DateTime.now().add(const Duration(days: 1));
  bool _importante = false;
  bool _realizada = false;

  Tarefa? _tarefaEdicao; // null = nova tarefa
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recebe a tarefa via arguments (null = modo criação)
    if (!_inicializado) {
      _tarefaEdicao =
          ModalRoute.of(context)?.settings.arguments as Tarefa?;
      if (_tarefaEdicao != null) {
        _tituloController.text = _tarefaEdicao!.titulo;
        _descricaoController.text = _tarefaEdicao!.descricao;
        _dataPrevista = _tarefaEdicao!.dataPrevista;
        _importante = _tarefaEdicao!.importante;
        _realizada = _tarefaEdicao!.realizada;
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
    if (picked != null) {
      setState(() => _dataPrevista = picked);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tarefaEdicao == null) {
      // Criar nova
      final nova = Tarefa(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        dataPrevista: _dataPrevista,
        importante: _importante,
        realizada: _realizada,
      );
      await _db.inserir(nova);
    } else {
      // Atualizar existente
      final atualizada = _tarefaEdicao!.copyWith(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        dataPrevista: _dataPrevista,
        importante: _importante,
        realizada: _realizada,
      );
      await _db.atualizar(atualizada);
    }

    if (mounted) Navigator.pop(context);
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
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
              const SizedBox(height: 8),

              // ── Realizada ────────────────────────────────────────────────
              Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Marcar como realizada'),
                  subtitle: const Text('A tarefa será exibida como concluída'),
                  secondary: Icon(
                    _realizada
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: _realizada ? Colors.green : Colors.grey,
                  ),
                  value: _realizada,
                  onChanged: (v) => setState(() => _realizada = v),
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
