#!/data/data/com.termux/files/usr/bin/sh
# Start Termux SSH server and print NixOS connect command

pkg install -y openssh > /dev/null 2>&1
ssh-keygen -A
pkill sshd 2>/dev/null
sshd

# Try to get Wi-Fi IP from termux API first
IP=$(termux-wifi-connectioninfo 2>/dev/null | grep -oE '"ip": *"[^"]+"' | cut -d'"' -f4)

# Fallback: parse wlan0 address
if [ -z "$IP" ]; then
  IP=$(ip -4 addr show wlan0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
fi

# If still empty, last resort
if [ -z "$IP" ]; then
  IP=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v 127.0.0.1 | awk '{print $2}' | head -n1)
fi

echo
echo "✅ SSH server is running on Termux"
echo "👉 From your NixOS machine, run:"
echo
echo "    ssh -p 8022 u0_a424@$IP"
echo
