import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../application/backup_service.dart';

/// Grava as cópias de segurança na pasta privada do app (`safety/`). Não são apagadas automaticamente.
class LocalSafetyStore implements SafetyCopyStore {
  const LocalSafetyStore();

  @override
  Future<void> save(String name, Uint8List bytes) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}safety');
    await dir.create(recursive: true);
    await File('${dir.path}${Platform.pathSeparator}$name').writeAsBytes(bytes, flush: true);
  }
}
