import 'package:finance_hub/domain/bill.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime(2026, 10, 10);

Payment pay(int cents, {String id = 'p'}) =>
    Payment(id: id, billId: 'b', amountCents: cents, paidAt: DateTime.utc(2026, 10, 1));

Bill bill({
  int planned = 100000,
  DateTime? due,
  List<Payment> payments = const [],
  DateTime? canceledAt,
}) =>
    Bill(
      id: 'b',
      name: 'Conta',
      plannedCents: planned,
      dueDate: due ?? DateTime(2026, 10, 20),
      categoryId: 'cat-outros',
      expenseType: ExpenseType.variable,
      createdAt: DateTime.utc(2026, 9, 1),
      payments: payments,
      canceledAt: canceledAt,
    );

void main() {
  group('valores previsto / pago / restante', () {
    test('sem pagamentos', () {
      final b = bill();
      expect((b.paidCents, b.remainingCents, b.excessCents), (0, 100000, 0));
      expect(b.paidFraction, 0);
    });

    test('pagamento parcial: 1000 previsto, 400 pago → 600 restante', () {
      final b = bill(planned: 100000, payments: [pay(40000)]);
      expect(b.paidCents, 40000);
      expect(b.remainingCents, 60000);
      expect(b.paidFraction, closeTo(0.4, 1e-9));
      expect(b.statusOn(today), BillStatus.partiallyPaid);
      expect(b.statusOn(today), isNot(BillStatus.paid));
    });

    test('exemplo do enunciado: 2000 previsto, 800 pago → 1200 restante, 40%', () {
      final b = bill(planned: 200000, payments: [pay(80000)]);
      expect((b.paidCents, b.remainingCents), (80000, 120000));
      expect(b.paidFraction, closeTo(0.4, 1e-9));
    });

    test('vários pagamentos parciais somam', () {
      final b = bill(planned: 100000, payments: [pay(10000, id: '1'), pay(25000, id: '2'), pay(5000, id: '3')]);
      expect(b.paidCents, 40000);
      expect(b.remainingCents, 60000);
      expect(b.statusOn(today), BillStatus.partiallyPaid);
    });

    test('pagamentos parciais que completam o total → paga', () {
      final b = bill(planned: 100000, payments: [pay(60000, id: '1'), pay(40000, id: '2')]);
      expect(b.remainingCents, 0);
      expect(b.statusOn(today), BillStatus.paid);
    });

    test('pagamento maior que o valor: restante 0, excedente registrado, fração limitada a 100%', () {
      final b = bill(planned: 100000, payments: [pay(130000)]);
      expect(b.remainingCents, 0);
      expect(b.excessCents, 30000);
      expect(b.paidCents, 130000); // nada é truncado
      expect(b.paidFraction, 1.0);
      expect(b.statusOn(today), BillStatus.paid);
    });

    test('pagamento exato → paga, sem excedente', () {
      final b = bill(payments: [pay(100000)]);
      expect(b.excessCents, 0);
      expect(b.statusOn(today), BillStatus.paid);
    });
  });

  group('vencimento', () {
    test('vence hoje não é vencida', () {
      final b = bill(due: today);
      expect(b.isOverdueOn(today), isFalse);
      expect(b.statusOn(today), BillStatus.pending);
    });

    test('venceu ontem é vencida', () {
      final b = bill(due: DateTime(2026, 10, 9));
      expect(b.isOverdueOn(today), isTrue);
      expect(b.statusOn(today), BillStatus.overdue);
    });

    test('hora do dia não altera a comparação de datas', () {
      final b = bill(due: DateTime(2026, 10, 10, 23, 59));
      expect(b.isOverdueOn(DateTime(2026, 10, 10, 0, 1)), isFalse);
      expect(b.isOverdueOn(DateTime(2026, 10, 11, 0, 1)), isTrue);
    });

    test('vencida e parcialmente paga: continua vencida, mas sabe que é parcial', () {
      final b = bill(due: DateTime(2026, 10, 5), payments: [pay(40000)]);
      expect(b.statusOn(today), BillStatus.overdue);
      expect(b.isPartiallyPaid, isTrue);
      expect(b.remainingCents, 60000);
    });

    test('vencida e totalmente paga → paga (não vencida)', () {
      final b = bill(due: DateTime(2026, 10, 5), payments: [pay(100000)]);
      expect(b.statusOn(today), BillStatus.paid);
      expect(b.isOverdueOn(today), isFalse);
    });

    test('paga com atraso continua paga em qualquer data futura', () {
      final b = bill(due: DateTime(2026, 1, 5), payments: [pay(100000)]);
      expect(b.statusOn(DateTime(2027, 5, 1)), BillStatus.paid);
    });
  });

  group('janela pendente × prevista', () {
    test('dentro de 30 dias → pendente; fora → prevista', () {
      expect(bill(due: DateTime(2026, 11, 9)).statusOn(today), BillStatus.pending); // +30
      expect(bill(due: DateTime(2026, 11, 10)).statusOn(today), BillStatus.planned); // +31
    });

    test('mês futuro distante → prevista', () {
      expect(bill(due: DateTime(2027, 3, 1)).statusOn(today), BillStatus.planned);
    });

    test('janela configurável', () {
      final b = bill(due: DateTime(2026, 10, 25));
      expect(b.statusOn(today, pendingWindowDays: 7), BillStatus.planned);
      expect(b.statusOn(today, pendingWindowDays: 15), BillStatus.pending);
    });

    test('parcialmente paga e futura → parcialmente paga', () {
      final b = bill(due: DateTime(2026, 12, 1), payments: [pay(100)]);
      expect(b.statusOn(today), BillStatus.partiallyPaid);
    });
  });

  group('cancelada', () {
    test('cancelada tem prioridade sobre qualquer outro estado', () {
      final canceled = DateTime.utc(2026, 10, 1);
      expect(bill(canceledAt: canceled).statusOn(today), BillStatus.canceled);
      expect(bill(canceledAt: canceled, due: DateTime(2026, 1, 1)).statusOn(today), BillStatus.canceled);
      expect(bill(canceledAt: canceled, payments: [pay(100000)]).statusOn(today), BillStatus.canceled);
    });

    test('cancelada nunca é vencida nem parcial', () {
      final b = bill(canceledAt: DateTime.utc(2026, 10, 1), due: DateTime(2026, 1, 1), payments: [pay(10)]);
      expect(b.isOverdueOn(today), isFalse);
      expect(b.isPartiallyPaid, isFalse);
    });
  });

  group('casos extremos', () {
    test('conta de valor zero nunca é "paga" nem tem fração', () {
      final b = bill(planned: 0);
      expect(b.isFullyPaid, isFalse);
      expect(b.paidFraction, 0);
      expect(b.remainingCents, 0);
      expect(b.isOverdueOn(today), isFalse); // nada a pagar → não vencida
    });

    test('remover um pagamento volta o estado (recalculado, não armazenado)', () {
      final full = bill(payments: [pay(60000, id: '1'), pay(40000, id: '2')]);
      expect(full.statusOn(today), BillStatus.paid);
      final fewer = full.copyWith(payments: [full.payments.first]);
      expect(fewer.statusOn(today), BillStatus.partiallyPaid);
      expect(fewer.remainingCents, 40000);
    });

    test('centavos não sofrem erro de ponto flutuante', () {
      final b = bill(planned: 10, payments: [pay(1, id: '1'), pay(2, id: '2'), pay(7, id: '3')]);
      expect(b.isFullyPaid, isTrue);
      expect(b.remainingCents, 0);
    });
  });
}
