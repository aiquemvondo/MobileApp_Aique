import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tests_aique/widgets/greeting_card.dart';

void main() {
  group('GreetingCard Widget Tests', () {
    testWidgets('Displays Hello, Alice! once', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GreetingCard(userName: 'Alice')),
        ),
      );

      expect(find.text('Hello, Alice!'), findsOneWidget);
    });

    testWidgets('Displays Likes: 0 initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GreetingCard(userName: 'Alice')),
        ),
      );

      expect(find.text('Likes: 0'), findsOneWidget);
    });

    testWidgets('Increments likes when button is tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GreetingCard(userName: 'Alice')),
        ),
      );

      await tester.tap(find.byKey(const Key('like_button_key')));

      await tester.pump();

      expect(find.text('Likes: 1'), findsOneWidget);
    });
  });
}
