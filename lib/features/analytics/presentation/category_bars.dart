import 'package:flutter/material.dart';

import '../../../core/money.dart';
import '../../../core/formatting.dart';
import '../../../data/db/app_database.dart';
import '../../../design_system/components/animated_value.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/analytics.dart';

const _maxRows = 8;

/// Gastos por categoria: barras horizontais ordenadas, uma única cor (a forma é a comparação de magnitudes;
/// a cor da categoria aparece só no marcador ao lado do nome). Acima de 8, o restante vira "Outras".
class CategoryBars extends StatelessWidget {
  const CategoryBars({super.key, required this.shares, required this.categories});
  final List<CategoryShare> shares;
  final Map<String, CategoryRow> categories;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final head = shares.take(_maxRows).toList();
    final tail = shares.skip(_maxRows).toList();
    final tailCents = tail.fold<int>(0, (s, e) => s + e.cents);
    final tailFraction = tail.fold<double>(0, (s, e) => s + e.fraction);
    final maxCents = shares.isEmpty ? 1 : shares.first.cents;

    Widget row({required Key key, required String name, required Color dot, required int cents, required double fraction, required Color bar}) => Padding(
          key: key,
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(children: [
            Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14))),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 64),
                child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatPercent(fraction), maxLines: 1, style: AppText.body(c.textSecondary).copyWith(fontSize: 13))),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 112),
                child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatCents(cents), maxLines: 1, style: AppText.number(c.textPrimary).copyWith(fontSize: 14.5))),
              ),
            ]),
            const SizedBox(height: 6),
            AppProgress(value: maxCents == 0 ? 0 : cents / maxCents, color: bar, track: c.surfaceAlt, height: 6),
          ]),
        );

    return Column(key: const Key('category-bars'), children: [
      for (final s in head)
        row(
          key: Key('category-row-${s.categoryId}'),
          name: categories[s.categoryId]?.name ?? 'Sem categoria',
          dot: Color(categories[s.categoryId]?.color ?? 0xFF78716C),
          cents: s.cents,
          fraction: s.fraction,
          bar: c.accent,
        ),
      if (tail.isNotEmpty)
        row(
          key: const Key('category-row-others'),
          name: 'Outras (${tail.length})',
          dot: c.textSecondary,
          cents: tailCents,
          fraction: tailFraction,
          bar: c.textSecondary.withValues(alpha: 0.5),
        ),
    ]);
  }
}
