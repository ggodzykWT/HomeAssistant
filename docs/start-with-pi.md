# Getting started with just the Raspberry Pi

You don't have to wait for the server. The Raspberry Pi can **run Home
Assistant temporarily**. Everything you set up on it moves to the server
later with a single backup file, and then the Pi becomes the kitchen display
as planned.

```
 Now:     Raspberry Pi = Home Assistant server (temporary)
          Dashboard on phones / laptop / any tablet browser

 Later:   Backup ──► restore on the mini PC (everything moves over)
          Raspberry Pi wiped ──► kitchen display + Bluetooth speaker bridge
```

Nothing you do now is wasted.

---

## What works on the Pi, and what waits for the server

| Phase | Do it now on the Pi? | Notes |
|---|---|---|
| 0 Inventory | ✅ | No hardware needed. |
| 2 Install Home Assistant | ✅ | Home Assistant OS on the Pi (below). |
| 3 Lights and plugs | ✅ | Moves to the server in the backup. |
| 4 Nest thermostat | ✅ | Moves over, and keeps working after the move. |
| 5 Cozi calendar | ✅ | |
| 6 Music Assistant | ✅ partly | Add Spotify etc. now. Play to an existing Chromecast/Sonos/AirPlay speaker, or skip playback for now. The Bluetooth speaker has to wait until the Pi becomes the display. |
| 7 Arlo cameras | ✅ | |
| 8 Voice | ⚠️ | Typed commands work everywhere. If you already have a Voice PE, use the Home Assistant Cloud free trial for speech; local speech recognition is slow on a Pi. |
| 9 Kitchen display | ❌ wait | The Pi is busy being the server. Use a phone, tablet or laptop browser to see the dashboard meanwhile. |
| 10 Dashboard | ✅ | Build and tweak it in any browser. |
| 11 Routines | ✅ | |
| 13 Media server | ❌ wait | Not on the Pi. |

---

## Step 1: Check your Pi (5 minutes)

- **Raspberry Pi 5 or Pi 4 with at least 4 GB RAM:** good.
- **Pi 4 with 2 GB:** works for lights, Nest, Cozi and Arlo. Music Assistant
  may be sluggish.
- **Pi 3 or older:** works for basics only, so expect it to be slow.
- **Storage:** a good-quality microSD card (A2 rated, 32 GB+) is fine for a
  few months. A USB SSD is better if you have one.
- **Network:** plug the Pi into the router with an **Ethernet cable** if you
  can. Wi-Fi works but is less reliable for a server.

## Step 2: Install Home Assistant OS on the Pi (30–60 minutes)

1. On a computer, install **Raspberry Pi Imager**
   (<https://www.raspberrypi.com/software/>).
2. **Choose device** → your Pi model. **Choose OS** → *Other specific-purpose
   OS* → *Home assistants and home automation* → **Home Assistant**.
   **Choose storage** → the SD card (or USB SSD). Write it.
3. Put the card in the Pi, connect Ethernet, power it on, and wait about 5
   minutes.
4. On a phone or computer, open `http://homeassistant.local:8123`. If that
   doesn't load, use the Pi's IP address from your router's device list.
5. Choose **Create my smart home**. Do *not* choose "restore" (that's for
   later, on the server).
6. Continue with **Phase 2** of the main guide: owner account, HACS,
   people, Companion apps.

> The Pi's touchscreen will only show a text screen while it runs Home
> Assistant OS. That's normal.

## Step 3: Set up the integrations (an evening or two)

Follow the main guide's phases in order:

- **Phase 3:** lights and plugs, and assign rooms.
- **Phase 4:** Nest. The Google Device Access registration and OAuth setup
  carry over to the server, so you only do them once.
- **Phase 5:** Cozi calendar feed.
- **Phase 6:** Music Assistant add-on and your Spotify account.
- **Phase 7:** Arlo (Aarlo from HACS).
- **Phases 10–11:** the dashboard (`config/dashboards/family-hub.yaml`) and
  automations (`config/packages/family_hub.yaml`).

Two temporary adjustments while the Pi is the server:

- The kitchen speaker entity (`media_player.kitchen`) won't exist yet. Point
  announcements at another speaker you already have, or leave those
  automations off until the display is built.
- The display-screen automations (screen on/off) don't apply yet. Leave them
  turned off (Settings → Automations → toggle).

## Step 4: Things to prepare in parallel (no Pi needed)

- **Fill in the inventory** in [`device-inventory.md`](device-inventory.md).
- **Copy the Cozi feed URLs** (Cozi → Settings → Shared Cozi Calendars).
- **Create the Arlo "friend" account** and an email box with an app
  password for 2FA (Phase 7).
- **Check your wiring:** open one phone jack and read the cable
  ([`phone-jacks.md`](phone-jacks.md)), and look at your coax splitter
  ([`coax-moca.md`](coax-moca.md)). That decides where the server can live.
- **Pick photos** for the screensaver and put them in one folder.
- **Decide on the server** (basic mini PC, or a stronger one for a future
  media server). See [`media-server.md`](media-server.md).

---

## Step 5: Move to the server when it arrives (1 hour)

1. **On the Pi:** Settings → System → **Backups** → **Back up now** →
   **Full backup**. When it finishes, **download** the backup file to your
   computer.
2. **Save the backup encryption key.** Home Assistant encrypts backups; find
   the key under Settings → System → Backups → ⋮ → *Encryption key*. Without
   it the backup can't be restored. Store it in a password manager.
3. **Shut down the Pi** (Settings → System → ⋮ → Shut down) so two Home
   Assistants never run at once.
4. **Install Home Assistant OS on the mini PC** (Phase 2, steps 1–2 of the
   main guide).
5. At the welcome screen choose **Upload backup** (restore), pick the file,
   and enter the encryption key. Wait 10–30 minutes.
6. **Router:** move the fixed-IP (DHCP reservation) from the Pi to the mini
   PC, or update bookmarks to the new address.
   `http://homeassistant.local:8123` keeps working either way.
7. **Check** that lights, Nest, Cozi, Arlo and Music Assistant all work.
   Anything that complains can be fixed under Settings → Devices &
   services → **Reconfigure**.
8. If you bought a Zigbee/Thread USB radio, move it from the Pi to the mini
   PC; the paired devices come along with the backup.

## Step 6: Turn the Pi into the kitchen display

Now do **Phase 9, Option B** of the main guide:

1. Re-flash the Pi with **Raspberry Pi OS (64-bit, with desktop)**. This
   wipes Home Assistant from the Pi, which is fine because it now lives on
   the server.
2. Run [`kiosk/setup-pi-kiosk.sh`](../kiosk/setup-pi-kiosk.sh) with the
   server's dashboard address.
3. Run [`kiosk/setup-bt-speaker.sh`](../kiosk/setup-bt-speaker.sh) to pair
   the kitchen Bluetooth speaker. `media_player.kitchen` then appears.
4. Turn the announcement and display-screen automations back on.
