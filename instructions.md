# Teacher - AI-Powered Deep Learning App

## 1. Project Overview

Build a Flutter application called "Teacher" for android and then we ll plan for ios release.

Teacher is a serious personal learning platform designed to help the user learn technical subjects deeply rather than superficially.

The initial learning domains are:

- Python
- ReactJS

The architecture must make it easy to add additional subjects later, such as:

- Java
- Go
- Spring Boot
- Node.js
- AWS
- Docker
- Kubernetes
- System Design
- AI Engineering
- LLM Engineering
- Databases
- Cloud Architecture
- DevOps

The central product principle is:

> Teacher should teach until the learner can understand, explain, apply, debug, and independently use a concept.

Teacher must not become a simple content reader, chatbot wrapper, or MCQ application.

---

# 2. Product Philosophy

The learning loop should be:

```text
Learn
  ↓
Understand
  ↓
Practice
  ↓
Explain
  ↓
Apply
  ↓
Assess
  ↓
Detect Gaps
  ↓
Remediate OR Increase Difficulty
  ↓
Review Later
  ↓
Mastery
```

A learner should not be considered proficient merely because they answered a few questions correctly.

Teacher should evaluate multiple dimensions:

1. Conceptual understanding
2. Recall
3. Ability to explain
4. Ability to predict behavior
5. Ability to write code
6. Ability to debug code
7. Ability to apply knowledge to unfamiliar situations
8. Ability to connect the concept with prerequisite concepts
9. Long-term retention

---

# 3. Core Learning Philosophy

Avoid this:

```text
Topic
↓
Read explanation
↓
5 MCQs
↓
Completed
```

Prefer this:

```text
Assess current knowledge
↓
Teach concept
↓
Show examples
↓
Ask learner to reason
↓
Give guided practice
↓
Ask learner to explain
↓
Give coding/problem-solving exercise
↓
Evaluate response
↓
Identify misconceptions
↓
Remediate weak areas
↓
Increase difficulty
↓
Schedule review
```

The app should be adaptive.

If the learner already understands a concept, Teacher should move faster.

If the learner demonstrates a misconception, Teacher should slow down and explain the underlying concept.

---

# 4. Initial Scope

## Phase 1 - Foundation

Build:

- Flutter Windows application
- Dashboard
- Learning Paths
- Python learning path
- ReactJS learning path
- Topic navigation
- Concept/lesson viewer
- Basic progress tracking
- Local persistence
- Application settings
- Clean desktop UI

Do NOT introduce backend infrastructure initially.

## Phase 2 - Interactive Learning

Add:

- Knowledge checks
- Multiple-choice questions
- Short-answer questions
- Code prediction exercises
- Coding exercises
- Debugging exercises
- Explanation exercises
- Concept assessments
- Mastery scoring

## Phase 3 - AI Teacher

Add an AI provider abstraction and Gemini integration.

The AI should:

- Explain concepts
- Adapt explanations to learner level
- Ask questions
- Evaluate answers
- Detect misconceptions
- Generate examples
- Generate exercises
- Generate hints
- Generate remediation
- Adjust difficulty
- Recommend what to learn next

## Phase 4 - Adaptive Learning

Add:

- Learner knowledge model
- Concept mastery
- Prerequisite tracking
- Difficulty adaptation
- Spaced repetition
- Review scheduling
- Weakness detection
- Personalized learning paths

## Phase 5 - Advanced Learning

Eventually support:

- Projects
- Real-world scenarios
- Long-form coding challenges
- Debugging sessions
- System design exercises
- Interview preparation
- Skill assessments
- Learning analytics
- AI-generated personalized curriculum

---

# 5. Technology Stack

## Frontend

Use:

- Flutter
- Dart

Target:

- Android first

Keep the architecture compatible with future:

- IOS
- Web
- macOS

Do not introduce platform-specific code unless necessary.

## State Management

Use:

- Riverpod

Avoid Provider unless there is a compelling reason.

## Navigation

Use a clean routing solution compatible with Flutter and Riverpod.

Prefer:

- go_router

## Local Database

Use SQLite for local persistence.

Prefer:

- drift

The application should work offline for all non-AI functionality.

## AI

Create an abstraction:

```text
AIProvider
├── GeminiProvider
├── OpenAIProvider
└── LocalProvider
```

Only Gemini needs to be implemented initially.

Do not tightly couple the application to Gemini.

## Networking

Use a clean HTTP abstraction.

Prefer:

- dio

## Serialization

Use:

- json_serializable
- freezed where useful

## Code Quality

Use:

- flutter_lints
- strict typing
- meaningful names
- small focused classes
- dependency injection through Riverpod

---

# 6. Architecture

Use feature-oriented architecture.

Recommended structure:

```text
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   ├── database/
│   ├── errors/
│   ├── extensions/
│   ├── services/
│   ├── utils/
│   └── config/
│
├── shared/
│   ├── widgets/
│   ├── models/
│   └── theme/
│
└── features/
    │
    ├── dashboard/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── learning_paths/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── learning/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── practice/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── assessment/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── review/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── progress/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── ai_teacher/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    └── settings/
        ├── data/
        ├── domain/
        └── presentation/
```

Do not put business logic into widgets.

---

# 7. Main Application Navigation

