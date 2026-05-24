#!/usr/bin/env bash
set -euo pipefail
# ============================================================
#  FlCroc — Download croc binary for the current platform
#  Usage: ./setup_croc.sh [platform] [arch]
# ============================================================

CROC_VERSION="v10.4.4"
PLATFORM="${1:-}"
ARCH="${2:-amd64}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Detect platform
if [ -z "$PLATFORM" ]; then
    case "$(uname -s)" in
        Linux*)  PLATFORM="linux" ;;
        Darwin*) PLATFORM="macos" ;;
        MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
        *) echo "Unknown OS"; exit 1 ;;
    esac
fi

# Detect arch
if [ "$ARCH" = "amd64" ] && [ "$(uname -m)" = "arm64" ]; then
    ARCH="arm64"
fi

echo "========================================"
echo " FlCroc - Download croc ${CROC_VERSION}"
echo " Platform: ${PLATFORM}  Arch: ${ARCH}"
echo "========================================"

download_url=""
output_name="croc"
output_dir=""

case "${PLATFORM}" in
    windows)
        download_url="https://github.com/schollz/croc/releases/download/${CROC_VERSION}/croc_${CROC_VERSION}_Windows-64bit_GUI.zip"
        output_name="croc.exe"
        output_dir="${PROJECT_ROOT}/windows/runner"
        ;;
    macos)
        if [ "$ARCH" = "arm64" ]; then
            download_url="https://github.com/schollz/croc/releases/download/${CROC_VERSION}/croc_${CROC_VERSION}_macOS-ARM64_GUI.zip"
        else
            download_url="https://github.com/schollz/croc/releases/download/${CROC_VERSION}/croc_${CROC_VERSION}_macOS-64bit_GUI.zip"
        fi
        output_dir="${PROJECT_ROOT}/macos/Runner"
        ;;
    linux)
        if [ "$ARCH" = "arm64" ]; then
            download_url="https://github.com/schollz/croc/releases/download/${CROC_VERSION}/croc_${CROC_VERSION}_Linux-ARM64_GUI.tar.gz"
        else
            download_url="https://github.com/schollz/croc/releases/download/${CROC_VERSION}/croc_${CROC_VERSION}_Linux-64bit_GUI.tar.gz"
        fi
        output_dir="${PROJECT_ROOT}/linux/flutter/ephemeral"
        ;;
    android)
        echo "[INFO] Android requires Go cross-compilation."
        echo "  cd go_bridge && ./build.sh android arm64"
        exit 0
        ;;
    *)
        echo "Unknown platform: ${PLATFORM}"
        exit 1
        ;;
esac

mkdir -p "${output_dir}"

# Download
echo ""
echo "[STEP 1/2] Downloading croc..."
TMP_DIR=$(mktemp -d)
ARCHIVE="${TMP_DIR}/croc_archive"

curl -L -o "${ARCHIVE}" "${download_url}" --progress-bar

# Extract
echo "[STEP 2/2] Extracting to ${output_dir}..."
cd "${TMP_DIR}"

if [[ "${ARCHIVE}" == *.tar.gz ]]; then
    tar -xzf "${ARCHIVE}"
else
    unzip -qo "${ARCHIVE}"
fi

# Find and copy croc binary
CROC_BIN=$(find "${TMP_DIR}" -type f -name "croc" -o -name "croc.exe" | head -1)
if [ -n "${CROC_BIN}" ]; then
    cp "${CROC_BIN}" "${output_dir}/${output_name}"
    chmod +x "${output_dir}/${output_name}" 2>/dev/null || true
else
    echo "[ERROR] Could not find croc binary in archive"
    exit 1
fi

# Cleanup
rm -rf "${TMP_DIR}"

echo ""
echo "========================================"
echo " croc ${CROC_VERSION} installed!"
echo " Location: ${output_dir}/${output_name}"
echo "========================================"

# Verify
if [ -x "${output_dir}/${output_name}" ]; then
    echo ""
    "${output_dir}/${output_name}" --version
fi

echo ""
echo "Next: flutter run"
