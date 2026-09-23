#!/usr/bin/env bash
set -euo pipefail
# ============================================================
#  FlCroc Go Bridge Build Script (Linux/macOS)
#
#  Usage: ./build.sh [platform] [arch]
#    platform: linux (default), macos, android, windows
#    arch:     amd64 (default), arm64
#
#  croc always comes from ../submodules/croc: the pinned submodule revision is the
#  single source of truth. This script never clones croc and never rewrites go.mod —
#  same contract as go_bridge/build.bat. To try a different croc, point go.mod's
#  replace directive at it yourself.
#
#  On Windows prefer build.bat: it resolves the NDK and the native toolchain itself.
# ============================================================

PLATFORM="${1:-linux}"
ARCH="${2:-amd64}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CROC_SRC="${REPO_ROOT}/submodules/croc"
OUTPUT_DIR="${REPO_ROOT}/build/${PLATFORM}"

ANDROID_ABI=""
FLUTTER_ARCH=""

echo "========================================"
echo " FlCroc Go Bridge Builder"
echo " Platform: ${PLATFORM}  Arch: ${ARCH}"
echo "========================================"

# --- Check Go ---
if ! command -v go >/dev/null 2>&1; then
    echo "[ERROR] Go is not installed. Install Go 1.27+ (https://go.dev/dl/)"
    exit 1
fi
echo "[OK] Go: $(go version)"

# --- Check the vendored croc ---
echo ""
echo "[STEP 1/4] Checking croc submodule..."
if [ ! -f "${CROC_SRC}/go.mod" ]; then
    echo "[ERROR] croc submodule missing at ${CROC_SRC}"
    echo "        Run: git submodule update --init --recursive"
    exit 1
fi
CROC_VER="$(git -C "${CROC_SRC}" describe --tags --abbrev=0 2>/dev/null || true)"
CROC_VER="${CROC_VER#v}"
if [ -z "${CROC_VER}" ]; then
    # 回退到 croc 自己的版本文件，与 Go 桥报告的 version.Value 是同一个值。
    CROC_VER="$(sed -n 's/.*Value = "\(.*\)"/\1/p' "${CROC_SRC}/src/version/version.go" 2>/dev/null | head -1 || true)"
fi
echo "[OK] croc ${CROC_VER:-unknown} (vendored; the submodule revision is authoritative)"

# --- Platform + arch config (validate before touching the module) ---
echo ""
echo "[STEP 2/4] Resolving ${PLATFORM}/${ARCH}..."
export CGO_ENABLED=1

case "${ARCH}" in
    amd64) export GOARCH=amd64 ;;
    arm64) export GOARCH=arm64 ;;
    *) echo "[ERROR] Unknown arch: ${ARCH} (use amd64 or arm64)"; exit 1 ;;
esac

case "${PLATFORM}" in
    linux)
        export GOOS=linux
        EXT=".so"; OUT_NAME="libcroc_bridge.so"
        ;;
    macos|darwin)
        export GOOS=darwin
        EXT=".dylib"; OUT_NAME="libcroc_bridge.dylib"
        ;;
    windows)
        export GOOS=windows
        EXT=".dll"; OUT_NAME="libcroc_bridge.dll"
        # 交叉编译要有面向 Windows 的 C 编译器；没有就明确报错，别让链接器
        # 抛一句看不懂的话。有 zig 就自动用上（CI 的 arm64 路径也是这么做的）。
        if [ -z "${CC:-}" ] && command -v zig >/dev/null 2>&1; then
            if [ "${GOARCH}" = "arm64" ]; then
                ZIG_TARGET="aarch64-windows-gnu"
            else
                ZIG_TARGET="x86_64-windows-gnu"
            fi
            export CC="zig cc -target ${ZIG_TARGET}"
            export CXX="zig c++ -target ${ZIG_TARGET}"
            echo "[OK] zig found — cross-compiling via ${ZIG_TARGET}"
        fi
        if [ -z "${CC:-}" ]; then
            echo "[ERROR] Cross-building for Windows needs a Windows-targeting C compiler."
            echo "        Install zig (auto-detected), or set CC/CXX yourself,"
            echo "        or run build.bat on a Windows host."
            exit 1
        fi
        ;;
    android)
        export GOOS=android
        EXT=".so"; OUT_NAME="libcroc_bridge.so"
        case "${GOARCH}" in
            arm64) ANDROID_TARGET="aarch64-linux-android21"; ANDROID_ABI="arm64-v8a" ;;
            amd64) ANDROID_TARGET="x86_64-linux-android21";  ANDROID_ABI="x86_64" ;;
        esac
        if [ -z "${ANDROID_NDK_HOME:-}" ]; then
            ANDROID_NDK_HOME="$(ls -d "${HOME}/Android/Sdk/ndk/"*/ 2>/dev/null | sort -r | tail -1 || true)"
        fi
        if [ ! -d "${ANDROID_NDK_HOME:-}" ]; then
            echo "[ERROR] Android NDK not found. Set ANDROID_NDK_HOME (CI uses r27c)."
            exit 1
        fi
        # NDK 只为 macOS 提供 x86_64 宿主机二进制，Apple Silicon 上同样用这个 tag。
        HOST_TAG="linux-x86_64"
        if [ "$(uname)" = "Darwin" ]; then
            HOST_TAG="darwin-x86_64"
        fi
        export CC="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_TAG}/bin/${ANDROID_TARGET}-clang"
        if [ ! -x "${CC}" ]; then
            echo "[ERROR] NDK compiler not found: ${CC}"
            echo "        Check ANDROID_NDK_HOME (host tag ${HOST_TAG})."
            exit 1
        fi
        ;;
    *)
        echo "[ERROR] Unknown platform: ${PLATFORM} (use linux, macos, android or windows)"
        exit 1
        ;;