Navigation should contain:

```text
Teacher
│
├── Dashboard
├── Learn
├── Practice
├── Review
├── Progress
└── Settings
```

The UI should feel like a professional developer tool, not a children's educational application.

Use:

- clean typography
- spacious layout
- subtle cards
- restrained colors
- clear hierarchy
- minimal visual noise
- responsive desktop layout

Avoid excessive:

- gradients. though keep subtle gradients
- cartoon illustrations
- badges everywhere
- gamification

---

# 8. Dashboard

The dashboard should show:

## Greeting

Example:

```text
Good evening
Ready to learn?
```

## Continue Learning

Show:

- current course
- current topic
- current concept
- progress
- Continue button

## Learning Progress

Example:

```text
Python       72%
ReactJS      41%
```

## Review Queue

Show:

```text
3 concepts due for review
```

## Recent Activity

Show:

- recently completed concepts
- assessment results
- current streak if implemented
- recent practice sessions

## Recommended Next Step

Teacher should eventually generate:

```text
Recommended next:
Python → Functions → Closures
```

with a short explanation of why.

---

# 9. Learning Paths

The Learning Paths screen should show available subjects.

Initial subjects:

```text
Python
ReactJS
```

Each learning path should have:

- title
- description
- difficulty
- overall progress
- number of concepts
- estimated learning time
- current position

Future subjects should be addable without changing the UI architecture.

---

# 10. Curriculum Model

Do not hard-code curriculum directly into widgets.

Represent the curriculum as data.

Conceptually:

```text
LearningPath
    ↓
Module
    ↓
Topic
    ↓
Concept
    ↓
Lesson
    ↓
Practice
    ↓
Assessment
```

Example:

```text
Python
└── Fundamentals
    ├── Python Runtime
    ├── Variables
    ├── Data Types
    ├── Operators
    └── Expressions

Python
└── Functions
    ├── Defining Functions
    ├── Parameters
    ├── Return Values
    ├── Scope
    ├── *args
    ├── **kwargs
    ├── Closures
    └── Decorators
```

---

# 11. Python Curriculum

The initial Python curriculum should be deep and structured.

Recommended progression:

## Module 1 - Python Foundations

- What Python is
- Python runtime
- Interpreted vs compiled concepts
- Variables
- Names and objects
- Dynamic typing
- Basic data types
- Numbers
- Strings
- Booleans
- None
- Operators
- Expressions
- Type conversion
- Input/output

## Module 2 - Control Flow

- if
- elif
- else
- for
- while
- break
- continue
- pass
- range
- nested control flow
- truthiness

## Module 3 - Collections

- Lists
- Tuples
- Sets
- Dictionaries
- Indexing
- Slicing
- Mutability
- Copying
- Shallow vs deep copy
- Comprehensions
- Iteration

## Module 4 - Functions

- Defining functions
- Parameters
- Arguments
- Return values
- Default arguments
- Keyword arguments
- *args
- **kwargs
- Scope
- LEGB
- First-class functions
- Lambda
- Closures
- Decorators

## Module 5 - Modules and Packages

- import
- from import
- module resolution
- packages
- __init__.py
- virtual environments
- pip
- dependency management

## Module 6 - Error Handling

- Exceptions
- try
- except
- else
- finally
- raise
- custom exceptions
- exception hierarchy

## Module 7 - Object-Oriented Python

- Classes
- Objects
- Attributes
- Methods
- Constructors
- Instance vs class attributes
- Inheritance
- Composition
- Polymorphism
- Encapsulation
- Abstract base classes
- Magic methods
- Dataclasses

## Module 8 - Pythonic Programming

- Iterators
- Iterables
- Generators
- yield
- Generator expressions
- Context managers
- with
- decorators
- functional programming concepts

## Module 9 - Files and Data

- File handling
- Paths
- JSON
- CSV
- Serialization
- Pickle awareness
- Encoding

## Module 10 - Async and Concurrency

- Processes
- Threads
- GIL
- asyncio
- async/await
- tasks
- futures
- concurrency vs parallelism

## Module 11 - Advanced Python

- descriptors
- metaclasses
- introspection
- memory model
- garbage collection
- performance
- profiling
- typing
- protocols
- generics

## Module 12 - Practical Python

Projects should eventually include:

- CLI application
- REST API
- automation script
- data processing application
- web scraper
- async application
- production-style service

---

# 12. ReactJS Curriculum

React should not be taught without JavaScript fundamentals.

Recommended progression:

## Module 1 - JavaScript Foundations

- variables
- let
- const
- types
- objects
- arrays
- functions
- scope
- closures
- this
- prototypes
- classes
- promises
- async/await
- modules
- destructuring
- spread/rest
- map/filter/reduce

## Module 2 - React Fundamentals

- Why React exists
- Components
- JSX
- Props
- State
- Events
- Rendering
- Conditional rendering
- Lists
- Keys

## Module 3 - Hooks

- useState
- useEffect
- useRef
- useMemo
- useCallback
- useContext
- Custom hooks

## Module 4 - State Architecture

- Local state
- Derived state
- Context
- Reducers
- State machines
- Server state
- Client state
- State ownership

## Module 5 - Rendering

