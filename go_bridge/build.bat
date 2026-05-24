@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  FlCroc Go Bridge Build Script (Windows)
REM  Clones croc source, then builds the shared library.
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
set "CROC_TAG=v10.4.4"
set "CROC_SRC=%TEMP%\croc_src"

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

REM --- Clone croc source ---
echo.
echo [STEP 1/4] Cloning croc source (tag %CROC_TAG%)...
if exist "%CROC_SRC%" rmdir /s /q "%CROC_SRC%"
git clone --depth 1 --branch %CROC_TAG% https://github.com/schollz/croc.git "%CROC_SRC%"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to clone croc
    exit /b 1
)
echo [OK] croc source cloned

REM --- Set up Go module with replace ---
echo.
echo [STEP 2/4] Setting up Go module...
cd /d "%SCRIPT_DIR%"
go mod edit -replace github.com/schollz/croc/v10=%CROC_SRC%
go mod tidy
if %ERRORLEVEL% neq 0 (
    echo [ERROR] go mod tidy failed
    exit /b 1
)

REM --- Set up platform env ---
echo.
echo [STEP 3/4] Building for %PLATFORM%/%ARCH%...

set "CGO_ENABLED=1"

if "%PLATFORM%"=="windows" (
    set "GOOS=windows"
    set "EXT=.dll"
)
if "%PLATFORM%"=="android" (
    set "GOOS=android"
    set "EXT=.so"
    if "%ARCH%"=="arm64" set "GOARCH=arm64"
    if not defined ANDROID_NDK_HOME (
        if exist "%LOCALAPPDATA%\Android\Sdk\ndk" (
            for /f "tokens=*" %%d in ('dir /b /ad "%LOCALAPPDATA%\Android\Sdk\ndk" 2^>nul ^| sort /r') do (
                set "ANDROID_NDK_HOME=%LOCALAPPDATA%\Android\Sdk\ndk\%%d"
                goto :ndk_found
            )
        )
        echo [ERROR] Android NDK not found. Set ANDROID_NDK_HOME.
        exit /b 1
    )
    :ndk_found
    echo [OK] NDK: %ANDROID_NDK_HOME%
    set "CC=%ANDROID_NDK_HOME%\toolchains\llvm\prebuilt\windows-x86_64\bin\aarch64-linux-android21-clang.cmd"
)

if "%ARCH%"=="amd64" set "GOARCH=amd64"

REM --- Build ---
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
go build -buildmode=c-shared ^
    -o "%OUTPUT_DIR%\libcroc_bridge%EXT%" ^
    -ldflags="-s -w" .

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build failed
    exit /b 1
)

REM --- Copy to Flutter dirs ---
echo.
echo [STEP 4/4] Copying to Flutter directories...
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
