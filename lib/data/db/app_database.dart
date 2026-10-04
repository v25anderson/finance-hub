import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

const planningId = 'planning';
const syncMetaId = 'sync';

/// Categorias padrão com ids estáveis, para não duplicar entre dispositivos na sincronização.
const defaultCategories = <({String id, String name, int color, String icon})>[
  (id: 'cat-moradia', name: 'Moradia', color: 0xFF6A2FD0, icon: 'home'),
  (id: 'cat-alimentacao', name: 'Alimentação', color: 0xFFD97706, icon: 'restaurant'),
  (id: 'cat-transporte', name: 'Transporte', color: 0xFF2B6CB0, icon: 'directions_car'),
  (id: 'cat-assinaturas', name: 'Assinaturas', color: 0xFFDB2777, icon: 'subscriptions'),
  (id: 'cat-saude', name: 'Saúde', color: 0xFF138A52, icon: 'favorite'),
  (id: 'cat-educacao', name: 'Educação', color: 0xFF0E7490, icon: 'school'),
  (id: 'cat-lazer', name: 'Lazer', color: 0xFF9333EA, icon: 'sports_esports'),
  (id: 'cat-compras', name: 'Compras', color: 0xFFEA580C, icon: 'shopping_bag'),
  (id: 'cat-impostos', name: 'Impostos', color: 0xFF64748B, icon: 'account_balance'),
  (id: 'cat-investimentos', name: 'Investimentos', color: 0xFF16A34A, icon: 'trending_up'),
  (id: 'cat-outros', name: 'Outros', color: 0xFF78716C, icon: 'category'),
];

@DriftDatabase(tables: [
  Categories,
  RecurringTransactions,
  Transactions,
  Payments,
  Attachments,
  Incomes,
  Investments,
  Plannings,
  MonthConfigurations,
  SyncMetadata,
  SyncConflicts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e, {DateTime Function()? clock}) : clock = clock ?? DateTime.now;

  /// Relógio injetável (testes). Sempre gravado em UTC.
  final DateTime Function() clock;

  DateTime now() => clock().toUtc();

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: ocorrências de recorrência únicas por (regra, data).
            await customStatement('DROP INDEX IF EXISTS idx_transactions_recurring');
            // Duplicatas (se existirem) perdem o vínculo com a regra, mas nenhum dado é apagado.
            await customStatement('''
              UPDATE transactions SET recurring_id = NULL, occurrence_date = NULL
              WHERE recurring_id IS NOT NULL AND rowid NOT IN (
                SELECT MIN(rowid) FROM transactions WHERE recurring_id IS NOT NULL GROUP BY recurring_id, occurrence_date)''');
            await m.createIndex(uqTransactionsOccurrence);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await _seed();
        },
      );

  /// Reaplica o seed (usado após restaurar um backup incompleto).
  Future<void> ensureSeed() => _seed();

  /// Garante categorias padrão e os singletons Planning e SyncMetadata.
  Future<void> _seed() async {
    final t = now();
    await batch((b) {
      for (var i = 0; i < defaultCategories.length; i++) {
        final c = defaultCategories[i];
        b.insert(
          categories,
          CategoriesCompanion.insert(
            id: c.id,
            createdAt: t,
            updatedAt: t,
            name: c.name,
            color: c.color,
            icon: c.icon,
            isDefault: const Value(true),
            sortOrder: Value(i),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
      b.insert(plannings, PlanningsCompanion.insert(id: planningId, createdAt: t, updatedAt: t),
          mode: InsertMode.insertOrIgnore);
      b.insert(syncMetadata, SyncMetadataCompanion.insert(id: syncMetaId, createdAt: t, updatedAt: t),
          mode: InsertMode.insertOrIgnore);
    });
    final meta = await (select(syncMetadata)..where((m) => m.id.equals(syncMetaId))).getSingle();
    if (meta.deviceId.isEmpty) {
      await (update(syncMetadata)..where((m) => m.id.equals(syncMetaId)))
          .write(SyncMetadataCompanion(deviceId: Value(const Uuid().v4())));
    }
  }

  /// Identificador deste dispositivo (usado em `deviceId` de cada registro).
  Future<String> currentDeviceId() async =>
      (await (select(syncMetadata)..where((m) => m.id.equals(syncMetaId))).getSingle()).deviceId;
}
