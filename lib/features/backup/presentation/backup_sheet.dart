import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/backup_service.dart';
import '../../../application/drive/drive_storage.dart';
import '../../../core/formatting.dart';
import '../../../data/db/app_database.dart' show SyncMetaRow;
import '../../../data/providers.dart';
import '../../../design_system/components/adaptive_sheet.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/sync_light.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../domain/backup/snapshot.dart';
import '../../../domain/enums.dart';
import '../../../domain/sync/change_file.dart';
import 'conflicts_sheet.dart';
import '../../../design_system/components/app_snack.dart';

Future<void> showBackupSheet(BuildContext context) => showAdaptiveSheet<void>(context, builder: (_) => const BackupSheet());

String _size(int bytes) => bytes < 1024 * 1024 ? '${(bytes / 1024).ceil()} KB' : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

/// Backup manual no Google Drive: conectar, enviar, listar, restaurar e excluir.
class BackupSheet extends ConsumerStatefulWidget {
  const BackupSheet({super.key});

  @override
  ConsumerState<BackupSheet> createState() => _BackupSheetState();
}

class _BackupSheetState extends ConsumerState<BackupSheet> {
  var _busy = false;

  void _say(String m) => showAppSnack(ScaffoldMessenger.of(context), m);

  /// Executa uma operação com tratamento único de erros. Permissão expirada derruba a conexão.
  Future<void> _run(Future<String?> Function() op) async {
    setState(() => _busy = true);
    String? message;
    try {
      message = await op();
    } on DriveException catch (e) {
      message = e.message;
      if (e.kind == DriveFailure.unauthorized) ref.read(driveConnectionProvider.notifier).expired();
    } on BackupFormatError catch (e) {
      message = e.message;
    } on SyncFormatError catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Não foi possível concluir. Seus dados não foram alterados.';
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (message != null) _say(message);
  }

  Future<void> _backup() => _run(() async {
        await ref.read(backupServiceProvider).backupNow();
        ref.invalidate(remoteBackupsProvider);
        return 'Backup enviado para o Drive.';
      });

  Future<void> _syncNow() => _run(() async {
        final r = await ref.read(syncServiceProvider).sync();
        ref.invalidate(remoteBackupsProvider);
        final parts = <String>[
          if (r.applied + r.merged > 0) '${r.applied + r.merged} recebidos',
          if (r.pushed > 0) '${r.pushed} enviados',
          if (r.newConflicts > 0) '${r.newConflicts} conflitos para resolver',
          if (r.skipped > 0) '${r.skipped} ignorados',
          if (r.waiting > 0) 'aguardando arquivos de outro aparelho',
        ];
        return parts.isEmpty ? 'Tudo em dia.' : 'Sincronizado: ${parts.join(', ')}.';
      });

