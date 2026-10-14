# go_bridge 稳定性调研与改造方案

> 调研基线：croc fork（`576576/croc`）的 `flcroc` 分支，即上游 + FlCroc 补丁。
> croc 侧一律用**符号名**定位（函数 / 方法名），不用行号 —— submodule 跟上游最新，行号会漂。

---

## 0. 结论速览

go_bridge 的"不稳定"不是单一 bug，而是一个结构性事实的三个后果：

> **croc 是 CLI，不是库。它被 `-buildmode=c-shared` 编进 Flutter 进程，
> 于是它所有"CLI 时代无所谓"的行为 —— 往 stderr 打进度条、panic 了就崩、
> 改进程级全局状态 —— 全部变成直接杀死宿主 App 的凶器。**

| # | 后果 | 典型现场 |
|---|---|---|
| 1 | **永久挂起**（无错误、无超时） | 传大文件传着传着不动了 |
| 2 | **整进程闪退**（无提示） | 端口 9009 被占、对端报文异常 |
| 3 | **状态串台** | 同时进行收发 / 取消后再发 |

按"能不能不动 croc 就修"分三档：

| 档 | 内容 | 收益 |
|---|---|---|
| **A** | 纯 bridge 加固：panic 屏障、per-transfer 通道、非阻塞 stderr 排空、`NewCtx` | 消灭全部挂起和 2/3 闪退 |
| **B** | fork croc 最小补丁 | 只留 A 档修不掉的那一条 |
| **C** | 架构换轨：croc 跑独立进程 | 彻底隔离崩溃、去掉 cgo 构建矩阵（并行预研） |

**推荐 A → B，C 先只做原型评估。**

---

## 1. 架构与约束

```
Flutter (Dart isolate) ──dart:ffi，每 200ms 轮询──► libcroc_bridge.{so,dylib,dll}
                                                     │ CrocSendFiles / CrocReceiveFiles
                                                     │ CrocPollProgress / CrocCancelTransfer
                                                     ▼
                                              croc.Client（submodules/croc）
```

| 约束 | 后果 |
|---|---|
| 同进程同地址空间（`-buildmode=c-shared`） | croc 的 panic / `os.Exit` / 全局状态 = Flutter 的 |
| 进度只能轮询拉取（`CrocPollProgress`） | 队列满就反压到 croc；宿主不轮询就堵死 |
| croc 是 CLI 心智 | 往 stderr 打进度条、panic、`os.Chdir`、改 `os.Stdout` |
| 一个进程同时只能有一个传输 | 全局 `activeClient` / `progressChan`，第二个会顶掉第一个 |

---

## 2. 失效模式清单

**P0** = 闪退或永久卡死；**P1** = 会出错但有绕过；**P2** = 隐患或工程成本。

### F1 【P0】stderr 管道被进度条撑爆 → 传输永久阻塞

"传大文件就卡住"最可能的根因，不需要并发就能触发。

1. bridge 的 `captureStderr` 用 `os.Pipe()` 接管 `os.Stderr`，再用 `bufio.Scanner` 按行
   扫描，只想抓 `"transfer interruption"` / `"Retrying securely"`。
2. croc 的进度条和接收状态都写 stderr：`newProgressBar`、`setReceiveStatus`
   （`src/croc/terminal_display.go`）→ `termui.Output(os.Stderr)`；而 `termui.Output`
   在非终端时**原样返回那个 `*os.File`**，不是 `io.Discard`，所以内容真的进管道。
3. 进度条每 100ms 重绘、以 `\r` 分隔，只在整个文件传完时才打一个 `\n`（`fmtPrintUpdate`）。
4. 单文件传输期间没有换行，累计超过 `bufio.MaxScanTokenSize`（64KB）后 `Scan()` 返回
   `false`（`ErrTooLong`），**扫描 goroutine 退出**。
5. 从此没人读管道；管道缓冲（Linux 64KB）写满后，croc 写 stderr 时**永久阻塞**。

量级：约 80 字节/次 × 10 次/秒 ≈ 800 B/s → 单文件传 **~80 秒**就触发。
后果：`Send()`/`Receive()` 永不返回，Dart 侧一直拿到 `null`，UI 永远停在"传输中"，
**没有任何错误事件**。

