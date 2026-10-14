# Dart 3.13 / Flutter 3.47 迁移方案

> 状态：**已执行**（Phase 0–2 + material_ui）。落地记录、决策与遗留见 §7 / §8；
> 上半部分保留原始设计，作为「当时为什么这么切」的依据。

## 1. 版本矩阵（迁移前）

| 处 | 版本 | 说明 |
|---|---|---|
| CI `FLUTTER_VERSION` | 3.47.5 (Dart 3.13.4) | `lint.yml` / `release.yml` / `build.yml` 三处同名 env |
| 本地 SDK | 3.47.5 (Dart 3.13.4) | Flutter SDK 是 git 仓库，`git checkout 3.47.5`（detached） |
| pubspec 语言版本 | `sdk: ^3.12.0` | **关键：语言版本仍停在 3.12** |
| pubspec `version` | `1.2.4+108` | |
| CI `GO_VERSION` | 1.27.1 | 本地已下 `go1.27.1.windows-amd64.msi`（SHA256 与官方一致），待安装 |
| Android | AGP 9.0.1 / KGP 2.3.20 / Gradle 9.1.0 / compileSdk 36 / targetSdk **34** | 正好等于 3.47 的 warn 线 |
| iOS / macOS 部署目标 | iOS 13.0 / macOS 10.15 | 3.47 要求 iOS 15 / macOS 12 |

**已跑在 3.13.4 的 SDK 上，但语言版本仍是 3.12** —— 这不是笔误，是两件互相独立的事，见 §2。

依赖现状 → 可用最新（pub.dev 实测）：

| 包 | 现在 | 最新 | 门槛 |
|---|---|---|---|
| `freezed` | 2.5.8 | **4.0.2** | 4.x **要求 sdk ≥3.13.0** |
| `freezed_annotation` | 2.4.4 | 3.1.0 | `>=3.0.0` |
| `build_runner` | `>=2.4.14 <3.0.0` | 2.16.2 | `^3.11.0` |
| `json_serializable` | `>=6.9.4 <7.0.0` | 6.14.1 | `^3.9.0` |
| `flutter_lints` | 6.0.0 | 6.0.0（无新版） | 3.13 的新 lint 规则不在其中，要显式开 |
| `flutter_riverpod` | 2.6.1 | 3.4.3（大版本） | `^3.12.0` |
| `drift` | 2.25.1 | 2.35.2 | `>=3.10.0` |

## 2. 先说结论：这是两条独立的轨道

| | 轨道 A：Flutter 3.44 → 3.47.5 | 轨道 B：语言版本 3.12 → 3.13 |
|---|---|---|
| 动什么 | 平台脚手架、渲染器、本地化委托、Android 依赖矩阵 | pubspec `sdk:`、freezed 4、生成物、格式化结果 |
| 能不能单独做 | 能 | 能 |
| 风险 | 中（Impeller 默认换渲染器、macOS/iOS 最低版本） | 高（生成物必须原子重生成，diff 大） |
| 谁阻塞谁 | 不阻塞 B | 不阻塞 A |

**不要合成一次提交。** 轨道 A 出问题要能单独回滚，轨道 B 的 diff（4 个 `*.freezed.dart` 全部重写）会淹没 A 的脚手架改动，bisect 会失效。

## 3. 轨道 B 的阻塞链条（必须先解决）

```
pubspec sdk: ^3.13.0
      │  语言版本 3.13 起，非声明参数上的 final / var 非法（extraneous_modifier）
      ▼
入库的 lib/models/*.freezed.dart 解析失败
      │  freezed 4.0.0 才不再生成 final 参数；3.2.x 不会，2.5.8 更不会
      ▼
必须升 freezed 到 4.0.2
      │  而 freezed 4.0.x 自己的 environment 是 sdk: >=3.13.0
      ▼
只能和 sdk 约束一起升 —— 两者必须同批次原子完成
```

三个可以直接引用的硬事实：

