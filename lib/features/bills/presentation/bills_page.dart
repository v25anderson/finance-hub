import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/bill_filters.dart';
import '../../../design_system/components/pressable.dart';
import '../../shared/presentation/page_header.dart';
import '../../shared/presentation/period_selector.dart';
import 'bill_detail_sheet.dart';
import 'bill_tile.dart';

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});
  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> {
  BillTab _tab = BillTab.pending;
  bool _favorites = false;

  static const _labels = {
    BillTab.pending: 'Pendentes',
    BillTab.paid: 'Pagas',
    BillTab.overdue: 'Vencidas',
    BillTab.all: 'Todas',
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ym = ref.watch(selectedYearMonthProvider);
    final today = ref.watch(todayProvider);
    final billsAsync = ref.watch(billsForMonthProvider(ym));
    final categories = {for (final cat in ref.watch(categoriesProvider).value ?? const []) cat.id: cat};

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(
          padding: EdgeInsets.fromLTRB(Space.md, Space.lg + topInset(context), Space.md, 120),
          children: [
            PageHeader(
              'Contas',
              trailing: Tooltip(
                message: _favorites ? 'Mostrar todas' : 'Filtrar favoritos',
                child: Pressable(
                  onTap: () => setState(() => _favorites = !_favorites),
                  scale: 0.9,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: _favorites ? c.warning.withValues(alpha: 0.16) : c.surface, shape: BoxShape.circle, border: Border.all(color: _favorites ? Colors.transparent : c.border)),
                    child: Icon(_favorites ? Icons.star_rounded : Icons.star_outline_rounded, color: _favorites ? c.warning : c.textSecondary, size: 22),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.sm),
            const Align(alignment: Alignment.centerLeft, child: PeriodSelector()),
            const SizedBox(height: Space.md),
            billsAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(Space.xl), child: Center(child: CircularProgressIndicator())),
              error: (_, _) => const AppCard(child: Text('Não foi possível carregar as contas.')),
              data: (bills) {
                final visible = filterBills(bills, _tab, today, favoritesOnly: _favorites);
                int count(BillTab t) => filterBills(bills, t, today, favoritesOnly: _favorites).length;
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    for (final t in BillTab.values)
                      Expanded(
                        child: _TabButton(
                          key: Key('tab-${t.name}'),
                          label: _labels[t]!,
                          count: count(t),
                          countKey: Key('tab-count-${t.name}'),
                          selected: _tab == t,
                          onTap: () => setState(() => _tab = t),
                        ),
                      ),
                  ]),
                  const SizedBox(height: Space.md),
                  if (visible.isEmpty)
                    _Empty(hasAny: bills.isNotEmpty)
                  else
                    for (final b in visible)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.sm),
                        child: BillTile(
                          bill: b,
                          category: categories[b.categoryId],
                          today: today,
                          onTap: () => showBillDetail(context, b.id),
                        ),
                      ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.hasAny});
  final bool hasAny;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xxl),
      child: Column(children: [
        Icon(Icons.receipt_long_outlined, size: 40, color: c.textSecondary),
        const SizedBox(height: Space.md),
        Text(hasAny ? 'Nenhuma conta nesta aba.' : 'Nenhuma conta neste mês.', style: AppText.body(c.textSecondary)),
        if (!hasAny) Text('Toque em Adicionar para criar a primeira.', style: AppText.body(c.textSecondary)),
      ]),
    );
  }
}

/// Aba com contagem e rótulo; as quatro dividem a largura igualmente (cabem em 360 px).
class _TabButton extends StatelessWidget {
  const _TabButton({super.key, required this.label, required this.count, required this.countKey, required this.selected, required this.onTap});
  final String label;
  final int count;
  final Key countKey;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final fg = selected ? Colors.white : c.textPrimary;
    final fgDim = selected ? Colors.white.withValues(alpha: 0.85) : c.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Pressable(
        onTap: onTap,
        scale: 0.96,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: reduce ? Duration.zero : Motion.normal,
          curve: Motion.curve,
          padding: const EdgeInsets.symmetric(vertical: Space.sm + 3),
          decoration: BoxDecoration(
            color: selected ? c.accent : c.surface,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: selected ? Colors.transparent : c.border),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$count', key: countKey, style: AppText.number(fg).copyWith(fontSize: 18)),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, style: AppText.body(fgDim).copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
