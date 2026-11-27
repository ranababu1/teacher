// App Store screenshot generator. Not part of the regular test suite.
//
// Run: flutter test tool/screenshots/app_store_screenshots_test.dart
// Output: build/screenshots/<device>/NN-name.png
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/app/app.dart';
import 'package:teacher/app/router.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/database/database_provider.dart';

const _outDir = String.fromEnvironment(
  'SHOTS_OUT',
  defaultValue: 'build/screenshots',
);

class _Device {
  const _Device(this.name, this.size, this.dpr, this.top, this.bottom);
  final String name;
  final Size size; // logical
  final double dpr;
  final double top;
  final double bottom;
}

const _devices = [
  _Device('iphone69', Size(440, 956), 3, 62, 34),
  _Device('ipad13', Size(1032, 1376), 2, 24, 20),
];

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<void> _loadFonts() async {
  final sdk =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  // Prefer the blank-.notdef copies from prepare_fonts.py (see there).
  final fonts = Directory('$_outDir/fonts').existsSync()
      ? '$_outDir/fonts'
      : 'assets/fonts';
  await _loadFont('Atkinson Hyperlegible', [
    for (final s in ['Regular', 'Bold', 'Italic', 'BoldItalic'])
      '$fonts/AtkinsonHyperlegible-$s.ttf',
  ]);
  final mat = '$sdk/bin/cache/artifacts/material_fonts';
  await _loadFont('MaterialIcons', ['$mat/MaterialIcons-Regular.otf']);
  await _loadFont(_emojiFamily, [
    Platform.environment['SHOTS_EMOJI_FONT'] ??
        '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
  ]);
  await _loadFont('Roboto', [
    '$mat/Roboto-Regular.ttf',
    '$mat/Roboto-Bold.ttf',
    '$mat/Roboto-Medium.ttf',
  ]);
  final mono =
      Platform.environment['SHOTS_MONO_FONT'] ??
      '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf';
  if (File(mono).existsSync()) {
    await _loadFont('monospace', [mono]);
  }
  final cupertino =
      Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev')
          .listSync()
          .whereType<Directory>()
          .where((d) => d.path.contains('cupertino_icons-'))
          .toList();
  if (cupertino.isNotEmpty) {
    await _loadFont('packages/cupertino_icons/CupertinoIcons', [
      '${cupertino.last.path}/assets/CupertinoIcons.ttf',
    ]);
  }
}

