# FlCroc

<p align="center">
  <strong>🐊 基于 <a href="https://github.com/schollz/croc">croc</a> 的跨平台文件传输 GUI 客户端，简单、安全、好用</strong>
</p>

<p align="center">
  <a href="../README.md">📖 English Docs</a> &nbsp;|&nbsp;
  界面设计灵感来自 <a href="https://github.com/chen08209/FlClash">FlClash</a> 的 Material 3 设计。
</p>

## 特性

- **仪表盘** — 传输速度监控、总量统计、快捷操作
- **发送文件** — 多文件选择、自动/自定义代码短语、二维码展示、文本发送
- **接收文件** — 输入代码短语或扫描二维码接收
- **历史记录** — 追踪所有发送和接收的传输记录
- **设置** — 中继服务器配置、主题定制、语言切换
- **全平台** — Android、Windows、macOS、Linux
- **端到端加密** — 基于 croc 的 PAKE 协议

## 架构

FlCroc 沿用了 FlClash 成熟的架构模式：

```
lib/
├── main.dart              # 入口 (Riverpod ProviderScope)
├── application.dart       # MaterialApp + ThemeManager
├── controller.dart        # AppController 单例
├── state.dart             # GlobalState 单例
├── common/                # 工具类、常量、扩展
├── enum/                  # 枚举定义
├── models/                # Freezed 数据模型
├── providers/             # Riverpod 状态管理
├── core/                  # 后端 (FFI + 进程)
├── manager/               # 状态管理器 (主题)
├── l10n/                  # 多语言 (en, zh_CN)
├── pages/                 # HomePage (响应式导航)
├── views/                 # 功能视图
│   ├── dashboard/         # 仪表盘 (SuperGrid 组件)
│   ├── send/              # 发送界面
│   ├── receive/           # 接收界面
│   ├── history/           # 历史记录
│   └── settings/          # 设置
├── widgets/               # 可复用组件
└── go_bridge/             # Go FFI 桥接
```

## 快速开始

### 环境要求
- Flutter SDK ^3.12.0
- Go 1.25+（必需 — croc 从源码编译）

### 安装依赖
```bash
flutter pub get
dart run build_runner build
```

### 从源码构建 croc（全平台）
```bash
# 克隆 croc 仓库
git clone --depth 1 --branch v10.4.4 https://github.com/schollz/croc.git /tmp/croc_src

# 桌面端：构建独立二进制
cd /tmp/croc_src
CGO_ENABLED=0 go build -ldflags="-s -w" -o croc .
cp croc linux/flutter/ephemeral/croc        # Linux
cp croc.exe windows/runner/croc.exe         # Windows (交叉编译 GOOS=windows)

# Android：构建 Go CGO 共享库（需要 Android NDK）
cd go_bridge
go mod edit -replace github.com/schollz/croc/v10=/tmp/croc_src
go mod tidy
CGO_ENABLED=1 GOOS=android GOARCH=arm64 \
  CC=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang \
  go build -buildmode=c-shared -o ../android/app/src/main/jniLibs/arm64-v8a/libcroc_bridge.so .
```

### 运行
```bash
flutter run
```

### 构建
```bash
# Android
flutter build apk

# Windows
flutter build windows

# Linux
flutter build linux

# macOS
flutter build macos
```

## 技术栈

| 组件 | 技术 |
|------|------|
| 框架 | Flutter (Dart) |
| 状态管理 | Riverpod + Freezed |
| UI | Material 3 |
| 后端 | Go FFI (c-shared) + 进程通信 |
| 存储 | SharedPreferences |
| 扫码 | mobile_scanner |
| 二维码 | qr_flutter |

## CI/CD

推送代码到 GitHub 后，Actions 自动构建全平台：

- **Android ARM64** — Go 交叉编译 → APK
- **Windows AMD64** — 内嵌 croc.exe → zip
- **Linux AMD64** — 内嵌 croc → .deb

详见 `.github/workflows/build.yml`。

## 后端架构

FlCroc 采用双轨后端架构，确保在所有平台上都能运行：

```
CoreController.init()
  ├─ 优先: CoreLib (Go FFI 共享库)
  │    └─ go_bridge/main.go → CGO → libcroc_bridge.so/.dll/.dylib
  │    └─ 用于 Android（必须）+ 桌面（可选优化）
  │
  └─ 回退: CoreService (内嵌二进制)
       └─ 自动搜索: app 目录 → lib/ → data/ → PATH
       └─ 用于桌面开发 + 生产
```

- **Android**: croc 通过 Go CGO 交叉编译为 `libcroc_bridge.so`，放在 `jniLibs/arm64-v8a/`，运行时通过 `dart:ffi` 调用
- **桌面端**: 通过 `setup_croc.ps1` / `setup_croc.sh` 下载官方 croc 二进制到 app 目录，CoreService 自动发现并调用

## 多语言

支持以下语言，欢迎贡献更多翻译：

| 语言 | 文件 | 状态 |
|------|------|------|
| English | `lib/l10n/intl/messages_en.dart` | ✅ 完整 |
| 简体中文 | `lib/l10n/intl/messages_zh.dart` | ✅ 完整 |

添加新语言只需：复制 `messages_en.dart` → 翻译 → 在 `app_localizations.dart` 的 `_lookupMap` 中注册。

## 许可证

[GNU General Public License v3.0](../LICENSE)

## 致谢

- [FlClash](https://github.com/chen08209/FlClash) — UI 架构灵感来源
- [croc](https://github.com/schollz/croc) — 核心文件传输引擎
