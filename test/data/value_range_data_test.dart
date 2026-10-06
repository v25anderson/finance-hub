import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:finance_hub/application/bill_service.dart';
import 'package:finance_hub/application/recurrence_service.dart';
import 'package:finance_hub/data/backup/backup_repository.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/bill_repository.dart';
import 'package:finance_hub/data/repositories/recurring_repository.dart';
import 'package:finance_hub/data/repositories/repo_base.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/backup/snapshot.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/recurrence.dart';
import 'package:finance_hub/domain/value_range.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_transport.dart';
import 'sync_test.dart' show Device;
import 'test_db.dart';

const energia = ValueRange(20000, 30000);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late BillService svc;
  late BillRepository bills;
  late TransactionRepository tx;
  late RecurrenceService rec;

  setUp(() {
    db = memoryDb(clock: () => DateTime.utc(2026, 10, 10, 12));
    tx = TransactionRepository(db);
    bills = BillRepository(db);
    svc = BillService(bills: bills, transactions: tx, clock: () => DateTime(2026, 10, 10, 12));
    rec = RecurrenceService(rules: RecurringRepository(db), transactions: tx, bills: bills, clock: () => DateTime(2026, 10, 10, 12));
  });
  tearDown(() => db.close());

  Future<String> energy({ValueRange? range = energia, int cents = 25000, ExpenseType type = ExpenseType.variable}) =>
      svc.create(name: 'Energia', plannedCents: cents, dueDate: DateTime(2026, 10, 20), categoryId: 'cat-moradia', expenseType: type, range: range);

  group('valor real do gasto variável', () {
    test('real dentro da faixa vira o valor esperado e quita sem excedente', () async {
      final id = await energy();
      await svc.payActual(id, 23750);
      final b = (await bills.getBill(id))!;
      expect(b.plannedCents, 23750);
      expect(b.paidCents, 23750);
      expect(b.isFullyPaid, isTrue);
      expect(b.excessCents, 0);
      expect(b.range, energia);
    });

    test('real fora da faixa amplia a faixa para incluí-lo', () async {
      final id = await energy();
      await svc.payActual(id, 31000);
      final b = (await bills.getBill(id))!;
      expect(b.plannedCents, 31000);
      expect(b.range, const ValueRange(20000, 31000));
      expect(b.isFullyPaid, isTrue);
    });

    test('valor inválido é recusado', () async {
      final id = await energy();
      expect(() => svc.payActual(id, 0), throwsA(isA<ValidationError>()));
    });
  });

  group('conta avulsa', () {
    test('gasto variável guarda a faixa e a conta a devolve', () async {
      final id = await energy();
      final b = (await bills.getBill(id))!;
      expect(b.range, energia);
      expect(b.plannedCents, 25000);
    });

    test('só existe em gasto variável: em fixo ou pontual a faixa é descartada', () async {
      for (final t in [ExpenseType.fixed, ExpenseType.oneOff]) {
        final id = await energy(type: t);
        expect((await bills.getBill(id))!.range, isNull, reason: '$t');
      }
    });

    test('valor esperado fora da faixa e faixa inválida são recusados', () async {
      await expectLater(energy(cents: 31000), throwsA(isA<ValidationError>()));
      await expectLater(energy(cents: 19999), throwsA(isA<ValidationError>()));
      await expectLater(energy(range: const ValueRange(30000, 20000)), throwsA(isA<ValidationError>()));
      await expectLater(energy(range: const ValueRange(0, 20000), cents: 100), throwsA(isA<ValidationError>()));
      expect(await tx.getByMonth('2026-10'), isEmpty); // nada foi gravado
    });

    test('editar: define, troca e remove a faixa; limite exato vale', () async {
      final id = await energy(range: null);
      expect((await bills.getBill(id))!.range, isNull);
      await svc.update(id, range: const ValueRange(20000, 25000)); // 250 é o máximo: dentro
      expect((await bills.getBill(id))!.range, const ValueRange(20000, 25000));
      await svc.update(id, plannedCents: 22000, range: const ValueRange(21000, 26000));
      expect((await bills.getBill(id))!.range, const ValueRange(21000, 26000));
      await svc.update(id, clearRange: true);
      expect((await bills.getBill(id))!.range, isNull);
    });

    test('editar com valor fora da faixa é recusado e nada muda', () async {
      final id = await energy();
      await expectLater(svc.update(id, plannedCents: 99999, range: energia), throwsA(isA<ValidationError>()));
      await expectLater(svc.update(id, range: const ValueRange(30000, 40000)), throwsA(isA<ValidationError>())); // 250 ficaria fora
      final b = (await bills.getBill(id))!;
      expect(b.plannedCents, 25000);
      expect(b.range, energia);
    });

    test('deixar de ser variável apaga a faixa; dar faixa a conta fixa é recusado', () async {
      final id = await energy();
      await svc.update(id, expenseType: ExpenseType.fixed);
      expect((await bills.getBill(id))!.range, isNull);
      await expectLater(svc.update(id, range: energia), throwsA(isA<ValidationError>()));
    });

    test('duplicar copia a faixa', () async {
      final id = await energy();
      final copy = await svc.duplicate(id);
      expect((await bills.getBill(copy))!.range, energia);
    });

    test('a faixa não altera pagamentos nem o estado da conta', () async {
      final id = await energy();
      await svc.registerPayment(id, 31000); // acima da faixa: é aceito, só registrado
      final b = (await bills.getBill(id))!;
      expect(b.paidRangePosition, RangePosition.above);
      expect(b.excessCents, 6000);
      expect(b.isFullyPaid, isTrue);
    });
  });

  group('recorrência', () {
    Future<String> rule() => rec.createRecurring(
          name: 'Energia',
          amountCents: 25000,
          firstDue: DateTime(2026, 10, 20),
          categoryId: 'cat-moradia',
          expenseType: ExpenseType.variable,
          frequency: Frequency.monthly,
          range: energia,
        );

    test('todas as ocorrências geradas nascem com a faixa', () async {
      final id = await rule();
      final occ = await bills.getOccurrences(id);
      expect(occ.length, greaterThan(6));
      expect(occ.every((b) => b.range == energia), isTrue);
    });

    test('recorrência fixa não recebe faixa; valor fora da faixa é recusado', () async {
      final fixed = await rec.createRecurring(
          name: 'Aluguel', amountCents: 100000, firstDue: DateTime(2026, 10, 5), categoryId: 'cat-moradia', expenseType: ExpenseType.fixed, frequency: Frequency.monthly, range: energia);
      expect((await bills.getOccurrences(fixed)).every((b) => b.range == null), isTrue);
      await expectLater(
          rec.createRecurring(name: 'X', amountCents: 50000, firstDue: DateTime(2026, 10, 5), categoryId: 'cat-moradia', expenseType: ExpenseType.variable, frequency: Frequency.monthly, range: energia),
          throwsA(isA<ValidationError>()));
    });

    test('"esta e as próximas" troca a faixa nas próximas ainda não editadas e nas sem pagamento', () async {
      final id = await rule();
      final occ = await bills.getOccurrences(id);
      await svc.registerPayment(occ[3].id, 1000); // com pagamento: não é tocada
      await rec.editOccurrence(occ[1].id, EditScope.thisAndFollowing, plannedCents: 40000, range: const ValueRange(35000, 45000));
      final after = await bills.getOccurrences(id);
      expect(after[0].range, energia); // anterior: intacta
      expect(after[1].range, const ValueRange(35000, 45000));
      expect(after[2].range, const ValueRange(35000, 45000));
      expect(after[3].range, energia); // tinha pagamento
      expect(after[4].plannedCents, 40000);
      expect((await RecurringRepository(db).getRule(id))!.range, const ValueRange(35000, 45000)); // as futuras geradas depois usam a nova
    });

    test('"somente esta" não mexe nas outras; clearRange remove só nesta', () async {
      final id = await rule();
      final occ = await bills.getOccurrences(id);
      await rec.editOccurrence(occ[2].id, EditScope.thisOnly, clearRange: true);
      final after = await bills.getOccurrences(id);
      expect(after[2].range, isNull);
      expect(after[1].range, energia);
      expect(after[3].range, energia);
    });
  });

  test('backup: a faixa sobrevive à ida e volta', () async {
    final id = await energy();
    final repo = BackupRepository(db);
    final snap = BackupSnapshot.decode((await repo.createSnapshot()).encode(), maxSchemaVersion: db.schemaVersion);
    await tx.update(id, clearRange: true);
    await repo.restore(snap);
    expect((await bills.getBill(id))!.range, energia);
  });

  test('sincronização: a faixa chega ao outro aparelho e a remoção também', () async {
    final cloud = MemoryTransport();
    final a = Device('A', cloud), b = Device('B', cloud);
    addTearDown(() async {
      await a.db.close();
      await b.db.close();
    });
    final id = await a.tx.create(
        name: 'Energia', plannedAmountCents: 25000, dueDate: DateTime(2026, 10, 20), categoryId: 'cat-moradia', expenseType: ExpenseType.variable, range: energia);
    await a.sync.sync();
    await b.sync.sync();
    expect((await b.row(id)).plannedMinCents, 20000);
    expect((await b.row(id)).plannedMaxCents, 30000);
    await a.tx.update(id, clearRange: true); // valores nulos também precisam atravessar
    await a.sync.sync();
    await b.sync.sync();
    expect((await b.row(id)).plannedMinCents, isNull);
    expect((await b.row(id)).plannedMaxCents, isNull);
  });
}
