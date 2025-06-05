#!/bin/bash

# Script to create a new release for WordBubbles
# This script will create a git tag and push it, triggering the release workflow

set -e

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
echo "Current version in pubspec.yaml: $CURRENT_VERSION"

# Ask for new version
echo "Enter the new version (e.g., 1.0.1, 1.1.0, 2.0.0):"
read NEW_VERSION

# Validate version format
if [[ ! $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 1.0.1)"
    exit 1
fi

# Ask for release notes
echo "Enter release notes (optional, press Enter to skip):"
read RELEASE_NOTES

# Update version in pubspec.yaml
echo "Updating version in pubspec.yaml..."
sed -i "s/^version: .*/version: $NEW_VERSION+1/" pubspec.yaml

# Commit the version change
git add pubspec.yaml
git commit -m "Bump version to $NEW_VERSION"

# Create and push tag
TAG_NAME="v$NEW_VERSION"
echo "Creating tag: $TAG_NAME"

if [ -n "$RELEASE_NOTES" ]; then
    git tag -a "$TAG_NAME" -m "Release $NEW_VERSION" -m "$RELEASE_NOTES"
else
    git tag -a "$TAG_NAME" -m "Release $NEW_VERSION"
fi

echo "Pushing changes and tag..."
git push origin main
git push origin "$TAG_NAME"

echo ""
echo "✅ Release $NEW_VERSION created successfully!"
echo "🚀 GitHub Actions will now build and create the release automatically."
echo "📦 Check the Actions tab in your GitHub repository to monitor the build progress."
echo "🎉 The release will appear in the Releases section once the workflow completes."
