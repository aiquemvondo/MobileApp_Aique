
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localstorage/localstorage.dart';

import 'package:expensetracker_aique/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Tracker app initializes', (WidgetTester tester) async {
    await initLocalStorage();

    await tester.pumpWidget(
      MyApp(localStorage: localStorage),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
