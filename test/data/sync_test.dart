import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:finance_hub/application/recurrence_service.dart';
import 'package:finance_hub/application/sync/sync_service.dart';
import 'package:finance_hub/application/sync/sync_transport.dart';
import 'package:finance_hub/data/backup/backup_repository.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/bill_repository.dart';
import 'package:finance_hub/data/repositories/category_repository.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/recurring_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/data/sync/sync_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/sync/change_file.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/memory_transport.dart';
import 'test_db.dart';

class Device {
  Device(this.name, MemoryTransport t) : db = memoryDb(clock: () => DateTime.utc(2026, 10, 10, 12)) {
    tx = TransactionRepository(db);
    plan = PlanningRepository(db);
    cats = CategoryRepository(db);
    repo = SyncRepository(db);
    sync = SyncService(repository: repo, transport: t, db: db, clock: () => DateTime.utc(2026, 10, 10, 12));
  }
  final String name;
  final AppDatabase db;
  late final TransactionRepository tx;
  late final PlanningRepository plan;
  late final CategoryRepository cats;
  late final SyncRepository repo;
  late final SyncService sync;

  Future<String> bill(String name, {int cents = 1000, String cat = 'cat-outros'}) =>
      tx.create(name: name, plannedAmountCents: cents, dueDate: DateTime(2026, 10, 20), categoryId: cat, expenseType: ExpenseType.fixed);

  Future<TransactionRow> row(String id) => (db.select(db.transactions)..where((t) => t.id.equals(id))).getSingle();
  Future<List<TransactionRow>> allBills() => db.select(db.transactions).get();
  Future<List<PaymentRow>> allPayments() => db.select(db.payments).get();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true; // dois aparelhos simulados no mesmo teste
  late MemoryTransport cloud;
  late Device a, b;

  setUp(() {
    cloud = MemoryTransport();
    a = Device('A', cloud);
    b = Device('B', cloud);
  });
  tearDown(() async {
    await a.db.close();
    await b.db.close();
  });

  test('o que A cria aparece em B, com pagamentos e categorias', () async {
    final id = await a.bill('Aluguel', cents: 180000);
    await a.tx.addPayment(transactionId: id, amountCents: 50000);
    final r = await a.sync.sync();
    expect(r.pushed, greaterThan(0));
    await b.sync.sync();
    expect((await b.allBills()).map((x) => x.name), ['Aluguel']);
    expect((await b.allPayments()).single.amountCents, 50000);
  });

  test('não há ping-pong: sincronizar de novo não envia nem altera nada', () async {
    await a.bill('Aluguel');
    await a.sync.sync();
    await b.sync.sync();
    final filesBefore = cloud.files.length;
    final rb = await b.sync.sync();
    final ra = await a.sync.sync();
    expect(rb.pushed, 0);
    expect(ra.pushed, 0);
    expect(ra.applied + ra.merged + rb.applied + rb.merged, 0);
    expect(cloud.files.length, filesBefore);
  });

  test('campos diferentes editados nos dois aparelhos são combinados, em ambos', () async {
    final id = await a.bill('Internet', cents: 10000);
    await a.sync.sync();
    await b.sync.sync();
    await a.tx.update(id, plannedAmountCents: 12000);
    await b.tx.update(id, note: 'vence dia 20');
    await a.sync.sync();
    final rb = await b.sync.sync();
    expect(rb.merged, 1);
    await a.sync.sync();
    for (final d in [a, b]) {
      final r = await d.row(id);
      expect(r.plannedAmountCents, 12000, reason: d.name);
      expect(r.note, 'vence dia 20', reason: d.name);
    }
    expect((await a.sync.sync()).pushed, 0);
  });

