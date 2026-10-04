/// Escala de espaçamento (múltiplos de 4).
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Raios de borda.
abstract final class Radii {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

/// Elevação (sombras sutis; a hierarquia vem de espaço e contraste, não de sombra).
abstract final class Elevation {
  static const double none = 0;
  static const double low = 1;
  static const double high = 6;
}

/// Pontos de quebra do layout adaptativo.
abstract final class Breakpoints {
  static const double compact = 600; // < 600: bottom nav
  static const double expanded = 1100; // >= 1100: sidebar
}
