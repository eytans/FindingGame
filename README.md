# WordBubbles: Learn & Play

A Flutter educational game app that helps children learn words through interactive animated bubbles with text-to-speech functionality.

## Features

- **Animated Word Bubbles**: Interactive emoji-based word bubbles that bounce around the screen
- **Text-to-Speech**: Click on any bubble to hear the word pronounced
- **Random Background Images**: Beautiful background images from Picsum Photos
- **Progressive Learning**: New words are added as you complete sets
- **100+ Educational Words**: Covering categories like animals, food, vehicles, emotions, shapes, and more
- **Cross-Platform**: Runs on Android and Web

## Original Implementation

This Flutter app is a rewrite of the original JavaScript/HTML WordBubbles game, maintaining all the core functionality while leveraging Flutter's powerful UI framework and native capabilities.

## How to Play

1. Watch the animated word bubbles bounce around the screen
2. Tap on any bubble to hear the word spoken aloud
3. Complete sets of words to unlock new backgrounds and vocabulary
4. Learn through play with over 100 different words!

## Technical Features

- **Flutter Framework**: Built with Flutter for cross-platform compatibility
- **Text-to-Speech**: Uses `flutter_tts` package for speech synthesis
- **Cached Images**: Efficient image loading with `cached_network_image`
- **Smooth Animations**: 60fps animations with proper collision detection
- **Responsive Design**: Adapts to different screen sizes

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio (for Android development)
- Web browser (for web development)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # For web
   flutter run -d web-server --web-port 8080
   
   # For Android
   flutter run -d android
   ```

## Project Structure

- `lib/main.dart` - Main application code with game logic
- `pubspec.yaml` - Dependencies and project configuration
- `web/` - Web-specific files
- `android/` - Android-specific files

## Dependencies

- `flutter_tts: ^4.2.0` - Text-to-speech functionality
- `cached_network_image: ^3.4.1` - Efficient image caching
- `http: ^1.2.2` - HTTP requests for image loading

## Educational Content

The app includes 100+ carefully selected words across various categories:

- **Animals**: cat, dog, bird, lion, elephant, etc.
- **Food**: apple, banana, pizza, ice cream, etc.
- **Vehicles**: car, train, airplane, bicycle, etc.
- **Emotions**: happy, sad, surprised, angry, etc.
- **Shapes & Colors**: circle, triangle, red square, blue circle, etc.
- **Nature**: cloud, rain, mountain, fire, etc.
- **Objects**: book, phone, computer, clock, etc.

## Contributing

Feel free to contribute by:
- Adding new word categories
- Improving animations
- Enhancing accessibility features
- Adding new languages

## License

This project is open source and available under the MIT License.
