import 'dart:typed_data';

import 'csv.dart';
import 'export_data.dart';

/// Formatos de exportação. Só o CSV está implementado; os demais já têm lugar na arquitetura.
enum ExportFormat {
  csv('CSV', 'csv', 'text/csv', true),
  json('JSON', 'json', 'application/json', false),
  xlsx('Excel', 'xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', false),
  pdf('PDF', 'pdf', 'application/pdf', false);

  const ExportFormat(this.label, this.extension, this.mime, this.available);
  final String label;
  final String extension;
  final String mime;

  /// Há implementação disponível.
  final bool available;
}

class ExportOptions {
  const ExportOptions({
    required this.datasets,
    this.format = ExportFormat.csv,
    this.delimiter = CsvDelimiter.comma,
    this.includeDeleted = false,
  });
  final Set<ExportDataset> datasets;
  final ExportFormat format;
  final CsvDelimiter delimiter;

  /// Inclui itens excluídos (lixeira), com a data da exclusão.
  final bool includeDeleted;
}

class ExportFile {
  const ExportFile({required this.name, required this.bytes, required this.mime});
  final String name;
  final Uint8List bytes;
  final String mime;
}

/// Gera arquivos de um formato a partir dos dados. Novos formatos (JSON, Excel, PDF) só implementam isto.
abstract interface class DataExporter {
  ExportFormat get format;

  /// Um arquivo por conjunto de dados selecionado, na ordem de [ExportDataset.values].
  List<ExportFile> export(ExportData data, ExportOptions options);
}
