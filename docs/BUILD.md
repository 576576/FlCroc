# Building FlCroc

## Build with CI/CD

Builds run **automatically on every push to `main`**, using exactly the default
targets in the table below (Windows x64 · Linux x64 · Android ARM64) and publishing
the nightly pre-release. A build can also be started by hand from
**Actions → Release → Run workflow** for any other combination. Pushes to other
branches and pull requests only run the maintenance jobs: tests, plus i18n/README
regeneration when the tracked inputs change. No commit-message keywords are
involved.

Changes that cannot affect the binaries — `docs/**`, root-level `*.md`, `LICENSE` and
`.github/ISSUE_TEMPLATE/**` — are excluded from the `push` trigger, so a docs-only push
produces **no workflow run at all** (nothing in the Actions tab, no error anywhere). Every
change under `assets/` still triggers a run: `assets/docs/` and `assets/templates/` are
inputs to the i18n renderer, so they must be re-rendered. The filter is deliberately not
applied to pull requests — they never build, and their i18n job is what validates that
`docs/i18n.md` and the READMEs are fresh.

Because a push uses the defaults, the extra targets (`windows_arm64`,
`linux_arm64`, `android_x64`, `macos_arm64`) are **never** built automatically —
dispatch a run if you want them.

| Input | Default | Effect |
|-------|---------|--------|
| `channel` | `nightly` | `nightly` publishes a pre-release — a push updates the fixed `nightly` tag, a manual run tags `r<commit-count>` · `release` cuts a `vX.Y.Z` release · `none` uploads artifacts only |
| `version` | *(from `pubspec.yaml`)* | Override the `x.y.z` part only; the `+build` number always comes from `pubspec.yaml`, where the local pre-commit hook maintains it |
| `windows_x64` | ✅ | Windows x64 — `FlCroc-x.y.z-windows-x64.zip` |
| `windows_arm64` | – | Windows ARM64 — `.zip`; the x64 package is built as an intermediate base but only published when `windows_x64` is selected too |
| `linux_x64` | ✅ | Linux x64 — `FlCroc-x.y.z-linux-x64.tar.gz` |
| `linux_arm64` | – | Linux ARM64 — `.tar.gz`; built on a native ARM64 runner |
| `android_arm64` | ✅ | Android ARM64 — `FlCroc-x.y.z-android-arm64.apk` |
| `android_x64` | – | Android x64 — `FlCroc-x.y.z-android-x64.apk` |
| `macos_arm64` | – | macOS ARM64 — `FlCroc-x.y.z-macos-arm64.zip`. ARM64 only: Flutter no longer supports Intel macOS, so there is no x64 package to pick |
| `force_docs` | – | Force-regenerate `docs/i18n.md` and all READMEs |

A `channel` other than `none` needs at least one platform selected, otherwise the
run fails early. Leaving `channel` at `nightly` while selecting a single platform
is the usual way to smoke-test one target; pick `none` to get artifacts without
creating any release at all.

> **`nightly` tags depend on how the run was started.** A push updates the fixed
> `nightly` tag, which is what the in-app updater polls (`releases/tags/nightly`); a
> manual run creates `r<commit-count>` instead — the number of commits reachable from
> `HEAD`, e.g. `r258`. That keeps every manual build as its own record and leaves the
> `nightly` slot alone. The trade-off: `r<N>` releases are visible on the GitHub
> Releases page only — neither in-app update channel (`releases/tags/nightly` and
> `releases/latest`) will find them. Both flavours stay pre-releases, so neither ever
> becomes the page's *Latest*; only `channel: release` moves that.

