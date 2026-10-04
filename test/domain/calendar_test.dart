import 'package:finance_hub/domain/bill.dart';
import 'package:finance_hub/domain/calendar.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime(2026, 10, 10);

Bill mk(String name, DateTime due, {int planned = 1000, int paid = 0, bool canceled = false}) => Bill(
      id: name,
      name: name,
      plannedCents: planned,
      dueDate: due,
      categoryId: 'c',
      expenseType: ExpenseType.fixed,
      createdAt: DateTime.utc(2026, 1, 1),
      canceledAt: canceled ? DateTime.utc(2026, 1, 2) : null,
      payments: paid > 0 ? [Payment(id: 'p$name', billId: name, amountCents: paid, paidAt: DateTime.utc(2026, 10, 1))] : const [],
    );

void main() {
  group('tom do vencimento', () {
    test('paga → verde, mesmo que tenha sido paga com atraso ou antecipada', () {
      expect(calendarTone(mk('a', DateTime(2026, 10, 3), paid: 1000), today), CalendarTone.paid);
      expect(calendarTone(mk('a', DateTime(2026, 12, 3), paid: 1000), today), CalendarTone.paid);
    });
    test('vencida (com saldo) → vermelho', () {
      expect(calendarTone(mk('a', DateTime(2026, 10, 9)), today), CalendarTone.overdue);
    });
    test('vencida e parcialmente paga continua vermelha', () {
      expect(calendarTone(mk('a', DateTime(2026, 10, 1), paid: 400), today), CalendarTone.overdue);
    });
    test('vence hoje e em até 7 dias → amarelo; a partir de 8 → neutro', () {
      expect(calendarTone(mk('a', DateTime(2026, 10, 10)), today), CalendarTone.soon);
      expect(calendarTone(mk('a', DateTime(2026, 10, 17)), today), CalendarTone.soon);
      expect(calendarTone(mk('a', DateTime(2026, 10, 18)), today), CalendarTone.future);
      expect(calendarTone(mk('a', DateTime(2027, 3, 1)), today), CalendarTone.future);
    });
    test('parcialmente paga no prazo segue a regra de aberta', () {
      expect(calendarTone(mk('a', DateTime(2026, 10, 12), paid: 300), today), CalendarTone.soon);
      expect(calendarTone(mk('a', DateTime(2026, 11, 12), paid: 300), today), CalendarTone.future);
    });
    test('hora do dia não altera o resultado', () {
      expect(calendarTone(mk('a', DateTime(2026, 10, 10, 23, 59)), DateTime(2026, 10, 10, 0, 1)), CalendarTone.soon);
    });
  });

  group('grade do mês', () {
    test('outubro/2026 começa na quinta: 4 vazios antes, 31 dias, 5 semanas', () {
      final g = buildMonthGrid(DateTime(2026, 10), const [], today);
      expect(g.weeks.length, 5);
      expect(g.weeks.every((w) => w.length == 7), isTrue);
      expect(g.weeks.first.take(4).every((d) => d == null), isTrue);
      expect(g.weeks.first[4]!.date, DateTime(2026, 10, 1));
      expect(g.days.length, 31);
      expect(g.weeks.last.last!.date, DateTime(2026, 10, 31)); // 4 + 31 = 35 células: fecha exatamente no sábado
    });

    test('mês que termina antes do sábado completa a semana com vazios (nov/2026 termina na segunda)', () {
      final g = buildMonthGrid(DateTime(2026, 11), const [], today);
      expect(g.weeks.last.first!.date, DateTime(2026, 11, 29));
      expect(g.weeks.last[1]!.date, DateTime(2026, 11, 30));
      expect(g.weeks.last.skip(2).every((d) => d == null), isTrue);
    });

    test('mês que começa no domingo não tem vazios antes (fev/2026 = 28 dias, 4 semanas)', () {
      final g = buildMonthGrid(DateTime(2026, 2), const [], today);
      expect(g.weeks.first.first!.date, DateTime(2026, 2, 1));
      expect(g.weeks.length, 4);
      expect(g.days.length, 28);
      expect(g.weeks.last.last!.date, DateTime(2026, 2, 28));
    });

    test('mês que precisa de 6 semanas (ago/2026 começa no sábado)', () {
      final g = buildMonthGrid(DateTime(2026, 8), const [], today);
      expect(g.weeks.length, 6);
      expect(g.weeks.first.take(6).every((d) => d == null), isTrue);
      expect(g.weeks.first.last!.date, DateTime(2026, 8, 1));
      expect(g.days.length, 31);
    });

    test('fevereiro bissexto tem 29 dias', () {
      expect(buildMonthGrid(DateTime(2028, 2), const [], today).days.length, 29);
    });

    test('toda semana tem 7 posições e a ordem dos dias é crescente', () {
      for (final m in [for (var i = 1; i <= 12; i++) DateTime(2026, i)]) {
        final g = buildMonthGrid(m, const [], today);
        expect(g.weeks.every((w) => w.length == 7), isTrue, reason: '$m');
        final ds = g.days.map((d) => d.date.day).toList();
        expect(ds, [for (var i = 1; i <= ds.length; i++) i], reason: '$m');
      }
    });

    test('coloca cada conta no seu dia, ordenada por nome, e soma o dia', () {
      final g = buildMonthGrid(DateTime(2026, 10), [
        mk('YouTube', DateTime(2026, 10, 10), planned: 2490),
        mk('Internet', DateTime(2026, 10, 12), planned: 12000),
        mk('Aluguel', DateTime(2026, 10, 10), planned: 180000),
      ], today);
      expect(g.day(10)!.bills.map((b) => b.name), ['Aluguel', 'YouTube']);
      expect(g.day(10)!.totalCents, 182490);
      expect(g.day(12)!.bills.single.name, 'Internet');
      expect(g.day(11)!.hasBills, isFalse);
    });

    test('ignora canceladas e contas de outros meses', () {
      final g = buildMonthGrid(DateTime(2026, 10), [
        mk('Cancelada', DateTime(2026, 10, 5), canceled: true),
        mk('Setembro', DateTime(2026, 9, 30)),
        mk('Novembro', DateTime(2026, 11, 1)),
        mk('Ok', DateTime(2026, 10, 31)),
      ], today);
      expect(g.days.expand((d) => d.bills).map((b) => b.name), ['Ok']);
    });

    test('marca apenas o dia de hoje, e só no mês de hoje', () {
      final g = buildMonthGrid(DateTime(2026, 10), const [], today);
      expect(g.days.where((d) => d.isToday).map((d) => d.date.day), [10]);
      expect(buildMonthGrid(DateTime(2026, 11), const [], today).days.any((d) => d.isToday), isFalse);
    });

    test('mês sem contas: todos os dias existem e vazios', () {
      final g = buildMonthGrid(DateTime(2030, 1), const [], today);
      expect(g.days.every((d) => !d.hasBills), isTrue);
      expect(g.day(32), isNull);
    });
  });
}
