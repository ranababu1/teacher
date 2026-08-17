import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';

/// Bottom navigation bar on phones, a side rail on wider screens (tablet,
/// foldable, desktop). See instructions.md sections 7 and 41.
///
/// Both are wrapped in a translucent, blurred "glass" shell (a floating
/// pill on phones, a flush-left tinted strip on wide screens) — purely a
/// visual treatment; the destination list, branch-selection logic, and
/// phone/wide split below are unchanged.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Order matches the router's StatefulShellBranch order exactly — indices
  /// here ARE branch indices. [showOnPhone] is derived from this single
  /// list (not a hand-maintained parallel one) so the phone bottom bar's
  /// subset can never drift out of sync with it. Practice and Review stay
  /// reachable on phones via Dashboard cards instead of a persistent tab —
  /// six always-labeled destinations overflow/cramp on phone widths; see
  /// instructions.md sections 7 and 41.
  static const _destinations = [
    (
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard,
      label: 'Dashboard',
      showOnPhone: true,
    ),
    (
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
      label: 'Learn',
      showOnPhone: true,
    ),
    (
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      label: 'Practice',
      showOnPhone: false,
    ),
    (
      icon: Icons.replay_circle_filled_outlined,
      selectedIcon: Icons.replay_circle_filled,
      label: 'Review',
      showOnPhone: false,
    ),
    (
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Progress',
      showOnPhone: true,
    ),
    (
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      showOnPhone: true,
    ),
  ];

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 840;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkSurface : Colors.white)
                        .withValues(alpha: isDark ? 0.55 : 0.6),
                  ),
                  child: NavigationRail(
                    backgroundColor: Colors.transparent,
                    indicatorColor: colorScheme.primary.withValues(alpha: 0.85),
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final d in _destinations)
                        NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(
                            d.selectedIcon,
                            color: colorScheme.onPrimary,
                          ),
                          label: Text(d.label),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    final phoneEntries = [
      for (final e in _destinations.indexed) if (e.$2.showOnPhone) e,
    ];
    final branchIndices = [for (final e in phoneEntries) e.$1];
    final phoneSelected = branchIndices.indexOf(navigationShell.currentIndex);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.darkSurface.withValues(alpha: 0.72),
                          AppColors.darkSurface.withValues(alpha: 0.92),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.68),
                          Colors.white.withValues(alpha: 0.42),
                        ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(
                      alpha: isDark ? 0.4 : 0.15,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      final selected = states.contains(WidgetState.selected);
                      return TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      );
                    }),
                  ),
                ),
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  height: 64,
                  indicatorColor: colorScheme.primary,
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  // Defaults to Dashboard when the current branch
                  // (Practice/Review) has no visible tab of its own on
                  // phones — the bar never disappears, and every visible
                  // destination stays functional.
                  selectedIndex: phoneSelected == -1 ? 0 : phoneSelected,
                  onDestinationSelected: (i) =>
                      _onDestinationSelected(branchIndices[i]),
                  destinations: [
                    for (final e in phoneEntries)
                      NavigationDestination(
                        icon: Icon(
                          e.$2.icon,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        selectedIcon: Icon(
                          e.$2.selectedIcon,
                          color: colorScheme.onPrimary,
                        ),
                        label: e.$2.label,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
