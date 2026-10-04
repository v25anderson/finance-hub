import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

enum MoneySize { display, number }

/// Exibe centavos formatados em BRL com algarismos tabulares.
class MoneyText extends StatelessWidget {
  const MoneyText(this.cents, {super.key, this.size = MoneySize.number, this.tone, this.compact = false});
  final int cents;
  final MoneySize size;
  final Tone? tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = tone == null ? c.textPrimary : c.tone(tone!);
    final style = size == MoneySize.display ? AppText.display(color) : AppText.number(color);
    return Text(compact ? formatCentsCompact(cents) : formatCents(cents), style: style);
  }
}
