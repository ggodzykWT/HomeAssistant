# Optional: adding a media server

A media server stores your own music, movies, TV shows and photos at home and
streams them to any screen or speaker. Once one is running, the Family Hub
can:

- play **your own music library** on the kitchen Bluetooth speaker (through
  Music Assistant), by voice or from the dashboard;
- show **family photos** as the kitchen display's screensaver;
- control what's playing on the **living-room TV** from Home Assistant;
- keep working even if a streaming service drops a song or raises its price.

You don't need this to replace the Echo Show. You can add it at any point
after the main build, and nothing in the main build has to change.

---

## 1. Pick the software

| Software | Best for | Cost | Home Assistant | Music Assistant |
|---|---|---|---|---|
| **Jellyfin** | Movies, TV and music; fully free and open source | Free | Jellyfin integration | ✅ Jellyfin provider |
| **Plex** | Polished apps on every TV, easy sharing with relatives | Free; Plex Pass (~$7/mo or lifetime) for hardware transcoding and extras | Plex integration | ✅ Plex provider |
| **Navidrome** | Music only, very lightweight | Free | (via Music Assistant) | ✅ Subsonic provider |
| **Immich** | Family photo backup from phones (a self-hosted Google Photos) | Free | Immich integration | — |

**Suggested combination:** **Jellyfin** (or Plex if family members already
use it) for video and music, plus **Immich** for photos.

## 2. Pick where it runs

The media server runs on the **server side**, never on the kitchen display.
Choose one of these options:

### Option 1: a NAS (recommended if you have lots of media)

A NAS (network storage box) such as a Synology, UGREEN or QNAP with Intel
graphics runs Jellyfin/Plex/Immich in Docker, next to your files.

- Keeps Home Assistant's server untouched and simple.
- Drives are built in, and you can mirror them (RAID 1) so one failed drive
  doesn't lose the family photos.
- The NAS also becomes a good target for Home Assistant's nightly backups.

### Option 2: one stronger mini PC running both (the best single box)

Buy a slightly stronger mini PC than the main guide suggests (Intel N150 or
N305, **16–32 GB RAM, 1 TB SSD**) and install **Proxmox** (free) on it.
Proxmox lets one machine run several separate systems side by side:

- a **Home Assistant OS** virtual machine (everything in the main guide,
  unchanged, add-ons included);
- a **Jellyfin or Plex** container with Intel QuickSync for smooth video
  playback on any device;
- an **Immich** container for photos;
- media files on the internal SSD or a USB drive.

If the media server crashes or needs updating, Home Assistant keeps running.
This route takes more setup than Option 1. Budget an extra evening.

### Option 3: a separate second mini PC

The same idea as Option 2, but on two physical boxes: the Home Assistant
mini PC from the main guide stays as is, and a second N100/N150 mini PC runs
Ubuntu or Debian with Docker for Jellyfin/Plex/Immich, plus a USB drive. It's
the easiest to understand, and each box can be replaced on its own.

### Not recommended: running it as a Home Assistant add-on

Community add-ons for Jellyfin and Plex exist, and they work for light use.
But big media libraries make Home Assistant's backups huge and slow, and heavy
video playback competes with voice and automations. Keep media on its own
system.

---

## 3. Set it up

The steps assume Jellyfin. Plex is almost identical.

1. **Install the server** using its official instructions for your chosen
   option:
   - Jellyfin: <https://jellyfin.org/docs/general/installation/>
   - Plex: <https://support.plex.tv/articles/200288586-installation/>
   - Immich: <https://immich.app/docs/install/requirements>
2. **Give it a fixed IP address** with a DHCP reservation in your router,
   just like the HA server.
3. **Organize the files** so the server recognizes them:
   ```
   /media/music/Artist/Album/01 - Song.flac
   /media/movies/Movie Name (2019)/Movie Name (2019).mkv
   /media/tv/Show Name/Season 01/Show Name S01E01.mkv
   ```
4. **Create libraries** (Music, Movies, TV) in the Jellyfin dashboard and let
   it scan.
5. **Turn on hardware transcoding** (Jellyfin: Dashboard → Playback →
   Transcoding → *Intel QuickSync*; Plex needs Plex Pass for this).
6. **Create users**: one per family member, plus a `homeassistant` user for
   the integrations below.

## 4. Connect it to the Family Hub

1. **Music on the kitchen speaker:** in **Music Assistant → Settings →
   Providers → Add**, choose **Jellyfin** (or Plex, or Subsonic for
   Navidrome), and sign in with the `homeassistant` user. Your library now
   appears alongside Spotify, and "Kitchen" can play it. This is also a
   partial answer to the Amazon Music gap: songs you've bought can be
   downloaded from Amazon Music and added to the library.
2. **Controls in Home Assistant:** **Settings → Devices & services → Add
   integration → Jellyfin** (or **Plex**). You get a media player entity for
   each TV or app that's playing, so automations can, for example, dim the
   living room lights when a movie starts.
3. **Photo frame:** add the **Immich** integration in Home Assistant, create
   an album such as "Kitchen Frame" in Immich, and point the Wallpanel
   screensaver at it in `config/dashboards/family-hub.yaml`. Wallpanel's
   documentation shows the exact `image_url` format for Immich.
4. **Voice:** "Play my Road Trip playlist in the kitchen" works through Music
   Assistant once the provider is added (best with an LLM conversation
   agent; see Phase 8 of the main guide).

## 5. Use the coax in your walls

Streaming video over Wi-Fi is the most common cause of buffering. If the
media server and TVs are near coax jacks, **MoCA adapters** give them a wired
connection over the existing cable. An antenna on the same coax plus an
**HDHomeRun** tuner lets Jellyfin/Plex offer live TV and a DVR. See
[`coax-moca.md`](coax-moca.md).

## 6. Remote access and backups

- To watch outside the house, use **Tailscale** on the media server (the
  same approach as Home Assistant). Avoid opening ports on your router.
- Back up **Immich photos** to a second place: a USB drive rotated monthly,
  or a cloud backup service such as Backblaze B2. A mirrored NAS on its own
  isn't a backup.
- Music and movies can usually be re-ripped or re-downloaded; family photos
  can't. Back those up first.
