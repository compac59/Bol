import 'package:flutter/material.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

/// Thème sombre « interface de chasseur » avec accents néon.
ThemeData buildTheme() {
  const neon = Color(0xFF36E2FF); // cyan néon
  const bg = Color(0xFF0E1117);
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: bg,
    colorScheme: base.colorScheme.copyWith(
      primary: neon,
      secondary: const Color(0xFF8B5CFF),
      surface: const Color(0xFF161B22),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF161B22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        // Hauteur min confortable, mais largeur FINIE : un minimumSize à
        // largeur infinie casse les boutons placés dans une Row.
        minimumSize: const Size(64, 48),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

/// Couleur associée à chaque rang (pour les badges).
Color rankColor(Rank rank) {
  switch (rank) {
    case Rank.e:
      return const Color(0xFF9AA4B2);
    case Rank.d:
      return const Color(0xFF35C46A);
    case Rank.c:
      return const Color(0xFF36E2FF);
    case Rank.b:
      return const Color(0xFF8B5CFF);
    case Rank.a:
      return const Color(0xFFFF8A3D);
    case Rank.s:
      return const Color(0xFFFFD24A);
  }
}
