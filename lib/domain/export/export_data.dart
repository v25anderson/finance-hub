import '../enums.dart';

/// Conjuntos de dados que podem ser exportados (um arquivo cada).
enum ExportDataset {
  bills('contas', 'Contas', 'Uma linha por conta, com valores, status e categoria'),
  payments('pagamentos', 'Pagamentos', 'Histórico de pagamentos de cada conta'),
  categories('categorias', 'Categorias', 'Categorias padrão e personalizadas'),
  recurrences('recorrencias', 'Recorrências', 'Regras de contas que se repetem'),
  incomes('rendas', 'Rendas', 'Rendas lançadas mês a mês'),
  investments('investimentos', 'Investimentos', 'Investimentos planejados e realizados'),
  planning('planejamento', 'Planejamento', 'Valores padrão e personalizados por mês');

  const ExportDataset(this.fileBase, this.label, this.description);

  /// Nome do arquivo, sem extensão.
  final String fileBase;
  final String label;
  final String description;
}

class ExportCategory {
  const ExportCategory({required this.id, required this.name, required this.colorHex, required this.isDefault, required this.sortOrder});
  final String id, name, colorHex;
  final bool isDefault;
  final int sortOrder;
}

class ExportBill {
  const ExportBill({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.expenseType,
    required this.dueDate,
    required this.plannedCents,
    required this.paidCents,
    required this.favorite,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    this.canceledAt,
    this.recurringId,
    this.occurrenceDate,
    this.deletedAt,
    this.minCents,
    this.maxCents,
  });
  final String id, name, categoryId, categoryName, note;
  final ExpenseType expenseType;
  final DateTime dueDate;
  final int plannedCents, paidCents;
  final bool favorite;
  final DateTime createdAt, updatedAt;
  final DateTime? canceledAt, occurrenceDate, deletedAt;
  final String? recurringId;

  /// Faixa de valor informada (gasto variável); nulas = sem faixa.
  final int? minCents, maxCents;
}

class ExportPayment {
  const ExportPayment({required this.id, required this.billId, required this.billName, required this.amountCents, required this.paidAt, required this.note, required this.createdAt, this.deletedAt});
  final String id, billId, billName, note;
  final int amountCents;
  final DateTime paidAt, createdAt;
  final DateTime? deletedAt;
}

class ExportRecurrence {
  const ExportRecurrence({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.expenseType,
    required this.frequency,
    required this.interval,
    required this.start,
    required this.baseCents,
    required this.favorite,
    this.end,
    this.deletedAt,
    this.minCents,
    this.maxCents,
  });
  final String id, name, categoryId, categoryName;
  final ExpenseType expenseType;
  final Frequency frequency;
  final int interval, baseCents;
  final DateTime start;
  final DateTime? end, deletedAt;
  final int? minCents, maxCents;
  final bool favorite;
}

class ExportIncome {
  const ExportIncome({required this.id, required this.yearMonth, required this.kind, required this.amountCents, required this.description, required this.received, this.deletedAt});
  final String id, yearMonth, description;
  final IncomeKind kind;
  final int amountCents;
  final bool received;
  final DateTime? deletedAt;
}

class ExportInvestment {
  const ExportInvestment({required this.id, required this.yearMonth, required this.plannedCents, required this.realizedCents, required this.description, this.deletedAt});
  final String id, yearMonth, description;
  final int plannedCents, realizedCents;
  final DateTime? deletedAt;
}

/// Uma linha do planejamento: `scope` é `padrao` ou o mês (`yyyy-MM`). Campo nulo = herda o padrão.
class ExportPlanningRow {
  const ExportPlanningRow({required this.scope, this.salaryCents, this.extraIncomeCents, this.savingsGoalCents, this.investmentCents});
  final String scope;
  final int? salaryCents, extraIncomeCents, savingsGoalCents, investmentCents;
}

/// Tudo que pode ser exportado, já lido do banco.
class ExportData {
  const ExportData({
    required this.exportedAt,
    required this.includeDeleted,
    this.categories = const [],
    this.bills = const [],
    this.payments = const [],
    this.recurrences = const [],
    this.incomes = const [],
    this.investments = const [],
    this.planning = const [],
  });
  final DateTime exportedAt;
  final bool includeDeleted;
  final List<ExportCategory> categories;
  final List<ExportBill> bills;
  final List<ExportPayment> payments;
  final List<ExportRecurrence> recurrences;
  final List<ExportIncome> incomes;
  final List<ExportInvestment> investments;
  final List<ExportPlanningRow> planning;
}
