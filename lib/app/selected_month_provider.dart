import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../data/providers.dart';

/// Mês exibido (compartilhado entre Visão geral, Contas e Calendário). Sempre o dia 1.
class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final t = ref.read(todayProvider);
    return DateTime(t.year, t.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);
  void next() => state = DateTime(state.year, state.month + 1);
  void set(int year, int month) => state = DateTime(year, month);
  void today() {
    final t = ref.read(todayProvider);
    state = DateTime(t.year, t.month);
  }
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(SelectedMonthNotifier.new);

/// `yyyy-MM` do mês selecionado.
final selectedYearMonthProvider = Provider<String>((ref) => yearMonthOf(ref.watch(selectedMonthProvider)));
