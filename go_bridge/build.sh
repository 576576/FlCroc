#!/usr/bin/env bash
set -euo pipefail
# ============================================================
#  FlCroc Go Bridge Build Script (Linux/macOS)
#  Clones croc source, then builds the shared library.
#
#  Usage: ./build.sh [platform] [arch]
#    platform: linux (default), macos, android, windows
#    arch:     amd64 (default), arm64, arm
# ============================================================

PLATFORM="${1:-linux}"
ARCH="${2:-amd64}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../build/${PLATFORM}"
CROC_TAG="v10.4.4"
CROC_SRC="/tmp/croc_src"

echo "========================================"
echo " FlCroc Go Bridge Builder"
echo " Platform: ${PLATFORM}  Arch: ${ARCH}"
echo "========================================"

# --- Check Go ---
if ! command -v go &> /dev/null; then
    echo "[ERROR] Go is not installed. Install Go 1.25+"
    exit 1
fi
echo "[OK] Go: $(go version)"

# --- Clone croc ---
echo ""
echo "[STEP 1/4] Cloning croc source (tag ${CROC_TAG})..."
rm -rf "${CROC_SRC}"
git clone --depth 1 --branch "${CROC_TAG}" https://github.com/schollz/croc.git "${CROC_SRC}"
echo "[OK] croc cloned"

# --- Setup Go module ---
echo ""
echo "[STEP 2/4] Setting up Go module..."
cd "${SCRIPT_DIR}"
go mod edit -replace github.com/schollz/croc/v10="${CROC_SRC}"
go mod tidy
echo "[OK] Module ready"

# --- Platform config ---
echo ""
echo "[STEP 3/4] Building for ${PLATFORM}/${ARCH}..."
export CGO_ENABLED=1

case "${PLATFORM}" in
    linux)   export GOOS=linux; EXT=".so" ;;
    macos|darwin) export GOOS=darwin; EXT=".dylib" ;;
    android)
        export GOOS=android; EXT=".so"
        [ -z "${ANDROID_NDK_HOME:-}" ] && ANDROID_NDK_HOME=$(ls -d "$HOME/Android/Sdk/ndk/"*/ 2>/dev/null | sort -r | head -1)
        HOST_TAG="linux-x86_64"; [ "$(uname)" = "Darwin" ] && HOST_TAG="darwin-x86_64"
        export CC="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_TAG}/bin/aarch64-linux-android21-clang"
        ;;
    windows) export GOOS=windows; EXT=".dll" ;;
    *) echo "Unknown platform: ${PLATFORM}"; exit 1 ;;
esac

case "${ARCH}" in
    amd64) export GOARCH=amd64 ;;
    arm64) export GOARCH=arm64 ;;
    arm)   export GOARCH=arm ;;
    *) echo "Unknown arch: ${ARCH}"; exit 1 ;;
esac

mkdir -p "${OUTPUT_DIR}"
LDFLAGS="-s -w"
[ "${PLATFORM}" = "windows" ] && LDFLAGS="${LDFLAGS} -H windowsgui"
go build -buildmode=c-shared -o "${OUTPUT_DIR}/libcroc_bridge${EXT}" -ldflags="${LDFLAGS}" .
echo "[OK] Built"

# --- Copy ---
echo ""
echo "[STEP 4/4] Copying..."
case "${PLATFORM}" in
    linux)   cp "${OUTPUT_DIR}/libcroc_bridge.so" "${SCRIPT_DIR}/../linux/runner/" 2>/dev/null || true ;;
    macos|darwin) cp "${OUTPUT_DIR}/libcroc_bridge.dylib" "${SCRIPT_DIR}/../macos/Runner/" 2>/dev/null || true ;;
    android) mkdir -p "${SCRIPT_DIR}/../android/app/src/main/jniLibs/arm64-v8a"
             cp "${OUTPUT_DIR}/libcroc_bridge.so" "${SCRIPT_DIR}/../android/app/src/main/jniLibs/arm64-v8a/" 2>/dev/null || true ;;
    windows) cp "${OUTPUT_DIR}/libcroc_bridge.dll" "${SCRIPT_DIR}/../windows/runner/" 2>/dev/null || true ;;
esac
echo "[OK] Done"

echo ""
echo "========================================"
echo " Build SUCCESS!"
echo " Output: ${OUTPUT_DIR}/libcroc_bridge${EXT}"
echo "========================================"
