# croc v10 → v11 特性落地审计

> 审计对象：FlCroc @ commit `7f13b1e`，croc submodule 固定于 **v11.5.2**
> 对照基线：**v10.4.4**（升级前的版本，见 `AGENTS.md`）
> 审计方式：bridge 源码 + Dart 侧源码 + croc v11.5.2 源码逐项比对；关键结论均标注 file:line
>
> **落地状态**：本审计的 P0/P1 全部已实现，P2 除第 9/10 项外也已实现。
> 逐项对应关系见文末[第七节](#七落地情况2026-09-23)。

---

## 一、结论摘要

**好消息**：v11 最重的那部分升级是**协议层**的，FlCroc 因为编的是完整 croc（未加 `croc_no_tailcat` 标签），所以**已经自动吃到**了 —— Tailcat/DERP 打洞、断线自动重连、渐进哈希、逐文件压缩协商、接收路径安全校验，全部无需改动即生效。

**坏消息**：v11 新增的**用户可选项**，FlCroc 几乎一个都没接。逐项核对下来：

| 类别 | 数量 |
|---|---|
| v11 自动生效、无需改动 | 8 项 |
| v11 新增但完全没接 | 7 项 |
| 模型/配置里有字段、但链路断了 | 6 项 |
| 审计中发现的**实际缺陷** | 3 个（1 严重 / 1 中等 / 1 轻微） |

**最严重的一条**：**传输进度是假的**。croc 全程在实时更新字节数、当前文件、已完成文件集合，但 bridge 一个字段都没读，UI 用定时器把进度条从 0 爬到 90%，完成时再跳 100%。

> 上面三张表是**审计当时**（`7f13b1e`）的快照，保留原样作为问题清单。实际落地结果见第七节。

---

## 二、已经在用的（自动生效，无需改动）

这些都是 v11 的底层协议升级，只要 `croc.Options` 不带 `Transport` 字段（即留空 → `ParseTransportMode("")` → `TransportAuto`，见 `src/croc/croc.go:147-158`），就走默认全自动协商。

| 特性 | 说明 | 证据 |
|---|---|---|
| **Tailcat / DERP 直连** | PAKE 握手后双方建立 Tailscale 用户态 WireGuard 网络，Magicsock 从 DERP 起步、NAT 打洞成功即升级为直连 UDP；失败则回落 relay | `src/croc/tailcat_negotiation.go`、`staged_transport.go`；README「Data transport selection」 |
| **断线自动重连** | `Send()`/`Receive()` 内部走 `transferWithReconnect()`，最多 10 次指数退避，支持分块续传 | `src/croc/croc.go:794` |
| **重连状态透出** | bridge 抓 stderr 里的 "transfer interruption / Retrying securely"，转成 type-5 事件给 UI | `go_bridge/main.go:203-233` |
| **渐进哈希 / 跳过未变文件** | 相同文件不再重传（`numberOfUnchangedFiles`） | `src/croc/progressive_hash.go`、`croc.go:3442-3451` |
| **逐文件压缩协商** | 与旧版对端自动回落 | `peerPerFileCompression`，`croc.go:1379` |
| **接收路径安全校验** | 拒绝绝对路径、`..` 穿越、`.ssh`、重复目标、逃逸符号链接 | `validateReceiveMetadata()`；`AGENTS.md` 已记录 |
| **文本传输 1 MiB 上限校验** | 发送端提前拦截，避免对端整单拒绝 | `go_bridge/main.go:50, 243-247` |
| **内联元数据 / 分块 file info / 文件清单** | 大文件列表不再一次性塞满控制通道 | `file_manifest.go` |

> 更正（复核后）：`--no-reconnect` 只作用于 `croc ssh` 子命令的**会话重连**
> （`src/cli/ssh.go:78` 的 `Reconnect: !c.Bool("no-reconnect")`），与文件传输走的
> `transferWithReconnect()` 是两套机制。文件传输在 v11.5.2 里**确实**没有关闭
> 重连的开关，`AGENTS.md` 的原描述成立，只是可以写得更精确（已在 `AGENTS.md`
> 里补上这条区分）。

---

## 三、v11 新增但完全没接的能力

| 能力 | croc 接口 | 审计时状态 | 现状 |
|---|---|---|---|
| **`--rename`：重名自动改名** | `Options.Rename`，`croc.go:3416-3423` | 未设置（永远 false） | ✅ 已接，默认开（`8758994`） |
| **`--transport`：通道选择** | `Options.Transport` (`auto`/`derp`/`relay`) | 未设置 → 走 auto | ✅ 已接，三选一（`45b2aee`） |
| **`--exclude-file`：按精确相对路径排除** | `Options.ExcludeFile` + `GetFilesInfoWithExactExclusions()` (`croc.go:1050`) | 未使用；只用了子串匹配的 `Exclude` | ⬜ 仍未接（低优先级，见 P2） |
| **`--throttleUpload`：上传限速** | `Options.ThrottleUpload`（如 `500k`），`croc.go:443-460` | 未设置 | ✅ 已接，含 panic 防护（`eaee481`） |
| **`--socks5` / `--connect`：代理** | 环境变量 `SOCKS5_PROXY` / `HTTP_PROXY` | 未设置 | ✅ 已接，显式配置而非 env（`eaee481`） |
| **`--disable-clipboard`** | `Options.DisableClipboard`，`croc.go:1801-1805` | 未设置 → 默认**开** | ✅ 已接，默认关（`c428d42`） |
| **`croc.NewCtx()`：上下文优雅取消** | `src/croc/ctx.go:59` | 用的是 `croc.New()` | ⬜ 仍未接（P2-9） |

补充：`--store`（加密暂存转发）、`croc ssh`（共享终端）、`serve`/`revoke`/`check` 等是 v11 面向 CLI/服务端的新产品线，与 FlCroc 的「桌面文件传输」定位不符，**建议不做**，仅在路线图上留个记号。

---

## 四、断链：模型和配置里有字段，但没传到 Go

这是最「可惜」的一类 —— 接口早就留好了，中间少一行代码。（下表为审计时的状态；已在 `8e109c5` / `eaee481` 中全部打通。）

| 字段 | Dart 模型 | 配置持久化 | 传给 `SendOptions` | 传到 Go | 现状 |
|---|---|---|---|---|---|
| `gitIgnore` | ✅ `core.dart:17` | ✅ `common.dart:114` | ❌ `send.dart:498-509` 未传 | ❌ | ✅ 已打通 |
| `disableLocal` | ✅ `core.dart:20` | ✅ `common.dart:115` | ❌ 未传 | ❌ | ✅ 已打通 |
| `exclude` | ✅ `core.dart:25` | ✅ `common.dart:123` | ❌ 未传 | ✅ bridge 已支持 | ✅ 已打通 |
| `socks5Proxy` | ✅ `core.dart:22` | ✅ `common.dart:119` | ❌ 未传 | ❌ bridge 无此字段 | ✅ 已打通 |
| `httpProxy` | ✅ `core.dart:23` | ✅ `common.dart:120` | ❌ 未传 | ❌ bridge 无此字段 | ✅ 已打通 |
| `throttleUpload` | ✅ `core.dart:24` | ✅ `common.dart:121` | ❌ 未传 | ❌ bridge 无此字段 | ✅ 已打通 |
| `showQrCode` | — | ✅ `common.dart:118` | — | — | ➖ 无意义（FlCroc 用 `qr_flutter` 自己画二维码） |
| `disableClipboard` | — | ✅ `common.dart:119` | — | ❌ | ✅ 已改为 opt-in 的 `copyCodeToClipboard` |

两个额外发现（均已修复）：

- **`CoreService`（CLI 子进程）路径是半死的**。`lib/core/controller.dart:36-50` 里 FFI 优先、CLI 兜底。但 CLI 路径只传了 `--socks5`（`service.dart:191`），`httpProxy` 和 `throttleUpload` 连兜底路径都没传。桌面端实际都走 FFI，所以这几个字段是**彻底的死代码**。→ `eaee481` 把 CLI 兜底路径的 argv 补齐（`--git` / `--no-local` / `--disable-clipboard` / `--transport` / `--throttleUpload` / `--connect` / `--exclude` / `--rename` / `--socks5`），两个后端行为一致。
- **`quick_transfer.dart`（仪表盘快捷传输）比 `send.dart` 传得更少** —— 连 `curve`/`hashAlgorithm`/`compress` 都没传（`quick_transfer.dart:439-449`），所以从快捷面板发起时会静默忽略用户在发送页配的加密曲线和哈希算法。这是一个**真实的配置不一致 bug**。→ `8e109c5` 让卡片直接读 `SendConfig` / `ReceiveConfig`，并给两个配置加了 `prefKey` + `load()` / `save()`，杜绝 key 字面量各写一份。

---

## 五、发现的三个实际缺陷

### 缺陷 1（严重）：传输进度是定时器假造的

**现象**：进度条匀速爬到 90% 后开始龟速爬，完成瞬间跳到 100%；全程没有速度、没有已传字节、没有当前文件名。

**根因**：`go_bridge/main.go:10` 声明了 `CROC_EVENT_PROGRESS 1`，但 **`doSend`/`doReceive` 从未发出过 type-1 事件**。发出的只有：

| 事件 | 含义 | 位置 |
|---|---|---|
| 4 | 码词就绪 / 传输开始 | `main.go:323-327, 438-441` |
| 2 | 完成 | `main.go:364-367, 507-515` |
| 3 | 错误 | 各处 |
| 5 | 重连状态 | `main.go:219-223` |

Dart 侧也只认 2/3/4/5（`lib_native.dart:222-257`），于是 UI 只能用 `_startSimProgress()` 造假：
`send.dart:55-71`、`receive.dart:38-49`。

**但 croc 一直在提供真数据**，全是**导出字段**，不需要改 croc 源码：

| 字段 | 含义 | 更新点 |
|---|---|---|
| `TotalSent` | 已传字节 | `croc.go:3670`（收）/ `3811`（发） |
| `TotalChunksTransferred` | 已传块数 | `croc.go:3671` |
| `FilesToTransferCurrentNum` | 当前文件序号 | `croc.go:3456` |
| `FilesHasFinished` | 已完成文件集合 | `croc.go:3189` |
| `TotalNumberOfContents` | 文件总数 | `croc.go:1779` |
| `Step1..Step4` / `SuccessfulTransfer` | 生命周期阶段（有锁保护） | `client_state.go:45-50` |

**修复方向**：在 bridge 里起一个 200ms 的 ticker goroutine，读 `activeClient` 的上表字段，发 type-1 事件；Dart 侧把 type-1 映射到已有的 `TransferProgress.transferredSize` / `speed`（`lib/models/core.dart:63,65`，字段本来就有）。UI 删掉 `_startSimProgress()`。

**已实现（`6ddba53`）**：

- `go_bridge/main.go` 新增 `progressSampler`：200ms ticker，从 `activeClient` 读
  `TotalSent` / `FilesToTransferCurrentNum` / `TotalNumberOfContents` / `FilesToTransfer`，
  跨文件进度 = 已完成文件大小之和 + 当前文件 `TotalSent`；速度用两次采样的增量除以时间差，
  而不是读 croc 内部瞬时速率。`doSend` / `doReceive` 各自起停一个 sampler。
- 事件里新增 `current_file_index`，Dart 的 `CoreLib._liveProgress()` 把它换算成
  `completedFiles`；`send.dart` / `receive.dart` / `quick_transfer.dart` 三处
  `_simProgress` + `_progressTimer` 全部删除，改由 `transferring` 事件驱动。
- 顺带修掉一个隐藏 bug：`appStateProvider.speeds` 一直没有生产者（`updateSpeeds` 从未被调用），
  仪表盘的速度统计恒为 0。新增 `AppController.setSpeed()` 后才有数据。
- `CapsuleProgressChip` 支持 `detail` 副标题（`2/5 · 12.3 MB/s`），并用 Tooltip 显示当前文件名。

⚠️ **注意并发**：`TotalSent` 等是裸 `int64`，croc 在别的 goroutine 写、bridge 在别的 goroutine 读，严格说存在数据竞争（c-shared 构建没开 `-race`，实际表现为「偶尔读到旧值」，不会崩）。要彻底干净，应在上游加一个带锁的导出访问器 —— 上游其实已经有 `lifecycleSnapshot()`（`client_state.go:20`），只是没导出，可以提 PR 让上游导出它，或用 `Step*` 这类有锁写入的字段做阶段判断、只把 `TotalSent` 当「近似值」用。

**采样器实际采取的规避策略**（`go_bridge/main.go` 的 `progressSampler.sample()`）：

- **绝不读 `FilesHasFinished`**。它是 `map`，并发读会触发 Go 的 **fatal error**（不是可恢复的 panic），
  整个 Flutter 进程会直接死掉。已完成文件数改用 `current_file_index` 推算。
- `FilesToTransfer` 的切片读取（可能读到撕裂的 slice header）包在 `recover()` 里，
  坏样本直接跳过，降级为「这一拍没数据」而不是崩溃。
- 裸 `int64`（`TotalSent` 等）的读取不额外保护 —— 跨 goroutine 读到的是旧值或新值，
  不会撕裂，也不会崩。

复核时把并发情况看得更细了：croc **并非完全没锁**，而是用了两把**不导出**且覆盖字段
不同的锁 —— 发送路径走 `c.mutex`（`croc.go:3810-3812`），接收路径走 `c.receiveMutex`
（`croc.go:3669-3671`、`:3199-3201`）；而 `FilesToTransferCurrentNum`（`:3456`）、
`FilesToTransfer`（`:1280`/`:1780`）、`FilesHasFinished`（`:3189`）、
`numberOfTransferredFiles`（`:3439`/`:3457`）**完全裸奔**。宿主进程既拿不到这两把私有锁，
也无法覆盖裸奔字段，所以「自己加锁同步」这条路在当前 API 下不存在。

彻底干净的方案需要上游配合，已写成 PR 草稿：`docs/upstream-pr-lifecycle-accessor.md`。

### 缺陷 2（中等）：接收时文件重名会被静默跳过

**推断链路**（源码推导，未实测）：

1. `quick_transfer.dart:531-538` 构造 `ReceiveOptions` 时**没传 `overwrite`** → 默认 `false`。
2. `Options.Rename` 从未设置 → 也为 `false`。
3. 于是命中 `croc.go:3424-3433`：
   ```go
   if destinationExists && !c.Options.Overwrite && !c.Options.Rename && !isTextArtifact {
       overwrite, promptErr := askReceiveOverwrite(...)   // 要交互
       if !overwrite { continue }                          // ← 跳过这个文件
   }
   ```
4. `askReceiveOverwrite`（`croc.go:3301`）调 `receiveOverwriteInput` = `utils.GetInputContext`（`croc.go:3299`），从 **stdin** 读一行。
5. Flutter Windows 是 GUI 子系统程序，**没有控制台，stdin 句柄无效** → 读失败返回空串（`src/utils/utils.go` 注释明确写了「On read error (e.g. closed or exhausted stdin) the returned string is empty」）。
6. 空串 ≠ `"y"` → 打印 `Skipping <file>` → 返回 `false` → `continue`。

**后果**：用户接收一个已存在的文件时，传输显示「完成」，但文件**没有落地也没有任何提示**。用户会以为丢了数据。

**修复**：最贴合 v11 设计的是把 `Options.Rename` 接上（这正是 v11 新增 `--rename` 的场景 —— README 章节名就叫 "Keep Both Files Without Prompt"），在接收页加一个「重名时自动改名保留两份」开关，默认开。次选是把 `overwrite` 补进 `quick_transfer.dart` 的构造点。

**已实现（`8758994`）**：两条都做了。

- `receiveOptions` 新增 `rename *bool`（指针语义同 `disable_clipboard`：缺省 true），
  映射到 `croc.Options.Rename`；`ReceiveOptions.rename` / `ReceiveConfig.rename` 默认 true，
  接收页「传输选项」新增开关「重名时自动改名」。
- `quick_transfer.dart` 的 `ReceiveOptions` 现在读 `ReceiveConfig`，`overwrite` / `rename` 都会带上。

**验证方法**：本机跑一次 `croc send` 传一个已存在的文件到 GUI，观察是否静默跳过。
（尚未实跑验证 —— 见文末「验证缺口」。）

### 缺陷 3（轻微）：发送时静默劫持系统剪贴板

`croc.go:1801-1805`（在 `Send()` 内）：
```go
if !c.Options.DisableClipboard {
    clipboardText := formatClipboardText(c.Options.SharedSecret, flags.String(), c.Options.ExtendedClipboard)
    if copyToClipboard(clipboardText, true, c.Options.ExtendedClipboard) { ... }
}
```
README「Clipboard Options」原文：*"By default, the code phrase is copied to your clipboard."*

bridge 没设 `DisableClipboard`，所以**每次发送都会把码词写进系统剪贴板**。FlCroc 自己的 UI 已经在展示码词了，这个副作用纯属多余；更麻烦的是现代剪贴板有云同步和历史记录，**码词会外泄**。

**修复**：`crocOpts` 里加 `DisableClipboard: true`（一行），或做成配置项（`SendConfig.disableClipboard` 字段已经存在）。

**已实现（`c428d42`）**：选了「默认关闭 + 用户可显式开启」这条路。

- `sendOptions` 新增 `disable_clipboard *bool`，字段缺席时默认 **true**（不去碰剪贴板）；
  `SendOptions.disableClipboard` 默认 true。
- `SendConfig.disableClipboard` **改名**为 `copyCodeToClipboard`（默认 false）。
  直接沿用旧字段名会留个坑：老版本把 `disableClipboard=false` 持久化在 prefs 里，
  升级后仍然是「允许劫持」。改名后旧键被 `fromJson` 忽略，升级即生效。
- 发送页高级面板新增开关「允许 croc 写入系统剪贴板」，默认关闭。

---

## 六、改进建议（按性价比排序）

### P0 —— 值得立刻做

| # | 改动 | 工作量 | 收益 | 状态 |
|---|---|---|---|---|
| 1 | **接真实进度**：bridge 加 200ms ticker 发 type-1 事件；Dart 映射到 `transferredSize`/`speed`；删掉 `_startSimProgress()` | 中（Go ~60 行 + Dart ~30 行） | 消除最显眼的「假」体验，大文件传输体感质变 | ✅ `6ddba53` |
| 2 | **`DisableClipboard: true`** | 1 行 | 堵住码词经剪贴板外泄 | ✅ `c428d42` |
| 3 | **接 `Options.Rename`** + 接收页开关 | 小（Go 1 字段 + Dart 1 开关） | 修掉「文件静默消失」这个数据信任问题 | ✅ `8758994` |

### P1 —— 补齐断链，让已存在的配置真正生效

| # | 改动 | 说明 | 状态 |
|---|---|---|---|
| 4 | `send.dart:498` 补上 `gitIgnore` / `disableLocal` / `exclude` | 三行，字段和 Go 支持都已就绪 | ✅ `8e109c5`（并补了对应 UI） |
| 5 | `quick_transfer.dart:439` 对齐 `send.dart` 的选项 | 修掉快捷面板忽略加密曲线/哈希的配置不一致 bug | ✅ `8e109c5` |
| 6 | `Options.Transport` 做成「自动 / 仅中继」二选一 | 网络封 DERP 时的救命开关；bridge 用 `croc.ParseTransportMode` 校验 | ✅ `45b2aee`（做了三选一：自动 / 直连优先 / 仅中继） |

### P2 —— 体验增强

| # | 改动 | 说明 | 状态 |
|---|---|---|---|
| 7 | `Options.ThrottleUpload` | 上传限速，`500k` 之类；需 bridge 加字段 | ✅ `eaee481`（含 panic 防护） |
| 8 | `SOCKS5_PROXY` / `HTTP_PROXY` 环境变量透传 | 受限网络场景；注意 bridge 是 CGO 共享库，env 由宿主进程传入 | ✅ `eaee481`（改为**显式配置**而非读 env，理由见该 commit message） |
| 9 | 换用 `croc.NewCtx()` | 取消时向对端发 `SendError`，对端少等一个超时 | ⬜ 未做 |
| 10 | 透出「直连 / 中继」标识 | 目前 croc 的 `peerToPeerDataPath()` 未导出，需上游 PR；可先用 type-5 事件近似 | ⬜ 未做（PR 草稿已备） |
| 11 | 顺手更正 `AGENTS.md` 关于 reconnect 不可关闭的过时描述 | 文档债 | ✅ 复核后确认原描述**成立**，改为写得更精确 |

### 建议的落地顺序

1. 先做 P0-1（真进度）—— 它是唯一「用户能直接感觉到」的项，且能把 `TransferProgress` 里那两个沉睡字段激活。
2. 再做 P0-2 / P0-3 —— 都是几行代码，但一个防泄露、一个防数据信任崩塌。
3. P1 集中在 `send.dart` / `quick_transfer.dart` 两个文件，可以合成一个 PR。
4. P2 里第 10 项需要给上游提 PR，建议单独走，别阻塞主线。

以上顺序即实际落地顺序（`6ddba53` → `c428d42` → `8758994` → `8e109c5` → `45b2aee` → `eaee481`）。

---

## 七、落地情况（2026-09-23）

一轮改动，6 个提交，全部在 `7f13b1e` 之上：

| commit | 内容 |
|---|---|
| `6ddba53` | `feat(progress)`：用 croc 真实计数器驱动进度，删除三处模拟进度 |
| `c428d42` | `fix(clipboard)`：默认不再让 croc 覆盖系统剪贴板 |
| `8758994` | `fix(receive)`：重名时自动改名，不再静默丢文件 |
| `8e109c5` | `fix(send)`：补齐断链的发送选项，仪表盘卡片复用同一份配置 |
| `45b2aee` | `feat(send)`：暴露传输通道选择（自动 / 直连优先 / 仅中继） |
| `eaee481` | `feat(transfer)`：打通上传限速与 SOCKS5/HTTP 代理 |

### 新增的 bridge 选项（`go_bridge/main.go`）

| JSON key | 类型 | 缺省 | 映射 |
|---|---|---|---|
| `disable_clipboard` | `*bool` | `true`（不碰剪贴板） | `croc.Options.DisableClipboard` |
| `rename` | `*bool` | `true`（重名改名） | `croc.Options.Rename` |
| `transport` | `string` | `auto` | `croc.Options.Transport`（经 `ParseTransportMode` 校验） |
| `throttle_upload` | `string` | 空 = 不限速 | `croc.Options.ThrottleUpload`（经 `normalizeThrottle` 校验） |
| `socks5_proxy` | `string` | 空 | `comm.Socks5Proxy`（包级全局，`croc.New` 前赋值） |
| `http_proxy` | `string` | 空 | `comm.HttpProxy`（同上） |
| `current_file_index`（**出**） | `int` | — | type-1 事件新增字段，Dart 换算成 `completedFiles` |

两个 `*bool` 用指针是为了区分「字段缺席」与「显式 false」：老的 Dart 版本不会发这些键，
bridge 必须能安全地退回安全默认值。

### 新增的 i18n key（en / zh / zh-Hant / ja / fr 五份齐全）

`crocClipboard`、`renameOnCollision`、`respectGitIgnore`、`disableLocalRelay`、
`excludePatterns`、`excludePatternsHint`、`transportMode`、`transportAuto`、
`transportDerp`、`transportRelay`、`transportLocalConflict`、`throttleUpload`、
`throttleUploadHint`、`socks5Proxy`、`httpProxy`、`proxyHint`（共 16 个，`allKeys` 165 → 179）。

### 验证缺口（需要人工确认）

自动化验证到位的部分：`flutter analyze` 无 error（27 项 info/warning 均为改动前既有）、
`flutter test` 32/32、`gofmt` / `go vet` 干净、Go c-shared 与 `flutter build windows --release` 均构建成功、
五个语言包键集合一致。

**没有**自动验证的部分（都要真机双端跑一次）：

1. 真实进度条是否与 `croc` 进度一致（尤其多文件、大文件）。
2. 重名接收是否真的落到新名字上（缺陷 2 的原始推导链仍未实跑验证）。
3. `transport=derp` 在能打洞的网络下是否真的走直连、`relay` 是否真的绕过直连。
4. `throttle_upload=500k` 是否真的限速（croc 内部限流器是否被正确初始化）。
5. 代理是否生效（需要一个真的 SOCKS5 / HTTP 代理）。

---

## 附：审计覆盖范围与置信度

| 结论 | 置信度 | 依据 |
|---|---|---|
| 进度是假的 | **确定** | bridge 无 type-1 发射点 + Dart 只认 2/3/4/5 + `_startSimProgress` 实现 |
| 断链的 6 个字段 | **确定** | 逐层 grep：模型有、构造点无、Go 无 |
| 剪贴板被劫持 | **高** | `croc.go:1801` 无 `DisableClipboard` 门槛短路 + README 明确默认开启 |
| 重名静默跳过 | **中高** | 源码链路完整推导，但未实跑验证 stdin 在 GUI 进程下的具体错误 |
| Tailcat 已生效 | **高** | `Transport` 留空 → `TransportAuto`；构建未加 `no_tailcat` 标签 |
| 进度字段存在数据竞争 | **确定** | 两把私有锁（`mutex` / `receiveMutex`）覆盖不一致，另有 4 个字段完全无锁；`FilesHasFinished` 是 map，并发读为 fatal error |

**未覆盖**：Linux/macOS/Android 三端的构建产物差异；`croc ssh` / `store` 等新产品线的可行性评估。

**本轮新增的未验证项**：见第七节「验证缺口」——真实进度、重名改名、transport、限速、代理都只做到了「编译/静态检查通过 + 逻辑链路完整」，没有双端实跑。
