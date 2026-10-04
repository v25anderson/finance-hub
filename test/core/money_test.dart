import 'package:finance_hub/core/money.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('formata centavos em BRL', () {
    expect(formatCents(2490), 'R\$ 24,90');
    expect(formatCents(524000), 'R\$ 5.240,00');
    expect(formatCents(0), 'R\$ 0,00');
    expect(formatCentsCompact(524000), 'R\$ 5.240');
  });

  test('formata valor negativo', () {
    expect(formatCents(-1050), contains('10,50'));
  });

  group('parseCents', () {
    test('entradas válidas', () {
      expect(parseCents('24,90'), 2490);
      expect(parseCents('1.234,56'), 123456);
      expect(parseCents('R\$ 10'), 1000);
      expect(parseCents('1.000'), 100000);
      expect(parseCents('0,1'), 10);
    });
    test('entradas inválidas', () {
      expect(parseCents(''), isNull);
      expect(parseCents('abc'), isNull);
    });
  });
}