esac

if [ "${PLATFORM}" = "linux" ] || [ "${PLATFORM}" = "macos" ] || [ "${PLATFORM}" = "darwin" ]; then
    if [ "${GOARCH}" = "amd64" ]; then
        FLUTTER_ARCH="x64"
    else
        FLUTTER_ARCH="arm64"
    fi
fi

LDFLAGS="-s -w"
case "${PLATFORM}" in
    # -H windowsgui 只作用于 Go 链接器自己那一步；CGO 下真正链接的是外部编译器，
    # 它的默认子系统是 console，所以必须再给 extldflags 一份，否则会闪出一个控制台窗口。
    windows) LDFLAGS="${LDFLAGS} -H windowsgui -extldflags=-Wl,--subsystem,windows" ;;
    # Android 15 起 16 KB 页是硬要求，4 KB 对齐的 .so 会在新设备上直接加载失败。
    android) LDFLAGS="${LDFLAGS} -extldflags=-Wl,-z,max-page-size=16384" ;;
esac

# --- Prepare the Go module and build ---
echo ""
echo "[STEP 3/4] Preparing Go module and building..."
cd "${SCRIPT_DIR}"
go mod tidy
mkdir -p "${OUTPUT_DIR}"
go build -buildmode=c-shared -o "${OUTPUT_DIR}/${OUT_NAME}" -ldflags="${LDFLAGS}" .
echo "[OK] Built"

# --- Stage next to the Flutter platform ---
echo ""
echo "[STEP 4/4] Staging for Flutter..."
case "${PLATFORM}" in
    linux)
        mkdir -p "${REPO_ROOT}/linux/flutter/ephemeral"
        cp "${OUTPUT_DIR}/${OUT_NAME}" "${REPO_ROOT}/linux/flutter/ephemeral/"
        echo "[OK] Staged -> linux/flutter/ephemeral/${OUT_NAME}"
        ;;
    macos|darwin)
        mkdir -p "${REPO_ROOT}/macos/Runner"
        cp "${OUTPUT_DIR}/${OUT_NAME}" "${REPO_ROOT}/macos/Runner/"
        echo "[OK] Staged -> macos/Runner/${OUT_NAME}"
        ;;
    windows)
        mkdir -p "${REPO_ROOT}/windows/runner"
        cp "${OUTPUT_DIR}/${OUT_NAME}" "${REPO_ROOT}/windows/runner/"
        echo "[OK] Staged -> windows/runner/${OUT_NAME}"
        ;;
    android)
        mkdir -p "${REPO_ROOT}/android/app/src/main/jniLibs/${ANDROID_ABI}"
        cp "${OUTPUT_DIR}/${OUT_NAME}" "${REPO_ROOT}/android/app/src/main/jniLibs/${ANDROID_ABI}/"
        echo "[OK] Staged -> android/app/src/main/jniLibs/${ANDROID_ABI}/${OUT_NAME}"
        ;;
esac

echo ""
echo "========================================"
echo " Build SUCCESS!"
echo " Output: ${OUTPUT_DIR}/${OUT_NAME}"
echo "========================================"

# 把库拷进发布包必须排在 `flutter build` **之后**：Linux 的 bundle 每次构建都会被
# 整个删掉重建，macOS 的 .app 也要重新签名。所以这里只打印下一步，不代劳。
case "${PLATFORM}" in
    linux)
        echo ""
        echo "Next — build the app first, then copy the bridge into the bundle:"
        echo "  flutter build linux --release"
        echo "  cp linux/flutter/ephemeral/${OUT_NAME} build/linux/${FLUTTER_ARCH}/release/bundle/lib/"
        ;;
    macos|darwin)
        echo ""
        echo "Next — copy the dylib into the bundle and re-sign (see docs/BUILD.md § macOS):"
        echo "  flutter build macos --release"
        echo "  APP=build/macos/Build/Products/Release/fl_croc.app"
        echo "  cp macos/Runner/${OUT_NAME} \"\$APP/Contents/Frameworks/\""
        echo "  codesign --force --sign - \"\$APP/Contents/Frameworks/${OUT_NAME}\""
        echo "  codesign --force --sign - --entitlements macos/Runner/Release.entitlements \"\$APP\""
        ;;
esac
