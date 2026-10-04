import '../domain/alerts.dart';
import '../domain/balance.dart';
import '../domain/month_comparison.dart';
import '../domain/month_plan.dart';
import '../domain/month_summary.dart';

/// Tudo que o dashboard exibe para um mês, já calculado (a UI só apresenta).
class DashboardData {
  const DashboardData({
    required this.yearMonth,
    required this.summary,
    required this.previousSummary,
    required this.comparison,
    required this.plan,
    required this.balance,
    required this.alerts,
  });

  final String yearMonth;
  final MonthSummary summary;
  final MonthSummary previousSummary;
  final MonthComparison comparison;
  final MonthPlan plan;
  final BalanceBreakdown balance;
  final List<DueAlert> alerts;
}
