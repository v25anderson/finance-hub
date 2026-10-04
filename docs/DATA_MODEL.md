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

## Calendário (Fase 6)
- Cada conta ativa e não cancelada aparece no dia do seu **vencimento** (`dueDate`), não da ocorrência na regra.
- Tom: paga → verde; com saldo e vencimento < hoje → vermelho; com saldo e vencimento em [hoje, hoje+7] → amarelo; demais → neutro. A hora do dia nunca altera o resultado.
- A grade só mostra dias do mês exibido (posições vazias nas pontas), para não sugerir "sem contas" em dias de outro mês.

## Projeção (Fase 7)
Por mês, a partir do mês atual (o atual conta como o 1º). Cada valor tem parte **real** e parte **projeção**:
| | real | projeção |
|---|---|---|
| renda | lançamentos de renda do mês | padrão ou valor personalizado do mês |
| gastos | pago (inclui excedente) | restante a pagar (contas e recorrências futuras já geradas) |
| investimentos | realizado | restante da meta do mês |
Saldo do mês = renda − gastos − investimentos (igual ao saldo projetado do dashboard). Total do período = soma dos saldos mensais (sem saldo de abertura). Meta de economia: diferença = saldo do mês − meta (positivo = acima); sem meta, não há diferença.
Personalização do mês: `MonthConfiguration` com 4 campos opcionais (nulo herda; zero é zero explícito).

## Análises (Fase 8)
Período: lista de meses `yyyy-MM` terminando, no máximo, no mês atual.
- **Gastos** = soma do valor **previsto** das contas com vencimento no mês, sem canceladas nem excluídas (inclui recorrências já geradas). Por categoria e por tipo (fixo/variável/pontual). **Média mensal** = total ÷ número de meses (meses sem gasto contam como zero).
- **Renda** = mesma regra do planejamento: (padrão ou valor do mês) + lançamentos de renda do mês. Os padrões valem também para meses passados sem personalização.
- **Investimentos**: planejado = meta do mês (valor do mês ou padrão); realizado = soma dos investimentos registrados no mês.
- **Taxa de poupança** = investimentos realizados ÷ renda, por mês e no período. Sem renda, é indefinida ("—"); pode passar de 100%.
- Categoria: parte = gasto da categoria ÷ gasto total; ordenadas do maior para o menor (desempate por id). A tela mostra as 8 maiores e agrupa o resto em "Outras".

## Exportação CSV (Fase 9)
Um arquivo por conjunto, UTF-8 com BOM, CRLF. Valores monetários em reais com duas casas (de centavos inteiros). Colunas:
- **contas**: id, nome, categoria, categoria_id, tipo (fixo/variavel/pontual), vencimento, valor_previsto, valor_pago, valor_restante, excedente, percentual_pago, status (prevista/pendente/parcialmente_paga/paga/vencida/cancelada), favorito, recorrente, recorrencia_id, data_ocorrencia, observacao, criado_em, atualizado_em, cancelada_em.
- **pagamentos**: id, conta_id, conta, valor, pago_em, observacao, criado_em.
- **categorias**: id, nome, padrao, ordem, cor.
- **recorrencias**: id, nome, categoria, categoria_id, tipo, frequencia (semanal/mensal/anual/dias), intervalo, primeiro_vencimento, fim, valor_base, favorito.
- **rendas**: id, mes, tipo, valor, descricao, recebida. **investimentos**: id, mes, planejado, realizado, descricao.
- **planejamento**: escopo (`padrao` ou `AAAA-MM`), salario_liquido, renda_extra, meta_economia, investimento_planejado. Campo vazio = herda o padrão; `0.00` = zero explícito.
- `excluido_em` é acrescentada a contas, pagamentos, recorrências, rendas e investimentos quando se inclui excluídos.
