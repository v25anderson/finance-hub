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
| 8 | Análises | ✅ (ver notas abaixo) |
| 9 | Exportação CSV (**marco MVP local**) | ✅ (ver notas abaixo) |
| 10 | Google Drive (backup manual; comprovantes ficam para depois) | ✅ (ver notas abaixo) |
| 11 | Sincronização bidirecional | ✅ (ver notas abaixo) |
| 12 | Testes de integração/golden e sync | ✅ (ver notas abaixo) |
| 13 | Android APK/AAB | ✅ (preparado; falta a chave de publicação e teste em aparelho real, ver notas) |
| 14 | Web | ✅ (ver notas abaixo) |
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

## Notas da Fase 8
- **Filtros**: 6, 12 e 24 meses (terminando no mês atual) e **Personalizado** (início e fim por mês e ano). O período nunca passa do mês atual: análise não mistura projeção. Fim antes do início leva o início junto; máximo de 60 meses.
- **Indicadores**: gastos e média mensal, renda, investido (realizado, com a meta ao lado) e taxa de poupança.
- **Gráficos** (um único eixo, sempre a partir de zero): evolução dos gastos (linha); gastos por categoria (barras horizontais); fixos × variáveis × pontuais (colunas empilhadas + totais e %); investimentos planejado × realizado (colunas agrupadas); renda (linha); taxa de poupança (linha).
- **Regras de visualização aplicadas**: sem donut (as fatias seriam parecidas), cores de status reservadas, 3 cores de série validadas para daltonismo nos dois temas, marcas finas (barra ≤ 24 px com 4 px na ponta, linha de 2 px, ponto final de 9 px com anel), espaço de 2 px entre trechos, legenda para 2 ou mais séries, rótulos em tinta de texto, **toque/arraste lê o mês** e **"ver como tabela"** em todo gráfico (acesso aos valores sem depender de cor ou toque).
- **Cores**: o verde-água do tema claro tem contraste de 2,74:1; a regra de compensação é atendida com valores visíveis na legenda e a visão em tabela.
- **Texto neutro**: o app diz explicitamente "Análise dos dados que você inseriu. Não é recomendação financeira." e não interpreta nem sugere nada.
- **Verificado**: analyze limpo; 308 testes (regras, repositório, funções de eixo e UI com números conferidos à mão); capturas conferidas no Chromium (desktop claro/escuro, celular, tabela).
- **Ainda não feito**: comparação entre dois períodos; exportação dos gráficos; zoom em um mês. Taxa de poupança só usa investimentos *realizados* (não considera saldo que sobrou em conta).
- **Bugs achados pelos testes e corrigidos**: a leitura do gráfico estourava a largura com fonte larga; "Personalizado" quebrava em duas linhas no celular.

## Notas da Fase 9
- **Onde**: Análises → "Exportar". Folha com formato, separador, conjuntos de dados e "Incluir itens excluídos".
- **Formato CSV** (UTF-8 com BOM, linhas CRLF, cabeçalho em português). Um arquivo por conjunto: contas, pagamentos, categorias, recorrências, rendas, investimentos, planejamento. Um conjunto → `.csv`; vários → `.zip` com os CSVs e um `LEIA-ME.txt`. Nome com a data (`finance_hub_AAAA-MM-DD.zip`).
- **Separador**: vírgula (decimal com ponto) ou ponto e vírgula (decimal com vírgula, abre direto no Excel pt-BR). Valores em reais com duas casas, calculados de centavos inteiros (sem ponto flutuante).
- **Status** da conta é o derivado na data da exportação; datas puras `AAAA-MM-DD`; carimbos em UTC ISO 8601.
- **Excluídos**: ficam de fora por padrão; com a opção ligada entram com a coluna `excluido_em`. Nada é alterado no banco ao exportar.
- **Segurança do CSV**: textos que começam com `= + - @` ou tab recebem `'` na frente (evita injeção de fórmula no Excel/Planilhas). Números negativos não são alterados.
- **Preparado para o futuro**: `DataExporter` por `ExportFormat` (JSON, Excel e PDF aparecem como "em breve" e são recusados pelo serviço); interface `DataImporter` reservada, sem implementação.
- **Verificado**: analyze limpo; 337 testes (escape e ida e volta com parser independente, valores, status, ordem determinística, ZIP, cancelamento, fluxo na tela); build web ok.
- **Ainda não feito / não verificado**: o seletor de arquivos real (`file_picker`) nunca rodou em um Android de verdade (só a compilação pelo GitHub Actions); sem importação; sem JSON/Excel/PDF; sem exportar um período específico.