- Render cycle
- Reconciliation
- Virtual DOM concepts
- Component lifecycle
- Effects
- Strict Mode
- Rendering behavior

## Module 6 - Performance

- Memoization
- React.memo
- useMemo
- useCallback
- profiling
- unnecessary renders
- code splitting
- lazy loading

## Module 7 - Advanced React

- component architecture
- composition
- controlled/uncontrolled components
- compound components
- render props
- custom hooks
- error boundaries
- Suspense
- concurrent rendering concepts

## Module 8 - Production React

- API integration
- forms
- validation
- authentication
- routing
- testing
- accessibility
- performance
- security
- deployment

## Module 9 - React Architecture

Eventually teach:

- feature-based architecture
- design systems
- state management decisions
- frontend architecture
- caching
- data fetching
- SSR/CSR concepts
- Next.js relationship
- large application architecture

---

# 13. Concept Model

Each concept should contain metadata similar to:

```text
Concept
├── id
├── title
├── description
├── subjectId
├── moduleId
├── topicId
├── difficulty
├── prerequisites[]
├── learningObjectives[]
├── explanation
├── examples[]
├── misconceptions[]
├── exercises[]
├── assessments[]
└── estimatedMinutes
```

Do not assume every concept needs exactly the same content.

The model should allow future content types.

---

# 14. Learning Objectives

Every concept should have explicit learning objectives.

Example:

```text
Concept: Python Closures

Objectives:

1. Explain what a closure is.
2. Explain how lexical scope affects closures.
3. Identify when a function forms a closure.
4. Predict the output of closure-based code.
5. Implement a closure.
6. Explain a practical use case.
7. Debug a closure-related bug.
```

Teacher should use these objectives to determine mastery.

---

# 15. Mastery Model

Do not use a single simplistic percentage.

Track multiple dimensions.

Example:

```text
ConceptMastery

conceptId

recallScore
understandingScore
applicationScore
explanationScore
codingScore
debuggingScore

overallMastery

attemptCount
successCount
failureCount

confidence

lastReviewedAt
nextReviewAt

status
```

Possible status:

```text
not_started
learning
developing
proficient
mastered
needs_review
```

Mastery should be evidence-based.

---

# 16. Assessment Types

Support these assessment types.

## Multiple Choice

Useful for:

- recall
- conceptual distinctions

Do not overuse.

## Short Answer

Example:

```text
Why does this Python code create a closure?
```

## Explain in Your Own Words

Teacher asks:

```text
Explain closures as if you were teaching another developer.
```

AI evaluates:

- correctness
- completeness
- misconceptions
- terminology

## Predict the Output

Example:

```python
x = 10

def test():
    print(x)

test()
```

Ask:

```text
What will this print and why?
```

## Debugging

Give broken code.

Ask learner to:

- identify issue
- explain cause
- fix it

## Coding

Small focused coding problems.

## Scenario

Example:

```text
You need to preserve state between function calls without using a class.

What Python construct could you use?
```

---

# 17. Assessment Difficulty

Difficulty should increase progressively.

Example:

```text
Level 1
Recall

Level 2
Recognition

Level 3
Prediction

Level 4
Application

Level 5
Debugging

Level 6
Design

Level 7
Novel problem solving
```

Do not jump from basic recall directly to advanced design.

---

# 18. Misconception Detection

Teacher should actively detect incorrect mental models.

Example:

Learner says:

> A Python variable stores the value directly.

Teacher should recognize that this is an oversimplification and explain:

```text
Python names refer to objects.
```

Then give a targeted example.

Misconceptions should be stored where useful:

```text
Misconception
├── conceptId
├── description
├── detectedAt
├── confidence
└── resolvedAt
```

---

# 19. AI Teacher Architecture

Create a domain abstraction:

```dart
abstract class AIProvider {
  Future<TeacherResponse> teach(TeacherRequest request);

  Future<AssessmentResult> assess(AssessmentRequest request);

  Future<Exercise> generateExercise(ExerciseRequest request);

  Future<ExplanationEvaluation> evaluateExplanation(
    ExplanationRequest request,
  );
}
```

Gemini implementation:

```text
GeminiProvider
```

AI calls must not happen directly from UI widgets.

Use:

```text
UI
 ↓
Riverpod Controller
 ↓
Use Case
 ↓
AI Teacher Service
 ↓
AI Provider
 ↓
Gemini
```

---

# 20. AI Context

Never send an isolated question to the AI if context is available.

Build a context object containing:

```text
Student profile
Current learning path
Current module
Current topic
Current concept
Prerequisites
Learning objectives
Current mastery
Recent mistakes
Known misconceptions
Previous attempts
Current difficulty
Current exercise
Learner response
```

This makes the AI adaptive.

---

# 21. AI Prompting Principles

The AI teacher should:

- be precise
- explain deeply
- avoid unnecessary jargon
- use practical examples
- ask one meaningful question at a time when appropriate
- avoid immediately revealing answers
- provide hints progressively
- challenge incorrect reasoning
- explicitly identify misconceptions
- adapt to demonstrated knowledge
- avoid fake encouragement
- never pretend the learner understands something they do not
- prefer reasoning over memorization

The AI should behave like a strong senior engineer who is also an excellent teacher.

---

# 22. Hint System

Hints should be progressive.

Example:

