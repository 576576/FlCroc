# Building FlCroc

## Build with CI/CD

Builds are started by hand from **Actions → Release → Run workflow**. Pushes and
pull requests only run the maintenance jobs: tests, plus i18n/README
regeneration when the tracked inputs change. No commit-message keywords are
involved.

| Input | Default | Effect |
|-------|---------|--------|
| `channel` | `nightly` | `nightly` rebuilds the nightly pre-release · `release` cuts a `vX.Y.Z` release · `none` uploads artifacts only |
| `version` | *(from `pubspec.yaml`)* | Override the `x.y.z` part; the `+build` number still increments |
| `windows_amd64` | ✅ | Windows x64 |
| `windows_arm64` | – | Windows ARM64 — repacked over the x64 package, so x64 is added automatically |
| `linux_amd64` | ✅ | Linux x64 |
| `android_arm64` | ✅ | Android ARM64 |
| `android_amd64` | – | Android x64 |
| `force_docs` | – | Force-regenerate `docs/i18n.md` and all READMEs |

A `channel` other than `none` needs at least one platform selected, otherwise the
run fails early. Leaving `channel` at `nightly` while selecting a single platform
is the usual way to smoke-test one target; pick `none` to get artifacts without
touching the published release.

> **Version numbers** — `pubspec.yaml` holds `x.y.z+N` and is the single source of
> truth. When packaging from a branch, `N` is incremented by 1 and committed back
> to that branch, so the workflow row is the record of what was built.

> **Docs:** `docs/i18n.md` and all README files are regenerated automatically when
> `assets/bundles/`, `assets/docs/` or `assets/templates/` change — detected by
> comparing git subtree IDs against the values recorded in `docs/i18n.md`. Use the
> `force_docs` input to force it.

---

## Build Locally

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.12 |
| Go | ≥ 1.25 |
| Android NDK | r27c (for Android) |

### Quick Start

```bash
git clone --recurse-submodules https://github.com/576576/FlCroc.git
cd FlCroc/fl_croc
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Platform-specific Builds

The Go bridge in `go_bridge/` builds as a CGO shared library (`.so` / `.dll` / `.dylib`) loaded via `dart:ffi`. croc source is vendored at `submodules/croc/`.

#### Windows

```bash
cd go_bridge
build.bat windows amd64    # or: build.bat windows arm64
cd .. && flutter build windows --release
```

#### Linux

```bash
cd go_bridge
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
./build.sh linux amd64
cd .. && flutter build linux --release
```

#### macOS

```bash
cd go_bridge
./build.sh darwin amd64
cd .. && flutter build macos --release
```

#### Android

```bash
cd go_bridge
build.bat android arm64    # or: build.bat android amd64
cd ..
flutter build apk --release --target-platform android-arm64
```

> ℹ️ **croc is fully vendored.** The Go FFI bridge calls croc's internal packages directly — no CLI subprocess. The shared library is bundled into every release artifact.
