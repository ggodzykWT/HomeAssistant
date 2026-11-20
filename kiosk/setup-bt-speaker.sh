#!/usr/bin/env bash
# Connect the kitchen Bluetooth speaker to the Raspberry Pi display and expose
# it to Music Assistant as a player called "Kitchen" (media_player.kitchen).
#
# Run on the Pi as your normal desktop user, after setup-pi-kiosk.sh:
#   bash setup-bt-speaker.sh                       # scan and pick the speaker
#   bash setup-bt-speaker.sh AA:BB:CC:DD:EE:FF     # speaker MAC already known
#   bash setup-bt-speaker.sh AA:BB:CC:DD:EE:FF 192.168.1.50
#                         (optional 2nd arg: HA / Music Assistant server IP,
#                          only needed if the player doesn't show up on its own)
#
# What it sets up:
#   1. Pairs, trusts and connects the speaker.
#   2. A background service that reconnects the speaker whenever it wakes up
#      and keeps it as the default audio output.
#   3. Squeezelite, which Music Assistant sees as the "Kitchen" player.
#
# Put the speaker in pairing mode before running.

set -euo pipefail

MAC="${1:-}"
SERVER="${2:-}"
PLAYER_NAME="Kitchen"

if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal desktop user, not root." >&2
  exit 1
fi

echo "==> Installing packages"
sudo apt-get update
sudo apt-get install -y bluez pulseaudio-utils pipewire-alsa squeezelite

# The Debian package starts a system-wide squeezelite. It can't reach the
# desktop user's audio (and so the Bluetooth speaker), so we run our own as a
# user service instead.
sudo systemctl disable --now squeezelite 2>/dev/null || true

bluetoothctl power on >/dev/null

if [[ -z "$MAC" ]]; then
  echo "==> Scanning for Bluetooth devices for 20 seconds (speaker in pairing mode?)"
  bluetoothctl --timeout 20 scan on >/dev/null || true
  mapfile -t DEVICES < <(bluetoothctl devices | sed -n 's/^Device \([0-9A-F:]\{17\}\) \(.*\)$/\1  \2/p')
  if [[ ${#DEVICES[@]} -eq 0 ]]; then
    echo "No devices found. Put the speaker in pairing mode and run again." >&2
    exit 1
  fi
  echo "Pick your speaker:"
  select CHOICE in "${DEVICES[@]}"; do
    [[ -n "${CHOICE:-}" ]] && break
  done
  MAC="${CHOICE%%  *}"
fi

if [[ ! "$MAC" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
  echo "That doesn't look like a Bluetooth address: $MAC" >&2
  exit 1
fi
MAC="${MAC^^}"

echo "==> Pairing with $MAC"
bluetoothctl pair "$MAC" || echo "(pair reported an error; it may already be paired, continuing)"
bluetoothctl trust "$MAC"
bluetoothctl connect "$MAC" || echo "(couldn't connect yet; the reconnect service will keep trying)"

echo "==> Installing the reconnect service"
mkdir -p "$HOME/.local/bin" "$HOME/.config/systemd/user"
cat > "$HOME/.local/bin/bt-speaker-keepalive" <<EOF
#!/usr/bin/env bash
# Reconnect the kitchen speaker whenever it's on but not connected, and make
# it the default audio output so Squeezelite and Chromium play through it.
MAC="$MAC"
SINK_PATTERN="bluez_output.\${MAC//:/_}"
while true; do
  if ! bluetoothctl info "\$MAC" 2>/dev/null | grep -q "Connected: yes"; then
    bluetoothctl connect "\$MAC" >/dev/null 2>&1 || true
  fi
  SINK="\$(pactl list short sinks 2>/dev/null | awk -v p="\$SINK_PATTERN" '\$2 ~ p {print \$2; exit}')"
  if [[ -n "\$SINK" && "\$(pactl get-default-sink 2>/dev/null)" != "\$SINK" ]]; then
    pactl set-default-sink "\$SINK" || true
  fi
  sleep 20
done
EOF
chmod +x "$HOME/.local/bin/bt-speaker-keepalive"

cat > "$HOME/.config/systemd/user/bt-speaker-keepalive.service" <<EOF
[Unit]
Description=Keep the kitchen Bluetooth speaker connected
After=pipewire.service wireplumber.service

[Service]
ExecStart=%h/.local/bin/bt-speaker-keepalive
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

echo "==> Installing the Squeezelite player ($PLAYER_NAME) for Music Assistant"
SERVER_ARG=""
[[ -n "$SERVER" ]] && SERVER_ARG="-s $SERVER"
cat > "$HOME/.config/systemd/user/squeezelite-kitchen.service" <<EOF
[Unit]
Description=Squeezelite player "$PLAYER_NAME" for Music Assistant
After=pipewire.service wireplumber.service bt-speaker-keepalive.service
Wants=bt-speaker-keepalive.service

[Service]
# -o default : play through the default output (the Bluetooth speaker)
# -C 5       : let go of the speaker after 5 s of silence, so a phone can
#              still connect to it directly when the hub isn't playing
ExecStart=/usr/bin/squeezelite -n "$PLAYER_NAME" -o default -C 5 $SERVER_ARG
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Start user services at boot, even before the desktop finishes logging in.
sudo loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now bt-speaker-keepalive.service squeezelite-kitchen.service

echo
echo "Done. In Music Assistant, make sure the Squeezelite provider is added;"
echo "a player named \"$PLAYER_NAME\" should appear within a minute."
echo "Check status with: systemctl --user status bt-speaker-keepalive squeezelite-kitchen"
