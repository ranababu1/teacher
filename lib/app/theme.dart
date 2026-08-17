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

/// Centralized elevation tiers — depth signals hierarchy instead of every
/// card looking identical. Link-row cards (a queue item, a settings row)
/// stay [flat] on purpose so stat/content cards visibly "float" above
/// them; that contrast is itself the hierarchy cue.
class AppElevation {
  AppElevation._();

  static const double flat = 0;
  static const double standard = 1;
  static const double prominent = 3;
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

  /// An ambient, corner-anchored sheen for ordinary cards — a single hue
  /// fading to nothing, an order of magnitude fainter than [primary] and
  /// visually unrelated to it (one color, not two; a corner highlight, not
  /// a full-card wash). Applied via `GradientCard` so every card in the
  /// app picks it up without individually hard-coding it. [primary]
  /// remains reserved for exactly one hero card per screen.
  static LinearGradient cardSheen(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primary.withValues(alpha: isDark ? 0.07 : 0.05),
        colorScheme.primary.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.55],
    );
  }
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
        elevation: AppElevation.standard,
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
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

  // Every size below is Material 3's default type-scale value +4 —
  // the user found the previous (mostly implicit-default) scale hard to
  // read and asked for a flat, consistent bump across every text style,
  // not just the headline. Every style now sets fontSize explicitly so
  // none of them can silently drift back to the M3 default.
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      displaySmall: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, height: 1.2),
      // Bumped past Material's default and given slightly negative
      // tracking — this is the one "big headline" style in the app (the
      // Dashboard greeting), so it needs real contrast against
      // everything else rather than sitting one notch above titleLarge.
      headlineMedium: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.35),
      titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, height: 1.4),
      bodyLarge: TextStyle(fontSize: 20, height: 1.5, letterSpacing: 0.1),
      bodyMedium: TextStyle(fontSize: 18, height: 1.5, letterSpacing: 0.1),
      bodySmall: TextStyle(fontSize: 16, height: 1.4, letterSpacing: 0.1),
      labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
