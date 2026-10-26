import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/models/skill.dart';
import 'package:skillswap/screens/splash_screen.dart';
import 'package:skillswap/widgets/skill_card.dart';

void main() {
  testWidgets('splash screen presents the brand and loading indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen()),
    );

    expect(find.text('SkillSwap'), findsOneWidget);
    expect(find.text('Learn Something. Share Something.'), findsOneWidget);
    expect(find.text('Getting things ready…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('skill card shows listing details and owner', (tester) async {
    final date = DateTime.utc(2026);
    final skill = Skill(
      id: 'skill-1',
      title: 'Dart basics',
      description: 'A beginner-friendly introduction.',
      category: 'Programming',
      ownerId: 'student-1',
      ownerName: 'Taylor Student',
      active: true,
      createdAt: date,
      updatedAt: date,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SkillCard(skill: skill))),
    );

    expect(find.text('Dart basics'), findsOneWidget);
    expect(find.text('A beginner-friendly introduction.'), findsOneWidget);
    expect(find.text('Programming'), findsOneWidget);
    expect(find.text('Taylor Student'), findsOneWidget);
  });
}
