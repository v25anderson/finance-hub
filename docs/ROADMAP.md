# ROADMAP

Uma fase só é concluída com: `flutter analyze` limpo, testes passando, build validado e docs atualizadas.

| Fase | Escopo | Estado |
|------|--------|--------|
| 0 | Arquitetura e especificação (docs) | ✅ |
| 1 | Projeto Flutter + design system + shell adaptativo | ✅ (analyze, 7 testes e build web OK; build Android pendente: sem Android SDK no ambiente) |
| 2 | Persistência local (Drift, schema, migrações, repositórios) | ✅ (ver notas abaixo) |
| 3 | Contas e pagamentos (regras de domínio + UI) | ✅ (ver notas abaixo) |
| 4 | Dashboard | ✅ (ver notas abaixo) |
| 5 | Recorrências | ✅ (ver notas abaixo) |
| 6 | Calendário | ✅ (ver notas abaixo) |
| 6.5 | Redesign visual (identidade própria, sem a cara padrão do Material) | ✅ (ver notas abaixo) |
| 7 | Planejamento e projeções | ✅ (ver notas abaixo) |
| 8 | Análises | ⏳ |
| 9 | Exportação CSV (**marco MVP local**) | ⏳ |
| 10 | Google Drive (backup, comprovantes) | ⏳ |
| 11 | Sincronização bidirecional | ⏳ |
| 12 | Testes de integração/golden e sync | ⏳ |
| 13 | Android APK/AAB | ⏳ |
| 14 | Web | ⏳ |
| 15 | Polimento final | ⏳ |

Testes de domínio são escritos **junto** de cada fase (3, 5, 7), não só na 12.

## Notas da Fase 2
- Schema v1 com as 11 entidades; seed idempotente (11 categorias com ids estáveis, `Planning`, `SyncMetadata` com `deviceId`).
- Repositórios: categorias, lançamentos + pagamentos, planejamento, mês personalizado, rendas e investimentos. Toda escrita atualiza `updatedAt`, `version` e `deviceId`; exclusões são soft delete.
- Verificado: testes com banco em memória e em arquivo real (com reabertura) e persistência no Chromium (recarregar a página mantém os dados).
- **Ainda não feito**: mapeamento para entidades de domínio puras (Fase 3, junto das regras de status); geração de ocorrências recorrentes (Fase 5); testes de migração (só existe a v1); validação em dispositivo/emulador Android (sem Android SDK no ambiente).
- Repositórios retornam as classes de linha do Drift por enquanto; a UI não deve depender delas diretamente a partir da Fase 3.

## Notas da Fase 3
- **Domínio puro** (`lib/domain/bill.dart`, `bill_filters.dart`): `Bill`/`Payment`, valores previsto/pago/restante/excedente e status derivado, sem Flutter nem banco.
- **Camadas**: `BillRepository` (leitura mapeada para o domínio, reativa) e `BillService` (criar, editar, duplicar, favoritar, excluir/restaurar, pagamento parcial, marcar como pago, excluir pagamento).
- **UI**: lista com abas (Pendentes/Pagas/Vencidas/Todas) + filtro de favoritos, seletor de período (mês/ano, meses futuros), cadastro rápido, detalhe (bottom sheet no celular, painel lateral no desktop), diálogos de pagamento, histórico de pagamentos, exclusão com desfazer.
- **Verificado**: analyze limpo; 97 testes (domínio, dados e fluxos de UI com banco em memória); build Web; fluxo criar → listar → abrir detalhe no Chromium real (celular, 390 px).
- **Ainda não feito (por design)**: recorrência no formulário (campo desabilitado; Fase 5); "Excluir esta/próximas/toda a recorrência" (Fase 5); anexar comprovante (botão desabilitado; Fase 10); cancelar conta pela UI (existe no repositório, sem botão); painel lateral do desktop validado só por teste de widget, não por captura de tela.

