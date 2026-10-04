# Finance Hub

Aplicativo financeiro pessoal **local-first** (Flutter). Funciona 100% offline; Google Drive é opcional (backup, sincronização, comprovantes). Android primeiro, Web/Desktop pelo mesmo código.

Docs: [ARCHITECTURE](docs/ARCHITECTURE.md) · [DATA_MODEL](docs/DATA_MODEL.md) · [SECURITY](docs/SECURITY.md) · [SYNC](docs/SYNC.md) · [ROADMAP](docs/ROADMAP.md) · [DECISIONS](docs/DECISIONS.md)

## Desenvolvimento
```
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # após mudar tabelas
flutter run -d chrome
```

Build Web offline (CanvasKit embutido, sem CDN):
```
flutter build web --release --no-web-resources-cdn
```
Os arquivos `web/sqlite3.wasm` e `web/drift_worker.js` são necessários ao banco na Web e devem acompanhar as versões do `pubspec.lock` (drift 2.35.1, sqlite3 3.5.2). O código gerado (`*.g.dart`) é versionado.
