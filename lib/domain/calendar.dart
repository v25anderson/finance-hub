import 'bill.dart';

/// Um vencimento a até [soonDays] dias (inclusive hoje) é "vence em breve" (amarelo no calendário).
const soonDays = 7;

/// Estado visual de um vencimento no calendário.
/// - [paid]: totalmente paga (verde)
/// - [overdue]: vencida e ainda com saldo (vermelho)
/// - [soon]: em aberto, vence hoje ou em até [soonDays] dias (amarelo)
/// - [future]: em aberto, mais distante (neutro)
enum CalendarTone { paid, overdue, soon, future }

/// Tom de uma conta **não cancelada** (canceladas não aparecem no calendário).
/// Parcialmente paga segue as mesmas regras de uma conta em aberto.
CalendarTone calendarTone(Bill bill, DateTime today) {
  if (bill.isFullyPaid) return CalendarTone.paid;
  if (bill.isOverdueOn(today)) return CalendarTone.overdue;
  final days = dateOnly(bill.dueDate).difference(dateOnly(today)).inDays;
  return days <= soonDays ? CalendarTone.soon : CalendarTone.future;
}

class CalendarDay {
  const CalendarDay({required this.date, required this.bills, required this.isToday});
  final DateTime date;

  /// Contas com vencimento neste dia (sem canceladas), por nome.
  final List<Bill> bills;
  final bool isToday;

  int get totalCents => bills.fold(0, (s, b) => s + b.plannedCents);
  bool get hasBills => bills.isNotEmpty;
}

/// Grade do mês: semanas de 7 posições (domingo a sábado). Posições antes do dia 1 e depois do
/// último dia são `null` (não mostramos dias de outros meses para não sugerir "sem contas").
class MonthGrid {
  const MonthGrid({required this.month, required this.weeks});
  final DateTime month;
  final List<List<CalendarDay?>> weeks;

  Iterable<CalendarDay> get days => weeks.expand((w) => w).whereType<CalendarDay>();

  CalendarDay? day(int dayOfMonth) {
    for (final d in days) {
      if (d.date.day == dayOfMonth) return d;
    }
    return null;
  }
}

MonthGrid buildMonthGrid(DateTime month, List<Bill> bills, DateTime today) {
  final first = DateTime(month.year, month.month);
  final count = DateTime(month.year, month.month + 1, 0).day;
  final lead = first.weekday % 7; // domingo = 0

  final byDay = <int, List<Bill>>{};
  for (final b in bills) {
    if (b.isCanceled) continue;
    final d = dateOnly(b.dueDate);
    if (d.year != month.year || d.month != month.month) continue; // defesa: só contas deste mês
    byDay.putIfAbsent(d.day, () => []).add(b);
  }
  final t = dateOnly(today);

  final cells = <CalendarDay?>[
    for (var i = 0; i < lead; i++) null,
    for (var d = 1; d <= count; d++)
      CalendarDay(
        date: DateTime(month.year, month.month, d),
        bills: (byDay[d] ?? <Bill>[])..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
        isToday: t.year == month.year && t.month == month.month && t.day == d,
      ),
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return MonthGrid(month: first, weeks: [for (var i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7)]);
}
