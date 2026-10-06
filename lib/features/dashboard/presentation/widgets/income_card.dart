import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/dashboard_data.dart';
import '../../../../core/dates.dart';
import '../../../../core/formatting.dart';
import '../../../../data/providers.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/money_text.dart';
import '../../../../design_system/components/status_chip.dart';
import '../../../../design_system/tokens/colors.dart';
import '../../../../design_system/tokens/spacing.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../bills/presentation/ui_helpers.dart';
import '../../../../data/db/app_database.dart';
import '../dashboard_dialogs.dart';
import 'entry_rows.dart';

class IncomeCard extends ConsumerWidget {
  const IncomeCard({super.key, required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plan = data.plan;
    final entries = ref.watch(incomesProvider(data.yearMonth)).value ?? const <IncomeRow>[];
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
                  'Total',
                  style: AppText.body(c.textPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              MoneyText(plan.totalIncomeCents, key: const Key('income-total')),
            ],
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            const SectionLabel('Lançamentos do mês'),
            const SizedBox(height: Space.xs),
            for (final e in entries)
              EntryRow(
                key: Key('income-entry-${e.id}'),
                title: e.description.isNotEmpty ? e.description : incomeKindLabel(e.kind),
                subtitle: e.description.isNotEmpty ? incomeKindLabel(e.kind) : null,
                cents: e.amountCents,
                removeTooltip: 'Desfazer lançamento',
                onRemove: () => removeWithUndo(
                  context,
                  remove: () => ref.read(incomeInvestmentServiceProvider).removeIncome(e.id),
                  restore: () => ref.read(incomeInvestmentServiceProvider).restoreIncome(e.id),
                  message: 'Lançamento de renda removido',
                ),
              ),
          ],
          const SizedBox(height: Space.md),
          Row(
            children: [
              Expanded(child: AppButton(label: 'Adicionar renda', icon: Icons.add_rounded, kind: AppButtonKind.primary, expand: true, onPressed: () => _addIncome(context, ref))),
              const SizedBox(width: Space.sm),
              Expanded(child: AppButton(label: 'Valores padrão', icon: Icons.tune_rounded, kind: AppButtonKind.tonal, expand: true, onPressed: () => _editDefaults(context, ref))),
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
    final timeline = await ref.read(planningRepositoryProvider).getDefaultsTimeline();
    final p = timeline.atOrZero(data.yearMonth);
    if (!context.mounted) return;
    final input = await showDefaultsDialog(
      context,
      fromLabel: formatMonthYear(parseYearMonth(data.yearMonth)),
      salaryCents: p.salaryCents,
      extraCents: p.extraIncomeCents,
      savingsCents: p.savingsGoalCents,
      investmentCents: p.investmentCents,
    );
    if (input == null || !context.mounted) return;
    await runGuarded(
      context,
      () => ref
          .read(incomeInvestmentServiceProvider)
          .setDefaults(
            fromYearMonth: data.yearMonth,
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
