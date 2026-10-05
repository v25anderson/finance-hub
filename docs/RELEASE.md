# RELEASE (Android)

## Estado atual
- O workflow `Android APK` gera, a cada push, o **APK** (instalação direta) e o **AAB** (Play Store) como artefatos da execução.
- Sem segredos de assinatura, ambos saem assinados com a **chave de TESTE** versionada em `android/app/test-signing.jks` (senha `financehub-test`, pública de propósito).
  - Vantagem: assinatura **estável**: um APK novo instala por cima do anterior sem apagar os dados, e o SHA-1 para o login Google não muda. SHA-1: `1F:AC:D2:4B:CF:3A:D1:16:7B:0F:6D:BB:2B:91:E0:63:44:AE:CD:51`.
  - Limite: **não use para publicar**. Qualquer pessoa pode assinar um APK falso com essa chave.
- O número do build (`versionCode`) é o número da execução do workflow; a versão exibida vem do `pubspec.yaml` (`version: 0.1.0+1` → nome 0.1.0).
- Nota: o primeiro APK com a chave de teste fixa **não instala por cima** de um APK antigo assinado com a chave de debug aleatória do Actions (assinaturas diferentes): desinstale uma vez (os dados locais do aparelho são apagados; exporte um CSV ou faça backup antes). Daí em diante as atualizações instalam normalmente.

## Antes de publicar (passos seus)
1. **Decida o ID do aplicativo.** Hoje é `com.financehub.finance_hub` (`android/app/build.gradle.kts`). Ele **não pode mudar** depois de publicado. Se quiser outro (por exemplo `app.financehub`), troque `namespace` e `applicationId` e o pacote em `android/app/src/main/kotlin/...`, e atualize o cliente Android do Google Cloud.
2. **Gere a chave de publicação** (guarde em local seguro e faça cópia; perdê-la impede atualizar o app, a menos que use Play App Signing):
   ```
   keytool -genkeypair -v -keystore release.jks -alias financehub -keyalg RSA -keysize 2048 -validity 10000
   ```
3. **Configure o GitHub Actions** (Settings → Secrets and variables → Actions): `ANDROID_KEYSTORE_BASE64` (`base64 -w0 release.jks`), `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` e, para o Drive, `GOOGLE_SERVER_CLIENT_ID` (veja `docs/GOOGLE_SETUP.md`). Com esses segredos o workflow assina com a sua chave.
   Para compilar localmente, crie `android/key.properties` (ignorado pelo git) com `storeFile=../release.jks`, `storePassword`, `keyAlias`, `keyPassword`.
4. **Play Console**: crie o app, ative **Play App Signing** (você envia o AAB assinado com a chave de *upload*), preencha ficha da loja, classificação de conteúdo e a política de privacidade (URL obrigatória).
5. **Formulário de segurança de dados** (sugestão fiel ao app): o desenvolvedor **não coleta** dados; os dados financeiros ficam no aparelho; o backup/sincronização no Google Drive são opcionais, iniciados pelo usuário e gravam na conta Google do próprio usuário (escopo `drive.file`); sem analytics, sem anúncios, sem rastreamento. A política de privacidade deve dizer o mesmo.
6. **Tela de consentimento OAuth**: enquanto estiver em "Teste", só os e-mails cadastrados conseguem entrar; para usuários em geral, publique a tela (o escopo `drive.file` não é sensível).
7. **Versão**: aumente `version:` no `pubspec.yaml` a cada publicação (o build number o workflow já incrementa).

## Verificação
Os AABs/APKs só são compilados no GitHub Actions (o ambiente de desenvolvimento não tem Android SDK). **O app nunca foi aberto em um Android real por quem o desenvolveu**: teste o APK em pelo menos um aparelho antes de publicar (instalação, ícone, login Google, backup, sincronização entre dois aparelhos, rotação e fonte ampliada).

## Ofuscação e símbolos
O R8 reduz e otimiza o código (padrão do Flutter em release). Não há ofuscação de Dart nem relatório de falhas (de propósito: nenhum dado sai do aparelho). Se quiser ofuscar: `--obfuscate --split-debug-info=build/symbols` e guarde os símbolos de cada versão.
