# Finance Hub

Aplicativo de finanças pessoais **local-first** (Flutter, Android primeiro; Web e desktop pelo mesmo código).
Seus dados ficam no aparelho e tudo funciona **sem internet e sem conta**. O Google Drive é opcional (backup e sincronização entre aparelhos), sempre por ação sua.

## O que ele faz
- **Contas e pagamentos**: cadastro rápido, faixa de valor opcional para gastos variáveis (ex.: energia entre R$ 200 e R$ 300), status derivado (prevista, pendente, vencida, parcialmente paga, paga), pagamento parcial sem nunca contar como pago, exclusão que preserva o histórico e permite desfazer.
- **Recorrências**: contas fixas que se repetem; editar ou excluir "só esta", "esta e as próximas" ou "toda a recorrência", preservando o passado e o que já foi pago.
- **Visão geral**: gastos do mês, "Próximas contas" em carrossel, alertas de vencimento, quanto sobra, comparação com o mês anterior, renda e investimentos.
- **Calendário** de vencimentos, **planejamento** (valores padrão e personalizados por mês) com **projeções** de 1 a 12 meses, **análises** de 6/12/24 meses com gráficos acessíveis. Dado real e projeção nunca se misturam; as análises só descrevem, nunca aconselham.
- **Exportação** em CSV/ZIP (valores em reais a partir de centavos inteiros, separador à escolha, proteção contra injeção de fórmula).
- **Backup e sincronização no Google Drive** (Android): backup manual com restauração segura (valida, pede confirmação e guarda cópia local antes) e sincronização entre aparelhos com merge por campo; conflitos são decididos por você, nunca em silêncio.
- **Web offline** (PWA) e visual próprio, claro e escuro.

## Princípios
Dinheiro em centavos inteiros · estado da conta derivado, nunca gravado · soft delete, nada de histórico apagado em silêncio · sem analytics, sem crash reporting, sem valores em logs · o app só fala com a internet quando você pede (Drive). Detalhes em [SECURITY](docs/SECURITY.md).

## Estado do projeto
Fases 0 a 14 do [ROADMAP](docs/ROADMAP.md) concluídas; a 15 (polimento) está em andamento. **Leia as limitações antes de confiar nele:**
- O app **nunca foi aberto em um Android real** por quem o desenvolveu (compila e passa nos testes; o APK é gerado no GitHub Actions). Teste em um aparelho.
- O **login Google e o Drive reais nunca foram exercitados** (exige credenciais suas: veja [GOOGLE_SETUP](docs/GOOGLE_SETUP.md)). Sem o ID de cliente a tela de backup aparece desligada, explicando o motivo.
- **Comprovantes (anexos) ainda não existem.**
- Backup e sincronização **não são criptografados** (previsto no roadmap).

## Desenvolvimento
```
flutter pub get
flutter analyze
flutter test                      # ~430 testes: domínio, dados, telas, golden, acessibilidade, jornada completa
dart run build_runner build --delete-conflicting-outputs   # depois de mudar tabelas (o código gerado é versionado)
flutter run -d chrome             # ou um emulador/aparelho Android
```
Guia de testes: [TESTING](docs/TESTING.md). Para regenerar as imagens golden depois de mudar o visual de propósito: `flutter test --update-goldens test/golden`.

## Gerar o app
| Alvo | Como | Detalhes |
|---|---|---|
| **Android (APK/AAB)** | GitHub Actions, workflow *Android APK*: **Actions → execução → Artifacts** (`finance-hub-apk`, `finance-hub-aab`) | [RELEASE](docs/RELEASE.md): assinatura, chave de publicação, Play Store |
| **Web** | `flutter build web --release --no-web-resources-cdn` (ou o workflow *Web*) | [WEB](docs/WEB.md): hospedagem, offline, dados no navegador |

Os APKs de teste são assinados com uma chave **de teste fixa** (instalam por cima do anterior; não servem para publicar). O primeiro APK com ela exige desinstalar um APK antigo uma vez; exporte um CSV antes.

## Documentação
[ARCHITECTURE](docs/ARCHITECTURE.md) · [DATA_MODEL](docs/DATA_MODEL.md) · [SECURITY](docs/SECURITY.md) · [SYNC](docs/SYNC.md) · [GOOGLE_SETUP](docs/GOOGLE_SETUP.md) · [RELEASE](docs/RELEASE.md) · [WEB](docs/WEB.md) · [TESTING](docs/TESTING.md) · [ROADMAP](docs/ROADMAP.md) · [DECISIONS](docs/DECISIONS.md)
