import 'package:flutter/material.dart';

import '../../../data/repositories/repo_base.dart';
import '../../../design_system/components/app_snack.dart';

/// Executa uma ação mostrando erros de regra de negócio ao usuário, sem expor dados em logs.
/// Retorna true se concluiu.
Future<bool> runGuarded(BuildContext context, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } on ValidationError catch (e) {
    showAppSnack(messenger, e.message);
  } on NotFoundError {
    showAppSnack(messenger, 'Registro não encontrado (pode ter sido excluído).');
  } catch (_) {
    showAppSnack(messenger, 'Não foi possível concluir a operação.');
  }
  return false;
}
