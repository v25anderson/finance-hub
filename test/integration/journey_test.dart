import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:finance_hub/application/file_saver.dart';
import 'package:finance_hub/application/sync/sync_service.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/providers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:finance_hub/data/sync/sync_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/test_db.dart';
import '../features/test_harness.dart';
import '../support/csv_parser.dart';
import '../support/drive_fakes.dart';
import '../support/memory_transport.dart';

class _Saver implements FileSaver {
  String? name;
  Uint8List? bytes;
  @override
  Future<bool> save({required String fileName, required Uint8List bytes, required String mime}) async {
    name = fileName;
    this.bytes = bytes;
    return true;
  }
}

/// Fecha a folha aberta tocando na área escura acima dela.
Future<void> dismissSheet(WidgetTester t, Harness h) async {
  await t.tapAt(const Offset(195, 12));
  await h.settle();
}

TransactionsCompanion _deleted(Harness h) => TransactionsCompanion(deletedAt: Value(fixedNow.toUtc()));

Future<void> tab(WidgetTester t, Harness h, String name) async {
  await t.tap(find.byKey(Key('nav-$name')));
  await h.settle();
}

void main() {
  setUpAll(initHarness);
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('jornada completa: cadastrar → pagar → dashboard → exportar → backup → restaurar → sincronizar', (t) async {
    final saver = _Saver();
    final drive = FakeDrive();
    final safety = FakeSafety();
    final cloud = MemoryTransport();
    final h = await pumpApp(t, overrides: [
      fileSaverProvider.overrideWithValue(saver),
      driveAuthProvider.overrideWithValue(FakeAuth()),
      driveStorageProvider.overrideWithValue(drive),
      safetyCopyStoreProvider.overrideWithValue(safety),
      syncTransportProvider.overrideWithValue(cloud),
    ]);

    // 1. cadastra uma conta pelo botão "+"
    await tab(t, h, 'Contas');
    await t.tap(find.byTooltip('Adicionar'));
    await h.settle();
    await t.enterText(field('Nome'), 'Internet fibra');
    await t.enterText(field('Valor'), '100');
    await tapSave(t);
    await h.settle();
    expect(find.text('Internet fibra'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);

    // 2. paga parcialmente (30 de 100): a conta passa a "parcialmente paga", nunca "paga"
    await t.tap(find.text('Internet fibra'));
    await h.settle();
    await t.tap(find.text('Pagamento parcial'));
    await h.settle();
    await t.enterText(field('Valor'), '30');
    await t.tap(find.text('Registrar'));
    await h.settle();
    expect(find.text('Parcialmente paga'), findsWidgets);
    expect(find.text('30% pago'), findsOneWidget);
    await dismissSheet(t, h);

    // 3. o dashboard reflete: total 100, pago 30, pendente 70
    await tab(t, h, 'Visão geral');
    expect(find.text('R\$ 100,00'), findsWidgets);
    expect(find.text('R\$ 30,00'), findsWidgets);
    expect(find.text('R\$ 70,00'), findsWidgets);

    // 4. exporta: ZIP com contas e pagamentos, status derivado correto, nada sai do aparelho além do arquivo
    await tab(t, h, 'Análises');
    await t.tap(find.byKey(const Key('export-open')));
    await h.settle();
    await t.scrollUntilVisible(find.byKey(const Key('export-submit')), 150, scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).last);
    await t.tap(find.byKey(const Key('export-submit')));
    await h.settle();
    expect(saver.name, 'finance_hub_2026-10-10.zip');
    final zip = ZipDecoder().decodeBytes(saver.bytes!);
    final bills = parseCsv(utf8.decode(zip.findFile('contas.csv')!.content as List<int>));
    expect(bills[1][1], 'Internet fibra');
    expect(bills[1][6], '100.00');
    expect(bills[1][7], '30.00');
    expect(bills[1][11], 'parcialmente_paga');
    final pays = parseCsv(utf8.decode(zip.findFile('pagamentos.csv')!.content as List<int>));
    expect(pays[1][3], '30.00');

    // 5. conecta ao Drive, faz backup e sincroniza
    await t.tap(find.byKey(const Key('backup-open')));
    await h.settle();
    await t.tap(find.byKey(const Key('backup-connect')));
    await h.settle();
    await t.tap(find.byKey(const Key('backup-now')));
    await h.settle();
    expect(drive.files.length, 1);
    await t.tap(find.byKey(const Key('sync-now')));
    await h.settle();
    expect(find.descendant(of: find.byKey(const Key('sync-badge')), matching: find.text('Sincronizado')), findsOneWidget);

    // 6. o segundo aparelho recebe a conta e o pagamento
    final other = memoryDb(clock: () => fixedNow.toUtc());
    addTearDown(() => t.runAsync(other.close));
    await t.runAsync(() => SyncService(repository: SyncRepository(other), transport: cloud, db: other, clock: () => fixedNow).sync());
    final remoteBills = await t.runAsync(() => other.select(other.transactions).get());
    final remotePays = await t.runAsync(() => other.select(other.payments).get());
    expect(remoteBills!.map((b) => b.name), ['Internet fibra']);
    expect(remotePays!.single.amountCents, 3000);

    // 7. apaga a conta neste aparelho e restaura o backup pela tela: ela volta, com o pagamento, e há cópia de segurança
    await h.run(() => h.db.update(h.db.transactions).write(_deleted(h)));
    expect((await h.run(() => h.db.select(h.db.transactions).get())).single.deletedAt, isNotNull);
    final id = drive.files.keys.single;
    await t.tap(find.byKey(Key('backup-restore-$id')));
    await h.settle();
    await t.tap(find.byKey(const Key('backup-restore-confirm')));
    await h.settle();
    final restored = await h.run(() => h.db.select(h.db.transactions).get());
    expect(restored.single.deletedAt, isNull);
    expect(restored.single.name, 'Internet fibra');
    expect(safety.saved.length, 1);
    await dismissSheet(t, h);

    // 8. de volta a Contas, a conta continua parcialmente paga (o estado é derivado, não gravado)
    await tab(t, h, 'Contas');
    expect(find.text('Internet fibra'), findsOneWidget);
    expect(find.text('Parcialmente paga'), findsOneWidget);
    await h.finish();
  }, timeout: const Timeout(Duration(minutes: 3)));
}
