import 'package:flutter/material.dart';

import '../../../design_system/tokens/colors.dart';
import '../../../domain/bill.dart';
import '../../../domain/calendar.dart' show soonDays;
import '../../../domain/enums.dart';

/// Aparência de cada estado. Cor sempre acompanhada de texto e ícone.
class StatusStyle {
  const StatusStyle(this.label, this.tone, this.icon);
  final String label;
  final Tone tone;
  final IconData icon;
}

StatusStyle styleFor(Bill bill, DateTime today) {
  final status = bill.statusOn(today);
  switch (status) {
    case BillStatus.paid:
      return const StatusStyle('Paga', Tone.success, Icons.check_circle_outline);
    case BillStatus.overdue:
      return const StatusStyle('Vencida', Tone.danger, Icons.error_outline);
    case BillStatus.partiallyPaid:
      return const StatusStyle('Parcialmente paga', Tone.info, Icons.timelapse);
    case BillStatus.canceled:
      return const StatusStyle('Cancelada', Tone.neutral, Icons.block);
    case BillStatus.pending:
      final days = dateOnly(bill.dueDate).difference(dateOnly(today)).inDays;
      return StatusStyle('Pendente', days <= soonDays ? Tone.warning : Tone.neutral, Icons.schedule);
    case BillStatus.planned:
      return const StatusStyle('Prevista', Tone.neutral, Icons.event_outlined);
  }
}

String expenseTypeLabel(ExpenseType type) => switch (type) {
      ExpenseType.fixed => 'Fixo',
      ExpenseType.variable => 'Variável',
      ExpenseType.oneOff => 'Pontual',
    };
