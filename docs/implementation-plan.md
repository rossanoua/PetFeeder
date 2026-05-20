# AiPetFeeder — Implementation Plan

Synthesizes `hardware/bom.md`, `docs/project-notes.md` and the OpenSCAD
models into a concrete functional plan: what each BOM component does,
how the firmware ties them together, and the order in which we add
capability. Every line item in the BOM has a defined role; nothing is
"bought because it's listed."

## TL;DR

A **closed-loop, weight-validated paddle-wheel dispenser**, controlled
by an ESP32 running ESPHome. Manual button + status display + scheduled
feeds + Home Assistant integration (no cloud). HX711 weighs every
portion; rotation continues until the target weight is reached, and
absence of weight change after rotation is the jam signal — so the
mechanism and the sensor share one feedback loop.

---

## 1. Component → function map

| BOM line | Role in the system | Phase |
|----------|--------------------|-------|
| Paddle wheel + housing + end cap (5a, 5b, 5c) | Primary dosing mechanism. One pocket ≈ one portion increment. | Stage 1 |
| Hopper (8) | Gravity feed into the wheel pocket; rectangular spout plugs into the housing socket. | Stage 1 |
| Drive axle (7) + motor coupler (7b) | Transmit torque from NEMA17 to the wheel via the D-flat. Same axle works for both wheel and auger benchmark. | Stage 1 |
| Auger + barrel (6a, 6b) | **Benchmark only.** Quantify jam rate vs the paddle wheel on the same kibble, then archive. | Stage 1 |
| NEMA17 stepper (1) | Discrete, repeatable rotation. Step-counted "pockets per command" → coarse open-loop dose, weight loop refines. | Stage 1 |
| Stepper driver A4988 / DRV8825 (2) | Microstepping (1/8 or 1/16) for low-noise smooth rotation. EN pin gated by ESP32 → motor de-energised between feeds (cool + silent). | Stage 1 |
| ESP32 dev board (3) | All control + Wi-Fi + HA + OTA. One MCU does everything. | Stage 1 |
| 12 V / ≥2 A PSU (4) | Powers the stepper motor; on-board buck or USB powers the ESP32 logic. Common ground. | Stage 1 |
| Vibration motor (11, optional) | Only if hopper bridges. Driven by a logic-level FET, pulsed during a feed if delta-weight stalls before the timeout. | Stage 1 (conditional) |
| Load cell 1–5 kg + HX711 (Stage 2: 1, 2) | The feedback half of the loop. Closes "did the portion actually arrive?", drives jam detection, exposes bowl_weight as a HA sensor. | Stage 2 |
| Momentary button (Stage 2: 3) | INPUT_PULLUP. Short press = feed one default portion. Long press = tare. | Stage 2 |
| TM1637 4×7-seg display (Stage 2: 4) | Idle: clock. Feeding: grams remaining countdown. Error: short code (`E001` etc.). Upgrade path: SSD1306 OLED for richer status. | Stage 2 |
| Printed enclosure (Stage 2: 5) | Holds motor, board, bowl, hopper. Designed *after* mechanism is locked. | Stage 2 |
| M3 screws / heat-set inserts (10) | All assemblies that need rework (motor mount, electronics tray, future end-cap screws). | Both |

Explicitly **not used**: HC-06 (ESP32 has Wi-Fi); any cloud service
(local-first by design).

---

## 2. Functional architecture

### Food path (mechanical)

```
                ┌──────────────────┐
                │   Feed hopper    │   ← refill here
                │   (cone, open)   │
                └────────┬─────────┘
                         │  gravity
                         ▼
                ┌──────────────────┐
                │   Inlet boss     │   spout plugged into socket
                │   + inlet slot   │
                └────────┬─────────┘
                         │  pocket fills
                         ▼
        ╔════════════════╧═════════════════╗
        ║                                  ║
        ║    PADDLE WHEEL inside HOUSING   ║   ← removable end_cap on top
        ║    axle ── D-flat ── wheel       ║
        ║                                  ║
        ╚════════════════╤═════════════════╝
                         │  pocket inverts at the bottom
                         ▼
                ┌──────────────────┐
                │  Outlet chute    │   widens downward
                └────────┬─────────┘
                         │  gravity
                         ▼
                ┌──────────────────┐
                │  BOWL on plate   │   ◄── load cell
                └──────────────────┘
                         │
                         ▼ (sensed weight)
```

### Signal / control path (electrical)

