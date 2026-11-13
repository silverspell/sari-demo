import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/main.dart';

void main() {
  testWidgets('shows the app name and tagline', (tester) async {
    await tester.pumpWidget(const SariApp());

    expect(find.text('Sarı'), findsOneWidget);
    expect(find.text('Taksin bir dokunuş uzağında'), findsOneWidget);
  });

  goldenTest(
    'splash screen',
    fileName: '00-splash',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'iPhone SE',
          constraints: BoxConstraints.tight(const Size(375, 667)),
          child: const SariApp(),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max',
          constraints: BoxConstraints.tight(const Size(430, 932)),
          child: const SariApp(),
        ),
      ],
    ),
  );
}
