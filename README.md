# FlCroc

<p align="center">
  <strong>🐊 A Flutter GUI for <a href="https://github.com/schollz/croc">croc</a> — easily and securely transfer files between computers</strong>
</p>

<p align="center">
  <a href="docs/README_zh.md">📖 中文文档</a> &nbsp;|&nbsp;
  Inspired by <a href="https://github.com/chen08209/FlClash">FlClash</a>'s elegant Material 3 design.
</p>

## Features

- **Dashboard** — Transfer speed monitoring, total statistics, quick actions
- **Send Files** — Multi-file selection, auto-generated or custom code phrase, QR code display, text sending
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
├── common/                # Utilities, constants, extensions
├── enum/                  # All enums
├── models/                # Freezed data models
├── providers/             # Riverpod providers
├── core/                  # Backend (FFI + process)
├── manager/               # State managers (theme)
├── l10n/                  # Localization (en, zh_CN)
├── pages/                 # HomePage (responsive nav)
├── views/                 # Feature views
│   ├── dashboard/         # Dashboard with SuperGrid widgets
│   ├── send/              # File send interface
│   ├── receive/           # File receive interface
│   ├── history/           # Transfer history
│   └── settings/          # App settings
├── widgets/               # Reusable widgets
└── go_bridge/             # Go FFI bridge to croc
```

## Getting Started

### Prerequisites
- Flutter SDK ^3.12.0
- Go 1.25+ (required — croc is built from source)

### Install
```bash
flutter pub get
dart run build_runner build
```

### Build croc from source (all platforms)
```bash
# Clone croc repository
git clone --depth 1 --branch v10.4.4 https://github.com/schollz/croc.git /tmp/croc_src

# Desktop: build standalone binary
cd /tmp/croc_src
CGO_ENABLED=0 go build -ldflags="-s -w" -o croc .
cp croc linux/flutter/ephemeral/croc        # Linux
cp croc.exe windows/runner/croc.exe         # Windows (cross-compile with GOOS=windows)

# Android: build Go CGO shared library (requires Android NDK)
cd go_bridge
go mod edit -replace github.com/schollz/croc/v10=/tmp/croc_src
go mod tidy
CGO_ENABLED=1 GOOS=android GOARCH=arm64 \
  CC=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang \
  go build -buildmode=c-shared -o ../android/app/src/main/jniLibs/arm64-v8a/libcroc_bridge.so .
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

# Linux
flutter build linux

# macOS
flutter build macos
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter (Dart) |
| State | Riverpod + Freezed |
| UI | Material 3 |
| Backend | Go FFI (c-shared) + process |
| Storage | SharedPreferences |
| Scanner | mobile_scanner |
| QR | qr_flutter |

## CI/CD

GitHub Actions automatically builds for all platforms on push:
- **Android ARM64** — Go cross-compile → APK
- **Windows AMD64** — bundled croc.exe → zip
- **Linux AMD64** — bundled croc → .deb

See `.github/workflows/build.yml`.

## License

[GNU General Public License v3.0](LICENSE)

## Acknowledgments

- [FlClash](https://github.com/chen08209/FlClash) — UI architecture inspiration
- [croc](https://github.com/schollz/croc) — Core file transfer engine
