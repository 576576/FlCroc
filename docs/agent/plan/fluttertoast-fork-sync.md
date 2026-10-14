# fluttertoast fork 的分支模型与同步流程

> 上游 `ponnamkarthik/FlutterToast` · fork `576576/flutter_toast`（本地 `D:/Github/flutter_toast`，
> remote：`origin` = fork，`upstream` = 上游）
> FlCroc 侧：`pubspec.yaml` 用 pub 的 **git 依赖**指向 fork 的 tag，见 §2

分支模型（`main` = 上游镜像，`flcroc` = 上游 + 补丁集，补丁 commit 前缀 `[flcroc]`，
tag 命名 `v<上游版本>-flcroc.<n>`）与 croc fork 完全一致，见
[croc-fork-sync.md §1](croc-fork-sync.md)。上游默认分支叫 **`master`**，镜像分支仍叫 `main`。

---

## 1. 已落地的补丁

| tag | 基底 | 补丁 |
|---|---|---|
| `v10.0.2-flcroc.1` | 上游 v10.0.2（`e8377b1`） | `lib/fluttertoast.dart` 的 import：`package:flutter/material.dart` → `package:material_ui/material_ui.dart`（`pubspec.yaml` 相应加依赖） |

补丁边界：

- 用到的 material API 只有 `Colors.black` / `Colors.white`（常量）与
  `Material(color: Colors.transparent, …)`（`FToast` 的 overlay 路径）。`MediaQuery` / `Overlay`
  这些都来自 `flutter/widgets.dart`，而 `material_ui` 会再导出它，所以是纯 import 交换。
- **不动 `environment` 的 SDK 约束。** material_ui 1.6.0 要求 `sdk ^3.13.0` / `flutter >=3.47.0`，
  但 pub 不校验"包自己声明的下限是否覆盖其依赖的下限"，保留上游的 `>=3.12.0` 补丁就只有两行。
  抬高它会让 `dart format` 按新语言版本重排整个包（`fluttertoast_web.dart` 会上榜），
  平白多出一批与补丁无关的改动。
- fork 的 `version` 仍是 `10.0.2`（与上游一致）。**`pubspec.lock` 不入库**（`.gitignore` 的
  `*.lock`），所以补丁的身份只在 tag 上 —— 光看 `10.0.2` 分不出是 pub.dev 的还是 fork 的。
- 不投上游。上游没有理由在自己还支持旧 Flutter 的时期依赖 material_ui。

## 2. FlCroc 侧为什么用 pub git 依赖，而不是像 croc 那样挂 submodule

Dart 这边不能照搬 croc 的做法：

- **仓库根的 `dart format .` 会走进 `submodules/`**（已实测）。`lint.yml` 的格式门禁是全仓扫描，
  而 `fluttertoast_web.dart` 在上游就没按当前 formatter 排过版 —— submodule 一进仓库树，
  一个我们没写过的文件就会让门禁变红。
- submodule 在 CI 里只由 `actions/checkout` 递归检出，**不会有 `.dart_tool/package_config.json`**；
  `dart format` 对同一个文件解析出的语言版本与本地不同，会出现本地绿、CI 红。
- pub 的 git 依赖不需要额外步骤，`ref` 本身就是那次解析的全部依据。

```yaml
  fluttertoast:
    git:
      url: https://github.com/576576/flutter_toast.git
      ref: v10.0.2-flcroc.1
```

**`ref` 必须是不可变的 tag，不能写分支。** `pubspec.lock` 被 `.gitignore` 忽略、不入库，
所以仓库里没有任何地方记录"上次 pub get 解到哪个 commit"；写 `ref: flcroc` 的话，
不同机器、不同时间的 `pub get` 可能拿到不同的补丁集。

本地迭代补丁时不要改 pub cache 里的副本，用 `pubspec_overrides.yaml`（不入库）指回
`D:/Github/flutter_toast`。

## 3. 同步 SOP

**节奏**：上游发新版后 3 天内；无新版时与 croc 一起月度巡检。

```bash
cd D:/Github/flutter_toast

# ① 看上游走了多远、有没有碰到补丁改过的文件
git fetch upstream --tags
git log --oneline flcroc..upstream/master -- lib pubspec.yaml

# ② 更新镜像分支（上游默认分支是 master）
git checkout main && git reset --hard upstream/master
git push --force-with-lease origin main

# ③ 补丁集变基到新基底，冲突处理同 croc
OLD_BASE=$(git merge-base main flcroc)
git checkout flcroc && git rebase --onto main $OLD_BASE flcroc

# ④ 验证
flutter pub get && dart analyze lib
dart format --output=none --set-exit-if-changed lib

# ⑤ 打 tag 并推
git tag -a v10.0.3-flcroc.1 -m "fluttertoast 10.0.3 + FlCroc patches"
git push --force-with-lease origin flcroc && git push origin v10.0.3-flcroc.1
```

```bash
# ⑥ 回 FlCroc 换 ref（pubspec.lock 不入库，不用管）
cd D:/Github/FlCroc
#   pubspec.yaml 的 ref: 改成新 tag
flutter pub get && git add pubspec.yaml
```

`remote.upstream.tagOpt=--no-tags` 已设置（上游 tag 会污染 `git describe`）。
注意 `flutter pub get` 也会顺带 `pub get` fork 里的 `example/`，会改到它的
`pubspec.lock` 与若干 `generated_*` 文件 —— 这些都不要提交。

## 4. 未决

1. `lib/fluttertoast.dart` 的 import 行是否会被上游改写（例如上游自己去迁 material_ui）。
   一行补丁，冲突概率低，但每轮次 rebase 仍要看一眼。
2. `FToast`（overlay 路径，唯一会实例化 `Material` 的地方）FlCroc 完全没用：App 里只用
   `Fluttertoast.showToast`，而它只在 Android/iOS 走原生 toast，桌面端走 `ScaffoldMessenger`。
   也就是说这个依赖只为移动端的 toast 存在。要不要连依赖一起去掉、移动端也走 `ScaffoldMessenger`，
   还没有结论。
