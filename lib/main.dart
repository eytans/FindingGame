import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

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

class AnimatedBubblesLayer extends StatefulWidget {
  final List<WordBubble> bubbles;
  final Function(WordBubble) onBubbleTap;
  final double bubbleSize;

  const AnimatedBubblesLayer({
    super.key,
    required this.bubbles,
    required this.onBubbleTap,
    required this.bubbleSize,
  });

  @override
  State<AnimatedBubblesLayer> createState() => _AnimatedBubblesLayerState();
}

class _AnimatedBubblesLayerState extends State<AnimatedBubblesLayer> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    );
    _startAnimation();
  }

  void _startAnimation() {
    _animationController.repeat();
    _animationController.addListener(_updateBubblePositions);
  }

  void _updateBubblePositions() {
    if (!mounted) return;
    
    final screenSize = MediaQuery.of(context).size;
    final maxX = (screenSize.width - widget.bubbleSize).clamp(widget.bubbleSize, double.infinity);
    final maxY = (screenSize.height - widget.bubbleSize - 100).clamp(widget.bubbleSize, double.infinity);

    bool needsUpdate = false;
    
    for (final bubble in widget.bubbles) {
      if (bubble.isClicked) continue;

      // Update position
      final newX = bubble.x + bubble.dx;
      final newY = bubble.y + bubble.dy;

      // Bounce off walls
      if (newX <= 0 || newX >= maxX) {
        bubble.dx *= -1;
        bubble.x = newX.clamp(0, maxX);
        needsUpdate = true;
      } else {
        bubble.x = newX;
        needsUpdate = true;
      }
      
      if (newY <= 0 || newY >= maxY) {
        bubble.dy *= -1;
        bubble.y = newY.clamp(0, maxY);
        needsUpdate = true;
      } else {
        bubble.y = newY;
        needsUpdate = true;
      }
    }

    // Only call setState if positions actually changed
    if (needsUpdate) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_updateBubblePositions);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: widget.bubbles.map((bubble) => Positioned(
        left: bubble.x,
        top: bubble.y,
        child: GestureDetector(
          onTap: () => widget.onBubbleTap(bubble),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.elasticOut,
            width: widget.bubbleSize,
            height: widget.bubbleSize,
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
      )).toList(),
    );
  }
}

class WordBubblesGame extends StatefulWidget {
  const WordBubblesGame({super.key});

  @override
  State<WordBubblesGame> createState() => _WordBubblesGameState();
}

class _WordBubblesGameState extends State<WordBubblesGame> {
  late FlutterTts flutterTts;
  
  List<WordBubble> bubbles = [];
  String? currentBackgroundImage;
  List<int>? _imageIds;
  int wordsClickedCount = 0;
  int setsCompletedCount = 0;
  List<TeachableWord> currentWords = [];
  final Random random = Random();
  
  static const int maxObjectsOnScreen = 3;
  static const double bubbleSize = 120.0;
  static const double animationSpeed = 2.0;
  
  // Add logging for image loading
  int imageLoadCount = 0;
  List<String> imageLoadLog = [];

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

  String? _currentImagePath;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadImageIds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (bubbles.isEmpty) {
      _initializeGame();
    }
  }

  void _initializeTts() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(Platform.isAndroid ? 0.5 : 2.0);
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

  Future<void> _loadImageIds() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/config/image_ids.json');
      final Map<String, dynamic> config = json.decode(jsonString);
      setState(() {
        _imageIds = List<int>.from(config['imageIds']);
      });
      _loadNextImage();
    } catch (e) {
      print('Error loading image IDs: $e');
    }
  }

  void _loadNextImage() async {
    if (_imageIds == null || _imageIds!.isEmpty || _isLoadingImage) return;
    
    _isLoadingImage = true;
    final imageId = _imageIds![random.nextInt(_imageIds!.length)];
    final newPath = 'assets/images/picsum/$imageId.jpg';
    
    // Simply set the new image path - Flutter will handle caching and optimization
    if (mounted) {
      setState(() {
        _currentImagePath = newPath;
        currentBackgroundImage = newPath;
        _isLoadingImage = false;
      });
    }
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
    final maxX = (screenSize.width - bubbleSize).clamp(bubbleSize, double.infinity);
    final maxY = (screenSize.height - bubbleSize - 100).clamp(bubbleSize, double.infinity);
    
    return WordBubble(
      word: word,
      x: random.nextDouble() * maxX,
      y: random.nextDouble() * maxY,
      dx: (random.nextDouble() - 0.5) * animationSpeed,
      dy: (random.nextDouble() - 0.5) * animationSpeed,
    );
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
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
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
                fit: StackFit.expand,
                children: [
                  // Static Background Image (not rebuilt on animation)
                  if (_currentImagePath != null)
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Image.asset(
                          _currentImagePath!,
                          key: ValueKey<String>(_currentImagePath!),
                          width: size.width,
                          height: size.height,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          cacheWidth: (size.width * 1.5).round(),
                          cacheHeight: (size.height * 1.5).round(),
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                  
                  // Animated Bubbles Layer (isolated animation)
                  AnimatedBubblesLayer(
                    bubbles: bubbles,
                    onBubbleTap: _speakWord,
                    bubbleSize: bubbleSize,
                  ),
                  
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
                  
                  // Debug Log Overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imageLoadLog.isNotEmpty)
                            ...imageLoadLog.take(3).map((log) => Text(
                              log,
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            )),
                        ],
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
