{{flutter_js}}
{{flutter_build_config}}

// Sem o service worker do Flutter (nesta versão ele só se desregistra): usamos o nosso, em sw.js,
// para o app abrir offline. A versão vai na URL para que cada build instale um service worker novo.
const swVersion = {{flutter_service_worker_version}};
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    navigator.serviceWorker.register('sw.js?v=' + encodeURIComponent(String(swVersion))).catch(function () {});
  });
}

// Pede ao navegador para NÃO apagar os dados locais (IndexedDB) quando faltar espaço: o app é local-first.
// O navegador decide (em geral concede a sites usados com frequência); não bloqueia nada se negar.
if (navigator.storage && navigator.storage.persist) {
  navigator.storage.persist().catch(function () {});
}

_flutter.loader.load();
