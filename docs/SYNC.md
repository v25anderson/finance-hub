# SYNC

Modelo: log de mudanças por registro, sem sobrescrever arquivo.
- Cada registro: `id`, `version`, `updatedAt` (relógio híbrido), `deviceId`.
- Exclusão = tombstone (`deletedAt`).
- Cada dispositivo escreve `Sync/<deviceId>/changes-<n>.json` (append-only) e lê os dos outros desde o último cursor.
- Conflito: mesmo registro alterado em dois dispositivos desde a `baseVersion`. Campos diferentes → merge automático. Mesmo campo → registro em `SyncConflict` com as duas versões; usuário escolhe local, remoto ou edita. Nada é descartado automaticamente.
- Pagamentos são append-only: união deduplicada por `id`.
- Snapshots periódicos em `Backups/` aceleram dispositivo novo e servem de restauração.
- Estados de UI: desconectado → conectado → sincronizando → sincronizado → erro.
- Implementação: Fases 10 (backup/Drive) e 11 (sync).