## Notas da Fase 4
- **Regras puras em `lib/domain`**: `month_summary` (totais, listas por estado, distribuição por categoria), `month_comparison`, `month_plan` (renda e investimento do mês: padrão, override e lançamentos), `balance` (três saldos) e `alerts` (faixas de vencimento).
- **Dashboard**: KPI "Gastos do mês" clicável (abre detalhe com Pagas/Pendentes/Vencidas/Parcialmente pagas/Futuras e distribuição por categoria), comparação neutra com o mês anterior, "Quanto sobra", renda, investimentos e alertas. Duas colunas a partir de 880 px de conteúdo; no celular os alertas vêm primeiro.
- **Ações no dashboard**: adicionar renda do mês, definir valores padrão (salário, extra, investimento), registrar investimento realizado e "marcar meta como realizada".
- **Verificado**: analyze limpo; 147 testes (domínio, dados e UI); build Web; dashboard conferido no Chromium real em celular claro/escuro e desktop, inclusive o detalhe do KPI.
- **Ainda não feito (por design)**: edição completa do planejamento e a personalização mensal pela UI (Fase 7; hoje a personalização existe no repositório e é lida pelo dashboard, mas sem tela); projeções (Fase 7); alerta que abre a aba/estado correspondente em Contas (hoje só abre a aba Contas).
- **Limitação conhecida**: os alertas leem todas as contas em aberto até 30 dias à frente (inclusive vencidas antigas) e filtram em memória; adequado ao volume pessoal, a otimizar com SQL se necessário.
- **Lição de teste**: com streams do Drift ativas, duas escritas dentro de um mesmo `runAsync` travam o teste; `Harness.run` esvazia a zona de relógio falso após cada operação.

## Notas da Fase 5
- **Regra e geração** (`lib/domain/recurrence.dart`): semanal, mensal, anual e "a cada N dias"; a k-ésima data é sempre calculada a partir do início (31/01 → 28/02 → 31/03; 29/02 em ano não bissexto vira 28/02). Ocorrências são **materializadas** e geradas até 12 meses à frente, e sob demanda ao navegar para meses mais distantes.
- **Schema v2** (primeira migração real): índice único `(regra, data)` torna a geração idempotente. A migração não apaga dados: duplicatas eventuais só perdem o vínculo com a regra. Testada reabrindo um banco v1.
- **Edição**: "somente esta" (marca como editada à mão) ou "esta e as próximas" (atualiza a regra e as futuras que não foram editadas à mão nem têm pagamento; não permite mudar o vencimento).
- **Exclusão**: "apenas esta" (não é recriada), "esta e as próximas" (a regra termina antes) e "toda a recorrência" (remove futuras sem pagamento; **passado e contas com pagamento permanecem**). O app informa quantas foram excluídas e quantas mantidas.
- **Histórico de valores**: gráfico valor × tempo (degraus; tracejado = futuras previstas) e lista de mudanças como fatos, sem inferir motivo.
- **Verificado**: analyze limpo; 201 testes (datas, serviço, migração, UI); gráfico conferido no Chromium real.
- **Ainda não feito**: editar a frequência/intervalo de uma regra existente (excluir e recriar); desfazer exclusões em lote; ver/gerenciar regras numa lista própria.
- **APK**: o ambiente de desenvolvimento não alcança `dl.google.com` (Android SDK). Foi adicionado `.github/workflows/android-apk.yml` para o GitHub Actions gerar o APK (artefato `finance-hub-apk`).

## Notas da Fase 6
- **Regras puras** (`lib/domain/calendar.dart`): tom de cada vencimento e grade do mês (domingo a sábado; vazios antes do dia 1 e depois do último dia; meses de 4, 5 e 6 semanas).
- **Cores** (sempre com ícone e legenda): verde = paga; vermelho = vencida com saldo (inclui parcialmente paga vencida); amarelo = em aberto vencendo hoje ou em até 7 dias; neutro = futuro. Canceladas não aparecem.
- **Telas largas (≥ 700 px)**: as contas aparecem dentro do dia (nome, valor, cor, ícone); mais de 3 no mesmo dia → "+N mais" abre a lista do dia. **Celular**: pontos coloridos (até 3 por dia) e a lista do dia selecionado logo abaixo (hoje por padrão; se o mês não tem hoje, o primeiro dia com contas). Tocar em uma conta abre o detalhe.
- **Verificado**: analyze limpo; 231 testes (regras, grade, UI em celular e desktop, recorrência nos meses futuros); capturas conferidas no Chromium (celular e desktop).
- **Bug encontrado e corrigido pelos testes**: pontos do mesmo dia e mesmo estado tinham a mesma chave (erro "Duplicate keys").
- **Ainda não feito**: arrastar uma conta para outro dia; criar conta tocando em um dia; dias de outros meses não são exibidos (decisão deliberada).

