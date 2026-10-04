import 'dart:typed_data';

import 'package:finance_hub/app/app.dart';
import 'package:finance_hub/application/file_saver.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/providers.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/features/export/presentation/export_sheet.dart';
import 'package:finance_hub/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/test_db.dart';
import 'test_harness.dart';

class _Saver implements FileSaver {
  final saved = <String>[];
  @override
  Future<bool> save({required String fileName, required Uint8List bytes, required String mime}) async {
    saved.add(fileName);
    return true;
  }
}

Future<void> seed(AppDatabase db) async {
  await TransactionRepository(db).create(name: 'Aluguel', plannedAmountCents: 100000, dueDate: DateTime(2026, 10, 5), categoryId: 'cat-moradia', expenseType: ExpenseType.fixed);
}

void main() {
  setUpAll(initHarness);

  testWidgets('abre a exportação em Análises, desmarca tudo, bloqueia, exporta ZIP', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    t.view.physicalSize = const Size(390, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final db = memoryDb(clock: () => fixedNow.toUtc());
    await t.runAsync(() => seed(db));
    final saver = _Saver();
    await t.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => fixedNow),
        fileSaverProvider.overrideWithValue(saver),
      ],
      child: const FinanceHubApp(),
    ));
    final h = Harness(t, db);
    await h.settle();

    await t.tap(find.text('Análises'));
    await h.settle();
    await t.tap(find.byKey(const Key('export-open')));
    await h.settle();
    expect(find.text('Exportar dados'), findsOneWidget);
    expect(find.textContaining('em breve'), findsNWidgets(3)); // JSON, Excel, PDF

    final sheetScroll = find.descendant(of: find.byType(ExportSheet), matching: find.byType(Scrollable)).first;
    Future<void> reveal(String key) => t.scrollUntilVisible(find.byKey(Key(key)), 150, scrollable: sheetScroll);

    // desmarcar os dois conjuntos padrão: botão fica desabilitado
    await t.tap(find.byKey(const Key('export-dataset-bills')));
    await t.tap(find.byKey(const Key('export-dataset-payments')));
    await t.pump();
    await reveal('export-submit');
    expect(t.widget<FilledButton>(find.byKey(const Key('export-submit'))).onPressed, isNull);

    // um único conjunto → CSV simples
    await reveal('export-dataset-bills');
    await t.tap(find.byKey(const Key('export-dataset-bills')));
    await t.pump();
    await reveal('export-submit');
    await t.tap(find.byKey(const Key('export-submit')));
    await h.settle();
    expect(saver.saved, ['contas_2026-10-10.csv']);
    expect(find.text('Exportar dados'), findsNothing); // fechou ao salvar
    await h.finish();
  });
}