- `dart format` 拿不到 `package_config.json` 时按 SDK 默认语言版本（3.13）排版 —— 这正是
  CI fmt job 之前失败的原因（`82 files (5 changed)` + 4 个 `*.freezed.dart` 解析失败），
  已在 `7b1c26f` 用「fmt job 先 `flutter pub get`」修掉。**同一个机制意味着：语言版本一旦
  真升到 3.13，本地也会开始出现那 5 个文件的重排**（`navigator.dart`、`prefs.dart`、
  `home.dart`、`list.dart`、`dashboard_layout_test.dart`）。
- `dart fix` 能自动处理手写代码里的 `final`/`var` 参数（`avoid_final_parameters`）。
  **实测手写代码零命中**，要改的全是生成物。
- 3.13 另有一处 **type promotion breaking change**（修不健全行为），影响面未知，
  必须靠 `flutter analyze` + `flutter test` 实测，不能靠读文档判断。

## 4. 核心特性清单

### 4.1 Dart 3.13 侧

| 特性 | 语言版本门槛 | 本仓库落点 | 建议 |
|---|---|---|---|
| **Primary constructors**（稳定） | 3.13 | 192 个类声明 | 分批采纳，见 §5 Phase 3 |
| 私有命名参数 | 3.12（已可用） | 未用 | 顺手可采纳 |
| `List.unmodifiableOf` / `Map.unmodifiableOf` | 3.13 | `lib/common/print.dart:11` | 一到就换（更强静态类型） |
| `Future.pause` | 3.13 | `lib/core/lib_native.dart:266,432`、`lib/pages/home.dart:46,58,94`、`quick_transfer.dart` 多处 | **只换无回调的纯延时**；带回调的仍是 `Future.delayed` |
| `int.trailingZeroBitCount` / `oneBitCount` | 3.13 | 无 | 不适用 |
| `Isolate` 同步 API（`runSync` / `create` / `pinToCurrentThread` …） | 3.13 | 无（跨进程走 FFI 到 Go） | 不适用 |
| `dart:io` 微秒时间戳 / `NetworkInterface.addresses` 返回 `List<InterfaceAddress>` / `InternetAddress.lookup` 收紧 | 3.13 | 仓库未用这些 API | 不适用，但依赖包可能受影响 |
| 新 lint（`no_raw_types` / `no_dynamic_casts` 取代 strict-* 选项；7 条 primary constructor 相关） | — | 现在都没开 | 按需显式开，`flutter_lints` 6.0.0 不含 |

主构造函数在本仓库最大的收益点是 **Widget 构造函数**：

```dart
// 现在（46 个文件 import material.dart，大量这种样板）
class MyCard extends StatelessWidget {
  const MyCard({super.key, required this.title});
  final String title;
}

// 3.13
class MyCard(super.key, final String title) extends StatelessWidget;
```

约束要知道的几条：`const` 主构造函数可以写 `class const X(final int a)`，但**不能有函数体块**；
声明的参数不能 `late` / `external`；不能既在字段声明处初始化又在初始化列表初始化；
类名/方法名与参数名冲突是编译错误；`this` 块不能 `async`。

好处是纯简洁性，**没有新语义**，所以可以慢慢来；坏处是它会跟 `dart format` 的新排版叠在一起，
建议排在轨道 B 之后再单独做。

### 4.2 Flutter 3.47 侧

