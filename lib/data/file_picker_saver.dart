import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../application/file_saver.dart';

/// Salva onde o usuário escolher (seletor de arquivos do sistema). Nada é enviado pela rede.
class FilePickerSaver implements FileSaver {
  const FilePickerSaver();

  @override
  Future<bool> save({required String fileName, required Uint8List bytes, required String mime}) async {
    final path = await FilePicker.saveFile(dialogTitle: 'Salvar exportação', fileName: fileName, bytes: bytes);
    return path != null;
  }
}
