import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import 'animated_value.dart';

enum MoneySize { hero, display, number }

/// Exibe centavos formatados em BRL com algarismos tabulares. Números grandes contam até o valor.
class MoneyText extends StatelessWidget {
  const MoneyText(this.cents, {super.key, this.size = MoneySize.number, this.tone, this.compact = false, this.color});
  final int cents;
  final MoneySize size;
  final Tone? tone;
  final bool compact;

  /// Cor explícita (ex.: branco sobre o cabeçalho de destaque). Tem prioridade sobre [tone].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final col = color ?? (tone == null ? c.textPrimary : c.tone(tone!));
    final style = switch (size) {
      MoneySize.hero => AppText.hero(col),
      MoneySize.display => AppText.display(col),
      MoneySize.number => AppText.number(col),
    };
    if (size == MoneySize.number) return Text(compact ? formatCentsCompact(cents) : formatCents(cents), style: style);
    return AnimatedMoney(cents, style: style, compact: compact);
  }
}
