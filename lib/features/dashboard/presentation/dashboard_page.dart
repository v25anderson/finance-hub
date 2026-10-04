import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../shared/presentation/period_selector.dart';
import 'month_detail_sheet.dart';
import 'widgets/alerts_card.dart';
import 'widgets/balance_card.dart';
import 'widgets/comparison_card.dart';
import 'widgets/income_card.dart';
import 'widgets/investment_card.dart';
import 'widgets/spending_kpi_card.dart';

/// Largura mínima do conteúdo para usar duas colunas.
const _twoColumnsFrom = 880.0;

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final month = ref.watch(selectedMonthProvider);
    final ym = ref.watch(selectedYearMonthProvider);
    final async = ref.watch(dashboardProvider(ym));
    final categories = {for (final cat in ref.watch(categoriesProvider).value ?? <CategoryRow>[]) cat.id: cat};

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.md, Space.lg, Space.md, 120),
      children: [
        Row(children: [Expanded(child: Text('Visão geral', style: AppText.title(c.textPrimary)))]),
        const Align(alignment: Alignment.centerLeft, child: PeriodSelector()),
        const SizedBox(height: Space.md),
        async.when(
          loading: () => const Padding(padding: EdgeInsets.all(Space.xl), child: Center(child: CircularProgressIndicator())),
          error: (_, _) => const AppCard(child: Text('Não foi possível carregar os dados do mês.')),
          data: (d) => LayoutBuilder(builder: (context, box) {
            final left = <Widget>[
              SpendingKpiCard(data: d, onTap: () => showMonthDetail(context, month)),
              ComparisonCard(data: d, month: month, categories: categories),
              AlertsCard(alerts: d.alerts),
            ];
            final right = <Widget>[BalanceCard(data: d), IncomeCard(data: d), InvestmentCard(data: d)];
            if (box.maxWidth >= _twoColumnsFrom) {
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _Stack(left)),
                const SizedBox(width: Space.md),
                Expanded(child: _Stack(right)),
              ]);
            }
            // Celular: alertas primeiro (informação acionável), depois KPI e o resto.
            return _Stack([left[2], left[0], right[0], left[1], right[1], right[2]]);
          }),
        ),
      ],
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack(this.children);
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: Space.md),
          children[i],
        ],
      ]);
}