> `croc.New` 在 `Quiet` 下本已把 `os.Stderr` 指向 `os.DevNull`，是 bridge 为了抓重连
> 通知又换成了管道 —— 所以这条**在 bridge 侧就能修**（A3）。

### F2 【P0】没有 panic 屏障 → 任何 Go panic 直接杀死 Flutter 进程

`doSend` / `doReceive` 跑在裸 goroutine 里，没有 `defer recover()`；c-shared 里宿主拦不住。

| 位置 | 触发 |
|---|---|
| `setupLocalRelay` 的 `panic("not enough open ports to run local relay")` | **默认开本地中继**，9009-9013 被占就崩 |
| `setupLocalRelay` 里本地中继 `tcp.Run` 失败后的 `panic(err)` | 中继启动失败 |
| `croc.New` 里 `ThrottleUpload` 解析的 panic | bridge 已用 `normalizeThrottle` 挡住（有单测） |
| `src/crypt/crypt.go` 的 `log.Fatalf` | **比 panic 更狠**：`os.Exit(1)`，进程直接消失 |

### F3 【P0 · 一行能修】`croc.New()` 不带 ctx → PAKE 阶段的 panic 被原样抛出

`processMessagePake` 的 recover 分支：`if c.stop.gui { 记日志 + Cancel } else { panic(r) }`。
`gui` 只在 `NewCtx` 里置 true，bridge 用的是 `croc.New`。
**改成 `croc.NewCtx(ctx, opts)`** —— 除 `gui=true` 外还拿到 `tcp.RunCtx` /
`utils.HashFileCtx` 的取消能力。`Client` 末尾匿名嵌入 `*stop`，`activeClient.Cancel()` 照旧可用。

> `docs/agent/croc-v11-feature-audit.md` 第七节第 9 项也把它列为"未做"。

### F4 【已修】进度计数器无锁 → 数据竞争

bridge 曾直接读 `TotalSent` / `FilesToTransferCurrentNum` / `FilesToTransfer`，这些由 croc
自己的 goroutine 并发写、没有共享的锁；**`FilesHasFinished` 是 map，并发读是 fatal error，
`recover()` 兜不住**。fork 已加 `progressMu` 并导出 `ProgressSnapshot()`
（`src/croc/progress.go`，带 `-race` 测试）；bridge 侧切过去见 A9。

### F5 【P1】全局单通道 → 串台 或 向 nil channel 发送导致永久阻塞

每次 `CrocSendFiles` / `CrocReceiveFiles` 都重建全局 `progressChan`，但 `doSend` /
`doReceive` / `captureStderr` 里所有发送都**直接读全局**。而 `CrocPollProgress`
看到 channel 关闭后会把它置 `nil`。

- 第二次传输开始 → 第一次的事件被送到新 channel（串台）。
- poll 先置 nil、之后 `doSend` 再发 → **向 nil channel 发送 = 永久阻塞** →
  goroutine 泄漏、完成事件永不到达。表现为"取消后再发一次就收不到完成"。

### F6 【P1】`os.Chdir` 改进程工作目录，从不恢复

c-shared 与 Flutter 同进程，cwd 是进程级资源：接收一次文件后，Flutter 侧的相对路径解析、
文件选择器、Dart 的 `Directory.current` 全部跟着变，直到进程退出。

### F7 【P1】stderr 事件用阻塞发送 → channel 满时反压到 croc

`captureStderr` 里是裸 `progressChan <-`（容量 100），Dart 每 200ms 只取 1 条。断线重连
风暴时写者阻塞，与 F1 同归于尽。（`progressSampler` 用了 `select/default`，是对的。）

### F8 【P2】同一时刻只允许一个传输，但没有拒绝第二个

`CrocCancelTransfer` 完全忽略传入的 `transfer_id`，取消的是"当前那一个"。

### F9 【P2】`transfer_id` 用 `os.Getpid()`

进程内恒定；Dart 侧另造毫秒时间戳 ID，两边不一致，只是因为同时只有一个传输才没出事。

### F10 【P2】接收时接管 `os.Stdout`，用无上界 `bytes.Buffer`

文本上限 1MiB（`validateSendingTextOffer` 会校验），实际有界，但二维码 / `\r` / 文本载荷
都写 stdout，`capturedStdout` 被原样当成正文，可能带脏字符。
另外 croc 的包级 `init()` 把 logger 绑到**当时的** `os.Stdout`（因此绕过 bridge 的管道，
直写宿主 stdout）并把级别设成 debug，随后 `newClient` 里才降到 warn。

