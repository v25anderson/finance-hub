import 'dart:convert';

import 'package:finance_hub/domain/enums.dart';
import 'package:finance_hub/domain/export/csv.dart';
import 'package:finance_hub/domain/export/csv_exporter.dart';
import 'package:finance_hub/domain/export/export_data.dart';
import 'package:finance_hub/domain/export/exporter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/csv_parser.dart';

final exportedAt = DateTime(2026, 10, 10, 12);

ExportBill bill(String id, String name, int planned, int paid, DateTime due,
        {String cat = 'Moradia', DateTime? canceled, String? recurring, DateTime? deleted, String note = '', ExpenseType type = ExpenseType.fixed}) =>
    ExportBill(
      id: id,
      name: name,
      categoryId: 'cat-1',
      categoryName: cat,
      expenseType: type,
      dueDate: due,
      plannedCents: planned,
      paidCents: paid,
      favorite: false,
      note: note,
      createdAt: DateTime.utc(2026, 1, 1, 9),
      updatedAt: DateTime.utc(2026, 1, 2, 9),
      canceledAt: canceled,
      recurringId: recurring,
      deletedAt: deleted,
    );

ExportOptions opts({Set<ExportDataset>? ds, CsvDelimiter d = CsvDelimiter.comma, bool deleted = false}) =>
    ExportOptions(datasets: ds ?? ExportDataset.values.toSet(), delimiter: d, includeDeleted: deleted);

List<List<String>> table(ExportFile f, {String d = ','}) => parseCsv(utf8.decode(f.bytes), delimiter: d);

