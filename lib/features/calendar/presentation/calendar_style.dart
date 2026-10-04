import 'package:flutter/material.dart';

import '../../../design_system/tokens/colors.dart';
import '../../../domain/calendar.dart';

/// Aparência de cada tom do calendário: cor semântica + ícone + rótulo (cor nunca sozinha).
class CalendarToneStyle {
  const CalendarToneStyle(this.tone, this.icon, this.label);
  final Tone tone;
  final IconData? icon;
  final String label;
}

CalendarToneStyle styleForCalendarTone(CalendarTone t) => switch (t) {
      CalendarTone.paid => const CalendarToneStyle(Tone.success, Icons.check_circle_outline, 'Pago'),
      CalendarTone.overdue => const CalendarToneStyle(Tone.danger, Icons.error_outline, 'Vencida'),
      CalendarTone.soon => const CalendarToneStyle(Tone.warning, Icons.schedule, 'Vence em até 7 dias'),
      CalendarTone.future => const CalendarToneStyle(Tone.neutral, null, 'Futuro'),
    };
