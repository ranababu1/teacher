import '../../curriculum/domain/models/concept.dart';

/// One bite-sized piece of an explanation section.
class ExplanationChunk {
  const ExplanationChunk({
    required this.heading,
    required this.body,
    required this.part,
    required this.partCount,
  });

  final String heading;
  final String body;
  final int part;
  final int partCount;
}

/// Splits explanation sections into chunks that fit one phone screen.
///
/// Each section body is split into blocks on blank lines, keeping fenced
/// code blocks whole. Blocks are then packed in order into chunks of about
/// [targetChars] characters. A code block may stretch a chunk up to
/// [maxChars] so it stays with the paragraph that introduces it. A single
/// block longer than the limit becomes its own chunk (its card scrolls).
/// Chunks never cross section boundaries, so every chunk keeps its heading.
List<ExplanationChunk> chunkExplanation(
  List<ExplanationSection> sections, {
  int targetChars = 650,
  int maxChars = 1000,
}) {
  final chunks = <ExplanationChunk>[];
  for (final section in sections) {
    final bodies = <String>[];
    var current = <String>[];
    var length = 0;
    for (final block in splitBlocks(section.body)) {
      final isCode = block.startsWith('```');
      final limit = isCode ? maxChars : targetChars;
      if (current.isNotEmpty && length + block.length > limit) {
        bodies.add(current.join('\n\n'));
        current = [];
        length = 0;
      }
      current.add(block);
      length += block.length;
    }
    if (current.isNotEmpty) bodies.add(current.join('\n\n'));
    if (bodies.isEmpty && section.heading.trim().isEmpty) continue;
    if (bodies.isEmpty) bodies.add('');
    for (final (i, body) in bodies.indexed) {
      chunks.add(
        ExplanationChunk(
          heading: section.heading,
          body: body,
          part: i + 1,
          partCount: bodies.length,
        ),
      );
    }
  }
  return chunks;
}

/// Splits markdown into paragraph-level blocks on blank lines, never
/// splitting inside a ``` fence.
List<String> splitBlocks(String markdown) {
  final blocks = <String>[];
  final buffer = <String>[];
  var inFence = false;
  void flush() {
    final text = buffer.join('\n').trim();
    if (text.isNotEmpty) blocks.add(text);
    buffer.clear();
  }

  for (final line in markdown.split('\n')) {
    final isFence = line.trimLeft().startsWith('```');
    if (isFence && !inFence) {
      flush();
      inFence = true;
      buffer.add(line);
      continue;
    }
    if (isFence && inFence) {
      buffer.add(line);
      inFence = false;
      flush();
      continue;
    }
    if (!inFence && line.trim().isEmpty) {
      flush();
      continue;
    }
    buffer.add(line);
  }
  flush();
  return blocks;
}
