# Mechanical tests — auger feeding

Goal of Stage 1: prove the auger moves the **real cat food** reliably,
without jamming, with a roughly repeatable portion. Everything else
(firmware, weight loop, enclosure) waits on this. See
`docs/project-notes.md` and `hardware/bom.md`.

## How to run one test

1. Print one auger + barrel variant from
   `hardware/cad/openscad/feeder_test_module.scad` (note the params).
2. Mount on NEMA17, fit barrel, attach throwaway hopper, fill with the
   **actual food the cat eats**.
3. Spin a fixed number of motor revolutions (start: 5 forward).
4. Weigh what came out (kitchen scale, grams).
5. Repeat the **same** run 5× without refilling logic changes.
6. Record below. One table row per printed variant.

Keep failed variants' rows — knowing what *didn't* work is the point.

## Test setup (fill once, update when it changes)

- Food (brand / kibble size & shape):
- Scale (model / resolution):
- Motor / driver / microstepping:
- Revolutions per run:
- Anti-jam reverse used (steps back per run): none / ___

## Results

| Date | Variant id | auger_od | pitch | flight_thick | barrel_clear | Runs (g, each) | Mean g | Spread (max−min) | Jam? | Notes |
|------|-----------|----------|-------|--------------|--------------|----------------|--------|------------------|------|-------|
|      |           |          |       |              |              |                |        |                  |      |       |

`Variant id` = short tag you write on the printed part (e.g. `A1`).

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
