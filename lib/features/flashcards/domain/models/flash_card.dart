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

  @override
  List<Object?> get props => [conceptId, conceptTitle, front, back];
}
