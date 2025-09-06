#!/data/data/com.termux/files/usr/bin/bash

# Create directories if they don't exist
RECORDINGS_DIR="recordings"
CONVERTED_DIR="whisper.cpp/converted-audio"
TRANSCRIPTS_DIR="transcripts"
mkdir -p "$RECORDINGS_DIR"
mkdir -p "$CONVERTED_DIR"
mkdir -p "$TRANSCRIPTS_DIR"

# Start recording
TEMP_FILE="$RECORDINGS_DIR/rec_$(date +%H%M%S).wav"
echo "⏺️  Recording... (press any key to stop)"

termux-microphone-record -f "$TEMP_FILE" >/dev/null 2>&1 &
PID=$!

# Timer until keypress or 15 min
SEC=0
while [ $SEC -lt 900 ]; do
  printf "\r⏺️  %02d:%02d" $((SEC/60)) $((SEC%60))
  read -n1 -t1 -s && break
  ((SEC++))
done

# Stop recording
termux-microphone-record -q >/dev/null 2>&1
wait $PID 2>/dev/null

# Rename with metadata
SIZE=$(du -h "$TEMP_FILE" | cut -f1)
TIME=$(date +%H%M%S)
DUR=$(printf "%02dm%02ds" $((SEC/60)) $((SEC%60)))
FINAL_FILE="$RECORDINGS_DIR/${TIME}_${SIZE}_${DUR}.wav"
mv "$TEMP_FILE" "$FINAL_FILE"
echo -e "\n✓ Saved: $FINAL_FILE"

# Convert to 16-bit WAV format
CONVERTED_FILE="$CONVERTED_DIR/${TIME}_16bit.wav"
ffmpeg -i "$FINAL_FILE" -ar 16000 -ac 1 -c:a pcm_s16le "$CONVERTED_FILE" >/dev/null 2>&1

echo "🔄 Converted to 16-bit WAV"

# Transcribe with Whisper
echo "🎧 Transcribing..."
TRANSCRIPT_TXT="$TRANSCRIPTS_DIR/${TIME}_transcript.txt"
./whisper.cpp/build/bin/whisper-cli -m whisper.cpp/models/ggml-small-q5_1.bin -f "$CONVERTED_FILE" -l ru > "$TRANSCRIPT_TXT"

echo -e "\n✅ Transcript saved to: $TRANSCRIPT_TXT"

# Display transcript content
echo -e "\n📄 Transcript content:"
cat "$TRANSCRIPT_TXT"

# Copy to clipboard if available
if command -v termux-clipboard-set >/dev/null 2>&1; then
  cat "$TRANSCRIPT_TXT" | termux-clipboard-set
  echo "📋 Copied to clipboard"
fi

echo -e "\n✅ All done!"
