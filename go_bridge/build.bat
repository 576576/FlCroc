@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  FlCroc Go Bridge Build Script (Windows)
REM  Uses local submodule croc source, builds the shared library.
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

REM --- Use submodule croc source (skip clone) ---
echo.
echo [STEP 1/4] Using submodule croc at ..\submodules\croc...
set "CROC_SRC=%SCRIPT_DIR%..\submodules\croc"
if not exist "%CROC_SRC%\go.mod" (
    echo [ERROR] Submodule not found. Run: git submodule update --init
    exit /b 1
)
echo [OK] croc submodule found

REM --- Verify go.mod replace directive ---
echo.
echo [STEP 2/4] Verifying Go module...
cd /d "%SCRIPT_DIR%"
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
if "%ARCH%"=="amd64" set "GOARCH=amd64"
if "%ARCH%"=="arm64" set "GOARCH=arm64"

if "%PLATFORM%"=="android" (
    set "GOOS=android"
    set "EXT=.so"
    if "%ARCH%"=="arm64" (
        set "ANDROID_ABI=arm64-v8a"
    ) else if "%ARCH%"=="amd64" (
        set "ANDROID_ABI=x86_64"
    ) else (
        echo [ERROR] Unsupported Android arch: %ARCH% (use arm64 or amd64)
        exit /b 1
    )
    call :resolve_ndk
    set "CC=%ANDROID_NDK_HOME%\toolchains\llvm\prebuilt\windows-x86_64\bin\%GOARCH%-linux-android21-clang.cmd"
)
goto :skip_ndk
:resolve_ndk
if not defined ANDROID_NDK_HOME (
    if exist "%LOCALAPPDATA%\Android\Sdk\ndk" (
        for /f "tokens=*" %%d in ('dir /b /ad "%LOCALAPPDATA%\Android\Sdk\ndk" 2^>nul ^| sort /r') do (
            set "ANDROID_NDK_HOME=%LOCALAPPDATA%\Android\Sdk\ndk\%%d"
            goto :eof
        )
    )
    echo [ERROR] Android NDK not found. Set ANDROID_NDK_HOME.
    exit /b 1
)
goto :eof
:skip_ndk

REM --- Build ---
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if "%PLATFORM%"=="windows" (
    set "LDFLAGS=-s -w -H windowsgui"
) else (
    set "LDFLAGS=-s -w"
)
go build -buildmode=c-shared ^
    -o "%OUTPUT_DIR%\libcroc_bridge%EXT%" ^
    -ldflags="%LDFLAGS%" .

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
    if not exist "%SCRIPT_DIR%..\android\app\src\main\jniLibs\%ANDROID_ABI%" mkdir "%SCRIPT_DIR%..\android\app\src\main\jniLibs\%ANDROID_ABI%"
    copy /Y "%OUTPUT_DIR%\libcroc_bridge.so" "%SCRIPT_DIR%..\android\app\src\main\jniLibs\%ANDROID_ABI%\" >nul 2>&1
    echo [OK] Copied to android/app/src/main/jniLibs/%ANDROID_ABI%/
)

echo.
echo ========================================
echo  Build SUCCESS!
echo  Output: %OUTPUT_DIR%\libcroc_bridge%EXT%
echo ========================================
exit /b 0
