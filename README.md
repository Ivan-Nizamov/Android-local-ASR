# Termux Whisper Recorder

Record audio on Android (Termux) with one keypress, auto-convert to 16-bit 16 kHz mono WAV, and transcribe locally with `whisper.cpp`.

---

## 1) Requirements

### Essential Apps
* **Termux** (Install from [F-Droid](https://f-droid.org/en/packages/com.termux/) or [GitHub](https://github.com/termux/termux-app))
* **Termux:API** (Install from [F-Droid](https://f-droid.org/en/packages/com.termux.api/) - required for microphone access)

### Permissions
* Grant **microphone permission** to Termux:API app
* Grant **storage permission** to Termux app (for saving recordings and transcripts)

### Before You Begin
1. Open the Termux:API app at least once after installation to ensure the service is running
2. Ensure your device has at least 2GB of free storage space (1GB for the model, 1GB+ for recordings)

---

## 2) Automated setup

Paste this into Termux after installing apps and granting permissions:

```bash
# Setup storage access
termux-setup-storage

# Update & install required packages
pkg update -y && pkg upgrade -y
pkg install -y git curl ffmpeg bc coreutils findutils grep sed awk clang cmake make termux-api

# Clone repo
cd ~
git clone https://github.com/ivan-nizamov/android-local-asr.git
cd android-local-asr
chmod +x improved.sh main.sh voice_recorder.sh

# Build whisper.cpp
cd whisper.cpp
cmake -S . -B build -DGGML_OPENMP=OFF
cmake --build build -j

# Download model (see Model Options section below)
cd models
bash ./download-ggml-model.sh small-q5_1
cd ../..
```

---

## 3) Run

```bash
cd ~/android-local-asr
./improved.sh
```

* Records until keypress
* Saves to `recordings/`
* Converts to `whisper.cpp/converted-audio/`
* Transcript in `transcripts/`

Press any key to stop recording. The script will automatically:
1. Save the recording with metadata (timestamp, size, duration)
2. Convert to 16-bit 16kHz mono WAV format
3. Transcribe using Whisper
4. Display results with performance metrics
5. Copy clean transcript to clipboard (if available)

---

## 4) Directory Structure

* `recordings/` - Original recordings with metadata in filename
* `whisper.cpp/converted-audio/` - Processed 16-bit WAV files
* `transcripts/` - Text transcripts with timestamps and clean versions
* `whisper.cpp/models/` - Downloaded Whisper models

---

## 5) Model Options

Different models offer trade-offs between accuracy and speed:

| Model | Size | Accuracy | Speed | Recommended For |
|-------|------|----------|-------|-----------------|
| tiny | 75 MB | Low | Fastest | Quick drafts, noisy environments |
| base | 142 MB | Medium-Low | Fast | General use, limited storage |
| small-q5_1 | 245 MB | Medium | Medium | Balanced performance (default) |
| medium | 767 MB | High | Slow | High accuracy requirements |
| large | 1.5 GB | Highest | Slowest | Professional use |

To use a different model, replace `small-q5_1` in the download command:
```bash
cd whisper.cpp/models
bash ./download-ggml-model.sh MODEL_NAME
```

---

## 6) Customize

Edit `improved.sh`:

* **Language**: Change `-l ru` to your language code (e.g., `-l en`, `-l fr`, `-l de`)
* **Model**: Adjust `-m` path if you use another model
* **Performance**: Modify CPU threads with `-t N` (where N is number of threads)

---

## 7) Troubleshooting

* **`termux-microphone-record: not found`** → Run `pkg install termux-api`
* **Permission errors** → 
  1. Ensure microphone permission is granted to Termux:API app
  2. Open Termux:API app at least once after installation
* **`whisper-cli: not found`** → Rebuild with:
  ```bash
  cd whisper.cpp
  cmake -S . -B build -DGGML_OPENMP=OFF
  cmake --build build -j
  ```
* **Slow transcription** → Use smaller models (e.g., tiny, base-q5_1)
* **Storage errors** → Free up device storage (need at least 1GB free)
* **No transcription output** → Check audio quality, try in quieter environment

---

## 8) Cleanup

```bash
rm -rf ~/android-local-asr
```

---

## Credits

* Scripts: this project
* `whisper.cpp`: MIT License — © Georgi Gerganov & contributors