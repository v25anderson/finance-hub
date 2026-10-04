import 'dart:typed_data';

import '../../application/sync/sync_transport.dart';
import 'drive_rest.dart';
import 'google_drive_storage.dart';

const syncFolderName = 'Sync';
final _name = RegExp(r'^changes_([0-9a-fA-F-]+)_(\d+)\.json$');

String changeFileName(String deviceId, int seq) => 'changes_${deviceId}_$seq.json';

/// Arquivos de mudanças em "Finance Hub/Sync", nomeados `changes_<aparelho>_<n>.json` (um conjunto plano, sem pasta por aparelho).
class GoogleDriveSyncTransport implements SyncTransport {
  GoogleDriveSyncTransport({required this.rest});
  final DriveRest rest;

  Future<String> _folder() async => rest.folder(syncFolderName, parentId: await rest.folder(driveFolderName));

  @override
  Future<List<RemoteChangeFile>> listChangeFiles() async {
    final out = <RemoteChangeFile>[];
    for (final f in await rest.list(await _folder(), 'changes_')) {
      final m = _name.firstMatch(f.name);
      if (m == null) continue; // ignora qualquer arquivo que não seja nosso
      out.add(RemoteChangeFile(id: f.id, deviceId: m.group(1)!, seq: int.parse(m.group(2)!), modifiedAt: f.modifiedAt));
    }
    return out;
  }

  @override
  Future<void> uploadChangeFile(String deviceId, int seq, Uint8List bytes) async {
    await rest.upload(await _folder(), changeFileName(deviceId, seq), bytes);
  }

  @override
  Future<Uint8List> downloadChangeFile(String id) => rest.download(id);
}
