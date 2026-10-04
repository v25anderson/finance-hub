# ARCHITECTURE

## Princípios
Local-first · offline-first · sem backend próprio · Drive opcional · dados do usuário · preparado para IA futura (via exportação, sob demanda).

## Camadas
```
UI (widgets, tema, layouts adaptativos)
  ↓ Riverpod
Application (casos de uso)
  ↓
Domain (entidades puras + regras)   ← sem Flutter, 100% testável
  ↑ interfaces (Repository, SyncGateway, FileStore, Exporter, ReminderScheduler)
Data (Drift/SQLite, arquivos, Drive, CSV)
```

## Persistência (D02)
Comparação resumida: SQLite/Drift atende consultas e agregações, ACID, migrações, arquivo único para backup e Web via wasm. Isar tem manutenção incerta; Hive não consulta; JSON é frágil e não escala para sync granular; SharedPreferences é só para configurações simples.
**Escolha: Drift.** Custo zero; exige `build_runner`; dependências `drift`, `drift_flutter`, `sqlite3_flutter_libs`. Alternativa mais simples (JSON) descartada.

## Navegação adaptativa
`<600px` BottomNavigation · `600–1100px` NavigationRail · `>1100px` Sidebar. Abas: Visão geral, Contas, Calendário, Planejamento, Análises. Conta detalhada: sheet no celular, painel lateral no desktop.

## Design system
Tokens em `lib/design_system/tokens` (espaçamento, tipografia, raio, elevação, cores semânticas success/warning/danger/neutral/info), Light e Dark. Material 3 apenas como infraestrutura.

## Dependências
Fase 1: `flutter_riverpod`, `intl`. Previstas: `drift` (F2), `uuid`, `file_picker`, `image_picker`, `path_provider`, `csv`, `share_plus` (F3–F9), `google_sign_in`, `googleapis`, `flutter_secure_storage` (F10). Cada uma é justificada na fase em que entra.

## Extensibilidade
`Exporter`/`Importer` são interfaces (CSV agora; JSON/Excel/PDF depois). IA futura consome o mesmo export, apenas por solicitação do usuário. Notificações locais: porta `ReminderScheduler` com implementação nula no MVP.
