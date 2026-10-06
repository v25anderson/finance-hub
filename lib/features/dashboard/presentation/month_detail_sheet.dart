import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/dashboard_data.dart';
import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/adaptive_sheet.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/components/money_text.dart';
import '../../../design_system/components/pressable.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/bill.dart';
import '../../../domain/value_range.dart';
import '../../bills/presentation/range_text.dart';
import '../../bills/presentation/bill_detail_sheet.dart';
import '../../bills/presentation/bill_tile.dart';

Future<void> showMonthDetail(BuildContext context, DateTime month) =>
    showAdaptiveSheet<void>(context, builder: (_) => MonthDetailSheet(month: month));

enum _Group { paid, pending, overdue, partial, future }

/// Detalhe do KPI: contas por estado e distribuição por categoria.
class MonthDetailSheet extends ConsumerStatefulWidget {
  const MonthDetailSheet({super.key, required this.month});
  final DateTime month;
  @override
  ConsumerState<MonthDetailSheet> createState() => _MonthDetailSheetState();
}

class _MonthDetailSheetState extends ConsumerState<MonthDetailSheet> {
  _Group _group = _Group.pending;

  static const _labels = {
    _Group.paid: 'Pagas',
    _Group.pending: 'Pendentes',
    _Group.overdue: 'Vencidas',
    _Group.partial: 'Parcialmente pagas',
    _Group.future: 'Futuras',
  };

  static const _tones = {
    _Group.paid: Tone.success,
    _Group.pending: Tone.warning,
    _Group.overdue: Tone.danger,
    _Group.partial: Tone.info,
    _Group.future: Tone.neutral,
  };

  List<Bill> _bills(DashboardData d) => switch (_group) {
        _Group.paid => d.summary.paidBills,
        _Group.pending => d.summary.pendingBills,
        _Group.overdue => d.summary.overdueBills,
        _Group.partial => d.summary.partiallyPaidBills,
        _Group.future => d.summary.futureBills,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ym = '${widget.month.year}-${widget.month.month.toString().padLeft(2, '0')}';
    final async = ref.watch(dashboardProvider(ym));
    final today = ref.watch(todayProvider);
    final categories = {for (final cat in ref.watch(categoriesProvider).value ?? const []) cat.id: cat};

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Não foi possível carregar o mês.')),
      data: (d) {
        final s = d.summary;
        final list = _bills(d)..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        int count(_Group g) => switch (g) {
              _Group.paid => s.paidBills.length,
              _Group.pending => s.pendingBills.length,
              _Group.overdue => s.overdueBills.length,
              _Group.partial => s.partiallyPaidBills.length,
              _Group.future => s.futureBills.length,
            };
        return ListView(padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, Space.xl), children: [
          Row(children: [
            Expanded(child: Text('Gastos de ${formatMonthYear(widget.month)}', style: AppText.title(c.textPrimary))),
            IconButton(tooltip: 'Fechar', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: Space.md),
          Row(children: [
            Expanded(child: _Stat('Total', s.totalCents)),
            Expanded(child: _Stat('Pago', s.paidCents, tone: Tone.success)),
            Expanded(child: _Stat('Pendente', s.pendingCents, tone: Tone.warning)),
          ]),
          if (s.hasRange) ...[
            const SizedBox(height: Space.sm),
            Text('Faixa ${formatRange(ValueRange(s.rangeMinCents, s.rangeMaxCents))}', key: const Key('detail-range'), style: AppText.body(c.textSecondary).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: Space.lg),
          Row(children: [
            for (final g in const [_Group.paid, _Group.pending, _Group.overdue]) ...[
              if (g != _Group.paid) const SizedBox(width: Space.sm),
              Expanded(child: _GroupTile(key: Key('group-${g.name}'), label: _labels[g]!, count: count(g), tone: _tones[g]!, selected: _group == g, onTap: () => setState(() => _group = g))),
            ],
          ]),
          const SizedBox(height: Space.sm),
          Row(children: [
            for (final g in const [_Group.partial, _Group.future]) ...[
              if (g != _Group.partial) const SizedBox(width: Space.sm),
              Expanded(child: _GroupTile(key: Key('group-${g.name}'), label: _labels[g]!, count: count(g), tone: _tones[g]!, selected: _group == g, onTap: () => setState(() => _group = g))),
            ],
          ]),
          const SizedBox(height: Space.md),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.lg),
              child: Text('Nada aqui.', style: AppText.body(c.textSecondary)),
            )
          else
            for (final b in list)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: BillTile(bill: b, category: categories[b.categoryId], today: today, onTap: () => showBillDetail(context, b.id)),
              ),
          const SizedBox(height: Space.lg),
          const SectionLabel('Categorias'),
          const SizedBox(height: Space.md),
          if (s.byCategory.isEmpty)
            Text('Sem gastos neste mês.', style: AppText.body(c.textSecondary))
          else
            for (final t in s.byCategory)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.md),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(categories[t.categoryId]?.name ?? 'Sem categoria', style: AppText.body(c.textPrimary))),
                    Text('${formatCents(t.plannedCents)} · ${formatPercent(t.fraction)}', style: AppText.body(c.textSecondary).copyWith(fontSize: 13)),
                  ]),
                  const SizedBox(height: Space.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Radii.pill),
                    child: LinearProgressIndicator(
                      value: t.fraction,
                      minHeight: 8,
                      backgroundColor: c.surfaceAlt,
                      color: Color(categories[t.categoryId]?.color ?? 0xFF78716C),
                    ),
                  ),
                ]),
              ),
        ]);
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.cents, {this.tone});
  final String label;
  final int cents;
  final Tone? tone;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionLabel(label),
        const SizedBox(height: Space.xs),
        MoneyText(cents, tone: tone),
      ]);
}

/// Filtro em bloco: número grande, nome do estado e um ponto na cor do estado. O selecionado ganha contorno e fundo tingido.
class _GroupTile extends StatelessWidget {
  const _GroupTile({super.key, required this.label, required this.count, required this.tone, required this.selected, required this.onTap});
  final String label;
  final int count;
  final Tone tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = c.tone(tone);
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      semanticLabel: '$label: $count',
      child: AnimatedContainer(
        duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ? Duration.zero : Motion.normal,
        curve: Motion.curve,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : c.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: selected ? color : Colors.transparent, width: 1.6),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const Spacer(),
            Text('$count', style: AppText.display(selected ? color : c.textPrimary).copyWith(fontSize: 26, letterSpacing: -1)),
          ]),
          const SizedBox(height: 6),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(selected ? c.textPrimary : c.textSecondary).copyWith(fontSize: 13, fontWeight: FontWeight.w700, height: 1.1)),
        ]),
      ),
    );
  }
}
