import 'package:drift/drift.dart';

import '../../domain/enums.dart';

/// Colunas comuns a toda entidade (DATA_MODEL: "Campos comuns").
mixin BaseColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryRow')
class Categories extends Table with BaseColumns {
  TextColumn get name => text()();
  IntColumn get color => integer()();
  TextColumn get icon => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('RecurringRow')
class RecurringTransactions extends Table with BaseColumns {
  TextColumn get name => text()();
  IntColumn get baseAmountCents => integer()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get expenseType => textEnum<ExpenseType>()();
  TextColumn get frequency => textEnum<Frequency>()();
  IntColumn get intervalCount => integer().withDefault(const Constant(1))();
  IntColumn get dueDay => integer()();

  /// Faixa de valor informada (gasto variável), v4. Ambas nulas = sem faixa.
  IntColumn get baseMinCents => integer().nullable()();
  IntColumn get baseMaxCents => integer().nullable()();

  /// Datas puras em ISO `yyyy-MM-dd`.
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
}

@DataClassName('TransactionRow')
@TableIndex(name: 'idx_transactions_due', columns: {#dueDate})
@TableIndex(name: 'idx_transactions_category', columns: {#categoryId})
/// Uma ocorrência por regra e data: torna a geração idempotente (v2). `NULL` em `recurring_id` é livre.
@TableIndex(name: 'uq_transactions_occurrence', columns: {#recurringId, #occurrenceDate}, unique: true)
class Transactions extends Table with BaseColumns {
  TextColumn get name => text()();
  IntColumn get plannedAmountCents => integer()();

  /// Data pura ISO `yyyy-MM-dd` (sem hora, sem fuso).
  TextColumn get dueDate => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get expenseType => textEnum<ExpenseType>()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get canceledAt => dateTime().nullable()();
  TextColumn get recurringId => text().nullable().references(RecurringTransactions, #id)();
  TextColumn get occurrenceDate => text().nullable()();

  /// Ocorrência editada manualmente: não é regenerada pela regra.
  BoolColumn get overridden => boolean().withDefault(const Constant(false))();

  /// Faixa de valor informada (gasto variável), v4. Ambas nulas = sem faixa.
  IntColumn get plannedMinCents => integer().nullable()();
  IntColumn get plannedMaxCents => integer().nullable()();
}

@DataClassName('PaymentRow')
@TableIndex(name: 'idx_payments_transaction', columns: {#transactionId})
class Payments extends Table with BaseColumns {
  TextColumn get transactionId => text().references(Transactions, #id)();
  IntColumn get amountCents => integer()();
  DateTimeColumn get paidAt => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
}

@DataClassName('AttachmentRow')
@TableIndex(name: 'idx_attachments_owner', columns: {#ownerType, #ownerId})
class Attachments extends Table with BaseColumns {
  TextColumn get ownerType => textEnum<AttachmentOwner>()();
  TextColumn get ownerId => text()();
  TextColumn get localPath => text()();
  TextColumn get originalName => text()();
  TextColumn get mime => text()();
  TextColumn get hash => text().withDefault(const Constant(''))();
  TextColumn get driveFileId => text().nullable()();
  TextColumn get uploadStatus => textEnum<UploadStatus>().withDefault(const Constant('localOnly'))();
}

@DataClassName('IncomeRow')
@TableIndex(name: 'idx_incomes_month', columns: {#yearMonth})
class Incomes extends Table with BaseColumns {
  /// `yyyy-MM`.
  TextColumn get yearMonth => text()();
  TextColumn get kind => textEnum<IncomeKind>()();
  IntColumn get amountCents => integer()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get received => boolean().withDefault(const Constant(false))();
}

@DataClassName('InvestmentRow')
@TableIndex(name: 'idx_investments_month', columns: {#yearMonth})
class Investments extends Table with BaseColumns {
  TextColumn get yearMonth => text()();
  IntColumn get plannedCents => integer().withDefault(const Constant(0))();
  IntColumn get realizedCents => integer().withDefault(const Constant(0))();
  TextColumn get description => text().withDefault(const Constant(''))();
}

/// Singleton (id fixo `planning`).
@DataClassName('PlanningRow')
class Plannings extends Table with BaseColumns {
  IntColumn get defaultSalaryCents => integer().withDefault(const Constant(0))();
  IntColumn get defaultExtraIncomeCents => integer().withDefault(const Constant(0))();
  IntColumn get defaultSavingsGoalCents => integer().withDefault(const Constant(0))();
  IntColumn get defaultInvestmentCents => integer().withDefault(const Constant(0))();
}

/// Padrões de planejamento com vigência (v5): cada linha vale **a partir** de `effective_from` até a próxima.
/// Mudar o padrão cria/atualiza a linha do mês escolhido e não reescreve os meses anteriores.
/// Id determinístico (`defaults-AAAA-MM`): a mesma vigência criada em dois aparelhos é o mesmo registro.
/// A tabela `plannings` (singleton) ficou só como legado: serve de origem da migração e não é mais usada.
@DataClassName('DefaultsVersionRow')
class PlanningDefaultsVersions extends Table with BaseColumns {
  /// `yyyy-MM`.
  TextColumn get effectiveFrom => text()();
  IntColumn get salaryCents => integer().withDefault(const Constant(0))();
  IntColumn get extraIncomeCents => integer().withDefault(const Constant(0))();
  IntColumn get savingsGoalCents => integer().withDefault(const Constant(0))();
  IntColumn get investmentCents => integer().withDefault(const Constant(0))();
}

/// Override mensal; coluna nula = herda o padrão, zero = zero explícito.
@DataClassName('MonthConfigRow')
class MonthConfigurations extends Table with BaseColumns {
  TextColumn get yearMonth => text().unique()();
  IntColumn get salaryCents => integer().nullable()();
  IntColumn get extraIncomeCents => integer().nullable()();
  IntColumn get savingsGoalCents => integer().nullable()();
  IntColumn get investmentCents => integer().nullable()();
}

/// Singleton (id fixo `sync`).
@DataClassName('SyncMetaRow')
class SyncMetadata extends Table with BaseColumns {
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get remoteCursor => text().nullable()();
  TextColumn get state => textEnum<SyncState>().withDefault(const Constant('disconnected'))();
}

@DataClassName('SyncConflictRow')
class SyncConflicts extends Table with BaseColumns {
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  TextColumn get localJson => text()();
  TextColumn get remoteJson => text()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
}

/// Último estado sincronizado de cada registro (ancestral comum do merge de três vias, v3).
/// Um registro é "alterado localmente" quando difere desta cópia; sem cópia, nunca foi sincronizado.
@DataClassName('SyncBaseRow')
class SyncBase extends Table {
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {entity, recordId};
}
