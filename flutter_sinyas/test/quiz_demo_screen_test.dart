import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sinyas/demo/demo_quiz_data.dart';
import 'package:flutter_sinyas/screens/lesson_quiz_screen.dart';
import 'package:flutter_sinyas/screens/lesson_screen.dart';
import 'package:flutter_sinyas/screens/quiz_demo_screen.dart';
import 'package:flutter_sinyas/widgets/demo_video_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('video-to-text demo shows wrong-tip then continue feedback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: QuizDemoScreen()));
    await tester.tap(find.text('Watch a video, choose a sign name'));
    await tester.pumpAndSettle();

    expect(find.byType(DemoVideoPreview), findsOneWidget);
    expect(find.text('This sign demonstrates what?'), findsOneWidget);

    await tester.tap(find.text('Hello'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'A tip! Watch the handshape and movement closely, then try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('CONTINUE'), findsNothing);

    await tester.tap(find.text('Thank you'));
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 2 correct\n50% accuracy'), findsOneWidget);
  });

  testWidgets('word-to-video demo uses four separate video choice cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: LessonQuizScreen.demo(
          question: demoQuestions[2],
          demoVideoLinks: demoVideoLinks,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Which video demonstrates how to sign the word below?'),
      findsOneWidget,
    );
    expect(find.byType(DemoVideoPreview), findsNWidgets(4));
    await tester.tap(find.text('Video 1'));
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('photo-to-text demo fits a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: LessonQuizScreen.demo(
          question: demoQuestions[1],
          demoVideoLinks: demoVideoLinks,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sample sign photo'), findsOneWidget);
    expect(find.text('This sign demonstrates what?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('camera demo reaches the continue state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LessonQuizScreen.demo(question: demoQuestions[3])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camera practice preview'), findsOneWidget);
    await tester.tap(find.text('I signed it correctly'));
    await tester.pumpAndSettle();
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('standard lesson demo runs without Supabase', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LessonScreen.demo()));
    await tester.pumpAndSettle();

    expect(find.byType(DemoVideoPreview), findsOneWidget);
    expect(find.text('Salamat - Thank you!'), findsOneWidget);
    await tester.tap(find.text('FINISH LESSON'));
    await tester.pumpAndSettle();
    expect(find.text('COMPLETED'), findsOneWidget);
  });
}
