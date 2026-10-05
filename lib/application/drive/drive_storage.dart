import 'dart:typed_data';

/// Por que o Drive não está disponível: build sem ID de cliente do Google, ou plataforma sem login Google (web e desktop).
enum DriveUnavailableReason { notConfigured, unsupportedPlatform }

enum DriveFailure { unauthorized, notFound, quota, network, unavailable, unknown }

/// Falha de acesso ao Drive. A mensagem nunca carrega dados do usuário nem trechos de resposta.
class DriveException implements Exception {
  DriveException(this.kind, [this.statusCode]);
  final DriveFailure kind;
  final int? statusCode;

  String get message => switch (kind) {
        DriveFailure.unauthorized => 'A permissão do Google expirou. Conecte novamente.',
        DriveFailure.notFound => 'O arquivo não foi encontrado no Drive.',
        DriveFailure.quota => 'Seu Google Drive está sem espaço.',
        DriveFailure.network => 'Sem conexão com a internet.',
        DriveFailure.unavailable => 'O Google Drive está indisponível agora. Tente de novo mais tarde.',
        DriveFailure.unknown => 'Não foi possível falar com o Google Drive.',
      };

  @override
  String toString() => 'DriveException($kind${statusCode == null ? '' : ', $statusCode'})';
}

class RemoteBackup {
  const RemoteBackup({required this.id, required this.name, required this.modifiedAt, required this.sizeBytes});
  final String id, name;
  final DateTime modifiedAt;
  final int sizeBytes;
}

/// Armazenamento remoto de backups. Só conhece arquivos criados pelo próprio app (escopo `drive.file`).
abstract interface class DriveStorage {
  /// Mais recentes primeiro.
  Future<List<RemoteBackup>> listBackups();
  Future<RemoteBackup> uploadBackup(String name, Uint8List bytes);
  Future<Uint8List> downloadBackup(String id);
  Future<void> deleteBackup(String id);
}

class DriveAccount {
  const DriveAccount({required this.email});
  final String email;
}

/// Conexão com a conta Google. O app nunca vê a senha; o token vem do serviço do sistema e não é gravado no banco.
abstract interface class DriveAuth {
  /// Falso quando o app não foi configurado com um cliente OAuth ou a plataforma não suporta.
  bool get available;

  /// Motivo da indisponibilidade; nulo quando [available].
  DriveUnavailableReason? get unavailableReason;

  /// Retoma uma conexão anterior sem tela, se houver.
  Future<DriveAccount?> restore();
  Future<DriveAccount> signIn();
  Future<void> signOut();

  /// Cabeçalhos `Authorization` válidos agora.
  Future<Map<String, String>> authHeaders();
}
