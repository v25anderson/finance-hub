import 'dart:io';

import 'package:drift/native.dart';
import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/category_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dados e deviceId persistem após fechar e reabrir o arquivo; seed não duplica', () async {
    final dir = await Directory.systemTemp.createTemp('fh_db');
    final file = File('${dir.path}/finance.sqlite');
    addTearDown(() => dir.delete(recursive: true));

    var db = AppDatabase(NativeDatabase(file));
    final device = await db.currentDeviceId();
    final txId = await TransactionRepository(db).create(
      name: 'Aluguel',
      plannedAmountCents: 180000,
      dueDate: DateTime(2026, 10, 15),
      categoryId: 'cat-moradia',
    );
    await db.close();

    db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    expect(await db.currentDeviceId(), device);
    expect((await CategoryRepository(db).getAll()).length, 11);
    final tx = await TransactionRepository(db).getById(txId);
    expect(tx?.name, 'Aluguel');
    expect(tx?.plannedAmountCents, 180000);
  });
}
