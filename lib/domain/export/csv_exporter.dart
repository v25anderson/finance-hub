import 'dart:convert';
import 'dart:typed_data';

import '../../core/dates.dart';
import '../bill.dart';
import '../enums.dart';
import 'csv.dart';
import 'export_data.dart';
import 'exporter.dart';

String _typeName(ExpenseType t) => switch (t) {
      ExpenseType.fixed => 'fixo',
      ExpenseType.variable => 'variavel',
      ExpenseType.oneOff => 'pontual',
    };

String _frequencyName(Frequency f) => switch (f) {
      Frequency.weekly => 'semanal',
      Frequency.monthly => 'mensal',
      Frequency.yearly => 'anual',
      Frequency.custom => 'dias',
    };

String _incomeKindName(IncomeKind k) => switch (k) {
      IncomeKind.salary => 'salario',
      IncomeKind.extra => 'extra',
      IncomeKind.other => 'outras',
    };

String _statusName(BillStatus s) => switch (s) {
      BillStatus.planned => 'prevista',
      BillStatus.pending => 'pendente',
      BillStatus.partiallyPaid => 'parcialmente_paga',
      BillStatus.paid => 'paga',
      BillStatus.overdue => 'vencida',
      BillStatus.canceled => 'cancelada',
    };

/// Estado da conta **na data da exportação**, pela mesma regra do app.
BillStatus statusAt(ExportBill b, DateTime today) => Bill(
      id: b.id,
      name: b.name,
      plannedCents: b.plannedCents,
      dueDate: b.dueDate,
      categoryId: b.categoryId,
      expenseType: b.expenseType,
      createdAt: b.createdAt,
      canceledAt: b.canceledAt,
      payments: b.paidCents > 0 ? [Payment(id: 'x', billId: b.id, amountCents: b.paidCents, paidAt: b.createdAt)] : const [],
    ).statusOn(today);

/// Exporta CSV (UTF-8 com BOM, CRLF), um arquivo por conjunto de dados.
class CsvExporter implements DataExporter {
  const CsvExporter();

  @override
  ExportFormat get format => ExportFormat.csv;

  @override
  List<ExportFile> export(ExportData data, ExportOptions options) {
    final d = options.delimiter;
    final del = options.includeDeleted;
    final today = dateOnly(data.exportedAt);
    final files = <ExportFile>[];

    ExportFile file(ExportDataset ds, List<String> header, List<List<Object?>> rows) {
      final text = buildCsv(header, rows, d);
      return ExportFile(name: '${ds.fileBase}.csv', bytes: Uint8List.fromList(utf8.encode(text)), mime: 'text/csv');
    }

    List<String> withDeleted(List<String> h) => del ? [...h, 'excluido_em'] : h;
    List<Object?> withDeletedCell(List<Object?> r, DateTime? at) => del ? [...r, at] : r;

    for (final ds in ExportDataset.values) {
      if (!options.datasets.contains(ds)) continue;
      switch (ds) {
        case ExportDataset.bills:
          final bills = [...data.bills]..sort((a, b) {
              final c = a.dueDate.compareTo(b.dueDate);
              if (c != 0) return c;
              final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
              return n != 0 ? n : a.id.compareTo(b.id);
            });
          files.add(file(ds, withDeleted([
            'id', 'nome', 'categoria', 'categoria_id', 'tipo', 'vencimento', 'valor_previsto', 'valor_pago', 'valor_restante', 'excedente',
            'percentual_pago', 'status', 'favorito', 'recorrente', 'recorrencia_id', 'data_ocorrencia', 'observacao', 'criado_em', 'atualizado_em', 'cancelada_em',
          ]), [
            for (final b in bills)
              withDeletedCell([
                b.id,
                b.name,
                b.categoryName,
                b.categoryId,
                _typeName(b.expenseType),
                isoDate(b.dueDate),
                CsvMoney(b.plannedCents),
                CsvMoney(b.paidCents),
                CsvMoney(b.plannedCents > b.paidCents ? b.plannedCents - b.paidCents : 0),
                CsvMoney(b.paidCents > b.plannedCents ? b.paidCents - b.plannedCents : 0),
                CsvDecimal(b.plannedCents <= 0 ? 0 : (b.paidCents / b.plannedCents * 100).clamp(0.0, 100.0)),
                _statusName(statusAt(b, today)),
                b.favorite,
                b.recurringId != null,
                b.recurringId,
                b.occurrenceDate == null ? null : isoDate(b.occurrenceDate!),
                b.note,
                b.createdAt,
                b.updatedAt,
                b.canceledAt,
              ], b.deletedAt),
          ]));
        case ExportDataset.payments:
          final pays = [...data.payments]..sort((a, b) {
              final c = a.paidAt.compareTo(b.paidAt);
              return c != 0 ? c : a.id.compareTo(b.id);
            });
          files.add(file(ds, withDeleted(['id', 'conta_id', 'conta', 'valor', 'pago_em', 'observacao', 'criado_em']), [
            for (final p in pays) withDeletedCell([p.id, p.billId, p.billName, CsvMoney(p.amountCents), p.paidAt, p.note, p.createdAt], p.deletedAt),
          ]));
        case ExportDataset.categories:
          final cats = [...data.categories]..sort((a, b) {
              final c = a.sortOrder.compareTo(b.sortOrder);
              return c != 0 ? c : a.name.compareTo(b.name);
            });
          files.add(file(ds, ['id', 'nome', 'padrao', 'ordem', 'cor'], [
            for (final c in cats) [c.id, c.name, c.isDefault, c.sortOrder, c.colorHex],
          ]));
        case ExportDataset.recurrences:
          final rs = [...data.recurrences]..sort((a, b) {
              final c = a.name.toLowerCase().compareTo(b.name.toLowerCase());
              return c != 0 ? c : a.id.compareTo(b.id);
            });
          files.add(file(ds, withDeleted(['id', 'nome', 'categoria', 'categoria_id', 'tipo', 'frequencia', 'intervalo', 'primeiro_vencimento', 'fim', 'valor_base', 'favorito']), [
            for (final r in rs)
              withDeletedCell([
                r.id,
                r.name,
                r.categoryName,
                r.categoryId,
                _typeName(r.expenseType),
                _frequencyName(r.frequency),
                r.interval,
                isoDate(r.start),
                r.end == null ? null : isoDate(r.end!),
                CsvMoney(r.baseCents),
                r.favorite,
              ], r.deletedAt),
          ]));
        case ExportDataset.incomes:
          final rs = [...data.incomes]..sort((a, b) {
              final c = a.yearMonth.compareTo(b.yearMonth);
              return c != 0 ? c : a.id.compareTo(b.id);
            });
          files.add(file(ds, withDeleted(['id', 'mes', 'tipo', 'valor', 'descricao', 'recebida']), [
            for (final i in rs) withDeletedCell([i.id, i.yearMonth, _incomeKindName(i.kind), CsvMoney(i.amountCents), i.description, i.received], i.deletedAt),
          ]));
        case ExportDataset.investments:
          final rs = [...data.investments]..sort((a, b) {
              final c = a.yearMonth.compareTo(b.yearMonth);
              return c != 0 ? c : a.id.compareTo(b.id);
            });
          files.add(file(ds, withDeleted(['id', 'mes', 'planejado', 'realizado', 'descricao']), [
            for (final i in rs) withDeletedCell([i.id, i.yearMonth, CsvMoney(i.plannedCents), CsvMoney(i.realizedCents), i.description], i.deletedAt),
          ]));
        case ExportDataset.planning:
          // 'padrao' primeiro, depois os meses em ordem
          final rs = [...data.planning]..sort((a, b) {
              if (a.scope == 'padrao') return b.scope == 'padrao' ? 0 : -1;
              if (b.scope == 'padrao') return 1;
              return a.scope.compareTo(b.scope);
            });
          CsvMoney? m(int? v) => v == null ? null : CsvMoney(v);
          files.add(file(ds, ['escopo', 'salario_liquido', 'renda_extra', 'meta_economia', 'investimento_planejado'], [
            for (final p in rs) [p.scope, m(p.salaryCents), m(p.extraIncomeCents), m(p.savingsGoalCents), m(p.investmentCents)],
          ]));
      }
    }
    return files;
  }

