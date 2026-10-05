# TESTING

`flutter analyze` limpo e `flutter test` verde são condição de cada fase. O workflow do GitHub Actions roda os dois antes de gerar o APK.

| Camada | Onde | O que prova |
|---|---|---|
| Domínio puro | `test/domain/` | Regras de negócio (status derivado, recorrência, projeção, análises, merge de sincronização, exportação) sem banco nem UI |
| Dados | `test/data/` | Repositórios e serviços com banco em memória (e em arquivo real para migração); backup/restauração; Drive REST com cliente HTTP simulado; sincronização entre aparelhos simulados |
| Estresse de sincronização | `test/data/sync_stress_test.dart` | Convergência de 3 aparelhos com operações aleatórias; desempenho com milhares de registros |
| Fluxos de tela | `test/features/` | Telas reais com dados reais, relógio fixo (10/10/2026 12:00) e animações desligadas |
| Acessibilidade | `test/features/accessibility_test.dart` | Sem estouro de layout com fonte 1,5× e 2×; rótulos do dock |
| Golden | `test/golden/` | Aparência das telas principais; regenerar com `flutter test --update-goldens test/golden` |
| Jornada | `test/integration/journey_test.dart` | O caminho completo de um usuário, atravessando todas as camadas |

## Convenções e armadilhas
- Nos testes o Flutter usa a fonte **Ahem** (blocos, mais larga que a Inter): testes de layout ficam mais rigorosos. Só os goldens carregam a Inter e os ícones.
- `appTest`/`pumpApp` montam o app com banco em memória. Duas escritas na mesma `runAsync` com streams do Drift ativas travam: use `seed:` (antes de montar o app) ou chamadas `h.run` separadas.
- Navegação nos testes por chave: `Key('nav-<Rótulo>')`.
- Vários bancos no mesmo teste: `driftRuntimeOptions.dontWarnAboutMultipleDatabases = true`.
- Fakes compartilhados em `test/support/` (Drive, autenticação, transporte de sincronização, parser CSV independente).

## O que os testes não cobrem
Aparelho Android real, Google Drive e login reais, TalkBack, desempenho em celular e goldens em outras plataformas.
