# Configurar o backup no Google Drive

O app não traz credenciais do Google. Sem a configuração abaixo, a tela de backup mostra "não configurado" e todo o resto funciona normalmente.

## 1. Projeto no Google Cloud
1. Crie um projeto em <https://console.cloud.google.com>.
2. **APIs e serviços → Biblioteca**: ative a **Google Drive API**.
3. **Tela de consentimento OAuth**: tipo *Externo*; adicione o escopo `https://www.googleapis.com/auth/drive.file` (escopo não sensível: só arquivos criados pelo app). Enquanto o app estiver em "Teste", adicione seu e-mail em *Usuários de teste*.

## 2. IDs de cliente OAuth
Em **Credenciais → Criar credenciais → ID do cliente OAuth** crie dois:
- **Android**: nome do pacote do app e a impressão digital **SHA-1** do certificado que assina o APK. Para o APK de teste do GitHub Actions é a chave de *debug* do runner, que muda a cada execução: para testar de verdade, assine com uma chave sua (keystore fixa) e use o SHA-1 dela.
- **Aplicativo da Web**: o ID gerado aqui (`xxxx.apps.googleusercontent.com`) é o **GOOGLE_SERVER_CLIENT_ID**. O Android o exige para o login funcionar, mesmo sem servidor.

## 3. Passar o ID para o app
- Local: `flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxx.apps.googleusercontent.com`
- GitHub Actions: crie o segredo `GOOGLE_SERVER_CLIENT_ID` em *Settings → Secrets and variables → Actions*. O workflow o repassa à build.

O ID de cliente não é um segredo de alto risco (vai embutido no app), mas não fica no repositório para que cada instalação use o seu projeto.

## Plataformas
Android é o alvo da Fase 10. Web e desktop não têm login Google suportado por este pacote: a tela mostra "não configurado".
