# 🐊 FlCroc

<p align="center">
  <img src="assets/images/icon.png" alt="FlCroc" width="96" height="96" />
</p>

<p align="center">
  <strong>A Flutter GUI for <a href="https://github.com/schollz/croc">croc</a></strong>
  <br>
  <em>Easily and securely transfer files between any two computers</em>
</p>

<p align="center">
  <a href="#-features">Features</a> ·
  <a href="#-screenshots">Screenshots</a> ·
  <a href="#-getting-started">Getting Started</a> ·
  <a href="#-build">Build</a> ·
  <a href="#-architecture">Architecture</a>
</p>

<p align="center">
  <img alt="Platforms" src="https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS-blue" />
  <img alt="License" src="https://img.shields.io/github/license/576576/FlCroc?color=green" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter" />
</p>

---

## ✨ Features

- **📊 Dashboard** — Transfer speed monitoring, total statistics, drag-to-reorder widget grid
- **📤 Send** — Multi-file selection, text sending, auto-generated code phrase, QR code display
- **📥 Receive** — Code phrase input, QR code scanner, auto-accept
- **📜 History** — Track all transfers with status chips and statistics
- **⚙️ Settings** — Relay server config, theme customization (light/dark/pure black), language switching
- **🌍 i18n** — English & 中文, extensible
- **🔒 Secure** — End-to-end encryption via croc's PAKE protocol
- **🖥️ Cross-platform** — Android, Windows, Linux, macOS

## 📸 Screenshots

| Desktop | Mobile |
|---------|--------|
| *Coming soon* | *Coming soon* |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.12
- Go ≥ 1.23 (for croc FFI bridge)

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

### Android
```bash
flutter build apk --release
```

### Windows
```bash
flutter build windows --release
```

### Linux
```bash
flutter build linux --release
```

### macOS
```bash
flutter build macos --release
```

> ℹ️ **croc is built from source** during CI and bundled into every release artifact. You don't need to install croc separately — it ships inside the app.

## 🏗️ Architecture

```
lib/
├── main.dart              # Entry point (Riverpod ProviderScope)
├── application.dart       # MaterialApp with ThemeManager & i18n
├── controller.dart        # AppController singleton
├── state.dart             # GlobalState singleton
├── common/                # Utilities, constants, extensions
├── enum/                  # Enums (PageLabel, DashboardWidget, etc.)
├── models/                # Freezed data models
├── providers/             # Riverpod state providers
├── core/                  # Croc backend (FFI bridge + process)
├── manager/               # Theme manager
├── l10n/                  # Localization (en, zh)
├── pages/                 # HomePage (responsive sidebar/navbar)
├── views/                 # Feature views
│   ├── dashboard/         # Dashboard + drag-reorder widget grid
│   ├── send/              # Send files & text
│   ├── receive/           # Receive with QR scanner
│   ├── history/           # Transfer history
│   └── settings/          # App configuration
└── widgets/               # Reusable Material 3 widgets
```

## 🧰 Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.44 · Material 3 |
| State | Riverpod · Freezed |
| Backend | Go CGO FFI (`c-shared`) + process |
| Storage | SharedPreferences |
| Scanner | mobile_scanner |
| QR | qr_flutter |
| CI/CD | GitHub Actions |

## 🤝 Acknowledgments

FlCroc's UI architecture is heavily inspired by **[FlClash](https://github.com/chen08209/FlClash)** — an elegant, well-structured Flutter application. The core file transfer engine is powered by **[croc](https://github.com/schollz/croc)**.

## 📄 License

[GNU General Public License v3.0](LICENSE)

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/576576">576576</a>
</p>
