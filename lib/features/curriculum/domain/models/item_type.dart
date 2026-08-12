/// Shared type tag for both practice [Exercise]s and formal [Assessment]s.
///
/// See instructions.md section 16.
enum ItemType {
  multipleChoice,
  shortAnswer,
  predictOutput,
  debugging,
  coding,
  explanation,
  scenario;

  static ItemType fromJson(String value) {
    return ItemType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => ItemType.shortAnswer,
    );
  }

  /// Whether this item type can be graded deterministically without a
  /// human or AI in the loop (exact-match style comparison).
  bool get isAutoGradable =>
      this == ItemType.multipleChoice || this == ItemType.predictOutput;

  String get label => switch (this) {
        ItemType.multipleChoice => 'Multiple Choice',
        ItemType.shortAnswer => 'Short Answer',
        ItemType.predictOutput => 'Predict the Output',
        ItemType.debugging => 'Debugging',
        ItemType.coding => 'Coding',
        ItemType.explanation => 'Explain in Your Own Words',
        ItemType.scenario => 'Scenario',
      };
}
