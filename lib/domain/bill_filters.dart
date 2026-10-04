import 'bill.dart';

/// Abas da tela de Contas.
///
/// - [pending]: ainda há valor a pagar e **não** está vencida (inclui parcialmente pagas no prazo).
/// - [paid]: totalmente paga.
/// - [overdue]: vencida (inclui parcialmente pagas vencidas).
/// - [all]: tudo, inclusive canceladas.
enum BillTab { pending, paid, overdue, all }

List<Bill> filterBills(
  List<Bill> bills,
  BillTab tab,
  DateTime today, {
  bool favoritesOnly = false,
}) {
  bool inTab(Bill b) => switch (tab) {
        BillTab.all => true,
        BillTab.paid => b.statusOn(today) == BillStatus.paid,
        BillTab.overdue => b.statusOn(today) == BillStatus.overdue,
        BillTab.pending => !b.isCanceled && b.remainingCents > 0 && !b.isOverdueOn(today),
      };
  final out = bills.where((b) => inTab(b) && (!favoritesOnly || b.favorite)).toList();
  out.sort((a, b) {
    final c = a.dueDate.compareTo(b.dueDate);
    return c != 0 ? c : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return out;
}