```text
Hint 1
Think about variable scope.

Hint 2
Which scope does Python search first?

Hint 3
Remember LEGB.

Hint 4
Look at the enclosing function.
```

Do not immediately expose the complete answer.

Track hint usage because heavy hint usage may indicate weak mastery.

---

# 23. Spaced Repetition

Teacher should eventually schedule concepts for review.

Basic approach:

```text
Poor performance
→ review soon

Good performance
→ review later

Excellent repeated performance
→ longer interval
```

Do not implement a complex algorithm prematurely.

Start with a configurable scheduling service so the algorithm can evolve later.

---

# 24. Local Database

Initial entities:

```text
learning_paths
modules
topics
concepts
learning_objectives

lessons
examples
exercises
questions
assessments

student_progress
concept_mastery
attempts
misconceptions
review_schedule

settings
```

Database access must remain behind repositories.

Example:

```text
UI
 ↓
Use Case
 ↓
Repository
 ↓
Drift DAO
 ↓
SQLite
```

Do not let widgets access SQLite directly.

---

# 25. Repository Pattern

Example:

```dart
abstract class ConceptRepository {
  Future<List<Concept>> getConcepts(String topicId);

  Future<Concept?> getConcept(String conceptId);

  Future<void> saveConcept(Concept concept);
}
```

Implementation:

```text
ConceptRepositoryImpl
```

This makes future migration to a remote backend easier.

---

# 26. Offline First

The app must remain usable without an internet connection.

Offline features:

- browse curriculum
- read lessons
- practice stored exercises
- review previous concepts
- view progress
- access completed content

AI features require internet unless a future local model is configured.

The UI should clearly communicate AI availability.

---

# 27. Security

Never hard-code API keys.

Do not put Gemini credentials directly in source code.

Create a secure configuration layer.

For initial development, environment-based configuration is acceptable.

Example conceptually:

```text
GEMINI_API_KEY
```

Never commit secrets.

Add:

```text
.env
```

to `.gitignore`.

---

# 28. Configuration

Create a configuration abstraction:

```text
AppConfig
├── environment
├── aiProvider
├── apiBaseUrl
└── featureFlags
```

Feature flags may eventually control:

- AI teacher
- advanced assessments
- experimental curriculum
- projects
- analytics

---

# 29. Seed Content

The first version should ship with local seed content.

Start with enough Python content to demonstrate the architecture.

Do NOT create hundreds of lessons initially.

Create a small but high-quality curriculum covering:

```text
Python Fundamentals
↓
Variables and Objects
↓
Data Types
↓
Control Flow
↓
Functions
↓
Scope
↓
Closures
```

This is enough to test:

- prerequisites
- lessons
- assessments
- mastery
- remediation
- progress

Then expand.

---

# 30. UI Screens

Implement these screens first.

## Dashboard

Route:

```text
/
```

## Learning Paths

Route:

```text
/learn
```

## Learning Path Detail

Example:

```text
/learn/python
```

## Topic Detail

Example:

```text
/learn/python/functions
```

## Lesson

Example:

```text
/learn/python/functions/closures
```

## Practice

```text
/practice
```

## Review

```text
/review
```

## Progress

```text
/progress
```

## Settings

```text
/settings
```

---

# 31. Lesson Screen

The lesson screen should support:

```text
Concept title

Learning objectives

Prerequisites

Explanation

Example

Interactive question

Try it

Your answer

Teacher feedback

Next challenge
```

Avoid making it a huge wall of text.

Break information into logical sections.

---

# 32. Code Display

Teacher is a developer-focused learning application.

Code blocks should be first-class UI components.

Features:

- syntax highlighting
- copy button
- line numbers where useful
- clear formatting
- expandable examples
- error highlighting for debugging exercises

Later support:

- editable code editor
- run code
- test cases

---

# 33. Coding Execution

Do NOT execute arbitrary learner code directly inside the Flutter process.

When code execution is introduced, use a sandboxed execution architecture.

Possible future approach:

```text
Flutter
 ↓
Execution API
 ↓
Sandbox
 ↓
Python Runtime
 ↓
Tests
 ↓
Result
```

Never expose the host machine directly to arbitrary code execution.

For the first version, coding exercises can be evaluated without execution.

---

# 34. Progress Screen

Show:

```text
Overall learning progress

Python
██████████░░ 72%

ReactJS
████░░░░░░░ 41%
```

Also show:

- concepts mastered
- concepts learning
- concepts needing review
- assessment accuracy
- coding performance
- explanation performance
- recent improvement

Avoid vanity metrics.

Progress should represent actual learning.

---

# 35. Review Screen

Show:

```text
Due for Review

3 concepts

1. Python Scope
2. Python Closures
3. List Comprehensions
```

Each review session should be short and focused.

Possible flow:

```text
Recall
↓
Question
↓
Answer
↓
Feedback
↓
Confidence
↓
Next review date
```

---

# 36. Settings

Initial settings:

```text
AI Provider
Gemini API configuration

Learning preferences
- Preferred explanation depth
- Daily learning target
- Difficulty preference

Weekly flash cards
- whatever weekly learning goal is set, from that topic/topics show full screen/ad-like information at random hours throughout the day for continuous learning

Appearance
- Light
- Dark
- System

Developer
- Debug mode
- AI request logging
```

