import 'dart:typed_data';

/// Entrega um arquivo ao usuário. A implementação real abre o seletor do sistema; testes usam um falso.
abstract interface class FileSaver {
  /// Retorna `true` se salvou, `false` se o usuário cancelou.
  Future<bool> save({required String fileName, required Uint8List bytes, required String mime});
}