  Future<void> _restore(RemoteBackup b) async {
    final service = ref.read(backupServiceProvider);
    BackupPreview? preview;
    await _run(() async {
      preview = await service.preview(b);
      return null;
    });
    final p = preview;
    if (p == null || !mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Restaurar este backup?'),
        scrollable: true,
        content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Backup de ${formatDateTime(p.createdAt)}: ${p.counts['transactions']} contas, ${p.counts['payments']} pagamentos.'),
          const SizedBox(height: Space.sm),
          const Text('Isso substitui TODOS os dados deste aparelho pelos do backup. Antes, uma cópia dos dados atuais é guardada no aparelho.'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar')),
          FilledButton(key: const Key('backup-restore-confirm'), onPressed: () => Navigator.pop(d, true), child: const Text('Restaurar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() async {
      await service.restore(b);
      return 'Dados restaurados.';
    });
  }

  Future<void> _delete(RemoteBackup b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Excluir backup do Drive?'),
        content: Text('${formatDateTime(b.modifiedAt)} será removido do Drive. Seus dados neste aparelho não mudam.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancelar')),
          FilledButton(key: const Key('backup-delete-confirm'), onPressed: () => Navigator.pop(d, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() async {
      await ref.read(backupServiceProvider).delete(b);
      ref.invalidate(remoteBackupsProvider);
      return 'Backup excluído do Drive.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final connection = ref.watch(driveConnectionProvider);
    final light = ref.watch(syncLightProvider);
    return Material(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.lg),
        children: [
          Text('Backup e sincronização', style: AppText.title(c.textPrimary)),
          const SizedBox(height: Space.xs),
          Text(
            'O app só acessa a pasta "Finance Hub" e os arquivos que ele mesmo criar. Nada é enviado sem você tocar em "Fazer backup" ou "Sincronizar agora".',
            style: AppText.body(c.textSecondary),
          ),
          const SizedBox(height: Space.md),
          Align(alignment: Alignment.centerLeft, child: SyncBadge(key: const Key('sync-badge'), state: light.state, label: light.label)),
          const SizedBox(height: Space.lg),
          switch (connection) {
            DriveUnavailable(:final reason) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      reason == DriveUnavailableReason.unsupportedPlatform ? 'Disponível só no aplicativo para celular' : 'Login com Google ainda não ativado',
                      style: AppText.headline(c.textPrimary),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      reason == DriveUnavailableReason.unsupportedPlatform
                          ? 'O backup e a sincronização com o Google Drive funcionam no aplicativo Android. Nesta versão, seus dados ficam salvos neste navegador e a exportação em CSV funciona normalmente.'
                          : 'Esta versão do app foi gerada sem o ID de cliente do Google, então o backup e a sincronização ficam desligados. Seus dados continuam salvos no aparelho e a exportação em CSV funciona normalmente.',
                      key: const Key('backup-unavailable'),
                      style: AppText.body(c.textSecondary),
                    ),
                  ]),
                ),
                const SizedBox(height: Space.md),
                const AppButton(key: Key('backup-connect-disabled'), label: 'Conectar com Google', icon: Icons.cloud_outlined, kind: AppButtonKind.primary, expand: true, onPressed: null),
              ]),
            DriveConnecting() => const Padding(padding: EdgeInsets.all(Space.xl), child: Center(child: CircularProgressIndicator())),
            DriveDisconnected(:final error) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (error != null) Padding(padding: const EdgeInsets.only(bottom: Space.sm), child: Text(error, key: const Key('backup-error'), style: AppText.body(c.danger))),
                AppButton(
                  key: const Key('backup-connect'),
                  label: 'Conectar com Google',
                  icon: Icons.cloud_outlined,
                  kind: AppButtonKind.primary,
                  expand: true,
                  onPressed: () => ref.read(driveConnectionProvider.notifier).connect(),
                ),
              ]),
            DriveConnected(:final email) => _connected(context, email),
          },
        ],
      ),
    );
  }

  Widget _connected(BuildContext context, String email) {
    final c = context.colors;
    final backups = ref.watch(remoteBackupsProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppCard(child: Row(children: [
        Icon(Icons.check_circle_rounded, color: c.success, size: 20),
        const SizedBox(width: Space.sm),
        Expanded(child: Text('Conectado: $email', key: const Key('backup-account'), overflow: TextOverflow.ellipsis)),
        TextButton(
          key: const Key('backup-disconnect'),
          onPressed: _busy ? null : () => ref.read(driveConnectionProvider.notifier).disconnect(),
          child: const Text('Desconectar'),
        ),
      ])),
      const SizedBox(height: Space.md),
      AppButton(
        key: const Key('backup-now'),
        label: _busy ? 'Aguarde…' : 'Fazer backup agora',
        icon: Icons.cloud_upload_outlined,
        kind: AppButtonKind.primary,
        expand: true,
        onPressed: _busy ? null : _backup,
      ),
      const SizedBox(height: Space.lg),
      _syncSection(context),
      const SizedBox(height: Space.lg),
      Text('Backups no Drive', style: AppText.label(c.textSecondary)),
      const SizedBox(height: Space.xs),
      backups.when(
        skipLoadingOnReload: true,
        loading: () => const Padding(padding: EdgeInsets.all(Space.lg), child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text(e is DriveException ? e.message : 'Não foi possível listar os backups.', key: const Key('backup-list-error'), style: AppText.body(c.danger)),
        data: (list) => list.isEmpty
            ? Text('Nenhum backup ainda.', key: const Key('backup-empty'), style: AppText.body(c.textSecondary))
            : Column(children: [
                for (final b in list)
                  ListTile(
                    key: Key('backup-item-${b.id}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(formatDateTime(b.modifiedAt)),
                    subtitle: Text(_size(b.sizeBytes)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      TextButton(key: Key('backup-restore-${b.id}'), onPressed: _busy ? null : () => _restore(b), child: const Text('Restaurar')),
                      IconButton(key: Key('backup-delete-${b.id}'), tooltip: 'Excluir backup', onPressed: _busy ? null : () => _delete(b), icon: const Icon(Icons.delete_outline)),
                    ]),
                  ),
              ]),
      ),
    ]);
  }

  String _syncStatus(SyncMetaRow? m) {
    if (m == null) return 'Ainda não sincronizado.';
    return switch (m.state) {
      SyncState.syncing => 'Sincronizando…',
      SyncState.error => 'A última sincronização falhou. Seus dados locais estão intactos.',
      _ => m.lastSyncAt == null ? 'Ainda não sincronizado.' : 'Última sincronização: ${formatDateTime(m.lastSyncAt!)}',
    };
  }

  Widget _syncSection(BuildContext context) {
    final c = context.colors;
    final meta = ref.watch(syncMetaProvider).value;
    final conflicts = ref.watch(openConflictsProvider).value?.length ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Sincronização entre aparelhos', style: AppText.label(c.textSecondary)),
      const SizedBox(height: Space.xs),
      Text(_syncStatus(meta), key: const Key('sync-status'), style: AppText.body(c.textSecondary)),
      const SizedBox(height: Space.sm),
      AppButton(
        key: const Key('sync-now'),
        label: 'Sincronizar agora',
        icon: Icons.sync_rounded,
        kind: AppButtonKind.tonal,
        expand: true,
        onPressed: _busy ? null : _syncNow,
      ),
      if (conflicts > 0) ...[
        const SizedBox(height: Space.sm),
        TextButton.icon(
          key: const Key('sync-conflicts'),
          onPressed: () => showConflictsSheet(context),
          icon: Icon(Icons.warning_amber_rounded, color: c.warning),
          label: Text(conflicts == 1 ? '1 conflito para resolver' : '$conflicts conflitos para resolver'),
        ),
      ],
    ]);
  }
}

