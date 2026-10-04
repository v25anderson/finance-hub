# DATA_MODEL

## Campos comuns (toda entidade)
`id` (UUID v4) · `createdAt` · `updatedAt` · `deletedAt?` (soft delete) · `version` (int, +1 por alteração) · `deviceId` (último autor).
Dinheiro: **centavos inteiros**. Datas de vencimento: data pura (sem hora). Instantes (pagamentos): UTC.

## Entidades
| Entidade | Atributos | Relações |
|---|---|---|
| Category | nome, cor, ícone, isDefault, ordem | 1:N Transaction |
| RecurringTransaction | nome, valorBaseCents, categoryId, tipo, frequência (semanal/mensal/anual/intervalo), intervalo, diaVencimento, inicio, fim?, favorito | 1:N Transaction |
| Transaction | nome, valorPrevistoCents, vencimento, categoryId, tipo (fixo/variável/pontual), favorito, observação, canceladaEm?, recurringId?, occurrenceDate?, overridden | N:1 Category, N:1 Recurring, 1:N Payment, 1:N Attachment |
| Payment | transactionId, valorCents, pagoEm, observação | N:1 Transaction, 0..1 Attachment |
| Attachment | ownerType, ownerId, caminhoLocal, nomeOriginal, mime, hash, driveFileId?, uploadStatus | polimórfico |
| Income | anoMes, tipo (salário/extra/outras), valorCents, descrição, recebida | por mês |
| Investment | anoMes, valorPlanejadoCents, valorRealizadoCents, data, descrição | por mês |
| Planning | salárioPadrão, rendaExtraPadrão, metaEconomiaPadrão, investimentoPadrão (centavos) | singleton |
| MonthConfiguration | anoMes, overrides nuláveis (salário, extra, meta, investimento) | 0..1 por mês |
| SyncMetadata | deviceId, últimoSync, cursor remoto, estado | singleton |
| SyncConflict | entidade, recordId, versãoLocal, versãoRemota, resolvidoEm? | — |

## Regras de negócio
1. `valorPago = Σ Payment ativos`; `valorRestante = max(previsto − pago, 0)`; `excedente = max(pago − previsto, 0)` (registrado, nunca truncado).
2. **Status derivado** (ordem de avaliação):
   1. `cancelada` se `canceladaEm != null`
   2. `paga` se `previsto > 0` e `pago ≥ previsto`
   3. `vencida` se `restante > 0` e `vencimento < hoje` (parcialmente paga e vencida mostra os dois fatos)
   4. `parcialmentePaga` se `0 < pago < previsto`
   5. `pendente` se vencimento dentro da janela (30 dias)
   6. `prevista` caso contrário
3. Excluir pagamento recalcula o status. Histórico de pagamentos nunca é apagado ao marcar como pago.
4. Mês sem `MonthConfiguration` herda `Planning`. Override nulo = herdar; zero = zero explícito.
5. Vencimento dia 31 em mês curto → último dia do mês.
6. Exclusão de recorrência: só esta / esta e próximas (define `fim`) / toda a regra (ocorrências passadas permanecem). Nada do passado é apagado silenciosamente.
7. Duplicar cria nova entidade com novo id, sem vínculo de recorrência.

## Exemplo
Transaction{previsto=100000, vencimento=2026-10-15}; Payment{40000} → pago=40000, restante=60000, status=parcialmentePaga (ou vencida após 15/10).

## Abas da tela de Contas (Fase 3)
- **Pendentes**: há valor restante, não cancelada e **não vencida** (inclui parcialmente paga no prazo e vence hoje).
- **Pagas**: totalmente paga.
- **Vencidas**: vencida, inclusive parcialmente paga (mostra o status "Vencida" e o percentual pago).
- **Todas**: tudo, inclusive canceladas.
Toda conta ativa aparece em exatamente uma entre Pendentes, Pagas e Vencidas. "Vence hoje" não é vencida.
