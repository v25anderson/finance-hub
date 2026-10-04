import 'package:flutter/material.dart';

import '../../../design_system/components/animated_value.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../shared/presentation/page_header.dart';
import 'defaults_card.dart';
import 'month_override_card.dart';
import 'projection_section.dart';

const _twoColumnsFrom = 900.0;

/// Planejamento: valores padrão, personalização de um mês e projeções.
class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        Space.md,
        Space.lg + topInset(context),
        Space.md,
        120,
      ),
      children: [
        const PageHeader('Planejamento'),
        const SizedBox(height: Space.md),
        LayoutBuilder(
          builder: (context, box) {
            const left = [
              Reveal(index: 0, child: DefaultsCard()),
              SizedBox(height: Space.md),
              Reveal(index: 1, child: MonthOverrideCard()),
            ];
            const right = Reveal(index: 2, child: ProjectionSection());
            if (box.maxWidth >= _twoColumnsFrom) {
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(children: left)),
                  SizedBox(width: Space.lg),
                  Expanded(flex: 2, child: right),
                ],
              );
            }
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...left,
                SizedBox(height: Space.lg),
                right,
              ],
            );
          },
        ),
      ],
    );
  }
}
