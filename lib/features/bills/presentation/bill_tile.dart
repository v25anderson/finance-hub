import 'package:flutter/material.dart';

import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/db/app_database.dart';
import '../../../design_system/components/money_text.dart';
import '../../../design_system/components/status_chip.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/bill.dart';
import 'status_style.dart';

/// Linha de conta: nome, valor, vencimento, categoria, status e indicador visual.
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
    final showPartial = bill.isPartiallyPaid;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 5, color: c.tone(st.tone)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Space.md),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(
                      child: Row(children: [
                        Flexible(child: Text(bill.name, overflow: TextOverflow.ellipsis, style: AppText.number(c.textPrimary))),
                        if (bill.favorite) ...[
                          const SizedBox(width: Space.xs),
                          Icon(Icons.star_rounded, size: 18, color: c.warning, semanticLabel: 'Favorita'),
                        ],
                        if (bill.isRecurring) ...[
                          const SizedBox(width: Space.xs),
                          Icon(Icons.repeat, size: 16, color: c.textSecondary, semanticLabel: 'Recorrente'),
                        ],
                      ]),
                    ),
                    MoneyText(bill.plannedCents),
                  ]),
                  const SizedBox(height: Space.xs),
                  Row(children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                    const SizedBox(width: Space.xs + 2),
                    Expanded(
                      child: Text(
                        '${formatDayShort(bill.dueDate)} · ${category?.name ?? 'Sem categoria'}',
                        style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
                      ),
                    ),
                    StatusChip(label: st.label, tone: st.tone, icon: st.icon),
                  ]),
                  if (showPartial) ...[
                    const SizedBox(height: Space.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.pill),
                      child: LinearProgressIndicator(
                        value: bill.paidFraction,
                        minHeight: 5,
                        backgroundColor: c.surfaceAlt,
                        color: c.info,
                      ),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      'Pago ${formatCents(bill.paidCents)} · restam ${formatCents(bill.remainingCents)} · ${formatPercent(bill.paidFraction)}',
                      style: AppText.body(c.textSecondary).copyWith(fontSize: 12),
                    ),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
