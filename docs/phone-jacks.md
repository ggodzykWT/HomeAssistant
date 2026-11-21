# Using old phone (RJ11) jacks for networking

Many homes have a phone jack in every room. Depending on the wire behind them,
those jacks can become **real Ethernet ports**, which is the best result, or
carry a network signal with adapters. Ten minutes with a screwdriver tells
you which.

## Which network option to use (best first)

1. **The phone wire is Cat5e/Cat6 and runs to a central box** → convert the
   jacks to Ethernet (Option A below). Full gigabit with no adapters.
2. **Coax jack in the room** → MoCA adapters ([`coax-moca.md`](coax-moca.md)).
   Up to ~2.5 Gbps.
3. **Phone wire is older (Cat3 / "quad" wire) or chains jack to jack** →
   G.hn phone-line adapters (Option B). Roughly 100–500 Mbps, still better
   than weak Wi-Fi.
4. Otherwise: powerline adapters or mesh Wi-Fi.

You can mix them, for example converted phone jacks in bedrooms and MoCA in
the living room.

---

## Step 1: Make sure the phone line is dead (5 minutes)

Before touching wires:

- If you still have **landline or DSL service** on these jacks, pick jacks
  that aren't used, or plan around them. Ethernet and active phone service
  can't share the same wires.
- Find the **phone company's box outside** (the "NID", a gray box by the
  electric meter). Unplug the house wiring from it at the customer test jack.
  A ringing phone line carries about 90 V, enough to damage network gear
  and give you a jolt.

## Step 2: Look at the wire (10 minutes per jack)

1. Unscrew a jack's wall plate and gently pull it out.
2. **Read the cable jacket.** It's printed every foot or so:

   | Printed on cable | What it means |
   |---|---|
   | **CAT 5E**, **CAT 6** | 🎉 Ethernet-capable. Gigabit works. |
   | **CAT 5** | Ethernet-capable. Gigabit usually works on short runs. |
   | **CAT 3** | Phone-grade. 100 Mbps Ethernet at best, or use G.hn adapters. |
   | Flat, or 4 wires (red/green/yellow/black), nothing printed | Old "quad" wire. Use G.hn adapters (Option B). |

3. **Count the cables in the box:**
   - **One cable** → it probably runs straight back to a central spot (a
     "home run"). Good.
   - **Two cables** (one in, one out) → the jacks are **daisy-chained**
     room to room. That rules out normal Ethernet; use Option B.
4. **Find where the cables meet.** Look in the basement, a utility or
   laundry room, the garage, or a wall panel (often a gray/white
   "structured media" box, or a small block where many cables land). If
   every room's cable ends there, you have home runs.

## Option A: Convert phone jacks to Ethernet (Cat5e home runs)

**What you need:** RJ45 keystone jacks and wall plates (~$2–4 each), a small
**patch panel** or RJ45 keystones at the central spot, a **punch-down tool**
(~$10), a **network cable tester** (~$15), and a network switch (~$25–40 for
8 ports) at the central spot.

1. **At each room jack:** cut off the old RJ11 jack and punch the wires
   into an **RJ45 keystone** using the **T568B** color order printed on the
   jack. Snap it into a new wall plate.
   - Cat5e has 4 pairs (8 wires). Use all 8; phone jacks often only used 2.
2. **At the central spot:** do the same into a patch panel or keystones,
   also **T568B**. Remove the old phone distribution block from these cables.
3. **Test each run** with the cable tester (all 8 lights in order).
4. **Connect** a short patch cable from each run to a **network switch**,
   and the switch to your router. If the router is elsewhere, link the
   switch back to it with one converted run, or with a MoCA adapter.
5. Now any room's wall plate is a wired port: plug in the HA server, the
   media server/NAS, a TV, a mesh Wi-Fi node, or the kitchen Pi display.

Tip: keep one pair for a phone, if anyone still needs one. Most people
don't, and using all 4 pairs for gigabit is better.

## Option B: G.hn phone-line adapters (old or daisy-chained wire)

G.hn adapters (for example gigacopper or other "G.hn over phone line"
Ethernet extenders, ~$60–120 per pair) send a network signal over existing
phone wire, much like MoCA does over coax.

1. Plug one adapter into a phone jack near the router and connect it to a
   router **LAN** port with Ethernet.
2. Plug another into a phone jack in the target room and connect the device
   (HA server, TV, mesh node) to it.
3. They pair automatically, or with a button press. Expect about 100–500
   Mbps depending on wire age and distance: plenty for the HA server, the
   Pi display and HD streaming, and borderline for 4K.
4. Point-to-point (two adapters) is the most reliable. Some models allow
   several adapters on one line; check the product notes.

---

## How this fits the Family Hub

| Device | Best wired option |
|---|---|
| Home Assistant server (closet/basement) | Converted phone jack (A), or MoCA |
| Media server / NAS (Phase 13) | Converted phone jack (A) or MoCA, for 4K streaming |
| TVs / streaming boxes | Converted jack (A) or MoCA |
| Mesh Wi-Fi nodes | Any wired option: better Wi-Fi for bulbs, plugs, Arlo cameras, Voice PE |
| Kitchen Pi display | Converted jack if handy. Wi-Fi is fine for it. |

None of this changes anything in Home Assistant: devices keep the same
addresses, and the DHCP reservations from Phase 2 still apply.
