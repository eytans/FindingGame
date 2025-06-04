#!/bin/bash

# Build Flutter web app for GitHub Pages
echo "Building Flutter web app..."
flutter build web --release --base-href="/WordBubbles/" --output-dir="www"

echo "Build complete! Web app is available in the /www directory."
echo "To test locally, you can serve the www directory with a local server."
echo "For example: cd www && python3 -m http.server 8000"
