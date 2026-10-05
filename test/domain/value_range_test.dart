import 'package:finance_hub/domain/bill.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/month_summary.dart';
import 'package:finance_hub/domain/value_range.dart';
import 'package:flutter_test/flutter_test.dart';

Bill bill(String id, int planned, {ValueRange? range, int paid = 0, ExpenseType type = ExpenseType.variable}) => Bill(
      id: id,
      name: id,
      plannedCents: planned,
      dueDate: DateTime(2026, 10, 20),
      categoryId: 'cat-moradia',
      expenseType: type,
      createdAt: DateTime(2026, 1, 1),
      range: range,
      payments: paid > 0 ? [Payment(id: 'p$id', billId: id, amountCents: paid, paidAt: DateTime(2026, 10, 2))] : const [],
    );

void main() {
  group('ValueRange', () {
    test('validade: mínimo positivo e máximo não menor que o mínimo', () {
      expect(const ValueRange(20000, 30000).isValid, isTrue);
      expect(const ValueRange(20000, 20000).isValid, isTrue); // faixa de um valor só
      expect(const ValueRange(0, 100).isValid, isFalse);
      expect(const ValueRange(30000, 20000).isValid, isFalse);
    });

    test('ponto médio arredondado e posição de um valor (limites inclusivos)', () {
      const r = ValueRange(20000, 30000);
      expect(r.midpointCents, 25000);
      expect(const ValueRange(101, 200).midpointCents, 151); // 150,5 arredonda para cima
      expect(r.position(19999), RangePosition.below);
      expect(r.position(20000), RangePosition.within);
      expect(r.position(30000), RangePosition.within);
      expect(r.position(30001), RangePosition.above);
      expect(r.contains(25000), isTrue);
    });

    test('igualdade por valor', () {
      expect(const ValueRange(1, 2), const ValueRange(1, 2));
      expect(const ValueRange(1, 2) == const ValueRange(1, 3), isFalse);
    });
  });

  group('Bill com faixa', () {
    const r = ValueRange(20000, 30000);

    test('posição do total pago; sem faixa ou sem pagamento não há posição', () {
      expect(bill('a', 25000, range: r).paidRangePosition, isNull);
      expect(bill('a', 25000, paid: 10000).paidRangePosition, isNull);
      expect(bill('a', 25000, range: r, paid: 10000).paidRangePosition, RangePosition.below);
      expect(bill('a', 25000, range: r, paid: 25000).paidRangePosition, RangePosition.within);
      expect(bill('a', 25000, range: r, paid: 31000).paidRangePosition, RangePosition.above);
    });

    test('a faixa não muda o estado: continua derivado do valor previsto e dos pagamentos', () {
      final today = DateTime(2026, 10, 10);
      expect(bill('a', 25000, range: r, paid: 21000).statusOn(today), BillStatus.partiallyPaid); // dentro da faixa, mas abaixo do previsto
      expect(bill('a', 25000, range: r, paid: 25000).statusOn(today), BillStatus.paid);
      expect(bill('a', 25000, range: r).hasRange, isTrue);
      expect(bill('a', 25000).hasRange, isFalse);
    });

    test('copyWith preserva a faixa', () {
      expect(bill('a', 25000, range: r).copyWith(favorite: true).range, r);
    });
  });

  group('resumo do mês com faixas', () {
    final today = DateTime(2026, 10, 10);

    test('sem faixas: hasRange falso e a faixa coincide com o total', () {
      final s = computeMonthSummary([bill('a', 10000, type: ExpenseType.fixed), bill('b', 5000, type: ExpenseType.fixed)], today);
      expect(s.hasRange, isFalse);
      expect(s.rangeMinCents, 15000);
      expect(s.rangeMaxCents, 15000);
    });

    test('contas com faixa entram com mínimo e máximo; as demais, com o previsto; o total segue o previsto', () {
      final s = computeMonthSummary([
        bill('energia', 25000, range: const ValueRange(20000, 30000)),
        bill('agua', 8000, range: const ValueRange(6000, 9000)),
        bill('aluguel', 180000, type: ExpenseType.fixed),
      ], today);
      expect(s.hasRange, isTrue);
      expect(s.totalCents, 213000); // previsto: 250 + 80 + 1.800
      expect(s.rangeMinCents, 206000); // 200 + 60 + 1.800
      expect(s.rangeMaxCents, 219000); // 300 + 90 + 1.800
      expect(s.paidCents + s.pendingCents, s.totalCents); // invariante preservado
    });

    test('contas canceladas ficam fora da faixa também', () {
      final canceled = Bill(
        id: 'c',
        name: 'c',
        plannedCents: 99999,
        dueDate: DateTime(2026, 10, 20),
        categoryId: 'cat-moradia',
        expenseType: ExpenseType.variable,
        createdAt: DateTime(2026, 1, 1),
        canceledAt: DateTime(2026, 10, 1),
        range: const ValueRange(1000, 200000),
      );
      final s = computeMonthSummary([canceled, bill('a', 10000, type: ExpenseType.fixed)], today);
      expect(s.hasRange, isFalse);
      expect(s.rangeMaxCents, 10000);
    });
  });
}
