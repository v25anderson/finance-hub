import 'dart:convert';

import 'package:finance_hub/data/backup/backup_repository.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/recurring_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/backup/snapshot.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_db.dart';

Future<void> populate(AppDatabase db) async {
  final tx = TransactionRepository(db);
  final plan = PlanningRepository(db);
  final a = await tx.create(name: 'Aluguel', plannedAmountCents: 180000, dueDate: DateTime(2026, 10, 1), categoryId: 'cat-moradia', expenseType: ExpenseType.fixed, note: 'ç ã "x"\nlinha');
  await tx.addPayment(transactionId: a, amountCents: 50000, paidAt: DateTime.utc(2026, 10, 2, 8), note: 'parte');
  final gone = await tx.create(name: 'Apagada', plannedAmountCents: 100, dueDate: DateTime(2026, 10, 3), categoryId: 'cat-outros', expenseType: ExpenseType.oneOff);
  await tx.softDelete(gone);
  await plan.updatePlanning(salaryCents: 800000, investmentCents: 100000);
  await plan.setMonthConfig('2026-11', salaryCents: 920000);
  await plan.addIncome(yearMonth: '2026-10', kind: IncomeKind.extra, amountCents: 10000, description: 'freela');
  await plan.addInvestment(yearMonth: '2026-10', plannedCents: 1, realizedCents: 2);
  await RecurringRepository(db).create(name: 'Netflix', baseAmountCents: 3990, categoryId: 'cat-assinaturas', expenseType: ExpenseType.fixed, frequency: Frequency.monthly, start: DateTime(2026, 1, 10));
}

Future<Map<String, Object?>> fingerprint(AppDatabase db) async => (await BackupRepository(db).createSnapshot()).toJson()..remove('createdAt');

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDb(clock: () => DateTime.utc(2026, 10, 10, 12)));
  tearDown(() => db.close());

  test('snapshot tem envelope, contagens e codifica/decodifica sem perda', () async {
    await populate(db);
    final s = await BackupRepository(db).createSnapshot();
    expect(s.schemaVersion, db.schemaVersion);
    expect(s.counts['transactions'], 2);
    expect(s.counts['payments'], 1);
    expect(s.counts['categories'], 11);
    final back = BackupSnapshot.decode(s.encode(), maxSchemaVersion: db.schemaVersion);
    expect(jsonEncode(back.toJson()), jsonEncode(s.toJson()));
  });

  test('ida e volta: restaurar num banco vazio reproduz tudo, inclusive excluídos e acentos', () async {
    await populate(db);
    final original = await fingerprint(db);
    final bytes = (await BackupRepository(db).createSnapshot()).encode();

    final other = memoryDb(clock: () => DateTime.utc(2026, 10, 10, 12));
    addTearDown(other.close);
    await BackupRepository(other).restore(BackupSnapshot.decode(bytes, maxSchemaVersion: other.schemaVersion));
    final restored = await fingerprint(other);
    // deviceId do envelope é do aparelho; o conteúdo das tabelas deve ser idêntico
    expect(jsonEncode(restored['tables']), jsonEncode(original['tables']));
    final bills = await other.select(other.transactions).get();
    expect(bills.firstWhere((b) => b.name == 'Aluguel').note, 'ç ã "x"\nlinha');
    expect(bills.firstWhere((b) => b.name == 'Apagada').deletedAt, isNotNull);
  });

  test('restaurar substitui os dados atuais e é idempotente', () async {
    await populate(db);
    final bytes = (await BackupRepository(db).createSnapshot()).encode();
    await TransactionRepository(db).create(name: 'Nova depois do backup', plannedAmountCents: 1, dueDate: DateTime(2026, 10, 20), categoryId: 'cat-outros', expenseType: ExpenseType.oneOff);
    final snap = BackupSnapshot.decode(bytes, maxSchemaVersion: db.schemaVersion);
    await BackupRepository(db).restore(snap);
    await BackupRepository(db).restore(snap);
    final names = (await db.select(db.transactions).get()).map((t) => t.name).toSet();
    expect(names, {'Aluguel', 'Apagada'});
  });

  test('preserva o deviceId local e recompõe o seed se o backup vier sem ele', () async {
    final device = await db.currentDeviceId();
    final empty = BackupSnapshot(createdAt: DateTime.utc(2026), deviceId: 'outro', schemaVersion: 2, tables: {for (final t in backupTables) t: const []});
    await BackupRepository(db).restore(empty);
    expect(await db.currentDeviceId(), device);
    expect((await db.select(db.categories).get()).length, 11);
    expect((await db.select(db.plannings).get()).length, 1);
  });

  test('falha no meio não deixa o banco pela metade', () async {
    await populate(db);
    final before = await fingerprint(db);
    final s = await BackupRepository(db).createSnapshot();
    // um pagamento aponta para uma conta que não existe: viola a chave estrangeira
    final bad = BackupSnapshot(
      createdAt: s.createdAt,
      deviceId: s.deviceId,
      schemaVersion: s.schemaVersion,
      tables: {...s.tables, 'transactions': const [], 'payments': s.tables['payments']!},
    );
    await expectLater(BackupRepository(db).restore(bad), throwsA(anything));
    expect(jsonEncode((await fingerprint(db))['tables']), jsonEncode(before['tables']));
  });

  group('validação do arquivo', () {
    int v() => db.schemaVersion;
    List<int> j(Map<String, Object?> m) => utf8.encode(jsonEncode(m));
    Future<Map<String, dynamic>> good() async => jsonDecode(jsonEncode((await BackupRepository(db).createSnapshot()).toJson())) as Map<String, dynamic>;

    test('recusa lixo, outro formato e versões mais novas', () async {
      expect(() => BackupSnapshot.decode(utf8.encode('não é json'), maxSchemaVersion: v()), throwsA(isA<BackupFormatError>()));
      expect(() => BackupSnapshot.decode(j({'format': 'outro'}), maxSchemaVersion: v()), throwsA(isA<BackupFormatError>()));
      final newer = await good();
      newer['schemaVersion'] = v() + 1;
      expect(() => BackupSnapshot.decode(j(newer), maxSchemaVersion: v()), throwsA(isA<BackupFormatError>()));
      final newerFormat = await good();
      newerFormat['formatVersion'] = 99;
      expect(() => BackupSnapshot.decode(j(newerFormat), maxSchemaVersion: v()), throwsA(isA<BackupFormatError>()));
    });

    test('recusa backup com tabela faltando ou linha inválida', () async {
      final noTable = await good();
      (noTable['tables'] as Map).remove('payments');
      expect(() => BackupSnapshot.decode(j(noTable), maxSchemaVersion: v()), throwsA(isA<BackupFormatError>()));
      final badRow = await good();
      (badRow['tables'] as Map)['payments'] = ['lixo'];
      expect(() => BackupSnapshot.decode(j(badRow), maxSchemaVersion: v()), throwsA(isA<BackupFormatError>()));
    });
  });
}
