# 🐊 FlCroc

<p align="center">
  <strong>A modern Flutter GUI for <a href="https://github.com/schollz/croc">croc</a></strong>
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

| | |
|---|---|
| 🐊 **Built-in croc** | All capabilities of [croc](https://github.com/schollz/croc) — encrypted transfer, PAKE, relay, text & file, code phrases. See [croc README](lib/croc/README.md). |
| 🎨 **Modern UI** | Material 3 design with light/dark/pure-black themes, responsive layout, drag-and-drop, collapsible settings. |
| 🖥️ **Cross-platform** | Android · Windows · Linux · macOS — single codebase, native performance. |
| 🌍 **Multi-language** | Supports most alphabet & non-Alphabet languages, extensible via `lib/l10n/`. Contribute to your language support through pull-request! |

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

croc source is linked AS-IS at `lib/croc/`. The Go bridge in `go_bridge/` builds as a CGO shared library (`.so` / `.dll` / `.dylib`) loaded via `dart:ffi`.

### Windows
```bash
cd go_bridge
$env:CGO_ENABLED="1"; $env:GOOS="windows"; $env:GOARCH="amd64"
go build -buildmode=c-shared -ldflags="-s -w" -o ../windows/runner/libcroc_bridge.dll .
cd .. && flutter build windows --release
```

### Linux
```bash
cd go_bridge
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
  go build -buildmode=c-shared -ldflags="-s -w" -o ../linux/flutter/ephemeral/libcroc_bridge.so .
cd .. && flutter build linux --release
```

### Android / macOS
```bash
flutter build apk --release
flutter build macos --release
```

> ℹ️ **croc is fully vendored**. The Go FFI bridge calls croc's internal packages directly — no CLI subprocess. The shared library is bundled into every release artifact.

## 🏗️ Architecture

```
lib/
├── main.dart              # Entry point (Riverpod)
├── application.dart       # MaterialApp + Theme + i18n
├── common/                # Utilities, constants, AppPrefs
├── enum/                  # Enums
├── models/                # Freezed data models
├── providers/             # Riverpod state providers
├── core/                  # Croc backend (Go FFI bridge)
├── go_bridge/             # Go CGO shared library
├── lib/croc/              # Vendored croc source
├── l10n/                  # Localization (en, zh)
├── pages/                 # HomePage
├── views/                 # Feature views (send, receive, history, settings)
└── widgets/               # Reusable Material 3 widgets
```

## 🧰 Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.44 · Material 3 |
| State | Riverpod · Freezed |
| Backend | Go CGO FFI (`c-shared`) |
| Storage | SharedPreferences |
| CI/CD | GitHub Actions |

## 🤝 Acknowledgments

FlCroc's UI is inspired by **[FlClash](https://github.com/chen08209/FlClash)**. Powered by **[croc](https://github.com/schollz/croc)**.

## 📄 License

[GNU General Public License v3.0](LICENSE)
