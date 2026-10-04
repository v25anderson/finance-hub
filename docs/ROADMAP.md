# ROADMAP

Uma fase só é concluída com: `flutter analyze` limpo, testes passando, build validado e docs atualizadas.

| Fase | Escopo | Estado |
|------|--------|--------|
| 0 | Arquitetura e especificação (docs) | ✅ |
| 1 | Projeto Flutter + design system + shell adaptativo | ✅ (analyze, 7 testes e build web OK; build Android pendente: sem Android SDK no ambiente) |
| 2 | Persistência local (Drift, schema, migrações, repositórios) | ⏳ |
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