## Notas da Fase 10
- **Escopo desta fase**: backup **manual** de todos os dados no Google Drive, listagem, restauração e exclusão de backups. Sincronização contínua é a Fase 11. **Comprovantes (anexos) não foram feitos**: o botão continua desabilitado e a tabela `attachments` entra no backup apenas como metadados.
- **Onde**: Análises → ícone de nuvem. Estados: não configurado → desconectado → conectando → conectado.
- **Acesso mínimo**: escopo `drive.file` (só a pasta "Finance Hub" e arquivos criados pelo app). Login pelo serviço do sistema (Play Services): o app não vê a senha e não grava token no banco.
- **Formato**: JSON único (`finance_hub_backup_AAAAMMDD_HHMMSS.json`, UTC) com versão do formato e do esquema, contagens e as 9 tabelas de dados (incluindo itens excluídos). Metadados de sincronização do aparelho ficam de fora. Nome único por segundo: um backup nunca sobrescreve outro; o app **nunca apaga backups sozinho**, só a pedido.
- **Restauração**: baixa e valida o arquivo antes de tocar no banco (recusa lixo, outro formato, versão mais nova), mostra contagens, exige confirmação, guarda uma cópia dos dados atuais em `safety/` no aparelho e então substitui tudo numa única transação (falha no meio = nada muda). O `deviceId` local é preservado.
- **Erros**: permissão expirada derruba a conexão com mensagem clara; sem rede, sem espaço e indisponibilidade têm texto próprio; mensagens nunca incluem trechos de resposta nem dados do usuário.
- **Configuração necessária**: veja `docs/GOOGLE_SETUP.md`. Sem o `GOOGLE_SERVER_CLIENT_ID` o recurso fica "não configurado".
- **Verificado**: analyze limpo; testes do formato, ida e volta, transação atômica, cliente REST (requisições conferidas com cliente HTTP simulado), serviço e fluxo na tela com Drive falso.
- **NÃO verificado**: o login Google e o Drive reais nunca foram exercitados (não há credenciais no ambiente nem Android físico). A forma exata das requisições segue a documentação da API v3 e foi conferida só contra um servidor simulado. Cópias de segurança em `safety/` não têm limpeza automática. Backup sem criptografia (previsto no roadmap de segurança).

## Notas da Fase 11
- **Escopo**: sincronização manual entre aparelhos via Drive, com merge de três vias por campo, conflitos decididos pelo usuário e tombstones. Detalhes e limites em `docs/SYNC.md`.
- **Esquema v3**: nova tabela `sync_base` (último estado sincronizado). Migração cria a tabela; nada mais muda. Ocorrências de recorrência passam a ter id determinístico (as já existentes mantêm o id antigo).
- **Onde**: tela "Backup e sincronização" (Análises → nuvem): "Sincronizar agora", estado e data da última sincronização, aviso e tela de conflitos (valores dos dois lados, "Manter este aparelho" / "Usar o outro").
- **Bug achado e corrigido pelos testes**: `insertOnConflictUpdate` do Drift ignora colunas nulas no UPDATE, então "restaurar uma conta excluída" não chegava ao outro aparelho; a aplicação passou a atualizar com `toCompanion(false)` (grava nulos).
- **Verificado**: testes puros do merge (todos os casos de base/local/remoto) e do formato; simulação de **dois aparelhos** com Drive em memória: criação, ausência de ping-pong, merge de campos diferentes, conflito + resolução nos dois sentidos, exclusão/restauração, pagamentos nos dois lados, seed sem conflito falso, recorrência gerada nos dois aparelhos sem duplicar, falha de envio com nova tentativa, arquivo de versão mais nova (nada aplicado), restauração reiniciando o histórico, seleção de arquivos com buracos; fluxo de tela com conflito.
- **NÃO verificado**: sincronização real entre dois aparelhos/contas Google (sem credenciais nem aparelhos aqui); comportamento do Drive real com consistência eventual, cotas e arquivos grandes; desempenho com milhares de registros (a leitura carrega as tabelas inteiras); uso concorrente real de dois aparelhos ao mesmo tempo.

