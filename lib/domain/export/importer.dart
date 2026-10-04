import 'dart:typed_data';

import 'exporter.dart';

/// Resultado de uma importação (reservado).
class ImportReport {
  const ImportReport({required this.created, required this.skipped, this.errors = const []});
  final int created;
  final int skipped;
  final List<String> errors;
}

/// **Reservado para o futuro**: importar CSV → aplicativo. Ainda sem implementação.
///
/// O formato de entrada previsto é o mesmo que o app exporta (mesmos arquivos e colunas), de modo que um
/// arquivo exportado possa ser reimportado. Ao implementar: validar tudo antes de gravar, nunca sobrescrever
/// silenciosamente (ids existentes viram conflito) e reportar o que foi pulado.
abstract interface class DataImporter {
  ExportFormat get format;
  Future<ImportReport> import(Uint8List bytes, {required bool dryRun});
}
