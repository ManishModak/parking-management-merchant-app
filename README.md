# CityPark Merchant App

A Flutter application for Automatic Parking Management, designed for merchants to manage parking operations efficiently.

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Development Setup](#development-setup)
- [Known Issues](#known-issues)
- [Localization](#localization)
- [Contributing](#contributing)
- [Development Notes](#development-notes)

## 🏙️ About

CityPark Merchant App is a comprehensive parking management solution that enables merchants to:
- Manage automatic parking operations
- Process payments and generate reports
- Monitor parking spaces in real-time
- Handle customer interactions and support

## ✨ Features

- **Real-time Parking Management**: Monitor and manage parking spaces
- **Payment Processing**: Handle payments with multiple methods
- **QR Code Generation**: Generate QR codes for parking transactions
- **NFC Support**: Near Field Communication for contactless operations
- **Camera Integration**: Capture images for verification and documentation
- **PDF Reports**: Generate and export parking reports
- **Multi-language Support**: Internationalization support
- **Offline Capability**: Works with limited connectivity
- **Geolocation**: Location-based services
- **Real-time Communication**: WebSocket and Socket.IO integration

## 📱 Demo

**Screen Recording of the App**: [Watch the app in action](https://drive.google.com/file/d/19jxe3WODNVjl6a4ZXgAJnHCSE6ZMwmCl/view?usp=sharing)

## 📋 Requirements

### System Requirements

- **Flutter SDK**: ^3.5.3
- **Dart SDK**: Compatible with Flutter SDK
- **Java**: JDK 24 (for Android development)
- **Android Gradle Plugin**: 8.6.0+
- **Gradle**: 8.14+
- **Kotlin**: 1.9.10+

### Platform Support

- **Android**: Minimum SDK 21 (Android 5.0)
- **iOS**: iOS 12.0+ (requires additional setup)

### Development Environment

- **Android Studio**: Latest version recommended
- **Visual Studio Code**: With Flutter and Dart extensions
- **Xcode**: Required for iOS development (macOS only)

## 🚀 Installation

### Prerequisites

1. **Install Flutter SDK**
   ```bash
   # Follow official Flutter installation guide
   # https://docs.flutter.dev/get-started/install
   ```

2. **Install Java 24**
   ```bash
   # Ensure Java 24 is installed and configured
   java -version
   ```

3. **Verify Flutter Installation**
   ```bash
   flutter doctor
   ```

### Clone and Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd CityPark-Merchant-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files**
   ```bash
   flutter packages pub run intl_utils:generate
   ```

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS (macOS only)
   flutter run -d ios
   ```

## 🛠️ Development Setup

### Android Setup

1. **Configure Android SDK**
   - Ensure Android SDK is properly installed
   - Set `ANDROID_HOME` environment variable

2. **Gradle Configuration**
   - Android Gradle Plugin: 8.6.0
   - Gradle: 8.14
   - Kotlin: 1.9.10

### iOS Setup (if applicable)

⚠️ **Important**: iOS permissions need to be configured in `ios/Runner/Info.plist`:

```xml
<!-- Add camera permission -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture parking-related images</string>

<!-- Add location permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide location-based parking services</string>

<!-- Add NFC permission (if using NFC) -->
<key>NFCReaderUsageDescription</key>
<string>This app uses NFC for contactless parking operations</string>
```

### Key Dependencies

```yaml
# Core Dependencies
flutter: sdk
provider: ^6.0.0          # State management
http: ^1.2.2              # HTTP requests
camera: ^0.11.1           # Camera functionality
qr_flutter: ^4.1.0       # QR code generation
nfc_manager: ^4.0.2       # NFC operations
geolocator: ^13.0.3       # Location services
socket_io_client: ^3.1.2  # Real-time communication

# UI & UX
fl_chart: ^0.69.2         # Charts and graphs
shimmer: ^3.0.0           # Loading animations
flutter_spinkit: ^5.2.1   # Loading indicators
cached_network_image: ^3.4.1 # Image caching

# Storage & Files
flutter_secure_storage: ^9.2.4 # Secure storage
shared_preferences: ^2.5.2     # Simple key-value storage
path_provider: ^2.0.15         # File system paths
file_picker: ^10.1.9           # File selection
```

### Build Commands

```bash
# Development build
flutter run --debug

# Release build for Android
flutter build apk --release

# Release build for iOS
flutter build ios --release

# Clean build
flutter clean && flutter pub get
```

## ⚠️ Known Issues

### Development Issues

1. **iOS Permissions**: iOS build requires manual permission configuration in Info.plist
2. **Plaza ID Bug**: Plaza registration fails if Plaza ID starts with '0' (Backend issue)
3. **Camera Dependencies**: Requires Android Gradle Plugin 8.6.0+ for AndroidX Camera libraries

### Backend Issues

- Plaza ID response may differ from request when ID starts with '0'
- Check backend API responses carefully for ID consistency

### Build Issues

- **Java 24 Compatibility**: Ensure Gradle 8.14+ is used
- **Android Gradle Plugin**: Must be 8.6.0+ for camera dependencies

## 🌍 Localization

### Supported Languages

**International Languages (Requested)**:
- English (default) (Done)
- Thailand (Pending)
- Malaysia (Pending)
- Mandarin (Chinese) (Pending)
- Vietnam (Pending)
- Singapore (Pending)
- Arabic (Pending)

**National Languages (Indian - Requested)**:
- Tamil (Pending)
- Telugu (Pending)
- Malayalam (Pending)
- Hindi (Pending)
- Marathi (Pending)
- Bengali (Pending)
- Gujarati (Pending)
- Tulu (Karnataka) (Pending)
- Kannada (Pending)

### Adding New Languages

1. Add language files in `lib/l10n/`
2. Run `flutter packages pub run intl_utils:generate`
3. Update supported locales in the app configuration

## 🤝 Contributing

### Development Guidelines

1. **Code Quality**: Follow Flutter best practices
2. **Testing**: Write tests for new features
3. **Documentation**: Update README and comments
4. **State Management**: Use Provider pattern consistently

### Important Notes from Developer

> ⚠️ **Developer Warning**: 
> - Don't modify User and Plaza modules unless absolutely necessary (created during late-night coding sessions)
> - Some code might be inefficient but functional - avoid unnecessary refactoring
> - Extensive AI assistance was used to meet deadlines
> - Test thoroughly before deploying changes

## 📝 Development Notes

### Architecture

- **State Management**: Provider pattern
- **API Communication**: HTTP with error handling
- **Real-time Updates**: WebSocket & Socket.IO
- **Local Storage**: Secure storage + SharedPreferences
- **Image Processing**: Camera + Image picker + Caching

### Performance Considerations

- Image caching implemented for better performance
- Shimmer loading effects for better UX
- Connectivity checking for offline handling
- Optimized chart rendering with fl_chart

### Security Features

- Secure storage for sensitive data
- Permission handling for camera, location, NFC
- HTTP error handling and validation

## 📞 Support

For issues and support:
1. Check [Known Issues](#known-issues) section
2. Review Flutter and Android documentation
3. Ensure all requirements are met
4. Test on clean environment before reporting issues

---