| 特性 / 变更 | 类型 | 本仓库落点 | 建议 |
|---|---|---|---|
| **`material_ui` / `cupertino_ui` 独立包到 1.0** | 采纳（**有时限**） | 46 个文件 import material/cupertino；`lib/application.dart:118-122` 的本地化委托 | `dart fix --apply --code=migrate_design_widgets`；核心 SDK 内的副本**计划在 11 月 Fall stable 废弃** |
| 本地化解耦 | 必随上一条 | `GlobalMaterialLocalizations.delegate` → `.delegates` | 迁移后一并改 |
| **Impeller 成为桌面默认渲染器**（macOS/Windows/Linux） | 风险 | 自绘标题栏（`lib/widgets/window_title_bar.dart` + `window_manager`） | 必须做视觉回归；回退开关只在 3 个平台文件里各一处 |
| 平台最低版本：iOS 13→**15**，macOS 10.15→**12** | 必改 | `ios/Runner.xcodeproj/project.pbxproj`、`macos/Runner.xcodeproj/project.pbxproj` | 见 §5 Phase 1 |
| Android 验证矩阵：Java 17 / KGP **2.4.0** / AGP **9.1.0** / Gradle **9.3.1**；SDK 默认 targetSdk 36 | 必改 | `android/settings.gradle.kts`、`gradle-wrapper.properties`、`app/build.gradle.kts` | 现在三项都正好卡在 warn 线，targetSdk 还是 34 |
| UIScene 生命周期（Xcode 27 SDK 强制） | 已满足？ | `ios/Runner/SceneDelegate.swift` **已存在** | 需在 Xcode 27 下实测确认 |
| 三处 breaking change：OpenGLES render-to-texture 改 top-down、iOS/Android semantics `header`/`headingLevel` 行为、**移除 `describeEnum`** | 必查 | `describeEnum` 仓库未使用 ✓ | 前两条按平台实测 |
| Widget Previews 转稳定 | 可选 | 本地 UI 迭代 | 值得开，`.widget_preview/` 有本地缓存 |
| 桌面 flavors（Windows/Linux） | 可选 | 当前不用 flavor | 暂不 |
| 多窗口：popup windows、`windowHandle`、sized-to-content；窗口化 API 改名（`preferredSize`→`size`、`preferredConstraints`→`constraints`，移除 `decorated`、`EnableTransparentWindowBackground`） | 观察 | 窗口用第三方 `window_manager`，**未用这些 API** ✓ | 改名不直接影响；但 `window_manager` 需实测 3.47 兼容 |
| Intel Mac 淘汰、SwiftPM 推进（前 100 个 iOS 插件已迁 92 个）、CocoaPods 进入维护模式 | 观察 | CI 的 macOS 构建已是 arm64 | 后续评估开 SwiftPM |

## 5. 分阶段方案

### Phase 0：预检（无行为变化，可随时做）

- `analysis_options.yaml` 显式开 `avoid_final_parameters` + `var_with_no_type_annotation`
  —— 这两个 lint 在 3.12 就能开，专门用来**提前**扫出 3.13 会报 `extraneous_modifier`
  的写法。当前手写代码零命中（已实测），开起来是防回归。
- `android/app/build.gradle.kts` 的 `targetSdk = 34` 换成 `flutter.targetSdkVersion`，
  以后跟 SDK 默认值走，不再手动落后。
- 验收：`dart format` / `flutter analyze` / `flutter test` / `go test -race` 四项全绿（现状即全绿）。

### Phase 1：轨道 A —— Flutter 3.47 脚手架与平台（独立一个 PR）

1. macOS 部署目标 `10.15` → `12.0`（`macos/Runner.xcodeproj/project.pbxproj` 三处）。
2. iOS 部署目标 `13.0` → `15.0`（`ios/Runner.xcodeproj/project.pbxproj` 三处）。
3. Android：AGP `9.0.1` → `9.1.0`、KGP `2.3.20` → `2.4.0`、Gradle `9.1.0` → `9.3.1`。
4. Impeller 回归：Windows / Linux / macOS 三端跑一遍，重点看自绘标题栏（DWM frame、
   圆角、拖拽区）、字体渲染（3.47 桌面改用 SDF）；有阻塞再按平台回退并单独立 issue。
5. `describeEnum` 已确认未使用；semantics 与 OpenGLES 两条 breaking change 按平台实测。
6. **语言版本保持在 3.12**：这一步不该出现任何 Dart 语言层面的改动。
7. 回滚：整步只碰平台配置文件，`git revert` 即可。

### Phase 2：轨道 B —— 语言版本 3.13 + freezed 4（原子一个 commit）

顺序不能变：

1. `pubspec.yaml`：`sdk: ^3.13.0`；`freezed: ^4.0.2`、`freezed_annotation: ^3.1.0`；
   `build_runner` 抬到 ≥2.16.2、`json_serializable` 抬到 ≥6.14.1。
2. `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs`，
   重新生成 4 个 `*.freezed.dart` + `*.g.dart`。
