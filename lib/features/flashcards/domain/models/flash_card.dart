import 'dart:convert';

import 'package:equatable/equatable.dart';

/// A single byte-sized review prompt surfaced via a weekly-flashcard
/// notification. See instructions.md section 36.
class FlashCard extends Equatable {
  const FlashCard({
    required this.conceptId,
    required this.conceptTitle,
    required this.front,
    required this.back,
  });

  final String conceptId;
  final String conceptTitle;
  final String front;
  final String back;

  Map<String, dynamic> toJson() => {
    'conceptId': conceptId,
    'conceptTitle': conceptTitle,
    'front': front,
    'back': back,
  };

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      conceptId: json['conceptId'] as String,
      conceptTitle: json['conceptTitle'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
    );
  }

  /// Best-effort conversion of whatever arrived as navigation data (a
  /// [FlashCard], its JSON map, or a JSON string such as a notification
  /// payload) into a card. Returns `null` instead of throwing when the data
  /// is missing or malformed, e.g. route `extra` lost after the app was
  /// restored from the background or opened via a deep link.
  static FlashCard? tryParse(Object? raw) {
    try {
      if (raw is FlashCard) return raw;
      if (raw is String) raw = jsonDecode(raw);
      if (raw is Map) return FlashCard.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      // Fall through: malformed data is treated the same as missing data.
    }
    return null;
  }

  @override
  List<Object?> get props => [conceptId, conceptTitle, front, back];
}
