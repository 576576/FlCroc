# FlCroc

<p align="center">
  <strong>🐊 基于 <a href="https://github.com/schollz/croc">croc</a> 的跨平台文件传输 GUI 客户端，简单、安全、好用</strong>
</p>

<p align="center">
  <a href="../README.md">📖 English Docs</a> &nbsp;|&nbsp;
  UI 设计灵感来自 <a href="https://github.com/chen08209/FlClash">FlClash</a> 的 Material 3 设计。
</p>

## 特性

- **仪表盘** — 传输速度监控、总量统计、拖拽排序组件网格
- **发送** — 文件/文本发送，3 种短语模式（默认 / FlCroc 管理 / 自定义），二维码展示，拖拽添加文件，自动复制短语
- **接收** — 代码短语输入（含粘贴 + 扫码按钮），一键接收
- **历史记录** — 追踪所有传输记录，状态标签和统计
- **设置** — 3 种中继类型（默认 / 自定义 / 不使用），自定义中继支持地址/端口/密码（密码可显隐），主题切换（浅色/深色/纯黑），语言切换
- **安全** — 基于 croc PAKE 协议端到端加密（曲线: p256, 哈希: xxhash）
- **持久化** — 所有设置通过 SharedPreferences 自动保存
- **全平台** — Android、Windows、macOS、Linux

## 架构

```
lib/
├── main.dart              # 入口 (Riverpod ProviderScope)
├── application.dart       # MaterialApp + ThemeManager + i18n
├── controller.dart        # AppController 单例
├── common/                # 工具类、常量、AppPrefs
├── enum/                  # 枚举 (RelayType 等)
├── models/                # Freezed 数据模型
├── providers/             # Riverpod 状态管理
├── core/                  # 后端 (Go FFI 桥接)
├── go_bridge/             # Go CGO 共享库
├── lib/croc/              # Vendored croc 源码 (v10.4.4)
├── l10n/                  # 多语言 (en, zh)
├── pages/                 # HomePage (响应式导航)
├── views/                 # 功能视图
│   ├── dashboard/         # 仪表盘
│   ├── send/              # 发送页
│   ├── receive/           # 接收页
│   ├── history/           # 历史记录
│   └── settings/          # 设置页
└── widgets/               # 可复用 Material 3 组件
```

## 快速开始

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

croc 源码已 vendored 在 `lib/croc/`（v10.4.4）。Go bridge 在 `go_bridge/` 编译为 CGO 共享库，通过 `dart:ffi` 加载。

```bash
# Windows
cd go_bridge
$env:CGO_ENABLED="1"; $env:GOOS="windows"; go build -buildmode=c-shared -ldflags="-s -w" -o ../windows/runner/libcroc_bridge.dll .
cd ..; flutter build windows

# Android
flutter build apk

# Linux / macOS
flutter build linux
flutter build macos
```

## 技术栈

| 组件 | 技术 |
|------|------|
| 框架 | Flutter 3.44 · Dart |
| 状态管理 | Riverpod + Freezed |
| UI | Material 3 |
| 后端 | Go CGO FFI（c-shared）— 以库形式调用 croc |
| 存储 | SharedPreferences (AppPrefs) |
| 扫码 | mobile_scanner |
| 二维码 | qr_flutter |
| 文件选择 | file_picker |
| 拖拽 | desktop_drop |
| CI/CD | GitHub Actions (build + nightly) |

## 中继设置

| 类型 | 说明 |
|------|------|
| 默认中继 | 使用 croc 公共中继 `croc.schollz.com:9009` |
| 自定义中继 | 自填地址、端口、密码 |
| 不使用 | 仅本地网络（等同于 `croc --local`） |

## 多语言

| 语言 | 文件 | 状态 |
|------|------|------|
| English | `lib/l10n/intl/messages_en.dart` | ✅ |
| 简体中文 | `lib/l10n/intl/messages_zh.dart` | ✅ |

## 许可证

[GNU General Public License v3.0](../LICENSE)

## 致谢

- [FlClash](https://github.com/chen08209/FlClash) — UI 架构灵感来源
- [croc](https://github.com/schollz/croc) — 核心文件传输引擎