### F11 【P2】构建链脆弱

构建脚本跑 `go mod tidy`：联网、改写 `go.mod`/`go.sum`，CI 上不可复现；交叉编译依赖
zig / NDK；macOS 要手工 codesign；Android 要 16KB 页对齐。

### F12 【P2】c-shared 与 Flutter 同进程的固有耦合

Go runtime 的线程 / GC / 信号处理与 Dart VM 共存。这条是 C 档的根本动机。

---

## 3. 待验证：文本传输退化成 `croc-stdin-*.txt`

已知症状：发文本，receiver 收到的是 `croc-stdin-*` 文件而不是流式文本。**还没复现定位。**

可疑点：接收端 `validateSendingTextOffer` 要求 `FolderRemote == "."` 且文件名以
`croc-stdin-` 开头，而 `GetFilesInfo` 对根层文件给的是 `FolderRemote: "./"`（带斜杠）；
是否相等取决于 `normalizeReceiveFilePath` 是否在校验**之前**跑过。

**验证成本极低**：加个 Go 单测，对 `os.CreateTemp` 出来的路径调 `GetFilesInfo`，
断言 `FolderRemote == "."`。若成立，改法是 `doSend` 里手动构造 `FileInfo` 而不走 `GetFilesInfo`。

---

## 4. 方案

### 4.1 A 档：不动 croc，纯 bridge 加固

| # | 改动 | 修掉 |
|---|---|---|
| A1 | `croc.New` → `croc.NewCtx(ctx, opts)` | F3 |
| A2 | 每个导出 C 函数 + `doSend`/`doReceive` goroutine 加 `defer recover()`，panic 转 type-3 错误 | F2（`os.Exit` 除外） |
| A3 | `captureStderr` 的 `bufio.Scanner` 换成**永不阻塞的排空器**：固定缓冲 + 滑窗子串匹配，超长就丢弃继续读 | F1 |
| A4 | 所有 `progressChan <-` 改用 **per-transfer channel**（传参，不再读全局）+ `select/default` | F5、F7 |
| A5 | 单飞锁：已有传输在跑时直接返回错误 | F5、F8 |
| A6 | 去掉 `os.Chdir`；改为 `defer` 恢复 + 传输期间持锁 | F6 |
| A7 | `transfer_id` 改原子自增，Dart 侧不再自造 ID | F9 |
| A8 | 构建脚本 `go mod tidy` → `-mod=readonly` + 显式 `go mod download` | F11 |
| A9 | `progressSampler.sample` 改成一行 `c.ProgressSnapshot()`，删掉 `recover()` 绕行 | F4（bridge 侧收尾） |

### 4.2 B 档：fork croc 补丁

原则见 `plan/croc-fork-sync.md`：每个补丁都要能独立回上游。已落地的补丁记在那份文档的
补丁表里，这里只列还没定的。

| # | 补丁 | 状态 |
|---|---|---|
| B1 | `Quiet` 时把进度条 / 接收状态的 writer 设为 `io.Discard` | **不做** —— 要改 25 处调用点，rebase 成本远高于收益；A3 零改动就能解决同一问题 |
| B3 | 库路径 `panic` → `error`（`Options.LibraryMode` 门控） | 待定；A2 能兜住大部分 |
| B4 | `src/crypt/crypt.go` 的 `log.Fatalf` → `error` | 待定；概率极低但后果最重 |
| B5 | `Options.OutputPath`（不再需要宿主 `os.Chdir`） | 待定；A6 先顶着 |
| B6 | `Options.EventCallback` 主动推事件 | 终局形态，但 diff 会很大；等 A 档做完再评估 |

### 4.3 C 档：进程外 sidecar

croc 跑成独立可执行文件，Flutter 通过 stdin/stdout JSON-Lines 或本地 socket 通信。

| 维度 | 现状（c-shared） | sidecar |
|---|---|---|
| 崩溃隔离 | ❌ panic / `os.Exit` 带走 App | ✅ 只崩子进程，可重启并重报 |
| 全局状态污染 | ❌ stderr / stdout / cwd / 代理都在宿主里 | ✅ 天然隔离 |
| cgo 构建矩阵 | ❌ 4 平台 × NDK/zig/codesign/16KB 页 | ✅ 纯 Go 交叉编译 |
| Android | 已能跑（16KB 页已处理） | ⚠️ 需从 APK 释放并 `exec`，Android 10+ 有限制，要实测 |

