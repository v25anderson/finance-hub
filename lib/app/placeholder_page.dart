import 'package:flutter/material.dart';

import '../design_system/components/app_card.dart';
import '../design_system/tokens/colors.dart';
import '../design_system/tokens/spacing.dart';
import '../design_system/tokens/typography.dart';

/// Tela provisória até a fase correspondente ser implementada.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title, required this.phase});
  final String title;
  final String phase;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(Space.lg),
      children: [
        Text(title, style: AppText.title(c.textPrimary)),
        const SizedBox(height: Space.lg),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionLabel('Em construção'),
            const SizedBox(height: Space.sm),
            Text('Disponível na $phase.', style: AppText.body(c.textSecondary)),
          ]),
        ),
      ],
    );
  }
}
