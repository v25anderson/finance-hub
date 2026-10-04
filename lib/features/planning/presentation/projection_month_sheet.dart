import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../design_system/components/adaptive_sheet.dart';
import '../../../design_system/components/app_card.dart' show SectionLabel;
import '../../../design_system/components/money_text.dart';
import '../../../design_system/components/status_chip.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/projection.dart';
import 'hatched_bar.dart';
import 'projection_section.dart';
import 'real_projected_table.dart';

Future<void> showProjectionMonth(BuildContext context, ProjectionMonth month) =>
    showAdaptiveSheet<void>(
      context,
      builder: (_) => ProjectionMonthSheet(month: month),
    );

/// Detalhe de um mês projetado: real e projeção em colunas separadas, saldo e meta de economia.
class ProjectionMonthSheet extends ConsumerWidget {
  const ProjectionMonthSheet({super.key, required this.month});
  final ProjectionMonth month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final m = month;
    final date = ymToDate(m.yearMonth);
    final gap = m.savingsGapCents;
    final deficit = m.balanceCents < 0;
    final outflow = m.spendingCents + m.investmentCents;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.sm,
        Space.lg,
        Space.xl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                formatMonthYear(date),
                style: AppText.title(c.textPrimary),
              ),
            ),
            IconButton(
              tooltip: 'Fechar',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            if (m.hasRealData)
              const StatusChip(
                label: 'Real + projeção',
                tone: Tone.info,
                icon: Icons.timelapse,
              )
            else
              const StatusChip(
                label: 'Projeção',
                tone: Tone.neutral,
                icon: Icons.auto_graph_rounded,
              ),
            if (m.customized)
              const StatusChip(
                label: 'Personalizado',
                tone: Tone.info,
                icon: Icons.tune,
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        const SectionLabel('Saldo projetado do mês'),
        const SizedBox(height: Space.xs),
        MoneyText(
          m.balanceCents,
          size: MoneySize.display,
          tone: deficit ? Tone.danger : null,
        ),
        const SizedBox(height: Space.md),
        HatchedBar(
          height: 16,
          segments: segmentsFor(m, c),
          markerFraction: deficit && outflow > 0
              ? m.incomeCents / outflow
              : null,
        ),
        const SizedBox(height: Space.sm),
        const RealProjectedLegend(),
        const SizedBox(height: Space.lg),
        RealProjectedTable(
          rows: [
            (
              label: 'Renda',
              real: m.incomeRealCents,
              projected: m.incomeProjectedCents,
            ),
            (
              label: 'Gastos',
              real: m.spendingRealCents,
              projected: m.spendingProjectedCents,
            ),
            (
              label: 'Investimentos',
              real: m.investmentRealCents,
              projected: m.investmentProjectedCents,
            ),
          ],
        ),
        const SizedBox(height: Space.lg),
        if (gap != null) ...[
          const SectionLabel('Meta de economia'),
          const SizedBox(height: Space.xs),
          Text(
            'Meta ${formatCents(m.savingsGoalCents)} · saldo projetado ${formatCents(m.balanceCents)} · '
            '${gap > 0
                ? '${formatCents(gap)} acima da meta'
                : gap < 0
                ? '${formatCents(-gap)} abaixo da meta'
                : 'igual à meta'}',
            key: const Key('savings-gap-text'),
            style: AppText.body(c.textPrimary),
          ),
          const SizedBox(height: Space.lg),
        ],
        OutlinedButton.icon(
          key: const Key('edit-month-plan'),
          onPressed: () {
            ref.read(selectedMonthProvider.notifier).set(date.year, date.month);
            Navigator.pop(context);
          },
          icon: const Icon(Icons.tune, size: 18),
          label: const Text('Editar planejamento deste mês'),
        ),
      ],
    );
  }
}
