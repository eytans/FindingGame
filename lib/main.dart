import 'package:flutter/material.dart';
import 'widgets/word_bubbles_game.dart';

void main() {
  runApp(const WordBubblesApp());
}

class WordBubblesApp extends StatelessWidget {
  const WordBubblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordBubbles: Learn & Play',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const WordBubblesGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}
