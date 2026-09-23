# 上游 PR 草稿：导出一个带锁的传输进度访问器

> **这份文件是 FlCroc 内部的 PR 草稿**，不是最终文档。下面从「PR 正文」开始的部分是
> 准备直接贴到 `schollz/croc` 的英文内容，可以整段复制。
>
> **背景**：FlCroc 的 Go bridge 以 `-buildmode=c-shared` 编进 Flutter 桌面/移动端进程，
> 需要一个 200ms 的 ticker 去读传输进度来驱动进度条。croc 把进度字段直接导出在
> `croc.Client` 上（`TotalSent`、`FilesToTransferCurrentNum`…），但它们的锁既不导出、
> 又覆盖不全（详见正文的写入点表格），宿主进程没法自行同步，只能靠 `recover()` 兜底。
> 最要命的是 `FilesHasFinished` 是 `map`：并发读会触发 Go 的 **fatal error**，
> **不可 recover**，直接带走整个 Flutter 进程。
>
> **对 FlCroc 的影响**：`go_bridge/main.go` 的 `progressSampler` 目前刻意不读
> `FilesHasFinished`，并用 `recover()` 包住切片读取（见 `AGENTS.md`
> 「Live Transfer Progress」一节）。这份 PR 若被接受，bridge 就能去掉这些绕行，
> 用一行 `c.ProgressSnapshot()` 拿到一致快照。
>
> **本仓库内的相关改动**：`6ddba53`（真实进度）、`docs/croc-v11-feature-audit.md`
> 第五节的「注意并发」段。
>
> **上游仓库**：https://github.com/schollz/croc
> **基线**：v11.5.2（`src/croc/croc.go`）

---

## PR 正文（可直接提交）

### Title

```
croc: add a race-free ProgressSnapshot accessor for the exported transfer counters
```

### Summary

`croc.Client` exports the fields an embedder needs to render a progress bar
(`TotalSent`, `TotalChunksTransferred`, `FilesToTransferCurrentNum`,
`TotalNumberOfContents`, `FilesToTransfer`, `FilesHasFinished`,
`numberOfTransferredFiles`, `numberOfUnchangedFiles`), but the synchronisation
around them is inconsistent and entirely private. The CLI never notices because
`progressbar` is fed through the locked `addProgress()` helper. Any *external*
consumer — a library user, or a `-buildmode=c-shared` host such as a GUI — has
to read the raw fields from another goroutine, and that is a genuine data race
with one unrecoverable case.

This PR adds `(*Client).ProgressSnapshot()`, which returns a consistent copy
under a new `progressMu`, and routes the writers through it. It follows the
pattern already used in the same package by `lifecycleSnapshot()`
(`src/croc/client_state.go:20`) and `connectionsSnapshot()`
(`src/croc/client_state.go:123`).

### Problem

The writers are spread across the transfer loops, and — this is the crux —
they use **two different private mutexes, or none at all**:

| Field | Written at | Guarded by |
|---|---|---|
| `TotalSent` | `croc.go:3811` (send, `+= n`) | `c.mutex` |
| `TotalSent` | `croc.go:3670` (receive, `+= len(data[8:])`) | `c.receiveMutex` |
| `TotalSent` | `croc.go:775`, `:3519` (reset to 0) | **none** |
| `TotalSent` | `croc.go:3199` (reset to 0) | `c.receiveMutex` |
| `TotalChunksTransferred` | `croc.go:3671` (`++`) | `c.receiveMutex` |
| `TotalChunksTransferred` | `croc.go:776` (reset) | **none** |
| `TotalChunksTransferred` | `croc.go:3200` (reset) | `c.receiveMutex` |
| `FilesToTransferCurrentNum` | `croc.go:2995`, `:3456` | **none** |
| `TotalNumberOfContents` | `croc.go:1779`, `:2471` | **none** |
| `FilesToTransfer` | `croc.go:1280`, `:1780` | **none** |
| `FilesHasFinished` | `croc.go:3189` (map insert) | **none** |
| `numberOfTransferredFiles` | `croc.go:3439`, `:3457` | **none** |
| `numberOfUnchangedFiles` | `croc.go:3444` | **none** |

So there are two separate problems:

1. **The locks are private, and there are two of them.** `mutex` and
   `receiveMutex` are unexported and cover different fields — `TotalSent` on the
   send path is protected by one, on the receive path by the other. An embedder
   has no way to synchronise with the writers at all, not even by "taking the
   same lock".
2. **Most of the fields are not protected by anything.** `FilesHasFinished` is
   inserted (`:3189`) and read (`:3364`) with no lock held at all; the same goes
   for `FilesToTransfer`, `FilesToTransferCurrentNum`,
   `numberOfTransferredFiles` and `numberOfUnchangedFiles`.

A reader polling these every 200 ms races with all of them. The consequences
differ per type:

