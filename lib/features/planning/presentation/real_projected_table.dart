import 'package:flutter/material.dart';

import '../../../core/money.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';

/// Tabela "Real | Projeção": os dois ficam em colunas separadas e nunca são somados em silêncio.
class RealProjectedTable extends StatelessWidget {
  const RealProjectedTable({super.key, required this.rows});
  final List<({String label, int real, int projected})> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget cell(
      String text, {
      bool bold = false,
      Color? color,
      Alignment align = Alignment.centerRight,
    }) => Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: Space.sm),
        child: Align(
          alignment: align,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              style: AppText.body(color ?? c.textPrimary).copyWith(
                fontSize: 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            const Expanded(flex: 4, child: SizedBox()),
            cell('DADO REAL', color: c.textSecondary, bold: true),
            cell('PROJEÇÃO', color: c.textSecondary, bold: true),
          ],
        ),
        const SizedBox(height: Space.xs),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    r.label,
                    style: AppText.body(c.textSecondary).copyWith(fontSize: 14),
                  ),
                ),
                cell(
                  formatCents(r.real),
                  color: r.real == 0 ? c.textSecondary : c.textPrimary,
                ),
                cell(formatCents(r.projected)),
              ],
            ),
          ),
      ],
    );
  }
}
