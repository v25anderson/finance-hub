import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Indicador de estado: cor + texto (+ ícone), nunca só cor.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone, this.icon});
  final String label;
  final Tone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.sm + 2, vertical: Space.xs + 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: Space.xs)],
        Text(label, style: AppText.label(color).copyWith(letterSpacing: 0.2)),
      ]),
    );
  }
}