## Notas da remodelagem visual 2 ("cinema")
- **Pedido**: mais memorável (Netflix/Airbnb), menos "cara de app Android", sem mexer na paleta de roxos. A navegação inferior era o ponto mais criticado.
- **Dock flutuante de vidro** (`AppDock`) no lugar da barra inferior: pílula com desfoque, só o item ativo mostra o rótulo, dentro de uma cápsula luminosa que anima a largura; o "+" fica dentro do dock (sem botão flutuante cobrindo valores). Rótulos curtos no dock (Início, Agenda, Plano); a barra lateral mantém os nomes completos. O conteúdo rola por baixo do vidro.
- **Cabeçalho "aurora"**: degradê da marca + halos de luz + anéis concêntricos (assinatura visual), número do mês em destaque e botão de alternar tema no próprio cabeçalho (antes só existia na barra lateral).
- **Prateleira "Próximas contas"** no início: carrossel horizontal de pôsteres coloridos pela categoria, com o dia em tamanho grande, "vence hoje/amanhã/em N dias" e valor restante; vencidas primeiro; toque abre os detalhes.
- **Cartões** com mais raio, sombra suave no claro e brilho sutil no topo no escuro; avatares de categoria em degradê.
- **Tema escuro passa a ser o padrão** (a identidade "cinema"); o botão no cabeçalho alterna. Antes o padrão seguia o sistema.
- **Bug achado**: `AnimatedSize` dentro de `FittedBox` (primeira versão do dock) re-sujava o layout; trocado por `AnimatedAlign` com `widthFactor`.
- **Testes**: navegação nos testes passou a usar chaves (`nav-<nome>`), porque os rótulos dos itens inativos não aparecem mais no dock; 394 testes passam.
- **Verificado**: capturas no Chromium (celular escuro/claro, Contas, Calendário, Análises, desktop escuro). **Não verificado**: em Android real (desfoque de vidro e desempenho do carrossel), com fonte muito ampliada no dock (ele reduz de escala em vez de quebrar), nem o toque de vibração (`HapticFeedback`).

## Notas dos ajustes de interface (após a remodelagem "cinema")
- **Filtros do detalhe do mês** (seta do cartão "Gastos do mês"): os chips viraram blocos com número grande, nome do estado e ponto na cor do estado (Pagas, Pendentes, Vencidas / Parcialmente pagas, Futuras). O selecionado ganha contorno e fundo tingidos.
- **Botões**: novo `AppButton` (principal com degradê e brilho, tonal e discreto) usado em Renda, Investimentos, Planejamento e Backup; o tema global também foi refeito (texto vira pílula suave, contornado ganha cor, preenchido ganha brilho). Em Renda e Investimentos os botões ficam empilhados em largura total (lado a lado cortavam o texto).
- **Luz de sincronização** (`SyncLight`/`SyncBadge`): ponto com brilho no ícone de nuvem de Análises e selo com texto na tela de backup. Cinza = desconectado ou não configurado, roxo = conectado, âmbar pulsando = sincronizando, verde = sincronizado, vermelho = falhou ou há conflito. Pulsa só quando o sistema não pede para reduzir movimento.
- **Drive não configurado** agora explica o motivo (falta o ID de cliente do Google na build) e mostra o botão "Conectar com Google" desligado, em vez de sumir. O login só passa a funcionar quando o `GOOGLE_SERVER_CLIENT_ID` for configurado (veja `docs/GOOGLE_SETUP.md`).
- **Ícone do app**: monograma "F" branco sobre o degradê da marca com os anéis do cabeçalho e um ponto verde-água; adaptativo no Android (fundo e primeiro plano separados) e também na web (favicon e PWA). Nome do app na web: "Finance Hub". Gerado por `flutter_launcher_icons` a partir de `assets/icon/`.
- **Não verificado**: o ícone no launcher de um Android real (só a imagem gerada foi conferida); a luz de sincronização com Drive real.

