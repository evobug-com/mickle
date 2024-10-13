# Mickle

Mickle is a next-generation chat application that allows you to communicate securely and privately with friends, family, and co-workers. Built with Flutter, it offers a cross-platform experience with a focus on security, privacy, and user-friendly features.

## Features

- Secure and private messaging
- Multi-server support
- Voice chat capabilities
- Customizable user interface
- Cross-platform support (Windows, macOS, Linux, Android, iOS)
- Automatic updates
- Rich text formatting and emoji support
- Localization support
- Tray icon and window management
- Launch at startup option
- Local notifications
- Connectivity status monitoring
- Encrypted shared preferences for secure storage

## Installation

### Prerequisites

- Flutter SDK (version 3.3.2 or higher)
- Dart SDK (version 3.3.2 or higher)

### Development Environment Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/mickle.git
   ```
2. Navigate to the project directory:
   ```
   cd mickle
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the app in debug mode:
   ```
   flutter run
   ```

## Project Structure

- `lib/`: Contains the main Dart source code
  - `areas/`: Core functionality areas (e.g., connection, security)
  - `components/`: Reusable UI components
  - `core/`: Core application logic and utilities
  - `generated/`: Generated localization files
  - `l10n/`: Localization resources
  - `layout/`: Layout-related widgets
  - `screens/`: Main application screens
  - `ui/`: Custom UI widgets
- `assets/`: Contains static assets (images, audio, scripts)
- `test/`: Unit and widget tests
- `integration_test/`: Integration tests
- `windows/`, `macos/`, `linux/`, `android/`, `ios/`: Platform-specific code

## Key Dependencies

- `go_router`: For application routing
- `audioplayers`: For audio playback
- `tray_manager` and `window_manager`: For system tray and window management
- `connectivity_plus`: For network connectivity monitoring
- `encrypt_shared_preferences`: For secure local storage
- `provider`: For state management
- `freezed`: For code generation of data classes
- `bot_toast`: For toast notifications
- `flutter_animate`: For animations
- `emoji_picker_flutter`: For emoji support
- `flutter_markdown`: For markdown rendering

For a complete list of dependencies, refer to the `pubspec.yaml` file.

## Building and Running

### Debug Mode

To run the app in debug mode:

```
flutter run
```

### Release Mode

To build the application for different platforms in release mode:

- Windows:
  ```
  flutter build windows
  ```
- macOS:
  ```
  flutter build macos
  ```
- Linux:
  ```
  flutter build linux
  ```
- Android:
  ```
  flutter build apk
  ```
- iOS:
  ```
  flutter build ios
  ```

## Testing

To run the tests, use the following commands:

- Unit and widget tests:
  ```
  flutter test
  ```
- Integration tests:
  ```
  flutter test integration_test
  ```

## Contributing

Contributions to Mickle are welcome! Here are some ways you can contribute:

1. Report bugs or suggest features by opening issues.
2. Submit pull requests for bug fixes or new features.
3. Improve documentation or add translations.

Please ensure that your code adheres to the project's coding standards and includes appropriate tests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

- GitHub: [sionzee](https://github.com/sionzee)
- Email: [mickle.support@evobug.com](mailto:mickle.support@evobug.com)
- Website: https://evobug.com
- Twitter: [@MickleApp](https://twitter.com/MickleApp)

For more information about the project roadmap, visit: https://roadmap.evobug.dev/
