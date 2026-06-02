# FlCroc

<p align="center">
  <img src="../assets/images/icon.png" alt="FlCroc" width="96" />
</p>

<p align="center">
  <strong>基于 <a href="https://github.com/schollz/croc">croc</a> 的现代化跨平台文件传输 GUI 客户端</strong><br>
  <em>在任何两台计算机之间安全、便捷地传输文件</em>
</p>

<p align="center">
  <a href="../README.md">📖 English Docs</a> &nbsp;|&nbsp;
  <a href="#-特性">特性</a> ·
  <a href="#-快速开始">快速开始</a> ·
  <a href="#-技术栈">技术栈</a>
</p>

<p align="center">
  <img alt="Platforms" src="https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS-blue" />
  <img alt="License" src="https://img.shields.io/github/license/576576/FlCroc?color=green" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter" />
  <img alt="croc" src="https://img.shields.io/badge/croc-v10.4.4-blue" />
  <img alt="version" src="https://img.shields.io/badge/version-1.0.1-informational" />
</p>

---

## ✨ 特性

| | |
|---|---|
| 🐊 **内建 croc** | 完整 [croc](https://github.com/schollz/croc) 能力 — 加密传输、PAKE、中继、文本/文件、代码短语。详见 [croc README](../submodules/croc/README.md)。 |
| 🎨 **现代化 UI** | Material 3 设计，浅色 / 深色 / 纯黑主题，响应式布局，可折叠设置。 |
| 🖥️ **全平台** | Android · Windows · Linux · macOS — 单套代码，原生性能。 |
| 🌍 **多语言** | English、中文 — 通过 `assets/bundles/` JSON 文件可扩展。 |

## 🚀 快速开始与构建

详见 [构建指南](../BUILD.md)（英文文档，无需本地化）。

---

## 🏗️ 架构

| 目录 | 描述 |
|------|------|
| `lib/` | Flutter 应用 (Riverpod + Material 3) |
| `go_bridge/` | Go CGO 共享库 (FFI 桥接) |
| `submodules/croc/` | Croc 子模块源码 |
| `assets/images/` | 应用图标 |
| `assets/bundles/` | 多语言 JSON |
| `android/` `ios/` `linux/` `macos/` `windows/` `web/` | 各平台目标 |
| `.github/workflows/` | CI/CD (build.yml) |

## 🧰 技术栈

| 层级 | 技术 |
|------|------|
| UI | Flutter 3.44 · Material 3 |
| 状态 | Riverpod · Freezed · Drift |
| 后端 | Go 1.25 CGO FFI · croc v10.4.4 |
| 国际化 | JSON bundles |
| CI/CD | GitHub Actions |

## 🌍 国际化 (I18n)

详见 [docs/i18n.md](../i18n.md)（语言状态与贡献指南，英文文档）。

## 📄 许可证

[GNU 通用公共许可证 v3.0](../LICENSE)
