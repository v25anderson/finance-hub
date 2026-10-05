import 'package:finance_hub/data/db/app_database.dart';
import 'package:finance_hub/data/repositories/planning_repository.dart';
import 'package:finance_hub/data/repositories/transaction_repository.dart';
import 'package:finance_hub/domain/enums.dart';

/// Dados variados e nomes longos, para forçar os piores casos de layout.
Future<void> seedRich(AppDatabase db) async {
  final tx = TransactionRepository(db);
  final plan = PlanningRepository(db);
  await plan.updatePlanning(salaryCents: 850000, extraIncomeCents: 120000, investmentCents: 150000, savingsGoalCents: 200000);
  Future<void> b(String n, int c, int d, String cat, {int paid = 0, int month = 10}) async {
    final id = await tx.create(name: n, plannedAmountCents: c, dueDate: DateTime(2026, month, d), categoryId: cat, expenseType: ExpenseType.fixed);
    if (paid > 0) await tx.addPayment(transactionId: id, amountCents: paid, paidAt: DateTime(2026, month, d));
  }

  await b('Aluguel do apartamento de cima da praia', 180000, 5, 'cat-moradia', paid: 180000);
  await b('Internet fibra ótica ultra rápida residencial', 12990, 8, 'cat-assinaturas');
  await b('Cartão de crédito principal', 240000, 12, 'cat-compras', paid: 90000);
  await b('Mercado', 68000, 14, 'cat-alimentacao');
  await b('Plano de saúde familiar', 62000, 18, 'cat-saude');
  await b('Aluguel', 180000, 5, 'cat-moradia', paid: 180000, month: 9);
  await plan.addIncome(yearMonth: '2026-10', kind: IncomeKind.extra, amountCents: 30000);
}

