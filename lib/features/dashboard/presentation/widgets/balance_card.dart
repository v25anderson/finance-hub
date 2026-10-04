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
        const SizedBox(height: Space.md),
        _Line('Renda', formatSigned(b.incomeCents), c.textPrimary),
        _Line('Gastos pagos', formatSigned(-b.paidCents), c.textSecondary),
        _Line('Gastos pendentes', formatSigned(-b.pendingCents), c.textSecondary),
        _Line('Investimentos', formatSigned(-b.investmentProjectedCents), c.textSecondary),
        Divider(height: Space.lg * 1.5, color: c.border),
        const SectionLabel('Saldo projetado'),
        const SizedBox(height: Space.xs),
        Text(formatCents(b.projectedCents), key: const Key('balance-projected'), style: AppText.display(b.projectedCents < 0 ? c.danger : c.textPrimary).copyWith(fontSize: 36)),
        const SizedBox(height: Space.md),
        _Balance('Saldo atual', 'renda − pagos − investimentos realizados', b.currentCents, key: const Key('balance-current')),
        _Balance('Se todas as pendentes forem pagas', 'saldo após contas', b.afterBillsCents, key: const Key('balance-after-bills')),
        _Balance('Saldo após investimentos planejados', 'restante da meta descontado', b.projectedCents, key: const Key('balance-after-investments')),
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
  const _Balance(this.title, this.subtitle, this.cents, {super.key});
  final String title, subtitle;
  final int cents;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs + 1),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.body(c.textPrimary).copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(subtitle, style: AppText.body(c.textSecondary).copyWith(fontSize: 12)),
          ]),
        ),
        const SizedBox(width: Space.sm),
        Text(formatCents(cents), style: AppText.number(cents < 0 ? c.danger : c.textPrimary).copyWith(fontSize: 16)),
      ]),
    );
  }
}
