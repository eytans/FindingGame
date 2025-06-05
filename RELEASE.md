# WordBubbles Release Guide

This document explains how to create releases for the WordBubbles app that will automatically build and publish both web and Android APK versions.

## Automated Release Process

The project now includes an automated release workflow that:
- Runs tests to ensure code quality
- Builds the web version as a ZIP file
- Builds the Android APK
- Creates a GitHub release with both files attached
- Provides detailed installation instructions

## How to Create a Release

### Method 1: Using the Release Script (Recommended)

1. Make sure all your changes are committed and pushed to the main branch
2. Run the release script:
   ```bash
   ./create-release.sh
   ```
3. Follow the prompts to:
   - Enter the new version number (e.g., 1.0.1, 1.1.0, 2.0.0)
   - Optionally add release notes
4. The script will:
   - Update the version in `pubspec.yaml`
   - Create a git commit with the version bump
   - Create and push a version tag
   - Trigger the GitHub Actions workflow

### Method 2: Manual Tag Creation

1. Update the version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+1  # Change 1.0.1 to your desired version
   ```

2. Commit the version change:
   ```bash
   git add pubspec.yaml
   git commit -m "Bump version to 1.0.1"
   ```

3. Create and push a version tag:
   ```bash
   git tag -a v1.0.1 -m "Release 1.0.1"
   git push origin main
   git push origin v1.0.1
   ```

### Method 3: Manual Workflow Trigger

You can also manually trigger the release workflow from the GitHub Actions tab without creating a tag. This is useful for testing the workflow.

## What Happens During Release

1. **Testing Phase**: The workflow runs `flutter analyze` and `flutter test` to ensure code quality
2. **Web Build**: Creates a production web build and packages it as a ZIP file
3. **Android Build**: Creates a release APK for Android devices
4. **Release Creation**: Creates a GitHub release with:
   - Descriptive release notes
   - Installation instructions for both platforms
   - Both the web ZIP and Android APK attached as downloadable assets

## Release Assets

Each release will include:

### Web Version (`wordbubbles-web-vX.X.X.zip`)
- Complete web application ready to serve
- Can be deployed to any web server
- Includes all necessary assets and files

### Android APK (`wordbubbles-vX.X.X.apk`)
- Release-signed APK for Android devices
- Compatible with Android 5.0 (API level 21) and higher
- Can be installed directly on Android devices

## Version Numbering

Follow semantic versioning (SemVer):
- **Major version** (X.0.0): Breaking changes or major new features
- **Minor version** (0.X.0): New features that are backward compatible
- **Patch version** (0.0.X): Bug fixes and small improvements

Examples:
- `1.0.0` - Initial release
- `1.0.1` - Bug fix release
- `1.1.0` - New feature release
- `2.0.0` - Major update with breaking changes

## Monitoring Releases

1. Go to your GitHub repository
2. Click on the "Actions" tab to monitor the build progress
3. Once complete, check the "Releases" section to see your new release
4. Share the release URL with users for easy download access

## Troubleshooting

### Build Failures
- Check the Actions tab for detailed error logs
- Ensure all tests pass locally before creating a release
- Verify that the Flutter version in the workflow matches your development environment

### Missing Files
- Ensure you've committed all necessary files before creating the release
- Check that the Android build configuration is correct
- Verify that web assets are properly configured

### Permission Issues
- The workflow requires `contents: write` permission to create releases
- This should be automatically granted, but check repository settings if issues occur

## Customizing Release Notes

You can customize the release notes by editing the `.github/workflows/release.yml` file. The current template includes:
- Version information
- Download links
- Installation instructions
- System requirements

Feel free to modify the release body template to match your project's needs.
