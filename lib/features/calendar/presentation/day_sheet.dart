import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/adaptive_sheet.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/calendar.dart';
import '../../bills/presentation/bill_detail_sheet.dart';
import '../../bills/presentation/bill_tile.dart';

/// Lista completa de um dia (usada pelo "+N mais" nas telas largas).
Future<void> showDaySheet(BuildContext context, CalendarDay day) =>
    showAdaptiveSheet<void>(context, builder: (_) => DaySheet(day: day));

class DaySheet extends ConsumerWidget {
  const DaySheet({super.key, required this.day});
  final CalendarDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final today = ref.watch(todayProvider);
    final categories = <String, CategoryRow>{for (final cat in ref.watch(categoriesProvider).value ?? <CategoryRow>[]) cat.id: cat};
    return ListView(padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.xl), children: [
      Row(children: [
        Expanded(child: Text(formatDayLong(day.date), style: AppText.title(c.textPrimary))),
        IconButton(tooltip: 'Fechar', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ]),
      Text('${day.bills.length} ${day.bills.length == 1 ? 'conta' : 'contas'} · ${formatCents(day.totalCents)}', style: AppText.body(c.textSecondary)),
      const SizedBox(height: Space.md),
      for (final b in day.bills)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.sm),
          child: BillTile(bill: b, category: categories[b.categoryId], today: today, onTap: () => showBillDetail(context, b.id)),
        ),
    ]);
  }
}
