# Bill of Materials — AiPetFeeder

Status legend:

- ✅ **decided** — chosen, low risk
- 🧪 **to validate** — chosen as starting point, must be confirmed by a real test
- ❓ **open** — not yet decided, depends on test results

This BOM is split into two stages. **Build Stage 1 first.** Do not buy
Stage 2 parts until a feeding mechanism is validated (see
`docs/project-notes.md` → "Mechanical concept").

> **Stage 1 mechanism — decision 2026-05-20:** the **paddle wheel** is now
> the primary candidate. The auger remains as a **benchmark** to confirm
> (against real-world experience) that screw-and-kibble is unreliable for
> this application; both are printed and tested. Whichever wins on jam
> rate + portion repeatability survives into Stage 2.

---

## Stage 1 — Mechanism test modules

Goal: prove that the chosen mechanism actually moves dry cat food
reliably, without jamming, with a roughly repeatable portion. Nothing
else matters until this works.

| # | Part | Spec / note | Qty | Status |
|---|------|-------------|-----|--------|
| 1 | Stepper motor NEMA17 | 17HS4401, 1.8°/step, ~40 N·cm. Torque reserve on purpose — food can compact. | 1 | 🧪 to validate (may downsize to short NEMA17 / NEMA14 later) |
| 2 | Stepper driver | A4988 or DRV8825 on a breakout. TMC2208 optional if noise matters. | 1 | 🧪 to validate |
| 3 | Microcontroller | ESP32 dev board (e.g. ESP32-WROOM DevKitC). Used only to spin the motor in Stage 1. | 1 | ✅ decided |
| 4 | Power supply | 12 V, ≥2 A DC for the stepper. Separate 5 V/USB for the ESP32. | 1 | 🧪 to validate (current draw under load is unknown) |
| 5a | **Paddle wheel** (primary) | 3D printed, parametric — `cad/openscad/paddle_wheel_module.scad`. Full-height hub + N paddles on the bottom half (sweep food along the floor). **2026-06-03 downscale:** back to wheel_d **80 mm**, wheel_thickness **18 mm**, hub_d **20 mm** (the Ø120 upscale fought bridging passively; now an active vibromotor does that). Portion set by **rotation count + HX711 weight loop**, not pocket volume. | 1–2 | 🧪 to validate |
| 5b | Paddle-wheel housing | 3D printed. **Lies on its flat floor.** Closed bottom with a rounded-rect OUTLET hole (**22×28 mm**, corner r=2); OPEN top; **4 slotted ears** on the rim that key the cap (anti-rotation, prints support-free). Housing Ø **87.6 mm** × **37 mm**. | 1 | 🧪 to validate |
| 5c | Paddle-wheel end cap | 3D printed, removable lid. Drops onto the housing rim; **4 outward tabs** seat into the housing ears (anti-rotation, 4 index positions, no supports). Central axle bore + radial-offset INLET hole (**22×28 mm rounded**) + **COLLAR** (low rectangular fence) on top of the cap that retains the hopper laterally (collar-mount, no socket — see ADR `2026-05-25-collar-mount-hopper-redesign`). | 1 | 🧪 to validate |
| 6a | Auger (benchmark) | 3D printed, parametric — `cad/openscad/feeder_test_module.scad`. Expected to jam per real-world experience; tested only to confirm. | 1 | 🧪 benchmark |
| 6b | Auger barrel (benchmark) | 3D printed, paired with the auger. | 1 | 🧪 benchmark |
| 7 | Drive axle | Ø5 mm rod, D-flat keys it (both wheel and auger have matching D-bore). **Steel rod preferred** — printed axles flex/wear. | 1 | 🧪 to validate |
| 7b | Motor coupler | 5 mm rigid/flex coupler: axle rear stub → NEMA17 5 mm shaft. | 1 | 🧪 to validate |
| 8a | Test hopper (small) | 3D printed, parametric — `paddle_wheel_module.scad part="hopper"`. Round Ø70 top → rect open bottom matching the cap inlet hole. **No spout walls** (collar-mount, sits ON the cap). | 1 | ✅ decided |
| 8b | **Bulk hopper — funnel** | 3D printed, parametric — `bulk_hopper_module.scad part="funnel"`. Ø160 round top × **115 mm** tall, narrows to **rect bottom matching the cap inlet hole (22×28 rounded)**. Cone is ~33° from vertical (steeper than the Ø120 version because the throat shrank) — OK because the **vibromotor** is the active anti-bridge. Has an **external vibromotor mounting pad** near the throat. **No spider** (the old anti-bridge insert was the bridge source — removed). **No spout walls** (collar-mount, sits ON the cap). **Print right-side up — rect plug on the bed, lip pointing up.** | 1 | 🧪 to validate |
| 8c | **Bulk hopper — storage ring** | 3D printed, parametric — `bulk_hopper_module.scad part="ring"`. Ø160 × 170 mm modular. Print **1** for ~1.6 kg total capacity (funnel 0.9 L + ring 3.16 L = 4.06 L × 0.4 g/mL), **2** for ~2.8 kg. Stackable slip-fit lip. | 1+ | 🧪 to validate |
| 8d | **Bulk hopper — lid** | 3D printed, parametric — `bulk_hopper_module.scad part="lid"`. Wraps the topmost ring lip; finger pad on top. | 1 | 🧪 to validate |
| 9a | **Lower body chassis** | 3D printed, `chassis_module.scad`. **220×200×160 mm** (Ø80 mechanism; the Ø160 hopper now centers at x=−29 so it fits 220 again). C-shape: bowl niche at front (130×160×80 mm), top recess seating the rotary housing (**Ø88**), internal slanted chute redirecting kibble from floor outlet to a front-face exit above the bowl, electronics-bay cavity carved from the back. | 1 | 🧪 to model further (next: motor mount, panel cutouts, load-cell mount) |
| 9 | Dry cat food | The actual food the cat eats. Kibble size/shape changes everything — test with the real thing. | — | ✅ decided |
| 10 | Misc | M3 screws/heat-set inserts for motor mount, jumper wires, breadboard. | — | ✅ decided |

