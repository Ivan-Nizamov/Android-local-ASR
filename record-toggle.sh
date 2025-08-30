#!/data/data/com.termux/files/usr/bin/bash

# Dynamic recorder - press any key to stop
TEMP="rec_$(date +%H%M%S).wav"

echo "⏺️  Recording... (press any key to stop)"

# Start recording
termux-microphone-record -f "$TEMP" >/dev/null 2>&1 &
PID=$!

# Timer until keypress or 15 min
SEC=0
while [ $SEC -lt 900 ]; do
  printf "\r⏺️  %02d:%02d" $((SEC/60)) $((SEC%60))
  read -n1 -t1 -s && break
  ((SEC++))
done

# Stop
termux-microphone-record -q >/dev/null 2>&1
wait $PID 2>/dev/null

# Rename with time + size + duration
SIZE=$(du -h "$TEMP" | cut -f1)
TIME=$(date +%H%M%S)
DUR=$(printf "%02dm%02ds" $((SEC/60)) $((SEC%60)))
FILE="${TIME}_${SIZE}_${DUR}.wav"
mv "$TEMP" "$FILE"

echo -e "\n✓ Saved: $FILE"

# Play
termux-media-player play "$FILE" >/dev/null 2>&1
