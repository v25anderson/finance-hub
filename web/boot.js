// Tira o indicador de carga quando o app desenha o primeiro quadro (e some da leitura por leitor de tela).
// Fica em arquivo próprio porque a política de segurança de conteúdo do index.html não permite scripts embutidos.
window.addEventListener('flutter-first-frame', function () {
  var b = document.getElementById('boot');
  if (b) b.remove();
});
