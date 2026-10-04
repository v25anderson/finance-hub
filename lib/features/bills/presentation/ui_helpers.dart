import 'package:flutter/material.dart';

import '../../../data/repositories/repo_base.dart';

/// Executa uma ação mostrando erros de regra de negócio ao usuário, sem expor dados em logs.
/// Retorna true se concluiu.
Future<bool> runGuarded(BuildContext context, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    return true;
  } on ValidationError catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } on NotFoundError {
    messenger.showSnackBar(const SnackBar(content: Text('Registro não encontrado (pode ter sido excluído).')));
  } catch (_) {
    messenger.showSnackBar(const SnackBar(content: Text('Não foi possível concluir a operação.')));
  }
  return false;
}
