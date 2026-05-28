# Mechanical tests — feeding mechanism

Goal of Stage 1: find a feeding mechanism that moves **real cat food**
reliably, without jamming, with a roughly repeatable portion. Two
candidates are being benchmarked head-to-head:

1. **Paddle wheel** — primary candidate; expected to win. Pockets fill
   and empty by gravity; no kibble shear.
   Model: `hardware/cad/openscad/paddle_wheel_module.scad`.
2. **Auger** — benchmark only; expected to jam (per the user's prior
   experience with screw-and-kibble feeders).
   Model: `hardware/cad/openscad/feeder_test_module.scad`.

Everything else (firmware, weight loop, enclosure) waits on this. See
`docs/project-notes.md` and `hardware/bom.md`.

## How to run one test

1. Print one **variant** (auger+barrel or wheel+housing — record which).
2. Mount on NEMA17, fit the matching hopper, fill with the **actual
   food the cat eats**.
3. Drive a fixed amount of motion (start: 5 motor revolutions for the
   auger; for the wheel, N pockets where N = wheel's `n_paddles`, i.e.
   one full rotation).
4. Weigh what came out (kitchen scale, grams).
5. Repeat the **same** run 5× without changing anything in between.
6. Record below. One table row per printed variant.

Keep failed variants' rows — knowing what *didn't* work is the point.

## Test setup (fill once, update when it changes)

- Food (brand / kibble size & shape):
- Scale (model / resolution):
- Motor / driver / microstepping:
- Revolutions per run:
- Anti-jam reverse used (steps back per run): none / ___

## Results — paddle wheel

| Date | Variant id | wheel_d | wheel_width | n_paddles | housing_clear | Runs (g, each) | Mean g | Spread (max−min) | Jam? | Notes |
|------|-----------|---------|-------------|-----------|---------------|----------------|--------|------------------|------|-------|
|      |           |         |             |           |               |                |        |                  |      |       |

## Results — auger (benchmark)

| Date | Variant id | auger_od | pitch | flight_thick | barrel_clear | Runs (g, each) | Mean g | Spread (max−min) | Jam? | Notes |
|------|-----------|----------|-------|--------------|--------------|----------------|--------|------------------|------|-------|
|      |           |          |       |              |              |                |        |                  |      |       |

`Variant id` = short tag you write on the printed part (e.g. `W1`, `A1`).

## Decisions log

Record conclusions as they emerge — these drive Stage 2 / BOM updates:

- Best variant so far:
- Open-loop portion repeatable enough, or HX711 weight loop mandatory?
- Vibration motor needed (did food bridge/jam)?
- NEMA17 17HS4401 overkill → downsize?
- Anti-jam reverse: how many steps back per portion works?

## Status

- [ ] At least one variant moves food without jamming
- [ ] Portion spread acceptable across 5 repeats (define threshold above)
- [ ] Decided: open-loop vs weight-loop dosing
- [ ] Decided: vibration motor in/out
- [ ] Stage 1 passed → unblock Stage 2
