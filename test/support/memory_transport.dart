import 'dart:typed_data';

import 'package:finance_hub/application/sync/sync_transport.dart';

/// "Drive" em memória compartilhado entre os aparelhos simulados.
class MemoryTransport implements SyncTransport {
  final files = <String, ({RemoteChangeFile meta, Uint8List bytes})>{};
  var _n = 0;
  var failUploads = false;

  @override
  Future<List<RemoteChangeFile>> listChangeFiles() async => [for (final f in files.values) f.meta];

  @override
  Future<void> uploadChangeFile(String deviceId, int seq, Uint8List bytes) async {
    if (failUploads) throw StateError('sem rede');
    final id = 'f${_n++}';
    files[id] = (meta: RemoteChangeFile(id: id, deviceId: deviceId, seq: seq, modifiedAt: DateTime.utc(2026, 10, 10, 12).add(Duration(seconds: _n))), bytes: bytes);
  }

  @override
  Future<Uint8List> downloadChangeFile(String id) async => files[id]!.bytes;
}

