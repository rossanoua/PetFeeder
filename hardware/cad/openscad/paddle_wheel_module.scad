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
//   part = "housing"  -> closed cylinder around the wheel, with a top inlet
//                        boss (hopper socket) and a bottom outlet chute
//   part = "hopper"   -> feed cone, spout plugs into the housing inlet boss
//   part = "assembly" -> all together (fit check, do NOT export)
//
// Torque path: motor -> axle round stub -> D-flat -> wheel -> portion drop.
// Food path:   bowl above -> hopper -> spout-in-socket -> top opening ->
//              pocket between paddles -> rotate ~half turn -> bottom opening
//              -> outlet chute -> bowl below.
// ===========================================================================

part = "assembly";   // wheel | axle | housing | hopper | assembly

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
fit_clear      = 0.20;  // bore clearance for printer fit

/* [Housing] */
housing_clear  = 0.6;   // radial gap between wheel OD and housing bore
housing_wall   = 3;     // housing wall thickness (radial)
end_wall       = 3;     // end-cap thickness (axial, at each side)
inlet_arc_deg  = 55;    // top opening arc width (degrees)
inlet_w        = 26;    // top opening width along the axle (mm)
outlet_arc_deg = 60;    // bottom opening arc width (degrees)
outlet_w       = 28;    // bottom opening width along the axle (mm)

/* [Inlet boss / hopper joint] (raised rectangular socket on top) */
boss_h         = 12;    // socket height above the housing surface
boss_wall      = 2.5;   // socket wall thickness
boss_flare     = 4;     // extra clearance around the inlet opening
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
hlen           = wheel_width + 2 * end_wall;       // housing total length

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

    difference() {
        union() {
            // main body (closed cylinder w/ end caps)
            cylinder(h = hlen, d = 2 * hr_out);
            // top inlet boss: rectangular pad overlapping into the housing
            // wall (starts inside the wall, ends boss_h above OD)
            translate([ -boss_x/2,
                         hr_in - 1,
                         inlet_z - boss_flare ])
                cube([ boss_x,
                       (hr_out - hr_in + 1) + boss_h,
                       socket_h ]);
            // bottom outlet chute: frustum widening downward. Top slab is
            // 3 mm INSIDE the cylinder so the union overlaps cleanly.
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

        // wheel cavity between end caps
        translate([0, 0, end_wall])
            cylinder(h = wheel_width, d = 2 * hr_in);

        // axle bore through both end caps (slip fit)
        translate([0, 0, -1])
            cylinder(h = hlen + 2, d = axle_d + fit_clear * 2);

        // INLET — single rectangular through-cut: spans from inside the
        // wheel cavity up through the housing wall and out the boss top.
        // (Replaces the earlier arc-extrude wedge, which left ledge
        // artifacts where the wedge angle was narrower than the boss
        // chord.)
        translate([ -socket_w/2,
                     hr_in - 2,
                     inlet_z - boss_flare ])
            cube([ socket_w,
                   (hr_out - hr_in + 1) + boss_h + 4,
                   socket_h ]);

        // OUTLET — chute interior, a single hulled frustum from inside
        // the wheel cavity down through the chute exit.
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
if (part == "hopper")  hopper();
if (part == "assembly") {
    color("Silver")               translate([0, 0, end_wall]) wheel();
    color("DimGray")  translate([0, 0, -axle_stub_rear])    axle();
    color("LightBlue", 0.28)                                 housing();
    // hopper above the housing (+Y in this Z-up build, real-world "up"
    // when the assembly is mounted with the axle horizontal). Spout points
    // -Y into the boss socket; cone opens +Y away from the housing.
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
