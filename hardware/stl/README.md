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
for p in wheel axle housing hopper; do
  openscad -o ../../stl/pw_$p.stl -D "part=\"$p\"" paddle_wheel_module.scad
  openscad -o ../../3mf/pw_$p.3mf -D "part=\"$p\"" paddle_wheel_module.scad
done
```

Suggested orientation:

- **pw_wheel** — flat on bed (axle bore vertical). 4 paddles self-support.
- **pw_axle** — same advice as the auger axle (use a steel rod ideally).
- **pw_housing** — bed-down on the end cap. Outlet chute will overhang;
  add supports for the chute and the inlet-boss roof.
- **pw_hopper** — upside down (wide opening on the bed).
