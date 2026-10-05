import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dates.dart';
import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/animated_value.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/components/app_segmented.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/analytics.dart';
import '../../../domain/enums.dart';
import '../../bills/presentation/status_style.dart' show expenseTypeLabel;
import '../../../design_system/components/sync_light.dart';
import '../../backup/presentation/backup_sheet.dart';
import '../../export/presentation/export_sheet.dart';
import '../../shared/presentation/page_header.dart';
import '../../shared/presentation/period_selector.dart' show pickMonth;
import 'category_bars.dart';
import 'charts/chart_format.dart';
import 'charts/month_series_chart.dart';
import 'stat_tile.dart';

const _twoColumnsFrom = 900.0;

/// Análises: o que os dados inseridos mostram em um período. Só descreve; não recomenda.
class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final async = ref.watch(analyticsProvider);
    final categories = <String, CategoryRow>{for (final cat in ref.watch(categoriesProvider).value ?? <CategoryRow>[]) cat.id: cat};

    return ListView(
      padding: EdgeInsets.fromLTRB(Space.md, Space.lg + topInset(context), Space.md, 120),
      children: [
        PageHeader(
          'Análises',
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            const _CloudButton(),
            IconButton(
              key: const Key('export-open'),
              tooltip: 'Exportar dados',
              onPressed: () => showExportSheet(context),
              icon: const Icon(Icons.ios_share_rounded),
            ),
          ]),
        ),
        const SizedBox(height: Space.xs),
        Text('Análise dos dados que você inseriu. Não é recomendação financeira.', style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
        const SizedBox(height: Space.md),
        const _FilterBar(),
        const SizedBox(height: Space.md),
        async.when(
          // mantém o quadro anterior enquanto recarrega, sem pisca
          skipLoadingOnReload: true,
          loading: () => const Padding(padding: EdgeInsets.all(Space.xl), child: Center(child: CircularProgressIndicator())),
          error: (_, _) => const AppCard(child: Text('Não foi possível carregar as análises.')),
          data: (a) => a.hasData ? _Content(analytics: a, categories: categories) : const _Empty(),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      key: const Key('analytics-empty'),
      child: Column(children: [
        Icon(Icons.insights_rounded, size: 40, color: c.textSecondary),
        const SizedBox(height: Space.md),
        Text('Sem dados neste período.', style: AppText.headline(c.textPrimary)),
        const SizedBox(height: Space.xs),
        Text('Cadastre contas, rendas e investimentos para ver as análises.', textAlign: TextAlign.center, style: AppText.body(c.textSecondary)),
      ]),
    );
  }
}

// ── Filtro ──────────────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final f = ref.watch(analyticsFilterProvider);
    final months = ref.watch(analyticsMonthsProvider);
    final notifier = ref.read(analyticsFilterProvider.notifier);
    final first = parseYearMonth(months.first);
    final last = parseYearMonth(months.last);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppSegmented<AnalyticsPreset>(
        options: const [
          (AnalyticsPreset.m6, '6 meses'),
          (AnalyticsPreset.m12, '12 meses'),
          (AnalyticsPreset.m24, '24 meses'),
          (AnalyticsPreset.custom, 'Personalizado'),
        ],
        selected: f.preset,
        onChanged: notifier.selectPreset,
      ),
      if (f.preset == AnalyticsPreset.custom) ...[
        const SizedBox(height: Space.sm),
        Row(children: [
          Expanded(child: _MonthButton(keyValue: 'custom-start', label: 'De', value: parseYearMonth(f.customStart), onPick: (d) => notifier.setCustomStart(yearMonthOf(d)))),
          const SizedBox(width: Space.sm),
          Expanded(child: _MonthButton(keyValue: 'custom-end', label: 'Até', value: parseYearMonth(f.customEnd), onPick: (d) => notifier.setCustomEnd(yearMonthOf(d)))),
        ]),
      ],
      const SizedBox(height: Space.sm),
      Text(
        '${formatMonthYear(first)}${months.length > 1 ? ' a ${formatMonthYear(last)}' : ''} · ${months.length} ${months.length == 1 ? 'mês' : 'meses'} · inclui o mês atual, em andamento',
        key: const Key('period-caption'),
        style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5),
      ),
    ]);
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.keyValue, required this.label, required this.value, required this.onPick});
  final String keyValue;
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      key: Key(keyValue),
      onTap: () async {
        final d = await pickMonth(context, value);
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: c.border)),
        child: Row(children: [
          Text('$label ', style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
          Expanded(child: Text(formatMonthShort(value), style: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w700, fontSize: 14.5))),
          Icon(Icons.expand_more_rounded, size: 20, color: c.textSecondary),
        ]),
      ),
    );
  }
}