> **Linux ARM64** needs a native ARM64 host and bootstraps its own Flutter SDK from
> git — see [Runners and toolchain](#runners-and-toolchain) below.

> **Version numbers** — `pubspec.yaml` holds `x.y.z+N` and is the single source of
> truth. `N` is incremented by the **local pre-commit hook** on every commit
> (see [Version numbers and the pre-commit hook](#version-numbers-and-the-pre-commit-hook)),
> so the number a build reports is exactly the one recorded in the commit it was
> built from. CI never writes to `pubspec.yaml`.

> **Docs:** `docs/i18n.md` and all README files are regenerated automatically when
> `assets/bundles/`, `assets/docs/` or `assets/templates/` change — detected by
> comparing git subtree IDs against the values recorded in `docs/i18n.md`. Use the
> `force_docs` input to force it.

---

## Runners and toolchain

| Job | Runner | Build environment |
|-----|--------|-------------------|
| Windows | `windows-latest` | host |
| Linux x64 | `ubuntu-24.04` | `container: ubuntu:22.04` |
| Linux ARM64 | `ubuntu-24.04-arm` | `container: ubuntu:22.04` |
| macOS ARM64 | `macos-latest` (currently macOS 26, arm64) | host |
| Android | `ubuntu-latest` | host |

**Flutter is pinned**, not tracked from `channel: stable`. The version lives in the
`FLUTTER_VERSION` env at the top of both workflow files (`3.47.5` as of writing), so
rebuilding an old commit installs the SDK that commit was written against instead of
whatever stable happens to be current. The same variable feeds the `Flutter` badge
and the "Tech Stack" row in the READMEs: `assets/docs/*.json` carries a
`{{flutter_version}}` placeholder, which the README renderer substitutes *after* all
other content, because that text is injected via `{{stack_ui}}`.

**The Linux jobs keep a glibc 2.34 floor by compiling inside an Ubuntu 22.04
container on a 24.04 host.** What sets the floor is the `libc` the binaries are
*linked against*, not the compiler version and not the host OS. Measured on the
release artifacts:

| Binary | Highest required symbol version |
|--------|---------------------------------|
| `fl_croc` | `GLIBC_2.34` |
| `lib/libcroc_bridge.so` | `GLIBC_2.34` |
| `lib/libflutter_linux_gtk.so` | `GLIBC_2.18` |
| `lib/libapp.so` | *(none)* |

`GLIBC_2.34` is the milestone where the pthread symbols moved into libc, so any
multi-threaded program linked on a glibc ≥ 2.34 host picks it up. Building directly
on a 24.04 runner would raise the requirement to 2.39, which locks out Ubuntu 22.04
LTS (supported until 2027), Debian 12 (2.36) and RHEL 9 (2.34) — the container is
what keeps the artifacts runnable there. Each Linux job therefore ends with a
`readelf` assertion that fails the build if the highest required symbol version ever
exceeds 2.34. That guard exists because the failure mode is silent: a raised floor
only surfaces on a user's machine, as `GLIBC_2.39 not found`.

Three container specifics are handled explicitly in the workflow:

- the bare `ubuntu` image ships **no `git`**, so an `apt-get install git` step runs
  *before* `actions/checkout` — the only position from which anything can be
  installed ahead of checkout;
- it has **no `sudo`** (the container runs as root), so `apt-get` is called directly;
- container jobs default to the **`sh`** shell, so the job sets
  `defaults.run.shell: bash` — the scripts use `pipefail` and `${VAR%%+*}`.

The dependency list is also longer than on a hosted runner, which pre-installs a
whole toolchain: `build-essential` supplies the `gcc` that the Go bridge's CGO build
needs plus the libstdc++ headers Flutter's C++ sources need, and `curl` / `unzip` /
`xz-utils` / `file` / `binutils` are used by the Flutter tool and by the artifact
checks.

**Linux ARM64 needs a native ARM64 host.** Flutter refuses to cross-build Linux
arm64 from an x64 host (`build_linux.dart`), and its release manifest publishes no
arm64 Linux SDK archive at all — `releases_linux.json` only ever carries
`dart_sdk_arch: x64` — so `subosito/flutter-action` cannot be used there. Instead the
job shallow-clones the Flutter git tag named by `FLUTTER_VERSION` and lets
`bin/flutter` fetch the arm64 engine and `dart-sdk-linux-arm64.zip` itself. The clone
is pinned to a tag rather than `-b stable` because `git describe` has to see the tag
locally to report a framework version; otherwise `flutter --version` prints
`0.0.0-unknown`.

**macOS ARM64** uses `macos-latest`, currently macOS 26 on arm64. The job asserts
with `lipo` that both the app binary and the bridge dylib are `arm64`, so if the
`-latest` label were ever pointed at an Intel image the build would fail instead of
quietly shipping the wrong architecture. No signing identity is configured anywhere:
the project sets `CODE_SIGN_IDENTITY = "-"`, so Xcode ad-hoc signs the app. That is
enough to produce a runnable app — but not a *notarized* one, so see
[macOS](#macos-1) for what users have to do on first launch.

---

## Build Locally

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | 3.47.5 (matches `FLUTTER_VERSION` in the workflows) |
| Go | ≥ 1.27 (`go_bridge/go.mod` requires 1.27.0; CI pins 1.27.1) |
| Xcode + CocoaPods | for macOS builds |
| Android NDK | r27c (for Android) |

### Quick Start

```bash
git clone --recurse-submodules https://github.com/576576/FlCroc.git
cd FlCroc
git config core.hooksPath .githooks    # enable the build-number pre-commit hook
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Version numbers and the pre-commit hook

`pubspec.yaml` carries `version: x.y.z+N` and is the single source of truth for both
the app version and the build number. The bump lives in a **pre-commit hook** rather
than in CI, so the number in the file is always the number of the commit it sits in —
no bot commits, no `[skip ci]` gymnastics, and a release artifact maps to a plain
source commit.

Enable it once per clone:

```bash
git config core.hooksPath .githooks
```

Then every `git commit` rewrites `version: x.y.z+N` to `x.y.z+(N+1)` and re-stages
`pubspec.yaml`. Things worth knowing:

| Situation | Behaviour |
|-----------|-----------|
| Plain commit | Bumps and stages `pubspec.yaml` alongside your changes |
| You changed `x.y.z` by hand | The new `x.y.z` is kept; `N` is bumped from whatever you staged (a bare `1.3.0` becomes `1.3.0+1`) |
| `FL_CROC_NO_BUMP=1 git commit` | Skips the bump for this commit |
| `git rebase` / `git merge` / `cherry-pick` | Hook stays out of the way — git's sequencer owns those commits |
| `git commit --amend` | Bumps **again** (git does not tell hooks this is an amend); use `--amend --no-verify` when you need an exact number |
| Merging branches that both bumped | `pubspec.yaml`'s version line conflicts — resolve by keeping the larger `N` |

> The hook is a local convenience, not an enforcement point: a machine that never ran
> `git config core.hooksPath .githooks`, or a commit made with `--no-verify`, leaves
> the number unchanged. That is harmless for a normal build, but a `nightly` whose
> build number does not advance will not be offered by the in-app updater, which
> compares build numbers.

### Platform-specific Builds

The Go bridge in `go_bridge/` builds as a CGO shared library (`.so` / `.dll` / `.dylib`) loaded via `dart:ffi`. croc source is vendored at `submodules/croc/`.

#### Windows

```bash
cd go_bridge
build.bat windows amd64    # or: build.bat windows arm64
cd .. && flutter build windows --release
cp windows/runner/libcroc_bridge.dll build/windows/x64/runner/Release/
```

`build.bat` is the Windows-native path and resolves the compiler toolchain itself. The
`copy` is not optional: nothing in `windows/` references the DLL, so `flutter build windows`
neither builds nor bundles it, and the app fails to start without it. CI copies it in a
dedicated step for the same reason.

Building Windows from `build.sh` (Linux/macOS/Git Bash) is possible — it auto-detects `zig`
and cross-compiles — but `build.bat` is less trouble on a Windows host.

#### Linux

Build dependencies (Debian/Ubuntu):

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

`build.sh` takes a platform and an arch (`linux` / `macos` / `android` / `windows`, times
`amd64` / `arm64`), writes the bridge to `build/<platform>/`, and stages it where Flutter
expects to find it:

```bash
cd go_bridge
./build.sh linux amd64        # stages linux/flutter/ephemeral/libcroc_bridge.so
cd .. && flutter build linux --release
cp linux/flutter/ephemeral/libcroc_bridge.so build/linux/x64/release/bundle/lib/
```

The `cp` must come **after** `flutter build`: the bundle directory is deleted and
regenerated on every build, so anything placed there beforehand is thrown away. CI performs
the same copy, and `--target-platform linux-x64` in the workflow is only there to fail
loudly on a non-x64 host instead of silently emitting the wrong arch. Substitute `arm64`
for `x64` in the bundle path when you built the arm64 bridge.

`build.sh` is committed with the executable bit, but `bash build.sh linux amd64` works too
if your checkout lost it.

#### macOS

macOS is **ARM64-only** — Flutter no longer supports Intel macOS, and its release
manifest stopped publishing x64 archives for the platform.

`build.sh` and `build.bat` share one contract: croc always comes from the pinned
`submodules/croc`, and neither script clones it nor rewrites `go_bridge/go.mod`. `build.sh`
is the shorter path here, since it stages the dylib into `macos/Runner/` for you:

```bash
cd go_bridge
./build.sh macos arm64
cd .. && flutter build macos --release
```

The equivalent by hand, if you would rather see every flag:

```bash
cd go_bridge
CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 \
  go build -buildmode=c-shared -ldflags="-s -w" -o ../macos/Runner/libcroc_bridge.dylib .
cd .. && flutter build macos --release
```

`macos/Podfile` is not in the repository: `flutter build macos` generates it from the
SDK's `Podfile-macos` template the first time plugins need CocoaPods (see
`CocoaPods.setupPodfile` in `flutter_tools`).

The Flutter build does **not** bundle the dylib by itself — `macos/Runner/` is not
part of any copy phase in the Xcode project. Copy it into the bundle afterwards and
re-sign, since touching the bundle invalidates Xcode's signature:

```bash
APP="build/macos/Build/Products/Release/fl_croc.app"
cp macos/Runner/libcroc_bridge.dylib "$APP/Contents/Frameworks/"
codesign --force --sign - "$APP/Contents/Frameworks/libcroc_bridge.dylib"
codesign --force --sign - --entitlements macos/Runner/Release.entitlements "$APP"
```

`Contents/Frameworks/` is where the dylib belongs: it is the target of the bundle's
`@executable_path/../Frameworks` rpath and the nested-code location `codesign` seals
properly. `lib/core/lib_native.dart` looks in the executable directory first, then
`Contents/Frameworks`, then `lib/`.

`--entitlements` must be passed explicitly — a bare `codesign --force` drops every
entitlement the project configures, sandbox included. `Release.entitlements` needs
more than Flutter's template ships:

| Entitlement | Why |
|-------------|-----|
| `com.apple.security.network.client` | Outbound sockets. **Flutter's template omits this**, and a sandboxed app without it cannot reach the relay or a peer at all |
| `com.apple.security.network.server` | croc binds a listener for LAN transfers |
| `com.apple.security.files.user-selected.read-write` | Picking files to send and picking a destination folder (`file_picker`) |
| `com.apple.security.files.downloads.read-write` | The default save path is the system Downloads folder (`AppPaths.getDefaultSavePath`) |

Finally, package with `ditto`, never `zip`:

```bash
ditto -c -k --sequesterRsrc --keepParent "$APP" FlCroc-<version>-macos-arm64.zip
```

`zip -r` flattens the symlinks inside the embedded frameworks, which produces a
broken bundle.

**First launch.** The package is ad-hoc signed and not notarized, so Gatekeeper
refuses it with *"Apple could not verify … is free of malware"*. Users open it once
via **right-click → Open**, or clear the quarantine flag:

```bash
xattr -dr com.apple.quarantine /Applications/fl_croc.app
```

#### Android

```bash
cd go_bridge
build.bat android arm64    # or: build.bat android amd64
cd ..
flutter build apk --release --target-platform android-arm64
```

Both scripts map Go's `amd64` onto Android's `x86_64` ABI, so the bridge lands in
`android/app/src/main/jniLibs/x86_64/` while the Go flag still reads `GOARCH=amd64`. Gradle
picks `jniLibs/` up on its own — but it has to be there **before** `flutter build apk`, since
the APK is assembled from what is already on disk. Use `--target-platform android-x64` for
the x64 build.

The NDK compiler is chosen from `ANDROID_NDK_HOME` (CI uses r27c). On Apple Silicon the host
tag is still `darwin-x86_64`: the NDK ships no arm64 host binaries, and Rosetta covers it.

> ℹ️ **croc is fully vendored.** The Go FFI bridge calls croc's internal packages directly — no CLI subprocess. The shared library is bundled into every release artifact.
