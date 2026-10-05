# WEB

O app web é o mesmo código do Android, com banco SQLite em WebAssembly guardado no **IndexedDB** do navegador. Funciona **offline** depois da primeira visita.

## Compilar e hospedar
```
flutter build web --release --no-web-resources-cdn
```
- `--no-web-resources-cdn` embute o CanvasKit no pacote: nada é baixado do Google em execução e o app abre offline.
- O resultado (`build/web`) é um conjunto de arquivos estáticos: qualquer hospedagem serve (GitHub Pages, Netlify, Nginx...). **HTTPS é obrigatório** fora do `localhost` (service worker e armazenamento persistente).
- Em subcaminho (ex.: GitHub Pages `https://usuario.github.io/finance-hub/`): `--base-href /finance-hub/`.
- O workflow `Web` gera o pacote como artefato (`finance-hub-web`); aceita o `base_href` ao rodar manualmente.
- Cabeçalhos opcionais para o banco usar a implementação mais rápida (OPFS, exige isolamento de origem): `Cross-Origin-Opener-Policy: same-origin` e `Cross-Origin-Embedder-Policy: require-corp`. Sem eles o banco usa IndexedDB, que funciona (foi o verificado).
- Servir `sqlite3.wasm` com `Content-Type: application/wasm`.

## Privacidade e política de segurança de conteúdo
O `index.html` traz uma Content-Security-Policy: o app web só carrega e consulta o **próprio site** (`default-src 'self'`, `connect-src 'self'`). Motivo concreto: o plugin de login do Google carrega `accounts.google.com/gsi/client` ao iniciar, mesmo sem uso (e o Drive não existe na web). Com a política, o navegador recusa o script ("Refused to load the script…" no console, esperado). Se o Drive for habilitado na web um dia, a política precisa liberar os domínios do Google. Hospedagens que sobrescrevem cabeçalhos devem manter uma política equivalente.

## Offline (service worker próprio)
O service worker do Flutter 3.47 apenas se desregistra, então o app traz o seu: `web/sw.js`, registrado em `web/flutter_bootstrap.js`.
- Um cache por versão do build (a versão vai em `sw.js?v=...`); a instalação guarda os arquivos essenciais (app, CanvasKit, SQLite wasm, fontes e ícones) e o restante é guardado quando usado.
- Cache primeiro para tudo do próprio site; não intercepta nada de outros domínios (Drive e Google nunca passam por ele).
- **Atualização**: uma versão nova só assume quando as abas antigas fecham (sem `skipWaiting`), para não misturar arquivos de versões diferentes; as versões antigas do cache são apagadas na ativação. Na prática: depois de publicar, feche e reabra o app para ver a versão nova.
- O cache guarda só arquivos do app. **Os dados do usuário ficam no IndexedDB**, fora do cache.

## Seus dados no navegador
- Ficam neste navegador e perfil. **Limpar os dados do site apaga tudo.** Navegação anônima não mantém nada.
- O app pede armazenamento persistente (`navigator.storage.persist()`) para o navegador não apagar os dados quando faltar espaço; o navegador decide. O Safari pode apagar dados de sites sem uso por cerca de 7 dias, se o app não estiver instalado na tela inicial.
- Por isso a web também tem **exportação em CSV/ZIP** (baixa o arquivo). Backup e sincronização com o Google Drive **não existem na web** (o login Google deste pacote só funciona em Android/iOS): a tela explica isso.
- O app pode ser instalado como aplicativo (PWA) pelo navegador; ícone e nome vêm de `web/manifest.json`.

## Verificado e não verificado
Verificado no Chromium: título e ícone, abertura offline com o app completo desenhado, download do ZIP de exportação, service worker ativo com cache por versão, sem erros no console.
Não verificado: Safari e Firefox, instalação como PWA, hospedagem real com HTTPS, cabeçalhos COOP/COEP, comportamento do cache numa atualização real de versão (a lógica foi escrita para isso, mas só testei uma versão).
