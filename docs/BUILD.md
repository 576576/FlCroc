# Building FlCroc

## Build with CI/CD

Push to `main`/`master`/`dev` with a commit message containing one of the triggers below.
GitHub Actions will build and upload artifacts automatically.

| Commit Message Tag | Builds |
|--------------------|--------|
| `b-all` | Main builds — Windows (amd64), Linux (amd64), Android (arm64) |
| `b-win` | Windows (amd64) |
| `b-linux` | Linux (amd64) |
| `b-mobile` | Android (arm64) |
| `b-none` | Skip all builds (only prebuild) |
| `b-doc` | Force regenerate `docs/i18n.md` and all READMEs |
| `arch-all` | Include secondary architectures — Windows (arm64), Android (amd64). Only works when main architecture enabled. |

Combine with other triggers:

| Additional Tag | Effect |
|----------------|--------|
| `r-1.2.3` / `release-1.2.3` | Production release |
| `beta-1.2.3` | Beta release |

> **Note:** `docs/i18n.md` and all README files are regenerated automatically when `assets/bundles/` or `assets/docs/` change — detected via hash comparison. No tag required.

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
