import 'package:finance_hub/app/app.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/providers.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/test_db.dart';
import '../support/drive_fakes.dart';
import 'package:finance_hub/application/drive/drive_storage.dart';
import 'test_harness.dart';

Future<Harness> openBackup(WidgetTester t, {required FakeAuth auth, required FakeDrive drive, required FakeSafety safety, Future<void> Function(AppDatabase)? seed}) async {
  t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
  t.view.physicalSize = const Size(390, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final db = memoryDb(clock: () => fixedNow.toUtc());
  if (seed != null) await t.runAsync(() => seed(db));
  await t.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => fixedNow),
      driveAuthProvider.overrideWithValue(auth),
      driveStorageProvider.overrideWithValue(drive),
      safetyCopyStoreProvider.overrideWithValue(safety),
    ],
    child: const FinanceHubApp(),
  ));
  final h = Harness(t, db);
  await h.settle();
  await t.tap(find.text('Análises'));
  await h.settle();
  await t.tap(find.byKey(const Key('backup-open')));
  await h.settle();
  return h;
}

Future<void> bill(AppDatabase db, String name) => TransactionRepository(db)
    .create(name: name, plannedAmountCents: 1000, dueDate: DateTime(2026, 10, 20), categoryId: 'cat-outros', expenseType: ExpenseType.oneOff)
    .then((_) {});

void main() {
  setUpAll(initHarness);

  testWidgets('sem cliente OAuth configurado: explica e não oferece conexão', (t) async {
    final h = await openBackup(t, auth: FakeAuth(available: false), drive: FakeDrive(), safety: FakeSafety());
    expect(find.byKey(const Key('backup-unavailable')), findsOneWidget);
    expect(find.byKey(const Key('backup-connect')), findsNothing);
    await h.finish();
  });

  testWidgets('conectar, fazer backup, restaurar com confirmação e excluir', (t) async {
    final drive = FakeDrive();
    final safety = FakeSafety();
    final h = await openBackup(t, auth: FakeAuth(), drive: drive, safety: safety, seed: (db) => bill(db, 'Original'));

    await t.tap(find.byKey(const Key('backup-connect')));
    await h.settle();
    expect(find.text('Conectado: pessoa@example.com'), findsOneWidget);
    expect(find.byKey(const Key('backup-empty')), findsOneWidget);

    await t.tap(find.byKey(const Key('backup-now')));
    await h.settle();
    expect(drive.files.length, 1);
    expect(find.textContaining('Backup enviado'), findsOneWidget);
    final id = drive.files.keys.single;
    expect(find.byKey(Key('backup-item-$id')), findsOneWidget);

    // altera os dados depois do backup
    await h.run(() => bill(h.db, 'Depois do backup'));
    expect((await h.run(() => h.db.select(h.db.transactions).get())).length, 2);

    await t.tap(find.byKey(Key('backup-restore-$id')));
    await h.settle();
    expect(find.text('Restaurar este backup?'), findsOneWidget);
    expect(find.textContaining('1 contas'), findsOneWidget);
    // cancelar não altera nada
    await t.tap(find.text('Cancelar'));
    await h.settle();
    expect((await h.run(() => h.db.select(h.db.transactions).get())).length, 2);
    expect(safety.saved, isEmpty);

    await t.tap(find.byKey(Key('backup-restore-$id')));
    await h.settle();
    await t.tap(find.byKey(const Key('backup-restore-confirm')));
    await h.settle();
    final names = (await h.run(() => h.db.select(h.db.transactions).get())).map((x) => x.name).toList();
    expect(names, ['Original']);
    expect(safety.saved.length, 1);
    expect(find.textContaining('Dados restaurados'), findsOneWidget);

    await t.tap(find.byKey(Key('backup-delete-$id')));
    await h.settle();
    await t.tap(find.byKey(const Key('backup-delete-confirm')));
    await h.settle();
    expect(drive.files, isEmpty);
    expect(find.byKey(const Key('backup-empty')), findsOneWidget);

    await t.tap(find.byKey(const Key('backup-disconnect')));
    await h.settle();
    expect(find.byKey(const Key('backup-connect')), findsOneWidget);
    await h.finish();
  });

  testWidgets('permissão expirada derruba a conexão e dados locais ficam intactos', (t) async {
    final drive = FakeDrive();
    final h = await openBackup(t, auth: FakeAuth(), drive: drive, safety: FakeSafety(), seed: (db) => bill(db, 'Original'));
    await t.tap(find.byKey(const Key('backup-connect')));
    await h.settle();
    drive.failNext = DriveException(DriveFailure.unauthorized);
    await t.tap(find.byKey(const Key('backup-now')));
    await h.settle();
    expect(find.byKey(const Key('backup-connect')), findsOneWidget);
    expect(find.byKey(const Key('backup-error')), findsOneWidget);
    expect((await h.run(() => h.db.select(h.db.transactions).get())).length, 1);
    await h.finish();
  });

  testWidgets('conexão recusada mostra o motivo e permite tentar de novo', (t) async {
    final auth = FakeAuth(failSignIn: true);
    final h = await openBackup(t, auth: auth, drive: FakeDrive(), safety: FakeSafety());
    await t.tap(find.byKey(const Key('backup-connect')));
    await h.settle();
    expect(find.text('Conexão cancelada.'), findsOneWidget);
    auth.failSignIn = false;
    await t.tap(find.byKey(const Key('backup-connect')));
    await h.settle();
    expect(find.byKey(const Key('backup-account')), findsOneWidget);
    await h.finish();
  });
}
