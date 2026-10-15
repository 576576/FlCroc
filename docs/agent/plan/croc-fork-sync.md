# croc fork 的分支模型与同步流程

> 上游 `schollz/croc` · fork `576576/croc`（本地 `D:/Github/croc`，remote：
> `origin` = fork，`upstream` = 上游）
> FlCroc 侧：`submodules/croc` 指向 fork 的 `flcroc` 分支，
> `go_bridge/go.mod` 用 `replace github.com/schollz/croc/v11 => ../submodules/croc`

---

## 0. 三条硬约束

1. **不改 module path。** fork 的 `go.mod` 仍是 `module github.com/schollz/croc/v11`。
   fork 只是换了个 remote，不是换了个模块。
2. **不动 `src/version/version.go` 的 `Value`。** CI 用 `git describe --tags --abbrev=0`
   取版本，取不到时回退到这个文件（`release.yml` 的 "Detect croc version" 一步），
   App 里显示的 croc 版本也来自它。
3. **每个补丁都要能独立回上游。** 越像"上游本来就该有的改动"，同步冲突越少，
   将来能删掉的概率也越高。

---

## 1. 分支模型

```
upstream/main ──────────────────────────────►  只读，只 fetch
      │
      │  git rebase --onto upstream/main <old-base> flcroc
      ▼
fork  flcroc  = upstream/main + 补丁集（每个补丁一个 commit，前缀 [flcroc]）
      │
      │  git tag v<上游版本>-flcroc.<n>
      ▼
   FlCroc 的 submodule 固定在这个 tag 上
```

**跟上游最新，不锁版本。** `flcroc` 的基底就是 `upstream/main`，不是某个历史 tag。
上游合并了新东西就 rebase 过去，FlCroc 的 submodule 跟着走。

`main` 分支保持和 `upstream/main` 逐 commit 一致（fork 建好时的原样镜像），
这样 `git diff main flcroc` 永远等于**纯粹的补丁集**，
`git format-patch main..flcroc` 直接就是待上游化的 PR 素材。

> 上游 tag 会污染 fork 的 tag 命名空间（`git describe` 会取到上游的 `vX.Y.Z`）。
> 给 upstream 关掉：`git config remote.upstream.tagOpt --no-tags`。

---

## 2. 已落地的补丁

| tag | 基底 | 补丁 |
|---|---|---|
| `v11.5.4-flcroc.1` | 上游 v11.5.4 | 进度计数器加锁 + `ProgressSnapshot()`（`src/croc/progress.go`） |
| `v11.5.4-flcroc.2` | 同基底 | 导出 `WebReceiveURL()`（`src/croc/web_receive_url.go`） |
| `v11.5.4-flcroc.3` | 同基底 | `Options.LibraryMode`：会 panic 的库路径改返回 error；crypt `New`/`NewArgon2` 不再 `log.Fatalf` |
| `v11.5.4-flcroc.4` | 同基底 | 本地 IP 探测不再弄乱控制流（`croc.go`：探测期限 + 消息循环跳过探测帧） |
| `v11.5.4-flcroc.5` | 同基底 | 导出 `LifecycleSnapshot()`（`src/croc/lifecycle.go`），宿主据此区分「等待对端」与「正在传输」 |

### 打补丁的规范

| 项 | 要求 |
|---|---|
| commit message | `[flcroc] <上游风格的英文标题>`，正文写清"为什么"和上游 PR 状态 |
| 代码注释 | 英文、只写"是什么"，与上游风格一致 |
| 落点 | **优先放新文件**，少动 `croc.go` / `terminal_display.go` 这些上游高频改动的文件 |
| 验收 | `go build ./...` + `go test -race ./src/croc/ -run '...'`，再回 FlCroc 编译一次 bridge |

### 为什么不做的补丁

- **`Quiet` 时把进度条 writer 设成 `io.Discard`**：能治 F1 的根因，但要改 25 处
  `termui.Output(os.Stderr)` 调用点，rebase 冲突成本远超收益 —— 而且 bridge 侧换成
  非阻塞排空器（A3）零改动就能解决同一个问题。

---

## 3. 同步 SOP

**节奏**：上游发 tag 后 3 天内；无新 tag 时每月巡检一次。

```bash
cd D:/Github/croc

# ① 看上游走了多远、有没有碰到补丁改过的文件
git fetch upstream --tags
git log --oneline flcroc..upstream/main -- src/croc src/crypt

# ② 更新镜像分支
git checkout main && git reset --hard upstream/main
git push --force-with-lease origin main

# ③ 补丁集变基到新基底
OLD_BASE=$(git merge-base main flcroc)
git checkout flcroc
git rebase --onto upstream/main $OLD_BASE flcroc

# ④ 冲突处理（见 §4），然后验证
go build ./...
go test -race ./src/croc/ -run 'TestProgressSnapshot|TestRecordReceivedChunk' -count=1

# ⑤ 打 tag（CI 会把它显示成 11.6.0-flcroc.1 —— 故意的，一眼能看出带补丁）
git tag -a v11.6.0-flcroc.1 -m "croc 11.6.0 + FlCroc patches"
git push --force-with-lease origin flcroc && git push origin v11.6.0-flcroc.1
```

```bash
# ⑥ 回 FlCroc 更新指针（v11.5.4 → v11.6.0 必踩：依赖版本变了）
cd D:/Github/FlCroc
git -C submodules/croc fetch --tags origin
git -C submodules/croc checkout v11.6.0-flcroc.1
(cd go_bridge && go mod tidy)      # 上游换了依赖就会需要，别跳过
go build -buildmode=c-shared -o /dev/null ./go_bridge   # 冒烟
git add submodules/croc go_bridge/go.mod go_bridge/go.sum
```

---

## 4. 冲突预案

| 情况 | 处理 |
|---|---|
| 补丁改的文件上游也动了 | 优先把补丁重做成"新增文件 + 最小埋点"，从根上避开 |
| 上游自己实现了同等功能 | 直接 `git rebase --skip` 删掉该补丁 |
| 上游改了 bridge 用到的 API | 见下面的影响面清单；把 bridge 适配和 fork 同步放在**同一个 commit**，避免中间态编译不过 |

**影响面清单**（上游一改就可能打到 bridge 的地方）：

- `croc.Options` 的字段 —— `main.go` 的 `doSend` / `doReceive`
- `croc.Client` 的导出字段 —— `progressSampler.sample`
- `croc.New` / `NewCtx` / `Client.Cancel` / `croc.GetFilesInfo`
- `models.DEFAULT_RELAY` / `DEFAULT_RELAY6` / `DEFAULT_PASSPHRASE`

---

## 5. 未决

1. 要不要把"每月巡检上游进度"做成定时任务（fetch → 输出提交数与受影响的补丁文件 →
   有变化才提醒）。
2. 补丁集超过约 10 个就该重新评估 B6（`Options.EventCallback`）或 C 档（进程外 sidecar），
   而不是继续堆补丁。
