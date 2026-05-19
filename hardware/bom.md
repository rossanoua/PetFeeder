# Bill of Materials — AiPetFeeder

Status legend:

- ✅ **decided** — chosen, low risk
- 🧪 **to validate** — chosen as starting point, must be confirmed by a real test
- ❓ **open** — not yet decided, depends on test results

This BOM is split into two stages. **Build Stage 1 first.** Do not buy
Stage 2 parts until the auger mechanism is validated (see
`docs/project-notes.md` → "Mechanical concept").

---

## Stage 1 — Auger mechanical test module

Goal: prove that the auger actually moves dry cat food reliably,
without jamming, with a roughly repeatable portion. Nothing else
matters until this works.

| # | Part | Spec / note | Qty | Status |
|---|------|-------------|-----|--------|
| 1 | Stepper motor NEMA17 | 17HS4401, 1.8°/step, ~40 N·cm. Torque reserve on purpose — food can compact. | 1 | 🧪 to validate (may downsize to short NEMA17 / NEMA14 later) |
| 2 | Stepper driver | A4988 or DRV8825 on a breakout. TMC2208 optional if noise matters. | 1 | 🧪 to validate |
| 3 | Microcontroller | ESP32 dev board (e.g. ESP32-WROOM DevKitC). Used only to spin the motor in Stage 1. | 1 | ✅ decided |
| 4 | Power supply | 12 V, ≥2 A DC for the stepper. Separate 5 V/USB for the ESP32. | 1 | 🧪 to validate (current draw under load is unknown) |
| 5 | Auger (screw) | 3D printed, parametric — see `hardware/cad/openscad/`. Print several pitch/diameter variants. | 3–5 | 🧪 to validate |
| 6 | Auger tube / barrel | 3D printed, parametric — same model. Inner Ø ≈ auger OD + clearance. | 1–2 | 🧪 to validate |
| 7 | Drive axle | Ø5 mm rod through the auger, D-flat keys it (model has the flat). **Steel rod preferred** — printed axles flex/wear. | 1 | 🧪 to validate |
| 7b | Motor coupler | 5 mm rigid/flex coupler: axle rear stub → NEMA17 5 mm shaft. | 1 | 🧪 to validate |
| 8 | Hopper / feed cone | 3D printed, parametric — round top → rectangular spout that plugs into the barrel socket collar. | 1 | ✅ decided |
| 9 | Dry cat food | The actual food the cat eats. Kibble size/shape changes everything — test with the real thing. | — | ✅ decided |
| 10 | Misc | M3 screws/heat-set inserts for motor mount, jumper wires, breadboard. | — | ✅ decided |

Optional for Stage 1:

| # | Part | Spec / note | Qty | Status |
|---|------|-------------|-----|--------|
| 11 | Vibration motor | Small coin/ERM motor + transistor. Only add if food bridges/jams in the test. | 1 | ❓ open (need test to know if required) |

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

- Auger outer diameter and pitch that move food reliably?
- Portion repeatability good enough for open-loop, or is the HX711
  weight loop mandatory?
- Is the vibration motor actually needed, or does geometry alone solve jams?
- Is NEMA17 17HS4401 overkill → can we downsize (cost, size, power)?
- Reverse-rotation anti-jam / anti-dribble: how many steps back per portion?
