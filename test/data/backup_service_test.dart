import 'dart:typed_data';

import 'package:finance_hub/application/backup_service.dart';
import 'package:finance_hub/application/drive/drive_storage.dart';
import 'package:finance_hub/data/backup/backup_repository.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/backup/snapshot.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/drive_fakes.dart';
import 'test_db.dart';

void main() {
  late AppDatabase db;
  late FakeDrive drive;
  late FakeSafety safety;
  late BackupService service;
  late TransactionRepository tx;

  setUp(() {
    db = memoryDb(clock: () => DateTime.utc(2026, 10, 10, 12));
    drive = FakeDrive();
    safety = FakeSafety();
    tx = TransactionRepository(db);
    service = BackupService(repository: BackupRepository(db), storage: drive, safety: safety, clock: () => DateTime.utc(2026, 10, 10, 12, 30, 5));
  });
  tearDown(() => db.close());

  Future<String> bill(String name) => tx.create(name: name, plannedAmountCents: 1000, dueDate: DateTime(2026, 10, 20), categoryId: 'cat-outros', expenseType: ExpenseType.oneOff);
  Future<List<String>> names() async => ((await db.select(db.transactions).get()).map((t) => t.name).toList()..sort());

  test('backup envia um arquivo com nome único por data e hora', () async {
    await bill('A');
    final r = await service.backupNow();
    expect(r.name, 'finance_hub_backup_20261010_123005.json');
    expect(drive.files.length, 1);
    final s = BackupSnapshot.decode(drive.files[r.id]!.bytes, maxSchemaVersion: db.schemaVersion);
    expect(s.counts['transactions'], 1);
  });

  test('restaurar: valida, guarda cópia de segurança e substitui os dados', () async {
    await bill('Antes');
    final b = await service.backupNow();
    await bill('Depois');
    final preview = await service.restore(b);
    expect(await names(), ['Antes']);
    expect(preview.counts['transactions'], 1);
    // a cópia de segurança contém o estado de ANTES da restauração (com "Depois")
    expect(safety.saved.keys.single, 'antes_de_restaurar_20261010_123005.json');
    final saved = BackupSnapshot.decode(safety.saved.values.single, maxSchemaVersion: db.schemaVersion);
    expect(saved.counts['transactions'], 2);
  });

  test('backup inválido ou de versão mais nova: nada é alterado e nenhuma cópia é feita', () async {
    await bill('Intacta');
    final garbage = await drive.uploadBackup('finance_hub_backup_x.json', Uint8List.fromList([1, 2, 3]));
    await expectLater(service.restore(garbage), throwsA(isA<BackupFormatError>()));
    final newer = BackupSnapshot(createdAt: DateTime.utc(2027), deviceId: 'x', schemaVersion: db.schemaVersion + 1, tables: {for (final t in backupTables) t: const []});
    final m = await drive.uploadBackup('finance_hub_backup_y.json', newer.encode());
    await expectLater(service.restore(m), throwsA(isA<BackupFormatError>()));
    expect(await names(), ['Intacta']);
    expect(safety.saved, isEmpty);
  });

  test('pré-visualização mostra contagens sem alterar os dados', () async {
    await bill('A');
    await bill('B');
    final b = await service.backupNow();
    await bill('C');
    final p = await service.preview(b);
    expect(p.counts['transactions'], 2);
    expect(p.total, greaterThan(2));
    expect(await names(), ['A', 'B', 'C']);
  });

  test('falhas do Drive viram DriveException e não mexem nos dados', () async {
    await bill('A');
    drive.failNext = DriveException(DriveFailure.network);
    await expectLater(service.backupNow(), throwsA(isA<DriveException>()));
    final b = await service.backupNow();
    drive.failNext = DriveException(DriveFailure.unauthorized);
    await expectLater(service.restore(b), throwsA(isA<DriveException>()));
    expect(await names(), ['A']);
    expect(safety.saved, isEmpty);
  });

  test('listar e excluir um backup remoto', () async {
    final a = await service.backupNow();
    await service.backupNow();
    expect((await service.list()).length, 2);
    await service.delete(a);
    expect((await service.list()).length, 1);
  });
}
