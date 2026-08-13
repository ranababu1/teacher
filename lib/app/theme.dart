import 'package:flutter/material.dart';

/// Centralized color, gradient, and typography definitions.
///
/// Widgets must never hard-code colors — pull everything from
/// `Theme.of(context)` / [AppColors] / [AppGradients] instead. See
/// instructions.md section 42.
class AppColors {
  AppColors._();

  static const Color _seed = Color(0xFF3D6BFF);
  static const Color _seedAccent = Color(0xFF8B5CF6);

  static const Color lightSurface = Color(0xFFFAFAFC);
  static const Color darkSurface = Color(0xFF0E0F13);

  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFC98A1F);
  static const Color danger = Color(0xFFD1483F);

  static Color get seed => _seed;
  static Color get seedAccent => _seedAccent;
}

/// Subtle, restrained gradients — never the loud kind. See
/// instructions.md section 7: "keep subtle gradients", avoid excess.
class AppGradients {
  AppGradients._();

  /// For hero surfaces: the Dashboard's "Continue Learning" card, primary
  /// CTAs. Diagonal, low-contrast between its two stops.
  static LinearGradient primary(ColorScheme colorScheme) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [colorScheme.primary, AppColors.seedAccent],
  );

  /// A near-invisible top-to-bottom wash for full-screen backgrounds —
  /// adds depth without reading as "a gradient" at a glance.
  static LinearGradient scaffold(ColorScheme colorScheme, bool isDark) {
    final base = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final tint = colorScheme.primary.withValues(alpha: isDark ? 0.05 : 0.04);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color.alphaBlend(tint, base), base],
      stops: const [0.0, 0.35],
    );
  }

  /// Fill for progress indicators — the same brand gradient as [primary]
  /// but oriented horizontally to read clearly as a fill direction.
  static LinearGradient progress(ColorScheme colorScheme) => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [colorScheme.primary, AppColors.seedAccent],
  );
}

class AppTheme {
  AppTheme._();

  static const fontFamily = 'Atkinson Hyperlegible';

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      // Transparent so the app-wide subtle gradient wash (painted once in
      // TeacherApp's MaterialApp.builder) shows through every screen,
      // instead of each Scaffold painting an opaque flat color over it.
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _SharedAxisPageTransitionsBuilder(),
          TargetPlatform.iOS: _SharedAxisPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      displaySmall: TextStyle(fontWeight: FontWeight.w600, height: 1.2),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600, height: 1.25),
      headlineSmall: TextStyle(fontWeight: FontWeight.w600, height: 1.3),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, height: 1.35),
      titleSmall: TextStyle(fontWeight: FontWeight.w500, height: 1.4),
      bodyLarge: TextStyle(height: 1.5, letterSpacing: 0.1),
      bodyMedium: TextStyle(height: 1.5, letterSpacing: 0.1),
      bodySmall: TextStyle(height: 1.4, letterSpacing: 0.1),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontWeight: FontWeight.w500),
    );
  }
}

/// A restrained fade-through-and-rise transition, used for every pushed
/// route in the app instead of the platform default slide. Subtle enough
/// to fit a "professional developer tool" feel while still being visibly
/// alive — see instructions.md section 7.
class _SharedAxisPageTransitionsBuilder extends PageTransitionsBuilder {
  const _SharedAxisPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
