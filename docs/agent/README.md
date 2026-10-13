# docs/agent —— 面向 Agent 与维护者的内部文档

`docs/` 根放给人看的：`BUILD.md`、`i18n.md`（CI 生成）、五个语言 `README.md`（CI 生成）。
本目录放给 Agent 和维护者看的工作文档。

两条约定：

- 本目录不参与 i18n 渲染，保留中文原文；CI 的 i18n job 只吃 `assets/` 下的子树。
- 两类文档都不触发构建：`release.yml` 的 `paths-ignore` 覆盖整个 `docs/**`。

## 跳转

- [croc v10 → v11 特性落地审计](croc-v11-feature-audit.md) —— 结论已落地，清单留档
- [上游 PR 草稿：`ProgressSnapshot()`](upstream-pr-lifecycle-accessor.md) —— 已在 fork 实现，未提 PR
- [Weblate 迁移操作手册](weblate-migration.md) —— 待执行
- [go_bridge 失效模式与改造方案](plan/go-bridge-stability.md) —— 进行中
- [croc fork 的分支模型与同步流程](plan/croc-fork-sync.md) —— 进行中

回到给人看的文档：[BUILD.md](../BUILD.md) · [i18n.md](../i18n.md)

## 索引

| 文件 | 用途 | 状态 |
|---|---|---|
| [`croc-v11-feature-audit.md`](croc-v11-feature-audit.md) | croc v10 → v11 特性落地审计 | 结论已落地，清单留档 |
| [`upstream-pr-lifecycle-accessor.md`](upstream-pr-lifecycle-accessor.md) | 投给上游的 PR 草稿：`ProgressSnapshot()` | 已在 fork 实现，未提 PR |
| [`weblate-migration.md`](weblate-migration.md) | 翻译流程迁到 Weblate 的操作手册 | 待执行 |
| [`plan/go-bridge-stability.md`](plan/go-bridge-stability.md) | go_bridge 失效模式与改造方案 | 进行中 |
| [`plan/croc-fork-sync.md`](plan/croc-fork-sync.md) | croc fork 的分支模型、补丁边界与同步流程 | 进行中 |

## croc 依赖的当前状态

`submodules/croc` 指向 fork **`576576/croc`** 的 `flcroc` 分支：跟上游最新，不锁版本。
`go_bridge/go.mod` 用 `replace` 指向它，fork 的 module path 仍是
`github.com/schollz/croc/v11`。

| tag | 补丁 |
|---|---|
| `v11.5.4-flcroc.1` | 进度计数器加锁 + `ProgressSnapshot()`（`src/croc/progress.go`） |