// ── Conteúdo ────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  const _Content({required this.analytics, required this.categories});
  final Analytics analytics;
  final Map<String, CategoryRow> categories;

  @override
  Widget build(BuildContext context) {
    final a = analytics;
    final c = context.colors;
    final months = [for (final m in a.months) m.yearMonth];
    final cards = <Widget>[
      _ChartCard(
        title: 'Evolução dos gastos',
        subtitle: 'Valor previsto das contas de cada mês',
        child: MonthSeriesChart(
          id: 'spending',
          months: months,
          kind: SeriesKind.line,
          series: [ChartSeries(label: 'Gastos', color: c.accent, values: [for (final m in a.months) m.spendingCents.toDouble()])],
          format: (v) => formatCents(v.round()),
          axisFormat: formatAxisMoney,
        ),
      ),
      _ChartCard(
        title: 'Gastos por categoria',
        subtitle: 'Parte de cada categoria no total do período',
        child: CategoryBars(shares: a.categories, categories: categories),
      ),
      _ChartCard(
        title: 'Fixos × variáveis × pontuais',
        subtitle: 'Gastos de cada mês por tipo',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MonthSeriesChart(
            id: 'types',
            months: months,
            kind: SeriesKind.stackedBars,
            series: [
              for (final (i, t) in ExpenseType.values.indexed)
                ChartSeries(
                  label: expenseTypeLabel(t),
                  color: [c.seriesA, c.seriesB, c.seriesC][i],
                  values: [for (final m in a.months) (m.byType[t] ?? 0).toDouble()],
                ),
            ],
            format: (v) => formatCents(v.round()),
            axisFormat: formatAxisMoney,
          ),
          const SizedBox(height: Space.md),
          _TypeSummary(analytics: a),
        ]),
      ),
      _ChartCard(
        title: 'Investimentos: planejado × realizado',
        subtitle: 'Meta do mês e o que foi investido',
        child: MonthSeriesChart(
          id: 'investments',
          months: months,
          kind: SeriesKind.groupedBars,
          series: [
            ChartSeries(label: 'Planejado', color: c.textSecondary.withValues(alpha: 0.4), values: [for (final m in a.months) m.investmentPlannedCents.toDouble()]),
            ChartSeries(label: 'Realizado', color: c.accent, values: [for (final m in a.months) m.investmentRealizedCents.toDouble()]),
          ],
          format: (v) => formatCents(v.round()),
          axisFormat: formatAxisMoney,
        ),
      ),
      _ChartCard(
        title: 'Renda',
        subtitle: 'Padrão ou valor do mês, mais as rendas lançadas',
        child: MonthSeriesChart(
          id: 'income',
          months: months,
          kind: SeriesKind.line,
          series: [ChartSeries(label: 'Renda', color: c.accent, values: [for (final m in a.months) m.incomeCents.toDouble()])],
          format: (v) => formatCents(v.round()),
          axisFormat: formatAxisMoney,
        ),
      ),
      _ChartCard(
        title: 'Taxa de poupança',
        subtitle: 'Investimentos realizados ÷ renda',
        trailing: a.savingsRate == null ? '—' : formatPercent(a.savingsRate!),
        trailingKey: const Key('savings-rate-period'),
        child: MonthSeriesChart(
          id: 'savings',
          months: months,
          kind: SeriesKind.line,
          series: [ChartSeries(label: 'Taxa', color: c.accent, values: [for (final m in a.months) m.savingsRate])],
          format: (v) => formatPercent(v),
          axisFormat: formatAxisPercent,
        ),
      ),
    ];

    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= _twoColumnsFrom;
      final tiles = _Tiles(analytics: a, wide: wide);
      if (!wide) {
        return Column(children: [
          tiles,
          for (final (i, card) in cards.indexed) ...[const SizedBox(height: Space.md), Reveal(index: i, child: card)],
        ]);
      }
      // duas colunas, alternando os cartões
      final left = [for (var i = 0; i < cards.length; i += 2) cards[i]];
      final right = [for (var i = 1; i < cards.length; i += 2) cards[i]];
      Widget col(List<Widget> l) => Expanded(
            child: Column(children: [
              for (final (i, w) in l.indexed) ...[if (i > 0) const SizedBox(height: Space.md), w],
            ]),
          );
      return Column(children: [
        tiles,
        const SizedBox(height: Space.md),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [col(left), const SizedBox(width: Space.md), col(right)]),
      ]);
    });
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.analytics, required this.wide});
  final Analytics analytics;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final a = analytics;
    final n = a.monthCount;
    final tiles = [
      StatTile(label: 'Gastos no período', value: formatCents(a.spendingCents), caption: '$n ${n == 1 ? 'mês' : 'meses'}', valueKey: const Key('stat-spending')),
      StatTile(label: 'Média mensal', value: formatCents(a.averageSpendingCents), caption: 'gastos por mês', valueKey: const Key('stat-average')),
      StatTile(label: 'Renda no período', value: formatCents(a.incomeCents), valueKey: const Key('stat-income')),
      StatTile(label: 'Investido (realizado)', value: formatCents(a.investmentRealizedCents), caption: 'meta ${formatCents(a.investmentPlannedCents)}', valueKey: const Key('stat-invested')),
      StatTile(label: 'Taxa de poupança', value: a.savingsRate == null ? '—' : formatPercent(a.savingsRate!), caption: 'investido ÷ renda', valueKey: const Key('stat-rate')),
    ];
    final perRow = wide ? 5 : 2;
    return LayoutBuilder(builder: (context, box) {
      final w = (box.maxWidth - Space.sm * (perRow - 1)) / perRow;
      return Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [for (final t in tiles) SizedBox(width: w, child: t)]);
    });
  }
}