3. `dart fix --apply` 处理 `final`/`var` 参数与其它 3.13 迁移项。
4. `dart format .` —— **预期会重排至少那 5 个文件**（语言版本 3.13 的新排版规则）。
5. `flutter analyze` / `flutter test`：重点看 type promotion 那条 breaking change 有没有
   浮出新错误。
6. 可选：把 `List.unmodifiable` 换 `unmodifiableOf`、无回调的 `Future.delayed` 换
   `Future.pause`（都是本阶段的顺手项，不另开阶段）。
7. 回滚：本阶段必须落在一个 commit 里（pubspec + lock + 生成物一起），
   单独回滚不会留下"语言版本升了但生成物没升"的中间态。

**freezed 2 → 4 跨了两个大版本，但本仓库已经符合 3.x 的形状**：模型都是
`abstract class X with _$X`（3.x 要求的 `abstract`/`sealed` 已满足），且**没有用**
`when` / `map`（3.0 已移除）和 `@unfreezed`（4.0 不允许其定义不可变字段）。要改的就是生成物本身。

### Phase 3：可选采纳（各自独立）

| 项 | 价值 | 备注 |
|---|---|---|
| `material_ui` / `cupertino_ui` | 高，**有时限** | 核心 SDK 副本 11 月 Fall stable 起废弃；`MaterialUiCompatibilityBridge` 可用于依赖未迁完时过渡；迁移后本地化改 `GlobalMaterialLocalizations.delegates` |
| Primary constructors | 中 | 192 个类声明，收益主要在 Widget 构造函数；纯书写形式变化，可分文件慢慢推 |
| Widget Previews | 中 | UI 迭代提速 |
| `flutter_riverpod` 2 → 3 | 中 | 大版本，参考现有 4 个 model provider 的用法单独评估 |
| `drift` 2.25 → 2.35 | 低-中 | 跟着 SDK 走，单独评估 |
| SwiftPM（iOS/macOS） | 中 | CocoaPods 维护模式；前 100 个 iOS 插件已迁 92 个 |

## 6. 验收清单

| 项 | 手段 | 通过标准 |
|---|---|---|
| 四项门禁 | `dart format --set-exit-if-changed` / `flutter analyze` / `flutter test` / `go test -race` | 全绿（本地 SDK 必须与 CI 的 3.47.5 对齐，否则排版结果会漂） |
| 生成物幂等 | 重新跑一次 `build_runner build` | 无 diff |
| 构建 | CI 的 `build-windows` / `build-linux` / `build-linux-arm64` / `build-android` / `build-macos` | 五个全过 |
| 传输回归 | 本地中继（见 `go-bridge-stability.md` §6），小文件 + 大文件 + 文本各一遍 | 无挂起、无闪退、进度正确 |
| 桌面渲染 | Windows / Linux / macOS 各跑一次，看标题栏与字体 | 无错位、无锯齿回退 |
| iOS 生命周期 | Xcode 27 SDK 构建并启动 | 能启动（UIScene 已就绪） |

## 7. 决策记录

| 问题 | 结论 |
|---|---|
| `material_ui` / `cupertino_ui` | Phase 2 之后顺带迁，独立一个 commit |
| Phase 2 现在做 | 做 |
| `flutter_riverpod` 3 / `drift` 2.35 | 都纳入 |
| 桌面窗口 | 不再用第三方 `window_manager`。官方窗口化 API 在 3.47.5 是实验特性、只有 master 通道可用，且不提供无边框 / 拖拽 / 置顶 —— 改为回归系统原生标题栏 |
| 原生标题栏暗色模式 | 跟随系统设置（还原 3.47 模板的 `UpdateTheme`）；不保留窗口最小尺寸 400×500 |

## 8. 执行记录

本地 SDK 已与 CI 对齐（Flutter 3.47.5 / Dart 3.13.4，`git checkout 3.47.5` + `flutter --version`）。

