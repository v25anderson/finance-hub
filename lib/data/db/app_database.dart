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
  SyncBase,
  PlanningDefaultsVersions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e, {DateTime Function()? clock}) : clock = clock ?? DateTime.now;

  /// Relógio injetável (testes). Sempre gravado em UTC.
  final DateTime Function() clock;

  DateTime now() => clock().toUtc();

  @override
  int get schemaVersion => 5;

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
          if (from < 3) {
            await m.createTable(syncBase);
          }
          if (from < 4) {
            // v4: faixa de valor para gastos variáveis (colunas novas, nulas: nada muda nos dados existentes).
            await m.addColumn(transactions, transactions.plannedMinCents);
            await m.addColumn(transactions, transactions.plannedMaxCents);
            await m.addColumn(recurringTransactions, recurringTransactions.baseMinCents);
            await m.addColumn(recurringTransactions, recurringTransactions.baseMaxCents);
          }
          if (from < 5) {
            // v5: padrões com vigência. O padrão único antigo vira a primeira versão, valendo a partir do mês do primeiro dado
            // (antes disso nada foi registrado, então não há renda "padrão" a atribuir).
            await m.createTable(planningDefaultsVersions);
            await seedDefaultsFromLegacy();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await _seed();
        },
      );

  /// Id da versão de padrões de um mês (determinístico: igual em todos os aparelhos).
  static String defaultsVersionId(String yearMonth) => 'defaults-$yearMonth';

  /// Cria a primeira versão de padrões a partir do padrão único antigo (`plannings`), se ele tiver algum valor e ainda
  /// não houver versões. Vale a partir do mês do primeiro dado registrado (conta, renda, investimento ou personalização);
  /// sem nenhum dado, a partir do mês atual. Usado na migração v5 e ao restaurar um backup antigo.
  Future<void> seedDefaultsFromLegacy() async {
    if ((await select(planningDefaultsVersions).get()).isNotEmpty) return;
    final legacy = await (select(plannings)..where((p) => p.id.equals(planningId))).getSingleOrNull();
    if (legacy == null) return;
    final values = [legacy.defaultSalaryCents, legacy.defaultExtraIncomeCents, legacy.defaultSavingsGoalCents, legacy.defaultInvestmentCents];
    if (values.every((v) => v == 0)) return;
    final firstMonth = (await customSelect('''
      SELECT MIN(m) AS m FROM (
        SELECT substr(due_date, 1, 7) AS m FROM transactions WHERE deleted_at IS NULL
        UNION ALL SELECT year_month FROM incomes WHERE deleted_at IS NULL
        UNION ALL SELECT year_month FROM investments WHERE deleted_at IS NULL
        UNION ALL SELECT year_month FROM month_configurations WHERE deleted_at IS NULL
      )''').getSingle()).read<String?>('m');
    final n = now();
    final ym = firstMonth ?? '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}';
    await into(planningDefaultsVersions).insert(PlanningDefaultsVersionsCompanion.insert(
      id: defaultsVersionId(ym),
      createdAt: n,
      updatedAt: n,
      effectiveFrom: ym,
      salaryCents: Value(values[0]),
      extraIncomeCents: Value(values[1]),
      savingsGoalCents: Value(values[2]),
      investmentCents: Value(values[3]),
    ));
  }

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
