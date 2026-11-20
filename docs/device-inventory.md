# Device inventory worksheet (Phase 0)

Fill this in from the Alexa app (**Devices** and **More → Routines**) before
you start. The *HA integration* column tells you what to add in Phase 3.

## Devices

| Device name (in Alexa) | Room | Type | Brand | App it uses | HA integration | Added to HA? |
|---|---|---|---|---|---|---|
| Hallway thermostat | Hallway | Thermostat | Google Nest | Google Home | Google Nest | ☐ |
| Front door camera | Outside | Camera | Arlo | Arlo | Aarlo (HACS) | ☐ |
| Kitchen ceiling | Kitchen | Bulb | | | | ☐ |
| Living room lamp | Living Room | Plug | | | | ☐ |
| | | | | | | ☐ |
| | | | | | | ☐ |
| | | | | | | ☐ |

Common brand → integration mapping:

- Philips Hue → **Philips Hue**
- Kasa / Tapo → **TP-Link Smart Home**
- Smart Life / Tuya / Gosund / Treatlife / many Amazon no-name → **Tuya** (or **LocalTuya** from HACS)
- Govee → **Govee lights local** (turn on *LAN Control* in the Govee app first)
- Wyze → **Wyze** (HACS)
- Meross → **Meross LAN** (HACS)
- Lutron Caséta → **Lutron Caséta**
- Ring → **Ring**
- Anything with a Matter logo → **Matter** (add via the HA Companion app; you can share it from Alexa using Matter multi-admin)
- Amazon Basics / "Alexa-only" plugs → usually **no** HA support — plan to replace (~$10–15 each with a Matter or Zigbee plug)

## Routines

| Routine name | Trigger (voice phrase / time / device) | Actions | Recreated in HA? |
|---|---|---|---|
| Good morning | 6:30 weekdays | Kitchen lights on, thermostat 68°, weather report | ☐ |
| Good night | "Alexa, good night" | All lights off, thermostat 64° | ☐ |
| | | | ☐ |
| | | | ☐ |

## Echo Show features we actually use

- [ ] Calendar on screen
- [ ] Shopping list
- [ ] Timers / alarms
- [ ] Music (which services: ____________ )
- [ ] Camera view / doorbell pop-up
- [ ] Photo frame
- [ ] Weather
- [ ] Drop-in / announcements
- [ ] Video calls
- [ ] Other: ____________
