import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/dashboard_data.dart';
import '../../../../data/providers.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/money_text.dart';
import '../../../../design_system/components/status_chip.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../bills/presentation/ui_helpers.dart';
import '../dashboard_dialogs.dart';

class IncomeCard extends ConsumerWidget {
  const IncomeCard({super.key, required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plan = data.plan;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionLabel('Renda')),
              if (plan.customized)
                const StatusChip(
                  label: 'Mês personalizado',
                  tone: Tone.info,
                  icon: Icons.tune,
                ),
            ],
          ),
          const SizedBox(height: Space.md),
          _Row('Salário líquido', plan.salaryCents),
          _Row('Renda extra', plan.extraCents),
          _Row('Outras rendas', plan.otherCents),
          Divider(height: Space.lg, color: c.border),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Renda total',
                  style: AppText.body(c.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              MoneyText(plan.totalIncomeCents, key: const Key('income-total')),
            ],
          ),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _addIncome(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar renda'),
              ),
              TextButton(
                onPressed: () => _editDefaults(context, ref),
                child: const Text('Valores padrão'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addIncome(BuildContext context, WidgetRef ref) async {
    final input = await showAddIncomeDialog(context);
    if (input == null || !context.mounted) return;
    await runGuarded(
      context,
      () => ref
          .read(incomeInvestmentServiceProvider)
          .addIncome(data.yearMonth, input.kind, input.cents),
    );
  }

  Future<void> _editDefaults(BuildContext context, WidgetRef ref) async {
    final p = await ref.read(planningRepositoryProvider).getPlanning();
    if (!context.mounted) return;
    final input = await showDefaultsDialog(
      context,
      salaryCents: p.defaultSalaryCents,
      extraCents: p.defaultExtraIncomeCents,
      savingsCents: p.defaultSavingsGoalCents,
      investmentCents: p.defaultInvestmentCents,
    );
    if (input == null || !context.mounted) return;
    await runGuarded(
      context,
      () => ref
          .read(incomeInvestmentServiceProvider)
          .setDefaults(
            salaryCents: input.salaryCents,
            extraIncomeCents: input.extraCents,
            savingsGoalCents: input.savingsCents,
            investmentCents: input.investmentCents,
          ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.cents);
  final String label;
  final int cents;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: AppText.body(context.colors.textSecondary)),
        ),
        MoneyText(cents),
      ],
    ),
  );
}
