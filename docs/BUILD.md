# Building FlCroc

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.12 |
| Go | ≥ 1.25 |
| Android NDK | r27c (for Android) |

## Quick Start

```bash
git clone --recurse-submodules https://github.com/576576/FlCroc.git
cd FlCroc/fl_croc
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Platform-specific Builds

The Go bridge in `go_bridge/` builds as a CGO shared library (`.so` / `.dll` / `.dylib`) loaded via `dart:ffi`. croc source is vendored at `submodules/croc/`.

### Windows

```bash
cd go_bridge
build.bat windows amd64    # or: build.bat windows arm64
cd .. && flutter build windows --release
```

### Linux

```bash
cd go_bridge
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
./build.sh linux amd64
cd .. && flutter build linux --release
```

### macOS

```bash
cd go_bridge
./build.sh darwin amd64
cd .. && flutter build macos --release
```

### Android

```bash
cd go_bridge
build.bat android arm64    # or: build.bat android amd64
cd ..
flutter build apk --release --target-platform android-arm64
```

> ℹ️ **croc is fully vendored.** The Go FFI bridge calls croc's internal packages directly — no CLI subprocess. The shared library is bundled into every release artifact.
