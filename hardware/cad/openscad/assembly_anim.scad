// Assembly animation for the form-1a tower — FULL build order, electronics included.
// Each part flies from an exploded approach offset into its SEATED pose along the
// insertion vector that run_sweep.sh actually swept for collisions, so the motion in
// this video is the motion that was proven clear, not a plausible-looking guess.
//
// TWO RENDER PATHS, same timing and the same colour table:
//   modules (default)  — reads the live model; correct geometry, but OpenSCAD's OpenCSG
//                        preview hatches base_motor's deck badly (cut planes coplanar
//                        with faces). Fine for checking poses in the GUI.
//   meshes  (mesh_dir) — imports the p_<name>.stl the clash harness already baked in
//                        their seated global poses. No CSG left to preview, so no
//                        hatching. THIS is what the video frames are rendered from.
//
//   xvfb-run -a openscad -o f.png --imgsize=900,680 --camera=0,0,90,68,0,0,620 \
//       -D '$t=0.30' -D 'mesh_dir="/path/to/asm"' assembly_anim.scad
//
// part="__h__" is the sentinel that keeps the included file's own dispatch silent.
// The camera is FIXED per frame by the driver; the scene turns instead (see view_ang),
// so whatever is being fitted faces the viewer: service side (-X, electronics + power)
// for the bay work, front (+X, the scallop) for the feed tray.
include <bulk_hopper_module.scad>
part = "__h__";
$fn = 48;                     // preview density; plenty for a motion video
mesh_dir = "";                // "" = build from modules; else dir holding p_<name>.stl

// cosine ease-in-out: 0 before window a, 1 after window b, smooth between.
function prog(a,b) = $t <= a ? 0 : $t >= b ? 1 : (0.5 - 0.5*cos(180*($t-a)/(b-a)));

// One colour table for both render paths, so they can't drift.
COL = [["base_motor",   "Gainsboro"],   ["motor",       "#2b2b2b"],
       ["cell",         "DimGray"],     ["cell_platform","Wheat"],
       ["el_tray",      "SteelBlue"],   ["boards",      "DarkGreen"],
       ["el_panel",     "Tomato"],      ["dc_jack",     "#1a1a1a"],
       ["base_hopper",  "Gold"],        ["housing",     "LightSteelBlue"],
       ["wheel",        "Silver"],      ["cap",         "MediumSeaGreen"],
       ["cone",         "Orange"],      ["shell",       "Khaki"],
       ["spider",       "MediumPurple"],["ring",        "BurlyWood"],
       ["lid_on_ring",  "Tan"],         ["tray",        "LightBlue"],
       ["dc_plug",      "#111111"],     ["usb_plug",    "#222222"]];
function col(n) = COL[search([n], COL)[0]][1];

// The funnel tube is the only thing that has to be see-through: the cone and the spider
// go in AFTER it, so an opaque shell would hide both. Everything else reads fine solid —
// the leg shroud is still open at the top while the bay is being populated.
function alp(n) = (n == "shell" && $t < 0.78) ? 0.32 : 1;

// --- seated global poses. Authoritative source is clash_harness.scad's A(): the same
// poses are what the swept-path check used, so the two files must not drift apart. ---
module G(name) {
    if      (name == "base_motor")    base_motor();
    else if (name == "motor")         motor_mock(base_deck_z);
    else if (name == "cell")          cell_mock();
    else if (name == "cell_platform") cell_platform();
    else if (name == "el_tray")       el_tray_mounted();
    else if (name == "boards")        el_boards_mounted();
    else if (name == "el_panel")      el_panel();
    else if (name == "dc_jack")       dc_jack_mock();
    else if (name == "dc_plug")       dc_plug_mock();
    else if (name == "usb_plug")      usb_plug_mock();
    else if (name == "base_hopper")   base_hopper();
    else if (name == "housing")       translate([0,0,base_motor_h])                   housing();
    else if (name == "wheel")         translate([throat_cx,0,base_motor_h + 3.5])     wheel();
    else if (name == "cap")           translate([0,0,base_h - nest_h])                cap_plate();
    else if (name == "cone")          translate([0,0,base_h + cap_t - nest_h])        funnel_cone();
    else if (name == "shell")         translate([0,0,base_h])                         funnel_shell();
    else if (name == "spider")        translate([0,0,base_h + cap_t - nest_h])        spider();
    else if (name == "ring")          translate([0,0,base_h + z_funnel_top])          ring();
    else if (name == "lid_on_ring")   translate([0,0,base_h + z_funnel_top + ring_h]) lid();
    else if (name == "tray")          tray_mounted();
}

module A(name)
    color(col(name), alp(name)) {
        if (mesh_dir != "") import(str(mesh_dir, "/p_", name, ".stl"));
        else                G(name);
    }

