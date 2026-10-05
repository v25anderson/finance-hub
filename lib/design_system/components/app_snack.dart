import 'package:flutter/material.dart';

/// Aviso rápido do app. Regras de usabilidade:
/// - **some sozinho**: 2 s sem ação, 3,5 s com "Desfazer". (Nas versões recentes do Flutter, um aviso com botão de ação NÃO
///   some sozinho a menos que `persist` seja falso; era o que deixava o "Desfazer" na tela por tempo demais.)
/// - **sem fila**: um aviso novo substitui o atual na hora, em vez de esperar o anterior terminar.
/// - fica **acima do dock** de navegação e pode ser dispensado deslizando.
void showAppSnack(ScaffoldMessengerState messenger, String message, {String? actionLabel, VoidCallback? onAction, double bottomMargin = 96}) {
  messenger.clearSnackBars();
  final hasAction = actionLabel != null && onAction != null;
  messenger.showSnackBar(SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
    duration: hasAction ? const Duration(milliseconds: 3500) : const Duration(seconds: 2),
    persist: false,
    dismissDirection: DismissDirection.horizontal,
    action: hasAction ? SnackBarAction(label: actionLabel, onPressed: onAction) : null,
  ));
}