桌面端收益明确；移动端先做"能不能 spawn + exec"的冒烟原型再决定。

---

## 5. 落地顺序

| Phase | 内容 | 验收 |
|---|---|---|
| **P0** | A1–A5 + A9 | 见 §6 |
| **P1** | B3/B4/B5（视 A 档效果决定做不做） | fork 单测 + 真机 |
| **P2** | A6/A7/A8 + 修 §3 的文本传输 | 单测 + 手工 |
| **P3（并行）** | C 档 Android spawn 冒烟原型 | 真机跑通一次，出结论 |

---

## 6. 怎么证明"稳了"

**所有用例必须跑本地中继，一个包都不许打到公共中继。**
`croc.schollz.com` 对入房频率有硬限制（`--source-join-limit` / `--room-join-limit` /
`--join-limit-window`）：挂起回归那种单文件长跑、以及浸泡测试每分钟两次的循环，
会把 IP 直接限掉，看起来像 bridge 的 bug，实际是被中继拦了。那也是拿别人的公共服务
做压测，本来就不该那么跑。

`-race` 在 c-shared + Flutter 里没法直接用，所以在 `go_bridge/` 加一个纯 Go harness，
模拟 Dart 的轮询节奏（每 200ms 取一条，与 `lib_native.dart` 一致）。

### 6.1 先起一个本地中继

```bash
cd submodules/croc
go run . relay --host 127.0.0.1 --ports 9009,9010,9011,9012,9013 \
    --source-join-limit 100000 --room-join-limit 100000
```

后两项是中继**自己**的入房限流。默认值是按真人手动传文件定的，浸泡测试一轮 100MB、
每分钟两次就会把配额打光，然后被自己的中继拦下来。

### 6.2 harness 的固定选项

| 选项 | 值 | 为什么 |
|---|---|---|
| `relay_address` | `127.0.0.1:9009` | 打到 6.1 那个进程 |
| `relay_ports` | `9009,9010,9011,9012,9013` | 与中继一致 |
| `disable_local` | `true` | 不让客户端再自己起一个本地中继 —— 那会去抢 9009–9013，正好撞上 F2 |
| `transport` | `relay` | 固定走中继路径，不让 auto 挑 Tailcat，结果才可复现 |

两条捷径都走不通：

- `--local`（`OnlyLocal`）要求 `transport` 必须是 `auto`（`src/cli/cli.go` 里
  `--transport must be auto for local-only transfers`），路径锁不住。
- 只给 `relay_address` 而不关 `disable_local`，客户端仍会去连公共中继
  （`!c.Options.OnlyLocal` 分支照跑），限流照样会来。

### 6.3 用例

1. **挂起回归（F1）**：传一个 ≥500MB 的单文件，断言 5 分钟内必收到 type-2 或 type-3。
   **修复前这条应该超时失败** —— 进度条约 800 B/s 往 stderr 写，80 秒左右就把
   `bufio.Scanner` 撑爆。
2. **panic 回归（F2）**：先占住 9009–9013 再发送。修复前进程直接死，修复后收到
   type-3 且进程存活。**注意**：6.2 里的 `disable_local=true` 会绕开这条路径
   （`setupLocalRelay` 只在 `!DisableLocal` 时调用），所以这个用例要单独把本地中继打开。
3. **串台回归（F5）**：并发调 send + receive，断言第二次收到
   `a transfer is already in progress`，且第一次的事件不被第二次接收。
4. **竞争回归（F4）**：`go test -race` 跑一次完整收发，断言无 race（配 A9 之后才可能干净）。
5. **浸泡**：1 小时、每 30 秒一次的 100MB 收发循环，断言 `runtime.NumGoroutine()` 不单调增长。

---

## 7. 未决问题

1. §3 的文本传输退化：`FolderRemote` 到底是 `"."` 还是 `"./"`？一个单测就能定论。
2. A2 兜不住 `log.Fatalf` → `os.Exit`，是否值得为它打 B4。
3. C 档在 Android 上是否允许 spawn + exec 释放出来的二进制。
4. B6 做不做：最干净，但会让 fork 与上游的 diff 显著变大，直接影响同步成本。
