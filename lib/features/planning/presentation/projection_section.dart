import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/components/app_segmented.dart';
import '../../../design_system/components/money_text.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/components/status_chip.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/projection.dart';
import 'hatched_bar.dart';
import 'projection_month_sheet.dart';
import 'real_projected_table.dart';

DateTime ymToDate(String ym) {
  final p = ym.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]));
}

/// Projeções: mês atual, 3, 6 ou 12 meses (contando o atual). Dado real e projeção ficam sempre separados.
class ProjectionSection extends ConsumerWidget {
  const ProjectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final range = ref.watch(projectionRangeProvider);
    final async = ref.watch(projectionProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Projeções', style: AppText.headline(c.textPrimary)),
        const SizedBox(height: Space.xs),
        Text(
          'Sólido: real · hachurado: projeção',
          style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
        ),
        const SizedBox(height: Space.md),
        AppSegmented<int>(
          options: const [
            (1, 'Mês atual'),
            (3, '3 meses'),
            (6, '6 meses'),
            (12, '12 meses'),
          ],
          selected: range,
          onChanged: (v) => ref.read(projectionRangeProvider.notifier).set(v),
        ),
        const SizedBox(height: Space.md),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(Space.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const AppCard(
            child: Text('Não foi possível calcular a projeção.'),
          ),
          data: (p) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Summary(projection: p),
              const SizedBox(height: Space.md),
              const _Legend(),
              const SizedBox(height: Space.md),
              for (final m in p.months)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.sm),
                  child: _MonthRow(month: m),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.projection});
  final Projection projection;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = projection;
    final first = ymToDate(p.months.first.yearMonth);
    final last = ymToDate(p.months.last.yearMonth);
    final n = p.months.length;
    return AppCard(
      key: const Key('projection-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionLabel('Saldo projetado no período')),
              const StatusChip(
                label: 'Projeção',
                tone: Tone.neutral,
                icon: Icons.auto_graph_rounded,
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          MoneyText(
            p.balanceCents,
            size: MoneySize.display,
            tone: p.balanceCents < 0 ? Tone.danger : null,
            key: const Key('projection-total-balance'),
          ),
          const SizedBox(height: Space.xs),
          Text(
            n == 1
                ? formatMonthYear(first)
                : '$n meses · ${formatMonthShort(first)} a ${formatMonthShort(last)}',
            style: AppText.body(c.textSecondary).copyWith(fontSize: 13),
          ),
          const SizedBox(height: Space.lg),
          RealProjectedTable(
            rows: [
              (
                label: 'Renda',
                real: p.incomeRealCents,
                projected: p.incomeProjectedCents,
              ),
              (
                label: 'Gastos',
                real: p.spendingRealCents,
                projected: p.spendingProjectedCents,
              ),
              (
                label: 'Investimentos',
                real: p.investmentRealCents,
                projected: p.investmentProjectedCents,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget dot(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(c.textSecondary)
                .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
    return Wrap(
      spacing: Space.md,
      runSpacing: Space.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const RealProjectedLegend(),
        dot(c.accent, 'Gastos'),
        dot(c.info, 'Investimentos'),
        dot(c.success, 'Sobra'),
      ],
    );
  }
}

/// Segmentos da barra: como a renda do mês se divide (ou, com saldo negativo, o total de saídas).
List<BarSegment> segmentsFor(ProjectionMonth m, AppColors c) => [
  BarSegment(m.spendingRealCents, c.accent, projected: false),
  BarSegment(m.spendingProjectedCents, c.accent, projected: true),
  BarSegment(m.investmentRealCents, c.info, projected: false),
  BarSegment(m.investmentProjectedCents, c.info, projected: true),
  if (m.balanceCents > 0)
    BarSegment(m.balanceCents, c.success, projected: true),
];

class _MonthRow extends StatelessWidget {
  const _MonthRow({required this.month});
  final ProjectionMonth month;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final m = month;
    final outflow = m.spendingCents + m.investmentCents;
    final deficit = m.balanceCents < 0;
    return Pressable(
      onTap: () => showProjectionMonth(context, m),
      scale: 0.985,
      child: Container(
        key: Key('projection-row-${m.yearMonth}'),
        padding: const EdgeInsets.all(Space.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: c.border.withValues(alpha: 0.8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatMonthYear(ymToDate(m.yearMonth)),
                        style: AppText.body(
                          c.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
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
                    ],
                  ),
                ),
                const SizedBox(width: Space.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCents(m.balanceCents),
                      key: Key('projection-balance-${m.yearMonth}'),
                      style: AppText.number(deficit ? c.danger : c.textPrimary)
                          .copyWith(fontSize: 18),
                    ),
                    Text(
                      'saldo projetado',
                      style: AppText.body(c.textSecondary)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            Semantics(
              label:
                  'Renda ${formatCents(m.incomeCents)}, gastos ${formatCents(m.spendingCents)}, investimentos ${formatCents(m.investmentCents)}',
              child: HatchedBar(
                segments: segmentsFor(m, c),
                markerFraction: deficit && outflow > 0
                    ? m.incomeCents / outflow
                    : null,
              ),
            ),
            const SizedBox(height: Space.sm),
            Text(
              'Renda ${formatCents(m.incomeCents)} · Gastos ${formatCents(m.spendingCents)} · Invest. ${formatCents(m.investmentCents)}',
              style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}