  test('mesmo campo: vira conflito, nada é sobrescrito; manter o meu propaga', () async {
    final id = await a.bill('Luz', cents: 10000);
    await a.sync.sync();
    await b.sync.sync();
    await a.tx.update(id, plannedAmountCents: 11000);
    await b.tx.update(id, plannedAmountCents: 15000);
    await a.sync.sync();
    final rb = await b.sync.sync();
    expect(rb.newConflicts, 1);
    expect((await b.row(id)).plannedAmountCents, 15000); // B continua com o seu
    final c = (await b.repo.watchOpenConflicts().first).single;
    expect(c.entity, 'transactions');
    expect(c.recordId, id);
    expect((await b.sync.sync()).pushed, 0); // registro em conflito não é enviado

    await b.repo.resolve(c.id, ConflictChoice.keepLocal);
    await b.sync.sync();
    await a.sync.sync();
    expect((await a.row(id)).plannedAmountCents, 15000);
    expect(await b.repo.watchOpenConflicts().first, isEmpty);
  });

  test('conflito resolvido com "usar o outro" adota o remoto e não reenvia', () async {
    final id = await a.bill('Água', cents: 5000);
    await a.sync.sync();
    await b.sync.sync();
    await a.tx.update(id, plannedAmountCents: 6000);
    await b.tx.update(id, plannedAmountCents: 7000);
    await a.sync.sync();
    await b.sync.sync();
    final c = (await b.repo.watchOpenConflicts().first).single;
    await b.repo.resolve(c.id, ConflictChoice.useRemote);
    expect((await b.row(id)).plannedAmountCents, 6000);
    expect((await b.sync.sync()).pushed, 0);
    expect((await a.row(id)).plannedAmountCents, 6000);
  });

  test('exclusão e restauração se propagam (tombstone)', () async {
    final id = await a.bill('Apagar');
    await a.sync.sync();
    await b.sync.sync();
    await a.tx.softDelete(id);
    await a.sync.sync();
    await b.sync.sync();
    expect((await b.row(id)).deletedAt, isNotNull);
    await b.tx.restore(id);
    await b.sync.sync();
    await a.sync.sync();
    expect((await a.row(id)).deletedAt, isNull);
  });

  test('pagamentos feitos nos dois aparelhos são somados, sem perda nem duplicação', () async {
    final id = await a.bill('Cartão', cents: 100000);
    await a.sync.sync();
    await b.sync.sync();
    await a.tx.addPayment(transactionId: id, amountCents: 10000);
    await b.tx.addPayment(transactionId: id, amountCents: 20000);
    await a.sync.sync();
    await b.sync.sync();
    await a.sync.sync();
    for (final d in [a, b]) {
      expect((await d.allPayments()).map((p) => p.amountCents).toList()..sort(), [10000, 20000], reason: d.name);
    }
  });

  test('padrões criados pelo seed não geram conflito; edição de um lado vale no outro', () async {
    await a.plan.setDefaultsFrom('2026-10', salaryCents: 800000, extraIncomeCents: 0, savingsGoalCents: 0, investmentCents: 0);
    await a.cats.update('cat-lazer', name: 'Diversão');
    await a.sync.sync();
    final rb = await b.sync.sync();
    expect(rb.newConflicts, 0);
    expect((await b.plan.getDefaultsTimeline()).atOrZero('2026-10').salaryCents, 800000);
    expect((await (b.db.select(b.db.categories)..where((c) => c.id.equals('cat-lazer'))).getSingle()).name, 'Diversão');
    expect((await b.sync.sync()).newConflicts, 0);
  });

  test('recorrência gerada nos dois aparelhos não duplica ocorrências', () async {
    Future<RecurrenceService> svc(Device d) async => RecurrenceService(
          rules: RecurringRepository(d.db),
          transactions: d.tx,
          bills: BillRepository(d.db),
          clock: () => DateTime(2026, 10, 10, 12),
        );
    final sa = await svc(a);
    await sa.createRecurring(name: 'Netflix', amountCents: 3990, categoryId: 'cat-assinaturas', expenseType: ExpenseType.fixed, frequency: Frequency.monthly, firstDue: DateTime(2026, 10, 10));
    await a.sync.sync();
    await b.sync.sync();
    final sb = await svc(b);
    await sb.ensureThrough(DateTime(2027, 6, 30)); // B gera por conta própria
    await sa.ensureThrough(DateTime(2027, 6, 30));
    await a.sync.sync();
    final rb = await b.sync.sync();
    await a.sync.sync();
    await b.sync.sync();
    final ids = (await a.allBills()).map((x) => x.id).toSet();
    expect((await a.allBills()).length, ids.length);
    expect(ids, (await b.allBills()).map((x) => x.id).toSet());
    expect(rb.skipped, 0);
    expect((await a.allBills()).length, greaterThan(12));
  });

