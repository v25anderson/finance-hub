import 'dart:typed_data';

import 'package:finance_hub/application/backup_service.dart';
import 'package:finance_hub/application/drive/drive_storage.dart';

class FakeDrive implements DriveStorage {
  final files = <String, ({RemoteBackup meta, Uint8List bytes})>{};
  DriveException? failNext;
  var _n = 0;

  void _maybeFail() {
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw f;
    }
  }

  @override
  Future<List<RemoteBackup>> listBackups() async {
    _maybeFail();
    return (files.values.map((f) => f.meta).toList()..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt)));
  }

  @override
  Future<RemoteBackup> uploadBackup(String name, Uint8List bytes) async {
    _maybeFail();
    final m = RemoteBackup(id: 'id${_n++}', name: name, modifiedAt: DateTime.utc(2026, 10, 10, 12, _n), sizeBytes: bytes.length);
    files[m.id] = (meta: m, bytes: bytes);
    return m;
  }

  @override
  Future<Uint8List> downloadBackup(String id) async {
    _maybeFail();
    final f = files[id];
    if (f == null) throw DriveException(DriveFailure.notFound);
    return f.bytes;
  }

  @override
  Future<void> deleteBackup(String id) async => files.remove(id);
}

class FakeSafety implements SafetyCopyStore {
  final saved = <String, Uint8List>{};
  @override
  Future<void> save(String name, Uint8List bytes) async => saved[name] = bytes;
}

class FakeAuth implements DriveAuth {
  FakeAuth({this.available = true, this.email = 'pessoa@example.com', this.failSignIn = false});
  @override
  final bool available;
  final String email;
  bool failSignIn;
  var signedIn = false;

  @override
  Future<DriveAccount?> restore() async => null;

  @override
  Future<DriveAccount> signIn() async {
    if (failSignIn) throw DriveException(DriveFailure.unauthorized);
    signedIn = true;
    return DriveAccount(email: email);
  }

  @override
  Future<void> signOut() async => signedIn = false;

  @override
  Future<Map<String, String>> authHeaders() async => {'Authorization': 'Bearer fake'};
}
