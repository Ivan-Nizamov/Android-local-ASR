#!/data/data/com.termux/files/usr/bin/bash

# Termux Whisper Recorder Installer Script
# This script automates the setup process described in the README

echo "🚀 Termux Whisper Recorder Installer"
echo "====================================="
echo ""

# Check if we're running on Termux
if [[ ! -d "/data/data/com.termux/files" ]]; then
    echo "❌ This script is intended to run on Termux only."
    exit 1
fi

# Setup storage access
echo "📂 Setting up storage access..."
termux-setup-storage
echo "✅ Storage setup complete"
echo ""

# Update & install required packages
echo "📦 Installing required packages..."
pkg update -y && pkg upgrade -y
pkg install -y git curl ffmpeg bc coreutils findutils grep sed awk clang cmake make termux-api
echo "✅ Package installation complete"
echo ""

# Clone repo
echo "📥 Cloning repository..."
cd ~
if [ -d "android-local-asr" ]; then
    echo "⚠️  Repository directory already exists. Backing up..."
    mv android-local-asr android-local-asr.backup.$(date +%s)
    echo "✅ Backed up existing directory"
fi

git clone https://github.com/ivan-nizamov/android-local-asr.git
cd android-local-asr
chmod +x improved.sh main.sh voice_recorder.sh
echo "✅ Repository cloned and scripts made executable"
echo ""

# Build whisper.cpp
echo "🔨 Building whisper.cpp..."
cd whisper.cpp
cmake -S . -B build -DGGML_OPENMP=OFF
cmake --build build -j
echo "✅ whisper.cpp build complete"
echo ""

# Download model
echo "📥 Downloading Whisper model (small-q5_1)..."
cd models
bash ./download-ggml-model.sh small-q5_1
cd ../..
echo "✅ Model download complete"
echo ""

echo "🎉 Installation complete!"
echo ""
echo "To run the recorder, execute:"
echo "  cd ~/android-local-asr"
echo "  ./improved.sh"
echo ""
echo "For more information, check the README.md file."