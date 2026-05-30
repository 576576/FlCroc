# FlCroc

<p align="center">
  <img src="assets/images/icon.png" alt="FlCroc" width="96" />
</p>

<p align="center">
  <strong>A modern Flutter GUI for <a href="https://github.com/schollz/croc">croc</a></strong><br>
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
  <img alt="version" src="https://img.shields.io/badge/version-1.0.1-informational" />
</p>

---

## ✨ Features

| | |
|---|---|
| 🐊 **Built-in croc** | Full [croc](https://github.com/schollz/croc) capabilities — encrypted transfer, PAKE, relay, text & file, code phrases. See [croc README](submodules/croc/README.md). |
| 🎨 **Modern UI** | Material 3 design with light / dark / pure-black themes, responsive layout, collapsible settings. |
| 🖥️ **Cross-platform** | Android · Windows · Linux · macOS — single codebase, native performance. |
| 🌍 **Multi-language** | English, 中文 — extensible via JSON bundles in `assets/bundles/`. |

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.12 |
| Go | ≥ 1.25 |

### Install

```bash
git clone --recurse-submodules https://github.com/576576/FlCroc.git
cd FlCroc
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Run

```bash
flutter run
```

## 🔨 Build

The Go bridge in `go_bridge/` builds as a CGO shared library (`.so` / `.dll` / `.dylib`) loaded via `dart:ffi`. croc source is vendored at `submodules/croc/`.

### Windows

```bash
cd go_bridge
$env:CGO_ENABLED="1"; $env:GOOS="windows"; $env:GOARCH="amd64"
go build -buildmode=c-shared -ldflags="-s -w -H windowsgui" -o ../windows/runner/libcroc_bridge.dll .
cd .. && flutter build windows --release
```

### Linux

```bash
cd go_bridge
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
  go build -buildmode=c-shared -ldflags="-s -w" -o ../linux/flutter/ephemeral/libcroc_bridge.so .
cd .. && flutter build linux --release
```

### macOS

```bash
cd go_bridge
CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 \
  go build -buildmode=c-shared -ldflags="-s -w" -o ../macos/Runner/libcroc_bridge.dylib .
cd .. && flutter build macos --release
```

### Android

```bash
flutter build apk --release --target-platform android-arm64
```

> ℹ️ **croc is fully vendored.** The Go FFI bridge calls croc's internal packages directly — no CLI subprocess. The shared library is bundled into every release artifact.

## 🏗️ Architecture

```
fl_croc/
├── lib/                      # Flutter app (Riverpod + Material 3)
├── go_bridge/                # Go CGO shared library (FFI bridge)
├── submodules/croc/          # Submodule croc
├── assets/
│   ├── images/icon.png       # App icon (source for all platforms)
│   └── bundles/              # I10n JSON bundles
├── android/ ios/ linux/ macos/ windows/ web/
└── .github/workflows/        # CI/CD (build.yml)
```

## 🧰 Tech Stack

| Layer | Technology |
|-------|------------|
| UI | Flutter 3.44 · Material 3 |
| State | Riverpod · Freezed · Drift |
| Backend | Go 1.25 CGO FFI · croc v10.4.4 |
| I10n | JSON bundles |
| CI/CD | GitHub Actions |

## 🌍 I10n Contribution

Translations are stored as JSON in `assets/bundles/`. To add a new language:

1. Copy `assets/bundles/en.json` to `assets/bundles/{code}.json` (e.g. `ja.json`, `ko.json`)
2. Translate all values (keep keys unchanged)
3. Register the locale in `lib/l10n/app_localizations.dart` → `supportedLocales`
4. Submit a pull request

> 💡 The fallback locale is English. Missing keys will display their key name.

## 📄 License

[GNU General Public License v3.0](LICENSE)
