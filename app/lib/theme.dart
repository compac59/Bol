import 'package:flutter/material.dart';
import 'package:mybody_rpg_engine/mybody_rpg_engine.dart';

/// Palette « interface de chasseur » — sombre, accents néon.
abstract final class AppColors {
  static const bg = Color(0xFF0A0E14); // fond général
  static const surface = Color(0xFF121A24); // cartes
  static const surfaceAlt = Color(0xFF0F151E); // champs, encarts
  static const border = Color(0xFF1E2A38); // liseré des cartes

  static const neon = Color(0xFF4FD8EB); // cyan principal
  static const violet = Color(0xFF8B5CFF); // secondaire
  static const gold = Color(0xFFFFD24A); // rang S / récompenses
  static const success = Color(0xFF3DDC84);
  static const danger = Color(0xFFFF5D6C);

  static const text = Color(0xFFE8EEF4);
  static const textDim = Color(0xFF8A97A8);
}

/// Thème global de MyBody:RPG.
ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  const display = 'Rajdhani'; // titres, chiffres, éléments « jeu »
  const body = 'Inter'; // texte courant

  final textTheme = base.textTheme
      .apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
        fontFamily: body,
      )
      .copyWith(
        displayLarge: const TextStyle(
            fontFamily: display, fontWeight: FontWeight.w700, fontSize: 40),
        headlineMedium: const TextStyle(
            fontFamily: display, fontWeight: FontWeight.w700, fontSize: 26),
        titleLarge: const TextStyle(
            fontFamily: display,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.4),
        titleMedium: const TextStyle(
            fontFamily: display,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.4),
        labelLarge: const TextStyle(
            fontFamily: display,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.6),
        bodySmall: const TextStyle(
            fontFamily: body, fontSize: 12.5, color: AppColors.textDim),
      );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.neon,
      onPrimary: const Color(0xFF06282E),
      secondary: AppColors.violet,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.danger,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: const IconThemeData(color: AppColors.text),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 50),
        backgroundColor: AppColors.neon,
        foregroundColor: const Color(0xFF06282E),
        textStyle: textTheme.labelLarge,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.neon,
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      labelStyle: const TextStyle(color: AppColors.textDim),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.neon, width: 1.4),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surfaceAlt,
      selectedColor: AppColors.neon.withValues(alpha: 0.18),
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(color: AppColors.text, fontFamily: body),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: AppColors.neon,
      thumbColor: AppColors.neon,
      inactiveTrackColor: AppColors.border,
    ),
    checkboxTheme: base.checkboxTheme.copyWith(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.success
            : Colors.transparent,
      ),
      side: const BorderSide(color: AppColors.textDim, width: 1.4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}

/// Couleur associée à chaque rang (badges, barres, glow).
Color rankColor(Rank rank) {
  switch (rank) {
    case Rank.e:
      return const Color(0xFF9AA4B2);
    case Rank.d:
      return const Color(0xFF3DDC84);
    case Rank.c:
      return AppColors.neon;
    case Rank.b:
      return AppColors.violet;
    case Rank.a:
      return const Color(0xFFFF8A3D);
    case Rank.s:
      return AppColors.gold;
  }
}

/// Couleur de chaque statistique (barres du profil).
Color statColor(String key) {
  switch (key) {
    case 'force':
      return const Color(0xFFFF6B6B);
    case 'endurance':
      return const Color(0xFFFFA94D);
    case 'explosivite':
      return AppColors.neon;
    case 'volonte':
      return AppColors.violet;
    case 'vitalite':
      return AppColors.success;
    default:
      return AppColors.neon;
  }
}
