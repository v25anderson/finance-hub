import '../../core/dates.dart';
import '../../domain/export/export_data.dart';
import 'repo_base.dart';

/// Leitura completa dos dados para exportação (uma passada por tabela).
class ExportRepository extends RepoBase {
  ExportRepository(super.db);

  Future<ExportData> load({required DateTime exportedAt, required bool includeDeleted}) async {
    final cats = await db.select(db.categories).get();
    final txs = await db.select(db.transactions).get();
    final pays = await db.select(db.payments).get();
    final rules = await db.select(db.recurringTransactions).get();
    final incomes = await db.select(db.incomes).get();
    final invs = await db.select(db.investments).get();
    final planning = await db.select(db.plannings).get();
    final configs = await db.select(db.monthConfigurations).get();

    bool keep(DateTime? deletedAt) => includeDeleted || deletedAt == null;
    final catNames = {for (final c in cats) c.id: c.name};
    final billNames = {for (final t in txs) t.id: t.name};

    final paidByBill = <String, int>{};
    for (final p in pays) {
      if (p.deletedAt == null) paidByBill[p.transactionId] = (paidByBill[p.transactionId] ?? 0) + p.amountCents;
    }

    return ExportData(
      exportedAt: exportedAt,
      includeDeleted: includeDeleted,
      categories: [
        for (final c in cats)
          if (keep(c.deletedAt))
            ExportCategory(id: c.id, name: c.name, colorHex: _hex(c.color), isDefault: c.isDefault, sortOrder: c.sortOrder),
      ],
      bills: [
        for (final t in txs)
          if (keep(t.deletedAt))
            ExportBill(
              id: t.id,
              name: t.name,
              categoryId: t.categoryId,
              categoryName: catNames[t.categoryId] ?? '',
              expenseType: t.expenseType,
              dueDate: parseIsoDate(t.dueDate),
              plannedCents: t.plannedAmountCents,
              paidCents: paidByBill[t.id] ?? 0,
              favorite: t.favorite,
              note: t.note,
              createdAt: t.createdAt,
              updatedAt: t.updatedAt,
              canceledAt: t.canceledAt,
              recurringId: t.recurringId,
              occurrenceDate: t.occurrenceDate == null ? null : parseIsoDate(t.occurrenceDate!),
              deletedAt: t.deletedAt,
            ),
      ],
      payments: [
        for (final p in pays)
          if (keep(p.deletedAt))
            ExportPayment(
              id: p.id,
              billId: p.transactionId,
              billName: billNames[p.transactionId] ?? '',
              amountCents: p.amountCents,
              paidAt: p.paidAt,
              note: p.note,
              createdAt: p.createdAt,
              deletedAt: p.deletedAt,
            ),
      ],
      recurrences: [
        for (final r in rules)
          if (keep(r.deletedAt))
            ExportRecurrence(
              id: r.id,
              name: r.name,
              categoryId: r.categoryId,
              categoryName: catNames[r.categoryId] ?? '',
              expenseType: r.expenseType,
              frequency: r.frequency,
              interval: r.intervalCount,
              start: parseIsoDate(r.startDate),
              end: r.endDate == null ? null : parseIsoDate(r.endDate!),
              baseCents: r.baseAmountCents,
              favorite: r.favorite,
              deletedAt: r.deletedAt,
            ),
      ],
      incomes: [
        for (final i in incomes)
          if (keep(i.deletedAt))
            ExportIncome(id: i.id, yearMonth: i.yearMonth, kind: i.kind, amountCents: i.amountCents, description: i.description, received: i.received, deletedAt: i.deletedAt),
      ],
      investments: [
        for (final i in invs)
          if (keep(i.deletedAt))
            ExportInvestment(id: i.id, yearMonth: i.yearMonth, plannedCents: i.plannedCents, realizedCents: i.realizedCents, description: i.description, deletedAt: i.deletedAt),
      ],
      planning: [
        for (final p in planning)
          ExportPlanningRow(
            scope: 'padrao',
            salaryCents: p.defaultSalaryCents,
            extraIncomeCents: p.defaultExtraIncomeCents,
            savingsGoalCents: p.defaultSavingsGoalCents,
            investmentCents: p.defaultInvestmentCents,
          ),
        for (final m in configs)
          if (m.deletedAt == null)
            ExportPlanningRow(
              scope: m.yearMonth,
              salaryCents: m.salaryCents,
              extraIncomeCents: m.extraIncomeCents,
              savingsGoalCents: m.savingsGoalCents,
              investmentCents: m.investmentCents,
            ),
      ],
    );
  }

  static String _hex(int argb) => '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
