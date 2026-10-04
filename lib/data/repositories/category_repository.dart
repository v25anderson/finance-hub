import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'repo_base.dart';

class CategoryRepository extends RepoBase {
  CategoryRepository(super.db);

  Stream<List<CategoryRow>> watchAll() => (db.select(db.categories)
        ..where((c) => c.deletedAt.isNull())
        ..orderBy([(c) => OrderingTerm.asc(c.sortOrder), (c) => OrderingTerm.asc(c.name)]))
      .watch();

  Future<List<CategoryRow>> getAll() => watchAll().first;

  Future<String> create({required String name, required int color, String icon = 'category'}) async {
    if (name.trim().isEmpty) throw ValidationError('Nome da categoria é obrigatório');
    final id = newId();
    final t = now();
    final last = await (db.select(db.categories)
          ..orderBy([(c) => OrderingTerm.desc(c.sortOrder)])
          ..limit(1))
        .getSingleOrNull();
    await db.into(db.categories).insert(CategoriesCompanion.insert(
          id: id,
          createdAt: t,
          updatedAt: t,
          deviceId: Value(await db.currentDeviceId()),
          name: name.trim(),
          color: color,
          icon: icon,
          sortOrder: Value((last?.sortOrder ?? 0) + 1),
        ));
    return id;
  }

  Future<void> update(String id, {String? name, int? color, String? icon}) async {
    final row = await (db.select(db.categories)..where((c) => c.id.equals(id) & c.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw NotFoundError('category', id);
    if (name != null && name.trim().isEmpty) throw ValidationError('Nome da categoria é obrigatório');
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(
      name: name == null ? const Value.absent() : Value(name.trim()),
      color: color == null ? const Value.absent() : Value(color),
      icon: icon == null ? const Value.absent() : Value(icon),
      updatedAt: Value(now()),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }

  /// Soft delete. Lançamentos existentes mantêm a referência (histórico preservado).
  /// Categorias padrão não podem ser excluídas.
  Future<void> softDelete(String id) async {
    final row = await (db.select(db.categories)..where((c) => c.id.equals(id) & c.deletedAt.isNull())).getSingleOrNull();
    if (row == null) throw NotFoundError('category', id);
    if (row.isDefault) throw ValidationError('Categorias padrão não podem ser excluídas');
    final t = now();
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(CategoriesCompanion(
      deletedAt: Value(t),
      updatedAt: Value(t),
      version: Value(row.version + 1),
      deviceId: Value(await db.currentDeviceId()),
    ));
  }
}
