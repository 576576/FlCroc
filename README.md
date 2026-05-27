# 🐊 FlCroc

<p align="center">
  <strong>A Flutter GUI for <a href="https://github.com/schollz/croc">croc</a></strong>
  <br>
  <em>Easily and securely transfer files between any two computers</em>
</p>

<p align="center">
  <a href="docs/README_zh.md">📖 中文文档</a> &nbsp;|&nbsp;
  <a href="#-features">Features</a> ·
  <a href="#-getting-started">Getting Started</a> ·
  <a href="#-build">Build</a> ·
  <a href="#-architecture">Architecture</a>
</p>

<p align="center">
  <img alt="Platforms" src="https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS-blue" />
  <img alt="License" src="https://img.shields.io/github/license/576576/FlCroc?color=green" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter" />
  <img alt="croc" src="https://img.shields.io/badge/croc-v10.4.4-blue" />
</p>

---

## ✨ Features

- **📊 Dashboard** — Transfer speed monitoring, total statistics, drag-to-reorder widget grid
- **📤 Send** — File & text sending, 3 phrase modes (Default / FlCroc / Custom), QR code, drag-and-drop, auto-copy
- **📥 Receive** — Code phrase input with paste & QR scanner, one-tap receive
- **📜 History** — Track all transfers with status chips and statistics
- **⚙️ Settings** — 3 relay types (Default / Custom / None), custom relay address/port/password with visibility toggle, theme (Light / Dark / Pure Black), language
- **🌍 i18n** — English & 中文
- **🔒 Secure** — End-to-end encryption via croc's PAKE protocol (curve: p256, hash: xxhash)
- **💾 Persistent** — All settings auto-saved via SharedPreferences
- **🖥️ Cross-platform** — Android, Windows, Linux, macOS

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.12
- Go ≥ 1.23 (croc source is vendored at `lib/croc/`)

### Install

```bash
git clone https://github.com/576576/FlCroc.git
cd FlCroc
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Run

```bash
flutter run
```

## 🔨 Build

croc source is vendored at `lib/croc/` (v10.4.4). The Go bridge in `go_bridge/` builds as a CGO shared library (`.so` / `.dll` / `.dylib`) loaded via `dart:ffi`.

### Android
```bash
flutter build apk --release
```

### Windows
```bash
cd go_bridge
$env:CGO_ENABLED="1"; $env:GOOS="windows"; $env:GOARCH="amd64"
go build -buildmode=c-shared -ldflags="-s -w" -o ../windows/runner/libcroc_bridge.dll .
cd ..
flutter build windows --release
```

### Linux
```bash
cd go_bridge
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
  go build -buildmode=c-shared -ldflags="-s -w" -o ../linux/flutter/ephemeral/libcroc_bridge.so .
cd ..
flutter build linux --release
```

### macOS
```bash
flutter build macos --release
```

> ℹ️ **croc is fully vendored** at `lib/croc/`. The Go FFI bridge calls croc's internal packages directly — no CLI subprocess. The shared library is bundled into every release artifact.

## 🏗️ Architecture

```
lib/
├── main.dart              # Entry point (Riverpod ProviderScope)
├── application.dart       # MaterialApp with ThemeManager & i18n
├── controller.dart        # AppController singleton
├── common/                # Utilities, constants, AppPrefs
├── enum/                  # Enums (RelayType, etc.)
├── models/                # Freezed data models
├── providers/             # Riverpod state providers
├── core/                  # Croc backend (FFI bridge)
├── go_bridge/             # Go CGO bridge (shared library)
├── lib/croc/              # Vendored croc source (v10.4.4)
├── l10n/                  # Localization (en, zh)
├── pages/                 # HomePage (responsive sidebar/navbar)
├── views/                 # Feature views
│   ├── dashboard/         # Dashboard + drag-reorder grid
│   ├── send/              # Send files & text
│   ├── receive/           # Receive with QR scanner & paste
│   ├── history/           # Transfer history
│   └── settings/          # App & relay config
└── widgets/               # Reusable Material 3 widgets
```

## 🧰 Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.44 · Material 3 |
| State | Riverpod · Freezed |
| Backend | Go CGO FFI — calls croc as a library |
| Storage | SharedPreferences (AppPrefs) |
| Scanner | mobile_scanner |
| QR | qr_flutter |
| CI/CD | GitHub Actions (build + nightly) |

## 🤝 Acknowledgments

FlCroc's UI architecture is heavily inspired by **[FlClash](https://github.com/chen08209/FlClash)**. The core file transfer engine is powered by **[croc](https://github.com/schollz/croc)**.

## 📄 License

[GNU General Public License v3.0](LICENSE)
