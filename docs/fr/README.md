<p align="center">
  <img src="../../assets/images/icon.png" width="64" alt="FlCroc">
</p>

<h1 align="center">FlCroc</h1>

<p align="center">
<a href="../zh/README.md">中文 (简体)</a> &nbsp;|&nbsp; <a href="../zh-Hant/README.md">中文 (繁體)</a> &nbsp;|&nbsp; <a href="../ja/README.md">日本語</a> &nbsp;|&nbsp; Français &nbsp;|&nbsp; <a href="../../README.md">English</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux-blue" alt="Platform">
  <img src="https://img.shields.io/badge/license-GPL v3-green" alt="License">
  <img alt="version" src="https://img.shields.io/badge/version-1.2.2-informational" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44.1-02569B?logo=flutter" />
  <img alt="croc" src="https://img.shields.io/badge/croc-10.4.4-blue" />
</p>

<em>Une interface Flutter pour croc — transférez facilement et en toute sécurité des fichiers entre ordinateurs</em>

---

## ✨ Fonctionnalités

| | Fonctionnalités |
|---|-----|
| 🖥️ | Multi-plateforme (Windows, Linux, Android) |
| 🔒 | Transfert de fichiers chiffré de bout en bout via croc |
| 🌍 | Support multilingue natif (voir [i18n.md](../i18n.md) pour plus de détails) |
| 🌙 | Interface Flutter moderne avec mise en page adaptative, animations et thèmes personnalisés |

---

## 🚀 Compilation

Voir [BUILD.md](../BUILD.md) pour les instructions de compilation et les guides spécifiques à chaque plateforme.

---

## 🏗️ Architecture

```
FlCroc/
├── lib/               Application Flutter (Riverpod + Material 3)
├── go_bridge/         Bibliothèque partagée Go CGO (pont FFI)
├── submodules/croc/   Source croc intégrée
├── assets/            Icône de l'application, bundles JSON i18n
├── (platform)/          Android, iOS, Linux, macOS, Windows, Web
└── .github/workflows/           CI/CD (build.yml)
```

---

## 🧰 Stack technique

| Couche | Technologie |
|-------|------------|
| UI | Flutter 3.44 · Material 3 |
| État | Riverpod · Freezed |
| Backend | Go CGO FFI · sous-module croc |
| I18n | Bundles JSON |
| CI/CD | GitHub Actions |

---

## 🌍 I18n

Voir [docs/i18n.md](../i18n.md) pour l'état des langues et le guide de contribution.

---

## 🙏 Remerciements

| Projet | Description |
|---------|-------------|
| [croc](https://github.com/schollz/croc) | Moteur de transfert de fichiers backend |
| [Flutter](https://flutter.dev) | Framework UI multiplateforme |
| [FlClash](https://github.com/chen08209/FlClash) | Inspiration pour le design UI |
| [croc-app](https://github.com/Dking08/croc-app) | Référence pour l'implémentation du scanner QR |

---

## 📄 Licence

GPL3 © FlCroc Contributors
