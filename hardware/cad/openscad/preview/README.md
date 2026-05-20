# Preview renders

Visual reference only — **not authoritative**. The model is
`../feeder_test_module.scad`; regenerate after any change:

```sh
cd hardware/cad/openscad
xvfb-run -a openscad -o preview/auger.png    --imgsize=1000,700 --autocenter --viewall -D 'part="auger"'    feeder_test_module.scad
xvfb-run -a openscad -o preview/axle.png     --imgsize=1000,500 --autocenter --viewall -D 'part="axle"'     feeder_test_module.scad
xvfb-run -a openscad -o preview/barrel.png   --imgsize=1000,700 --camera=-260,30,46,0,0,46 -D 'part="barrel"'   feeder_test_module.scad
xvfb-run -a openscad -o preview/hopper.png   --imgsize=1000,700 --autocenter --viewall -D 'part="hopper"'   feeder_test_module.scad
xvfb-run -a openscad -o preview/assembly.png --imgsize=1000,750 --camera=-200,-200,150,0,0,35 -D 'part="assembly"' feeder_test_module.scad
```

(`xvfb-run` only needed on headless machines.)

- `auger.png`    — the screw, with the through D-bore for the axle
- `axle.png`     — drive axle: round stubs + D-flat over the middle
- `barrel.png`   — tube, viewed from the inlet side; rectangular socket
  collar with a conical funnel down into the bore (green = bore opened)
- `hopper.png`   — feed cone: round top → rectangular plug-in spout
- `assembly.png` — axle through auger, inside barrel, hopper spout
  seated in the collar socket

Verified with OpenSCAD 2021.01: all parts render `Simple: yes` (manifold,
printable); axle passes through the auger; hopper spout seats in the
collar; funnel leads from the socket into the bore.

Torque path: motor → axle round stub → D-flat → auger → food.
Use a real 5 mm steel rod as the axle if possible (printed axles flex).

---

## Paddle wheel module (`pw_*` files)

Alternative — and now primary — Stage 1 mechanism. Source:
`../paddle_wheel_module.scad`. Regenerate:

```sh
for p in wheel axle housing end_cap hopper; do
  xvfb-run -a openscad -o preview/pw_$p.png --imgsize=1000,750 --autocenter --viewall -D "part=\"$p\"" paddle_wheel_module.scad
done
xvfb-run -a openscad -o preview/pw_assembly.png --imgsize=1100,800 --autocenter --viewall -D 'part="assembly"' paddle_wheel_module.scad
```

- `pw_wheel.png`    — N-paddle wheel with through D-bore for the axle
- `pw_axle.png`     — drive axle (round stubs + D-flat, same idea as auger axle)
- `pw_housing.png`  — cup-shaped, OPEN at the top; closed bottom; rim has
  a recess for the cap's register lip
- `pw_end_cap.png`  — removable lid; slip-fit lip drops into the rim
  recess; carries the upper axle bore. Take it off to insert the wheel.
- `pw_hopper.png`   — feed cone, rectangular spout plugs into the inlet boss
- `pw_assembly.png` — wheel inside housing, cap closing the top, hopper
  plugged into the boss, chute extending below

Real-world mounting: rotate the whole assembly 90° so the axle is
horizontal — then the hopper sits on top (gravity-fed), the chute drops
kibble down to the bowl below.