```
                       ┌────────────────────────────────┐
                       │            ESP32               │
                       │     (ESPHome firmware)         │
        button ─GPIO──►│                                │
                       │  Wi-Fi + mDNS + HA native API  │◄─── Home Assistant
        HX711 ─dout───►│  OTA updates                   │     phone / web UI
              ─sck────│  cron-style schedule           │
                       │  Feed FSM (see §3)             │
        TM1637 ◄─DIO───│                                │
               ◄─CLK───│                                │
                       │                                │
                       │  STEP   DIR   EN               │
                       └────┬─────┬─────┬───────────────┘
                            ▼     ▼     ▼
                       ┌──────────────────┐    12 V ──► MOT  ─────┐
                       │  A4988 / DRV8825 │                       │
                       └────────┬─────────┘                       ▼
                                ▼                            NEMA17
                       (microstepping pulses)                   │
                                                     coupler ───┤
                                                                ▼
                                                              axle ─ D ─ wheel
                       (optional)
                       FET ──► vibration motor on the hopper wall
```

### Power

```
   12 V / 2 A PSU ──┬── stepper driver V_MOT (NEMA17 only)
                    └── buck or LDO → 5 V → ESP32 (Vin), HX711, display, button
   (all GNDs tied to one star point near the ESP32)
```

---

## 3. Control loops & state machine

### Feed state machine (per "feed N grams" command)

```
   IDLE
     │  command: feed(target_g)
     ▼
   ARMING ──► tare offset checked, EN low → motor on
     │
     ▼
   ROTATING ── step pocket_arc (= 360° / n_paddles) ──┐
     │                                                │
     ▼                                                │
   SETTLING ── wait HX711 settle (≈ 300 ms) ──────────┘
     │
     ├──► delta_g > 0  AND  total_g < target_g   → ROTATING (next pocket)
     ├──► total_g ≥ target_g                     → DONE
     ├──► delta_g ≈ 0  for K consecutive pockets → JAM_RECOVER
     └──► elapsed > timeout                      → ERROR
   JAM_RECOVER
     │  reverse by ~30°, optionally pulse vibration motor, then ROTATING
     │  give up after R retries → ERROR (publish to HA)
     ▼
   DONE / ERROR → EN high (motor off, cool), report dispensed_g
```

### Why this works

- **Open-loop count of pockets** gives a coarse first guess.
- **Weight delta after each pocket** is the truth source — bypasses
  pocket-fill variance and kibble density drift.
- **No weight change after rotation** is the only thing we need to call
  "jam OR empty hopper" — distinguishing them is a v1+ refinement
  (current sense, hopper switch).

### Manual button

| Action | Behaviour |
|--------|-----------|
| Short press (< 500 ms) | `feed(default_portion_g)` |
| Long press (≥ 2 s) | `tare()` (zero the bowl) |
| Held during boot | (future) reset Wi-Fi credentials |

### Schedule

ESPHome `time` + `script.execute` at configured times. Times and
default portion live in HA UI (not hard-coded). Persisted across
reboots.

---

## 4. Feature priority

| # | Feature | M0 | M1 | M2 | M3+ |
|---|---------|:--:|:--:|:--:|:---:|
| 1 | Spin stepper N pockets (open-loop, no sensors) | ✓ | | | |
| 2 | Manual button → feed default portion | ✓ | | | |
| 3 | Wi-Fi + ESPHome + Home Assistant discovery | ✓ | | | |
| 4 | OTA firmware updates | ✓ | | | |
| 5 | TM1637 status (idle / feeding / error) | ✓ | | | |
| 6 | HX711 closed-loop weight per feed | | ✓ | | |
| 7 | Jam detection via weight delta | | ✓ | | |
| 8 | Scheduled feeds (cron-like via HA) | | ✓ | | |
| 9 | Persistent counters (NVS): total dispensed, last feed | | ✓ | | |
| 10 | Reverse-on-jam recovery + retry budget | | | ✓ | |
| 11 | Vibration motor pulse on stall | | | ✓ | |
| 12 | Hopper-low detection (stall pattern → notify HA) | | | ✓ | |
| 13 | TMC2208 driver + StallGuard (cleaner jam signal) | | | | ✓ |
| 14 | Replace TM1637 with SSD1306 OLED (richer UI) | | | | ✓ |
| 15 | Cat detection / per-cat schedules | | | | ✓ |

`Mn` = milestone, not a deadline.

---

