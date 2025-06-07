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
