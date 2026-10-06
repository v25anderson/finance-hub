import 'package:flutter/material.dart';

import '../../../design_system/components/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../core/dates.dart';
import '../../../core/formatting.dart';
import '../../../domain/month_plan.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/components/money_text.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../bills/presentation/ui_helpers.dart';
import '../../dashboard/presentation/dashboard_dialogs.dart';

/// Valores padrão **em vigor no mês selecionado**. Mudar vale a partir desse mês; os anteriores não mudam.
class DefaultsCard extends ConsumerWidget {
  const DefaultsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final ym = ref.watch(selectedYearMonthProvider);
    final timeline = ref.watch(defaultsTimelineProvider).value;
    final version = timeline?.versionAt(ym);
    final p = version?.defaults;
    final monthLabel = formatMonthYear(parseYearMonth(ym));
    Widget row(String label, int? cents) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.body(c.textSecondary))),
          if (cents == null) const Text('—') else Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: MoneyText(cents))),
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
            version == null ? 'Nada definido em $monthLabel.' : 'Desde ${formatMonthYear(parseYearMonth(version.effectiveFrom))}',
            key: const Key('defaults-vigencia'),
            style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: Space.md),
          row('Salário', p?.salaryCents),
          row('Renda extra', p?.extraIncomeCents),
          row('Economia', p?.savingsGoalCents),
          row('Investimento', p?.investmentCents),
          const SizedBox(height: Space.md),
          AppButton(
            label: 'Editar padrões',
            icon: Icons.edit_outlined,
            kind: AppButtonKind.tonal,
            expand: true,
            onPressed: timeline == null ? null : () => _edit(context, ref, ym, p ?? const PlanningDefaults()),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, String ym, PlanningDefaults p) async {
    final input = await showDefaultsDialog(
      context,
      fromLabel: formatMonthYear(parseYearMonth(ym)),
      salaryCents: p.salaryCents,
      extraCents: p.extraIncomeCents,
      savingsCents: p.savingsGoalCents,
      investmentCents: p.investmentCents,
    );
    if (input == null || !context.mounted) return;
    await runGuarded(
      context,
      () => ref
          .read(planningServiceProvider)
          .setDefaults(
            fromYearMonth: ym,
            salaryCents: input.salaryCents,
            extraIncomeCents: input.extraCents,
            savingsGoalCents: input.savingsCents,
            investmentCents: input.investmentCents,
          ),
    );
  }
}
