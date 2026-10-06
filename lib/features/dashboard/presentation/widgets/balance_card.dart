import 'package:flutter/material.dart';

import '../../../../application/dashboard_data.dart';
import '../../../../core/money.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../dashboard_format.dart';

/// "Quanto sobra": renda − gastos pagos − pendentes − investimentos = saldo projetado,
/// com os três saldos (atual, após contas, após investimentos) claramente separados.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = data.balance;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel('Quanto sobra'),
        const SizedBox(height: Space.xs),
        Text(formatCents(b.projectedCents), key: const Key('balance-projected'), style: AppText.display(b.projectedCents < 0 ? c.danger : c.textPrimary).copyWith(fontSize: 36)),
        const SizedBox(height: Space.md),
        _Line('Renda', formatSigned(b.incomeCents), c.textPrimary),
        _Line('Gastos', formatSigned(-(b.paidCents + b.pendingCents)), c.textSecondary),
        _Line('Investimentos', formatSigned(-b.investmentProjectedCents), c.textSecondary),
        Divider(height: Space.lg * 1.5, color: c.border),
        _Balance('Saldo atual', b.currentCents, key: const Key('balance-current')),
        _Balance('Após contas', b.afterBillsCents, key: const Key('balance-after-bills')),
        _Balance('Após investimentos', b.projectedCents, key: const Key('balance-after-investments')),
      ]),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, this.color);
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Expanded(child: Text(label, style: AppText.body(context.colors.textSecondary))),
          Text(value, style: AppText.number(color).copyWith(fontSize: 16)),
        ]),
      );
}

class _Balance extends StatelessWidget {
  const _Balance(this.title, this.cents, {super.key});
  final String title;
  final int cents;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(title, style: AppText.body(c.textSecondary))),
        Text(formatCents(cents), style: AppText.number(cents < 0 ? c.danger : c.textPrimary).copyWith(fontSize: 16)),
      ]),
    );
  }
}
