import 'package:flutter/material.dart';

/// Badge visual que indica ativo/inativo com ícone e cor.
class StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool ativo;
  final Color corAtivo;

  const StatusBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.ativo,
    required this.corAtivo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ativo ? corAtivo.withValues(alpha: 0.15) : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ativo ? corAtivo : Colors.grey, size: 20),
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
