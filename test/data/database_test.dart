import 'package:finance_hub/data/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  test('seed cria 11 categorias padrão, Planning e SyncMetadata com deviceId', () async {
    final cats = await db.select(db.categories).get();
    expect(cats.length, 11);
    expect(cats.every((c) => c.isDefault), isTrue);
    expect(cats.map((c) => c.name), containsAll(['Moradia', 'Assinaturas', 'Outros']));
    expect((await db.select(db.plannings).get()).single.id, planningId);
    expect(await db.currentDeviceId(), isNotEmpty);
  });

  test('foreign keys são aplicadas', () async {
    final t = DateTime.utc(2026, 1, 1);
    expect(
      () => db.into(db.payments).insert(PaymentsCompanion.insert(
            id: 'p1',
            createdAt: t,
            updatedAt: t,
            transactionId: 'inexistente',
            amountCents: 100,
            paidAt: t,
          )),
      throwsA(predicate((e) => e.toString().toLowerCase().contains('foreign key'))),
    );
  });

  test('datas são gravadas como texto UTC', () async {
    final row = (await db.select(db.categories).get()).first;
    expect(row.createdAt.isUtc, isTrue);
  });
}