## Notas da Fase 12
- **Sincronização sob estresse** (`test/data/sync_stress_test.dart`): 3 aparelhos, 12 rodadas de operações aleatórias (criar, editar nome/valor/observação, excluir, favoritar, pagar) com sincronizações em ordem aleatória, 3 sementes. Depois de resolver os conflitos por uma política determinística, os três convergem ao **mesmo conteúdo**, sem conflito aberto nem nada pendente de envio. O teste prova que exercita de verdade o motor (≈200 aplicações, ≈20 merges, ≈5 conflitos por execução).
- **Desempenho medido** (memória, máquina do ambiente): 3.000 contas + 3.000 pagamentos → envio de 6.012 registros em ≈0,5 s e recebimento no outro aparelho em ≈1,3 s; segunda rodada sem mudanças não envia nada. Não substitui medir em um celular real.
- **Acessibilidade** (`test/features/accessibility_test.dart`): as 5 telas principais com fonte do sistema a 1,5× e 2× em celular de 360 px, com nomes longos. Achou e corrigiu **5 estouros de layout** (rótulos do cabeçalho, legenda do calendário, saldo projetado, valores padrão, percentuais das categorias). Também confere rótulo e papel de botão do dock para leitor de tela.
- **Golden** (`test/golden/`): 12 imagens (início claro/escuro e desktop, Contas, Agenda, Plano, Análises, detalhe do mês, backup, botões e luzes de sincronização). Carregam a fonte Inter e os ícones do SDK para ficarem legíveis. Regenerar: `flutter test --update-goldens test/golden`. Foram geradas no Linux; outra plataforma pode renderizar o texto de forma diferente.
- **Jornada de ponta a ponta** (`test/integration/journey_test.dart`): cadastrar pela tela → pagar parcialmente (fica "parcialmente paga", 30%) → dashboard (total, pago e pendente) → exportar ZIP e conferir o CSV (valores e status derivado) → conectar ao Drive, fazer backup e sincronizar → um segundo aparelho recebe conta e pagamento → apagar e restaurar o backup pela tela (cópia de segurança criada) → a conta volta parcialmente paga.
- **Total**: 423 testes. `pumpApp` do harness aceita `overrides`.
- **Não coberto**: execução em Android/iOS reais (integration_test em aparelho/emulador), Drive e login Google reais, toque físico/gestos nativos, leitor de tela real (TalkBack), goldens em outras plataformas.

## Notas da Fase 13
- **Problema encontrado**: o APK de teste era assinado com a chave de *debug* do Flutter, **que muda a cada execução do Actions**. Resultado: cada APK novo não instalava por cima do anterior (desinstalar apagaria os dados locais) e o SHA-1 para o login Google nunca seria estável.
- **Correção**: chave de teste **fixa** versionada de propósito em `android/app/test-signing.jks` (senha pública; NÃO serve para publicar). SHA-1 estável: `1F:AC:D2:4B:CF:3A:D1:16:7B:0F:6D:BB:2B:91:E0:63:44:AE:CD:51`. Quem tiver `android/key.properties` (ou os segredos no CI) assina com a chave real.
- **CI**: gera APK e **AAB**; `versionCode` = número da execução (o APK novo atualiza o instalado); imprime o SHA-1 do APK no resumo; decodifica a chave de publicação quando os segredos existem.
- **Abertura escura**: o fundo da janela de abertura passou de branco para o escuro do app (sem clarão branco antes do primeiro quadro). Descrição do pacote corrigida.
- **Verificado**: o Actions compilou, assinou e publicou o APK e o AAB com a nova configuração.
- **NÃO verificado / pendente**: o app **nunca foi aberto em um Android real**; a chave de publicação **não existe** (você precisa gerar); o ID do app (`com.financehub.finance_hub`) precisa ser confirmado antes de publicar (não muda depois); o primeiro APK com a chave fixa exige desinstalar o antigo uma vez. Passo a passo em `docs/RELEASE.md`.

