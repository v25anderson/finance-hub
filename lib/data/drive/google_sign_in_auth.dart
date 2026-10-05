import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../application/drive/drive_storage.dart';

const driveFileScope = 'https://www.googleapis.com/auth/drive.file';

/// Cliente OAuth "web" do projeto no Google Cloud, passado na compilação:
/// `--dart-define=GOOGLE_SERVER_CLIENT_ID=...apps.googleusercontent.com` (veja docs/GOOGLE_SETUP.md).
const configuredServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

/// Login Google pelo serviço do sistema (Play Services no Android). O app não grava senha nem token.
class GoogleSignInAuth implements DriveAuth {
  GoogleSignInAuth({this.serverClientId = configuredServerClientId, GoogleSignIn? signIn}) : _gs = signIn ?? GoogleSignIn.instance;

  final String serverClientId;
  final GoogleSignIn _gs;
  GoogleSignInAccount? _account;
  Future<void>? _init;

  /// O login Google deste pacote só existe em Android e iOS (não na web nem no desktop).
  static bool get platformSupported => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  DriveUnavailableReason? get unavailableReason {
    if (!platformSupported) return DriveUnavailableReason.unsupportedPlatform;
    if (serverClientId.isEmpty) return DriveUnavailableReason.notConfigured;
    if (!_gs.supportsAuthenticate()) return DriveUnavailableReason.unsupportedPlatform;
    return null;
  }

  @override
  bool get available => unavailableReason == null;

  Future<void> _ensureInit() => _init ??= _gs.initialize(serverClientId: serverClientId);

  @override
  Future<DriveAccount?> restore() async {
    if (!available) return null;
    await _ensureInit();
    try {
      final account = await _gs.attemptLightweightAuthentication();
      if (account == null) return null;
      if (await account.authorizationClient.authorizationForScopes(const [driveFileScope]) == null) return null;
      _account = account;
      return DriveAccount(email: account.email);
    } on GoogleSignInException {
      return null;
    }
  }

  @override
  Future<DriveAccount> signIn() async {
    if (!available) throw DriveException(DriveFailure.unknown);
    await _ensureInit();
    try {
      final account = await _gs.authenticate(scopeHint: const [driveFileScope]);
      await account.authorizationClient.authorizeScopes(const [driveFileScope]);
      _account = account;
      return DriveAccount(email: account.email);
    } on GoogleSignInException catch (e) {
      throw DriveException(
        switch (e.code) {
          GoogleSignInExceptionCode.canceled || GoogleSignInExceptionCode.interrupted => DriveFailure.canceled,
          GoogleSignInExceptionCode.clientConfigurationError ||
          GoogleSignInExceptionCode.providerConfigurationError =>
            DriveFailure.configuration,
          _ => DriveFailure.unknown,
        },
        null,
        e.code.name,
      );
    }
  }

  @override
  Future<void> signOut() async {
    _account = null;
    if (!available) return;
    await _ensureInit();
    await _gs.signOut();
  }

  @override
  Future<Map<String, String>> authHeaders() async {
    final account = _account;
    if (account == null) throw DriveException(DriveFailure.unauthorized);
    try {
      final h = await account.authorizationClient.authorizationHeaders(const [driveFileScope]);
      if (h == null) throw DriveException(DriveFailure.unauthorized);
      return h;
    } on GoogleSignInException {
      throw DriveException(DriveFailure.unauthorized);
    }
  }
}
