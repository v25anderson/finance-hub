import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/selected_month_provider.dart';
import '../../../core/formatting.dart';
import '../../../core/money.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/calendar.dart';
import '../../bills/presentation/bill_detail_sheet.dart';
import '../../bills/presentation/bill_tile.dart';
import '../../shared/presentation/page_header.dart';
import '../../shared/presentation/period_selector.dart';
import 'calendar_event_chip.dart';
import 'calendar_style.dart';
import 'day_sheet.dart';

/// A partir desta largura as contas aparecem dentro de cada dia; abaixo, pontos + lista do dia.
const _wideFrom = 700.0;
const _maxEventsPerCell = 3;

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime? _selected;

  /// Dia selecionado válido para o mês exibido: o escolhido, senão hoje, senão o primeiro com contas.
  DateTime _effectiveSelected(MonthGrid grid, DateTime today) {
    final s = _selected;
    if (s != null && s.year == grid.month.year && s.month == grid.month.month) return s;
    final t = grid.days.where((d) => d.isToday);
    if (t.isNotEmpty) return t.first.date;
    final withBills = grid.days.where((d) => d.hasBills);
    return (withBills.isNotEmpty ? withBills.first : grid.days.first).date;
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    final ym = ref.watch(selectedYearMonthProvider);
    final today = ref.watch(todayProvider);
    final async = ref.watch(billsForMonthProvider(ym));
    final categories = <String, CategoryRow>{for (final cat in ref.watch(categoriesProvider).value ?? <CategoryRow>[]) cat.id: cat};

    return ListView(
      padding: EdgeInsets.fromLTRB(Space.md, Space.lg + topInset(context), Space.md, 120),
      children: [
        const PageHeader('Calendário'),
        const SizedBox(height: Space.sm),
        const Align(alignment: Alignment.centerLeft, child: PeriodSelector()),
        const SizedBox(height: Space.md),
        const _Legend(),
        const SizedBox(height: Space.md),
        async.when(
          loading: () => const Padding(padding: EdgeInsets.all(Space.xl), child: Center(child: CircularProgressIndicator())),
          error: (_, _) => const AppCard(child: Text('Não foi possível carregar o calendário.')),
          data: (bills) {
            final grid = buildMonthGrid(month, bills, today);
            return LayoutBuilder(builder: (context, box) {
              if (box.maxWidth >= _wideFrom) return _WideGrid(grid: grid, today: today);
              final selected = _effectiveSelected(grid, today);
              final day = grid.day(selected.day)!;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _CompactGrid(grid: grid, today: today, selected: selected, onSelect: (d) => setState(() => _selected = d)),
                const SizedBox(height: Space.lg),
                _Agenda(day: day, today: today, categories: categories),
              ]);
            });
          },
        ),
      ],
    );
  }
}

const _weekdaysShort = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
const _weekdaysLong = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(spacing: Space.md, runSpacing: Space.xs, children: [
      for (final t in CalendarTone.values)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c.tone(styleForCalendarTone(t).tone), shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(styleForCalendarTone(t).label, style: AppText.body(c.textSecondary).copyWith(fontSize: 12)),
        ]),
    ]);
  }
}

// ── Celular ─────────────────────────────────────────────────────

class _CompactGrid extends StatelessWidget {
  const _CompactGrid({required this.grid, required this.today, required this.selected, required this.onSelect});
  final MonthGrid grid;
  final DateTime today;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.sm),
      child: Column(children: [
        Row(children: [
          for (final w in _weekdaysShort)
            Expanded(child: Center(child: Text(w, style: AppText.label(c.textSecondary)))),
        ]),
        const SizedBox(height: Space.xs),
        for (final week in grid.weeks)
          Row(children: [
            for (final d in week)
              Expanded(child: d == null ? const SizedBox(height: 54) : _CompactCell(day: d, today: today, selected: d.date.day == selected.day, onTap: () => onSelect(d.date))),
          ]),
      ]),
    );
  }
}

