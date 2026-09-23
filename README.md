<p align="center">
  <img src="assets/images/icon.png" width="64" alt="FlCroc">
</p>

<h1 align="center">FlCroc</h1>

<p align="center">
<a href="docs/zh/README.md">中文 (简体)</a> &nbsp;|&nbsp; <a href="docs/zh-Hant/README.md">中文 (繁體)</a> &nbsp;|&nbsp; <a href="docs/ja/README.md">日本語</a> &nbsp;|&nbsp; <a href="docs/fr/README.md">Français</a> &nbsp;|&nbsp; English
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20Android-blue" alt="Platform">
  <img src="https://img.shields.io/badge/license-GPL v3-green" alt="License">
  <img alt="version" src="https://img.shields.io/badge/version-1.2.4-informational" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter" />
  <img alt="croc" src="https://img.shields.io/badge/croc-11.5.2-blue" />
</p>

<em>A Flutter GUI for croc — easily and securely transfer files between computers</em>

---

## ✨ Features

| | Features |
|---|-----|
| 🖥️ | Cross-platform (Windows, Linux, macOS, Android) |
| 🔒 | End-to-end encrypted file transfer via croc |
| 🌍 | Native multi-language support (see [i18n.md](docs/i18n.md) for details) |
| 🌙 | Modern Flutter UI with adaptive layout, animations, and custom color schemes |

---

## 🚀 Build

See [BUILD.md](docs/BUILD.md) for build instructions and platform-specific guides.

---

## 🏗️ Architecture

```
FlCroc/
├── lib/               Flutter app (Riverpod + Material 3)
├── go_bridge/         Go CGO shared library (FFI bridge)
├── submodules/croc/   Vendored croc source
├── assets/            App icon, I18n JSON bundles
├── .github/workflows/ CI/CD (release.yml + build.yml)
└── (platform)/
```

---

## 🧰 Tech Stack

| Layer | Technology |
|-------|------------|
| UI | Flutter 3.47.5 · Material 3 |
| State | Riverpod · Freezed |
| Backend | Go CGO FFI · croc submodule |
| I18n | JSON bundles |
| CI/CD | GitHub Actions |

---

## 🌍 I18n

See [docs/i18n.md](docs/i18n.md) for language status and contribution guide.

---

## 🙏 Acknowledgments

| Project | Description |
|---------|-------------|
| [croc](https://github.com/schollz/croc) | Backend file transfer engine |
| [Flutter](https://flutter.dev) | Cross-platform UI framework |
| [FlClash](https://github.com/chen08209/FlClash) | UI inspiration |
| [croc-app](https://github.com/Dking08/croc-app) | QR scanner reference |

---

## 📄 License

GPL3 © FlCroc Contributors