## Notas do Redesign visual (entre as Fases 6 e 7)
- **Motivação**: o visual padrão do Material (Roboto, barra inferior e botão flutuante padrão, chips e campos com contorno) parecia "nativo do Android". O Flutter desenha tudo por conta própria, então a aparência é 100% decisão de design.
- **Tipografia**: Inter embutida (pesos 400 a 800, licença OFL em `assets/fonts`), com algarismos tabulares nos valores.
- **Tema**: sem ondas de toque, botões em pílula, campos preenchidos e sem contorno, diálogos e sheets com cantos de 28, chaves e chips próprios, paleta nova (violeta de marca + neutros frios), claro e escuro refeitos.
- **Componentes próprios**: barra de navegação inferior, barra lateral, botão "+" com degradê, controle segmentado, chips de seleção, `Pressable` (feedback de toque por escala), cartões, itens de lista com avatar da categoria.
- **Dashboard**: cabeçalho de destaque em degradê com o seletor de período e o número do mês em tamanho grande (conta até o valor); cartões abaixo com entrada suave.
- **Movimento**: contagem de valores, barras que preenchem, entrada escalonada dos cartões e troca de telas com fade. Tudo respeita "reduzir movimento" do sistema (também usado nos testes).
- **Robustez de layout** (achada pelos testes com fonte larga e vale para fontes ampliadas): textos da barra lateral, do título de comparação, do chip de estado e da linha de valor das contas agora se adaptam ao espaço.
- **Verificado**: analyze limpo; 231 testes; capturas conferidas no Chromium (celular claro/escuro, desktop, formulário, detalhe).
- **Ainda não feito**: ícones personalizados (usa Material arredondado), ilustrações/estados vazios com arte, transições compartilhadas entre telas, tela de abertura.

## Notas da Fase 7
- **Planejamento**: valores padrão (salário líquido, renda extra, meta de economia, investimento) e **"Personalizar este mês"** por mês (switch). Campo vazio herda o padrão; zero é zero explícito; só o mês escolhido muda. Desligar o switch volta o mês aos padrões. Salvar tudo em branco é recusado com explicação.
- **Projeções** (`lib/domain/projection.dart`): a partir do **mês atual**, em 1, 3, 6 ou 12 meses (**o mês atual conta**: "3 meses" = atual + 2). Usa renda padrão/personalizada, contas recorrentes (geradas até o horizonte), contas já cadastradas e investimento planejado.
- **Real × projeção nunca misturados**: tabela com colunas "Dado real" e "Projeção"; barras com trecho **sólido = real** e **hachurado = projeção**; selos "Projeção" (só futuro) e "Real + projeção" (mês com algo já realizado); legenda fixa.
- **Barra de composição** de cada mês: gastos, investimentos e sobra. Com saldo negativo, um traço marca onde a renda termina.
- **Detalhe do mês**: tabela real/projeção, saldo, e a **meta de economia** como fato ("R$ X acima/abaixo da meta"), sem recomendação. Atalho "Editar planejamento deste mês".
- **Consistência**: o saldo projetado do mês é o mesmo do "Quanto sobra" do dashboard (teste dedicado).
- **Verificado**: analyze limpo; 261 testes (regras, UI e números conferidos à mão); capturas conferidas no Chromium (celular e desktop).
- **Ainda não feito**: saldo inicial/acumulado entre meses (a soma do período é a soma dos saldos mensais, sem saldo de abertura); gráfico de linha da evolução; copiar o planejamento de um mês para vários.
- **Bug achado pelos testes**: `SwitchListTile` dentro de cartão colorido exige `Material` próprio (asserção do Flutter).
