import 'package:equatable/equatable.dart';

import '../../../curriculum/domain/models/concept.dart';

class DashboardRecommendation extends Equatable {
  const DashboardRecommendation({
    required this.concept,
    required this.learningPathTitle,
    required this.moduleTitle,
    required this.reason,
  });

  final Concept concept;
  final String learningPathTitle;
  final String moduleTitle;
  final String reason;

  @override
  List<Object?> get props => [concept, learningPathTitle, moduleTitle, reason];
}
