# Using your home's coax cable (MoCA)

Most homes have coax (TV cable) jacks in several rooms. With **MoCA
adapters** ("Multimedia over Coax"), that same cable carries a fast, wired
network connection. It's nearly as good as running new Ethernet cable, with
no drilling or fishing wires through walls.

## Why it helps the Family Hub

| Where | Benefit |
|---|---|
| **Home Assistant server** | It can live in any room with a coax jack (a closet, basement, office) and still be wired. This was a requirement in Phase 2. |
| **Media server / NAS** (Phase 13) | Smooth 4K streaming to TVs. Wi-Fi is the usual cause of buffering. |
| **TVs and streaming boxes** | Wired connection for Jellyfin/Plex playback. |
| **Mesh Wi-Fi nodes** | Wired backhaul makes every node as fast as the main router. Better coverage for bulbs, plugs, Arlo cameras and the Voice PE. |
| **Kitchen display** (optional) | If there's a coax jack nearby, wire the Pi for a rock-solid dashboard. Wi-Fi is also fine for it. |

You also keep any cable TV or antenna service on the same coax. MoCA uses
different frequencies and runs alongside it.

**Typical performance (MoCA 2.5):** about 1–2.5 Gbps real-world, with
~3–5 ms latency. That's far more than any of these devices need.

---

## Step 1: Check what you have (30 minutes)

1. **Find where the coax enters the house**, usually by the electric meter,
   in the basement, a utility closet or the garage. Follow it to the main
   **splitter**: a metal block with one input and several outputs.
2. **Figure out which jacks are live.** Each splitter output should run to a
   room. Label them. A cheap coax tone tester (~$15) speeds this up, or plug
   a TV into each jack.
3. **Read the splitter's rating.** It's printed on the splitter, e.g.
   "5–1002 MHz" or "5–1675 MHz". MoCA 2.5 needs **5–1675 MHz** (often labeled
   "MoCA"). Older splitters usually still work but slow it down. Replace them
   if speeds are poor.
4. **Look for an amplifier** (a powered box on the coax line). Many block
   MoCA. Bypass it, or replace it with a MoCA-compatible amplifier with a
   passive return path.
5. **Know what the coax is used for today.** This decides the next step:

| Current use | MoCA works? | Notes |
|---|---|---|
| Cable internet / cable TV (Comcast/Xfinity, Spectrum, Cox…) | ✅ | Add a **PoE filter** (step 2). |
| Antenna (over-the-air TV) | ✅ | Works alongside. See "Bonus: free live TV" below. |
| Nothing (unused) | ✅ | Easiest case. Add a PoE filter where the cable enters anyway. |
| **Verizon Fios** | ⚠️ Usually | The Fios router may already use MoCA. Either use it as your MoCA network, or set your adapters to a non-conflicting channel. Check before buying. |
| **DirecTV / satellite** | ❌ Usually not | Satellite uses the same frequencies. Ask the provider, or use powerline or Ethernet instead. |

## Step 2: Install a PoE filter ($5–10)

A **Point-of-Entry (PoE) filter** screws onto the input of the main splitter
(where the provider's cable comes in). It:

- keeps your MoCA network **inside your home** (privacy; neighbors on the
  same cable line can't see it);
- **reflects the signal back** through your splitter, which improves speed;
- prevents interference with your cable modem.

Make sure it's rated for MoCA (it will say "MoCA filter" and block above
~1000/1125 MHz).

> Note: unrelated to "PoE" as in Power over Ethernet. Same letters, different
> meaning.

## Step 3: Buy adapters

You need **one adapter at the router** plus **one in each room** you want to
wire. Most homes need 2–4.

- Look for **MoCA 2.5** adapters with a 2.5 GbE port (for example goCoax
  MA2500D, ScreenBeam ECB6250, Hitron/Motorola MoCA 2.5 models). They're
  about $60–90 each, or less in 2-packs.
- If your cable modem/router or mesh system already has MoCA built in (many
  Xfinity/Spectrum gateways and Fios routers do), that counts as the router
  adapter.
- Each adapter has two coax ports: **"In"** from the wall jack and **"TV
  Out"**, which passes TV through if you also have a TV or cable box there.

## Step 4: Connect (15 minutes per room)

1. **At the router:** coax from the wall → adapter **In**. Ethernet from
   the adapter → a **LAN** port on the router (not the WAN/internet port).
   If the modem is in the same spot, put a MoCA-rated 2-way splitter in front
   of it so modem and adapter both get coax.
2. **In each room:** coax from the wall → adapter **In**. Ethernet from the
   adapter → the device: HA server, NAS, TV, mesh node. Use a small network
   switch if more than one device is there.
3. Power everything on. The adapters link automatically (their link light
   turns solid). Most are plug and play.
4. **Turn on encryption** if your adapters support it. Usually a button
   pair, or a password set in their web page, same on every adapter.

## Step 5: Test

1. From a laptop plugged into a remote adapter, run a speed test, or use
   `iperf3` between two wired machines.
2. Expect several hundred Mbps to 2+ Gbps. If it's low:
   - replace old splitters with 5–1675 MHz ones;
   - remove unused splitter outputs and put a 75 Ω terminator cap on any
     empty port;
   - check for amplifiers and loose connectors;
   - confirm the PoE filter is on the input side of the main splitter.
3. In Home Assistant, the server's IP stays the same (DHCP reservation from
   Phase 2). Nothing in HA needs to change.

---

## Suggested layout for the Family Hub

```
 Provider cable ──[PoE filter]──[main splitter 5–1675 MHz]
                                   │        │         │          │
                               Office    Closet    Living     Kitchen
                              (router)  (servers)    room    (optional)
                                 │         │          │          │
                              [MoCA]    [MoCA]     [MoCA]     [MoCA]
                                 │         │          │          │
                              Router    switch ──  TV/stream   Pi display
                              LAN port   ├ HA server  box +
                                         └ NAS /      mesh node
                                           media server
```

## Bonus: free live TV on the media server

If you have (or add) a TV antenna on the coax, an **HDHomeRun** network tuner
(~$100–200) turns over-the-air channels into network streams:

- **Jellyfin or Plex** (Phase 13) can show live TV and record shows, like a
  DVR, to every TV, phone and tablet in the house.
- Antenna TV signals run below 700 MHz and MoCA runs above 1125 MHz, so both
  share the same coax.

## Alternatives if coax isn't an option

- **Powerline adapters** use electrical wiring. Slower and less consistent
  than MoCA, but no coax needed.
- **Ethernet cable** remains the best if you can run it. Flat cables tucked
  along baseboards work for short distances.
- **Mesh Wi-Fi with wireless backhaul**: fine for the display and voice
  devices, less good for the server and media streaming.