Never expose sensitive API keys in logs.

---

# 37. Error Handling

Create application-level error handling.

Examples:

```text
NetworkUnavailable
AIUnavailable
InvalidAIResponse
DatabaseError
ContentNotFound
ConfigurationError
```

User-facing messages should be human and actionable.

Avoid exposing stack traces to normal users.

---

# 38. Logging

Use structured logging.

Log:

- app startup
- navigation errors
- database errors
- AI errors
- configuration errors

Do not log:

- API keys
- sensitive user data
- complete AI prompts containing private information
- private credentials

---

# 39. Testing Strategy

Testing is important.

## Unit Tests

Test:

- mastery calculations
- prerequisite logic
- review scheduling
- repositories
- curriculum parsing
- AI response parsing
- use cases

## Widget Tests

Test:

- dashboard
- lesson screen
- assessment UI
- progress UI

## Integration Tests

Eventually test:

```text
Start lesson
↓
Complete assessment
↓
Update mastery
↓
Schedule review
↓
Dashboard reflects progress
```

---

# 40. Code Quality Rules

Follow these rules strictly.

1. No business logic inside widgets.
2. No database calls directly from widgets.
3. No API calls directly from widgets.
4. No hard-coded secrets.
5. Avoid giant files.
6. Avoid giant widgets.
7. Prefer immutable models.
8. Use meaningful domain names.
9. Use async/await correctly.
10. Handle loading, success, empty, and error states.
11. Keep UI responsive.
12. Avoid premature abstractions.
13. Do not introduce dependencies without justification.
14. Keep features independently testable.

---

# 41. Responsive Design

- Primary target: Samsung s25 ultra but it should be responsive for other devices as well
- Use responsive layouts rather than fixed pixel positioning.

---

# 42. Theme

Create a central theme.

Support:

- light mode
- dark mode
- system mode

Keep colors centralized.

Do not hard-code colors throughout widgets.

Typography should prioritize readability.

---

# 43. Accessibility

Build accessibility into the UI.

Support:

- keyboard navigation
- semantic labels
- sufficient contrast
- readable font sizes
- focus states
- accessible buttons
- screen reader-friendly semantics where applicable

---

# 44. Gamification

Do not make gamification the core product.

Optional lightweight elements:

- learning streak
- completed concepts
- mastery milestones

Avoid:

- meaningless points
- excessive badges
- leaderboards

Learning quality matters more than engagement tricks.

---

# 45. Future User Model

Eventually support a learner profile:

```text
LearnerProfile

id

name

learningGoals[]

experienceLevel

preferredDepth

preferredDifficulty

dailyTargetMinutes

learningPreferences

careerGoals

knownSkills[]
```

This allows Teacher to personalize curriculum.

---

# 46. Future Skill Graph

Eventually model concepts as a graph:

```text
Variables
   ↓
Objects
   ↓
Functions
   ↓
Scope
   ↓
Closures
   ↓
Decorators
```

Each concept can have:

```text
prerequisites
dependents
relatedConcepts
```

Teacher can then answer:

> Why am I struggling with decorators?

by tracing prerequisite mastery.

---

# 47. Future Projects

After sufficient mastery, Teacher should assign projects.

Example:

```text
Python
→ Functions
→ Collections
→ Files
→ Exceptions
→ APIs
→ Async
```

Then:

```text
Build a CLI data-processing application.
```

Teacher evaluates:

- architecture
- correctness
- code quality
- error handling
- testing
- explanation

---

# 48. Future Interview Mode

Eventually support:

```text
Interview Mode
```

For:

- Python interviews
- React interviews
- Java interviews
- System design
- engineering management
- architecture

Teacher should dynamically interview the learner and adapt difficulty.

---

# 49. Future AI Agents

Do not implement multi-agent architecture in version 1.

Later, if useful, the architecture can evolve into:

```text
                    Teacher Orchestrator
                            │
           ┌────────────────┼────────────────┐
           ↓                ↓                ↓
     Curriculum Agent   Teaching Agent   Assessment Agent
           │                │                │
           └────────────────┼────────────────┘
                            ↓
                     Student Model
                            ↓
                     Learning Plan
```

Only introduce agents when they solve a real problem.

---

# 50. Development Phases

## Phase 0 - Environment

Verify:

```text
flutter --version
flutter doctor -v
flutter devices
```

Ensure Windows desktop tooling is configured.

## Phase 1 - Project Bootstrap

Create Flutter project:

```text
teacher
```

Configure:

- Riverpod
- go_router
- Drift
- Dio
- JSON serialization
- Freezed if needed
- linting

Run the default Windows application.

## Phase 2 - Architecture

Implement:

- app shell
- routing
- theme
- database layer
- repository abstractions
- feature folders
- configuration
- error handling

## Phase 3 - Core UI

Implement:

- sidebar
- dashboard
- learning paths
- lesson screen
- practice
- review
- progress
- settings

Use mock/local data initially.

## Phase 4 - Curriculum

Implement local curriculum data.

Start with:

```text
Python
├── Fundamentals
├── Variables and Objects
├── Data Types
├── Control Flow
├── Functions
├── Scope
└── Closures
```

Implement enough ReactJS content to validate multi-course architecture.

