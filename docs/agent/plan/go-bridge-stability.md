# go_bridge 稳定性：现行结论与遗留项

> A 档加固（A1–A9）与 B3/B4 补丁已落地，方案过程只在 git 历史里。这里留三类东西：
> **为什么 bridge 必须加固**（失效模式清单）、**还没做的**、**怎么验证**。
>
> 调研基线：croc fork（`576576/croc`）的 `flcroc` 分支。croc 侧一律用**符号名**定位
> （函数 / 方法名），不用行号 —— submodule 跟上游最新，行号会漂。

---

## 0. 结论

> **croc 是 CLI，不是库。它被 `-buildmode=c-shared` 编进 Flutter 进程，于是它所有
> "CLI 时代无所谓"的行为 —— 往 stderr 打进度条、panic 了就崩、改进程级全局状态 ——
> 全部变成直接杀死宿主 App 的凶器。**

三个后果：永久挂起（无错误、无超时）、整进程闪退（无提示）、状态串台。

| 档 | 内容 | 状态 |
|---|---|---|
| **A** | 纯 bridge 加固 | ✅ 全部落地 |
| **B** | fork croc 最小补丁 | B1 不做；B3/B4 已落地（`v11.5.4-flcroc.3`）；B5/B6 待定 |
| **C** | 架构换轨：croc 跑独立进程 | 只做了评估，未开工 |

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
| 一个进程同时只能有一个传输 | session 单飞，第二个直接返回 `errTransferInProgress` |

---

## 2. 失效模式清单（含现状）

**P0** = 闪退或永久卡死；**P1** = 会出错但有绕过；**P2** = 隐患或工程成本。

| # | 级别 | 失效模式 | 现状 |
|---|---|---|---|
| F1 | P0 | stderr 管道被进度条撑爆 → 传输永久阻塞 | ✅ 已修（A3） |
| F2 | P0 | 没有 panic 屏障 → Go panic 直接杀死 Flutter 进程 | ✅ 已修（A2 + B3） |
| F3 | P0 | `croc.New()` 不带 ctx → PAKE 阶段的 panic 被原样抛出 | ✅ 已修（A1 改用 `NewCtx`） |
| F4 | P0 | 进度计数器无锁 → 数据竞争（`FilesHasFinished` 是 map，并发读是 fatal） | ✅ 已修（fork `v11.5.4-flcroc.1` + A9 收尾） |
| F5 | P1 | 全局单通道 → 串台 / 向 nil channel 发送导致永久阻塞 | ✅ 已修（A4 + A5） |
| F6 | P1 | `os.Chdir` 改进程工作目录，从不恢复 | ✅ 已修（A6） |
| F7 | P1 | stderr 事件用阻塞发送 → channel 满时反压到 croc | ✅ 已修（`session.emit` 用 `select/default`） |
| F8 | P2 | 同一时刻只允许一个传输，但没有拒绝第二个 | ✅ 已修（A5） |
| F9 | P2 | `transfer_id` 用 `os.Getpid()` | ✅ 已修（A7 原子自增） |
| F10 | P2 | 接收时接管 `os.Stdout`，用无上界 `bytes.Buffer` | ⬜ **还在** —— 见 §3 |
| F11 | P2 | 构建链脆弱 | 🟡 部分：A8 去掉了 `go mod tidy` 的联网改写；交叉编译 / codesign / 16KB 页仍在 |
| F12 | P2 | c-shared 与 Flutter 同进程的固有耦合 | ⬜ 结构性，是 C 档的动机 |

几条值得记住的细节：

- **F1 的量级**：进度条约 80 字节/次 × 10 次/秒 ≈ 800 B/s，单文件传 **~80 秒**就把
  `bufio.Scanner` 的 64 KiB token 上限撑爆；扫描 goroutine 退出后没人读管道，croc 下一次
  写 stderr 就永久阻塞。修法是不用 Scanner：固定缓冲 + 滑窗子串匹配（`scanNotices`）。
- **F2 里 `log.Fatalf` 比 panic 更狠**：`os.Exit(1)` 连 `recover()` 都拦不住。所以 B4
  把 `crypt.New` / `NewArgon2` 的 `log.Fatalf` 改成返回 error —— 两个函数本来就有 `err`
  返回值，改成返回是零 API 变化。
- **F10 的额外一层**：croc 的包级 `init()` 把 logger 绑到**当时的** `os.Stdout`（绕过
  bridge 的管道直写宿主 stdout）并把级别设成 debug，随后 `newClient` 里才降到 warn。

---

## 3. 还没做的

