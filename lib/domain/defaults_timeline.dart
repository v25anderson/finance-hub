import 'month_plan.dart';

/// Padrões de planejamento a partir de um mês (inclusive). Vale até a próxima versão.
class DefaultsVersion {
  const DefaultsVersion(this.effectiveFrom, this.defaults);

  /// `yyyy-MM`.
  final String effectiveFrom;
  final PlanningDefaults defaults;
}

/// Os padrões ao longo do tempo. Mudar o padrão cria uma versão que vale **a partir** de um mês; os meses anteriores
/// continuam com o que valia antes (ou sem padrão algum, se nada tinha sido definido). Evita reescrever o passado.
class DefaultsTimeline {
  DefaultsTimeline(Iterable<DefaultsVersion> versions) : versions = ([...versions]..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom)));

  static final empty = DefaultsTimeline(const []);

  /// Em ordem crescente de mês.
  final List<DefaultsVersion> versions;

  bool get isEmpty => versions.isEmpty;

  /// Primeiro mês com padrões definidos; antes dele não há padrão.
  String? get firstEffective => versions.isEmpty ? null : versions.first.effectiveFrom;

  /// A versão em vigor em [yearMonth]; nulo se ainda não havia padrão definido.
  DefaultsVersion? versionAt(String yearMonth) {
    DefaultsVersion? found;
    for (final v in versions) {
      if (v.effectiveFrom.compareTo(yearMonth) <= 0) {
        found = v;
      } else {
        break;
      }
    }
    return found;
  }

  PlanningDefaults? at(String yearMonth) => versionAt(yearMonth)?.defaults;

  /// Padrões em [yearMonth], ou zeros quando ainda não havia padrão definido.
  PlanningDefaults atOrZero(String yearMonth) => at(yearMonth) ?? const PlanningDefaults();
}
