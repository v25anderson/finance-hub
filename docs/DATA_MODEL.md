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

## Cálculos do dashboard (Fase 4)
Contas **canceladas** ficam fora de todos os valores.
- **Gastos do mês** = soma dos valores previstos. **Pago** = por conta, o menor entre pago e previsto. **Pendente** = soma do restante. Invariante: `pago + pendente = gastos`. **Excedente** (pago além do previsto) é mostrado à parte e conta como saída real de caixa no saldo.
- **% quitado** = pago ÷ gastos; mês sem gastos = 0%.
- **Comparação**: variação absoluta e percentual do total previsto contra o mês anterior. Se o mês anterior não tem gastos, o percentual é indefinido (não exibido). Principais categorias = maiores variações absolutas (desempate por id). Sem juízo de valor (sem cores de bom/ruim).
- **Renda do mês**: salário = (override do mês ?? padrão) + lançamentos de salário; renda extra = (override ?? padrão) + lançamentos de extra; outras = lançamentos de outras. Override nulo herda; zero é zero explícito.
- **Investimento**: meta = override ?? padrão; realizado = soma dos investimentos registrados; % = realizado ÷ meta (pode passar de 100%); diferença = meta − realizado; projeção do mês = máx(meta, realizado).
- **Saldos** (nunca misturados): *atual* = renda − pagos (caixa) − investimentos realizados; *após contas* = atual − pendentes; *projetado / após investimentos planejados* = renda − pagos − pendentes − max(meta, realizado).
- **Alertas** (a partir de hoje, independem do mês exibido; só contas com saldo a pagar): vencidas; vencem hoje; vencem amanhã; vencem em 2–7 dias ("esta semana"); vencem em 8–30 dias. Faixas exclusivas, cada conta cai em uma só.

## Recorrência (Fase 5)
- **Regra**: frequência (semanal/mensal/anual/personalizado = a cada N dias), intervalo, primeiro vencimento (ancora o dia), fim opcional, dados-base (nome, valor, categoria, tipo, favorito).
- **Ocorrência**: um `Transaction` com `recurringId` e `occurrenceDate` (a data na regra; `dueDate` pode divergir se editada só nela). Único por (regra, `occurrenceDate`), inclusive excluídas (tombstone): excluir não recria.
- **Geração**: do início da regra até hoje + 12 meses (e até o mês navegado); idempotente.
- **Valor**: cada ocorrência guarda o próprio valor previsto, então mudar o preço daqui para frente nunca reescreve o passado.
- **Edição "esta e as próximas"**: atualiza a regra e as ocorrências posteriores **não editadas à mão, não canceladas e sem pagamento**.
- **Exclusão** (nunca apaga histórico em silêncio): apenas esta · esta e as próximas (fim da regra = dia anterior; se for a primeira, a regra é excluída) · toda (futuras sem pagamento; passadas e com pagamento ficam; regra excluída).
