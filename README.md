# Kepubify macOS App

A macOS application for converting EPUB files to Kobo KEPUB format using the [Kepubify](https://pgaskin.net/kepubify/) command-line tool.

## Features

- **Drag and Drop Interface**: Easily add EPUB files or folders for conversion
- **Batch Processing**: Convert multiple files at once
- **Full Kepubify Options**: Access to all Kepubify command-line options through a user-friendly GUI
- **Real-time Logging**: View conversion progress and output in real-time
- **Custom Output**: Specify output directory or use in-place conversion
- **Automatic Build System**: Uses Fastlane for automated builds and testing

## Screenshots

The app provides a clean, intuitive interface with:
- File selection area with drag-and-drop support
- Comprehensive conversion options panel
- Real-time progress and logging
- One-click conversion

## Requirements

- **macOS 12.0 (Monterey) or later**
- **Kepubify command-line tool** installed on your system

## Installation

### Prerequisites

1. **Install Kepubify**:
   ```bash
   brew install kepubify
   ```
   
   Or download from [Kepubify website](https://pgaskin.net/kepubify/dl/)

2. **Install Xcode**: Required for building the app from source

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/icod/kepubify-mac-app.git
   cd kepubify-mac-app
   ```

2. Install dependencies:
   ```bash
   # Install Ruby dependencies for Fastlane
   bundle install
   ```

3. Open the Xcode project:
   ```bash
   open kepubify-mac-app.xcodeproj
   ```

4. Build and run the app in Xcode

### Using Fastlane

The project includes Fastlane configuration for automated builds and testing:

```bash
# Install Fastlane dependencies
bundle install

# Build the app
bundle exec fastlane build

# Run tests
bundle exec fastlane test

# Build and test
bundle exec fastlane build_and_test

# Create a development build
bundle exec fastlane dev_build

# Archive for distribution
bundle exec fastlane archive
```

## Usage

1. **Add Files**: Click "Add Files" or "Add Folder" to select EPUB files for conversion
2. **Configure Options**: Set your desired conversion options
3. **Set Output**: Choose an output directory or enable in-place conversion
4. **Convert**: Click the "Convert" button to start the conversion process
5. **View Results**: Monitor progress in the log output area

### Conversion Options

#### Output Options
- **In-place conversion**: Don't add `_converted` suffix to output files
- **Update existing**: Skip files that have already been converted
- **No preserve dirs**: Flatten directory structure in output
- **Calibre compatible**: Use `.kepub` extension instead of `.kepub.epub`
- **Copy extensions**: Copy files with specified extensions unchanged

#### Text Processing Options
- **Smarten punctuation**: Convert straight quotes to smart quotes, etc.
- **Hyphenation**: Force enable, force disable, or use default
- **Fullscreen reading fixes**: Apply fixes for fullscreen reading bugs
- **Find & Replace**: Apply custom find and replace rules to HTML content
- **Charset**: Override HTML charset (default: utf-8)

#### Advanced Options
- **Verbose output**: Show detailed conversion information

## Project Structure

```
kepubify-mac-app/
├── KepubifyMacApp/
│   ├── Sources/
│   │   ├── KepubifyMacApp.swift      # Main app entry point
│   │   ├── ContentView.swift         # Main UI view
│   │   └── KepubifyManager.swift     # Kepubify integration and logic
│   └── Tests/
│       ├── KepubifyMacAppTests.swift # App tests
│       └── KepubifyManagerTests.swift # Manager tests
├── fastlane/
│   ├── Fastfile                       # Fastlane configuration
│   └── Appfile                        # App configuration
├── .github/
│   └── workflows/
│       └── build-and-test.yml         # GitHub Actions workflow
├── Gemfile                            # Ruby dependencies
├── kepubify-mac-app.xcodeproj/        # Xcode project
└── README.md
```

## Testing

The app includes comprehensive unit tests for:
- Kepubify availability checking
- Kepubify version detection
- File system operations
- Conversion option handling
- Status and progress tracking

Run tests using Xcode or Fastlane:
```bash
# Using Xcode
xcodebuild test -scheme KepubifyMacApp

# Using Fastlane
bundle exec fastlane test
```

## Continuous Integration

The project includes a GitHub Actions workflow that:
1. Checks out the repository
2. Sets up the build environment
3. Installs dependencies
4. Builds the app
5. Runs all tests
6. Uploads test results and build artifacts

The workflow runs automatically on pushes and pull requests to the main branch.

## Troubleshooting

### Kepubify not found

If you see "Kepubify not found" error:

1. Ensure Kepubify is installed:
   ```bash
   which kepubify
   ```

2. If installed via Homebrew, ensure it's in your PATH

3. You can also manually specify the path to Kepubify in the app settings (future feature)

### Permission issues

If you get permission errors when running Kepubify:
```bash
chmod +x /path/to/kepubify
```

### Build errors

1. Ensure you have Xcode installed
2. Make sure you're using a supported macOS version
3. Clean and rebuild the project

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Kepubify](https://pgaskin.net/kepubify/) by Patrick Gaskin - The core conversion engine
- [SwiftUI](https://developer.apple.com/documentation/swiftui) - Apple's modern UI framework
- [Fastlane](https://fastlane.tools/) - For automated builds and deployment

## Support

For issues or questions:
- Open an issue on GitHub
- Check the [Kepubify documentation](https://pgaskin.net/kepubify/docs/) for conversion options

---

**Note**: This app is a GUI wrapper around the Kepubify command-line tool. All conversion is performed by Kepubify, which must be installed separately on your system.
