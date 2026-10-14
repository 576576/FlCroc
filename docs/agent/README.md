# docs/agent —— 面向 Agent 与维护者的内部文档

`docs/` 根放给人看的：`BUILD.md`、`i18n.md`（CI 生成）、五个语言 `README.md`（CI 生成）。
本目录放给 Agent 和维护者看的工作文档。

两条约定：

- 本目录不参与 i18n 渲染，保留中文原文；CI 的 i18n job 只吃 `assets/` 下的子树。
- 两类文档都不触发构建：`release.yml` 的 `paths-ignore` 覆盖整个 `docs/**`。

## 跳转

- [croc v10 → v11 特性落地审计](croc-v11-feature-audit.md) —— 结论已落地，清单留档
- [Dart 3.13 / Flutter 3.47：现行约束与遗留项](dart3.13-flutter3.47.md) —— 迁移已执行，只留约束与遗留
- [上游 PR 草稿：`ProgressSnapshot()`](upstream-pr-lifecycle-accessor.md) —— 已在 fork 实现，未提 PR
- [Weblate 迁移操作手册](weblate-migration.md) —— 待执行
- [go_bridge 失效模式与遗留项](plan/go-bridge-stability.md) —— A 档已落地，留清单与遗留
- [croc fork 的分支模型与同步流程](plan/croc-fork-sync.md) —— 进行中
- [fluttertoast fork 的分支模型与同步流程](plan/fluttertoast-fork-sync.md) —— 进行中

`plan/` 只放**还没落地**或**长期维护**的东西：改造方案与 fork 同步流程。执行完的方案不留档，
只把仍然有效的约束与遗留项整理成文档放进本目录。

> `.workbuddy/memory/` 是本机的 agent 记忆，被 `.gitignore` 忽略、不进仓库 ——
> 要留给维护者的知识必须写进 `docs/`。

回到给人看的文档：[BUILD.md](../BUILD.md) · [i18n.md](../i18n.md)

## 索引

| 文件 | 用途 | 状态 |
|---|---|---|
| [`croc-v11-feature-audit.md`](croc-v11-feature-audit.md) | croc v10 → v11 特性落地审计 | 结论已落地，清单留档 |
| [`dart3.13-flutter3.47.md`](dart3.13-flutter3.47.md) | 语言版本 / Flutter 版本的现行约束与遗留项 | 迁移已执行，留档 |
| [`upstream-pr-lifecycle-accessor.md`](upstream-pr-lifecycle-accessor.md) | 投给上游的 PR 草稿：`ProgressSnapshot()` | 已在 fork 实现，未提 PR |
| [`weblate-migration.md`](weblate-migration.md) | 翻译流程迁到 Weblate 的操作手册 | 待执行 |
| [`plan/go-bridge-stability.md`](plan/go-bridge-stability.md) | go_bridge 失效模式清单、遗留项与验证方法 | A 档已落地 |
| [`plan/croc-fork-sync.md`](plan/croc-fork-sync.md) | croc fork 的分支模型、补丁边界与同步流程 | 进行中 |
| [`plan/fluttertoast-fork-sync.md`](plan/fluttertoast-fork-sync.md) | fluttertoast fork 的分支模型与 pub git 依赖的接入方式 | 进行中 |

## 上游 fork 的当前状态

两个 fork 的分支模型一样（`main` = 上游镜像，`flcroc` = 上游 + 补丁集），**接入方式不同**：
Go 侧挂 submodule，Dart 侧走 pub 的 git 依赖（仓库根的 `dart format .` 会扫进 `submodules/`，
两者混用会把格式门禁弄红，理由见 [fluttertoast fork 文档](plan/fluttertoast-fork-sync.md) §2）。

### croc（Go）

`submodules/croc` 指向 fork **`576576/croc`** 的 `flcroc` 分支：跟上游最新，不锁版本。
`go_bridge/go.mod` 用 `replace` 指向它，fork 的 module path 仍是
`github.com/schollz/croc/v11`。

| tag | 补丁 |
|---|---|
| `v11.5.4-flcroc.1` | 进度计数器加锁 + `ProgressSnapshot()`（`src/croc/progress.go`） |
| `v11.5.4-flcroc.2` | 导出 `WebReceiveURL()`（`src/croc/web_receive_url.go`）：bridge 与 App 都不再自己拼 getcroc.com 的 URL |
| `v11.5.4-flcroc.3` | `Options.LibraryMode`：会 panic 的库路径改返回 error（`src/croc/croc.go`）；`crypt.New` / `NewArgon2` 不再 `log.Fatalf`（`src/crypt/crypt.go`） |

`flcroc` 每轮同步会 rebase 到新的上游基底，补丁 commit 的 hash 随之改变，旧 tag 留在
原基底上不动（tag 不可变）。**当下有效的补丁集以 `flcroc` 分支为准**，tag 只用来钉住某一轮
给消费方引用的快照。

### fluttertoast（Dart）

`pubspec.yaml` 的 git 依赖指向 fork **`576576/flutter_toast`** 的 tag `v10.0.2-flcroc.1`
（`pubspec.lock` 记 `resolved-ref`）。

| tag | 补丁 |
|---|---|
| `v10.0.2-flcroc.1` | `lib/fluttertoast.dart` 的 import 由 `package:flutter/material.dart` 换成 `material_ui` |
