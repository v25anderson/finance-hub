import 'package:flutter/material.dart';

import '../../../../application/dashboard_data.dart';
import '../../../../core/formatting.dart';
import '../../../../core/money.dart';
import '../../../../data/db/app_database.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../dashboard_format.dart';

/// Mês atual × anterior. Só números: sem cores de "bom/ruim" nem interpretação.
class ComparisonCard extends StatelessWidget {
  const ComparisonCard({super.key, required this.data, required this.month, required this.categories});
  final DashboardData data;
  final DateTime month;
  final Map<String, CategoryRow> categories;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cmp = data.comparison;
    final prevName = formatMonthName(DateTime(month.year, month.month - 1).month).toLowerCase();
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel('Comparação com o mês anterior'),
        const SizedBox(height: Space.md),
        if (cmp.isEmpty)
          Text('Nenhum gasto neste mês nem em $prevName.', style: AppText.body(c.textSecondary))
        else ...[
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Icon(cmp.deltaCents == 0 ? Icons.drag_handle : (cmp.deltaCents > 0 ? Icons.arrow_upward : Icons.arrow_downward), size: 20, color: c.textSecondary),
            const SizedBox(width: Space.xs),
            Text(
              cmp.deltaFraction == null ? formatSigned(cmp.deltaCents) : formatSignedPercent(cmp.deltaFraction!),
              style: AppText.title(c.textPrimary),
            ),
            const SizedBox(width: Space.sm),
            Flexible(child: Text('vs $prevName', style: AppText.body(c.textSecondary))),
          ]),
          const SizedBox(height: Space.xs),
          Text(
            cmp.deltaFraction == null
                ? 'Sem gastos em $prevName para calcular o percentual.'
                : '${formatSigned(cmp.deltaCents)} (de ${formatCents(cmp.previousCents)} para ${formatCents(cmp.currentCents)})',
            style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
          ),
          if (cmp.topChanges.isNotEmpty) ...[
            const SizedBox(height: Space.lg),
            const SectionLabel('Maiores variações por categoria'),
            const SizedBox(height: Space.sm),
            for (final ch in cmp.topChanges)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.xs),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(categories[ch.categoryId]?.color ?? 0xFF78716C), shape: BoxShape.circle)),
                  const SizedBox(width: Space.sm),
                  Expanded(child: Text(categories[ch.categoryId]?.name ?? 'Sem categoria', style: AppText.body(c.textPrimary))),
                  Text(formatSigned(ch.deltaCents), style: AppText.number(c.textPrimary).copyWith(fontSize: 15)),
                ]),
              ),
          ],
        ],
      ]),
    );
  }
}
