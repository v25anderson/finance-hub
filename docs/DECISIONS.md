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
