import 'package:flutter/material.dart';

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
                onPressed: () => Navigator.of(context).maybePop(),
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
                        color: theme.colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.7),
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
                        onPressed: () => Navigator.of(context).maybePop(),
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