| 阶段 | commit | 验证 |
|---|---|---|
| 桌面窗口去第三方 | `f5f0b54` | Windows 调试构建通过 |
| Phase 0：lint 预检 + targetSdk | `e2ddf58` | analyze 0 |
| Phase 1：平台底线 + Android 矩阵 | `7a04256` | 仅配置改动，iOS / macOS 未本地构建 |
| Phase 2：语言版本 3.13 + freezed 4 | `74be190` | analyze 0 / test 32 / format 重排 5 个文件 |
| riverpod 3 | `18729ba` | analyze 0 / test 32 |
| material_ui / cupertino_ui | `a18d951` | analyze 0 / test 32 |
| drift 2.35 | `2ba7152` | 仅约束改动 |

落地要点：

- **freezed 4 的产出形态变了**：不再是 `const factory _X({final ...}) = _$XImpl`，而是普通
  `const _X({...})` 加私有字段；公共 API（`X(...)` / `copyWith` / `fromJson`）不变。
- **`dart format` 重排的 5 个文件与之前 CI fmt job 报的完全一致** —— 反向印证那次失败是
  语言版本差异（3.12 vs 3.13），不是 SDK 版本差异。
- **material_ui 当时还需要兼容桥**：`super_sliver_list`、`qr_flutter`、`fluttertoast`、
  `desktop_drop`、`defer_pointer` 都还在 import 旧的核心 material。桥放在
  `lib/application.dart` 的 `MaterialApp.builder`，它自身已被标记废弃。前四个在 §9 清掉，
  最后两个在 §10 清掉，桥随之删除。
- **`CupertinoPageTransitionsBuilder` 在 3.47 从 material 移进了 cupertino_ui**，
  所以两个包都要依赖。
- `lib/l10n/app_localizations.dart` 被迁移 fix 改了一行 import（生成物已入库、CI 不重新
  生成）；将来手动跑 `flutter gen-l10n` 时注意这一行可能被写回旧 import。
- ~~本地跑 Windows 构建需要 `CL=-utf-8`~~：`connectivity_plus` 已删，做全量重编验证过，
  不再需要。

### 遗留（本轮未做）

| 项 | 说明 |
|---|---|
| `StateProvider` / `StateNotifierProvider` → `Notifier` | 22 + 3 处仍在 legacy API 上（官方支持的过渡路径） |
| ~~移除 `MaterialUiCompatibilityBridge`~~ | 已完成，见 §10 |
| ~~移除 drift 三件套~~ | 已完成，见 §9 |
| Primary constructors | 192 个类声明，纯书写形式变化 |

## 9. 依赖清理与两个第三方依赖的自研替换

这一轮把依赖面收干净：删掉声明了却没用的包，去掉两个第三方依赖并自己实现（QR、桌面拖放），
其余升到当前可用的最高版本。

| 动作 | commit | 验证 |
|---|---|---|
| croc fork `v11.5.4-flcroc.2` + bridge 的 `CrocQRCode` / `CrocWebReceiveURL` | `d1574ba` | `go test -race`（含矩阵结构断言） |
| QR 渲染、收码归一化、Windows 自研拖放、删依赖与升级 | `d6062e8` | analyze 0 / test 41 / `flutter build windows` 通过（`/W4 /WX`） |

落地要点：

- **`qr_flutter` → Go 侧出矩阵**：`CrocQRCode` 用 croc 已有的 `skip2/go-qrcode`，回一个
  `{"size","modules"}`，Dart 只负责 `CustomPaint`。矩阵**含 4 模块静区**（`go-qrcode` 的
  `quietZoneSize`），所以 Dart 不再自己加边距。QR 内容改成 `croc --qr` 编码的网页接收 URL。
- **网页 URL 由 croc 提供**：`WebReceiveURL()` 是 fork 上的新补丁（新文件，零 rebase 风险），
  bridge 与 Dart 都不再自己拼 `https://getcroc.com/?code=…`。
- **收码入口都过 `normalizeShareCode`**：发送页/接收页的粘贴与扫码、仪表盘快捷卡片。扫码得到
  的是 URL，直接交给 croc 会去找一个"码就是这串 URL"的对端。