## 5. Roadmap aligned to BOM

| Phase | Hardware delivered | Firmware delivered | Gate to next |
|-------|--------------------|--------------------|--------------|
| **S1-mech** *(now)* | Print + assemble paddle wheel kit. Auger printed as benchmark only. | None. | Food feeds without jamming for N consecutive portions on real kibble. Recorded in `mechanical-tests.md`. |
| **M0 — open-loop firmware** | NEMA17 + driver + ESP32 wired up; no scale yet. | ESPHome project: stepper, button, display, Wi-Fi, OTA, HA discovery. `feed(pockets)` action. | Pressing the button dispenses one repeatable portion via HA. |
| **M1 — closed-loop** | Add HX711 + load cell under a temporary bowl plate. | Add HX711 to ESPHome; switch `feed()` to grams target; jam-by-weight-delta. Schedule. | Feeding 5 / 10 / 15 g via HA hits target ± tolerance; jam is reported, not silent. |
| **M2 — robustness** | Optional vibration motor if S1-mech / M1 testing showed bridging. | Reverse-on-jam, retry budget, hopper-low notification. | Two weeks unattended with no manual intervention. |
| **S2-enclosure** | Designed printed enclosure (separate `.scad`), load-cell bowl mount, electronics tray. | No new firmware. | Aesthetically and serviceably acceptable for use. |
| **M3+** | Driver swap to TMC2208; OLED swap. | StallGuard-based jam; richer display. | Optional. |

---

## 6. Firmware stack — recommendation

**Default: ESPHome.** Reasons:

- Native components for everything we use: `stepper`, `hx711`, `button`,
  `tm1637`, `output` (FET), `wifi`, `ota`, `api`, `time`, `script`,
  `schedule`. Less hand-rolled code per feature.
- First-class Home Assistant integration: every sensor, button, and
  service appears automatically.
- YAML config is reviewable in PRs; secrets in `secrets.yaml`.

**Escape hatch:** if the closed-loop logic gets too tangled inside YAML
scripts, drop into a `custom_component` (C++) for the FSM only, keep the
rest declarative. Last resort: full PlatformIO / Arduino, lose HA
auto-discovery (would need Web Server + REST).

**Topology in repo (planned, not built):**

```
firmware/
  esphome/
    aipetfeeder.yaml         # main config
    secrets.yaml.example
    fsm/                     # optional custom_component (C++) for feed FSM
    README.md                # build + flash instructions
```

---

## 7. HA-side surface (what the user sees)

| HA entity | Type | What it does |
|-----------|------|--------------|
| `button.feeder_feed_now` | Button | Triggers default portion |
| `number.feeder_default_portion_g` | Number | Default portion size |
| `sensor.feeder_bowl_weight_g` | Sensor | Live weight from HX711 |
| `sensor.feeder_total_dispensed_g` | Sensor | Lifetime counter (NVS) |
| `sensor.feeder_last_feed_time` | Timestamp | When the last successful feed completed |
| `binary_sensor.feeder_jam` | Binary | True during a JAM_RECOVER/ERROR state |
| `button.feeder_tare` | Button | Re-zero the scale |
| `switch.feeder_motor_enable` | Switch | (Debug) hold EN low manually |

Automations live in HA, not in the feeder — e.g. "if `total_dispensed`
hasn't increased today by 18:00, send a phone notification."

---

## 8. Out of scope (deliberately)

- **HC-06 / Bluetooth** — superseded by ESP32 Wi-Fi.
- **Cloud account / vendor app** — local-first by design.
- **Per-cat identification** — out of scope unless we later add RFID.
- **Camera** — out of scope.
- **Battery operation** — wall-powered only; pet feeders need to be
  always-on.
- **Auger in production firmware** — auger is benchmark-only; once
  M0 begins, the firmware targets the paddle wheel.

---

## 9. Open decisions to resolve before M0

1. Microstepping resolution: 1/8 vs 1/16 (driver-dependent; smoother
   ≠ better if torque drops).
2. Stepper speed at which kibble actually transfers cleanly — measured
   during S1-mech testing.
3. Where the bowl sits relative to the chute — affects bowl plate
   design (impacts S2-enclosure, not M0).
4. Default portion size — depends on the actual cat; record in tests.
5. Driver IC choice for the *built* prototype: A4988 cheapest, DRV8825
   higher torque, TMC2208 quieter + StallGuard. **Default A4988 for
   M0**; revisit at M3.