- `int64` / `int` reads: torn values are impossible on the supported
  architectures, so the practical symptom is a stale or skipped sample. Still a
  race as far as `go test -race` is concerned.
- Slice header reads (`FilesToTransfer`): can observe a torn
  `(ptr, len, cap)`, which panics with "slice bounds out of range" — recoverable,
  but only if the caller remembers to wrap every read.
- **`map` reads (`FilesHasFinished`): a concurrent read of a map being written
  is a *fatal error*, not a panic.** `runtime.throw("concurrent map read and map
  write")` cannot be recovered; in a `c-shared` build it terminates the host
  process. This is the one that actually breaks embedders — and it is
  unavoidable today, because `FilesHasFinished` is exactly the field you need
  to compute "how many files are done".

The existing locked helpers (`lifecycleSnapshot`, `connectionsSnapshot`,
`addProgress`) show the intent is already there; it just stops short of the
progress counters.

### Minimal repro

```go
// Run with: go test -race -run TestProgressSnapshotRace ./src/croc/
func TestProgressSnapshotRace(t *testing.T) {
	relay := startTestRelay(t, 4)
	// ... build sender/receiver exactly like TestCrocRenameExistingFile ...

	stop := make(chan struct{})
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		for {
			select {
			case <-stop:
				return
			default:
			}
			// What an embedder has to do today.
			_ = sender.TotalSent
			_ = sender.FilesToTransferCurrentNum
			_ = len(sender.FilesToTransfer)
			_ = len(sender.FilesHasFinished) // <- concurrent map read
		}
	}()

	go sender.Send(filesInfo, emptyFolders, totalNumberFolders)
	go receiver.Receive()

	// ... wait for completion ...
	close(stop)
	wg.Wait()
}
```

Observed today: `-race` reports races on every field, and the
`len(sender.FilesHasFinished)` read can abort the test binary with
`fatal error: concurrent map read and map write`.

### Proposed API

```go
// src/croc/progress.go

// TransferProgressSnapshot is a consistent, race-free view of an in-flight
// transfer. The zero value means "no transfer has started yet".
//
// It is safe to call from any goroutine at any point during Send()/Receive().
type TransferProgressSnapshot struct {
	// TotalSent is the number of bytes moved for the file currently in flight.
	// It resets to zero when croc moves on to the next file, so use
	// TransferredBytes() for a whole-transfer figure.
	TotalSent int64

	// TotalChunksTransferred is the number of chunks moved for the file
	// currently in flight. Like TotalSent, it is per-file.
	TotalChunksTransferred int

	// CurrentFileIndex is the index of the file in flight, or -1 when the
	// manifest is not known yet.
	CurrentFileIndex int

	// TotalNumberOfContents is the number of entries in the manifest.
	TotalNumberOfContents int

	// FilesToTransfer is a copy of the manifest. Callers may keep it.
	FilesToTransfer []FileInfo

	// FilesFinished is the number of manifest entries that have finished.
	// It is derived from the internal bookkeeping, so unlike the
	// FilesHasFinished map it is safe to read from any goroutine.
	FilesFinished int

	// FilesUnchanged is the number of files skipped because their hash already
	// matched the destination.
	FilesUnchanged int

	// Lifecycle is the (already locked) step flags, mirrored here so a caller
	// needs a single call to render a status line.
	Lifecycle TransferLifecycle
}

// TransferredBytes returns the cumulative byte count for the whole transfer:
// the sizes of the finished files plus TotalSent for the file in flight.
func (s TransferProgressSnapshot) TransferredBytes() int64 {
	var done int64
	for i := 0; i < s.CurrentFileIndex && i < len(s.FilesToTransfer); i++ {
		done += s.FilesToTransfer[i].Size
	}
	return done + s.TotalSent
}

// ProgressSnapshot returns a consistent view of the current transfer.
func (c *Client) ProgressSnapshot() TransferProgressSnapshot { /* locked copy */ }
```

`TransferLifecycle` is the exported twin of the unexported `transferLifecycle`
(`client_state.go:11`), so embedders can render "reconnecting / hashing /
waiting for recipient" without reaching into `Step1..Step5` individually.

### Patch sketch

```diff
 type Client struct {
 	// steps involved in forming relationship
 	lifecycleMu               sync.RWMutex
 	Step1ChannelSecured       bool
 	...
+	// progressMu guards the exported progress counters below. They are read
+	// from arbitrary goroutines by embedders, so writes must go through
+	// setProgress/updateProgress.
+	progressMu                sync.RWMutex
 	// send / receive information of all files
 	FilesToTransfer           []FileInfo
```

