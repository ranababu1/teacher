import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/item_type.dart';

enum ItemKind { exercise, assessment }

/// Domain representation of a persisted attempt row.
class Attempt extends Equatable {
  const Attempt({
    required this.id,
    required this.conceptId,
    required this.itemId,
    required this.itemKind,
    required this.itemType,
    required this.isCorrect,
    required this.selfRating,
    required this.hintsUsed,
    required this.userResponse,
    required this.createdAt,
  });

  final int id;
  final String conceptId;
  final String itemId;
  final ItemKind itemKind;
  final ItemType itemType;
  final bool? isCorrect;
  final int? selfRating;
  final int hintsUsed;
  final String? userResponse;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    conceptId,
    itemId,
    itemKind,
    itemType,
    isCorrect,
    selfRating,
    hintsUsed,
    userResponse,
    createdAt,
  ];
}
