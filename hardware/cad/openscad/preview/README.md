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
