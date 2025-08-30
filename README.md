# Android Local ASR

A collection of bash scripts for performing local Automatic Speech Recognition (ASR) on Android devices using Termux.

## Overview

This repository contains a set of utility scripts that enable audio recording and playback directly on Android devices through Termux, without requiring any cloud services or internet connection. These scripts are particularly useful for privacy-focused speech recognition applications.

## Prerequisites

- [Termux](https://termux.dev/) app installed on your Android device
- Termux:API package (for accessing device features)

## Installation

1. Install Termux from F-Droid (recommended) or Google Play Store
2. Install Termux:API app from F-Droid
3. In Termux, run:
   ```bash
   pkg install termux-api
   ```

## Scripts

### 1. record-and-play-10s.sh
Records exactly 10 seconds of audio and plays it back automatically.

Features:
- Creates a timestamped WAV file in your shared storage
- Visual progress bar during recording
- Shows file size after recording
- Automatic playback after recording

Usage:
```bash
./record-and-play-10s.sh
```

### 2. record-toggle.sh
Records audio for a variable duration (up to 15 minutes) until any key is pressed.

Features:
- Dynamic recording length (press any key to stop)
- Timer display during recording
- Automatically names files with timestamp, size, and duration
- Automatic playback after recording

Usage:
```bash
./record-toggle.sh
```

### 3. start-ssh.sh
Sets up an SSH server on your Android device for remote access.

Features:
- Installs OpenSSH if not already present
- Starts SSH daemon on port 8022
- Displays connection command for your NixOS machine
- Attempts to detect your device's IP address

Usage:
```bash
./start-ssh.sh
```

## File Naming Convention

Recorded files follow a specific naming convention:
- `record-and-play-10s.sh`: `rec_YYYYMMDD_HHMMSS.wav`
- `record-toggle.sh`: `HHMMSS_SIZE_MMmSSs.wav` (e.g., `142356_2.1M_00m15s.wav`)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.