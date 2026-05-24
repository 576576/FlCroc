@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  FlCroc Go Bridge Build Script (Windows)
REM  Dynamically downloads croc dependency and builds the shared
REM  library for the specified platform.
REM
REM  Usage: build.bat [platform] [arch]
REM    platform: windows (default), android
REM    arch:     amd64 (default), arm64
REM ============================================================

set "PLATFORM=%1"
set "ARCH=%2"
if "%PLATFORM%"=="" set "PLATFORM=windows"
if "%ARCH%"=="" set "ARCH=amd64"

set "SCRIPT_DIR=%~dp0"
set "OUTPUT_DIR=%SCRIPT_DIR%..\build\%PLATFORM%"
set "BRIDGE_SRC=%SCRIPT_DIR%main.go"

echo ========================================
echo  FlCroc Go Bridge Builder
echo  Platform: %PLATFORM%  Arch: %ARCH%
echo ========================================

REM --- Check Go installation ---
where go >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Go is not installed. Please install Go 1.25+ from https://go.dev/dl/
    exit /b 1
)
echo [OK] Go found: 
go version

REM --- Download dependencies ---
echo.
echo [STEP 1/3] Downloading croc dependency...
cd /d "%SCRIPT_DIR%"
go mod download
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to download dependencies
    exit /b 1
)
echo [OK] Dependencies downloaded

REM --- Set up environment variables ---
set "GOOS=windows"
set "CGO_ENABLED=1"

if "%ARCH%"=="amd64" set "GOARCH=amd64"
if "%ARCH%"=="arm64" set "GOARCH=arm64"

if "%PLATFORM%"=="android" (
    set "GOOS=android"
    set "GOARCH=arm64"
    REM Android NDK toolchain (auto-detected or configure manually)
    if not defined ANDROID_NDK_HOME (
        echo [WARN] ANDROID_NDK_HOME not set. Attempting auto-detect...
        if exist "%LOCALAPPDATA%\Android\Sdk\ndk" (
            for /f "tokens=*" %%d in ('dir /b /ad "%LOCALAPPDATA%\Android\Sdk\ndk" 2^>nul ^| sort /r') do (
                set "ANDROID_NDK_HOME=%LOCALAPPDATA%\Android\Sdk\ndk\%%d"
                goto :ndk_found
            )
        )
        echo [ERROR] Android NDK not found. Set ANDROID_NDK_HOME manually.
        exit /b 1
    )
    :ndk_found
    echo [OK] Using NDK: %ANDROID_NDK_HOME%
    set "CC=%ANDROID_NDK_HOME%\toolchains\llvm\prebuilt\windows-x86_64\bin\aarch64-linux-android21-clang.cmd"
)

if "%PLATFORM%"=="windows" (
    set EXT=.dll
) else (
    set EXT=.so
)

REM --- Build ---
echo.
echo [STEP 2/3] Building Go shared library...
cd /d "%SCRIPT_DIR%"

if "%PLATFORM%"=="windows" (
    go build -buildmode=c-shared ^
        -o "%OUTPUT_DIR%\libcroc_bridge%EXT%" ^
        -ldflags="-s -w" ^
        "%BRIDGE_SRC%"
) else (
    go build -buildmode=c-shared ^
        -o "%OUTPUT_DIR%\libcroc_bridge%EXT%" ^
        -ldflags="-s -w" ^
        "%BRIDGE_SRC%"
)

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build failed
    exit /b 1
)

REM --- Copy to Flutter directories ---
echo.
echo [STEP 3/3] Copying library to Flutter platform directories...
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

if "%PLATFORM%"=="windows" (
    copy /Y "%OUTPUT_DIR%\libcroc_bridge.dll" "%SCRIPT_DIR%..\windows\runner\" >nul 2>&1
    echo [OK] Copied to windows/runner/
)
if "%PLATFORM%"=="android" (
    if not exist "%SCRIPT_DIR%..\android\app\src\main\jniLibs\arm64-v8a" mkdir "%SCRIPT_DIR%..\android\app\src\main\jniLibs\arm64-v8a"
    copy /Y "%OUTPUT_DIR%\libcroc_bridge.so" "%SCRIPT_DIR%..\android\app\src\main\jniLibs\arm64-v8a\" >nul 2>&1
    echo [OK] Copied to android/app/src/main/jniLibs/arm64-v8a/
)

echo.
echo ========================================
echo  Build SUCCESS!
echo  Output: %OUTPUT_DIR%\libcroc_bridge%EXT%
echo ========================================
exit /b 0
