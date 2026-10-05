import 'package:drift/drift.dart';

import '../../domain/backup/snapshot.dart';
import '../db/app_database.dart';
import '../repositories/repo_base.dart';

/// Gera e restaura snapshots completos do banco local.
class BackupRepository extends RepoBase {
  BackupRepository(super.db);

  Future<BackupSnapshot> createSnapshot() async {
    final deviceId = await db.currentDeviceId();
    final tables = <String, List<Map<String, Object?>>>{};
    await db.transaction(() async {
      tables['categories'] = [for (final r in await db.select(db.categories).get()) r.toJson()];
      tables['recurring_transactions'] = [for (final r in await db.select(db.recurringTransactions).get()) r.toJson()];
      tables['transactions'] = [for (final r in await db.select(db.transactions).get()) r.toJson()];
      tables['payments'] = [for (final r in await db.select(db.payments).get()) r.toJson()];
      tables['attachments'] = [for (final r in await db.select(db.attachments).get()) r.toJson()];
      tables['incomes'] = [for (final r in await db.select(db.incomes).get()) r.toJson()];
      tables['investments'] = [for (final r in await db.select(db.investments).get()) r.toJson()];
      tables['plannings'] = [for (final r in await db.select(db.plannings).get()) r.toJson()];
      tables['planning_defaults_versions'] = [for (final r in await db.select(db.planningDefaultsVersions).get()) r.toJson()];
      tables['month_configurations'] = [for (final r in await db.select(db.monthConfigurations).get()) r.toJson()];
    });
    return BackupSnapshot(createdAt: now(), deviceId: deviceId, schemaVersion: db.schemaVersion, tables: tables);
  }

  /// Substitui TODOS os dados locais pelos do snapshot, numa única transação: ou aplica tudo, ou nada.
  /// Metadados de sincronização do aparelho são preservados. Quem chama deve ter confirmado com o usuário
  /// e guardado uma cópia de segurança antes.
  Future<void> restore(BackupSnapshot s) async {
    if (s.schemaVersion > db.schemaVersion) throw BackupFormatError('Backup criado por uma versão mais nova do app.');
    await db.transaction(() async {
      // exclusão na ordem inversa das chaves estrangeiras
      await db.delete(db.monthConfigurations).go();
      await db.delete(db.planningDefaultsVersions).go();
      await db.delete(db.plannings).go();
      await db.delete(db.investments).go();
      await db.delete(db.incomes).go();
      await db.delete(db.attachments).go();
      await db.delete(db.payments).go();
      await db.delete(db.transactions).go();
      await db.delete(db.recurringTransactions).go();
      await db.delete(db.categories).go();

      Future<void> load<T extends Table, D>(TableInfo<T, D> table, String key, D Function(Map<String, dynamic>) from) async {
        final rows = s.tables[key] ?? const [];
        await db.batch((b) {
          b.insertAll(table, [for (final r in rows) (from(r) as Insertable<D>)]);
        });
      }

      await load(db.categories, 'categories', CategoryRow.fromJson);
      await load(db.recurringTransactions, 'recurring_transactions', RecurringRow.fromJson);
      await load(db.transactions, 'transactions', TransactionRow.fromJson);
      await load(db.payments, 'payments', PaymentRow.fromJson);
      await load(db.attachments, 'attachments', AttachmentRow.fromJson);
      await load(db.incomes, 'incomes', IncomeRow.fromJson);
      await load(db.investments, 'investments', InvestmentRow.fromJson);
      await load(db.plannings, 'plannings', PlanningRow.fromJson);
      await load(db.planningDefaultsVersions, 'planning_defaults_versions', DefaultsVersionRow.fromJson);
      await db.seedDefaultsFromLegacy(); // backup antigo (sem versões): o padrão único vira a primeira versão
      await load(db.monthConfigurations, 'month_configurations', MonthConfigRow.fromJson);
      // os dados mudaram por inteiro: o histórico de sincronização deixou de valer
      await db.delete(db.syncBase).go();
      await db.delete(db.syncConflicts).go();
      await (db.update(db.syncMetadata)).write(const SyncMetadataCompanion(remoteCursor: Value(null), lastSyncAt: Value(null)));
      await db.ensureSeed(); // garante categorias padrão e singletons mesmo se o backup não os trouxer
    });
  }
}
