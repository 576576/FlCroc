#!/usr/bin/env bash
set -euo pipefail
# ============================================================
#  FlCroc Go Bridge Build Script (Linux / macOS)
#  Dynamically downloads croc dependency and builds the shared
#  library for the specified target platform.
#
#  Usage: ./build.sh [platform] [arch]
#    platform: linux (default), macos, android, windows
#    arch:     amd64 (default), arm64, arm
# ============================================================

PLATFORM="${1:-linux}"
ARCH="${2:-amd64}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../build/${PLATFORM}"
BRIDGE_SRC="${SCRIPT_DIR}/main.go"

echo "========================================"
echo " FlCroc Go Bridge Builder"
echo " Platform: ${PLATFORM}  Arch: ${ARCH}"
echo "========================================"

# --- Check Go installation ---
if ! command -v go &> /dev/null; then
    echo "[ERROR] Go is not installed. Please install Go 1.25+ from https://go.dev/dl/"
    exit 1
fi
echo "[OK] Go found: $(go version)"

# --- Download dependencies ---
echo ""
echo "[STEP 1/3] Downloading croc dependency..."
cd "${SCRIPT_DIR}"
go mod download
echo "[OK] Dependencies downloaded"

# --- Set up environment ---
case "${PLATFORM}" in
    linux)
        export GOOS=linux
        EXT=".so"
        ;;
    macos|darwin)
        export GOOS=darwin
        EXT=".dylib"
        ;;
    android)
        export GOOS=android
        EXT=".so"
        if [ -z "${ANDROID_NDK_HOME:-}" ]; then
            # Auto-detect Android NDK
            if [ -d "$HOME/Android/Sdk/ndk" ]; then
                ANDROID_NDK_HOME=$(ls -d "$HOME/Android/Sdk/ndk/"*/ 2>/dev/null | sort -r | head -1)
                export ANDROID_NDK_HOME
            elif [ -d "/usr/local/lib/android/sdk/ndk" ]; then
                ANDROID_NDK_HOME=$(ls -d /usr/local/lib/android/sdk/ndk/*/ 2>/dev/null | sort -r | head -1)
                export ANDROID_NDK_HOME
            fi
        fi
        if [ -z "${ANDROID_NDK_HOME:-}" ]; then
            echo "[ERROR] ANDROID_NDK_HOME not set and could not auto-detect"
            exit 1
        fi
        echo "[OK] Using NDK: ${ANDROID_NDK_HOME}"
        HOST_TAG="linux-x86_64"
        [ "$(uname)" = "Darwin" ] && HOST_TAG="darwin-x86_64"
        export CC="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_TAG}/bin/aarch64-linux-android21-clang"
        ;;
    windows)
        export GOOS=windows
        EXT=".dll"
        ;;
    *)
        echo "[ERROR] Unknown platform: ${PLATFORM}"
        echo "  Valid: linux, macos, android, windows"
        exit 1
        ;;
esac

case "${ARCH}" in
    amd64) export GOARCH=amd64 ;;
    arm64) export GOARCH=arm64 ;;
    arm)   export GOARCH=arm ;;
    *)
        echo "[ERROR] Unknown arch: ${ARCH}"
        echo "  Valid: amd64, arm64, arm"
        exit 1
        ;;
esac

export CGO_ENABLED=1

# --- Build ---
echo ""
echo "[STEP 2/3] Building Go shared library for ${GOOS}/${GOARCH}..."
mkdir -p "${OUTPUT_DIR}"

cd "${SCRIPT_DIR}"
go build -buildmode=c-shared \
    -o "${OUTPUT_DIR}/libcroc_bridge${EXT}" \
    -ldflags="-s -w" \
    "${BRIDGE_SRC}"

echo "[OK] Build complete: ${OUTPUT_DIR}/libcroc_bridge${EXT}"

# --- Copy to Flutter directories ---
echo ""
echo "[STEP 3/3] Copying to Flutter platform directories..."
FLUTTER_ROOT="${SCRIPT_DIR}/.."

case "${PLATFORM}" in
    linux)
        cp "${OUTPUT_DIR}/libcroc_bridge.so" "${FLUTTER_ROOT}/linux/runner/" 2>/dev/null || true
        echo "[OK] Copied to linux/runner/"
        ;;
    macos|darwin)
        cp "${OUTPUT_DIR}/libcroc_bridge.dylib" "${FLUTTER_ROOT}/macos/Runner/" 2>/dev/null || true
        echo "[OK] Copied to macos/Runner/"
        ;;
    android)
        mkdir -p "${FLUTTER_ROOT}/android/app/src/main/jniLibs/arm64-v8a"
        cp "${OUTPUT_DIR}/libcroc_bridge.so" "${FLUTTER_ROOT}/android/app/src/main/jniLibs/arm64-v8a/" 2>/dev/null || true
        echo "[OK] Copied to android/app/src/main/jniLibs/arm64-v8a/"
        ;;
    windows)
        cp "${OUTPUT_DIR}/libcroc_bridge.dll" "${FLUTTER_ROOT}/windows/runner/" 2>/dev/null || true
        echo "[OK] Copied to windows/runner/"
        ;;
esac

echo ""
echo "========================================"
echo " Build SUCCESS!"
echo " Output: ${OUTPUT_DIR}/libcroc_bridge${EXT}"
echo "========================================"
