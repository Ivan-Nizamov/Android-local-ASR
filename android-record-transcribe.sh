#!/data/data/com.termux/files/usr/bin/bash

# Create directories if they don't exist
RECORDINGS_DIR="recordings"
CONVERTED_DIR="whisper.cpp/converted-audio"
TRANSCRIPTS_DIR="transcripts"
mkdir -p "$RECORDINGS_DIR"
mkdir -p "$CONVERTED_DIR"
mkdir -p "$TRANSCRIPTS_DIR"

# Function to calculate available recording time
calculate_max_recording_time() {
    local free_space_kb=$(df -k . | awk 'NR==2 {print $4}')
    local reserved_space_kb=$((1024 * 1024)) # 1GB in KB
    
    if [ $free_space_kb -le $reserved_space_kb ]; then
        echo "0"
        return
    fi
    
    local available_space_kb=$((free_space_kb - reserved_space_kb))
    
    # Estimate WAV file size: sample rate (16000) * bit depth (16) * channels (1) / 8 bits per byte
    local bytes_per_second=$((16000 * 16 * 1 / 8))
    local max_seconds=$((available_space_kb * 1024 / bytes_per_second))
    
    echo "$max_seconds"
}

# Check available space
MAX_TIME=$(calculate_max_recording_time)
if [ "$MAX_TIME" -le "0" ]; then
    echo "❌ Insufficient storage space (need at least 1GB free)"
    exit 1
fi

echo "💾 Available recording time: $(($MAX_TIME/60)) minutes"

# Start recording with unlimited time but space monitoring
TEMP_FILE="$RECORDINGS_DIR/rec_$(date +%H%M%S).wav"
echo "⏺️  Recording... (press any key to stop)"

termux-microphone-record -f "$TEMP_FILE" >/dev/null 2>&1 &
PID=$!

# Prevent device from sleeping during recording
termux-wake-lock

# Timer with space monitoring
SEC=0
MAX_SEC=$((MAX_TIME < 86400 ? MAX_TIME : 86400)) # Cap at 24 hours for safety
while [ $SEC -lt $MAX_SEC ]; do
    printf "\r⏺️  %02d:%02d:%02d" $(($SEC/3600)) $(($SEC%3600/60)) $(($SEC%60))
    
    # Check available space every 30 seconds
    if [ $(($SEC % 30)) -eq 0 ]; then
        CURRENT_MAX=$(calculate_max_recording_time)
        if [ "$CURRENT_MAX" -le "10" ]; then # Less than 10 seconds remaining
            echo -e "\n⚠️  Low storage space, stopping recording"
            break
        fi
    fi
    
    # Check for keypress
    read -n1 -t1 -s && break
    ((SEC++))
done

# Stop recording
termux-microphone-record -q >/dev/null 2>&1
wait $PID 2>/dev/null
termux-wake-unlock

# Check if file was created
if [ ! -f "$TEMP_FILE" ]; then
    echo "❌ Recording failed - no file created"
    exit 1
fi

# Rename with metadata
SIZE=$(du -h "$TEMP_FILE" | cut -f1)
TIME=$(date +%H%M%S)
DUR=$(printf "%02dh%02dm%02ds" $(($SEC/3600)) $(($SEC%3600/60)) $(($SEC%60)))
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
