/// Separador de campos. Excel em português costuma exigir ponto e vírgula; Google Sheets e Python usam vírgula.
enum CsvDelimiter {
  comma(',', '.'),
  semicolon(';', ',');

  const CsvDelimiter(this.char, this.decimalSeparator);

  /// Caractere que separa os campos.
  final String char;

  /// Separador decimal usado junto: vírgula como separador → ponto decimal; ponto e vírgula → vírgula decimal (pt-BR).
  final String decimalSeparator;
}

/// Valor em reais a partir de centavos inteiros (nunca `double`): `1234.56` ou `1234,56`, sem milhar.
class CsvMoney {
  const CsvMoney(this.cents);
  final int cents;
}

/// Número decimal (ex.: percentual de 0 a 100) com [digits] casas.
class CsvDecimal {
  const CsvDecimal(this.value, {this.digits = 2});
  final double value;
  final int digits;
}

/// Formata centavos como reais, com [decimal] como separador e sem separador de milhar.
String formatCsvMoney(int cents, String decimal) {
  final neg = cents < 0;
  final abs = cents.abs();
  return '${neg ? '-' : ''}${abs ~/ 100}$decimal${(abs % 100).toString().padLeft(2, '0')}';
}

/// Neutraliza "injeção de fórmula": planilhas executam células de texto que começam com `= + - @`
/// (ou tab/retorno). Um apóstrofo à frente mantém o conteúdo como texto.
String neutralizeFormula(String s) {
  if (s.isEmpty) return s;
  const risky = ['=', '+', '-', '@', '\t', '\r'];
  return risky.contains(s[0]) ? "'$s" : s;
}

String _render(Object? v, CsvDelimiter d) {
  if (v == null) return '';
  return switch (v) {
    CsvMoney m => formatCsvMoney(m.cents, d.decimalSeparator),
    CsvDecimal x => x.value.toStringAsFixed(x.digits).replaceAll('.', d.decimalSeparator),
    bool b => b ? 'true' : 'false',
    int i => '$i',
    DateTime t => t.toUtc().toIso8601String(),
    String s => neutralizeFormula(s),
    _ => neutralizeFormula(v.toString()),
  };
}

/// Escapa um campo (RFC 4180): aspas quando há separador, aspas, quebra de linha; aspas internas são dobradas.
String csvEscape(String s, CsvDelimiter d) {
  final needsQuotes = s.contains(d.char) || s.contains('"') || s.contains('\n') || s.contains('\r');
  return needsQuotes ? '"${s.replaceAll('"', '""')}"' : s;
}

/// Monta um CSV completo: BOM UTF-8 (Excel reconhece os acentos), cabeçalho e linhas com CRLF.
/// Valores aceitos: `null`, `String`, `int`, `bool`, `DateTime` (UTC, ISO 8601), [CsvMoney] e [CsvDecimal].
String buildCsv(List<String> header, List<List<Object?>> rows, CsvDelimiter d) {
  final b = StringBuffer('﻿');
  b.write('${header.map((h) => csvEscape(h, d)).join(d.char)}\r\n');
  for (final row in rows) {
    assert(row.length == header.length, 'linha com ${row.length} colunas; cabeçalho tem ${header.length}');
    b.write('${row.map((v) => csvEscape(_render(v, d), d)).join(d.char)}\r\n');
  }
  return b.toString();
}
