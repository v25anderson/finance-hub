import 'package:flutter/material.dart';

import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/typography.dart';

/// Recuo da barra de status (0 na Web e em telas sem recorte).
double topInset(BuildContext context) => MediaQuery.paddingOf(context).top;

/// Título grande de página (sem AppBar do Material).
class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: AppText.title(context.colors.textPrimary))),
        ?trailing,
      ]);
}