Future<void> _seed(AppDatabase db, {required bool dark}) async {
  Future<void> set(String k, String v) => db
      .into(db.settingsTable)
      .insertOnConflictUpdate(SettingsTableCompanion.insert(key: k, value: v));
  await set('learner_name', 'Imran');
  await set('learner_career_goal', 'Backend engineer');
  await set('learner_has_onboarded', 'true');
  await set('theme_mode', dark ? 'dark' : 'light');

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 9);
  DateTime daysAgo(int d, [int h = 0]) =>
      today.subtract(Duration(days: d)).add(Duration(hours: h));

  for (final path in ['python', 'react']) {
    await db
        .into(db.learningPathProgressTable)
        .insertOnConflictUpdate(
          LearningPathProgressTableCompanion.insert(
            learningPathId: path,
            startedAt: daysAgo(12),
          ),
        );
  }
  // Completed modules: (path, module, concepts, module test passed).
  const done = [
    (
      'python',
      'basics-and-io',
      [
        'python-syntax-basics',
        'python-strings',
        'python-numbers-operators',
        'python-input-output',
      ],
      true,
    ),
    (
      'python',
      'fundamentals',
      ['python-variables-objects', 'python-data-types'],
      true,
    ),
    ('python', 'control-flow', ['python-control-flow'], true),
    (
      'python',
      'collections',
      [
        'python-lists',
        'python-tuples',
        'python-sets',
        'python-dictionaries',
        'python-comprehensions',
      ],
      true,
    ),
    ('react', 'javascript-foundations', ['js-closures-scope'], true),
    (
      'react',
      'js-language-deep-dive',
      ['js-data-types-and-variables', 'js-functions', 'js-arrays'],
      false,
    ),
  ];
  const scores = [
    0.92,
    0.86,
    0.78,
    0.81,
    0.74,
    0.69,
    0.88,
    0.83,
    0.64,
    0.58,
    0.71,
    0.52,
  ];
  var i = 0;
  var day = 15;
  for (final (pathId, moduleId, concepts, passed) in done) {
    for (final concept in concepts) {
      final when = daysAgo(day > 0 ? day : 0, i % 5);
      await db
          .into(db.studentProgressTable)
          .insertOnConflictUpdate(
            StudentProgressTableCompanion.insert(
              conceptId: concept,
              learningPathId: pathId,
              moduleId: moduleId,
              startedAt: Value(when),
              completedAt: Value(when.add(const Duration(minutes: 25))),
              lastAccessedAt: Value(when.add(const Duration(minutes: 25))),
            ),
          );
      final m = scores[i % scores.length];
      await db
          .into(db.conceptMasteryTable)
          .insertOnConflictUpdate(
            ConceptMasteryTableCompanion.insert(
              conceptId: concept,
              recallScore: Value(m + 0.05 > 1 ? 1 : m + 0.05),
              understandingScore: Value(m),
              applicationScore: Value(m - 0.08),
              explanationScore: Value(m - 0.04),
              codingScore: Value(m - 0.1),
              debuggingScore: Value(m - 0.12),
              overallMastery: Value(m),
              attemptCount: const Value(6),
              successCount: Value((6 * m).round()),
              failureCount: Value(6 - (6 * m).round()),
              confidence: Value(m),
              lastReviewedAt: Value(when),
              nextReviewAt: Value(daysAgo(i.isEven ? 0 : -3)),
              status: Value(
                m >= 0.85
                    ? 'mastered'
                    : m >= 0.7
                    ? 'proficient'
                    : 'developing',
              ),
            ),
          );
      await db
          .into(db.reviewScheduleTable)
          .insertOnConflictUpdate(
            ReviewScheduleTableCompanion.insert(
              conceptId: concept,
              dueAt: daysAgo(i.isEven ? 1 : -3),
              intervalDays: const Value(3),
              lastReviewedAt: Value(when),
              reviewCount: const Value(2),
            ),
          );
      for (var k = 0; k < 3; k++) {
        await db
            .into(db.attemptsTable)
            .insert(
              AttemptsTableCompanion.insert(
                conceptId: concept,
                itemId: '$concept-q$k',
                itemKind: 'exercise',
                itemType: 'multipleChoice',
                isCorrect: Value(k != 2 || m > 0.75),
                createdAt: when.add(Duration(minutes: 10 + k)),
              ),
            );
      }
      i++;
      if (day > 0) day--;
    }
    if (!passed) continue;
    await db
        .into(db.moduleTestProgressTable)
        .insertOnConflictUpdate(
          ModuleTestProgressTableCompanion.insert(
            learningPathId: pathId,
            moduleId: moduleId,
            passedAt: daysAgo(day),
            scorePercent: 85,
            questionCount: 10,
          ),
        );
  }
  // Daily activity for a streak.
  for (var d = 0; d < 9; d++) {
    await db
        .into(db.attemptsTable)
        .insert(
          AttemptsTableCompanion.insert(
            conceptId: 'python-lists',
            itemId: 'review-$d',
            itemKind: 'exercise',
            itemType: 'multipleChoice',
            isCorrect: const Value(true),
            createdAt: daysAgo(d, 2),
          ),
        );
  }
  // In progress: Functions.
  for (final c in ['python-functions-basics', 'python-scope']) {
    await db
        .into(db.studentProgressTable)
        .insertOnConflictUpdate(
          StudentProgressTableCompanion.insert(
            conceptId: c,
            learningPathId: 'python',
            moduleId: 'functions',
            startedAt: Value(daysAgo(0)),
            completedAt: c == 'python-functions-basics'
                ? Value(daysAgo(0, 1))
                : const Value.absent(),
            lastAccessedAt: Value(daysAgo(0, c == 'python-scope' ? 2 : 1)),
          ),
        );
  }
}

const _emojiFamily = 'Noto Color Emoji';

bool _isEmoji(int rune) =>
    (rune >= 0x1F000 && rune <= 0x1FAFF) ||
    (rune >= 0x2600 && rune <= 0x27BF) ||
    rune == 0x2B50 ||
    rune == 0x2B06 ||
    rune == 0x2705 ||
    rune == 0x231B ||
    rune == 0x23F3 ||
    rune == 0x23F0;

