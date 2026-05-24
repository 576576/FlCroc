#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Downloads the croc binary for the current platform and places it
  in the correct Flutter bundle directory.

.DESCRIPTION
  Supports: windows-amd64, macos-amd64, macos-arm64, linux-amd64, linux-arm64
  For Android ARM64, you must cross-compile with Go (see go_bridge/build.bat).

.PARAMETER Platform
  Target platform: windows, macos, linux, android (default: current OS)

.PARAMETER Arch
  Target architecture: amd64, arm64 (default: amd64)

.EXAMPLE
  .\setup_croc.ps1                    # Download for current OS
  .\setup_croc.ps1 -Platform android  # Note: Android needs Go cross-compile
#>

param(
    [string]$Platform = "",
    [string]$Arch = "amd64"
)

$ErrorActionPreference = "Stop"
$CROC_VERSION = "v10.4.4"

# Detect current platform
if ($Platform -eq "") {
    if ($IsWindows) { $Platform = "windows" }
    elseif ($IsMacOS) { $Platform = "macos" }
    elseif ($IsLinux) { $Platform = "linux" }
    else { Write-Error "Cannot detect platform. Use -Platform." }
}

# Detect architecture
if ($Arch -eq "amd64" -and $env:PROCESSOR_ARCHITECTURE -eq "ARM64") { $Arch = "arm64" }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " FlCroc - Download croc $CROC_VERSION" -ForegroundColor Cyan
Write-Host " Platform: $Platform  Arch: $Arch" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir

# Map platform to download URL
$downloadUrl = ""
$outputName = ""
$outputDir = ""

switch ($Platform) {
    "windows" {
        $downloadUrl = "https://github.com/schollz/croc/releases/download/$CROC_VERSION/croc_${CROC_VERSION}_Windows-64bit_GUI.zip"
        $outputName = "croc.exe"
        $outputDir = "$projectRoot\windows\runner"
    }
    "macos" {
        if ($Arch -eq "arm64") {
            $downloadUrl = "https://github.com/schollz/croc/releases/download/$CROC_VERSION/croc_${CROC_VERSION}_macOS-ARM64_GUI.zip"
        } else {
            $downloadUrl = "https://github.com/schollz/croc/releases/download/$CROC_VERSION/croc_${CROC_VERSION}_macOS-64bit_GUI.zip"
        }
        $outputName = "croc"
        $outputDir = "$projectRoot\macos\Runner"
    }
    "linux" {
        if ($Arch -eq "arm64") {
            $downloadUrl = "https://github.com/schollz/croc/releases/download/$CROC_VERSION/croc_${CROC_VERSION}_Linux-ARM64_GUI.tar.gz"
        } else {
            $downloadUrl = "https://github.com/schollz/croc/releases/download/$CROC_VERSION/croc_${CROC_VERSION}_Linux-64bit_GUI.tar.gz"
        }
        $outputName = "croc"
        $outputDir = "$projectRoot\linux\flutter\ephemeral"
    }
    "android" {
        Write-Host "[INFO] Android requires Go cross-compilation." -ForegroundColor Yellow
        Write-Host "  cd go_bridge && .\build.bat android arm64" -ForegroundColor Yellow
        Write-Host "  This will produce libcroc_bridge.so for jniLibs." -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Error "Unknown platform: $Platform"
    }
}

# Create output directory
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Download
$zipPath = "$env:TEMP\croc_download.zip"
Write-Host ""
Write-Host "[STEP 1/2] Downloading croc from GitHub..." -ForegroundColor Green
Write-Host "  URL: $downloadUrl" -ForegroundColor Gray

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "  Downloaded to $zipPath" -ForegroundColor Gray
} catch {
    Write-Error "Download failed: $_"
}

# Extract and copy
Write-Host "[STEP 2/2] Extracting and copying to $outputDir" -ForegroundColor Green

if ($Platform -eq "windows") {
    Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\croc_extract" -Force
    $extracted = Get-ChildItem -Path "$env:TEMP\croc_extract" -Recurse -Filter "croc.exe" | Select-Object -First 1
    Copy-Item -Path $extracted.FullName -Destination "$outputDir\croc.exe" -Force
} else {
    # tar.gz or zip for macOS
    if ($zipPath.EndsWith(".tar.gz")) {
        $tarDir = "$env:TEMP\croc_extract"
        New-Item -ItemType Directory -Path $tarDir -Force | Out-Null
        tar -xzf $zipPath -C $tarDir
        $extracted = Get-ChildItem -Path $tarDir -Recurse -Filter "croc" | Select-Object -First 1
        Copy-Item -Path $extracted.FullName -Destination "$outputDir\croc" -Force
    } else {
        Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP\croc_extract" -Force
        $extracted = Get-ChildItem -Path "$env:TEMP\croc_extract" -Recurse -Filter "croc" | Select-Object -First 1
        Copy-Item -Path $extracted.FullName -Destination "$outputDir\croc" -Force
    }
    # Make executable
    if ($IsMacOS -or $IsLinux) {
        chmod +x "$outputDir\croc"
    }
}

# Cleanup
Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:TEMP\croc_extract" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " croc $CROC_VERSION installed!" -ForegroundColor Green
Write-Host " Location: $outputDir\$outputName" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

# Verify
$crocPath = "$outputDir\$outputName"
if (Test-Path $crocPath) {
    Write-Host ""
    Write-Host "Verifying..." -ForegroundColor Gray
    & $crocPath --version 2>&1 | Write-Host -ForegroundColor Gray
}

Write-Host ""
Write-Host "Next: flutter run" -ForegroundColor Yellow
