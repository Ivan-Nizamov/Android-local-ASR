#!/data/data/com.termux/files/usr/bin/bash

# 10s audio recorder for Termux
DIR="$HOME/storage/shared"
FILE="$DIR/rec_$(date +%Y%m%d_%H%M%S).wav"

mkdir -p "$DIR"
echo "📱 Starting 10s recording..."
echo "📁 Output: ${FILE##*/}"
echo ""

# Record with clean progress bar
termux-microphone-record -f "$FILE" >/dev/null 2>&1 &
echo -n "⏺️  ["
for i in {1..10}; do
  echo -n "■"
  sleep 1
done
echo "] Done!"

# Stop and get size
termux-microphone-record -q >/dev/null 2>&1
wait $! 2>/dev/null
echo "💾 Size: $(du -h "$FILE" | cut -f1)"
echo ""

# Playback
echo "▶️  Playing back..."
termux-media-player play "$FILE" >/dev/null 2>&1
