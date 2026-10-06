import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/db/app_database.dart';
import '../../../design_system/components/animated_value.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/components/status_chip.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/bill.dart';
import '../../shared/presentation/category_icon.dart';
import 'range_text.dart';
import 'status_style.dart';

/// Item de lista: avatar da categoria, nome e vencimento, valor e estado. Toque com feedback próprio.
class BillTile extends StatelessWidget {
  const BillTile({super.key, required this.bill, required this.category, required this.today, required this.onTap});
  final Bill bill;
  final CategoryRow? category;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final st = styleFor(bill, today);
    final accent = Color(category?.color ?? 0xFF78716C);
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: isLight ? c.border.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent.withValues(alpha: 0.30), accent.withValues(alpha: 0.10)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Icon(categoryIcon(category?.icon), color: accent, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(bill.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w700, fontSize: 15.5))),
                  if (bill.favorite) ...[const SizedBox(width: 4), Icon(Icons.star_rounded, size: 16, color: c.warning, semanticLabel: 'Favorita')],
                  if (bill.isRecurring) ...[const SizedBox(width: 4), Icon(Icons.repeat_rounded, size: 15, color: c.textSecondary, semanticLabel: 'Recorrente')],
                ]),
                const SizedBox(height: 2),
                Text('${formatDayShort(bill.dueDate)} · ${category?.name ?? 'Sem categoria'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
              ]),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatCents(bill.plannedCents), style: AppText.number(c.textPrimary).copyWith(fontSize: 16))),
                const SizedBox(height: 5),
                StatusChip(label: st.label, tone: st.tone, icon: st.icon),
              ]),
            ),
          ]),
          if (bill.range != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.swap_vert_rounded, size: 15, color: c.textSecondary),
                const SizedBox(width: 4),
                Flexible(child: Text('Faixa ${formatRange(bill.range!)}', key: Key('tile-range-${bill.id}'), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5, fontWeight: FontWeight.w600))),
              ]),
            ),
          ],
          if (bill.isPartiallyPaid) ...[
            const SizedBox(height: 12),
            AppProgress(value: bill.paidFraction, color: c.info, track: c.surfaceAlt, height: 6),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Restam ${formatCents(bill.remainingCents)}',
                style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
