import '../../../core/money.dart';
import '../../../domain/value_range.dart';

/// `R$ 200,00 a R$ 300,00`.
String formatRange(ValueRange r) => '${formatCents(r.minCents)} a ${formatCents(r.maxCents)}';

/// Onde o total pago cai na faixa. Só descreve; não julga.
String rangePositionText(RangePosition p) => switch (p) {
      RangePosition.below => 'O total pago está abaixo da faixa informada.',
      RangePosition.within => 'O total pago está dentro da faixa informada.',
      RangePosition.above => 'O total pago está acima da faixa informada.',
    };