  test('registros com conflito aberto recebem a versão remota mais nova, sem decidir pelo usuário', () async {
    final id = await a.bill('X', cents: 1);
    await a.sync.sync();
    await b.sync.sync();
    await a.tx.update(id, plannedAmountCents: 2);
    await b.tx.update(id, plannedAmountCents: 3);
    await a.sync.sync();
    await b.sync.sync();
    await a.tx.update(id, plannedAmountCents: 4);
    await a.sync.sync();
    await b.sync.sync();
    final c = (await b.repo.watchOpenConflicts().first);
    expect(c.length, 1);
    expect(c.single.remoteJson, contains('4'));
    expect((await b.row(id)).plannedAmountCents, 3);
  });

  group('robustez', () {
    test('falha no envio: nada se perde e a próxima tentativa envia', () async {
      await a.bill('Pendente');
      cloud.failUploads = true;
      await expectLater(a.sync.sync(), throwsA(isA<StateError>()));
      expect((await a.repo.meta()).state, SyncState.error);
      cloud.failUploads = false;
      final r = await a.sync.sync();
      expect(r.pushed, greaterThan(0));
      expect((await a.repo.meta()).state, SyncState.synced);
      await b.sync.sync();
      expect((await b.allBills()).single.name, 'Pendente');
    });

    test('arquivo de versão mais nova: erro claro e nenhum dado aplicado', () async {
      await a.bill('Antes');
      await a.sync.sync();
      final newer = ChangeFile(deviceId: 'zzzz-0001', seq: 1, schemaVersion: b.db.schemaVersion + 1, createdAt: DateTime.utc(2027), changes: const []);
      await cloud.uploadChangeFile('zzzz-0001', 1, newer.encode());
      await expectLater(b.sync.sync(), throwsA(isA<SyncFormatError>()));
      expect(await b.allBills(), isEmpty); // nem o arquivo bom de A foi aplicado: tudo ou nada
      expect((await b.repo.meta()).state, SyncState.error);
    });

    test('restaurar um backup recomeça o histórico de sincronização', () async {
      await a.bill('Um');
      await a.sync.sync();
      expect((await a.db.select(a.db.syncBase).get()), isNotEmpty);
      final snap = await BackupRepository(a.db).createSnapshot();
      await BackupRepository(a.db).restore(snap);
      expect((await a.db.select(a.db.syncBase).get()), isEmpty);
      expect((await a.repo.cursor()).ownSeq, 0);
    });
  });

  group('seleção de arquivos', () {
    RemoteChangeFile f(String dev, int seq, [int sec = 0]) => RemoteChangeFile(id: '$dev$seq-$sec', deviceId: dev, seq: seq, modifiedAt: DateTime.utc(2026, 1, 1, 0, 0, sec));

    test('ignora arquivos do próprio aparelho', () {
      final s = SyncService.select([f('me', 1), f('x', 1)], const SyncCursor(), 'me');
      expect(s.files.map((e) => e.deviceId), ['x']);
    });

    test('lê em sequência a partir do cursor e para no primeiro buraco', () {
      final s = SyncService.select([f('x', 1), f('x', 2), f('x', 4), f('x', 5)], const SyncCursor(peers: {'x': 1}), 'me');
      expect(s.files.map((e) => e.seq), [2]);
      expect(s.waiting, 2);
    });

    test('aparelho novo começa no menor arquivo disponível', () {
      final s = SyncService.select([f('x', 7), f('x', 8)], const SyncCursor(), 'me');
      expect(s.files.map((e) => e.seq), [7, 8]);
    });

    test('número repetido: vale o envio mais recente', () {
      final s = SyncService.select([f('x', 1, 1), f('x', 1, 9)], const SyncCursor(), 'me');
      expect(s.files.single.modifiedAt.second, 9);
    });
  });
}
