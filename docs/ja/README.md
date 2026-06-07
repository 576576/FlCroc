<p align="center">
  <img src="../../assets/images/icon.png" width="64" alt="FlCroc">
</p>

<h1 align="center">FlCroc</h1>

<p align="center">
<a href="../zh/README.md">中文 (简体)</a> &nbsp;|&nbsp; <a href="../zh-Hant/README.md">中文 (繁體)</a> &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; <a href="../fr/README.md">Français</a> &nbsp;|&nbsp; <a href="../../README.md">English</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux-blue" alt="Platform">
  <img src="https://img.shields.io/badge/license-GPL v3-green" alt="License">
  <img alt="version" src="https://img.shields.io/badge/version-1.2.3-informational" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44.1-02569B?logo=flutter" />
  <img alt="croc" src="https://img.shields.io/badge/croc-10.4.4-blue" />
</p>

<em>croc の Flutter GUI — コンピュータ間で安全にファイルを転送</em>

---

## ✨ 機能

| | 機能 |
|---|-----|
| 🖥️ | クロスプラットフォーム (Windows、Linux、Android) |
| 🔒 | croc によるエンドツーエンド暗号化ファイル転送 |
| 🌍 | ネイティブ多言語サポート (詳細は [i18n.md](../i18n.md) を参照) |
| 🌙 | アダプティブレイアウト、アニメーション、カスタム配色を備えたモダンな Flutter UI |

---

## 🚀 ビルド

ビルド手順とプラットフォーム別ガイドは [BUILD.md](../BUILD.md) を参照してください。

---

## 🏗️ アーキテクチャ

```
FlCroc/
├── lib/               Flutter アプリ (Riverpod + Material 3)
├── go_bridge/         Go CGO 共有ライブラリ (FFI ブリッジ)
├── submodules/croc/   内蔵 croc ソース
├── assets/            アプリアイコン、i18n JSON バンドル
├── .github/workflows/ CI/CD (build.yml)
└── (platform)/
```

---

## 🧰 技術スタック

| レイヤー | 技術 |
|-------|------------|
| UI | Flutter 3.44 · Material 3 |
| 状態管理 | Riverpod · Freezed |
| バックエンド | Go CGO FFI · croc サブモジュール |
| 国際化 | JSON バンドル |
| CI/CD | GitHub Actions |

---

## 🌍 国際化

各言語の状況と貢献ガイドについては [docs/i18n.md](../i18n.md) を参照してください。

---

## 🙏 謝辞

| プロジェクト | 説明 |
|---------|-------------|
| [croc](https://github.com/schollz/croc) | バックエンドファイル転送エンジン |
| [Flutter](https://flutter.dev) | クロスプラットフォーム UI フレームワーク |
| [FlClash](https://github.com/chen08209/FlClash) | UI デザインのインスピレーション |
| [croc-app](https://github.com/Dking08/croc-app) | QR スキャナ実装の参考 |

---

## 📄 ライセンス

GPL3 © FlCroc Contributors