/// Finds every emoji drawn by a [RenderParagraph] and returns a positioned
/// colour-emoji glyph to paint over it (flutter_tester has no font fallback).
List<Widget> _emojiOverlays(RenderObject root) {
  final out = <Widget>[];
  void visit(RenderObject node) {
    if (node is RenderParagraph && node.attached && node.hasSize) {
      final text = node.text.toPlainText(includeSemanticsLabels: false);
      var offset = 0;
      final runes = text.runes.toList();
      for (var i = 0; i < runes.length; i++) {
        final r = runes[i];
        final len = r > 0xFFFF ? 2 : 1;
        if (_isEmoji(r)) {
          final boxes = node.getBoxesForSelection(
            TextSelection(baseOffset: offset, extentOffset: offset + len),
          );
          if (boxes.isNotEmpty) {
            final b = boxes.first.toRect();
            final topLeft = node.localToGlobal(b.topLeft);
            // Only paint emoji that are really on screen: a hit test at the
            // glyph reaches the paragraph unless it is offstage, in a hidden
            // tab or route, scrolled away, or under another widget.
            final hit = HitTestResult();
            final binding = WidgetsBinding.instance;
            binding.hitTestInView(
              hit,
              node.localToGlobal(b.center),
              binding.platformDispatcher.implicitView!.viewId,
            );
            if (!hit.path.any((e) => e.target == node)) {
              offset += len;
              continue;
            }
            final fontSize = b.width / 1.2;
            out.add(
              Positioned(
                left: topLeft.dx,
                top: topLeft.dy,
                width: b.width,
                height: b.height,
                child: Center(
                  child: Text(
                    String.fromCharCode(r),
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(
                      fontFamily: _emojiFamily,
                      fontSize: fontSize,
                      height: 1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            );
          }
        }
        offset += len;
      }
    }
    node.visitChildren(visit);
  }

  visit(root);
  return out;
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.height, required this.dark});
  final double height;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final c = dark ? Colors.white : Colors.black;
    // iPad status bars are shorter, with smaller type than iPhone ones.
    final compact = height < 40;
    final icon = compact ? 14.0 : 18.0;
    final style = TextStyle(
      fontFamily: 'Roboto',
      fontSize: compact ? 13 : 17,
      fontWeight: FontWeight.w600,
      color: c,
      decoration: TextDecoration.none,
    );
    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 28),
          child: Row(
            children: [
              Text('9:41', style: style),
              const Spacer(),
              Icon(Icons.signal_cellular_alt, size: icon, color: c),
              const SizedBox(width: 6),
              Icon(Icons.wifi, size: icon, color: c),
              const SizedBox(width: 6),
              Icon(Icons.battery_full, size: icon + 2, color: c),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final device in _devices) {
    for (final dark in [false, true]) {
      testWidgets('${device.name} ${dark ? 'dark' : 'light'}', (tester) async {
        debugDisableShadows = false;
        tester.view.physicalSize = device.size * device.dpr;
        tester.view.devicePixelRatio = device.dpr;
        tester.view.padding = FakeViewPadding(
          top: device.top * device.dpr,
          bottom: device.bottom * device.dpr,
        );
        tester.view.viewPadding = FakeViewPadding(
          top: device.top * device.dpr,
          bottom: device.bottom * device.dpr,
        );
        addTearDown(tester.view.reset);

        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await tester.runAsync(() => _seed(db, dark: dark));
        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);
        final key = GlobalKey();
        final appKey = GlobalKey();
        final overlays = ValueNotifier<List<Widget>>(const []);
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: ValueListenableBuilder<List<Widget>>(
                valueListenable: overlays,
                builder: (context, extra, _) => Stack(
                  children: [
                    KeyedSubtree(
                      key: appKey,
                      child: UncontrolledProviderScope(
                        container: container,
                        child: const TeacherApp(),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _StatusBar(
                        height: device.top < 40 ? device.top : 54,
                        dark: dark,
                      ),
                    ),
                    ...extra,
                  ],
                ),
              ),
            ),
          ),
        );
        Future<void> settle() async {
          for (var i = 0; i < 20; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 50)),
            );
            await tester.pump(const Duration(milliseconds: 100));
          }
        }

        Future<void> shot(String name) async {
          overlays.value = const [];
          await settle();
          overlays.value = _emojiOverlays(
            appKey.currentContext!.findRenderObject()!,
          );
          await tester.pump();
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: device.dpr);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final f = File(
              '$_outDir/${device.name}/${dark ? 'dark' : 'light'}-$name.png',
            );
            f.parent.createSync(recursive: true);
            f.writeAsBytesSync(bytes!.buffer.asUint8List());
          });
        }

        final router = container.read(routerProvider);
        await shot('home');
        router.go('/learn');
        await shot('learn');
        router.go('/progress');
        await shot('progress');
        router.go('/profile');
        await shot('profile');
        router.go('/learn/python');
        await shot('path');
        router.go('/learn/python/functions');
        await shot('module');
        router.go('/learn/python/functions/python-closures');
        await shot('lesson1');
        Future<void> next() async {
          await tester.tap(
            find.byKey(const ValueKey('lesson-next')).first,
            warnIfMissed: false,
          );
        }

        await next();
        await shot('lesson2');
        await next();
        await shot('lesson3');
        await next();
        await shot('quiz');
        await tester.tap(
          find.byKey(const ValueKey('quick-option-0')).first,
          warnIfMissed: false,
        );
        await shot('quiz-answered');
        router.go('/practice/python-closures');
        await shot('practice');
        router.go('/review');
        await shot('review');
        router.go('/progress');
        await settle();
        router.push('/settings');
        await shot('settings');
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(db.close);
        debugDisableShadows = true;
      });
    }
  }
}
