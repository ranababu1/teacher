import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/async_value_view.dart';
import '../../../flashcards/domain/models/flash_card.dart';
import '../../../flashcards/presentation/providers/flashcard_providers.dart';
import '../../domain/settings_models.dart';
import '../providers/settings_providers.dart';
import '../widgets/api_key_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsValue = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: AsyncValueView(
          value: settingsValue,
          onRetry: () => ref.invalidate(settingsControllerProvider),
          data: (settings) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionCard(
                title: 'AI Provider',
                children: [ApiKeySection()],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Learning Preferences',
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Preferred explanation depth'),
                    subtitle: Text(_depthLabel(settings.explanationDepth)),
                    trailing: DropdownButton<ExplanationDepth>(
                      value: settings.explanationDepth,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setExplanationDepth(value);
                        }
                      },
                      items: ExplanationDepth.values
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(_depthLabel(d)),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Daily learning target'),
                    subtitle: Text(
                      '${settings.dailyTargetMinutes} minutes / day',
                    ),
                    trailing: SizedBox(
                      width: 160,
                      child: Slider(
                        value: settings.dailyTargetMinutes.toDouble(),
                        min: 5,
                        max: 120,
                        divisions: 23,
                        label: '${settings.dailyTargetMinutes} min',
                        onChanged: (value) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setDailyTargetMinutes(value.round());
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Difficulty preference'),
                    subtitle: Text(
                      _difficultyLabel(settings.difficultyPreference),
                    ),
                    trailing: DropdownButton<DifficultyPreference>(
                      value: settings.difficultyPreference,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setDifficultyPreference(value);
                        }
                      },
                      items: DifficultyPreference.values
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(_difficultyLabel(d)),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Weekly Flash Cards',
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Enable weekly flash cards'),
                    subtitle: const Text(
                      "Byte-sized reviews of what you've learned this week, "
                      'shown as notifications throughout the day.',
                    ),
                    value: settings.weeklyFlashcardsEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setWeeklyFlashcardsEnabled(value);
                    },
                  ),
                  if (settings.weeklyFlashcardsEnabled) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Daily volume'),
                      subtitle: Text(
                        '${settings.flashcardVolume.notificationsPerDay} '
                        'notifications a day',
                      ),
                      trailing: DropdownButton<FlashcardVolume>(
                        value: settings.flashcardVolume,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .setFlashcardVolume(value);
                          }
                        },
                        items: FlashcardVolume.values
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(_volumeLabel(v)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Frequency'),
                      subtitle: Text(
                        settings.flashcardFrequencyMode ==
                                FlashcardFrequencyMode.random
                            ? 'Random times through the day'
                            : 'Times you choose below',
                      ),
                      trailing: DropdownButton<FlashcardFrequencyMode>(
                        value: settings.flashcardFrequencyMode,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .setFlashcardFrequencyMode(value);
                          }
                        },
                        items: FlashcardFrequencyMode.values
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m == FlashcardFrequencyMode.random
                                      ? 'Random'
                                      : 'Fixed',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (settings.flashcardFrequencyMode ==
                        FlashcardFrequencyMode.fixed)
                      _FixedTimesEditor(times: settings.flashcardFixedTimes),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Appearance',
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'light',
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: 'dark',
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                      ButtonSegment(
                        value: 'system',
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                    ],
                    selected: {settings.themeModeKey},
                    onSelectionChanged: (selection) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setThemeMode(selection.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Developer',
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Debug mode'),
                    value: settings.debugMode,
                    onChanged: (value) => ref
                        .read(settingsControllerProvider.notifier)
                        .setDebugMode(value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('AI request logging'),
                    subtitle: const Text(
                      'Logs request metadata only — never prompts or keys.',
                    ),
                    value: settings.aiRequestLogging,
                    onChanged: (value) => ref
                        .read(settingsControllerProvider.notifier)
                        .setAiRequestLogging(value),
                  ),
                  if (settings.debugMode) const _SendTestFlashcardButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _depthLabel(ExplanationDepth depth) => switch (depth) {
    ExplanationDepth.concise => 'Concise',
    ExplanationDepth.standard => 'Standard',
    ExplanationDepth.deep => 'Deep',
  };

  String _difficultyLabel(DifficultyPreference preference) =>
      switch (preference) {
        DifficultyPreference.relaxed => 'Relaxed',
        DifficultyPreference.standard => 'Standard',
        DifficultyPreference.challenging => 'Challenging',
      };

  String _volumeLabel(FlashcardVolume volume) => switch (volume) {
    FlashcardVolume.low => 'Low',
    FlashcardVolume.medium => 'Medium',
    FlashcardVolume.high => 'High',
  };
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Lets the learner add/remove the specific times of day flash card
/// notifications fire when [FlashcardFrequencyMode.fixed] is selected.
class _FixedTimesEditor extends ConsumerWidget {
  const _FixedTimesEditor({required this.times});

  final List<String> times;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...times]..sort();

    Future<void> addTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked == null) return;
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
      if (sorted.contains(formatted)) return;
      ref
          .read(settingsControllerProvider.notifier)
          .setFlashcardFixedTimes([...sorted, formatted]);
    }

    void removeTime(String time) {
      ref
          .read(settingsControllerProvider.notifier)
          .setFlashcardFixedTimes(sorted.where((t) => t != time).toList());
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final time in sorted)
            Chip(
              label: Text(time),
              onDeleted: sorted.length > 1 ? () => removeTime(time) : null,
            ),
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: const Text('Add time'),
            onPressed: addTime,
          ),
        ],
      ),
    );
  }
}

/// Developer-only action to verify the full tap-to-open flow (notification
/// -> full-screen card) without waiting for a real scheduled time.
class _SendTestFlashcardButton extends ConsumerStatefulWidget {
  const _SendTestFlashcardButton();

  @override
  ConsumerState<_SendTestFlashcardButton> createState() =>
      _SendTestFlashcardButtonState();
}

class _SendTestFlashcardButtonState
    extends ConsumerState<_SendTestFlashcardButton> {
  bool _sending = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    final service = ref.read(flashcardNotificationServiceProvider);
    try {
      await service.initialize();
      final granted = await service.requestPermission();
      if (!granted) {
        _showMessage('Notification permission was not granted.');
        return;
      }
      await service.sendTestNotification(
        const FlashCard(
          conceptId: 'test',
          conceptTitle: 'Test flash card',
          front: 'This is a test flash card notification.',
          back: "If you can see this, the notification and tap-to-open flow both work.",
        ),
      );
      _showMessage('Test notification sent — it should arrive in a few seconds.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: _sending ? null : _send,
        icon: _sending
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.notifications_active_outlined, size: 16),
        label: Text(_sending ? 'Sending...' : 'Send test flash card notification'),
      ),
    );
  }
}
