import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tarefa.dart';

class TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.onTap,
    required this.onToggle,
    required this.onEditar,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    final dataFormatada = DateFormat('dd/MM/yyyy').format(tarefa.dataPrevista);
    final atrasada =
        !tarefa.realizada && tarefa.dataPrevista.isBefore(DateTime.now());
    final estimativa = tarefa.estimativaHoras == tarefa.estimativaHoras.roundToDouble()
        ? '${tarefa.estimativaHoras.toInt()}h'
        : '${tarefa.estimativaHoras.toStringAsFixed(1)}h';

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
            Icon(Icons.calendar_today,
                size: 12, color: atrasada ? Colors.red : Colors.grey),
            const SizedBox(width: 4),
            Text(
              dataFormatada,
              style: TextStyle(
                fontSize: 12,
                color: atrasada ? Colors.red : Colors.grey.shade600,
                fontWeight: atrasada ? FontWeight.bold : FontWeight.normal,
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
            const Spacer(),
            const Icon(Icons.timer_outlined, size: 12, color: Colors.blueGrey),
            const SizedBox(width: 2),
            Text(
              estimativa,
              style:
                  const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
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
                title: Text('Excluir', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