- **`desktop_drop` → 自研 Windows 拖放**：`IDropTarget` + `RegisterDragDrop` 注册在 Flutter
  视图的 HWND 上，坐标按物理像素上报（Dart 除 `devicePixelRatio`），命中判定留在 Dart ——
  原生目标覆盖整个视图，而一屏上可能有多个投放区。Linux/macOS 没有原生投放区，回退到选文件
  按钮。`main.cpp` 需要 `OleInitialize`（只有 `CoInitializeEx` 时 `RegisterDragDrop` 会失败）。
- **file_picker 13 的两个破坏性变更**：`FilePicker.platform.*` → 静态方法；`PlatformFile`
  变成不可构造、不可外部实现的 `abstract base class`，`size` 换成 `lengthSync()`。所以选中
  文件的状态从 `List<PlatformFile>` 换成已有的 `FileItem`（name/path/size），转换集中在
  `lib/common/file.dart` 的 `toFileItems` / `fileItemForPath`。
- **`build_runner` 停在 2.16.x 是解析上限**：2.17 要求 `build >=5`，而 `json_serializable
  6.14.1`（6.x 最新）要 `build ^4.0.4`。

### 遗留（§9 之后）

| 项 | 说明 |
|---|---|
| Android 侧无拖放 | 本轮只做了 Windows；移动端本来就是选文件 |
| 拖放与 QR 的真机验证 | 只有编译级保证与结构断言，需要人工拖一次、扫一次 |

## 10. fluttertoast 换 fork、兼容桥删除

| 动作 | commit | 验证 |
|---|---|---|
| fluttertoast fork `v10.0.2-flcroc.1`（import 换 material_ui）+ pubspec 改 git 依赖 | `f23f464` | analyze 0 / test 41 / build windows 通过 |
| 删除 `MaterialUiCompatibilityBridge` | `2d4a60e` | analyze 0 / test 41 / build windows 通过 |

fork 侧的分支模型、补丁内容与 FlCroc 侧的接入方式见
[fluttertoast fork 的分支模型与同步流程](fluttertoast-fork-sync.md)。

**兼容桥为什么现在能删。** 桥做的事是"把 material_ui 的 ThemeData 映射成 legacy ThemeData，
让树里还在用旧 material 的 widget 取得到"。所以判据不是"谁 import 了旧 material"，而是
"谁会真的往 widget 树里放旧 material 的 widget"。逐包扫过锁文件里全部 138 个包：

| 包 | 旧 material / cupertino 的实际用法 | 需要桥吗 |
|---|---|---|
| `fluttertoast` | `Colors.black` / `Colors.white` 常量 + `FToast` overlay 里的 `Material(...)` | 补丁后不需要。而且那个 `Material` 只在 `FToast` 路径上，App 用的是 `Fluttertoast.showToast`（原生 toast），根本没走到 |
| `flutter_riverpod` 3.4.3 | `lib/src/core.dart` 只 import，**非注释代码里一个 material API 都没用**（`MaterialApp` / `Scaffold` 只出现在 doc 注释里） | 不需要。已实测：把该 import 换成 `flutter/widgets.dart` 后 analyze + test 全过 |
| `url_launcher_web` 2.4.3 | 同上，且是 web 平台实现 —— 仓库没有 `web/` 目标 | 不需要 |
| `leak_tracker_flutter_testing` 3.0.10 | `flutter_test` 的测试基建 | 不需要，不进 App 树 |
| `material_ui` / `cupertino_ui` | 各自的 `migration_utility.dart` —— 就是桥本身 | —— |

`material_ui` 只再导出 `flutter/widgets.dart`，不存在"某个包再导出旧 material"的间接路径。
删桥的失败模式本身也是良性的：没有 legacy Theme 祖先时 `legacy.Theme.of` 回落默认主题而不是
抛异常，真正需要桥的是"树里有 legacy widget 且要求主题一致"这种情形。

**还没动的两处**（都还没结论）：

- `flutter_localizations` 在 `pubspec.yaml` 里是直接依赖，但 `lib/` 与 `test/` 里没有任何地方
  import 它 —— 本地化委托来自 `material_ui`（它自己依赖 flutter_localizations）。
- `fluttertoast` 只为移动端的原生 toast 存在（桌面端走 `ScaffoldMessenger`），`FToast` 没用过。

