import 'package:flutter/material.dart';

import '../../../../application/dashboard_data.dart';
import '../../../../core/formatting.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/money_text.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../dashboard_format.dart';

/// KPI principal: gastos do mês, pago × pendente e percentual quitado. Clicável.
class SpendingKpiCard extends StatelessWidget {
  const SpendingKpiCard({super.key, required this.data, required this.onTap});
  final DashboardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = data.summary;
    return AppCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: SectionLabel('Gastos do mês')),
          Icon(Icons.chevron_right, color: c.textSecondary, semanticLabel: 'Ver detalhes'),
        ]),
        const SizedBox(height: Space.sm),
        MoneyText(s.totalCents, size: MoneySize.display),
        const SizedBox(height: Space.lg),
        if (s.isEmpty)
          Text('Nenhuma conta neste mês.', style: AppText.body(c.textSecondary))
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(value: s.paidFraction, minHeight: 10, backgroundColor: c.surfaceAlt, color: c.success),
          ),
          const SizedBox(height: Space.md),
          Row(children: [
            Expanded(child: _Part('Pago', s.paidCents, Tone.success)),
            Expanded(child: _Part('Pendente', s.pendingCents, s.pendingCents > 0 ? Tone.warning : Tone.neutral)),
          ]),
          const SizedBox(height: Space.md),
          Wrap(spacing: Space.md, children: [
            Text('${formatPercent(s.paidFraction)} quitado', style: AppText.number(c.textPrimary).copyWith(fontSize: 15)),
            Text('${formatPercent(s.remainingFraction)} restante', style: AppText.body(c.textSecondary)),
          ]),
          if (s.excessCents > 0) ...[
            const SizedBox(height: Space.sm),
            Text('Pago além do previsto: ${formatSigned(s.excessCents)}', style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
          ],
        ],
      ]),
    );
  }
}

class _Part extends StatelessWidget {
  const _Part(this.label, this.cents, this.tone);
  final String label;
  final int cents;
  final Tone tone;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionLabel(label),
        const SizedBox(height: Space.xs),
        MoneyText(cents, tone: tone),
      ]);
}