## Phase 5 - Persistence

Implement:

- SQLite
- progress
- attempts
- mastery
- review scheduling
- settings

## Phase 6 - Assessment

Implement:

- MCQ
- short answer
- prediction
- explanation
- debugging

## Phase 7 - AI

Implement:

- AIProvider
- GeminiProvider
- AI request/response models
- prompt templates
- AI error handling
- AI teacher UI

## Phase 8 - Adaptive Learning

Implement:

- learner model
- mastery engine
- misconception engine
- adaptive difficulty
- recommendation engine
- spaced repetition

## Phase 9 - Advanced Practice

Implement:

- coding challenges
- projects
- debugging sessions
- scenario-based problems

## Phase 10 - Production Hardening

Implement:

- robust error handling
- testing
- performance improvements
- secure configuration
- logging
- backup/export if useful
- packaging

---

# 51. MVP Definition

The first usable MVP is complete when the user can:

1. Open Teacher.
2. See Python and ReactJS.
3. Select Python.
4. Select a topic.
5. Open a concept.
6. Read a structured lesson.
7. Complete an exercise.
8. Receive feedback.
9. Have progress persisted locally.
10. See mastery update.
11. Return later.
12. Review previously learned concepts.

AI is NOT required for the first MVP.

---

# 52. First Vertical Slice

Before building the entire app, implement one complete learning journey.

Use:

```text
Python
↓
Functions
↓
Closures
```

The vertical slice should demonstrate:

```text
Dashboard
↓
Python
↓
Functions
↓
Closures
↓
Lesson
↓
Question
↓
Answer
↓
Assessment
↓
Mastery update
↓
Review scheduled
↓
Dashboard updated
```

This is more important than building 20 screens with fake functionality.

---

# 53. Development Principle: Vertical Slices

Prefer complete vertical functionality over large amounts of scaffolding.

Bad approach:

```text
Build all screens
↓
Build all database tables
↓
Build all repositories
↓
Build AI
↓
Connect everything
```

Better:

```text
Build one feature end-to-end
↓
Validate architecture
↓
Generalize
↓
Expand
```

---

# 54. Seed Data Strategy

Use strongly typed seed data.

Do not put large curriculum content inside Flutter widgets.

Possible structure:

```text
assets/
└── curriculum/
    ├── python/
    │   ├── fundamentals.json
    │   ├── variables.json
    │   ├── control_flow.json
    │   ├── functions.json
    │   └── closures.json
    │
    └── react/
        ├── javascript.json
        ├── fundamentals.json
        └── hooks.json
```

Load and validate these into the domain model.

The exact format may evolve after implementation.

---

# 55. Content Quality

Content must be technically accurate.

For programming topics:

- explain why, not only what
- show realistic examples
- explain edge cases
- explain common mistakes
- connect related concepts
- distinguish language behavior from implementation details
- avoid outdated practices
- avoid cargo-cult recommendations

For example, Python should not simply teach:

```python
def foo():
    pass
```

It should explain what functions mean in Python's object model, how arguments work, how scope works, and how the behavior matters in real code.

---

# 56. AI Content Validation

AI-generated content must not automatically become trusted curriculum.

Eventually introduce:

```text
Curriculum
↓
Authoritative content
↓
AI augmentation
```

The AI may explain, quiz, adapt, and generate exercises.

Core curriculum should remain controlled.

---

# 57. Data Model Principle

Keep these concepts separate:

```text
Curriculum
Student Progress
AI Session
Assessment Attempt
Review Schedule
```

Do not mix them into one giant model.

---

# 58. AI Session Model

Eventually:

```text
LearningSession
├── id
├── learnerId
├── conceptId
├── startedAt
├── endedAt
├── messages
├── exercises
├── assessmentResults
├── misconceptions
└── masteryDelta
```

This enables future analytics.

---

# 59. AI Response Safety

AI output must be parsed into typed structures where possible.

Prefer:

```text
JSON schema
↓
Validate
↓
Parse
↓
Domain model
↓
UI
```

Do not blindly render arbitrary AI-generated structured data.

If parsing fails:

1. retry if appropriate
2. fall back gracefully
3. show a human-readable error

---

# 60. Dependency Policy

Before adding a package:

1. Confirm it solves a real problem.
2. Prefer mature packages.
3. Check Flutter/Dart compatibility.
4. Avoid redundant packages.
5. Keep package count reasonable.

Document major architectural dependencies.

---

# 61. Git Strategy

Use Git from day one.

Recommended initial commits:

```text
chore: bootstrap flutter application
feat: add application shell
feat: add learning paths
feat: add curriculum domain model
feat: add first python lesson
feat: add local persistence
feat: add assessment engine
feat: add mastery tracking
feat: add review scheduling
feat: add ai teacher abstraction
feat: add gemini provider
```

Do not make giant commits containing unrelated work.

---

# 62. README

Create a useful README containing:

- project purpose
- architecture
- prerequisites
- setup
- development commands
- testing commands
- project structure
- AI configuration
- curriculum architecture
- contribution/development guidelines

---

# 63. Development Commands

Expected commands:

```powershell
flutter pub get
```

```powershell
flutter analyze
```

```powershell
flutter test
```

```powershell
flutter run -d windows
```

