/// Onde um valor cai em relação a uma faixa.
enum RangePosition { below, within, above }

/// Faixa de valor informada para um gasto variável (ex.: energia entre R$ 200 e R$ 300). Em centavos.
/// É uma informação do usuário, não uma previsão do app: o valor esperado da conta continua sendo um número só.
class ValueRange {
  const ValueRange(this.minCents, this.maxCents);
  final int minCents;
  final int maxCents;

  /// Mínimo positivo e máximo não menor que o mínimo.
  bool get isValid => minCents > 0 && maxCents >= minCents;

  /// Ponto médio arredondado (sugestão de valor esperado).
  int get midpointCents => ((minCents + maxCents) / 2).round();

  bool contains(int cents) => cents >= minCents && cents <= maxCents;

  RangePosition position(int cents) => cents < minCents ? RangePosition.below : (cents > maxCents ? RangePosition.above : RangePosition.within);

  @override
  bool operator ==(Object other) => other is ValueRange && other.minCents == minCents && other.maxCents == maxCents;

  @override
  int get hashCode => Object.hash(minCents, maxCents);
}
