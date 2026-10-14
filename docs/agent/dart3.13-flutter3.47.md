# Dart 3.13 / Flutter 3.47：现行约束与遗留项

> 迁移（Phase 0–2 + material_ui + 依赖收窄一轮）已执行完，方案与执行过程只在 git 历史里。
> 这里只留两类东西：**仍然约束本仓库的事实**，和**当时没做、现在还没做的事**。

---

## 现行约束

- **语言版本与 SDK 版本是两件事**：pubspec 的 `environment.sdk`（现为 `^3.13.0`）决定
  `dart format` 的排版结果与可用语法，SDK 版本（现为 3.13.4）只是工具链。本地 SDK 必须与
  CI 的 `FLUTTER_VERSION` 对齐，否则排版结果会漂。
- **语言版本 ≥3.13 时 `final` / `var` 只能用在主构造函数的声明参数上**，写在其他参数上是
  `extraneous_modifier` 编译错误。freezed 2.x / 3.x 的生成物恰好带 `final`，只有 4.x 不带，
  而 4.x 自身又要求 sdk ≥3.13 —— 升语言版本与升 freezed 必须同批完成。
- **Flutter 3.47 的平台底线**：iOS 15 / macOS 12；Android 矩阵 AGP 9.1.0 / KGP 2.4.0 /
  Gradle 9.3.1，targetSdk 走 `flutter.targetSdkVersion`。桌面端默认渲染器是 Impeller。
- **UI 只用 `material_ui` / `cupertino_ui`**（核心 SDK 里那份 11 月 Fall stable 废弃）。
  `CupertinoPageTransitionsBuilder` 已移进 `cupertino_ui`，两个包都要依赖。
  `MaterialUiCompatibilityBridge` 已删除 —— 判据是「谁往 widget 树里放旧 material 的 widget」，
  不是「谁 import 了旧 material」。
- **`build_runner` 停在 2.16.x 是解析上限**：2.17 要 `build >=5`，而 `json_serializable
  6.14.1`（6.x 最新）要 `build ^4.0.4`。
- 生成文件（`lib/l10n/*`、`*.g.dart`、`*.freezed.dart`）已入库且 CI 不重新生成，因此也在 lint
  范围内；动过 `sdk:` 或 freezed 之后必须重新生成，不能靠 CI 绕开。
- 本地 Windows 构建**不再需要** `CL=-utf-8`：`connectivity_plus` 已删，做过全量重编验证。
  再遇到 C4819 就加回去，注意 Git Bash 会把 `/utf-8` 转成路径，必须写 `-utf-8`。

## 还没做

| 项 | 说明 |
|---|---|
| `StateProvider` / `StateNotifierProvider` → `Notifier` | 22 + 3 处仍在 riverpod 的 legacy API 上（官方支持的过渡路径） |
| Primary constructors | 192 个类声明，纯书写形式变化 |
| Android 侧拖放 | 只做了 Windows，移动端目前靠选文件按钮 |
| 拖放与 QR 的真机验证 | 只有编译级保证与结构断言，需要人工拖一次、扫一次 |
| `flutter_localizations` 直接依赖 | `lib/` 与 `test/` 里没有任何地方 import 它（本地化委托来自 `material_ui`），可以直接删声明 |
| `fluttertoast` 的去留 | 它只为移动端的原生 toast 存在，桌面端走 `ScaffoldMessenger`；见 [fluttertoast fork 文档](plan/fluttertoast-fork-sync.md) §4 |
| `flutter_riverpod` 的 legacy material import | `lib/src/core.dart` 只 import、代码里零使用（换成 `flutter/widgets.dart` 实测能过）。现在不阻塞，但核心 SDK 去掉 material 后会编译失败 |
