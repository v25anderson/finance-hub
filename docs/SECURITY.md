# SECURITY

- Dados financeiros ficam no armazenamento privado do app. Sem analytics, sem crash reporting com dados.
- Dados só saem do dispositivo por ação explícita (Drive conectado, exportar). IA futura: somente por solicitação explícita do usuário.
- Tokens OAuth em armazenamento seguro (Keystore). Credenciais separadas dos dados. Nenhuma senha Google é vista pelo app.
- Escopo Drive mínimo: `drive.file`.
- Logs com *redaction*: nunca registrar valores, nomes de contas ou caminhos de comprovantes.
- `android:allowBackup="false"`: backup é opt-in via Drive.
- Comprovantes: cópia local sempre; abertura nunca depende do Drive.
- Roadmap: criptografia de backup com senha (AES-GCM), bloqueio biométrico.
- Exportação: sempre iniciada pelo usuário; o arquivo é salvo onde ele escolher (seletor do sistema), sem envio pela rede. O arquivo exportado contém valores financeiros e fica fora da proteção do app: a tela avisa. CSV neutraliza injeção de fórmula (`= + - @`, tab) nos textos.
