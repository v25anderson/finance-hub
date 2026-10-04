import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/category_repository.dart';
import 'package:finance_hub/data/repositories/repo_base.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_db.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository repo;
  setUp(() {
    db = memoryDb();
    repo = CategoryRepository(db);
  });
  tearDown(() => db.close());

  test('cria categoria personalizada ao final da ordem', () async {
    final id = await repo.create(name: '  Pets ', color: 0xFF112233);
    final all = await repo.getAll();
    expect(all.length, 12);
    expect(all.last.id, id);
    expect(all.last.name, 'Pets');
    expect(all.last.isDefault, isFalse);
  });

  test('nome vazio é rejeitado', () {
    expect(() => repo.create(name: '  ', color: 1), throwsA(isA<ValidationError>()));
  });

  test('update incrementa version e atualiza updatedAt', () async {
    var clock = DateTime.utc(2026, 1, 1);
    final d = memoryDb(clock: () => clock);
    addTearDown(d.close);
    final r = CategoryRepository(d);
    final id = await r.create(name: 'Pets', color: 1);
    clock = DateTime.utc(2026, 1, 2);
    await r.update(id, name: 'Animais');
    final row = (await r.getAll()).firstWhere((c) => c.id == id);
    expect(row.name, 'Animais');
    expect(row.version, 2);
    expect(row.updatedAt, DateTime.utc(2026, 1, 2));
    expect(row.createdAt, DateTime.utc(2026, 1, 1));
  });

  test('categoria padrão não pode ser excluída; personalizada vira soft delete', () async {
    expect(() => repo.softDelete('cat-moradia'), throwsA(isA<ValidationError>()));
    final id = await repo.create(name: 'Pets', color: 1);
    await repo.softDelete(id);
    expect((await repo.getAll()).any((c) => c.id == id), isFalse);
    final raw = await (db.select(db.categories)..where((c) => c.id.equals(id))).getSingle();
    expect(raw.deletedAt, isNotNull); // registro continua no banco
  });

  test('excluir categoria inexistente lança NotFoundError', () {
    expect(() => repo.softDelete('nada'), throwsA(isA<NotFoundError>()));
  });
}
