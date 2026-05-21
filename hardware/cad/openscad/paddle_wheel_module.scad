// AiPetFeeder — Stage 1 paddle-wheel test module
// ---------------------------------------------------------------------------
// Why this exists: the auger module (feeder_test_module.scad) is being kept
// as a benchmark only. Real-world experience with auger + cat kibble is bad:
// jams + a permanent forward/back step dance. This module is the proven
// alternative — a vane wheel where each pocket between paddles holds one
// portion. Kibble enters by gravity, exits by gravity, never gets sheared.
// Reference architecture: GyverFeed2.
//
// Parts:
//   part = "wheel"    -> paddle wheel (rotates inside the housing)
//   part = "axle"     -> drive axle (round stubs + middle D-flat, like the
//                        auger axle but sized for this housing)
//   part = "housing"  -> cylinder around the wheel — closed bottom, OPEN
//                        TOP, with a top inlet boss (hopper socket) and a
//                        bottom outlet chute. Has a rim recess for the cap.
//   part = "end_cap"  -> removable disc that closes the top of the housing.
//                        Drops a register lip into the rim recess (slip
//                        fit, no screws for Stage 1). Carries the upper
//                        axle bore. **Remove the cap to insert the wheel.**
//   part = "hopper"   -> feed cone, spout plugs into the housing inlet boss
//   part = "assembly" -> all together (fit check, do NOT export)
//
// Torque path: motor -> axle round stub -> D-flat -> wheel -> portion drop.
// Food path:   bowl above -> hopper -> spout-in-socket -> top opening ->
//              pocket between paddles -> rotate ~half turn -> bottom opening
//              -> outlet chute -> bowl below.
// ===========================================================================

part = "assembly";   // wheel | axle | housing | end_cap | hopper | assembly

/* [Wheel] */
wheel_d        = 60;    // outer diameter (over paddle tips)
wheel_width    = 30;    // axial width (= pocket depth along axle)
n_paddles      = 4;     // number of paddles (= number of pockets per turn)
paddle_thick   = 2.4;   // paddle wall thickness
hub_d          = 16;    // central hub diameter (wraps the axle)

/* [Axle] — same key concept as the auger module */
axle_d         = 5.0;   // axle diameter (use a Ø5 mm steel rod ideally)
axle_flat      = 0.8;   // D-flat depth — torque key wheel <-> axle
axle_stub_rear = 22;    // length sticking out the rear (motor side)
axle_stub_front= 12;    // length sticking out the front (support side)
fit_clear      = 0.30;  // bore clearance for printer fit (axle, cap lip,
                        //   etc.). Bumped from 0.20 after first print: the
                        //   cap lip was too tight to seat by hand.

/* [Housing] */
housing_clear      = 0.8;  // radial gap wheel OD <-> housing bore. Was 0.6
                           // — bumped after first print so the wheel
                           // doesn't bind against the cavity walls.
wheel_axial_clear  = 0.5;  // axial play between wheel top and the start of
                           // the cap recess. Was 0 (wheel filled cavity
                           // exactly → wheel sat proud → cap couldn't
                           // seat). 0.5 mm is enough slack for print
                           // tolerance without letting the wheel rattle.
housing_wall       = 3;    // housing wall thickness (radial)
end_wall           = 3;    // bottom end-cap thickness / cap thickness
inlet_arc_deg      = 55;   // (legacy, unused after rect-cut refactor)
inlet_w            = 26;   // top opening width along the axle (mm)
outlet_arc_deg     = 60;   // (legacy)
outlet_w           = 24;   // bottom opening width along the axle (mm)

/* [Angular layout — where the inlet/outlet sit around the wheel axis] */
// Angles in the XY plane, CCW from +X. 90° = +Y; 270° = -Y. When the
// assembly is physically mounted with the axle HORIZONTAL, +Y is "up".
// Inlet stays on top so the hopper drops kibble in by gravity.
// Outlet is offset from straight-down on purpose: with a coaxial 90/270
// layout, a kibble piece that misses a pocket can slide along the housing
// wall and fall straight through the outlet unmetered. Offsetting the
// outlet forces every piece to be carried by a pocket — cleaner dosing.
inlet_angle_deg    = 90;
outlet_angle_deg   = 240;  // 30° offset from coaxial; bump up to e.g. 220
                           //   or 260 to suit motor rotation direction

/* [Removable end cap] (slip-fit lid so you can insert the wheel) */
register_d     = 1.5;   // depth of cap register lip into the housing rim
step_w         = 1.0;   // radial step width of the rim recess (mm)

/* [Inlet boss / hopper joint] (raised rectangular socket on top) */
boss_h         = 12;    // socket height above the housing surface
boss_wall      = 2.5;   // socket wall thickness
boss_flare     = 2;     // extra clearance around the inlet (kept small so
                        //   the boss doesn't extend above the housing rim)
join_clear     = 0.35;  // hopper-spout <-> boss-socket slip fit

/* [Outlet chute] (a short downward funnel below the bottom opening) */
chute_h        = 14;    // chute height below the housing surface
chute_taper    = 6;     // chute mouth widens by this much at the exit