## Notas da Fase 14
- **Achado importante**: o service worker do Flutter 3.47 é um *stub que se desregistra*; ou seja, **o app web nunca abriu offline**, apesar do princípio offline-first. Foi escrito um service worker próprio (`web/sw.js`, cache por versão do build, sem `skipWaiting`) com bootstrap próprio (`web/flutter_bootstrap.js`).
- **Achado de privacidade**: o plugin de login do Google carrega `accounts.google.com/gsi/client` **a cada abertura na web**, mesmo sem ninguém conectar (o Drive nem existe na web). Corrigido com uma **Content-Security-Policy** no `index.html` (o app web só fala com o próprio site); o navegador agora recusa o script. Isso também protege contra injeção de scripts.
- **Armazenamento persistente**: o app pede `navigator.storage.persist()` para o navegador não apagar o IndexedDB quando faltar espaço.
- **Mensagem por plataforma**: na web e no desktop a tela de backup diz "Disponível só no aplicativo para celular" (antes dizia que faltava configuração, o que era enganoso); a luz mostra "Indisponível nesta plataforma".
- **Pacote**: título e nome "Finance Hub", tela de carregamento escura, `theme-color`, ícones do app; workflow `Web` gera o pacote (`finance-hub-web`) com `base_href` opcional. Hospedagem e limites em `docs/WEB.md`.
- **Verificado no Chromium**: título, abertura offline com o app completo e dados, download do ZIP de exportação, service worker ativo com cache por versão, nenhuma requisição externa permitida, app funcionando com a CSP.
- **NÃO verificado**: Safari e Firefox, instalação como PWA, hospedagem real em HTTPS, cabeçalhos COOP/COEP, atualização real de versão com o cache antigo.

## Notas: faixa de valor para gastos variáveis (pedido do usuário)
- **Pedido**: ao marcar uma conta como variável, poder informar uma faixa (ex.: energia entre R$ 200 e R$ 300).
- **Feito**: formulário com a opção "Informar faixa de valor" (só em Variável) com mínimo e máximo; valor esperado em branco = meio da faixa; validações (mínimo positivo, máximo ≥ mínimo, esperado dentro da faixa); faixa na lista, no detalhe e como "Faixa informada" no cabeçalho e no detalhe do mês; recorrências carregam a faixa; exportação, backup e sincronização incluem. Detalhes em `docs/DATA_MODEL.md`.
- **Decisão de produto** (D73): a faixa **não** substitui o valor esperado; totais, status e projeções seguem usando um número só, para não misturar informação do usuário com estimativa do app. A faixa total do mês é apenas a soma das faixas informadas.
- **Ainda não**: o planejamento/projeções não usam a faixa (não mostram cenário mínimo/máximo); não há aviso quando o valor pago sai da faixa além do texto descritivo no detalhe; alertas de conta variável fora da faixa não existem (seriam julgamento).
- **Verificado**: 457 testes (domínio, regras, recorrência, sincronização com valores nulos, backup, exportação, fluxos de tela, dashboard) e 3 goldens novos; migração v1→v4 de um banco antigo.
- Além disso: corrigido um texto antigo no detalhe da conta ("Comprovantes chegam na Fase 10"); `BillService.create` agora devolve erros de validação como `Future` (antes lançava de forma síncrona).