```go
// src/croc/progress.go

func (c *Client) ProgressSnapshot() TransferProgressSnapshot {
	c.progressMu.RLock()
	defer c.progressMu.RUnlock()
	snapshot := TransferProgressSnapshot{
		TotalSent:              c.TotalSent,
		TotalChunksTransferred: c.TotalChunksTransferred,
		CurrentFileIndex:       c.FilesToTransferCurrentNum,
		TotalNumberOfContents:  c.TotalNumberOfContents,
		FilesToTransfer:        append([]FileInfo(nil), c.FilesToTransfer...),
		FilesFinished:          len(c.FilesHasFinished),
		FilesUnchanged:         c.numberOfUnchangedFiles,
	}
	snapshot.Lifecycle = c.lifecycleSnapshot()
	return snapshot
}

// addSent records bytes moved for the file in flight.
func (c *Client) addSent(n int64) {
	c.progressMu.Lock()
	c.TotalSent += n
	c.TotalChunksTransferred++
	c.progressMu.Unlock()
}
```

then at each write site listed above, e.g.

```diff
-			c.mutex.Lock()
-			c.TotalSent += int64(n)
-			c.mutex.Unlock()
+			c.addSent(int64(n))
```

and the reset sites collapse into a `resetFileProgress()` helper. The two
existing private locks (`mutex` for send, `receiveMutex` for receive) can then
be dropped from the progress paths entirely — `progressMu` subsumes them for
these fields, and keeping one lock per field group is easier to reason about
than two locks with overlapping coverage.

### Backward compatibility

- Purely additive: no existing exported symbol changes shape.
- The exported fields stay exported (removing them would break embedders that
  already read them). They become documented as "read via `ProgressSnapshot()`;
  direct reads are racy".
- `FileInfo` is already exported and JSON-serializable, so copying the manifest
  is cheap and safe.

### Alternatives considered

1. **Document the fields as internal and stop exporting them.** Rejected: it is
   a breaking change for anyone already doing this, and the fields are genuinely
   useful.
2. **Use `atomic.Int64` for the counters.** Works for `TotalSent` /
   `TotalChunksTransferred`, but does not help the `map` and slice fields, and
   changes the field types (breaking). A `RWMutex` covers all of them with one
   mechanism and matches the existing house style.
3. **Tell embedders to pass a custom `progressbar` via `addProgress`.** Not
   viable: `addProgress` is unexported and only reports a delta, with no
   per-file or manifest context.

### Test plan

- New `TestProgressSnapshotRace`: the repro above, run under `-race`; asserts no
  races and that `TransferredBytes()` is monotonically non-decreasing.
- New `TestProgressSnapshotBeforeStart`: `ProgressSnapshot()` on a fresh client
  returns the zero value with `CurrentFileIndex == -1`.
- Existing suite (`go test -race ./src/croc/`) stays green — the diff only
  introduces lock acquisitions around field access.

### Checklist

- [ ] `go test -race ./src/croc/` passes
- [ ] `gofmt` / `go vet` clean
- [ ] No changes to the wire protocol
- [ ] CHANGELOG / README note added if the maintainer wants one

---

## 提交前要确认的事（FlCroc 内部）

1. **先确认上游有没有已经在做的相关改动。** 搜一下 issue / PR 里有没有
   「concurrent map read and map write」「export lifecycleSnapshot」之类的讨论，
   避免重复劳动。
2. **确认命名偏好。** 上游用的是 `xxxSnapshot()` 的命名（`lifecycleSnapshot`、
   `connectionsSnapshot`），`ProgressSnapshot()` 是顺着来的；如果维护者更想要
   `Snapshot()` 或 `TransferStatus()`，改起来是纯改名。
3. **锁粒度要跟维护者对齐。** 现在方案是「新增一把 `progressMu` 管所有进度字段，
   并把原来分散在 `c.mutex` / `c.receiveMutex` 上的进度写入统一收进来」。
   另一种更保守的做法是复用现有的 `receiveMutex`（但发送路径用的是 `mutex`，
   两个锁覆盖的字段不同，直接复用会顾此失彼）。如果维护者担心传输热路径上的锁
   竞争（发送端每块数据一次 `addSent`），可以退一步：只锁 `FilesHasFinished` 和
   `FilesToTransfer`（真正会崩/撕裂的那两个），`TotalSent` / `TotalChunksTransferred`
   改成 `atomic.Int64` / `atomic.Int64`。
4. **说清「私有锁」这件事。** 现状不是「完全没锁」，而是「用了两把不导出、且彼此
   不覆盖同一组字段的锁，外加若干字段完全裸奔」。这点如果表述含糊，容易被维护者
   以「已经有锁了」驳回。
5. **不要顺手带 FlCroc 特有的东西进 PR。** 比如 `normalizeThrottle()` 那类
   「防 croc panic」的防御代码是宿主侧的责任，不属于上游。
6. **如果要同时提「导出 `peerToPeerDataPath()`」**（审计 P2-10：透出
   「直连 / 中继」标识），建议拆成第二个 PR，两个改动关注点不同。
