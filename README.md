# Homegrown Family Hub — Replacing the Echo Show with Home Assistant

This repo is a step-by-step build guide (plus starter config) for replacing an
Amazon Echo Show with a self-built, locally controlled smart display running
[Home Assistant](https://www.home-assistant.io/).

**What the finished device does**

| Echo Show feature | Homegrown replacement |
|---|---|
| Family calendar on screen | Cozi calendar feed (ICS) → Home Assistant calendar → week-view card |
| Shopping / to-do lists | Home Assistant to-do lists (optional unofficial Cozi list sync) |
| Thermostat control | Google Nest integration (official) |
| Music (Amazon Music / Spotify / Pandora) | Music Assistant + Spotify Connect; see the Amazon Music caveat |
| Smart bulbs and plugs | Native HA integrations (Hue, Kasa, Tuya, Matter, Zigbee…) |
| Arlo cameras on screen | `aarlo` community integration + camera card |
| "Alexa, …" voice | Home Assistant Assist + Home Assistant Voice Preview Edition |
| Routines | Home Assistant automations and scripts |
| Photo frame when idle | Wallpanel screensaver (photos from a local folder or Immich) |
| Timers, weather, clock | Assist timers, weather integration, dashboard cards |
| *(new)* Your own music, movies and photos | Optional media server: Jellyfin/Plex + Immich ([Phase 13](#phase-13--optional-add-a-media-server)) |

**What does *not* carry over cleanly** (know this before you start)

- **Amazon Music** has no third-party API, so the hub can't play it directly
  (workarounds are in Phase 6).
- **Drop-in and video calls** to other Echo devices go away. Use phone video
  calls, or HA's announce/broadcast to Voice devices for "dinner's ready".
- **Adding events to Cozi by voice or from the screen** isn't possible. Cozi's
  feed is read-only, so keep adding events in the Cozi app.
- **Alexa skills** (trivia, recipes) have no direct equivalent. An LLM
  conversation agent covers a lot of general questions.

---

## Architecture

```
                ┌──────────────────────────────┐
                │  Home Assistant server        │  (mini PC or Raspberry Pi 5,
                │  - HA OS                      │   lives in a closet, wired
                │  - Music Assistant add-on     │   ethernet)
                │  - Whisper / Piper (voice)    │
                └──────┬───────────────┬───────┘
          Wi-Fi/LAN    │               │   Cloud APIs
   ┌───────────────────┼───────┐       ├── Google Nest (SDM API)
   │                   │       │       ├── Arlo cloud
┌──▼───────────┐ ┌─────▼─────┐ │       ├── Cozi ICS feed
│ Kitchen      │ │ HA Voice  │ │       └── Spotify
│ display      │ │ PE (mic + │ │
│ (touchscreen │ │ speaker)  │ │   Bulbs / plugs (Wi-Fi, Zigbee, Matter)
│  kiosk)      │ └───────────┘ └──────────────────────────────────
└──────┬───────┘
       │                 ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐
       │                   Optional media server (Phase 13)
       │                 │ Jellyfin / Plex + Immich, on a  │
       │                   NAS or a second mini PC
       │                 └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
       │ Bluetooth
┌──────▼───────┐
│ Kitchen BT   │  music, announcements, doorbell chime
│ speaker      │
└──────────────┘
```

Splitting the **server** from the **display** is the key design choice. The
server runs 24/7 and does all the work; the display is a "dumb" touchscreen
that shows a dashboard **and** is the Bluetooth bridge to your kitchen
speaker. (The HA server is in another room and Home Assistant OS can't stream
audio to Bluetooth speakers, which is why the display handles that.) You can
later add more displays (bedroom, office) without duplicating anything.

Why not run everything on the one Raspberry Pi in the kitchen? Home Assistant
OS has no screen output or Bluetooth audio. The workarounds lose the add-on
store or rely on unofficial add-ons. And a kitchen server on Wi-Fi that
anyone can unplug takes the whole house down with it. Two devices cost about
$100–150 more and are much more reliable.

A **media server** for your own music, movies and photos is an optional third
piece on the server side (Phase 13). It plugs into Music Assistant and the
display without changing anything else.

---

## Step-by-step build

Work through the phases in order. Each phase is usable on its own, so you can
leave the Echo Show running in parallel until the end.

### Phase 0 — Inventory what the Echo Show does today (1 hour)

1. Open the Alexa app → **Devices**. Write down every bulb, plug, camera and
   thermostat, its **brand** and its **app** (Kasa, Smart Life, Hue, Wyze…).
   Use [`docs/device-inventory.md`](docs/device-inventory.md) as the worksheet.
2. Open **More → Routines** and write down every routine (trigger + actions).
   These become HA automations in Phase 11.
3. Note what you actually use the screen for each day (calendar? cameras?
   timers? music?). That drives the dashboard layout in Phase 10.

> Why the brand matters: Home Assistant talks to each device through its own
> integration. A "Kasa" plug uses the TP-Link integration, a "Smart Life" plug
> uses Tuya, and so on. The inventory tells you which integrations to add.

### Phase 1 — Buy the hardware (see [`docs/shopping-list.md`](docs/shopping-list.md))

Minimum recommended kit (≈ $300–450 total):

- **Server:** Intel N100 mini PC (16 GB RAM, 256 GB+ SSD) *or* Home Assistant
  Green. A Raspberry Pi 5 (8 GB) with an NVMe SSD also works but has less
  headroom for local voice.
- **Display:** one of
  - **Option B (recommended with a Bluetooth speaker):** Raspberry Pi 5 (4 GB)
    + Raspberry Pi Touch Display 2 + case/stand, running Chromium in kiosk mode
    (script in [`kiosk/setup-pi-kiosk.sh`](kiosk/setup-pi-kiosk.sh)). The Pi's
    built-in Bluetooth connects to the kitchen speaker and shows up in Music
    Assistant as a speaker called "Kitchen", so music, announcements and the
    doorbell all play through it
    ([`kiosk/setup-bt-speaker.sh`](kiosk/setup-bt-speaker.sh)).
  - **Option A (simpler screen, weaker audio):** a 10″ Android tablet +
    wall/stand mount, running *Fully Kiosk Browser*. Pair the speaker to the
    tablet and play music from the Spotify / Pandora / Amazon Music apps on
    the tablet. HA can't easily send music or announcements to it, though.
- **Voice:** Home Assistant Voice Preview Edition (≈ $59): far-field mics,
  hardware mute switch, on-device wake word. Its own small speaker gives
  short replies ("OK, lights off"). Music and announcements go to the
  Bluetooth speaker.
- **Speaker:** your existing kitchen **Bluetooth speaker**, so nothing to buy.
  Ideally keep it on its charger and turn off its auto-power-off if it has
  that setting, because a speaker that sleeps drops the connection (the setup
  script reconnects automatically when it wakes).
- **Optional:** Zigbee/Thread USB radio (Home Assistant Connect ZBT-2 or
  similar) for future local-only bulbs and sensors.
- **No Ethernet where the server will live?** If there's a coax (TV cable)
  jack there, a pair of **MoCA adapters** (~$120–180) turns the coax into a
  wired network connection. See [`docs/coax-moca.md`](docs/coax-moca.md).
- **Planning a media server later?** Either keep this server as is and add a
  NAS or a second mini PC later, or buy a stronger mini PC now (N150/N305,
  16–32 GB RAM, 1 TB SSD) to run both. See
  [`docs/media-server.md`](docs/media-server.md) before you buy.

### Phase 2 — Install Home Assistant on the server (1–2 hours)

1. Download **Home Assistant OS** for your hardware from
   <https://www.home-assistant.io/installation/> and flash it
   (mini PC: write the "generic x86-64" image to the SSD; Pi: use Raspberry Pi
   Imager → *Other specific-purpose OS → Home assistant*).
2. Connect the server by **ethernet** (directly to the router, or through a
   MoCA adapter on your coax; see [`docs/coax-moca.md`](docs/coax-moca.md)),
   power it on, and browse to
   `http://homeassistant.local:8123`.
3. Create the owner account, set home location, units, and time zone.
4. In your router, give the server a **DHCP reservation** (fixed IP).
5. **Settings → Add-ons**: install **File editor** (or **Studio Code
   Server**) and **Terminal & SSH**.
6. Install **HACS** (community store) following <https://hacs.xyz/docs/use/>.
   Several pieces below (Arlo, calendar cards, kiosk tools) come from HACS.
7. **Settings → System → Backups**: enable automatic daily backups, ideally to
   a NAS or Google Drive (via the Google Drive backup location).
8. Create a **person** for each family member (**Settings → People**) and
   install the Home Assistant Companion app on everyone's phone for presence
   and notifications.

### Phase 3 — Lights and plugs (1–2 hours)

1. **Settings → Devices & services**. HA auto-discovers many devices — click
   **Configure** on each discovered card.
2. For the rest, **+ Add integration** by brand, using your inventory:

   | Brand / app | Integration | Local? |
   |---|---|---|
   | Philips Hue | Philips Hue | ✅ local via the bridge |
   | TP-Link Kasa / Tapo | TP-Link Smart Home | ✅ local |
   | Smart Life / Tuya / many no-name brands | Tuya (or *LocalTuya* via HACS) | ☁️ cloud (LocalTuya = local) |
   | Govee | Govee lights local (enable LAN control in Govee app) | ✅ local |
   | Wyze | *Wyze* via HACS | ☁️ cloud |
   | Matter devices | Matter (add via the HA Companion app) | ✅ local |
   | Lutron Caséta | Lutron Caséta | ✅ local |

3. **Settings → Areas**: assign every device to a room (Kitchen, Living Room…).
   Voice commands and the dashboard rely on areas ("turn off the kitchen").
4. Rename entities to friendly names you'd actually say out loud.
5. Long term: when replacing bulbs/plugs, prefer **Zigbee, Thread/Matter or
   Z-Wave** devices — they keep working when the internet is down.

### Phase 4 — Nest thermostat (45 minutes, one-time $5 fee)

The official **Google Nest** integration uses Google's Smart Device Management
API. HA's setup wizard walks you through it; the outline is:

1. Make sure the thermostat is in the **Google Home** app on a **personal
   Google account** (Device Access does not support Google Workspace /
   school / work accounts).
2. Register at the **Device Access Console**
   (<https://console.nest.google.com/device-access>) and pay the one-time
   $5 fee.
3. In **Google Cloud Console**, create a project, enable the **Smart Device
   Management API** and **Cloud Pub/Sub API**, and create an **OAuth client
   ID** (type *Web application*) with redirect URI
   `https://my.home-assistant.io/redirect/oauth`.
4. In the Device Access Console, create a project using that OAuth client ID
   and enable events (Pub/Sub).
5. In HA: **Settings → Devices & services → + Add integration → Google Nest**,
   paste the IDs when asked, sign in, and grant access to the thermostat.
6. You now have a `climate.` entity (e.g. `climate.hallway`) plus temperature
   and humidity sensors.

Full guide: <https://www.home-assistant.io/integrations/nest/>

### Phase 5 — Cozi calendar and lists (30 minutes)

Cozi has no official API, but it **publishes an ICS calendar feed**, which is
all we need to show the calendar.

1. In Cozi (web at <https://my.cozi.com> is easiest): open **Settings →
   Shared Cozi Calendars** (sometimes labelled *Calendar feeds* / *Send Cozi
   to other calendars*). Copy the feed URL for the **whole family**, and
   optionally one per family member so each person gets their own color.
2. In HA: **Settings → Devices & services → + Add integration → Remote
   Calendar**. Paste the feed URL and name it (e.g. "Cozi Family"). Repeat for
   each member feed.
   - Older HA versions: install **ICS Calendar** from HACS instead.
3. Result: `calendar.cozi_family` (etc.) entities that the dashboard and
   voice ("what's on the calendar today?") can read.
4. **Limitation:** the feed is **read-only** and refreshes periodically (not
   instantly). Keep adding events in the Cozi app as you do today.
5. **Lists:** use HA's built-in **Shopping List** / **Local To-do** (voice:
   "add milk to the shopping list"). If you want Cozi's lists themselves on
   the screen, there is an unofficial *Cozi* integration on HACS — it uses
   Cozi's private API, so treat it as "may break".

### Phase 6 — Music (1–2 hours)

1. **Settings → Add-ons → Add-on store → Music Assistant** → Install → Start.
   Then add the **Music Assistant** integration when HA prompts.
2. In the Music Assistant UI, add **music providers**:
   - **Spotify** — fully supported (Premium required). Music Assistant can also
     expose each speaker as a **Spotify Connect** target, so the Spotify app on
     any phone can play to the kitchen.
   - **Pandora** — check Music Assistant's current provider list; if it isn't
     listed for your version, pair your phone straight to the Bluetooth speaker
     for Pandora.
   - **Amazon Music** — ⚠️ *not supported*: Amazon offers no public API for
     third-party players. Options: (a) keep one Echo Dot around purely as a
     speaker and control it with the *Alexa Media Player* HACS integration,
     (b) pair your phone straight to the kitchen Bluetooth speaker (most
     speakers remember several devices; the Pi reconnects once your phone
     lets go), or (c) consolidate onto Spotify. This is the one
     feature that truly doesn't come along cleanly.
   - Also available: internet radio (TuneIn / Radio Browser), YouTube Music,
     Tidal, Apple Music and more.
   - **Your own library:** local files on a NAS, or a Jellyfin / Plex /
     Navidrome media server. See Phase 13.
3. Add the **Squeezelite (Slimproto)** player provider in Music Assistant
   (Settings → Providers → Add → *Squeezelite*). Once the Pi display is set up
   in Phase 9, a player called **Kitchen** appears. That's your Bluetooth
   speaker, and it shows up in HA as `media_player.kitchen`.
4. Enable **Spotify Connect** for the Kitchen player in Music Assistant, so
   anyone can pick "Kitchen" in the Spotify app on their phone.
5. Later you can add other speakers (Sonos, Chromecast, AirPlay) and group
   them for whole-house audio.

### Phase 7 — Arlo cameras (1 hour)

There is no official Arlo integration. Use the well-maintained community one:

1. In the Arlo app, **invite a second "friend" account** (a separate email)
   with *Allow access rights*. Using a dedicated account keeps HA from logging
   your phone out.
2. Set that account's 2-factor method to **email**, and use an email box HA
   can read over IMAP (e.g. a Gmail with an app password), so HA can complete
   2FA automatically.
3. HACS → search **Aarlo** → install → restart HA → configure with the friend
   account and IMAP details (see <https://github.com/twrecked/hass-aarlo>).
4. You'll get camera, motion, battery and doorbell entities.
5. Cards: use the built-in *Picture glance* card for snapshots, or
   **Advanced Camera Card** (HACS) for live view, clips and timelines.
6. **Expectations:** Arlo is cloud-only, so live view takes a few seconds to
   start, and pulling streams frequently drains battery cameras. Show the
   latest snapshot by default and open live view on tap. If you later want
   fully local cameras, look at PoE cameras + the **Frigate** add-on.

### Phase 8 — Voice assistant: "Alexa" → "Okay Nabu" (1 hour)

1. **Settings → Voice assistants → Add assistant.** Choose:
   - **Fully local:** add-ons **Whisper** (speech-to-text) + **Piper**
     (text-to-speech). Needs the mini PC for snappy responses.
   - **Faster/easier:** **Home Assistant Cloud** (Nabu Casa, ≈ $65/yr —
     also gives you secure remote access and funds the project).
   - **Optional smarter conversations:** add an LLM conversation agent
     (e.g. Anthropic Claude, OpenAI, or local Ollama) and enable *Prefer
     handling commands locally* so device control stays fast and local.
2. Plug in the **Voice Preview Edition**, open the HA Companion app, and follow
   the setup prompt to join Wi-Fi and pick the assistant.
3. Pick a wake word (*Okay Nabu*, *Hey Jarvis*, *Hey Mycroft*…).
4. **Settings → Voice assistants → Expose**: expose only the entities you want
   controllable by voice.
5. Try: "Turn off the kitchen lights", "Set the thermostat to 68",
   "Set a timer for 10 minutes", "What's the weather?", "Add eggs to the
   shopping list", "What's on the calendar today?" (the last one needs an LLM
   agent or the calendar script in `config/packages/family_hub.yaml`).

### Phase 9 — Build the display (2–3 hours)

**Option B — Raspberry Pi + Touch Display 2 (recommended)**

1. Flash **Raspberry Pi OS (64-bit, with desktop)** with Raspberry Pi Imager.
   In the imager's settings set hostname `familyhub`, your Wi-Fi, a user, and
   enable SSH.
2. Attach the Touch Display 2 per its instructions and boot.
3. Copy [`kiosk/setup-pi-kiosk.sh`](kiosk/setup-pi-kiosk.sh) to the Pi and run:
   `bash setup-pi-kiosk.sh http://<server-ip>:8123/family-hub/home`
4. **Bluetooth speaker:** put the speaker in pairing mode, then copy
   [`kiosk/setup-bt-speaker.sh`](kiosk/setup-bt-speaker.sh) to the Pi and run
   `bash setup-bt-speaker.sh`. It scans for the speaker, lets you pick it,
   pairs it, makes it the default audio output, installs a background service
   that reconnects it whenever it wakes up, and installs **Squeezelite** so
   Music Assistant sees a player called "Kitchen".
5. Reboot. Chromium starts full-screen on the dashboard and the speaker
   reconnects.
6. Test: in Music Assistant, play something on **Kitchen**. Then in HA go to
   **Developer tools → Actions** and run `tts.speak` with
   `media_player_entity_id: media_player.kitchen`.
7. Optional: install **LNXlink** (a Linux companion agent that talks to HA
   over MQTT) so HA automations can blank/wake the Pi screen.

**Option A — Android tablet**

1. Factory reset the tablet, remove unneeded apps, disable auto-updates of
   the OS during school/work hours.
2. Install **Fully Kiosk Browser** (Plus license recommended, ≈ $9) and set the
   start URL to `http://<server-ip>:8123/family-hub/home`.
3. Enable *Kiosk mode*, *Motion detection* (screen wakes when someone walks
   up), *Keep screen on while plugged in*, and *Remote administration*.
4. In HA add the **Fully Kiosk Browser** integration — you can now turn the
   screen on/off and change brightness from automations.
5. Pair the Bluetooth speaker in Android Settings → Connected devices.

**Both options**

1. In HA create a dedicated **non-admin user** called `kitchen-display` and
   log the display in with it (tick *Keep me logged in*).
2. Install from HACS: **kiosk-mode** (hides the header/sidebar for that user)
   and **Wallpanel** (photo-frame screensaver after N minutes idle).

### Phase 10 — Dashboard (2–4 hours, iterate over a week)

1. HACS → install frontend cards: **Mushroom**, **Week Planner Card**,
   **Advanced Camera Card**, **kiosk-mode**, **Wallpanel**.
2. **Settings → Dashboards → + Add dashboard** → *New dashboard from
   scratch* → title "Family Hub", URL `family-hub`.
3. Open it → ✏️ → ⋮ → **Raw configuration editor** → paste
   [`config/dashboards/family-hub.yaml`](config/dashboards/family-hub.yaml)
   and replace the example entity IDs with yours
   (**Settings → Entities** lists them).
4. Recommended layout (landscape):
   - **Home view:** clock + weather, today/next 7 days from Cozi, thermostat,
     now-playing, quick light/plug buttons, shopping list.
   - **Cameras view:** Arlo snapshots, tap for live.
   - **Music view:** Music Assistant player and favourites.
   - **Rooms view:** areas with all lights/plugs.
5. Big touch targets, high contrast, minimal text — it's read from across the
   kitchen.

### Phase 11 — Recreate routines as automations (1–2 hours)

Use your Phase 0 routine list. Examples are in
[`config/packages/family_hub.yaml`](config/packages/family_hub.yaml):

- Morning: lights on at 6:30 on weekdays, thermostat to day temp, announce
  today's calendar on the kitchen Bluetooth speaker.
- Good night (voice: "good night"): all lights off, plugs off, thermostat
  setback.
- Arlo doorbell: announce it on the Bluetooth speaker (pausing music) and
  pop the camera up on the display.
- Display: screen off at night, on when someone is home in the morning.

To use the package file: in `configuration.yaml` add

```yaml
homeassistant:
  packages: !include_dir_named packages
```

then copy `config/packages/family_hub.yaml` into `/config/packages/`, edit the
entity IDs, and **Developer tools → YAML → Check configuration → Restart**.

### Phase 12 — Remote access, hardening, and cut-over

1. **Remote access:** Home Assistant Cloud (simplest) *or* Tailscale add-on.
   Do **not** port-forward 8123 to the internet.
2. Enable **multi-factor auth** on admin accounts (profile → Security).
3. Put IoT devices on a separate Wi-Fi/VLAN if your router supports it.
4. Run the new hub alongside the Echo Show for **1–2 weeks**. Keep a note of
   anything the family reaches for that's missing.
5. When nothing's missing: in the Alexa app, disable the routines, then
   deregister and factory-reset the Echo Show. (Devices connected via Alexa
   skills keep working through their own apps/HA.)

---

### Phase 13 — (Optional) Add a media server

Do this any time after the main build. Full guide:
[`docs/media-server.md`](docs/media-server.md).

1. **Choose the software:** **Jellyfin** (free) or **Plex** for music, movies
   and TV, and **Immich** for family photos.
2. **Choose where it runs** (never on the kitchen display):
   - a **NAS** (easiest if you have lots of files and want mirrored drives);
   - **one stronger mini PC running Proxmox**, with Home Assistant OS and the
     media server side by side; or
   - a **second mini PC** with Docker.
3. **Install the server**, organize your files, and create a
   `homeassistant` user.
4. **Connect it:**
   - add it as a **Music Assistant provider**, so your library plays on the
     kitchen Bluetooth speaker;
   - add the **Jellyfin/Plex** integration in HA to control TV playback;
   - add **Immich** so the display's screensaver shows a family photo album.
5. **Back up the photos** to a second location.
6. **Tip:** wire the media server and your TVs over **coax with MoCA
   adapters** for smooth 4K streaming. An antenna on the same coax plus an
   **HDHomeRun** tuner adds free live TV and DVR to Jellyfin/Plex. See
   [`docs/coax-moca.md`](docs/coax-moca.md).

---

## Ongoing maintenance

- Update HA monthly (first Wednesday-ish release cycle); read the release
  notes' *breaking changes* first. Backups happen automatically before updates.
- Update HACS integrations, especially Aarlo, when Arlo changes its cloud.
- Re-check the Cozi feed occasionally — if Cozi rotates the URL, update the
  Remote Calendar entry.

## Repo layout

```
README.md                          ← this guide
docs/shopping-list.md              ← hardware options and approximate prices
docs/device-inventory.md           ← Phase 0 worksheet
docs/media-server.md               ← Phase 13: optional Jellyfin/Plex/Immich
docs/coax-moca.md                  ← wired networking over existing coax
config/packages/family_hub.yaml    ← automations, scripts, helpers (edit IDs)
config/dashboards/family-hub.yaml  ← kitchen display dashboard (edit IDs)
kiosk/setup-pi-kiosk.sh            ← Raspberry Pi kiosk setup (Option B)
kiosk/setup-bt-speaker.sh          ← pair Bluetooth speaker + Music Assistant player
```
