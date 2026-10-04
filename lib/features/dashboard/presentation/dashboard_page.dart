import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/animated_value.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/tokens/spacing.dart';
import 'month_detail_sheet.dart';
import 'widgets/alerts_card.dart';
import 'widgets/balance_card.dart';
import 'widgets/comparison_card.dart';
import 'widgets/hero_header.dart';
import 'widgets/income_card.dart';
import 'widgets/investment_card.dart';

/// Largura mínima do conteúdo para usar duas colunas.
const _twoColumnsFrom = 880.0;

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final ym = ref.watch(selectedYearMonthProvider);
    final async = ref.watch(dashboardProvider(ym));
    final categories = <String, CategoryRow>{for (final cat in ref.watch(categoriesProvider).value ?? <CategoryRow>[]) cat.id: cat};
    final narrow = MediaQuery.sizeOf(context).width < Breakpoints.compact;

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        HeroHeader(data: async.value, edgeToEdge: narrow, onOpenDetail: () => showMonthDetail(context, month)),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, 0),
          child: async.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const AppCard(child: Text('Não foi possível carregar os dados do mês.')),
            data: (d) => LayoutBuilder(builder: (context, box) {
              final comparison = ComparisonCard(data: d, month: month, categories: categories);
              final alerts = AlertsCard(alerts: d.alerts);
              final balance = BalanceCard(data: d);
              final income = IncomeCard(data: d);
              final investment = InvestmentCard(data: d);
              if (box.maxWidth >= _twoColumnsFrom) {
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _Stack([comparison, alerts])),
                  const SizedBox(width: Space.md),
                  Expanded(child: _Stack([balance, income, investment], startIndex: 2)),
                ]);
              }
              // Celular: alertas logo abaixo do destaque (informação acionável), depois o resto.
              return _Stack([alerts, balance, comparison, income, investment]);
            }),
          ),
        ),
      ],
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack(this.children, {this.startIndex = 0});
  final List<Widget> children;
  final int startIndex;
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: Space.md),
          Reveal(index: startIndex + i, child: children[i]),
        ],
      ]);
}
