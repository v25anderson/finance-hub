import 'package:finance_hub/features/analytics/presentation/charts/chart_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('niceTicks', () {
    test('passos redondos a partir de zero, cobrindo o máximo', () {
      expect(niceTicks(1000, target: 4), [0, 250, 500, 750, 1000]);
      expect(niceTicks(980, target: 4), [0, 250, 500, 750, 1000]);
      expect(niceTicks(7, target: 4), [0, 2, 4, 6, 8]);
      expect(niceTicks(1, target: 4), [0, 0.25, 0.5, 0.75, 1]);
    });
    test('sempre começa em 0 e termina em ou além do máximo', () {
      for (final m in <double>[0.3, 3, 42, 999, 12345, 5e6, 8.3e7]) {
        final t = niceTicks(m);
        expect(t.first, 0);
        expect(t.last, greaterThanOrEqualTo(m), reason: '$m');
        expect(t.length, lessThanOrEqualTo(13));
      }
    });
    test('máximo zero, negativo ou inválido devolve uma escala mínima', () {
      expect(niceTicks(0), [0, 1]);
      expect(niceTicks(-5), [0, 1]);
      expect(niceTicks(double.nan), [0, 1]);
    });
  });

  group('rótulos de eixo', () {
    test('dinheiro em centavos, compacto', () {
      expect(formatAxisMoney(0), '0');
      expect(formatAxisMoney(80000), '800');
      expect(formatAxisMoney(500000), '5 mil');
      expect(formatAxisMoney(250000), '2,5 mil');
      expect(formatAxisMoney(120000000), '1,2 mi');
      expect(formatAxisMoney(-100000), '-1 mil');
    });
    test('percentual', () {
      expect(formatAxisPercent(0), '0%');
      expect(formatAxisPercent(0.125), '12,5%');
      expect(formatAxisPercent(0.2), '20%');
      expect(formatAxisPercent(1.5), '150%');
    });
  });

  test('nearestSlotIndex prende nas pontas e acerta o meio', () {
    expect(nearestSlotIndex(0, left: 40, width: 300, count: 6), 0);
    expect(nearestSlotIndex(1000, left: 40, width: 300, count: 6), 5);
    expect(nearestSlotIndex(40 + 50 * 2 + 1, left: 40, width: 300, count: 6), 2);
    expect(nearestSlotIndex(123, left: 40, width: 300, count: 1), 0);
    expect(nearestSlotIndex(123, left: 40, width: 0, count: 6), 0);
  });
}