Anti-bridge (now part of the design, not optional):

| # | Part | Spec / note | Qty | Status |
|---|------|-------------|-----|--------|
| 11 | **Vibration motor** | Small **coin ERM** (e.g. Ø10×3.4 mm) or cylindrical pager motor, mounted on the funnel's external pad near the throat. **Active anti-bridge** — pulsed during dispense (replaces the removed passive spider). **Exact motor TBD** → drives the final mount geometry. | 1 | 🧪 to validate (need motor spec to finalize pad) |
| 11b | Motor driver | Logic-level **MOSFET** (e.g. AO3400/2N7000-class) + **flyback diode** (1N4148/Schottky) across the motor, driven from an ESP32 GPIO. | 1 | ✅ decided |

---

## Stage 2 — Full prototype (only after Stage 1 passes)

| # | Part | Spec / note | Qty | Status |
|---|------|-------------|-----|--------|
| 1 | Load cell | 1–5 kg bar load cell, for closed-loop portion control by weight. | 1 | 🧪 to validate (range depends on bowl + portion size) |
| 2 | HX711 | 24-bit ADC amplifier board for the load cell. | 1 | ✅ decided |
| 3 | Button | Momentary push button, "feed one portion". INPUT_PULLUP. | 1 | ✅ decided |
| 4 | Display | TM1637 4-digit 7-seg, or small OLED. Shows last feed / weight / status. | 1 | ❓ open (nice-to-have, not MVP-critical) |
| 5 | Enclosure | Printed, serviceable, separate from the validated auger module. | 1 | ❓ open (design last) |

### Explicitly dropped

- **HC-06 Bluetooth** — not needed. ESP32 has Wi-Fi; config goes over
  local API / Home Assistant. (Per `docs/project-notes.md`.)
- **Cloud dependency** — out of scope by design: local-first.

---

## Open questions to resolve via Stage 1 test

- **Paddle wheel:** pocket count and pocket volume that give one
  acceptable portion per fraction of a rotation? Does any kibble jam
  in the inlet boss, the wheel cavity, or the chute?
- **Auger (benchmark):** does it confirm the expected jam behaviour
  (or surprise us)? Anti-jam reverse stepping needed?
- Portion repeatability good enough for open-loop, or is the HX711
  weight loop mandatory anyway?
- Is NEMA17 17HS4401 overkill → can we downsize (cost, size, power)?
  (Paddle wheel torque requirement is much lower than auger.)
