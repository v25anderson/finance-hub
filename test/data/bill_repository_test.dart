import 'package:finance_hub/application/bill_service.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/bill_repository.dart';
import 'package:finance_hub/data/repositories/repo_base.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/bill.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  late BillService svc;
  late BillRepository bills;
  final today = DateTime(2026, 10, 10);

  setUp(() {
    db = memoryDb();
    bills = BillRepository(db);
    svc = BillService(bills: bills, transactions: TransactionRepository(db), clock: () => DateTime.utc(2026, 10, 10, 12));
  });
  tearDown(() => db.close());

  Future<String> create({int cents = 200000, DateTime? due, String name = 'Conta'}) => svc.create(
        name: name,
        plannedCents: cents,
        dueDate: due ?? DateTime(2026, 10, 15),
        categoryId: 'cat-moradia',
        expenseType: ExpenseType.fixed,
      );

  test('mapeia lançamento e pagamentos para Bill', () async {
    final id = await create();
    await svc.registerPayment(id, 80000);
    final b = (await bills.getBill(id))!;
    expect(b.plannedCents, 200000);
    expect((b.paidCents, b.remainingCents), (80000, 120000));
    expect(b.statusOn(today), BillStatus.partiallyPaid);
    expect(b.dueDate, DateTime(2026, 10, 15));
  });

  test('pagamento parcial múltiplo e depois "marcar como pago" quita o restante', () async {
    final id = await create(cents: 100000);
    await svc.registerPayment(id, 10000);
    await svc.registerPayment(id, 25000);
    await svc.markAsPaid(id, note: 'resto');
    final b = (await bills.getBill(id))!;
    expect(b.payments.length, 3); // histórico preservado
    expect(b.paidCents, 100000);
    expect(b.statusOn(today), BillStatus.paid);
    expect(b.payments.last.amountCents, 65000);
    expect(b.payments.last.note, 'resto');
  });

  test('marcar como pago registra data/hora do pagamento', () async {
    final id = await create();
    await svc.markAsPaid(id, paidAt: DateTime.utc(2026, 10, 3, 14, 30));
    expect((await bills.getBill(id))!.payments.single.paidAt, DateTime.utc(2026, 10, 3, 14, 30));
  });

  test('marcar como pago em conta já quitada ou cancelada é recusado', () async {
    final id = await create();
    await svc.markAsPaid(id);
    expect(() => svc.markAsPaid(id), throwsA(isA<ValidationError>()));
    final other = await create(name: 'Outra');
    await TransactionRepository(db).cancel(other);
    expect(() => svc.markAsPaid(other), throwsA(isA<ValidationError>()));
    expect(() => svc.markAsPaid('nada'), throwsA(isA<NotFoundError>()));
  });

  test('pagamento maior que o restante é aceito e vira excedente', () async {
    final id = await create(cents: 10000);
    await svc.registerPayment(id, 15000);
    final b = (await bills.getBill(id))!;
    expect((b.remainingCents, b.excessCents), (0, 5000));
  });

  test('excluir pagamento recalcula o estado', () async {
    final id = await create(cents: 10000);
    await svc.markAsPaid(id);
    var b = (await bills.getBill(id))!;
    expect(b.statusOn(today), BillStatus.paid);
    await svc.deletePayment(b.payments.single.id);
    b = (await bills.getBill(id))!;
    expect(b.statusOn(today), BillStatus.pending);
    expect(b.remainingCents, 10000);
  });

  test('conta excluída some das listas mas pode ser restaurada', () async {
    final id = await create();
    await svc.registerPayment(id, 100);
    await svc.delete(id);
    expect(await bills.getBill(id), isNull);
    expect(await bills.getMonth('2026-10'), isEmpty);
    await svc.restore(id);
    expect((await bills.getBill(id))!.paidCents, 100);
  });

  test('favoritar alterna', () async {
    final id = await create();
    await svc.toggleFavorite(id);
    expect((await bills.getBill(id))!.favorite, isTrue);
    await svc.toggleFavorite(id);
    expect((await bills.getBill(id))!.favorite, isFalse);
  });

  test('criar exige valor maior que zero', () {
    expect(() => create(cents: 0), throwsA(isA<ValidationError>()));
  });

  test('mês sem contas e mês futuro retornam vazio', () async {
    expect(await bills.getMonth('2026-10'), isEmpty);
    expect(await bills.getMonth('2035-01'), isEmpty);
  });

  test('watchMonth reemite ao registrar pagamento', () async {
    final id = await create();
    final emissions = <int>[];
    final sub = bills.watchMonth('2026-10').listen((l) => emissions.add(l.single.paidCents));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await svc.registerPayment(id, 500);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await sub.cancel();
    expect(emissions.first, 0);
    expect(emissions.last, 500);
  });

  test('duplicar cria conta independente', () async {
    final id = await create();
    await svc.markAsPaid(id);
    final copy = await svc.duplicate(id, name: 'Nova', dueDate: DateTime(2026, 11, 5));
    final b = (await bills.getBill(copy))!;
    expect(b.id, isNot(id));
    expect(b.name, 'Nova');
    expect(b.payments, isEmpty);
    expect(b.dueDate, DateTime(2026, 11, 5));
  });
}