// place `name`: HIDDEN until its window opens at `a`, then slides from the approach
// offset (ox,oy,oz) into its seat across [a,b]. Progressive build — only the in-flight
// part is aloft, everything earlier is already seated.
module place(name, ox,oy,oz, a,b) {
    if ($t >= a) {
        p = prog(a,b);
        translate([ox*(1-p), oy*(1-p), oz*(1-p)]) A(name);
    }
}

// Scene spin, so whatever is being fitted faces the viewer. Verified by rendering the
// base + panel + platform at 0 and 90 and looking:
//   90  = service window (electronics, power) toward the camera
//   270 = front scallop (feed tray) toward the camera
//
// This MUST be a function called from inside rotate(), not a top-level variable.
// $t arrives via -D, and OpenSCAD does not have it in scope during the top-level
// ASSIGNMENT pass — `view_ang = ...*prog($t...)` silently evaluated as if $t were 0,
// so the scene never turned while the parts animated correctly (they are guarded
// inside module instantiations, where $t is live). Same trap for anything else
// derived from $t outside a module.
// Each turn is timed so the part being fitted is roughly face-on when it seats.
function view_ang() =
      270                               // front-on: the niche, the load cell, the bowl platform
    + 180*prog(0.20, 0.28)              // swing to the service side for the electronics bay
    + 180*prog(0.80, 0.89)              // back to the front for the feed tray
    + 180*prog(0.955, 0.975);           // and round again to end on the power lead

rotate([0, 0, view_ang()]) {
    A("base_motor");                                        // ground — static

    // --- 1. inside the leg shroud: motor, weighing, electronics bay ---
    place("motor",          0,  0, -70,   0.05, 0.11);      // NEMA17 enters from BELOW
    // The weighing pair comes in from the FRONT (+X), not straight down. Both cantilever
    // past the Ø160 base (cell to x=105, platform to x=158) and the tray they carry slides
    // out +X, so a drop was never the real motion — and the sweep agrees: dropped, they
    // clip the base rim (103 / 606 mm3); slid in +X, the platform is 0.0 mm3 at every
    // sample. The cell still scrapes a 1 mm sill on the way (38.9 mm3, see the report) —
    // that is a seated-fit defect, constant along the path, not a blocked corridor.
    place("cell",          60,  0,   0,   0.11, 0.16);      // load cell onto its pedestal
    place("cell_platform", 60,  0,   0,   0.16, 0.21);      // weighing platform onto the cell
    place("el_tray",        0,  0,  60,   0.21, 0.27);      // tray drops down the wall rails
    place("boards",         0,  0,  60,   0.21, 0.27);      // boards ride the tray in
    place("el_panel",      27,  0,   0,   0.27, 0.32);      // panel fitted from INSIDE, outward
    place("dc_jack",       20,  0,   0,   0.32, 0.36);      // barrel jack through the panel

    // --- 2. the dosing stack ---
    place("base_hopper",    0,  0,  70,   0.36, 0.42);      // core disc caps the bay
    place("housing",        0,  0,  80,   0.42, 0.48);      // paddle housing over the centre
    place("wheel",          0,  0,  80,   0.48, 0.53);      // dosing wheel INTO the housing
    place("cap",            0,  0,  80,   0.53, 0.58);      // cap plate onto the housing top
    place("cone",           0,  0,  75,   0.58, 0.64);      // mass-flow cone onto the cap
    place("shell",          0,  0,  85,   0.64, 0.70);      // big tube down over the cone
    place("spider",         0,  0,  75,   0.70, 0.76);      // anti-pressure spider into pockets

    // --- 3. bayonets: drop held at +bay_run, then twist to 0 to lock ---
    if ($t >= 0.76) {
        translate([0, 0, 60*(1 - prog(0.76, 0.82))])
            rotate([0, 0, bay_run*(1 - prog(0.82, 0.86))]) A("ring");
    }
    if ($t >= 0.86) {
        translate([0, 0, 55*(1 - prog(0.86, 0.90))])
            rotate([0, 0, bay_run*(1 - prog(0.90, 0.92))]) A("lid_on_ring");
    }

    // --- 4. service items the owner touches: feed tray, then the power lead ---
    // Nothing here may overlap the lid twist above. The lid sits at z350..366 and the tray
    // at z22..38, so a camera asked to hold both at once has to frame the entire 366 mm
    // tower and the plugs end up three pixels wide — the exact thing this video must show.
    // Sequential beats, with the scene turn parked in the gap at 0.955..0.975.
    place("tray",          90,  0,   0,   0.925, 0.955);    // slides back into the scallop
    place("dc_plug",      -40,  0,   0,   0.975, 0.990);    // power plug pushed in
    place("usb_plug",     -40,  0,   0,   0.985, 1.000);    // USB for flashing / service
}