class _TypeSummary extends StatelessWidget {
  const _TypeSummary({required this.analytics});
  final Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final colors = [c.seriesA, c.seriesB, c.seriesC];
    return Column(children: [
      for (final (i, t) in analytics.types.indexed)
        Padding(
          key: Key('type-row-${t.type.name}'),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], borderRadius: BorderRadius.circular(2.5))),
            const SizedBox(width: 8),
            Expanded(child: Text(expenseTypeLabel(t.type), style: AppText.body(c.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14))),
            Text(formatPercent(t.fraction), style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 112),
              child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: Text(formatCents(t.cents), maxLines: 1, style: AppText.number(c.textPrimary).copyWith(fontSize: 14.5))),
            ),
          ]),
        ),
    ]);
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.subtitle, required this.child, this.trailing, this.trailingKey});
  final String title;
  final String subtitle;
  final Widget child;
  final String? trailing;
  final Key? trailingKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.headline(c.textPrimary).copyWith(fontSize: 17)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppText.body(c.textSecondary).copyWith(fontSize: 12.5)),
            ]),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Space.sm),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(trailing!, key: trailingKey, style: AppText.number(c.textPrimary).copyWith(fontSize: 20)),
              Text('no período', style: AppText.body(c.textSecondary).copyWith(fontSize: 12)),
            ]),
          ],
        ]),
        const SizedBox(height: Space.md),
        child,
      ]),
    );
  }
}

/// Ícone de nuvem com a luz de sincronização no canto.
class _CloudButton extends ConsumerWidget {
  const _CloudButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = ref.watch(syncLightProvider);
    return IconButton(
      key: const Key('backup-open'),
      tooltip: 'Backup e sincronização: ${light.label}',
      onPressed: () => showBackupSheet(context),
      icon: Stack(clipBehavior: Clip.none, children: [
        const Icon(Icons.cloud_outlined),
        Positioned(right: -3, top: -3, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: context.colors.background, width: 2)), child: SyncLight(state: light.state, size: 9))),
      ]),
    );
  }
}