void main() {
  group('csv: escape e formatação', () {
    test('valores em reais a partir de centavos inteiros', () {
      expect(formatCsvMoney(0, '.'), '0.00');
      expect(formatCsvMoney(5, '.'), '0.05');
      expect(formatCsvMoney(123456, '.'), '1234.56');
      expect(formatCsvMoney(123456, ','), '1234,56');
      expect(formatCsvMoney(-1050, '.'), '-10.50');
      expect(formatCsvMoney(100000000000, '.'), '1000000000.00'); // sem erro de ponto flutuante
    });

    test('aspas, separador e quebra de linha são escapados', () {
      const d = CsvDelimiter.comma;
      expect(csvEscape('simples', d), 'simples');
      expect(csvEscape('a,b', d), '"a,b"');
      expect(csvEscape('diz "oi"', d), '"diz ""oi"""');
      expect(csvEscape('linha1\nlinha2', d), '"linha1\nlinha2"');
      expect(csvEscape('a;b', d), 'a;b'); // ';' só é separador no modo ponto e vírgula
      expect(csvEscape('a;b', CsvDelimiter.semicolon), '"a;b"');
    });

    test('injeção de fórmula é neutralizada nos textos, mas números negativos não', () {
      expect(neutralizeFormula('=HYPERLINK("http://x")'), "'=HYPERLINK(\"http://x\")");
      expect(neutralizeFormula('+55 11'), "'+55 11");
      expect(neutralizeFormula('-cmd'), "'-cmd");
      expect(neutralizeFormula('@SUM(A1)'), "'@SUM(A1)");
      expect(neutralizeFormula('\tabc'), "'\tabc");
      expect(neutralizeFormula('Aluguel'), 'Aluguel');
      expect(neutralizeFormula(''), '');
      final csv = buildCsv(['nome', 'valor'], [
        ['=1+1', const CsvMoney(-500)],
      ], CsvDelimiter.comma);
      expect(parseCsv(csv)[1], ["'=1+1", '-5.00']);
    });

    test('BOM, cabeçalho, CRLF e tipos', () {
      final csv = buildCsv(['a', 'b', 'c', 'd', 'e', 'f'], [
        ['x', 3, true, null, DateTime.utc(2026, 10, 1, 9, 30), const CsvDecimal(12.345, digits: 2)],
      ], CsvDelimiter.comma);
      expect(csv.startsWith('﻿'), isTrue);
      expect(csv.endsWith('\r\n'), isTrue);
      expect(parseCsv(csv)[1], ['x', '3', 'true', '', '2026-10-01T09:30:00.000Z', '12.35']);
    });

    test('ponto e vírgula usa vírgula decimal', () {
      final csv = buildCsv(['v', 'p'], [
        [const CsvMoney(123456), const CsvDecimal(40.5)],
      ], CsvDelimiter.semicolon);
      expect(parseCsv(csv, delimiter: ';')[1], ['1234,56', '40,50']);
    });
  });

  group('exportador de contas', () {
    final data = ExportData(
      exportedAt: exportedAt,
      includeDeleted: false,
      bills: [
        bill('b2', 'Internet', 12000, 0, DateTime(2026, 10, 3)), // vencida
        bill('b1', 'Aluguel', 180000, 180000, DateTime(2026, 10, 1)), // paga
        bill('b3', 'Cartão', 100000, 40000, DateTime(2026, 10, 25)), // parcial
        bill('b4', 'Luz', 10000, 13000, DateTime(2026, 10, 5)), // excedente
        bill('b5', 'Futura', 5000, 0, DateTime(2027, 3, 1)), // prevista
        bill('b6', 'Proxima', 5000, 0, DateTime(2026, 10, 20)), // pendente
        bill('b7', 'Velha cancelada', 7000, 0, DateTime(2026, 1, 1), canceled: DateTime.utc(2026, 1, 2)),
      ],
    );

    List<List<String>> rows([ExportData? d, ExportOptions? o]) {
      final f = const CsvExporter().export(d ?? data, o ?? opts(ds: {ExportDataset.bills})).single;
      return table(f);
    }

    test('cabeçalho e uma linha por conta, ordenadas por vencimento', () {
      final r = rows();
      expect(r.first.take(8), ['id', 'nome', 'categoria', 'categoria_id', 'tipo', 'vencimento', 'valor_previsto', 'valor_pago']);
      expect(r.length, 8);
      expect(r.skip(1).map((x) => x[1]), ['Velha cancelada', 'Aluguel', 'Internet', 'Luz', 'Proxima', 'Cartão', 'Futura']);
      expect(r.every((x) => x.length == r.first.length), isTrue);
    });

    test('valores previsto, pago, restante, excedente e percentual', () {
      final byName = {for (final x in rows().skip(1)) x[1]: x};
      List<String> money(String n) => byName[n]!.sublist(6, 11); // previsto, pago, restante, excedente, percentual
      expect(money('Aluguel'), ['1800.00', '1800.00', '0.00', '0.00', '100.00']);
      expect(money('Cartão'), ['1000.00', '400.00', '600.00', '0.00', '40.00']);
      expect(money('Luz'), ['100.00', '130.00', '0.00', '30.00', '100.00']);
      expect(money('Internet'), ['120.00', '0.00', '120.00', '0.00', '0.00']);
    });

    test('status na data da exportação, para todos os estados', () {
      final status = {for (final x in rows().skip(1)) x[1]: x[11]};
      expect(status, {
        'Aluguel': 'paga',
        'Internet': 'vencida',
        'Cartão': 'parcialmente_paga',
        'Luz': 'paga',
        'Futura': 'prevista',
        'Proxima': 'pendente',
        'Velha cancelada': 'cancelada',
      });
    });

    test('datas, tipo, recorrência e booleanos em formato de máquina', () {
      final d = ExportData(exportedAt: exportedAt, includeDeleted: false, bills: [
        bill('r1', 'Netflix', 3990, 0, DateTime(2026, 11, 10), recurring: 'rule-1', type: ExpenseType.variable),
      ]);
      final r = rows(d)[1];
      expect(r[4], 'variavel');
      expect(r[5], '2026-11-10');
      expect(r[12], 'false'); // favorito
      expect(r[13], 'true'); // recorrente
      expect(r[14], 'rule-1');
      expect(r[17], '2026-01-01T09:00:00.000Z');
    });

    test('ida e volta: nomes e observações com vírgula, aspas, quebra de linha e fórmula', () {
      const tricky = 'Mercado, "Zé"\nlinha 2; fim';
      final d = ExportData(exportedAt: exportedAt, includeDeleted: false, bills: [
        bill('t1', '=cmd|calc', 100, 0, DateTime(2026, 10, 20), note: tricky),
      ]);
      for (final delim in CsvDelimiter.values) {
        final f = const CsvExporter().export(d, opts(ds: {ExportDataset.bills}, d: delim)).single;
        final r = parseCsv(utf8.decode(f.bytes), delimiter: delim.char);
        expect(r.length, 2, reason: 'a quebra de linha não pode criar linha nova');
        expect(r[1][1], "'=cmd|calc");
        expect(r[1][16], tricky);
      }
    });

    test('coluna excluido_em só aparece quando incluídos os excluídos', () {
      final withDeleted = ExportData(exportedAt: exportedAt, includeDeleted: true, bills: [
        bill('d1', 'Apagada', 100, 0, DateTime(2026, 10, 20), deleted: DateTime.utc(2026, 10, 5)),
        bill('d2', 'Ativa', 100, 0, DateTime(2026, 10, 21)),
      ]);
      final on = rows(withDeleted, opts(ds: {ExportDataset.bills}, deleted: true));
      expect(on.first.last, 'excluido_em');
      expect(on[1].last, '2026-10-05T00:00:00.000Z');
      expect(on[2].last, '');
      expect(rows(withDeleted, opts(ds: {ExportDataset.bills})).first, isNot(contains('excluido_em')));
    });

    test('mil contas exportam rápido e completas', () {
      final big = ExportData(exportedAt: exportedAt, includeDeleted: false, bills: [
        for (var i = 0; i < 1000; i++) bill('id$i', 'Conta $i', 1000 + i, i % 3 == 0 ? 1000 + i : 0, DateTime(2026, 1 + i % 12, 1 + i % 28)),
      ]);
      final sw = Stopwatch()..start();
      final r = rows(big);
      sw.stop();
      expect(r.length, 1001);
      expect(sw.elapsedMilliseconds, lessThan(2000));
    });
  });

  group('demais conjuntos', () {
    final data = ExportData(
      exportedAt: exportedAt,
      includeDeleted: false,
      categories: const [
        ExportCategory(id: 'c2', name: 'Pets', colorHex: '#112233', isDefault: false, sortOrder: 12),
        ExportCategory(id: 'c1', name: 'Moradia', colorHex: '#6A2FD0', isDefault: true, sortOrder: 0),
      ],
      payments: [
        ExportPayment(id: 'p2', billId: 'b1', billName: 'Aluguel', amountCents: 50000, paidAt: DateTime.utc(2026, 10, 3, 14), note: 'parte 2', createdAt: DateTime.utc(2026, 10, 3)),
        ExportPayment(id: 'p1', billId: 'b1', billName: 'Aluguel', amountCents: 130000, paidAt: DateTime.utc(2026, 10, 1, 9), note: '', createdAt: DateTime.utc(2026, 10, 1)),
      ],
      recurrences: [
        ExportRecurrence(
          id: 'r1',
          name: 'Netflix',
          categoryId: 'c1',
          categoryName: 'Assinaturas',
          expenseType: ExpenseType.fixed,
          frequency: Frequency.monthly,
          interval: 1,
          start: DateTime(2026, 1, 10),
          baseCents: 3990,
          favorite: true,
        ),
        ExportRecurrence(
          id: 'r2',
          name: 'Vacina',
          categoryId: 'c1',
          categoryName: 'Saúde',
          expenseType: ExpenseType.oneOff,
          frequency: Frequency.custom,
          interval: 30,
          start: DateTime(2026, 2, 1),
          end: DateTime(2026, 12, 1),
          baseCents: 5000,
          favorite: false,
        ),
      ],
      incomes: const [
        ExportIncome(id: 'i1', yearMonth: '2026-10', kind: IncomeKind.extra, amountCents: 10000, description: 'freela', received: true),
        ExportIncome(id: 'i0', yearMonth: '2026-09', kind: IncomeKind.salary, amountCents: 800000, description: '', received: false),
      ],
      investments: const [ExportInvestment(id: 'v1', yearMonth: '2026-10', plannedCents: 200000, realizedCents: 150000, description: 'CDB')],
      planning: const [
        ExportPlanningRow(scope: '2026-11', salaryCents: 920000, investmentCents: 300000),
        ExportPlanningRow(scope: 'padrao_desde_2026-01', salaryCents: 800000, extraIncomeCents: 50000, savingsGoalCents: 100000, investmentCents: 200000),
        ExportPlanningRow(scope: '2026-10', extraIncomeCents: 0),
      ],
    );
    List<List<String>> only(ExportDataset ds) => table(const CsvExporter().export(data, opts(ds: {ds})).single);

    test('pagamentos em ordem cronológica, com nome da conta', () {
      final r = only(ExportDataset.payments);
      expect(r.first, ['id', 'conta_id', 'conta', 'valor', 'pago_em', 'observacao', 'criado_em']);
      expect(r.skip(1).map((x) => [x[0], x[2], x[3]]), [['p1', 'Aluguel', '1300.00'], ['p2', 'Aluguel', '500.00']]);
    });

    test('categorias ordenadas, com cor e se é padrão', () {
      final r = only(ExportDataset.categories);
      expect(r.skip(1).map((x) => [x[1], x[2], x[3], x[4]]), [['Moradia', 'true', '0', '#6A2FD0'], ['Pets', 'false', '12', '#112233']]);
    });

    test('recorrências com frequência, intervalo e fim opcional', () {
      final r = only(ExportDataset.recurrences);
      final n = r.skip(1).firstWhere((x) => x[1] == 'Netflix');
      expect(n.sublist(4), ['fixo', 'mensal', '1', '2026-01-10', '', '39.90', 'true', '', '']); // sem faixa: colunas vazias
      final v = r.skip(1).firstWhere((x) => x[1] == 'Vacina');
      expect(v.sublist(4), ['pontual', 'dias', '30', '2026-02-01', '2026-12-01', '50.00', 'false', '', '']);
    });

    test('rendas e investimentos por mês', () {
      expect(only(ExportDataset.incomes).skip(1).map((x) => [x[1], x[2], x[3], x[5]]), [['2026-09', 'salario', '8000.00', 'false'], ['2026-10', 'extra', '100.00', 'true']]);
      expect(only(ExportDataset.investments)[1], ['v1', '2026-10', '2000.00', '1500.00', 'CDB']);
    });

    test('planejamento: padrão primeiro; campo vazio = herda; zero é zero', () {
      final r = only(ExportDataset.planning);
      expect(r.first, ['escopo', 'salario_liquido', 'renda_extra', 'meta_economia', 'investimento_planejado']);
      expect(r[1], ['padrao_desde_2026-01', '8000.00', '500.00', '1000.00', '2000.00']);
      expect(r[2], ['2026-10', '', '0.00', '', '']);
      expect(r[3], ['2026-11', '9200.00', '', '', '3000.00']);
    });

    test('só os conjuntos pedidos, na ordem fixa', () {
      final files = const CsvExporter().export(data, opts(ds: {ExportDataset.planning, ExportDataset.bills, ExportDataset.payments}));
      expect(files.map((f) => f.name), ['contas.csv', 'pagamentos.csv', 'planejamento.csv']);
      expect(const CsvExporter().export(data, const ExportOptions(datasets: {})), isEmpty);
    });

    test('conjuntos vazios geram só o cabeçalho', () {
      final r = table(const CsvExporter().export(ExportData(exportedAt: exportedAt, includeDeleted: false), opts(ds: {ExportDataset.bills})).single);
      expect(r.length, 1);
    });
  });

  test('faixa de valor: colunas faixa_minima/faixa_maxima em contas e recorrências, vazias sem faixa', () {
    final ranged = ExportBill(
      id: 'e1',
      name: 'Energia',
      categoryId: 'cat-1',
      categoryName: 'Moradia',
      expenseType: ExpenseType.variable,
      dueDate: DateTime(2026, 10, 20),
      plannedCents: 25000,
      paidCents: 0,
      favorite: false,
      note: '',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
      minCents: 20000,
      maxCents: 30000,
    );
    final data = ExportData(exportedAt: exportedAt, includeDeleted: true, bills: [ranged, bill('e2', 'Aluguel', 100000, 0, DateTime(2026, 10, 25))], recurrences: [
      ExportRecurrence(
        id: 'r9',
        name: 'Energia',
        categoryId: 'c1',
        categoryName: 'Moradia',
        expenseType: ExpenseType.variable,
        frequency: Frequency.monthly,
        interval: 1,
        start: DateTime(2026, 1, 20),
        baseCents: 25000,
        favorite: false,
        minCents: 20000,
        maxCents: 30000,
      ),
    ]);
    final bills = table(const CsvExporter().export(data, opts(ds: {ExportDataset.bills}, deleted: true)).single);
    final h = bills.first;
    expect(h.sublist(h.length - 3), ['faixa_minima', 'faixa_maxima', 'excluido_em']);
    final energia = bills.skip(1).firstWhere((r) => r[1] == 'Energia');
    expect(energia.sublist(energia.length - 3, energia.length - 1), ['200.00', '300.00']);
    final aluguel = bills.skip(1).firstWhere((r) => r[1] == 'Aluguel');
    expect(aluguel.sublist(aluguel.length - 3, aluguel.length - 1), ['', '']);
    final recs = table(const CsvExporter().export(data, opts(ds: {ExportDataset.recurrences}, deleted: true)).single);
    expect(recs.first.sublist(recs.first.length - 3), ['faixa_minima', 'faixa_maxima', 'excluido_em']);
    expect(recs[1].sublist(recs[1].length - 3, recs[1].length - 1), ['200.00', '300.00']);
  });

  test('LEIA-ME descreve separador, decimal e arquivos', () {
    final data = ExportData(exportedAt: exportedAt, includeDeleted: true);
    const exporter = CsvExporter();
    final o = opts(ds: {ExportDataset.bills, ExportDataset.payments}, d: CsvDelimiter.semicolon, deleted: true);
    final readme = utf8.decode(exporter.readme(data, o, exporter.export(data, o)).bytes);
    expect(readme, contains('ponto e vírgula'));
    expect(readme, contains('1234,56'));
    expect(readme, contains('contas.csv'));
    expect(readme, contains('pagamentos.csv'));
    expect(readme, isNot(contains('planejamento.csv')));
    expect(readme, contains('Inclui itens excluídos'));
    expect(readme, contains('faixa_minima'));
  });

  test('formatos: só CSV disponível por enquanto', () {
    expect(ExportFormat.values.where((f) => f.available), [ExportFormat.csv]);
    expect(ExportFormat.xlsx.extension, 'xlsx');
  });
}
