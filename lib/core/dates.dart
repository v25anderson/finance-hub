/// Datas puras (vencimentos) são `yyyy-MM-dd`; meses são `yyyy-MM`. Sem hora, sem fuso.
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseIsoDate(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String yearMonthOf(DateTime d) => isoDate(d).substring(0, 7);

/// Intervalo `[início, fim)` em ISO de um mês `yyyy-MM`.
({String start, String endExclusive}) monthRange(String yearMonth) {
  final p = yearMonth.split('-');
  final y = int.parse(p[0]);
  final m = int.parse(p[1]);
  final next = DateTime(y, m + 1, 1);
  return (start: '$yearMonth-01', endExclusive: isoDate(next));
}

/// Último dia do mês (regra: vencimento dia 31 em mês curto vira o último dia).
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
