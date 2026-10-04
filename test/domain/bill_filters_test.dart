import 'package:finance_hub/domain/bill.dart';
import 'package:finance_hub/domain/bill_filters.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime(2026, 10, 10);

Bill mk(String name, DateTime due, {int planned = 1000, int paid = 0, bool fav = false, bool canceled = false}) => Bill(
      id: name,
      name: name,
      plannedCents: planned,
      dueDate: due,
      categoryId: 'c',
      expenseType: ExpenseType.fixed,
      createdAt: DateTime.utc(2026, 1, 1),
      favorite: fav,
      canceledAt: canceled ? DateTime.utc(2026, 10, 1) : null,
      payments: paid > 0 ? [Payment(id: 'p$name', billId: name, amountCents: paid, paidAt: DateTime.utc(2026, 10, 1))] : const [],
    );

void main() {
  final bills = [
    mk('Futura', DateTime(2026, 10, 20)),
    mk('ParcialNoPrazo', DateTime(2026, 10, 25), paid: 400),
    mk('Paga', DateTime(2026, 10, 3), paid: 1000),
    mk('Vencida', DateTime(2026, 10, 5)),
    mk('ParcialVencida', DateTime(2026, 10, 2), paid: 300, fav: true),
    mk('VenceHoje', today),
    mk('Cancelada', DateTime(2026, 10, 4), canceled: true),
  ];
  List<String> names(BillTab t, {bool fav = false}) => filterBills(bills, t, today, favoritesOnly: fav).map((b) => b.name).toList();

  test('Pendentes: com saldo a pagar e não vencidas (inclui parcial no prazo e vence hoje)', () {
    expect(names(BillTab.pending), ['VenceHoje', 'Futura', 'ParcialNoPrazo']);
  });

  test('Pagas', () => expect(names(BillTab.paid), ['Paga']));

  test('Vencidas inclui parcialmente paga vencida, ordenadas por data', () {
    expect(names(BillTab.overdue), ['ParcialVencida', 'Vencida']);
  });

  test('Todas inclui canceladas', () {
    expect(names(BillTab.all).length, 7);
    expect(names(BillTab.all), contains('Cancelada'));
  });

  test('Favoritos combina com a aba', () {
    expect(names(BillTab.all, fav: true), ['ParcialVencida']);
    expect(names(BillTab.paid, fav: true), isEmpty);
  });

  test('lista vazia', () => expect(filterBills(const [], BillTab.all, today), isEmpty));

  test('cada conta ativa aparece em exatamente uma de Pendentes/Pagas/Vencidas', () {
    for (final b in bills.where((b) => !b.isCanceled)) {
      final n = [BillTab.pending, BillTab.paid, BillTab.overdue].where((t) => filterBills([b], t, today).isNotEmpty).length;
      expect(n, 1, reason: b.name);
    }
  });
}
