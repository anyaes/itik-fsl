import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sinyas/screens/lessons_page.dart';
import 'package:flutter_sinyas/widgets/choice_style_card.dart';

void main() {
  testWidgets('mobile lesson headers remain pinned while scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(502, 1022);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LessonsPage(onTracksSelected: () {})),
      ),
    );
    await tester.pumpAndSettle();

    final statsTop = tester
        .getTopLeft(find.byIcon(Icons.local_fire_department_rounded))
        .dy;
    final unitTop = tester
        .getTopLeft(find.text('Greetings and introductions'))
        .dy;

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.byIcon(Icons.local_fire_department_rounded)).dy,
      statsTop,
    );
    expect(
      tester.getTopLeft(find.text('Greetings and introductions')).dy,
      unitTop,
    );
  });

  testWidgets('unit card selects Tracks on wide and mobile layouts', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> tapCardAt(Size size) async {
      var tracksSelected = false;
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonsPage(onTracksSelected: () => tracksSelected = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Greetings and introductions').first);
      expect(tracksSelected, isTrue);
    }

    await tapCardAt(const Size(1200, 900));
    await tapCardAt(const Size(502, 1022));
  });

  testWidgets('unit card uses the solid selected ChoiceCard style', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LessonsPage(onTracksSelected: () {})),
      ),
    );
    await tester.pumpAndSettle();

    final styleCard = tester.widget<ChoiceStyleCard>(
      find.byType(ChoiceStyleCard).first,
    );
    expect(styleCard.isSelected, isTrue);

    final animatedContainer = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(ChoiceStyleCard).first,
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = animatedContainer.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFF4EBFD0));
    expect(decoration.gradient, isNull);
  });
}
