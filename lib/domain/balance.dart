import 'month_plan.dart';
import 'month_summary.dart';

/// "Quanto sobra": três saldos distintos (nunca misturados).
///
/// - [currentCents] **saldo atual**: renda − gastos já pagos − investimentos realizados.
/// - [afterBillsCents] **saldo após contas**: se todas as pendentes forem pagas.
/// - [projectedCents] **saldo projetado / após investimentos planejados**: também desconta o
///   restante da meta de investimento.
class BalanceBreakdown {
  const BalanceBreakdown({
    required this.incomeCents,
    required this.paidCents,
    required this.pendingCents,
    required this.investmentRealizedCents,
    required this.investmentProjectedCents,
  });

  final int incomeCents;

  /// Saída real de caixa com contas (inclui excedente pago).
  final int paidCents;
  final int pendingCents;
  final int investmentRealizedCents;
  final int investmentProjectedCents;

  int get currentCents => incomeCents - paidCents - investmentRealizedCents;
  int get afterBillsCents => incomeCents - paidCents - pendingCents - investmentRealizedCents;
  int get projectedCents => incomeCents - paidCents - pendingCents - investmentProjectedCents;
}

BalanceBreakdown computeBalance(MonthPlan plan, MonthSummary summary) => BalanceBreakdown(
      incomeCents: plan.totalIncomeCents,
      paidCents: summary.paidCashCents,
      pendingCents: summary.pendingCents,
      investmentRealizedCents: plan.investmentRealizedCents,
      investmentProjectedCents: plan.investmentProjectedCents,
    );
