#!/usr/bin/env bash
# Turn a Raspberry Pi 5 + Touch Display 2 (Raspberry Pi OS desktop, 64-bit)
# into a full-screen Home Assistant kiosk.
#
# Usage (run as your normal user, not root):
#   bash setup-pi-kiosk.sh http://192.168.1.50:8123/family-hub/home
#
# After reboot Chromium opens full screen on the dashboard. Log in once with
# the "kitchen-display" HA user and tick "Keep me logged in".
# To get back to the desktop: plug in a keyboard and press Alt+F4.

set -euo pipefail

URL="${1:-}"
if [[ -z "$URL" ]]; then
  echo "Usage: $0 <home-assistant-dashboard-url>" >&2
  exit 1
fi
if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal desktop user, not root (sudo is used where needed)." >&2
  exit 1
fi

echo "==> Updating packages"
sudo apt-get update
sudo apt-get -y full-upgrade

# Chromium is 'chromium' on Raspberry Pi OS (Trixie) and 'chromium-browser' on Bookworm.
echo "==> Installing Chromium and helpers"
if apt-cache show chromium >/dev/null 2>&1; then
  sudo apt-get install -y chromium curl
else
  sudo apt-get install -y chromium-browser curl
fi
CHROMIUM="$(command -v chromium || command -v chromium-browser)"

echo "==> Disabling screen blanking (HA automations control the screen instead)"
sudo raspi-config nonint do_blanking 1 || true

echo "==> Writing kiosk launcher"
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/ha-kiosk" <<EOF
#!/usr/bin/env bash
# Clear the "Chromium didn't shut down correctly" bubble after power loss.
PREFS="\$HOME/.config/chromium/Default/Preferences"
if [[ -f "\$PREFS" ]]; then
  sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"[^"]*"/"exit_type":"Normal"/' "\$PREFS"
fi
# Wait for the network / HA server to answer before opening the page.
for _ in \$(seq 1 60); do
  curl -fs -o /dev/null --max-time 2 "$URL" && break
  sleep 2
done
exec "$CHROMIUM" \\
  --kiosk "$URL" \\
  --noerrdialogs --disable-infobars --no-first-run \\
  --disable-session-crashed-bubble --disable-features=Translate \\
  --check-for-update-interval=31536000 \\
  --overscroll-history-navigation=0
EOF
chmod +x "$HOME/.local/bin/ha-kiosk"

echo "==> Configuring autostart (XDG autostart works on the Wayland and X11 desktops)"
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/ha-kiosk.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Home Assistant Kiosk
Exec=$HOME/.local/bin/ha-kiosk
X-GNOME-Autostart-enabled=true
EOF

echo "==> Enabling desktop auto-login"
sudo raspi-config nonint do_boot_behaviour B4 || true

echo
echo "Done. Reboot with: sudo reboot"
