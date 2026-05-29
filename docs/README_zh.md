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
  <a href="#-构建">构建</a> ·
  <a href="#-架构">架构</a>
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

## 🚀 快速开始

### 环境要求

| 工具 | 版本 |
|------|------|
| Flutter SDK | ≥ 3.12 |
| Go | ≥ 1.25 |

### 安装

```bash
git clone --recurse-submodules https://github.com/576576/FlCroc.git
cd FlCroc
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 运行

```bash
flutter run
```

## 🔨 构建

Go 桥接位于 `go_bridge/`，编译为 CGO 共享库（`.so` / `.dll` / `.dylib`），通过 `dart:ffi` 加载。croc 源码位于 `submodules/croc/`。

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

> ℹ️ **croc 已完整内置。** Go FFI 桥接直接调用 croc 内部包 — 无需 CLI 子进程。共享库会打包到每个发布产物中。

## 🏗️ 架构

```
fl_croc/
├── lib/                      # Flutter 应用 (Riverpod + Material 3)
├── go_bridge/                # Go CGO 共享库 (FFI 桥接)
├── submodules/croc/          # 子模块 Croc
├── assets/
│   ├── images/icon.png       # 应用图标
│   └── bundles/              # 多语言 JSON 
├── android/ ios/ linux/ macos/ windows/ web/
└── .github/workflows/        # CI/CD (build.yml)
```

## 🧰 技术栈

| 层级 | 技术 |
|------|------|
| UI | Flutter 3.44 · Material 3 |
| 状态 | Riverpod · Freezed · Drift |
| 后端 | Go 1.25 CGO FFI · croc v10.4.4 |
| 国际化 | JSON bundles |
| CI/CD | GitHub Actions |

## 🌍 国际化贡献

翻译文件以 JSON 格式存放在 `assets/bundles/` 中。添加新语言的方法：

1. 复制 `assets/bundles/en.json` 为 `assets/bundles/{代码}.json`（如 `ja.json`、`ko.json`）
2. 翻译所有值（**保留键名不变**）
3. 在 `lib/l10n/app_localizations.dart` → `supportedLocales` 中注册语言
4. 提交 Pull Request

> 💡 回退语言为英语。缺失的键会显示键名本身。

## 📄 许可证

[GNU 通用公共许可证 v3.0](../LICENSE)
