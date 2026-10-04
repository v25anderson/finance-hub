import 'dart:typed_data';

class RemoteChangeFile {
  const RemoteChangeFile({required this.id, required this.deviceId, required this.seq, required this.modifiedAt});
  final String id, deviceId;
  final int seq;
  final DateTime modifiedAt;
}

/// Onde os aparelhos trocam arquivos de mudanças. Só acrescenta arquivos; nunca altera nem apaga os existentes.
abstract interface class SyncTransport {
  Future<List<RemoteChangeFile>> listChangeFiles();
  Future<void> uploadChangeFile(String deviceId, int seq, Uint8List bytes);
  Future<Uint8List> downloadChangeFile(String id);
}
