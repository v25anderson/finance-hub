import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/dashboard_data.dart';
import '../../../../core/formatting.dart';
import '../../../../core/money.dart';
import '../../../../data/providers.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/money_text.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../bills/presentation/ui_helpers.dart';
import '../../../../data/db/app_database.dart';
import '../dashboard_dialogs.dart';
import 'entry_rows.dart';
import '../../../../design_system/components/app_snack.dart';

class InvestmentCard extends ConsumerWidget {
  const InvestmentCard({super.key, required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final p = data.plan;
    final hasTarget = p.investmentTargetCents > 0;
    final gap = p.investmentGapCents;
    final entries = ref.watch(investmentsProvider(data.yearMonth)).value ?? const <InvestmentRow>[];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel('Investimentos'),
        const SizedBox(height: Space.md),
        Row(children: [
          Expanded(child: _Part('Meta', p.investmentTargetCents)),
          Expanded(child: _Part('Realizado', p.investmentRealizedCents, tone: Tone.success)),
        ]),
        const SizedBox(height: Space.md),
        if (hasTarget) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(value: p.investmentFraction.clamp(0.0, 1.0), minHeight: 8, backgroundColor: c.surfaceAlt, color: c.success),
          ),
          const SizedBox(height: Space.xs),
          Text('${formatPercent(p.investmentFraction)} da meta', key: const Key('investment-percent'), style: AppText.number(c.textPrimary).copyWith(fontSize: 15)),
          const SizedBox(height: Space.xs),
          Text(
            gap > 0
                ? 'Diferença: faltam ${formatCents(gap)}'
                : gap == 0
                    ? 'Meta atingida'
                    : 'Meta superada em ${formatCents(-gap)}',
            style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
          ),
          Text('Projeção do mês, se a meta for cumprida: ${formatCents(p.investmentProjectedCents)}',
              style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
        ] else
          Text('Sem meta neste mês. Defina em Renda › Valores padrão.', style: AppText.body(c.textSecondary)),
        if (entries.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          const SectionLabel('Lançamentos do mês'),
          const SizedBox(height: Space.xs),
          for (final e in entries)
            EntryRow(
              key: Key('investment-entry-${e.id}'),
              title: e.description.isNotEmpty ? e.description : 'Investimento realizado',
              cents: e.realizedCents,
              removeTooltip: 'Desfazer lançamento',
              onRemove: () => removeWithUndo(
                context,
                remove: () => ref.read(incomeInvestmentServiceProvider).removeInvestment(e.id),
                restore: () => ref.read(incomeInvestmentServiceProvider).restoreInvestment(e.id),
                message: 'Lançamento de investimento removido',
              ),
            ),
        ],
        const SizedBox(height: Space.md),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (gap > 0) ...[
            AppButton(label: 'Marcar meta como realizada', icon: Icons.check_rounded, kind: AppButtonKind.primary, expand: true, onPressed: () => _registerWithUndo(context, ref, gap)),
            const SizedBox(height: Space.sm),
          ],
          AppButton(label: 'Registrar investimento', icon: Icons.add_rounded, kind: AppButtonKind.tonal, expand: true, onPressed: () => _custom(context, ref)),
        ]),
      ]),
    );
  }

  /// "Marcar meta como realizada" é um toque só: oferece desfazer na hora, caso tenha sido sem querer.
  Future<void> _registerWithUndo(BuildContext context, WidgetRef ref, int cents) async {
    final svc = ref.read(incomeInvestmentServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    String? id;
    final done = await runGuarded(context, () async => id = await svc.registerInvestment(data.yearMonth, cents));
    if (!done || id == null) return;
    showAppSnack(messenger, 'Meta marcada como realizada', actionLabel: 'Desfazer', onAction: () => svc.removeInvestment(id!));
  }

  Future<void> _register(BuildContext context, WidgetRef ref, int cents) =>
      runGuarded(context, () => ref.read(incomeInvestmentServiceProvider).registerInvestment(data.yearMonth, cents));

  Future<void> _custom(BuildContext context, WidgetRef ref) async {
    final gap = data.plan.investmentGapCents;
    final cents = await showAmountDialog(
      context,
      title: 'Registrar investimento',
      confirmLabel: 'Registrar',
      initialCents: gap > 0 ? gap : null,
      hint: 'Valor realmente investido neste mês.',
    );
    if (cents == null || !context.mounted) return;
    await _register(context, ref, cents);
  }
}

class _Part extends StatelessWidget {
  const _Part(this.label, this.cents, {this.tone});
  final String label;
  final int cents;
  final Tone? tone;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionLabel(label),
        const SizedBox(height: Space.xs),
        MoneyText(cents, tone: tone),
      ]);
}
