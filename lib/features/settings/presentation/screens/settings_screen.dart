import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/async_value_view.dart';
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
                      "Periodic reminders from this week's learning goal, shown throughout "
                      'the day.',
                    ),
                    value: settings.weeklyFlashcardsEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setWeeklyFlashcardsEnabled(value);
                    },
                  ),
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
