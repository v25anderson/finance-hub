import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/components/money_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../bills/presentation/ui_helpers.dart';
import '../../dashboard/presentation/dashboard_dialogs.dart';

/// Valores padrão (valem para todos os meses que não foram personalizados).
class DefaultsCard extends ConsumerWidget {
  const DefaultsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final p = ref.watch(planningProvider).value;
    Widget row(String label, int? cents) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.body(c.textSecondary))),
          if (cents == null) const Text('—') else MoneyText(cents),
        ],
      ),
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Valores padrão'),
          const SizedBox(height: Space.xs),
          Text(
            'Valem para todos os meses que não foram personalizados.',
            style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: Space.md),
          row('Salário líquido padrão', p?.defaultSalaryCents),
          row('Renda extra padrão', p?.defaultExtraIncomeCents),
          row('Meta de economia padrão', p?.defaultSavingsGoalCents),
          row('Investimento planejado padrão', p?.defaultInvestmentCents),
          const SizedBox(height: Space.md),
          OutlinedButton.icon(
            onPressed: p == null ? null : () => _edit(context, ref, p),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar padrões'),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, PlanningRow p) async {
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
          .read(planningServiceProvider)
          .setDefaults(
            salaryCents: input.salaryCents,
            extraIncomeCents: input.extraCents,
            savingsGoalCents: input.savingsCents,
            investmentCents: input.investmentCents,
          ),
    );
  }
}