class _CompactCell extends StatelessWidget {
  const _CompactCell({required this.day, required this.today, required this.selected, required this.onTap});
  final CalendarDay day;
  final DateTime today;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tones = [for (final b in day.bills) calendarTone(b, today)];
    return Semantics(
      button: true,
      selected: selected,
      label: '${formatDayLong(day.date)}, ${day.bills.length} ${day.bills.length == 1 ? 'vencimento' : 'vencimentos'}',
      child: InkWell(
        key: ValueKey('cal-day-${day.date.day}'),
        borderRadius: BorderRadius.circular(Radii.sm),
        onTap: onTap,
        child: Container(
          height: 54,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(color: selected ? c.accent : Colors.transparent, width: 1.5),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: day.isToday ? c.accent : null, shape: BoxShape.circle),
              child: Text(
                '${day.date.day}',
                style: AppText.body(day.isToday ? Colors.white : c.textPrimary).copyWith(fontSize: 14, fontWeight: day.isToday || selected ? FontWeight.w700 : FontWeight.w500),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 8,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (final (i, t) in tones.take(3).indexed)
                  Container(
                    key: ValueKey('cal-dot-${day.date.day}-$i-${t.name}'), // o índice evita chaves repetidas no mesmo dia
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(color: c.tone(styleForCalendarTone(t).tone), shape: BoxShape.circle),
                  ),
                if (tones.length > 3) Text('+', style: AppText.label(c.textSecondary).copyWith(fontSize: 9, height: 1)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.day, required this.today, required this.categories});
  final CalendarDay day;
  final DateTime today;
  final Map<String, CategoryRow> categories;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(formatDayLong(day.date), key: const Key('agenda-title'), style: AppText.title(c.textPrimary).copyWith(fontSize: 18)),
      const SizedBox(height: 2),
      Text(
        day.hasBills ? '${day.bills.length} ${day.bills.length == 1 ? 'conta' : 'contas'} · ${formatCents(day.totalCents)}' : 'Nenhum vencimento neste dia.',
        style: AppText.body(c.textSecondary),
      ),
      const SizedBox(height: Space.sm),
      for (final b in day.bills)
        Padding(
          padding: const EdgeInsets.only(bottom: Space.sm),
          child: BillTile(bill: b, category: categories[b.categoryId], today: today, onTap: () => showBillDetail(context, b.id)),
        ),
    ]);
  }
}

// ── Tablet / desktop ────────────────────────────────────────────

class _WideGrid extends StatelessWidget {
  const _WideGrid({required this.grid, required this.today});
  final MonthGrid grid;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(Space.sm),
      child: Column(children: [
        Row(children: [
          for (final w in _weekdaysLong) Expanded(child: Padding(padding: const EdgeInsets.all(Space.xs), child: Text(w.toUpperCase(), style: AppText.label(c.textSecondary)))),
        ]),
        for (final week in grid.weeks)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final d in week) Expanded(child: _WideCell(day: d, today: today)),
            ]),
          ),
      ]),
    );
  }
}

class _WideCell extends StatelessWidget {
  const _WideCell({required this.day, required this.today});
  final CalendarDay? day;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = day;
    final border = Border.all(color: c.border.withValues(alpha: 0.6), width: 0.5);
    if (d == null) return Container(constraints: const BoxConstraints(minHeight: 104), decoration: BoxDecoration(color: c.surfaceAlt.withValues(alpha: 0.35), border: border));
    final shown = d.bills.take(_maxEventsPerCell).toList();
    final more = d.bills.length - shown.length;
    return Container(
      key: ValueKey('cal-cell-${d.date.day}'),
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(border: border, color: d.isToday ? c.accent.withValues(alpha: 0.06) : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: d.isToday ? c.accent : null, shape: BoxShape.circle),
          child: Text('${d.date.day}', style: AppText.body(d.isToday ? Colors.white : c.textPrimary).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 4),
        for (final b in shown)
          CalendarEventChip(bill: b, tone: calendarTone(b, today), onTap: () => showBillDetail(context, b.id)),
        if (more > 0)
          InkWell(
            key: ValueKey('cal-more-${d.date.day}'),
            onTap: () => showDaySheet(context, d),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2), child: Text('+$more mais', style: AppText.body(c.accent).copyWith(fontSize: 12, fontWeight: FontWeight.w600))),
          ),
      ]),
    );
  }
}
