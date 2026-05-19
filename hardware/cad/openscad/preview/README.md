# Preview renders

Visual reference only — **not authoritative**. The model is
`../feeder_test_module.scad`; regenerate after any change:

```sh
cd hardware/cad/openscad
xvfb-run -a openscad -o preview/auger.png    --imgsize=1000,700 --autocenter --viewall -D 'part="auger"'    feeder_test_module.scad
xvfb-run -a openscad -o preview/barrel.png   --imgsize=1000,700 --camera=-220,0,42,0,0,42                   -D 'part="barrel"'   feeder_test_module.scad
xvfb-run -a openscad -o preview/assembly.png --imgsize=1000,700 --camera=-220,40,55,0,0,40                  -D 'part="assembly"' feeder_test_module.scad
```

(`xvfb-run` only needed on headless machines.)

- `auger.png` — the screw
- `barrel.png` — tube, viewed from the inlet side (green = bore opened through)
- `assembly.png` — auger inside barrel, fit check

Verified with OpenSCAD 2021.01: both parts render `Simple: yes` (manifold,
printable); inlet penetrates the bore; auger clears the tube.
