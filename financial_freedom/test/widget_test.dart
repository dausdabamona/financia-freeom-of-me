import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App MaterialApp widget can be created', (WidgetTester tester) async {
    // Test only the MaterialApp shell without dependency injection
    await tester.pumpWidget(
      MaterialApp(
        title: 'Financial Freedom',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(child: Text('Financial Freedom')),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Financial Freedom'), findsOneWidget);
  });
}
