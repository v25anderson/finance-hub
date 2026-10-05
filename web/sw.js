'use strict';

// Service worker do Finance Hub: deixa o app abrir sem internet.
// - Um cache por versão do build (a versão vem na URL: sw.js?v=...). Versões antigas são apagadas na ativação.
// - Cache primeiro para tudo do mesmo site; o que ainda não está no cache é buscado na rede e guardado.
// - Não usa skipWaiting: uma versão nova só assume quando as abas antigas fecham, para não misturar arquivos de versões diferentes.
// - Nada é enviado para fora: só atende requisições do próprio site. Os dados do usuário ficam no IndexedDB, fora deste cache.
const VERSION = new URL(self.location.href).searchParams.get('v') || 'dev';
const CACHE = 'finance-hub-' + VERSION;

const CORE = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'sqlite3.wasm',
  'drift_worker.js',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
];

self.addEventListener('install', function (event) {
  event.waitUntil((async function () {
    const cache = await caches.open(CACHE);
    // Falha em um arquivo não impede a instalação: ele será guardado quando for usado.
    await Promise.all(CORE.map(async function (url) {
      try {
        const res = await fetch(new Request(url, { cache: 'reload' }));
        if (res.ok) await cache.put(url, res);
      } catch (_) { /* offline durante a instalação */ }
    }));
  })());
});

self.addEventListener('activate', function (event) {
  event.waitUntil((async function () {
    const keys = await caches.keys();
    await Promise.all(keys.filter(function (k) { return k.startsWith('finance-hub-') && k !== CACHE; }).map(function (k) { return caches.delete(k); }));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', function (event) {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;
  event.respondWith((async function () {
    const cache = await caches.open(CACHE);
    const hit = await cache.match(req, { ignoreSearch: true });
    if (hit) return hit;
    try {
      const res = await fetch(req);
      if (res.ok && res.type === 'basic') cache.put(req, res.clone());
      return res;
    } catch (err) {
      if (req.mode === 'navigate') {
        const index = await cache.match('index.html');
        if (index) return index;
      }
      throw err;
    }
  })());
});
