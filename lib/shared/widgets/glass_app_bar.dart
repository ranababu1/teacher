import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A translucent, blurred app bar — a drop-in replacement for [AppBar]
/// forwarding the params this app's screens actually use (`title`,
/// `actions`, `leading`). Every screen lays its body out strictly below
/// the app bar today (none set `extendBodyBehindAppBar`), so the blur
/// mostly reads as a soft frosted tint rather than "content visibly
/// scrolling under frosted glass" — accepted as the pragmatic scope for
/// this pass; making content scroll under a literally-frosted bar would
/// need `extendBodyBehindAppBar` plus body padding on every screen, which
/// is a separate, larger change.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      AppColors.darkSurface.withValues(alpha: 0.78),
                      AppColors.darkSurface.withValues(alpha: 0.52),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.78),
                      Colors.white.withValues(alpha: 0.42),
                    ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.5),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            title: title,
            actions: actions,
            leading: leading,
            centerTitle: centerTitle,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
