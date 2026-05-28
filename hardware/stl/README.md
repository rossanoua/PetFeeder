# Printable meshes (STL)

Generated from `../cad/openscad/feeder_test_module.scad` — **the .scad is
the source of truth**, these are build artifacts. 3MF copies are in
`../3mf/` (OrcaSlicer reads both; 3MF preserves units, prefer it).

> OpenSCAD cannot export STEP (it is mesh-based, STEP is CAD/BREP).
> OrcaSlicer *does* import STEP, but for these parts STL/3MF is enough.

Regenerate after editing the model:

```sh
cd hardware/cad/openscad
for p in auger axle barrel hopper; do
  openscad -o ../../stl/$p.stl  -D "part=\"$p\"" feeder_test_module.scad
  openscad -o ../../3mf/$p.3mf -D "part=\"$p\"" feeder_test_module.scad
done
```

## Suggested print orientation (Stage 1 test, tune later)

- **auger** — vertical, shaft axis along Z, supports off / tree. The
  helical flight self-supports reasonably; a brim helps adhesion on the
  small base. This is the part most sensitive to print quality.
- **axle** — better to use a Ø5 mm steel rod. If printed: vertical,
  thin — expect flex and wear, test-only.
- **barrel** — vertical (bore along Z). Bore prints without supports;
  the inlet/socket may need light supports on its overhangs.
- **hopper** — print upside down (wide opening on the bed) so the cone
  and spout self-support; no supports inside the funnel.

All exported manifold (OpenSCAD `Simple: yes`). Fit clearances
(`fit_clear`, `join_clear`, `barrel_clear`) are guesses — adjust in the
.scad and reprint test coupons until the slip fits feel right on your
printer. Record results in `docs/mechanical-tests.md`.

## Paddle wheel parts (`pw_*`)

Source: `../cad/openscad/paddle_wheel_module.scad`. Same axle interface
(Ø5 mm with D-flat) as the auger, so one printed axle works for both
benchmarks.

```sh
cd hardware/cad/openscad
for p in wheel axle housing end_cap hopper; do
  openscad -o ../../stl/pw_$p.stl -D "part=\"$p\"" paddle_wheel_module.scad
  openscad -o ../../3mf/pw_$p.3mf -D "part=\"$p\"" paddle_wheel_module.scad
done
```

Suggested orientation:

- **pw_wheel** — flat on bed, hub axis vertical. Paddles on the bottom
  half (closer to the bed) self-support; no supports needed.
- **pw_axle** — use a Ø5 mm steel rod if possible.
- **pw_housing** — bed-down on the closed floor (open top facing up).
  No overhangs to support — the floor is flat and the outlet is a clean
  through-hole in the floor.
- **pw_end_cap** — flat on the bed, register lip pointing UP, boss
  pointing up. Boss has a flat overhanging roof — needs light supports
  if you print it cap-down. Or print boss-down (boss touching the bed)
  to avoid supports inside the socket. Pick whichever your slicer
  handles better.
- **pw_hopper** — upside down (wide opening on the bed).

Assembly order:
1. Slide the axle up through the housing's bottom bore (motor stub
   exits below the floor).
2. Drop the wheel onto the axle inside the housing (D-flat keys it).
3. Drop the cap onto the rim — the register lip seats in the recess,
   and the upper axle stub passes through the cap bore.
4. Slide the hopper spout into the boss-socket on top of the cap.

**Mounting note for Stage 1 tests:** the housing rests on its flat
floor BUT the outlet is in that floor. Prop the housing up on small
blocks under the rim (or place it over the bowl on a piece of cardboard
with a hole cut) so kibble can fall through the outlet into the bowl.
The motor coupler attached to the bottom axle stub also works as a
built-in standoff if the motor is mounted below the housing.
