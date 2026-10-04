# ROADMAP

Uma fase só é concluída com: `flutter analyze` limpo, testes passando, build validado e docs atualizadas.

| Fase | Escopo | Estado |
|------|--------|--------|
| 0 | Arquitetura e especificação (docs) | ✅ |
| 1 | Projeto Flutter + design system + shell adaptativo | ✅ (analyze, 7 testes e build web OK; build Android pendente: sem Android SDK no ambiente) |
| 2 | Persistência local (Drift, schema, migrações, repositórios) | ✅ (ver notas abaixo) |
| 3 | Contas e pagamentos (regras de domínio + UI) | ⏳ |
| 4 | Dashboard | ⏳ |
| 5 | Recorrências | ⏳ |
| 6 | Calendário | ⏳ |
| 7 | Planejamento e projeções | ⏳ |
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
