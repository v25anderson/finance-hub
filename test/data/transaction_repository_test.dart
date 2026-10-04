import 'package:finance_hub/core/dates.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/repo_base.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository repo;
  setUp(() {
    db = memoryDb();
    repo = TransactionRepository(db);
  });
  tearDown(() => db.close());

  Future<String> make(String name, DateTime due, {int cents = 100000, String? recurringId}) =>
      repo.create(name: name, plannedAmountCents: cents, dueDate: due, categoryId: 'cat-moradia', recurringId: recurringId);

  test('cria e consulta por mês (fronteiras inclusivas/exclusivas)', () async {
    await make('Fim de setembro', DateTime(2026, 9, 30));
    await make('Início de outubro', DateTime(2026, 10, 1));
    await make('Fim de outubro', DateTime(2026, 10, 31));
    await make('Início de novembro', DateTime(2026, 11, 1));
    final out = await repo.getByMonth('2026-10');
    expect(out.map((t) => t.name), ['Início de outubro', 'Fim de outubro']);
  });

  test('mês sem lançamentos retorna lista vazia', () async {
    expect(await repo.getByMonth('2030-01'), isEmpty);
  });

  test('valida nome vazio e valor negativo', () {
    expect(() => make(' ', DateTime(2026, 10, 1)), throwsA(isA<ValidationError>()));
    expect(() => make('x', DateTime(2026, 10, 1), cents: -1), throwsA(isA<ValidationError>()));
  });

  test('dueDate é gravado como data pura ISO', () async {
    final id = await make('x', DateTime(2026, 3, 5, 23, 59));
    expect((await repo.getById(id))!.dueDate, '2026-03-05');
  });

  group('pagamentos', () {
    test('múltiplos pagamentos ficam registrados em ordem', () async {
      final id = await make('Conta', DateTime(2026, 10, 10), cents: 200000);
      await repo.addPayment(transactionId: id, amountCents: 80000, paidAt: DateTime.utc(2026, 10, 2));
      await repo.addPayment(transactionId: id, amountCents: 50000, paidAt: DateTime.utc(2026, 10, 1));
      final ps = await repo.getPayments(id);
      expect(ps.map((p) => p.amountCents), [50000, 80000]);
    });

    test('pagamento maior que o previsto é aceito (excedente preservado)', () async {
      final id = await make('Conta', DateTime(2026, 10, 10), cents: 10000);
      await repo.addPayment(transactionId: id, amountCents: 15000);
      expect((await repo.getPayments(id)).single.amountCents, 15000);
    });

    test('valor zero ou negativo é rejeitado', () async {
      final id = await make('Conta', DateTime(2026, 10, 10));
      expect(() => repo.addPayment(transactionId: id, amountCents: 0), throwsA(isA<ValidationError>()));
      expect(() => repo.addPayment(transactionId: id, amountCents: -5), throwsA(isA<ValidationError>()));
    });

    test('conta cancelada ou inexistente não aceita pagamento', () async {
      final id = await make('Conta', DateTime(2026, 10, 10));
      await repo.cancel(id);
      expect(() => repo.addPayment(transactionId: id, amountCents: 100), throwsA(isA<ValidationError>()));
      expect(() => repo.addPayment(transactionId: 'nada', amountCents: 100), throwsA(isA<NotFoundError>()));
    });

    test('excluir pagamento é soft delete', () async {
      final id = await make('Conta', DateTime(2026, 10, 10));
      final p = await repo.addPayment(transactionId: id, amountCents: 100);
      await repo.deletePayment(p);
      expect(await repo.getPayments(id), isEmpty);
      expect(await db.select(db.payments).get(), hasLength(1));
    });

    test('pagamentos do mês consideram só lançamentos ativos do mês', () async {
      final a = await make('A', DateTime(2026, 10, 5));
      final b = await make('B', DateTime(2026, 11, 5));
      final c = await make('C', DateTime(2026, 10, 6));
      await repo.addPayment(transactionId: a, amountCents: 100);
      await repo.addPayment(transactionId: b, amountCents: 200);
      await repo.addPayment(transactionId: c, amountCents: 400);
      await repo.softDelete(c);
      final ps = await repo.getPaymentsForMonth('2026-10');
      expect(ps.map((p) => p.amountCents), [100]);
    });
  });

  group('exclusão e histórico', () {
    test('soft delete preserva pagamentos e permite restaurar', () async {
      final id = await make('Conta', DateTime(2026, 10, 10));
      await repo.addPayment(transactionId: id, amountCents: 100);
      await repo.softDelete(id);
      expect(await repo.getById(id), isNull);
      expect(await db.select(db.payments).get(), hasLength(1));
      await repo.restore(id);
      expect(await repo.getById(id), isNotNull);
      expect(await repo.getPayments(id), hasLength(1));
    });

    test('excluir ocorrência de recorrência não afeta as demais', () async {
      final rid = await _recurring(db);
      final o1 = await make('Netflix', DateTime(2026, 9, 10), recurringId: rid);
      final o2 = await make('Netflix', DateTime(2026, 10, 10), recurringId: rid);
      final o3 = await make('Netflix', DateTime(2026, 11, 10), recurringId: rid);
      await repo.softDelete(o2);
      expect(await repo.getById(o1), isNotNull);
      expect(await repo.getById(o2), isNull);
      expect(await repo.getById(o3), isNotNull);
    });

    test('cancelar mantém a conta e registra canceledAt', () async {
      final id = await make('Conta', DateTime(2026, 10, 10));
      await repo.cancel(id);
      expect((await repo.getById(id))!.canceledAt, isNotNull);
    });
  });

  group('edição', () {
    test('editar ocorrência de recorrência marca overridden; editar só favorito não', () async {
      final rid = await _recurring(db);
      final id = await make('Netflix', DateTime(2026, 10, 10), cents: 3990, recurringId: rid);
      await repo.update(id, favorite: true);
      expect((await repo.getById(id))!.overridden, isFalse);
      await repo.update(id, plannedAmountCents: 4490);
      final row = (await repo.getById(id))!;
      expect(row.overridden, isTrue);
      expect(row.plannedAmountCents, 4490);
      expect(row.version, 3);
    });

    test('editar conta inexistente lança NotFoundError', () {
      expect(() => repo.update('nada', name: 'x'), throwsA(isA<NotFoundError>()));
    });
  });

  group('duplicar', () {
    test('cria nova entidade, sem pagamentos e sem recorrência', () async {
      final rid = await _recurring(db);
      final id = await make('Netflix', DateTime(2026, 10, 10), cents: 3990, recurringId: rid);
      await repo.addPayment(transactionId: id, amountCents: 3990);
      final copy = await repo.duplicate(id);
      expect(copy, isNot(id));
      final row = (await repo.getById(copy))!;
      expect(row.name, 'Netflix (cópia)');
      expect(row.plannedAmountCents, 3990);
      expect(row.recurringId, isNull);
      expect(await repo.getPayments(copy), isEmpty);
    });
  });

  test('ordem por vencimento e depois por nome', () async {
    await make('B', DateTime(2026, 10, 10));
    await make('A', DateTime(2026, 10, 10));
    await make('C', DateTime(2026, 10, 2));
    expect((await repo.getByMonth('2026-10')).map((t) => t.name), ['C', 'A', 'B']);
  });

  test('yearMonthOf e monthRange', () {
    expect(yearMonthOf(DateTime(2026, 12, 31)), '2026-12');
    expect(monthRange('2026-12').endExclusive, '2027-01-01');
    expect(daysInMonth(2026, 2), 28);
    expect(daysInMonth(2028, 2), 29);
  });
}

Future<String> _recurring(AppDatabase db) async {
  final t = DateTime.utc(2026, 1, 1);
  const id = 'rec-1';
  await db.into(db.recurringTransactions).insert(RecurringTransactionsCompanion.insert(
        id: id,
        createdAt: t,
        updatedAt: t,
        name: 'Netflix',
        baseAmountCents: 3990,
        categoryId: 'cat-assinaturas',
        expenseType: ExpenseType.fixed,
        frequency: Frequency.monthly,
        dueDay: 10,
        startDate: '2026-01-10',
      ));
  return id;
}
