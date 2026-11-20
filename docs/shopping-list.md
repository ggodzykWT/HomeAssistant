# Shopping list

Prices are approximate (USD, late 2026) and change often — use them for budgeting only.

## 1. Server (pick one)

| Option | ~Price | Notes |
|---|---|---|
| Intel N100 / N150 mini PC, 16 GB RAM, 256–512 GB SSD | $150–220 | **Recommended.** Fast enough for fully local voice (Whisper + Piper) and Music Assistant. |
| Home Assistant Green | $99–129 | Plug-and-play, but too slow for local speech-to-text — pair with Home Assistant Cloud for voice. |
| Raspberry Pi 5 (8 GB) + NVMe HAT + SSD + official PSU + case | $150–180 | Works well; avoid running from an SD card long term. |

## 2. Display (pick one)

| Option | ~Price | Notes |
|---|---|---|
| **B. (recommended)** Raspberry Pi 5 (4 GB) + Raspberry Pi Touch Display 2 (7″ or larger) + stand/case + 27 W PSU + 32 GB SD | $160–200 | Most "homegrown". Runs Chromium kiosk, and its built-in Bluetooth connects to the kitchen speaker as a Music Assistant player. |
| **A.** 10–11″ Android tablet (e.g. Lenovo Tab M11, Samsung Galaxy Tab A9+) | $150–230 | Easiest screen. Add Fully Kiosk Browser Plus (~$9) and a mount. Music only from apps on the tablet; HA can't easily announce through it. |
| Used 10″ touchscreen monitor + any mini PC/Pi | varies | Good for a bigger wall-mounted screen. |

## 3. Voice

| Item | ~Price | Notes |
|---|---|---|
| Home Assistant Voice Preview Edition | $59 | Wake word, far-field mics, hardware mute. Its small speaker handles short spoken replies. One per room you want voice in. |
| Kitchen speaker | $0 | Use your existing **Bluetooth speaker**, connected through the Pi display. Keep it on its charger and turn off auto-power-off if you can. |

## 4. Optional

| Item | ~Price | Notes |
|---|---|---|
| Home Assistant Connect ZBT-2 (Zigbee or Thread radio) | $45–50 | For local Zigbee / Thread bulbs, plugs, sensors. Use a USB extension cable. |
| Home Assistant Cloud (Nabu Casa) subscription | ~$65/yr | Remote access, cloud voice, Google/Alexa bridging. |
| Motion sensor near the display | $15–25 | Wake the screen when someone walks up (tablet camera can also do this). |
| UPS for server + router | $60–90 | Keeps the hub alive through brief outages. |

## Typical builds

- **Budget (~$300):** HA Green + Android tablet + Voice PE + HA Cloud.
- **Recommended (~$380):** N100 mini PC + Pi 5 Touch Display 2 kit + Voice PE + your Bluetooth speaker.
- **Fully local (~$430):** Recommended build + ZBT-2, gradually swap cloud bulbs/plugs for Zigbee/Matter.
