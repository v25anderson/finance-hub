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
