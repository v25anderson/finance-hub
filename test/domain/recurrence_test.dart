import 'package:finance_hub/domain/bill.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/recurrence.dart';
import 'package:finance_hub/domain/value_history.dart';
import 'package:flutter_test/flutter_test.dart';

RecurrenceRule rule(Frequency f, DateTime start, {int interval = 1, DateTime? end}) => RecurrenceRule(
      id: 'r',
      name: 'Netflix',
      baseAmountCents: 3990,
      categoryId: 'c',
      expenseType: ExpenseType.fixed,
      frequency: f,
      start: start,
      interval: interval,
      end: end,
    );

String d(DateTime x) => '${x.year}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}';
List<String> dates(RecurrenceRule r, DateTime from, DateTime to) => occurrenceDates(r, from: from, to: to).map(d).toList();

void main() {
  group('mensal', () {
    test('mesmo dia a cada mês', () {
      expect(dates(rule(Frequency.monthly, DateTime(2026, 1, 10)), DateTime(2026, 1, 1), DateTime(2026, 4, 30)),
          ['2026-01-10', '2026-02-10', '2026-03-10', '2026-04-10']);
    });

    test('dia 31 → último dia do mês curto, e volta ao 31 depois (sem acumular erro)', () {
      expect(dates(rule(Frequency.monthly, DateTime(2026, 1, 31)), DateTime(2026, 1, 1), DateTime(2026, 5, 31)),
          ['2026-01-31', '2026-02-28', '2026-03-31', '2026-04-30', '2026-05-31']);
    });

    test('fevereiro de ano bissexto', () {
      expect(dates(rule(Frequency.monthly, DateTime(2028, 1, 31)), DateTime(2028, 2, 1), DateTime(2028, 2, 29)), ['2028-02-29']);
    });

    test('a cada 2 meses atravessando o ano', () {
      expect(dates(rule(Frequency.monthly, DateTime(2026, 11, 5), interval: 2), DateTime(2026, 1, 1), DateTime(2027, 5, 31)),
          ['2026-11-05', '2027-01-05', '2027-03-05', '2027-05-05']);
    });
  });

  group('semanal, anual e personalizado', () {
    test('semanal', () {
      expect(dates(rule(Frequency.weekly, DateTime(2026, 10, 1)), DateTime(2026, 10, 1), DateTime(2026, 10, 29)),
          ['2026-10-01', '2026-10-08', '2026-10-15', '2026-10-22', '2026-10-29']);
    });
    test('a cada 2 semanas', () {
      expect(dates(rule(Frequency.weekly, DateTime(2026, 10, 1), interval: 2), DateTime(2026, 10, 1), DateTime(2026, 11, 15)),
          ['2026-10-01', '2026-10-15', '2026-10-29', '2026-11-12']);
    });
    test('anual, inclusive 29/02 em ano não bissexto', () {
      expect(dates(rule(Frequency.yearly, DateTime(2024, 2, 29)), DateTime(2024, 1, 1), DateTime(2028, 12, 31)),
          ['2024-02-29', '2025-02-28', '2026-02-28', '2027-02-28', '2028-02-29']);
    });
    test('personalizado: a cada N dias', () {
      expect(dates(rule(Frequency.custom, DateTime(2026, 10, 1), interval: 10), DateTime(2026, 10, 1), DateTime(2026, 11, 1)),
          ['2026-10-01', '2026-10-11', '2026-10-21', '2026-10-31']);
    });
  });

  group('limites', () {
    test('nunca antes do início', () {
      expect(dates(rule(Frequency.monthly, DateTime(2026, 6, 10)), DateTime(2026, 1, 1), DateTime(2026, 7, 31)), ['2026-06-10', '2026-07-10']);
    });
    test('respeita a data final (inclusive)', () {
      final r = rule(Frequency.monthly, DateTime(2026, 1, 10), end: DateTime(2026, 3, 10));
      expect(dates(r, DateTime(2026, 1, 1), DateTime(2026, 12, 31)), ['2026-01-10', '2026-02-10', '2026-03-10']);
    });
    test('fim antes do início → vazio', () {
      final r = rule(Frequency.monthly, DateTime(2026, 5, 10), end: DateTime(2026, 4, 1));
      expect(dates(r, DateTime(2026, 1, 1), DateTime(2026, 12, 31)), isEmpty);
    });
    test('janela sem ocorrências e janela invertida', () {
      final r = rule(Frequency.yearly, DateTime(2026, 3, 1));
      expect(dates(r, DateTime(2026, 4, 1), DateTime(2026, 12, 31)), isEmpty);
      expect(dates(r, DateTime(2027, 1, 1), DateTime(2026, 1, 1)), isEmpty);
    });
    test('janela distante do início traz as datas certas (salto eficiente)', () {
      final r = rule(Frequency.monthly, DateTime(2000, 1, 31));
      expect(dates(r, DateTime(2026, 2, 1), DateTime(2026, 3, 31)), ['2026-02-28', '2026-03-31']);
      final w = rule(Frequency.weekly, DateTime(2000, 1, 1));
      final got = occurrenceDates(w, from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 31));
      expect(got.every((x) => x.difference(DateTime(2000, 1, 1)).inDays % 7 == 0), isTrue);
      expect(got.length, inInclusiveRange(4, 5));
    });
    test('intervalo inválido não gera nada nem trava', () {
      expect(dates(rule(Frequency.monthly, DateTime(2026, 1, 1), interval: 0), DateTime(2026, 1, 1), DateTime(2026, 12, 1)), isEmpty);
    });
    test('resultado é idempotente e ordenado', () {
      final r = rule(Frequency.monthly, DateTime(2026, 1, 31));
      final a = dates(r, DateTime(2026, 1, 1), DateTime(2026, 12, 31));
      expect(a, dates(r, DateTime(2026, 1, 1), DateTime(2026, 12, 31)));
      expect(a, [...a]..sort());
      expect(a.length, 12);
    });
  });

  test('descrição da frequência', () {
    expect(describeFrequency(Frequency.monthly, 1), 'Mensal');
    expect(describeFrequency(Frequency.weekly, 2), 'A cada 2 semanas');
    expect(describeFrequency(Frequency.custom, 15), 'A cada 15 dias');
    expect(describeFrequency(Frequency.yearly, 1), 'Anual');
  });

  group('histórico de valores', () {
    Bill occ(int month, int cents, {bool canceled = false}) => Bill(
          id: 'b$month',
          name: 'YouTube Premium',
          plannedCents: cents,
          dueDate: DateTime(2026, month, 10),
          categoryId: 'c',
          expenseType: ExpenseType.fixed,
          createdAt: DateTime.utc(2026, 1, 1),
          canceledAt: canceled ? DateTime.utc(2026, 1, 2) : null,
        );

    test('exemplo do enunciado: 24,90 → 27,90 em março', () {
      final h = buildValueHistory([occ(1, 2490), occ(2, 2490), occ(3, 2790), occ(4, 2790)]);
      expect(h.points.map((p) => p.cents), [2490, 2490, 2790, 2790]);
      expect(h.changes.length, 1);
      expect(h.changes.single.date, DateTime(2026, 3, 10));
      expect((h.changes.single.fromCents, h.changes.single.toCents, h.changes.single.deltaCents), (2490, 2790, 300));
    });
    test('ordena por data, ignora canceladas, sem mudanças quando constante', () {
      final h = buildValueHistory([occ(3, 1000), occ(1, 1000), occ(2, 1000, canceled: true)]);
      expect(h.points.length, 2);
      expect(h.changes, isEmpty);
    });
    test('queda também é mudança; vazio é vazio', () {
      expect(buildValueHistory([occ(1, 3000), occ(2, 2000)]).changes.single.deltaCents, -1000);
      expect(buildValueHistory(const []).isEmpty, isTrue);
    });
  });
}
