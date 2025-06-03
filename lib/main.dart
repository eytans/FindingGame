import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import 'dart:async';

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

class TeachableWord {
  final String word;
  final String type;
  final String iconUrl;

  TeachableWord({
    required this.word,
    required this.type,
    required this.iconUrl,
  });
}

class WordBubble {
  final TeachableWord word;
  double x;
  double y;
  double dx;
  double dy;
  bool isClicked;
  bool isActive;

  WordBubble({
    required this.word,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    this.isClicked = false,
    this.isActive = false,
  });
}

class WordBubblesGame extends StatefulWidget {
  const WordBubblesGame({super.key});

  @override
  State<WordBubblesGame> createState() => _WordBubblesGameState();
}

class _WordBubblesGameState extends State<WordBubblesGame>
    with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  late AnimationController _animationController;
  late Timer _animationTimer;
  
  List<WordBubble> bubbles = [];
  String? currentBackgroundImage;
  int wordsClickedCount = 0;
  int setsCompletedCount = 0;
  List<TeachableWord> currentWords = [];
  final Random random = Random();
  
  static const int maxObjectsOnScreen = 3;
  static const double bubbleSize = 120.0;
  static const double animationSpeed = 2.0;

  final List<TeachableWord> teachableWords = [
    // Original 20
    TeachableWord(word: "flower", type: "noun", iconUrl: "🌸"),
    TeachableWord(word: "circle", type: "shape", iconUrl: "●"),
    TeachableWord(word: "red square", type: "color", iconUrl: "🟥"),
    TeachableWord(word: "tree", type: "noun", iconUrl: "🌳"),
    TeachableWord(word: "square", type: "shape", iconUrl: "■"),
    TeachableWord(word: "blue square", type: "color", iconUrl: "🟦"),
    TeachableWord(word: "sun", type: "noun", iconUrl: "☀️"),
    TeachableWord(word: "star", type: "shape", iconUrl: "⭐"),
    TeachableWord(word: "yellow square", type: "color", iconUrl: "🟨"),
    TeachableWord(word: "car", type: "noun", iconUrl: "🚗"),
    TeachableWord(word: "cat", type: "animal", iconUrl: "🐱"),
    TeachableWord(word: "dog", type: "animal", iconUrl: "🐶"),
    TeachableWord(word: "apple", type: "food", iconUrl: "🍎"),
    TeachableWord(word: "banana", type: "food", iconUrl: "🍌"),
    TeachableWord(word: "book", type: "object", iconUrl: "📖"),
    TeachableWord(word: "chair", type: "object", iconUrl: "🪑"),
    TeachableWord(word: "house", type: "place", iconUrl: "🏠"),
    TeachableWord(word: "ball", type: "toy", iconUrl: "⚽"),
    TeachableWord(word: "moon", type: "celestial", iconUrl: "🌙"),
    TeachableWord(word: "hat", type: "clothing", iconUrl: "🧢"),
    // Additional words
    TeachableWord(word: "bird", type: "animal", iconUrl: "🐦"),
    TeachableWord(word: "fish", type: "animal", iconUrl: "🐠"),
    TeachableWord(word: "lion", type: "animal", iconUrl: "🦁"),
    TeachableWord(word: "tiger", type: "animal", iconUrl: "🐅"),
    TeachableWord(word: "bear", type: "animal", iconUrl: "🐻"),
    TeachableWord(word: "elephant", type: "animal", iconUrl: "🐘"),
    TeachableWord(word: "monkey", type: "animal", iconUrl: "🐒"),
    TeachableWord(word: "horse", type: "animal", iconUrl: "🐎"),
    TeachableWord(word: "cow", type: "animal", iconUrl: "🐄"),
    TeachableWord(word: "pig", type: "animal", iconUrl: "🐖"),
    TeachableWord(word: "orange", type: "food", iconUrl: "🍊"),
    TeachableWord(word: "grapes", type: "food", iconUrl: "🍇"),
    TeachableWord(word: "strawberry", type: "food", iconUrl: "🍓"),
    TeachableWord(word: "watermelon", type: "food", iconUrl: "🍉"),
    TeachableWord(word: "pizza", type: "food", iconUrl: "🍕"),
    TeachableWord(word: "burger", type: "food", iconUrl: "🍔"),
    TeachableWord(word: "ice cream", type: "food", iconUrl: "🍦"),
    TeachableWord(word: "cake", type: "food", iconUrl: "🍰"),
    TeachableWord(word: "cookie", type: "food", iconUrl: "🍪"),
    TeachableWord(word: "milk", type: "drink", iconUrl: "🥛"),
    TeachableWord(word: "juice", type: "drink", iconUrl: "🧃"),
    TeachableWord(word: "water", type: "drink", iconUrl: "💧"),
    TeachableWord(word: "bed", type: "furniture", iconUrl: "🛏️"),
    TeachableWord(word: "sofa", type: "furniture", iconUrl: "🛋️"),
    TeachableWord(word: "lamp", type: "furniture", iconUrl: "💡"),
    TeachableWord(word: "shirt", type: "clothing", iconUrl: "👕"),
    TeachableWord(word: "pants", type: "clothing", iconUrl: "👖"),
    TeachableWord(word: "shoe", type: "clothing", iconUrl: "👟"),
    TeachableWord(word: "dress", type: "clothing", iconUrl: "👗"),
    TeachableWord(word: "socks", type: "clothing", iconUrl: "🧦"),
    TeachableWord(word: "train", type: "vehicle", iconUrl: "🚆"),
    TeachableWord(word: "bus", type: "vehicle", iconUrl: "🚌"),
    TeachableWord(word: "bicycle", type: "vehicle", iconUrl: "🚲"),
    TeachableWord(word: "boat", type: "vehicle", iconUrl: "⛵"),
    TeachableWord(word: "airplane", type: "vehicle", iconUrl: "✈️"),
    TeachableWord(word: "helicopter", type: "vehicle", iconUrl: "🚁"),
    TeachableWord(word: "rocket", type: "vehicle", iconUrl: "🚀"),
    TeachableWord(word: "happy", type: "emotion", iconUrl: "😊"),
    TeachableWord(word: "sad", type: "emotion", iconUrl: "😢"),
    TeachableWord(word: "angry", type: "emotion", iconUrl: "😠"),
    TeachableWord(word: "surprised", type: "emotion", iconUrl: "😮"),
    TeachableWord(word: "laugh", type: "action", iconUrl: "😂"),
    TeachableWord(word: "cry", type: "action", iconUrl: "😭"),
    TeachableWord(word: "run", type: "action", iconUrl: "🏃"),
    TeachableWord(word: "dance", type: "action", iconUrl: "💃"),
    TeachableWord(word: "books", type: "action", iconUrl: "📚"),
    TeachableWord(word: "sleep", type: "action", iconUrl: "😴"),
    TeachableWord(word: "plate", type: "action", iconUrl: "🍽️"),
    TeachableWord(word: "drink", type: "action", iconUrl: "🥤"),
    TeachableWord(word: "green circle", type: "color", iconUrl: "🟢"),
    TeachableWord(word: "purple circle", type: "color", iconUrl: "🟣"),
    TeachableWord(word: "orange circle", type: "color", iconUrl: "🟠"),
    TeachableWord(word: "black circle", type: "color", iconUrl: "⚫"),
    TeachableWord(word: "white circle", type: "color", iconUrl: "⚪"),
    TeachableWord(word: "brown circle", type: "color", iconUrl: "🟤"),
    TeachableWord(word: "triangle", type: "shape", iconUrl: "🔺"),
    TeachableWord(word: "diamond", type: "shape", iconUrl: "💎"),
    TeachableWord(word: "egg", type: "shape", iconUrl: "🥚"),
    TeachableWord(word: "heart", type: "shape", iconUrl: "❤️"),
    TeachableWord(word: "cloud", type: "nature", iconUrl: "☁️"),
    TeachableWord(word: "rain", type: "nature", iconUrl: "🌧️"),
    TeachableWord(word: "snow", type: "nature", iconUrl: "❄️"),
    TeachableWord(word: "mountain", type: "nature", iconUrl: "⛰️"),
    TeachableWord(word: "river", type: "nature", iconUrl: "🏞️"),
    TeachableWord(word: "wave", type: "nature", iconUrl: "🌊"),
    TeachableWord(word: "fire", type: "nature", iconUrl: "🔥"),
    TeachableWord(word: "earth", type: "celestial", iconUrl: "🌍"),
    TeachableWord(word: "computer", type: "object", iconUrl: "💻"),
    TeachableWord(word: "phone", type: "object", iconUrl: "📱"),
    TeachableWord(word: "key", type: "object", iconUrl: "🔑"),
    TeachableWord(word: "door", type: "object", iconUrl: "🚪"),
    TeachableWord(word: "picture", type: "object", iconUrl: "🖼️"),
    TeachableWord(word: "clock", type: "object", iconUrl: "⏰"),
    TeachableWord(word: "guitar", type: "instrument", iconUrl: "🎸"),
    TeachableWord(word: "piano", type: "instrument", iconUrl: "🎹"),
    TeachableWord(word: "drum", type: "instrument", iconUrl: "🥁"),
    TeachableWord(word: "pencil", type: "tool", iconUrl: "✏️"),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (bubbles.isEmpty) {
      _initializeGame();
      _startAnimation();
    }
  }

  void _initializeTts() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.9);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
  }

  void _initializeGame() {
    _initializeWordPool();
    _loadNextImage();
    _displayTeachableObjects();
  }

  void _initializeWordPool() {
    currentWords.clear();
    final shuffledWords = List<TeachableWord>.from(teachableWords)..shuffle(random);
    currentWords = shuffledWords.take(20).toList();
  }

  void _loadNextImage() {
    final imageId = random.nextInt(387) + 1;
    setState(() {
      currentBackgroundImage = 'https://picsum.photos/id/$imageId/800/600';
    });
  }

  void _displayTeachableObjects() {
    if (currentWords.isEmpty) {
      _initializeWordPool();
    }

    final wordsToDisplay = _getRandomWords(currentWords, maxObjectsOnScreen);
    
    setState(() {
      bubbles.clear();
      for (final word in wordsToDisplay) {
        bubbles.add(_createWordBubble(word));
      }
    });
  }

  List<TeachableWord> _getRandomWords(List<TeachableWord> words, int count) {
    final shuffled = List<TeachableWord>.from(words)..shuffle(random);
    return shuffled.take(count).toList();
  }

  WordBubble _createWordBubble(TeachableWord word) {
    final screenSize = MediaQuery.of(context).size;
    final maxX = screenSize.width - bubbleSize;
    final maxY = screenSize.height - bubbleSize - 100; // Account for app bar
    
    return WordBubble(
      word: word,
      x: random.nextDouble() * maxX.clamp(0, double.infinity),
      y: random.nextDouble() * maxY.clamp(0, double.infinity),
      dx: (random.nextDouble() - 0.5) * animationSpeed,
      dy: (random.nextDouble() - 0.5) * animationSpeed,
    );
  }

  void _startAnimation() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateBubblePositions();
    });
  }

  void _updateBubblePositions() {
    if (!mounted) return;
    
    final screenSize = MediaQuery.of(context).size;
    final maxX = screenSize.width - bubbleSize;
    final maxY = screenSize.height - bubbleSize - 100;

    setState(() {
      for (final bubble in bubbles) {
        if (bubble.isClicked) continue;

        // Update position
        bubble.x += bubble.dx;
        bubble.y += bubble.dy;

        // Bounce off walls
        if (bubble.x <= 0 || bubble.x >= maxX) {
          bubble.dx *= -1;
          bubble.x = bubble.x.clamp(0, maxX);
        }
        if (bubble.y <= 0 || bubble.y >= maxY) {
          bubble.dy *= -1;
          bubble.y = bubble.y.clamp(0, maxY);
        }
      }
    });
  }

  Future<void> _speakWord(WordBubble bubble) async {
    if (bubble.isClicked) return;

    setState(() {
      bubble.isClicked = true;
      bubble.isActive = true;
      bubble.dx = 0;
      bubble.dy = 0;
    });

    wordsClickedCount++;

    try {
      await flutterTts.speak(bubble.word.word);
      
      // Wait a bit for speech to complete
      await Future.delayed(const Duration(milliseconds: 2000));
      
      _handleWordCleanup(bubble);
    } catch (e) {
      print('Speech synthesis failed: $e');
      _handleWordCleanup(bubble);
    }
  }

  void _handleWordCleanup(WordBubble bubble) {
    setState(() {
      bubbles.remove(bubble);
    });

    if (bubbles.isEmpty) {
      setsCompletedCount++;
      if (setsCompletedCount >= 3) {
        _loadNextImage();
        setsCompletedCount = 0;
        wordsClickedCount = 0;

        // Add new words to the pool
        final availableNewWords = teachableWords
            .where((tw) => !currentWords.any((cw) => cw.word == tw.word))
            .toList();
        final shuffledAvailable = List<TeachableWord>.from(availableNewWords)
          ..shuffle(random);
        final newWordsToAdd = shuffledAvailable.take(6).toList();
        currentWords.addAll(newWordsToAdd);
      }
      
      // Display new objects after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _displayTeachableObjects();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationTimer.cancel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          ),
        ),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Background Image
                  if (currentBackgroundImage != null)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: currentBackgroundImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'Could not load image.\nEnjoy the words on a plain background!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Word Bubbles
                  ...bubbles.map((bubble) => Positioned(
                    left: bubble.x,
                    top: bubble.y,
                    child: GestureDetector(
                      onTap: () => _speakWord(bubble),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.elasticOut,
                        width: bubbleSize,
                        height: bubbleSize,
                        decoration: BoxDecoration(
                          color: bubble.isActive 
                              ? Colors.white 
                              : Colors.white.withValues(alpha: 0.92),
                          border: Border.all(
                            color: bubble.isActive 
                                ? const Color(0xFFFFA500) 
                                : const Color(0xFFFF6347),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: bubble.isActive 
                                  ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                                  : Colors.black.withValues(alpha: 0.25),
                              blurRadius: bubble.isActive ? 15 : 8,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        transform: bubble.isActive 
                            ? (Matrix4.identity()..scale(1.1))
                            : Matrix4.identity(),
                        child: Center(
                          child: Text(
                            bubble.word.iconUrl,
                            style: const TextStyle(fontSize: 48),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )),
                  
                  // Title
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'WordBubbles: Learn & Play',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
