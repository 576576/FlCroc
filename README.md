# FlCroc

<p align="center">
  <img src="assets/images/icon.png" width="128" alt="FlCroc"/>
</p>

<p align="center">
  <strong>🐊 A Flutter GUI for <a href="https://github.com/schollz/croc">croc</a> — easily and securely transfer files between computers</strong>
</p>

<p align="center">
  Inspired by <a href="https://github.com/chen08209/FlClash">FlClash</a>'s elegant Material 3 design.
</p>

## Features

- **Dashboard** — Transfer speed monitoring, total statistics, quick actions
- **Send Files** — Multi-file selection, auto-generated or custom code phrase, QR code display
- **Receive Files** — Enter code phrase or scan QR code to receive
- **History** — Track all sent and received transfers
- **Settings** — Relay server configuration, theme customization, language switching
- **Cross-platform** — Android, Windows, macOS, Linux
- **End-to-end encryption** — Powered by croc's PAKE protocol

## Architecture

FlCroc follows FlClash's proven architecture patterns:

```
lib/
├── main.dart              # Entry point (Riverpod ProviderScope)
├── application.dart       # MaterialApp with ThemeManager
├── controller.dart        # AppController singleton
├── state.dart             # GlobalState singleton
├── common/                # Utilities, constants, extensions (~15 files)
├── enum/                  # All enums
├── models/                # Freezed data models
├── providers/             # Riverpod providers
├── core/                  # Backend interface (FFI + process)
├── manager/               # State managers (theme)
├── l10n/                  # Localization (en, zh_CN)
├── pages/                 # HomePage (responsive nav)
├── views/                 # Feature views
│   ├── dashboard/         # Dashboard with SuperGrid widgets
│   ├── send/              # File send interface
│   ├── receive/           # File receive interface
│   ├── history/           # Transfer history
│   └── settings/          # App settings
├── widgets/               # Reusable widgets (~15 files)
└── go_bridge/             # Go FFI bridge to croc
```

## Getting Started

### Prerequisites
- Flutter SDK ^3.12.0
- Go 1.25+ (for building the bridge library)
- croc CLI (bundled or installed separately)

### Install Dependencies
```bash
flutter pub get
dart run build_runner build
```

### Build Go Bridge
```bash
cd go_bridge
# Windows
.\build.bat
# Linux/macOS
./build.sh linux amd64
```

### Run
```bash
flutter run
```

### Build
```bash
# Android
flutter build apk

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter (Dart) |
| State | Riverpod + Freezed |
| UI | Material 3 |
| Backend | Go FFI (c-shared library) |
| Storage | SharedPreferences + Drift |

## License

MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgments

- [FlClash](https://github.com/chen08209/FlClash) — UI architecture inspiration
- [croc](https://github.com/schollz/croc) — Core file transfer engine
