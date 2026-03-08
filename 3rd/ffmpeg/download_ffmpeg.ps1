param(
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$binDir = Join-Path $currentDir "bin"

if (!(Test-Path $binDir)) {
    New-Item -ItemType Directory -Force -Path $binDir | Out-Null
}

$ffmpegExe = Join-Path $binDir "ffmpeg.exe"
$ffprobeExe = Join-Path $binDir "ffprobe.exe"

if ((Test-Path $ffmpegExe) -and (Test-Path $ffprobeExe) -and !$Force) {
    Write-Host "ffmpeg.exe and ffprobe.exe already exist in $binDir. Skipping download."
    exit 0
}

Write-Host "Downloading FFmpeg for Windows..."

# We use the yt-dlp recommended FFmpeg builds (https://github.com/yt-dlp/FFmpeg-Builds)
$downloadUrl = "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
$zipPath = Join-Path $binDir "ffmpeg.zip"
$extractDir = Join-Path $binDir "ffmpeg-extract"

try {
    Write-Host "Downloading from $downloadUrl..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

    Write-Host "Extracting..."
    if (Test-Path $extractDir) {
        Remove-Item -Recurse -Force $extractDir
    }
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

    # Find the bin directory inside the extracted folder
    $extractedBinDir = Get-ChildItem -Path $extractDir -Recurse -Directory | Where-Object { $_.Name -eq "bin" } | Select-Object -First 1

    if ($extractedBinDir) {
        Write-Host "Copying ffmpeg.exe and ffprobe.exe..."
        Copy-Item -Path (Join-Path $extractedBinDir.FullName "ffmpeg.exe") -Destination $binDir -Force
        Copy-Item -Path (Join-Path $extractedBinDir.FullName "ffprobe.exe") -Destination $binDir -Force
        Write-Host "Done!"
    } else {
        Write-Error "Could not find 'bin' directory in the extracted FFmpeg archive."
    }

} catch {
    Write-Error "Failed to download or extract FFmpeg: $_"
} finally {
    # Cleanup
    if (Test-Path $zipPath) {
        Remove-Item -Force $zipPath
    }
    if (Test-Path $extractDir) {
        Remove-Item -Recurse -Force $extractDir
    }
}
