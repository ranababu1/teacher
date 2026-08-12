import 'package:flutter/material.dart';

/// Centralized color and typography definitions.
///
/// Widgets must never hard-code colors — pull everything from
/// `Theme.of(context)` / [AppColors] instead. See instructions.md section 42.
class AppColors {
  AppColors._();

  static const Color _seed = Color(0xFF3D6BFF);

  static const Color lightSurface = Color(0xFFFAFAFC);
  static const Color darkSurface = Color(0xFF101114);

  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFC98A1F);
  static const Color danger = Color(0xFFD1483F);

  static Color get seed => _seed;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );

    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkSurface
          : AppColors.lightSurface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        elevation: 0,
        height: 64,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: textTheme.labelMedium,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    const family = 'Roboto';
    return const TextTheme(
      displaySmall: TextStyle(
        fontFamily: family,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: family,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      headlineSmall: TextStyle(
        fontFamily: family,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontFamily: family,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontFamily: family,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      titleSmall: TextStyle(
        fontFamily: family,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyLarge: TextStyle(fontFamily: family, height: 1.5, letterSpacing: 0.1),
      bodyMedium: TextStyle(
        fontFamily: family,
        height: 1.5,
        letterSpacing: 0.1,
      ),
      bodySmall: TextStyle(fontFamily: family, height: 1.4, letterSpacing: 0.1),
      labelLarge: TextStyle(fontFamily: family, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontFamily: family, fontWeight: FontWeight.w500),
    );
  }
}
