import 'package:flutter/material.dart';

import '../../../design_system/components/app_card.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// Indicador do período: rótulo, valor (auto-ajustado ao espaço) e legenda opcional.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.caption, this.valueKey});
  final String label;
  final String value;
  final String? caption;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(Space.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, key: valueKey, maxLines: 1, style: AppText.number(c.textPrimary).copyWith(fontSize: 21))),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(caption!, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textSecondary).copyWith(fontSize: 12)),
        ],
      ]),
    );
  }
}
