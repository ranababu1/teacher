import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';

import '../../domain/models/flash_card.dart';

/// A single-card, full-screen interstitial — deliberately not styled like
/// the rest of the app's screens (no app bar, no bottom nav) so it reads
/// as a quick, self-contained interruption rather than another page to
/// navigate. Opened either by tapping a weekly-flashcard notification or,
/// in the Developer settings section, the "send test notification" action.
class FlashCardScreen extends StatefulWidget {
  const FlashCardScreen({super.key, required this.card});

  final FlashCard card;

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;

    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: theme.colorScheme.onPrimaryContainer,
                onPressed: () => closeFlashCard(context),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.conceptTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.7,
                        ),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _revealed ? card.back : card.front,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (!_revealed)
                      FilledButton(
                        onPressed: () => setState(() => _revealed = true),
                        child: const Text('Reveal answer'),
                      )
                    else
                      FilledButton(
                        onPressed: () => closeFlashCard(context),
                        child: const Text('Got it'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Leaves the flash card: pops when there is a screen underneath, otherwise
/// (opened as the first route, e.g. from a cold-start notification) goes to
/// the dashboard so the learner is never left on a dead end.
void closeFlashCard(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router == null) {
    Navigator.of(context).maybePop();
  } else if (router.canPop()) {
    router.pop();
  } else {
    router.go(Routes.dashboard);
  }
}

/// Shown when the flash-card route is opened without usable card data
/// (lost route data after a restart, a deep link, or a malformed
/// notification payload) instead of crashing.
class FlashCardUnavailableScreen extends StatelessWidget {
  const FlashCardUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.style_outlined,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'This flash card is no longer available',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "New cards will arrive with your next reminder.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => closeFlashCard(context),
                  child: const Text('Back to Teacher'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
