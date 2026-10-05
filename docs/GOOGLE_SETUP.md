# Configurar o backup no Google Drive

O app não traz credenciais do Google. Sem a configuração abaixo, a tela de backup mostra "não configurado" e todo o resto funciona normalmente.

## 1. Projeto no Google Cloud
1. Crie um projeto em <https://console.cloud.google.com>.
2. **APIs e serviços → Biblioteca**: ative a **Google Drive API**.
3. **Tela de consentimento OAuth**: tipo *Externo*; adicione o escopo `https://www.googleapis.com/auth/drive.file` (escopo não sensível: só arquivos criados pelo app). Enquanto o app estiver em "Teste", adicione seu e-mail em *Usuários de teste*.

## 2. IDs de cliente OAuth
Em **Credenciais → Criar credenciais → ID do cliente OAuth** crie dois:
- **Android**: nome do pacote `com.financehub.finance_hub` e a impressão digital **SHA-1** do certificado que assina o APK. Para os APKs de teste do GitHub Actions a chave agora é **fixa** (`android/app/test-signing.jks`), então o SHA-1 não muda:
  `1F:AC:D2:4B:CF:3A:D1:16:7B:0F:6D:BB:2B:91:E0:63:44:AE:CD:51`
  (cada execução do Actions também mostra o SHA-1 do APK gerado, no resumo da execução). Para a versão publicada, registre também o SHA-1 da sua chave de publicação e, se usar Play App Signing, o da chave de assinatura do app que o Play Console mostra.
- **Aplicativo da Web**: o ID gerado aqui (`xxxx.apps.googleusercontent.com`) é o **GOOGLE_SERVER_CLIENT_ID**. O Android o exige para o login funcionar, mesmo sem servidor.

## 3. Passar o ID para o app
- Local: `flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com`
- GitHub Actions: crie o segredo `GOOGLE_SERVER_CLIENT_ID` em *Settings → Secrets and variables → Actions*. O workflow o repassa à build.

O ID de cliente não é um segredo de alto risco (vai embutido no app), mas não fica no repositório para que cada instalação use o seu projeto.

## Plataformas
Android é o alvo da Fase 10. Web e desktop não têm login Google suportado por este pacote: a tela mostra "não configurado".

## Se o login não funciona (checklist)
A mensagem na tela de backup indica a causa:
- **"Login com Google ainda não ativado"** → o app foi compilado sem `GOOGLE_SERVER_CLIENT_ID` (passo 3). Crie o segredo no GitHub e gere um APK novo.
- **"Login não concluído"** (mesmo sem cancelar) → no Android, SHA-1 ou pacote errado costuma aparecer assim. Confira no cliente OAuth *Android*: pacote `com.financehub.finance_hub` e SHA-1 do APK instalado.
- **"Configuração do Google incorreta … código: clientConfigurationError"** → cliente OAuth ausente/errado; o ID usado em `GOOGLE_SERVER_CLIENT_ID` precisa ser do tipo **Aplicativo da Web**, do mesmo projeto do cliente Android.
- **Erro de acesso bloqueado / app não verificado** → adicione seu e-mail em *Tela de consentimento → Usuários de teste*.
- Confirme que a **Google Drive API** está ativada no mesmo projeto e que há uma conta Google no aparelho.
- Alterações no Google Cloud podem levar alguns minutos para valer.
