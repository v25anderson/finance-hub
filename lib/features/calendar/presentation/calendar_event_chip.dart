import 'package:flutter/material.dart';

import '../../../core/money.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/bill.dart';
import '../../../domain/calendar.dart';
import 'calendar_style.dart';

/// Conta dentro do dia (telas largas): nome e valor, com cor, ícone e barra lateral do estado.
class CalendarEventChip extends StatelessWidget {
  const CalendarEventChip({super.key, required this.bill, required this.tone, required this.onTap});
  final Bill bill;
  final CalendarTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final st = styleForCalendarTone(tone);
    final color = c.tone(st.tone);
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Semantics(
        button: true,
        label: '${bill.name}, ${formatCents(bill.plannedCents)}, ${st.label}',
        child: Material(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(Radii.sm - 2),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('cal-event-${tone.name}-${bill.id}'),
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(width: 3, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Row(children: [
                        if (st.icon != null) ...[Icon(st.icon, size: 11, color: color), const SizedBox(width: 3)],
                        Expanded(
                          child: Text(
                            bill.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(c.textPrimary).copyWith(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
                          ),
                        ),
                      ]),
                      Text(formatCents(bill.plannedCents), style: AppText.body(c.textSecondary).copyWith(fontSize: 11, height: 1.2)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
