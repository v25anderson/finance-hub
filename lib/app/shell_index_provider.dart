import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aba ativa do shell (0 Visão geral, 1 Contas, 2 Calendário, 3 Planejamento, 4 Análises).
class ShellIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void select(int i) => state = i;
}

final shellIndexProvider = NotifierProvider<ShellIndexNotifier, int>(ShellIndexNotifier.new);

const billsTabIndex = 1;
