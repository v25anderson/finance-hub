# DECISIONS (ADR resumido)

Formato: **ID — decisão** · contexto · alternativa descartada.

| ID | Decisão | Motivo | Alternativa descartada |
|----|---------|--------|------------------------|
| D01 | Local-first: SQLite no dispositivo é a fonte da verdade | Funciona offline, sem custo, dados do usuário | Firebase/Supabase (custo, dependência, privacidade) |
| D02 | Persistência: **Drift sobre SQLite** | Agregações por mês/categoria, migrações, ACID, arquivo único portável, Web via wasm | Isar (manutenção incerta), Hive (sem consultas), JSON (frágil), SharedPrefs (inadequado) |
| D03 | Dinheiro em **centavos inteiros** (`int`) | Evita erro de ponto flutuante | `double` |
| D04 | **Status da conta é derivado**, nunca persistido | Elimina inconsistência entre pagamentos e status | Coluna `status` mutável |
| D05 | Recorrência = regra + ocorrências **materializadas** | Preserva histórico e edições por ocorrência | Cálculo virtual sem persistir |
| D06 | Estado: **Riverpod** | Testável, sem BuildContext | Provider/ChangeNotifier, Bloc |
| D07 | Drive com escopo `drive.file`; app cria a pasta `FinanceHub/` | Escopo não sensível, sem verificação pesada | Escopo `drive` completo (restrito) |
| D08 | Sync por **log de mudanças por registro** + tombstones + conflito por campo | Nunca sobrescreve; nunca apaga dado em conflito | Último-escreve-vence sobre arquivo único |
| D09 | Moeda BRL / pt-BR fixa no MVP, arquitetura preparada | Simplicidade | i18n completo agora |
| D10 | "Saldo atual" = renda − pagos (sem contas bancárias) | MVP | Contas bancárias com saldo real |
| D11 | Janela "pendente" = 30 dias; "vence em breve" (amarelo) = 7 dias, ambas configuráveis | Regras claras | — |
| D12 | Soft delete + lixeira (restauração por 30 dias) | Nunca perder histórico | Exclusão física |
| D13 | Gráficos próprios com `CustomPaint` no início; avaliar `fl_chart` se necessário | Menos dependências | `fl_chart` desde o início |
| D14 | Sem `go_router` no MVP (navegação por shell + sheets) | Menos dependências | `go_router` |
| D15 | Material 3 só como infraestrutura; identidade visual própria via tokens | Requisito do produto | Tema M3 padrão |
| D16 | Datas de vencimento como texto ISO `yyyy-MM-dd`; instantes em UTC como texto | Sem erro de fuso; ordenação lexicográfica correta | Unix timestamp para tudo |
| D17 | Categorias padrão com ids estáveis (`cat-*`) | Não duplicam entre dispositivos na sincronização | UUID aleatório por dispositivo |
| D18 | Código gerado do Drift versionado; Web com `--no-web-resources-cdn` | Build reproduzível e app Web 100% offline | Gerar no CI; CanvasKit via CDN |
| D19 | "Marcar como pago" registra o **valor restante** como um novo pagamento (nunca zera nem apaga os anteriores) | Preserva o histórico | Sobrescrever o valor pago |
| D20 | Valor da conta exige > 0 na UI/serviço; pagamento acima do restante é aceito e vira excedente | Evita contas vazias sem perder dinheiro registrado | Truncar o pagamento |
| D21 | Ações principais de pagamento ficam no topo do detalhe; secundárias abaixo | Visíveis sem rolar no celular | Todas as ações no rodapé |
| D22 | Comparação mensal só com números, cores neutras e sem texto interpretativo | Requisito: não gerar conclusões subjetivas | Verde/vermelho para queda/alta |
| D23 | Faixas de alerta exclusivas (hoje, amanhã, 2–7 dias, 8–30 dias) | Evita o mesmo vencimento em várias mensagens | Faixas cumulativas |
| D24 | Investimento realizado = lançamentos registrados; meta vem do planejamento | Separa expectativa de fato | Um único campo |
| D25 | "Marcar meta como realizada" registra o restante da meta como um lançamento | Mesmo padrão de "marcar como pago": preserva histórico | Sobrescrever o realizado |
| D26 | Índice único (regra, data) e geração idempotente; ocorrência excluída permanece como tombstone | Concorrência segura e "excluir não recria" | Gerar sem unicidade e deduplicar depois |
| D27 | Exclusão em lote preserva passado e contas com pagamento, e informa o que manteve | Requisito: nunca apagar histórico em silêncio | Apagar tudo da regra |
| D28 | "Esta e as próximas" não muda o vencimento nem as ocorrências editadas à mão/pagas | Evita sobrescrever decisões do usuário | Reescrever todas as futuras |
| D29 | APK via GitHub Actions (chave de debug do Flutter), pois o ambiente não alcança o Android SDK | Entrega testável sem custo | Instalar o SDK localmente (bloqueado pela rede) |
| D30 | Calendário: contas dentro do dia em telas largas; pontos + lista do dia no celular | Células estreitas não comportam nome e valor | Sempre chips (ilegível no celular) |
| D31 | Cores do calendário sempre acompanhadas de ícone, legenda e rótulo de acessibilidade | Cor nunca sozinha | Apenas cor |
| D32 | Canceladas e dias de outros meses não aparecem no calendário | Evita ruído e leitura enganosa | Mostrar riscadas / dias adjacentes |
| D33 | Manter Flutter e redesenhar a identidade visual em vez de migrar para Kotlin | O Flutter desenha os próprios pixels (o visual é decisão de design); Kotlin perderia a Web, exigiria reescrever tudo e não pode ser compilado no ambiente de desenvolvimento | Migrar para Jetpack Compose |
| D34 | Inter embutida como fonte única; sem fontes baixadas em execução | Funciona offline e é consistente entre plataformas | `google_fonts` (rede em execução) |
| D35 | Componentes de navegação, segmentados e chips próprios; Material só como infraestrutura (diálogos, foco, acessibilidade) | Identidade própria sem perder acessibilidade | Tema padrão do Material |
| D36 | Todo movimento respeita "reduzir movimento" do sistema | Acessibilidade e testes determinísticos | Animações sempre ligadas |
| D37 | Faixas de projeção contam o mês atual (1, 3, 6, 12 meses) | O enunciado é ambíguo ("próximos 3 meses"); contar o atual mantém "mês atual" como a faixa de 1 | Atual + N seguintes |
| D38 | Sólido = dado real, hachurado = projeção, em barras, tabelas e selos | Requisito: nunca misturar os dois | Mesma cor para ambos |
| D39 | Meta de economia mostrada como diferença factual, sem recomendação | Análise dos dados, não conselho financeiro | Alertas "você deveria…" |
| D40 | Sem saldo de abertura nas projeções | MVP: não há contas bancárias com saldo (D10) | Saldo acumulado entre meses |
| D41 | Análises só até o mês atual; sem projeção no período | Real e projeção nunca se misturam (projeção fica no Planejamento) | Permitir meses futuros nas análises |
| D42 | Gastos das análises = valor previsto das contas do mês | Mesma base do dashboard e da comparação mensal; não depende de pagamento | Somar só o que foi pago |
| D43 | Categorias em barras horizontais, não em donut | Valores próximos e muitas categorias: barras comparam melhor | Donut / pizza |
| D44 | Cores de série fixas e validadas (3 séries); série única usa a cor de destaque; status reservado | Acessibilidade para daltonismo e significado consistente | Cores geradas por gráfico |
| D45 | Todo gráfico tem leitura por toque e visão em tabela | Valores acessíveis sem depender de cor ou gesto | Só o desenho |
| D46 | `file_picker` para salvar e `archive` para ZIP | Salvar onde o usuário escolher, em Android/Web/Desktop, sem permissões amplas; ZIP puro em Dart | `share_plus` (envia para apps), escrever em pasta fixa |
| D47 | Um CSV por conjunto de dados; vários viram ZIP com LEIA-ME | CSV é tabular: misturar entidades num arquivo perde estrutura | Um CSV gigante |
| D48 | Separador escolhível (vírgula/ponto e vírgula); BOM UTF-8; reais com duas casas a partir de centavos | Excel pt-BR exige `;` e BOM para acentos; sem erro de ponto flutuante | Só vírgula; valores em centavos |
| D49 | Neutralizar injeção de fórmula em textos, não em números | Planilhas executam `=…` vindo de nomes digitados; números negativos devem continuar números | Não tratar; aspas em tudo |
| D50 | `DataExporter` por formato e `DataImporter` reservado, sem implementação | JSON/Excel/PDF e importação futura entram sem mexer no resto; sem código especulativo | Implementar já |
| D51 | `google_sign_in` + REST do Drive v3 com `http`, sem `googleapis` | O token fica com o serviço do sistema; poucas chamadas (listar, enviar, baixar, excluir) não justificam um SDK enorme | `googleapis` + `extension_google_sign_in_as_googleapis_auth` |
| D52 | Backup = um JSON com todas as tabelas de dados, versão de formato e de esquema | Simples de validar, de restaurar atomicamente e de evoluir; base para os snapshots da Fase 11 | Um arquivo por tabela; cópia do arquivo SQLite |
| D53 | Restauração substitui tudo, exige confirmação e guarda cópia local antes | É destrutiva; o usuário precisa poder voltar atrás | Mesclar na restauração (vira sincronização, Fase 11) |
| D54 | O app nunca apaga backups do Drive sozinho | "Nunca apagar histórico em silêncio" | Retenção automática dos N últimos |
| D55 | ID do cliente OAuth passado por `--dart-define`, não versionado; sem ele o recurso fica "não configurado" | Não há credenciais no repositório; o app continua útil sem Drive | Credenciais embutidas |
| D56 | Comprovantes (anexos) adiados | Escopo grande (seleção de arquivo, cópia local, hash, envio); backup de dados primeiro | Fazer tudo na Fase 10 |
| D57 | Sincronização por estado completo do registro + base local (merge de três vias), não log de operações | Idempotente, tolera reenvio e perda de arquivo, e permite conflito por campo sem relógio sincronizado | Log de operações; último-escreve-ganha |
| D58 | Conflito nunca é resolvido em silêncio: o registro fica como está, não é enviado e o usuário escolhe | "Nada é descartado automaticamente" | Vence o mais recente |
| D59 | Ocorrências de recorrência com id determinístico (UUID v5 de regra + data) | Dois aparelhos que geram a mesma ocorrência produzem o mesmo registro, sem duplicar nem violar o índice único | Deduplicar depois; só um aparelho gera |
| D60 | Arquivos de mudanças em conjunto plano `changes_<aparelho>_<n>.json`; leitura em sequência sem buracos | Sem pasta por aparelho; evita pular dados com listagem atrasada | Pasta por aparelho; ler tudo acima do cursor |
| D61 | Sincronização manual, sem segundo plano | Previsível, sem consumo escondido; background exige permissões e agendamento por plataforma | Sincronização automática |
| D62 | Registro local nunca editado e sem base adota o remoto (seed) | Evita conflito falso em categorias padrão e singletons criados em cada aparelho | Conflito sempre |
| D63 | Dock flutuante de vidro com cápsula ativa e "+" embutido, em vez de barra inferior fixa | Visual próprio e memorável; libera o canto da tela (sem FAB cobrindo valores) | Barra inferior Material; FAB separado |
| D64 | Tema escuro como padrão, com alternância no cabeçalho | Identidade "cinema" e contraste dos pôsteres; o usuário escolhe | Seguir o sistema |
| D65 | Navegação nos testes por chave (`nav-<nome>`), não por texto | Rótulos de itens inativos não existem mais no dock | Manter rótulos invisíveis na árvore |
| D66 | Filtros de estado em blocos com contagem (não chips com "(n)" no texto) | Leitura rápida, mais organizado e com cor de estado | Chips em linha |
| D67 | `AppButton` com três ênfases e tema global de botões em pílula | Consistência e hierarquia clara entre ação principal, secundária e discreta | Botões padrão do Material |
| D68 | Serviço indisponível mostra o motivo e o botão desligado, não some | O usuário vê o que existe e por que não funciona | Esconder a opção |
| D69 | Chave de teste fixa e versionada para os APKs de teste; chave real só por `key.properties` ou segredos do CI | A chave de debug do runner muda a cada execução (APK não atualiza e SHA-1 instável); a chave de teste é pública de propósito e nunca publica | Chave de debug do CI; chave real no repositório |
| D70 | Service worker próprio com cache por versão e sem `skipWaiting` | O do Flutter 3.47 só se desregistra; evita misturar arquivos de versões diferentes | Sem offline na web; precache fixo |
| D71 | Content-Security-Policy no `index.html` (app web só fala com o próprio site) | O plugin do Google contatava `accounts.google.com` a cada abertura; princípio de privacidade | Aceitar a requisição; remover o plugin da web (não é possível por plataforma) |
| D72 | Pedir armazenamento persistente ao navegador | App local-first: o IndexedDB não deve ser descartado por falta de espaço | Não pedir |