Eventually:

```powershell
dart format .
```

---

# 64. Definition of Done

A feature is not complete merely because the UI exists.

A feature is complete when:

- UI exists
- state management works
- domain logic works
- persistence works where required
- loading state exists
- empty state exists
- error state exists
- tests exist for important logic
- no analyzer errors
- no secrets are committed
- desktop layout works
- code is readable
- architecture remains clean

---

# 65. Claude Working Instructions

When implementing this project:

1. Inspect the existing repository before changing anything.
2. Do not overwrite existing work unnecessarily.
3. Preserve working functionality.
4. Implement incrementally.
5. Run `flutter analyze` after meaningful changes.
6. Run tests after meaningful changes.
7. Fix errors rather than ignoring them.
8. Do not leave placeholder implementations where real functionality is expected.
9. Do not create unnecessary abstractions.
10. Keep the first implementation simple.
11. Prefer complete vertical slices.
12. Do not implement future features prematurely.
13. Do not hard-code API secrets.
14. Keep curriculum content separate from UI.
15. Keep AI logic separate from UI.
16. Keep persistence behind repositories.
17. Keep domain logic testable.
18. Use strongly typed models.
19. Avoid giant files.
20. When a feature is finished, verify the complete user flow.

If something is ambiguous, prefer the simplest architecture that preserves future extensibility.

---

# 66. Immediate Implementation Order

Start here.

## Step 1

Inspect the environment:

```powershell
flutter --version
flutter doctor -v
flutter devices
```

## Step 2

I already created the flutter project Teacher:

```text
teacher
```

## Step 3

Configure dependencies and architecture.

## Step 4

Build the application shell:

```text
Sidebar
Main content
Theme
Routing
```

## Step 5

Build Dashboard.

## Step 6

Build Learning Paths.

## Step 7

Build Python path.

## Step 8

Build one complete lesson:

```text
Python
→ Functions
→ Closures
```

## Step 9

Add exercise and assessment.

## Step 10

Add local progress persistence.

## Step 11

Add mastery calculation.

## Step 12

Add review scheduling.

## Step 13

Run the complete vertical slice.

Only after this is stable should additional curriculum and AI be implemented.

---

# 67. First Target Experience

The first meaningful experience should feel like this:

```text
Teacher
    ↓
"Let's learn Python."
    ↓
"How familiar are you with Python?"
    ↓
Quick diagnostic
    ↓
Personalized starting point
    ↓
Lesson
    ↓
Teacher asks questions
    ↓
Learner answers
    ↓
Teacher identifies understanding
    ↓
Practice
    ↓
Assessment
    ↓
Mastery
    ↓
"You're ready for the next concept."
```

This experience is the heart of the application.

---

# 68. Long-Term Vision

Teacher should eventually become a personal technical mentor.

Not:

```text
Course player
```

Not:

```text
Chatbot
```

Not:

```text
Quiz app
```

Instead:

```text
Personal Technical Teacher
```

It should know:

- what the learner has learned
- what they understand
- what they misunderstand
- what they repeatedly get wrong
- what prerequisites are weak
- what they are ready to learn
- when they should review something
- what practical problems they can solve
- where their skills are strong
- where their skills are weak

The ultimate loop:

```text
                   LEARNER
                      │
                      ↓
               Student Model
                      │
                      ↓
               Learning Graph
                      │
                      ↓
                Teacher Engine
                      │
             ┌────────┼────────┐
             ↓        ↓        ↓
          Teach    Practice  Assess
             │        │        │
             └────────┼────────┘
                      ↓
                 New Evidence
                      │
                      ↓
               Student Model
                      │
                      ↓
              Adaptive Plan
```

That is the product we are building.
The quality of the learning architecture is more important than the number of features.

---

# 69. Git and GitHub Enforcement

GitHub synchronization is a mandatory part of the development workflow.

The repository must NOT be allowed to accumulate large amounts of unpushed work.

Mandatory Rule
Never add "co-authored by..." messages while pushing to github.
Every meaningful implementation increment MUST follow this sequence:

Implement
↓
Test
↓
Analyze
↓
Update changelog.md
↓
Commit
↓
Push to GitHub
↓
Verify push succeeded
↓
Continue to next increment
A feature or task is NOT considered complete until the corresponding changes have been successfully pushed to GitHub.

Do not defer GitHub pushes.

Do not accumulate multiple unrelated features and push them together.

Do not say or imply:

“I’ll push this later.”
“I’ll push everything at the end.”
“The changes are ready and can be pushed later.”
“GitHub sync can be done after the current phase.”
The default behavior MUST be to commit and push incremental changes immediately after a meaningful unit of work is complete.

What Counts as a Meaningful Increment
Examples:

Add application shell
Add routing
Add dashboard
Add learning path model
Add Python curriculum
Add lesson screen
Add assessment engine
Add mastery calculation
Add review scheduling
Add Gemini integration
Fix authentication/configuration
Fix major UI issue
Fix major architecture issue
Each meaningful increment should normally result in its own commit and push.

Do not create one giant commit containing several unrelated features.

Required Git Workflow
Before starting work:

git status
git branch --show-current
git remote -v
git log -5 --oneline
After implementing a meaningful increment:

flutter analyze
flutter test
Then inspect the changes:

git status
git diff
Update:

changelog.md
with the changes made during this increment.

Then commit:

git add <specific-files>
git commit -m "<appropriate conventional commit message>"
Immediately push:

git push
Then verify:

git status
git log -1 --oneline
The working tree should normally be clean after the push.

GitHub Push Is Mandatory
The following is a hard requirement:

NEVER finish an implementation increment with unpushed Git changes unless the user explicitly instructs you not to push.

If code has been changed and the work is complete enough to commit, it MUST be committed and pushed.

If the push fails:

Inspect the error.
Determine the cause.
Fix the issue if it is safe to do so.
Retry the push.
Verify that the push succeeded.
Only then report the work as complete.
Do NOT simply report:

Push failed.
and consider the task complete.

If a push cannot be completed because of credentials, permissions, authentication, network, branch protection, merge conflicts, or another external blocker, explicitly state:

IMPLEMENTATION STATUS: COMPLETE
GITHUB PUSH STATUS: BLOCKED
REASON: <exact reason>
Do not falsely claim that the work was pushed.

Never Accumulate Unpushed Work
Do not allow multiple completed features to remain uncommitted or unpushed.

For example, this is NOT acceptable:

Dashboard
+
Learning Paths
+
Python Curriculum
+
Assessment
+
Progress
+
Review
↓
One giant commit
↓
One GitHub push
Prefer:

Dashboard
↓
commit
↓
push

Learning Paths
↓
commit
↓
push

Python Curriculum
↓
commit
↓
push

Assessment
↓
commit
↓
push
This provides clear visibility into development history and makes rollback, review, debugging, and context recovery much easier.

Commit Messages
Use clear conventional commit messages.

Examples:

chore: bootstrap flutter application
feat: add application shell
feat: add learning paths
feat: add python curriculum
feat: add closures lesson
feat: add assessment engine
feat: add mastery tracking
feat: add review scheduling
feat: add ai teacher abstraction
feat: add gemini provider
fix: correct lesson progress calculation
fix: handle empty review queue
refactor: separate curriculum repository
test: add mastery engine coverage
Do not use meaningless messages such as:

update
changes
stuff
fix
work
latest
Changelog Requirement
changelog.md is a mandatory project context file.

Every meaningful implementation increment MUST update:

changelog.md
before committing.

The changelog entry should contain:

date
short summary
features added
fixes made
architectural changes where relevant
tests/verification performed
commit hash if known
Example:

## 2026-08-14

### Added
- Added the initial Teacher application shell.
- Added dashboard navigation.
- Added Python learning path structure.

### Verification
- flutter analyze: passed
- flutter test: passed

### Git
- Commit: abc1234
- Pushed to GitHub: yes
The changelog update MUST be included in the same commit as the implementation it describes.

Do not create a separate later commit merely for documenting completed work unless there is a specific reason.

Start of Every New Claude Session
At the beginning of every new development session, BEFORE making changes:

git status
git branch --show-current
git log -10 --oneline
Then read:

changelog.md
This is mandatory.

Use the changelog and Git history to understand:

what was recently implemented
what was already pushed
what remains incomplete
the most recent commit
the current development direction
Do not assume previous work from conversation history is sufficient.

The repository is the source of truth.

End of Every Claude Response
When reporting completed implementation work, always include:

Implementation:
<what was implemented>

Verification:
<tests/analyze performed>

Git:
Commit: <commit hash>
Push: SUCCESS
Branch: <branch name>
Working tree: clean
If GitHub push was blocked:

Implementation:
<what was implemented>

Verification:
<tests/analyze performed>

Git:
Commit: <commit hash>
Push: BLOCKED
Reason: <exact reason>

The implementation is NOT considered fully complete until the changes are successfully pushed.
Never claim Push: SUCCESS unless the push command actually succeeded.

Git Safety Rules
Claude MUST NOT perform destructive Git operations without explicit user permission.

Never automatically:

git reset --hard
git clean -fd
git push --force
git push --force-with-lease
git rebase
git checkout -- <files>
git restore <files>
if these operations could discard or rewrite existing work.

If such an operation appears necessary, stop and ask for explicit permission.

Never overwrite another developer’s work.

Never rewrite published Git history without explicit permission.

Branch Rules
Work on the current branch unless the user explicitly requests a different branch strategy.

Before pushing, verify:

git branch --show-current
Never accidentally push implementation work to an unexpected branch.

If the current branch is unclear or appears unsafe to push to, stop and ask.

GitHub Is Part of the Definition of Done
A development increment is considered complete only when:

implementation is complete
tests pass
analyzer passes
changelog is updated
changes are committed
commit exists locally
changes are pushed to GitHub
push is verified
working tree is clean
Therefore:

“Implemented” does not mean “done”.

“Implemented + verified + committed + pushed” means “done”.

This rule takes priority over convenience.


# 70. Success Criteria

Teacher succeeds if, after using it for a subject, the learner can:

explain concepts without memorized wording
predict behavior
write working code
debug unfamiliar code
recognize incorrect assumptions
connect concepts together
solve practical problems
retain knowledge over time
learn progressively harder concepts independently
The objective is not:

“I completed the Python course.”

The objective is:

“I actually understand Python and can use it.”
