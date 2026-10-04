import 'package:flutter/animation.dart';

/// Escala de espaçamento (múltiplos de 4).
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Raios de borda (generosos: identidade do produto).
abstract final class Radii {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;
}

/// Elevação (a hierarquia vem de espaço, cor e contraste, quase sem sombra).
abstract final class Elevation {
  static const double none = 0;
  static const double low = 1;
  static const double high = 6;
}

/// Movimento: curto, suave e sem exagero.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 600);
  static const Curve curve = Curves.easeOutCubic;
}

/// Pontos de quebra do layout adaptativo.
abstract final class Breakpoints {
  static const double compact = 600; // < 600: barra inferior
  static const double expanded = 1100; // >= 1100: barra lateral completa
}
