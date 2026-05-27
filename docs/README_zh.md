# 🐊 FlCroc

<p align="center">
  <strong>基于 <a href="https://github.com/schollz/croc">croc</a> 的现代化跨平台文件传输 GUI 客户端</strong>
</p>

<p align="center">
  <a href="../README.md">📖 English Docs</a> &nbsp;|&nbsp;
  UI 设计灵感来自 <a href="https://github.com/chen08209/FlClash">FlClash</a>
</p>

---

## ✨ 特性

| | |
|---|---|
| 🐊 **内建 croc** | 拥有 [croc](https://github.com/schollz/croc) 的全部能力——加密传输、PAKE、中继、文本/文件、代码短语。详见 [croc README](../lib/croc/README.md)。 |
| 🎨 **现代化 UI** | Material 3 设计，浅色/深色/纯黑主题，响应式布局，拖拽操作，可折叠设置。 |
| 🖥️ **全平台** | Android · Windows · Linux · macOS，一套代码，原生性能。 |
| 🌍 **多语言** | 支持添加大部分语言的支持，通过 `lib/l10n/` 可扩展，请通过`pull-request`提交翻译。 |

## 🚀 快速开始

### 环境要求
- Flutter SDK ≥ 3.12
- Go ≥ 1.23

### 安装
```bash
git clone https://github.com/576576/FlCroc.git
cd FlCroc
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 运行
```bash
flutter run
```

### 构建

croc 源码*按原样*链接在 `lib/croc/`，通过Go bridge 编译为 CGO 共享库。

```bash
# Windows
cd go_bridge
$env:CGO_ENABLED="1"; $env:GOOS="windows"; go build -buildmode=c-shared -ldflags="-s -w" -o ../windows/runner/libcroc_bridge.dll .
cd ..; flutter build windows

# Android / Linux / macOS
flutter build apk
flutter build linux
flutter build macos
```

## 🏗️ 架构

```
lib/
├── main.dart              # 入口 (Riverpod)
├── application.dart       # MaterialApp + 主题 + 国际化
├── common/                # 工具类、常量、AppPrefs
├── enum/                  # 枚举
├── models/                # Freezed 数据模型
├── providers/             # Riverpod 状态管理
├── core/                  # Croc 后端 (Go FFI)
├── go_bridge/             # Go CGO 共享库
├── lib/croc/              # Vendored croc 源码
├── l10n/                  # 多语言 (en, zh)
├── pages/                 # 首页
├── views/                 # 功能视图 (发送、接收、历史、设置)
└── widgets/               # Material 3 组件
```

## 🧰 技术栈

| 组件 | 技术 |
|------|------|
| UI | Flutter 3.44 · Material 3 |
| 状态 | Riverpod · Freezed |
| 后端 | Go CGO FFI |
| 存储 | SharedPreferences |
| CI/CD | GitHub Actions |

## 📄 许可证

[GNU General Public License v3.0](../LICENSE)