/* [Feed cone / hopper] */
hopper_top_d   = 70;    // wide food opening at the top of the cone
hopper_h       = 55;    // cone height
hopper_wall    = 2;     // cone wall thickness
spout_h        = 9;     // straight spout that plugs into the boss socket

/* [Quality] */
$fn = 96;

// --- derived ------------------------------------------------------------
wheel_r        = wheel_d / 2;
hub_r          = hub_d  / 2;
hr_in          = wheel_r + housing_clear;          // housing inner radius
hr_out         = hr_in + housing_wall;             // housing outer radius
// housing_h = bottom end_wall + wheel + axial slack + cap recess depth.
// Was just (end_wall + wheel_width); the wheel was binding into the
// recess so the cap couldn't seat.
housing_h      = end_wall + wheel_width
               + wheel_axial_clear + register_d;
hlen           = housing_h + end_wall;             // total assembly (housing + cap)

// inlet/outlet boss footprint (rectangular, on top/bottom of housing)
boss_y         = (inlet_w + 2*boss_flare);
boss_x         = 2 * hr_in * sin(inlet_arc_deg/2) + 2*boss_flare;
chute_y        = outlet_w + 2*boss_flare;
chute_x        = 2 * hr_in * sin(outlet_arc_deg/2) + 2*boss_flare;

// D-shape solid: cylinder with one +X side flattened. Axle and matching
// bore both use this shape so they key together.
module d_solid(d, flat, len) {
    difference() {
        cylinder(h = len, d = d);
        translate([d/2 - flat, -d, -1]) cube([d, 2*d, len + 2]);
    }
}

// ===========================================================================
// PADDLE WHEEL
// ===========================================================================
module wheel() {
    difference() {
        union() {
            // central hub
            cylinder(h = wheel_width, d = hub_d);
            // N radial paddles
            for (i = [0 : n_paddles - 1])
                rotate([0, 0, 360 * i / n_paddles])
                    translate([hub_r - 0.1, -paddle_thick/2, 0])
                        cube([wheel_r - hub_r + 0.1, paddle_thick, wheel_width]);
        }
        // through D-bore for the axle
        translate([0, 0, -1])
            d_solid(axle_d + fit_clear, axle_flat, wheel_width + 2);
    }
}

// ===========================================================================
// AXLE  (same idea as the auger axle)
// ===========================================================================
module axle() {
    total = axle_stub_rear + wheel_width + axle_stub_front;
    difference() {
        cylinder(h = total, d = axle_d);
        // D-flat over the wheel engagement length
        translate([axle_d/2 - axle_flat, -axle_d, axle_stub_rear])
            cube([axle_d, 2*axle_d, wheel_width]);
    }
}

// ===========================================================================
// HOUSING  (closed cylinder + top inlet boss + bottom outlet chute)
// ===========================================================================
module housing() {
    inlet_z   = end_wall + (wheel_width - inlet_w)  / 2;
    outlet_z  = end_wall + (wheel_width - outlet_w) / 2;
    socket_w  = boss_x  - 2 * boss_wall;       // socket inner X (= spout X)
    socket_h  = inlet_w + 2 * boss_flare;      // socket inner Z (= spout Z)
    cs_w      = chute_x - 2 * boss_wall;       // chute interior top X
    cs_wbot   = chute_x + chute_taper - 2 * boss_wall;  // chute interior bottom X
    cs_h      = outlet_w + 2 * boss_flare;     // chute interior Z

    // Both the inlet and the outlet are built first at their "natural"
    // orientations (boss at +Y, chute at -Y), then rotated to their final
    // angular positions around Z. Keep these rotations identical for the
    // boss-outer/inlet-cut pair and the chute-outer/outlet-cut pair so the
    // material and the cavity stay aligned.
    inlet_rot  = inlet_angle_deg  - 90;
    outlet_rot = outlet_angle_deg - 270;

