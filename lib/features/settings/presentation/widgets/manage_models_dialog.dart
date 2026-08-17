import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/settings_models.dart';
import '../providers/settings_providers.dart';

/// Lets the learner add, rename, or remove custom model ids for one AI
/// provider. The provider's built-in default (from `AppConfig`) is shown
/// locked at the top and can never be edited or removed — only entries
/// the learner has added themselves can be changed.
class ManageModelsDialog extends ConsumerStatefulWidget {
  const ManageModelsDialog({
    super.key,
    required this.provider,
    required this.baselineModel,
  });

  final AiProviderKind provider;
  final String baselineModel;

  @override
  ConsumerState<ManageModelsDialog> createState() =>
      _ManageModelsDialogState();
}

class _ManageModelsDialogState extends ConsumerState<ManageModelsDialog> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _addModel() async {
    final value = _addController.text.trim();
    if (value.isEmpty) return;
    await ref
        .read(settingsControllerProvider.notifier)
        .addCustomModel(widget.provider, value);
    _addController.clear();
  }

  Future<void> _editModel(String current) async {
    final renamed = await _promptForModelId(
      context,
      title: 'Rename model',
      initialValue: current,
    );
    if (renamed == null || renamed == current) return;
    await ref
        .read(settingsControllerProvider.notifier)
        .renameCustomModel(widget.provider, current, renamed);
  }

  Future<void> _removeModel(String model) async {
    await ref
        .read(settingsControllerProvider.notifier)
        .removeCustomModel(widget.provider, model);
  }

  @override
  Widget build(BuildContext context) {
    final customModels =
        ref.watch(settingsControllerProvider).valueOrNull?.customModelsByProvider[widget.provider] ??
        const <String>[];

    return AlertDialog(
      title: Text('${widget.provider.displayName} models'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline, size: 18),
              title: Text(widget.baselineModel),
              subtitle: const Text('Default — cannot be edited or removed'),
            ),
            for (final model in customModels)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(model),
                trailing: Wrap(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Rename',
                      onPressed: () => _editModel(model),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      tooltip: 'Remove',
                      onPressed: () => _removeModel(model),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: const InputDecoration(
                      hintText: 'Add a model id',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addModel(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add model',
                  onPressed: _addModel,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

Future<String?> _promptForModelId(
  BuildContext context, {
  required String title,
  required String initialValue,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
