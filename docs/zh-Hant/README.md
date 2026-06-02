<p align="center">
  <img src="../../assets/images/icon.png" width="64" alt="FlCroc">
</p>

<h1 align="center">FlCroc</h1>

<p align="center">
<a href="README.md">English</a> &nbsp;|&nbsp; <a href="docs/fr/README.md">Français</a> &nbsp;|&nbsp; <a href="docs/ja/README.md">日本語</a> &nbsp;|&nbsp; 中文 &nbsp;|&nbsp; <a href="docs/zh/README.md">中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux-blue" alt="Platform">
  <img src="https://img.shields.io/badge/license-GPL v3-green" alt="License">
  <img alt="version" src="https://img.shields.io/badge/version-1.2.2-informational" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44.1-02569B?logo=flutter" />
  <img alt="croc" src="https://img.shields.io/badge/croc-10.4.4-blue" />
</p>

<em>Croc 的 Flutter 圖形界面 — 輕鬆安全地在計算機之間傳輸文件</em>

---

## ✨ 功能特性

| | 功能特性 |
|---|-----|
| 🖥️ | 跨平台 (Windows、Linux、Android) |
| 🔒 | 通過 croc 實現端到端加密文件傳輸 |
| 🌍 | 原生多語言支持 (詳見 [i18n.md](../i18n.md)) |
| 🌙 | 現代的 Flutter UI，具有自適應頁面、動畫和自定義配色方案 |

---

## 🚀 構建

請參閱 [BUILD.md](../BUILD.md) 了解構建說明和各平台指南。

---

## 🏗️ 架構

```
FlCroc/
├── lib/               Flutter 應用 (Riverpod + Material 3)
├── go_bridge/         Go CGO 共享庫 (FFI 橋接)
├── submodules/croc/   內置 croc 源碼
├── assets/            應用圖標、國際化 JSON 語言包
├── (platform)/          Android、iOS、Linux、macOS、Windows、Web
└── .github/workflows/           CI/CD (build.yml)
```

---

## 🧰 技術棧

| 層級 | 技術 |
|-------|------------|
| UI | Flutter 3.44 · Material 3 |
| 狀態管理 | Riverpod · Freezed |
| 後端 | Go CGO FFI · croc 子模塊 |
| 國際化 | JSON 語言包 |
| CI/CD | GitHub Actions |

---

## 🌍 國際化

請參閱 [docs/i18n.md](../i18n.md) 了解各語言狀態和貢獻指南。

---

## 🙏 鳴謝

| 項目 | 說明 |
|---------|-------------|
| [croc](https://github.com/schollz/croc) | 後端文件傳輸引擎 |
| [Flutter](https://flutter.dev) | 跨平台 UI 框架 |
| [FlClash](https://github.com/chen08209/FlClash) | UI 設計靈感 |
| [croc-app](https://github.com/Dking08/croc-app) | 掃碼實現參考 |

---

## 📄 許可證

GPL3 © FlCroc Contributors