    difference() {
        union() {
            // main body — CLOSED BOTTOM, OPEN TOP. The top end_wall is
            // removed; the cavity goes through to the rim. The removable
            // end_cap closes it from above.
            cylinder(h = housing_h, d = 2 * hr_out);
            // inlet boss at inlet_angle_deg
            rotate([0, 0, inlet_rot])
                translate([ -boss_x/2,
                             hr_in - 1,
                             inlet_z - boss_flare ])
                    cube([ boss_x,
                           (hr_out - hr_in + 1) + boss_h,
                           socket_h ]);
            // outlet chute at outlet_angle_deg (frustum widening outward)
            rotate([0, 0, outlet_rot])
                hull() {
                    translate([ -chute_x/2,
                                -hr_out + 3,
                                 outlet_z - boss_flare ])
                        cube([ chute_x, 0.1, cs_h ]);
                    translate([ -(chute_x + chute_taper)/2,
                                -(hr_out + chute_h),
                                 outlet_z - boss_flare ])
                        cube([ chute_x + chute_taper, 0.1, cs_h ]);
                }
        }

        // wheel cavity — extends past the wheel top by wheel_axial_clear
        // so the wheel doesn't crash into the cap recess above
        translate([0, 0, end_wall])
            cylinder(h = wheel_width + wheel_axial_clear + 1,
                     d = 2 * hr_in);

        // axle bore through the bottom end_wall (the cap carries the top
        // half of the bore in its own module)
        translate([0, 0, -1])
            cylinder(h = end_wall + 2, d = axle_d + fit_clear * 2);

        // rim recess: the upper register_d mm of the cavity is widened by
        // step_w so the cap's register lip can drop in and locate the cap
        translate([0, 0, housing_h - register_d])
            cylinder(h = register_d + 1, d = 2 * (hr_in + step_w));

        // INLET — rectangular through-cut, at inlet_angle_deg
        rotate([0, 0, inlet_rot])
            translate([ -socket_w/2,
                         hr_in - 2,
                         inlet_z - boss_flare ])
                cube([ socket_w,
                       (hr_out - hr_in + 1) + boss_h + 4,
                       socket_h ]);

        // OUTLET — chute interior frustum, at outlet_angle_deg
        rotate([0, 0, outlet_rot])
            hull() {
                translate([ -cs_w/2,
                            -hr_in + 1,
                             outlet_z - boss_flare ])
                    cube([ cs_w, 0.1, cs_h ]);
                translate([ -cs_wbot/2,
                            -(hr_out + chute_h + 1),
                             outlet_z - boss_flare ])
                    cube([ cs_wbot, 0.1, cs_h ]);
            }
    }
}

// ===========================================================================
// END CAP  (removable lid for the open top of the housing)
// Slip-fit: a register lip on the underside drops into the rim recess in
// the housing. Carries the upper half of the axle bore. No screws for the
// Stage 1 test rig — gravity + lip alignment is enough; a rubber band or
// tape externally if it pops off during testing.
// ===========================================================================
module end_cap() {
    lip_d = 2 * (hr_in + step_w - fit_clear);   // fits the housing recess
    difference() {
        union() {
            // main disc, sits flush on the housing rim
            cylinder(h = end_wall, d = 2 * hr_out);
            // register lip on the underside
            translate([0, 0, -register_d])
                cylinder(h = register_d, d = lip_d);
        }
        // axle bore
        translate([0, 0, -register_d - 1])
            cylinder(h = end_wall + register_d + 2,
                     d = axle_d + fit_clear * 2);
    }
}

// ===========================================================================
// HOPPER  (round food opening -> rectangular spout, plugs into boss socket)
// Built along +Z, spout at z=0. Local X aligns to the axle when placed.
// ===========================================================================
module hopper() {
    sx = (boss_x - 2*boss_wall) - join_clear;   // along axle once placed
    sy = (inlet_w + 2*boss_flare) - join_clear; // around the wheel
    ix = sx - 2*hopper_wall;
    iy = sy - 2*hopper_wall;
    difference() {
        union() {
            translate([-sx/2, -sy/2, 0]) cube([sx, sy, spout_h]);
            hull() {
                translate([-sx/2, -sy/2, spout_h]) cube([sx, sy, 0.01]);
                translate([0, 0, spout_h + hopper_h - 0.01])
                    cylinder(h = 0.01, d = hopper_top_d);
            }
        }
        // hollow interior, open at both ends
        translate([-ix/2, -iy/2, -1]) cube([ix, iy, spout_h + 1]);
        translate([0, 0, spout_h])
            hull() {
                translate([-ix/2, -iy/2, -0.01]) cube([ix, iy, 0.01]);
                translate([0, 0, hopper_h + 1])
                    cylinder(h = 0.01, d = hopper_top_d - 2*hopper_wall);
            }
    }
}

// ===========================================================================
// RENDER
// ===========================================================================
if (part == "wheel")   wheel();
if (part == "axle")    axle();
if (part == "housing") housing();
if (part == "end_cap") end_cap();
if (part == "hopper")  hopper();
if (part == "assembly") {
    color("Silver")               translate([0, 0, end_wall]) wheel();
    color("DimGray")  translate([0, 0, -axle_stub_rear])    axle();
    color("LightBlue", 0.28)                                 housing();
    // removable cap on top of the housing rim
    color("LightSteelBlue", 0.55) translate([0, 0, housing_h]) end_cap();
    // hopper above the housing (+Y in this Z-up build, real-world "up"
    // when the assembly is mounted with the axle horizontal). Spout points
    // -Y into the boss socket; cone opens +Y away from the housing.
    // Wrapped in the same Z-rotation as the inlet boss so they track each
    // other when inlet_angle_deg changes.
    rotate([0, 0, inlet_angle_deg - 90])
    color("Khaki", 0.55)
        translate([0,
                   hr_out - 1,
                   end_wall + wheel_width/2 ])
            rotate([-90, 0, 0])
                hopper();
}

echo(str("wheel_d=", wheel_d, " pockets=", n_paddles,
         " pocket_arc=", round(360/n_paddles), "deg",
         " hr_out=", hr_out, " hlen=", hlen,
         " est_pocket_mL~", round((wheel_r*wheel_r - hub_r*hub_r) *
                                   3.14159 / n_paddles * wheel_width / 1000)));
