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

## Como funciona (Fase 11, implementado)
Sincronização **manual** ("Sincronizar agora") entre aparelhos que usam a mesma conta Google. Sem servidor: o Drive é só o ponto de encontro (pasta `Finance Hub/Sync`, escopo `drive.file`).

**Arquivos**: cada aparelho publica `changes_<deviceId>_<n>.json`, só acrescentando (nunca altera nem apaga). O arquivo traz a **cópia completa** dos registros novos ou alterados desde a última sincronização (não operações), então aplicar duas vezes dá o mesmo resultado. Mudança em relação ao desenho original: arquivos num conjunto plano (sem pasta por aparelho) e estado completo por registro, em vez de um log de operações.

**Base do merge**: a tabela `sync_base` guarda o último estado sincronizado de cada registro. "Alterado aqui" = difere da base. Campos de controle (`createdAt`, `updatedAt`, `version`, `deviceId`) não contam como alteração nem geram conflito.

**Ciclo** (`SyncService.sync`):
1. Lista os arquivos de OUTROS aparelhos e escolhe, por aparelho, a sequência contínua a partir do cursor (para no primeiro buraco; aparelho novo começa no menor número disponível).
2. Baixa e valida tudo antes de aplicar (versão mais nova do app → erro claro, nada aplicado).
3. Aplica numa única transação, com merge de três vias por campo (`mergeRecord`):
   - só o outro mudou → adota; só eu mudei → mantenho;
   - campos diferentes → combina automaticamente (e o resultado é enviado);
   - mesmo campo, valores diferentes → **conflito** (`sync_conflicts`): o registro local fica como está e **não é enviado** até o usuário escolher "manter este aparelho" ou "usar o outro". Novas versões remotas de um registro em conflito atualizam a versão remota guardada, sem decidir nada.
   - sem base (nunca sincronizado): dados iguais → nada; registro local nunca editado (ex.: criado pelo seed) → adota o remoto; senão conflito.
4. Envia um novo arquivo com os registros alterados aqui (exceto os em conflito) e só então atualiza a base e o número.

**Exclusão** é tombstone (`deletedAt`), um campo como os outros: excluir e restaurar se propagam. **Pagamentos** são registros com id próprio: criados em dois aparelhos, os dois ficam (união sem duplicar). **Ocorrências de recorrência** têm id determinístico (UUID v5 de regra + data): geradas em dois aparelhos, são o mesmo registro.

**Estados**: desconectado → conectado → sincronizando → sincronizado / erro (em `sync_metadata`). Falha de rede ou de envio não perde nada: a base só avança depois do envio, então a próxima tentativa reenvia.

**Fora do escopo / limites conhecidos**
- Comprovantes (`attachments`) não sincronizam (recurso ainda não existe; caminho local é do aparelho).
- Não é automática nem em segundo plano; sem notificação de mudança remota.
- Os arquivos de mudanças acumulam no Drive (nenhuma compactação ou limpeza automática, por design: nunca apagar histórico em silêncio).
- Se um arquivo de outro aparelho for apagado à mão, os seguintes ficam "aguardando" até o buraco ser preenchido; um aparelho que nunca viu o outro começa no menor número disponível (dados anteriores só chegam por backup).
- Restaurar um backup **reinicia** o histórico de sincronização deste aparelho (base, conflitos e cursor); a próxima sincronização o trata como aparelho novo e pode gerar conflitos.
- Edição manual de um campo em conflito (além de escolher um lado) não existe ainda.
- Dois envios simultâneos do mesmo aparelho não são tratados (há uma trava local contra sincronizações paralelas no mesmo app).