| 项 | 说明 |
|---|---|
| **F10：接收时接管 `os.Stdout`** | 文本载荷靠抓 stdout 拿到（croc 在 `SendingText` 时把正文 echo 出来）。上限 1 MiB，实际有界，但二维码 / `\r` 都可能混进正文 |
| **§5 的文本传输退化** | 见下 |
| **B5 `Options.OutputPath`** | fork 侧给输出目录，bridge 就不必 `os.Chdir`。现在 A6 用 `defer` 恢复顶着 |
| **B6 `Options.EventCallback`** | croc 主动推事件而非轮询，是终局形态，但会让 fork 与上游的 diff 显著变大 |
| **C 档 sidecar** | croc 跑成独立可执行文件，Flutter 通过 stdin/stdout JSON-Lines 或本地 socket 通信 |

### C 档的取舍（未开工）

| 维度 | 现状（c-shared） | sidecar |
|---|---|---|
| 崩溃隔离 | ❌ panic / `os.Exit` 带走 App | ✅ 只崩子进程，可重启并重报 |
| 全局状态污染 | ❌ stderr / stdout / cwd / 代理都在宿主里 | ✅ 天然隔离 |
| cgo 构建矩阵 | ❌ 4 平台 × NDK/zig/codesign/16KB 页 | ✅ 纯 Go 交叉编译 |
| Android | 已能跑（16KB 页已处理） | ⚠️ 需从 APK 释放并 `exec`，Android 10+ 有限制，要实测 |

桌面端收益明确；移动端先做"能不能 spawn + exec"的冒烟原型再决定。

### 待验证：文本传输退化成 `croc-stdin-*.txt`

已知症状：发文本，receiver 收到的是 `croc-stdin-*` 文件而不是流式文本。**还没复现定位。**

可疑点：接收端 `validateSendingTextOffer` 要求 `FolderRemote == "."` 且文件名以
`croc-stdin-` 开头，而 `GetFilesInfo` 对根层文件给的是 `FolderRemote: "./"`（带斜杠）；
是否相等取决于 `normalizeReceiveFilePath` 是否在校验**之前**跑过。

**验证成本极低**：加个 Go 单测，对 `os.CreateTemp` 出来的路径调 `GetFilesInfo`，
断言 `FolderRemote == "."`。若成立，改法是 `doSend` 里手动构造 `FileInfo` 而不走 `GetFilesInfo`。

---

## 4. 怎么证明"稳了"

**所有用例必须跑本地中继，一个包都不许打到公共中继。**
`croc.schollz.com` 对入房频率有硬限制（`--source-join-limit` / `--room-join-limit` /
`--join-limit-window`）：挂起回归那种单文件长跑、以及浸泡测试每分钟两次的循环，
会把 IP 直接限掉，看起来像 bridge 的 bug，实际是被中继拦了。那也是拿别人的公共服务
做压测，本来就不该那么跑。

`-race` 在 c-shared + Flutter 里没法直接用，所以在 `go_bridge/` 加一个纯 Go harness，
模拟 Dart 的轮询节奏（每 200ms 取一条，与 `lib_native.dart` 一致）。

### 4.1 先起一个本地中继

```bash
cd submodules/croc
go run . relay --host 127.0.0.1 --ports 9009,9010,9011,9012,9013 \
    --source-join-limit 100000 --room-join-limit 100000
```

后两项是中继**自己**的入房限流。默认值是按真人手动传文件定的，浸泡测试一轮 100MB、
每分钟两次就会把配额打光，然后被自己的中继拦下来。

### 4.2 harness 的固定选项

| 选项 | 值 | 为什么 |
|---|---|---|
| `relay_address` | `127.0.0.1:9009` | 打到 4.1 那个进程 |
| `relay_ports` | `9009,9010,9011,9012,9013` | 与中继一致 |
| `disable_local` | `true` | 不让客户端再自己起一个本地中继 —— 那会去抢 9009–9013 |
| `transport` | `relay` | 固定走中继路径，不让 auto 挑 Tailcat，结果才可复现 |

两条捷径都走不通：

- `--local`（`OnlyLocal`）要求 `transport` 必须是 `auto`（`src/cli/cli.go` 里
  `--transport must be auto for local-only transfers`），路径锁不住。
- 只给 `relay_address` 而不关 `disable_local`，客户端仍会去连公共中继
  （`!c.Options.OnlyLocal` 分支照跑），限流照样会来。

### 4.3 用例

1. **挂起回归（F1）**：传一个 ≥500MB 的单文件，断言 5 分钟内必收到 type-2 或 type-3。
   **A3 之前这条应该超时失败**。
2. **panic 回归（F2）**：先占住 9009–9013 再发送。修复前进程直接死，修复后收到
   type-3 且进程存活。**注意**：4.2 里的 `disable_local=true` 会绕开这条路径
   （`setupLocalRelay` 只在 `!DisableLocal` 时调用），所以这个用例要单独把本地中继打开。
3. **串台回归（F5）**：并发调 send + receive，断言第二次收到
   `a transfer is already in progress`，且第一次的事件不被第二次接收。
4. **竞争回归（F4）**：`go test -race` 跑一次完整收发，断言无 race。
5. **浸泡**：1 小时、每 30 秒一次的 100MB 收发循环，断言 `runtime.NumGoroutine()` 不单调增长。