  /// Texto explicativo que acompanha o ZIP: separadores, formatos e o que cada arquivo contém.
  ExportFile readme(ExportData data, ExportOptions options, List<ExportFile> files) {
    final d = options.delimiter;
    final b = StringBuffer()
      ..writeln('FINANCE HUB — EXPORTAÇÃO DE DADOS')
      ..writeln('Gerado em: ${data.exportedAt.toUtc().toIso8601String()} (UTC)')
      ..writeln()
      ..writeln('FORMATO')
      ..writeln('- Codificação: UTF-8 com BOM; fim de linha CRLF.')
      ..writeln('- Separador de campos: ${d == CsvDelimiter.comma ? 'vírgula ( , )' : 'ponto e vírgula ( ; )'}.')
      ..writeln('- Valores em reais, sem separador de milhar, com "${d.decimalSeparator}" como separador decimal (ex.: ${formatCsvMoney(123456, d.decimalSeparator)}).')
      ..writeln('- Datas de vencimento: AAAA-MM-DD. Instantes (criação, pagamento): ISO 8601 em UTC. Meses: AAAA-MM.')
      ..writeln('- Booleanos: true / false. Campo vazio = sem valor (no planejamento, vazio significa "usa o padrão").')
      ..writeln('- Textos que começariam com = + - @ recebem um apóstrofo (\') à frente para não virarem fórmula na planilha.')
      ..writeln('- "status" das contas é calculado na data da exportação: prevista, pendente, parcialmente_paga, paga, vencida ou cancelada.')
      ..writeln('- "valor_pago" é a soma dos pagamentos; "excedente" é o que foi pago além do previsto.')
      ..writeln('- ${options.includeDeleted ? 'Inclui itens excluídos (coluna excluido_em).' : 'Itens excluídos não estão incluídos.'}')
      ..writeln()
      ..writeln('ARQUIVOS');
    for (final f in files) {
      final ds = ExportDataset.values.firstWhere((x) => '${x.fileBase}.csv' == f.name);
      b.writeln('- ${f.name}: ${ds.description}.');
    }
    b
      ..writeln()
      ..writeln('PRIVACIDADE')
      ..writeln('Este arquivo contém dados financeiros pessoais. Guarde-o em local seguro.');
    return ExportFile(name: 'LEIA-ME.txt', bytes: Uint8List.fromList(utf8.encode(b.toString())), mime: 'text/plain');
  }
}
