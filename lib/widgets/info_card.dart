import 'package:flutter/material.dart';

/// Card genérico para exibir um par ícone + título + conteúdo.
class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String titulo;
  final String conteudo;
  final Color? conteudoColor;

  const InfoCard({
    super.key,
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
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
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
