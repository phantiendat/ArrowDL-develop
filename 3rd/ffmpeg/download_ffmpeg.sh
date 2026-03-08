#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BIN_DIR="$DIR/bin"

mkdir -p "$BIN_DIR"

if [ -f "$BIN_DIR/ffmpeg" ] && [ -f "$BIN_DIR/ffprobe" ] && [ "$1" != "--force" ]; then
    echo "ffmpeg and ffprobe already exist in $BIN_DIR. Skipping download."
    exit 0
fi

echo "Downloading FFmpeg for Linux..."

# Recommend yt-dlp FFmpeg builds
DOWNLOAD_URL="https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz"
TAR_PATH="$BIN_DIR/ffmpeg.tar.xz"
EXTRACT_DIR="$BIN_DIR/ffmpeg-extract"

echo "Downloading from $DOWNLOAD_URL..."
curl -L -o "$TAR_PATH" "$DOWNLOAD_URL"

echo "Extracting..."
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"
tar -xf "$TAR_PATH" -C "$EXTRACT_DIR"

# Find the bin directory inside the extracted folder
EXTRACTED_BIN_DIR=$(find "$EXTRACT_DIR" -type d -name "bin" | head -n 1)

if [ -n "$EXTRACTED_BIN_DIR" ]; then
    echo "Copying ffmpeg and ffprobe..."
    cp "$EXTRACTED_BIN_DIR/ffmpeg" "$BIN_DIR/"
    cp "$EXTRACTED_BIN_DIR/ffprobe" "$BIN_DIR/"
    
    chmod +x "$BIN_DIR/ffmpeg"
    chmod +x "$BIN_DIR/ffprobe"
    echo "Done!"
else
    echo "Error: Could not find 'bin' directory in the extracted FFmpeg archive."
    exit 1
fi

# Cleanup
rm -f "$TAR_PATH"
rm -rf "$EXTRACT_DIR"
