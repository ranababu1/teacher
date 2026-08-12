import 'package:equatable/equatable.dart';

class TeacherRequest extends Equatable {
  const TeacherRequest({required this.context, required this.learnerMessage});

  final Object
  context; // TeachingContext — kept loose until a provider consumes it
  final String? learnerMessage;

  @override
  List<Object?> get props => [context, learnerMessage];
}

class TeacherResponse extends Equatable {
  const TeacherResponse({required this.explanation, this.followUpQuestion});

  final String explanation;
  final String? followUpQuestion;

  @override
  List<Object?> get props => [explanation, followUpQuestion];
}

class AssessmentRequest extends Equatable {
  const AssessmentRequest({
    required this.context,
    required this.learnerResponse,
  });

  final Object context;
  final String learnerResponse;

  @override
  List<Object?> get props => [context, learnerResponse];
}

class AssessmentResult extends Equatable {
  const AssessmentResult({
    required this.isCorrect,
    required this.feedback,
    required this.detectedMisconceptions,
  });

  final bool isCorrect;
  final String feedback;
  final List<String> detectedMisconceptions;

  @override
  List<Object?> get props => [isCorrect, feedback, detectedMisconceptions];
}

class ExerciseRequest extends Equatable {
  const ExerciseRequest({required this.context});

  final Object context;

  @override
  List<Object?> get props => [context];
}

class ExplanationRequest extends Equatable {
  const ExplanationRequest({
    required this.context,
    required this.learnerExplanation,
  });

  final Object context;
  final String learnerExplanation;

  @override
  List<Object?> get props => [context, learnerExplanation];
}

class ExplanationEvaluation extends Equatable {
  const ExplanationEvaluation({
    required this.isCorrect,
    required this.isComplete,
    required this.feedback,
    required this.detectedMisconceptions,
  });

  final bool isCorrect;
  final bool isComplete;
  final String feedback;
  final List<String> detectedMisconceptions;

  @override
  List<Object?> get props => [
    isCorrect,
    isComplete,
    feedback,
    detectedMisconceptions,
  ];
}
