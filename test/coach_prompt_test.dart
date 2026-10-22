import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/ai_teacher/data/shared_prompt_builder.dart';
import 'package:teacher/features/ai_teacher/domain/models/study_coaching.dart';
import 'package:teacher/features/settings/domain/settings_models.dart';

void main() {
  test('coach prompt numbers the plan, includes goal and asks for N tips', () {
    final prompt = buildCoachStudyPlanPrompt(
      const StudyCoachingRequest(
        learnerSummary: 'Python: 3 of 10 topics passed.',
        planSteps: ['Review 2 due concepts', 'Learn Generators'],
        careerGoal: 'Data engineer',
      ),
      depth: ExplanationDepth.standard,
      outputInstruction: 'JSON only.',
    );
    expect(prompt.userContent, contains('Python: 3 of 10 topics passed.'));
    expect(prompt.userContent, contains('Career goal: Data engineer'));
    expect(prompt.userContent, contains('1. Review 2 due concepts'));
    expect(prompt.userContent, contains('2. Learn Generators'));
    expect(prompt.userContent, contains('exactly 2 short tips'));
    expect(prompt.systemInstruction, contains('study coach'));
    expect(prompt.systemInstruction, contains('JSON only.'));
  });

  test('blank goal is left out', () {
    final prompt = buildCoachStudyPlanPrompt(
      const StudyCoachingRequest(
        learnerSummary: 's',
        planSteps: ['a'],
        careerGoal: '  ',
      ),
      depth: ExplanationDepth.standard,
      outputInstruction: '',
    );
    expect(prompt.userContent, isNot(contains('Career goal')));
  });
}
