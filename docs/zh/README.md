<p align="center">
  <img src="../../assets/images/icon.png" width="64" alt="FlCroc">
</p>

<h1 align="center">FlCroc</h1>

<p align="center">
中文 (简体) &nbsp;|&nbsp; <a href="../zh-Hant/README.md">中文 (繁體)</a> &nbsp;|&nbsp; <a href="../ja/README.md">日本語</a> &nbsp;|&nbsp; <a href="../fr/README.md">Français</a> &nbsp;|&nbsp; <a href="../../README.md">English</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux-blue" alt="Platform">
  <img src="https://img.shields.io/badge/license-GPL v3-green" alt="License">
  <img alt="version" src="https://img.shields.io/badge/version-1.2.2-informational" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44.1-02569B?logo=flutter" />
  <img alt="croc" src="https://img.shields.io/badge/croc-10.4.4-blue" />
</p>

<em>Croc的Flutter图形界面 — 轻松安全地在计算机之间传输文件</em>

---

## ✨ 功能特性

| | 功能特性 |
|---|-----|
| 🖥️ | 跨平台 (Windows、Linux、Android) |
| 🔒 | 通过 croc 实现端到端加密文件传输 |
| 🌍 | 原生多语言支持 (详见 [i18n.md](../i18n.md)) |
| 🌙 | 现代的 Flutter UI，具有自适应页面、动画和自定义配色方案 |

---

## 🚀 构建

请参阅 [BUILD.md](../BUILD.md) 了解构建说明和各平台指南。

---

## 🏗️ 架构

```
FlCroc/
├── lib/               Flutter 应用 (Riverpod + Material 3)
├── go_bridge/         Go CGO 共享库 (FFI 桥接)
├── submodules/croc/   内置 croc 源码
├── assets/            应用图标、国际化 JSON 语言包
├── (platform)/          Android、iOS、Linux、macOS、Windows、Web
└── .github/workflows/           CI/CD (build.yml)
```

---

## 🧰 技术栈

| 层级 | 技术 |
|-------|------------|
| UI | Flutter 3.44 · Material 3 |
| 状态管理 | Riverpod · Freezed |
| 后端 | Go CGO FFI · croc 子模块 |
| 国际化 | JSON 语言包 |
| CI/CD | GitHub Actions |

---

## 🌍 国际化

请参阅 [docs/i18n.md](../i18n.md) 了解各语言状态和贡献指南。

---

## 🙏 鸣谢

| 项目 | 说明 |
|---------|-------------|
| [croc](https://github.com/schollz/croc) | 后端文件传输引擎 |
| [Flutter](https://flutter.dev) | 跨平台 UI 框架 |
| [FlClash](https://github.com/chen08209/FlClash) | UI 设计灵感 |
| [croc-app](https://github.com/Dking08/croc-app) | 扫码实现参考 |

---

## 📄 许可证

GPL3 © FlCroc Contributors
