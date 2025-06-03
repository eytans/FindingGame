import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wordbubbles/main.dart';

void main() {
  testWidgets('WordBubbles app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WordBubblesApp());
    
    // Pump a few frames to let the app initialize
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that our app loads with the title.
    expect(find.text('WordBubbles: Learn & Play'), findsOneWidget);
    
    // Verify that the app structure is correct
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(WordBubblesGame), findsOneWidget);
  });
  
  testWidgets('WordBubbles app has correct theme', (WidgetTester tester) async {
    await tester.pumpWidget(const WordBubblesApp());
    await tester.pump();
    
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'WordBubbles: Learn & Play');
    expect(app.debugShowCheckedModeBanner, false);
  });
  
  testWidgets('WordBubbles game initializes without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const WordBubblesApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verify the game widget exists and doesn't throw errors
    expect(find.byType(WordBubblesGame), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    
    // Verify that the app has a gradient background
    expect(find.byType(Container), findsWidgets);
  });
  
  testWidgets('WordBubbles app structure test', (WidgetTester tester) async {
    await tester.pumpWidget(const WordBubblesApp());
    await tester.pump();
    
    // Test that basic widgets are present
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(Stack), findsWidgets);
  });
}
