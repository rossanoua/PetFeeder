// AiPetFeeder — Stage 1 paddle-wheel rotary-disc dispenser
// ---------------------------------------------------------------------------
// REVISED ARCHITECTURE (2026-05-21) — user feedback after first physical
// test: the radial inlet/outlet layout was wrong. The correct layout is
// AXIAL: housing rests on its flat circular floor, the wheel axis is
// vertical, inlet is a hole through the top end_cap, outlet is the same
// shape hole through the floor. Paddles fill only the BOTTOM HALF of the
// cavity so they can sweep kibble along the floor from inlet position to
// outlet position; food drops into a pocket through the cap, rides
// around in the pocket, and falls out through the floor outlet.
//
//        ┌────────────────────────┐
//        │      hopper cone       │
//        └───────────┬────────────┘
//                    │ spout
//             ┌──────┴───────┐         (inlet boss on the cap)
//             │              │
//        ╞════╧══════════════╧═════╡   ← end_cap rim (removable)
//        │     ░░░░░░░░░░░░░         ░ │   open space (top half)
//        │                          │
//        │  ┌──┐  ┌──┐  ┌──┐  ┌──┐  │   ← paddles, bottom half only
//        │  │  │  │  │  │  │  │  │  │       (sweep kibble along floor)
//        ├──┤  ├──┤  ├──┤  ├──┤  ├──┤   ← housing floor
//                    │
//                    ▼ outlet
//                   bowl
//
// Parts:
//   part = "wheel"    -> full-height hub + half-height paddles + D-bore
//   part = "axle"     -> through axle (motor below, retention above)
//   part = "housing"  -> cylindrical wall + closed floor with outlet
//                        hole. OPEN top for cap insertion.
//   part = "end_cap"  -> removable lid: axle bore + inlet hole +
//                        boss-socket on top for the hopper spout
//   part = "hopper"   -> feed cone (round → rectangular spout)
//   part = "assembly" -> all together
//
// Torque path: motor → axle bottom stub → axle D-flat → wheel hub
//              → paddles → kibble.
// Food path:   hopper → spout → cap boss-socket → cap inlet hole →
//              pocket between paddles → wheel rotates → pocket arrives
//              over the floor outlet hole → kibble falls into the bowl.
//
// MOUNTING NOTE: the housing rests on its flat floor BUT the outlet is in
// that floor. For the Stage 1 test rig you need to prop the housing up
// (small blocks under the rim, or a future bracket) so kibble can clear
// the outlet. The motor coupler attached to the bottom axle stub also
// works as a built-in standoff if the motor is mounted below.
// ===========================================================================

part = "assembly";   // wheel | axle | housing | end_cap | hopper | assembly

/* [Wheel] */
// Sized 2026-05-24 from real-kibble test: previous 60 mm wheel had
// 16×12 mm inlet/outlet holes — too small for the user's kibble
// (~10–12 mm pieces wedged at the opening). Scaled up to 80 mm wheel
// to make the rectangular hole 20×22 mm so two kibble pieces can pass
// without binding. See vault decision 2026-05-24-upscale-wheel-d-60-to-80.
wheel_d         = 80;    // outer diameter (over paddle tips)
wheel_thickness = 26;    // axial extent of the wheel hub (full cavity height)
n_paddles       = 4;     // number of paddles
paddle_thick    = 2.4;   // paddle wall thickness
paddle_fraction = 0.5;   // paddles occupy this fraction of wheel_thickness
                         //   from the bottom (per user spec: half)
hub_d           = 20;    // central hub diameter (kept proportional to wheel_d)

/* [Axle] */
axle_d          = 5.0;
axle_flat       = 0.8;
axle_stub_top   = 8;     // sticks above the cap (helps retain the cap)
axle_stub_bot   = 22;    // sticks below the housing floor (motor side)
fit_clear       = 0.30;  // bore clearance for printer fit

/* [Housing] */
housing_clear      = 0.8;   // radial gap wheel OD <-> housing bore
wheel_axial_clear  = 0.5;   // axial play between wheel top and cap recess
floor_clear        = 0.5;   // gap between paddle bottom and housing floor
housing_wall       = 3;
end_wall           = 3;     // bottom floor thickness; cap thickness

/* [Removable end cap — slip-fit lid] */
register_d     = 1.5;
step_w         = 1.0;

/* [Inlet / outlet rectangular hole] (in cap and floor respectively) */
// Hole is rectangular and aligned RADIALLY (long axis runs from near the
// axle outward toward the housing wall). It must fit inside one pocket
// sector (so only one pocket dispenses at a time).
hole_radial_in   = 18;   // inner edge from axle center
hole_radial_out  = 38;   // outer edge (just inside wheel_r=40)
hole_w           = 22;   // tangential width — sized so that 2 kibble
                         //   pieces (~10–12 mm each) can fit side by
                         //   side. Margin against pocket chord at r=18,
                         //   n=4: ~0.85 mm per side for paddle clearance.
inlet_angle_deg  = 180;  // -X side of cap (BACK of feeder; hopper above is on the back/centre column)
outlet_angle_deg = 0;    // +X side of floor (FRONT of feeder; over the bowl niche / chute)
                         //   inlet and outlet 180° apart = half-rotation transit

/* [Inlet boss / hopper joint] (raised socket on top of the cap) */
boss_h         = 12;     // socket height above the cap surface
boss_wall      = 2.5;    // socket wall thickness
boss_flare     = 2;      // socket clearance around the hole (creates shelf)
join_clear     = 0.35;   // hopper-spout <-> socket slip fit

/* [Hopper] */
hopper_top_d   = 70;
hopper_h       = 55;
hopper_wall    = 2;
spout_h        = 9;

/* [Quality] */
$fn = 96;

// --- derived ------------------------------------------------------------
wheel_r    = wheel_d / 2;
hub_r      = hub_d   / 2;
hr_in      = wheel_r + housing_clear;
hr_out     = hr_in + housing_wall;
housing_h  = end_wall + floor_clear + wheel_thickness
           + wheel_axial_clear + register_d;
hlen       = housing_h + end_wall;

paddle_h   = wheel_thickness * paddle_fraction;
hole_len   = hole_radial_out - hole_radial_in;
hole_mid_r = (hole_radial_in + hole_radial_out) / 2;

socket_x   = hole_len + 2 * boss_flare;       // socket inner (radial)
socket_y   = hole_w   + 2 * boss_flare;       // socket inner (tangential)
boss_bx    = socket_x + 2 * boss_wall;        // boss outer (radial)
boss_by    = socket_y + 2 * boss_wall;        // boss outer (tangential)

// D-profile solid: cylinder with one +X side flattened (axle cross-section
// and matching bore).
module d_solid(d, flat, len) {
    difference() {
        cylinder(h = len, d = d);
        translate([d/2 - flat, -d, -1]) cube([d, 2*d, len + 2]);
    }
}

// ===========================================================================
// WHEEL  full-height hub + N radial paddles on the bottom half
// ===========================================================================
module wheel() {
    difference() {
        union() {
            // hub spans the full cavity height for axle support
            cylinder(h = wheel_thickness, d = hub_d);
            // paddles only on the bottom half — they sweep the floor
            for (i = [0 : n_paddles - 1])
                rotate([0, 0, 360 * i / n_paddles])
                    translate([hub_r - 0.1, -paddle_thick/2, 0])
                        cube([wheel_r - hub_r + 0.1,
                              paddle_thick,
                              paddle_h]);
        }
        // through D-bore
        translate([0, 0, -1])
            d_solid(axle_d + fit_clear, axle_flat, wheel_thickness + 2);
    }
}

// ===========================================================================
// AXLE  long enough to span motor stub + floor + cavity + cap + retention
// ===========================================================================
module axle() {
    total = axle_stub_bot + housing_h + end_wall + axle_stub_top;
    // D-flat over the wheel engagement region only (middle section)
    engage_z0 = axle_stub_bot + end_wall + floor_clear;
    difference() {
        cylinder(h = total, d = axle_d);
        translate([axle_d/2 - axle_flat, -axle_d, engage_z0])
            cube([axle_d, 2*axle_d, wheel_thickness]);
    }
}

// ===========================================================================
// HOUSING  cylindrical wall + closed floor (outlet hole) + open top
// ===========================================================================
module housing() {
    difference() {
        // main body — closed floor, open top
        cylinder(h = housing_h, d = 2 * hr_out);

        // wheel cavity (open at the top — extends past housing_h)
        translate([0, 0, end_wall])
            cylinder(h = housing_h - end_wall + 1, d = 2 * hr_in);

        // central axle bore through the floor
        translate([0, 0, -1])
            cylinder(h = end_wall + 2, d = axle_d + fit_clear * 2);

        // rim recess for the cap register lip
        translate([0, 0, housing_h - register_d])
            cylinder(h = register_d + 1, d = 2 * (hr_in + step_w));

        // OUTLET — rectangular hole through the floor, at outlet_angle_deg
        rotate([0, 0, outlet_angle_deg])
            translate([hole_radial_in, -hole_w/2, -1])
                cube([hole_len, hole_w, end_wall + 2]);
    }
}

// ===========================================================================
// END_CAP  disc + register lip + axle bore + inlet hole + boss-socket
// ===========================================================================
module end_cap() {
    lip_d = 2 * (hr_in + step_w - fit_clear);
    difference() {
        union() {
            // disc body (sits flush on the housing rim)
            cylinder(h = end_wall, d = 2 * hr_out);
            // register lip on the underside
            translate([0, 0, -register_d])
                cylinder(h = register_d, d = lip_d);
            // hopper-socket boss on top, around the inlet hole
            rotate([0, 0, inlet_angle_deg])
                translate([hole_mid_r - boss_bx/2, -boss_by/2, end_wall])
                    cube([boss_bx, boss_by, boss_h]);
        }
        // central axle bore
        translate([0, 0, -register_d - 1])
            cylinder(h = end_wall + register_d + 2,
                     d = axle_d + fit_clear * 2);

        // inlet hole + socket cavity (rotated to inlet_angle_deg)
        rotate([0, 0, inlet_angle_deg]) {
            // through-hole (narrower → forms a shelf at cap-top surface
            // that the hopper spout sits on)
            translate([hole_radial_in, -hole_w/2, -register_d - 1])
                cube([hole_len, hole_w, end_wall + register_d + 2]);
            // socket cavity above the cap (wider — receives the spout)
            translate([hole_mid_r - socket_x/2,
                       -socket_y/2,
                       end_wall])
                cube([socket_x, socket_y, boss_h + 1]);
        }
    }
}

// ===========================================================================
// HOPPER  cone (round opening) → rectangular spout plug
// ===========================================================================
module hopper() {
    sx = socket_x - join_clear;
    sy = socket_y - join_clear;
    ix = sx - 2 * hopper_wall;
    iy = sy - 2 * hopper_wall;
    difference() {
        union() {
            translate([-sx/2, -sy/2, 0]) cube([sx, sy, spout_h]);
            hull() {
                translate([-sx/2, -sy/2, spout_h]) cube([sx, sy, 0.01]);
                translate([0, 0, spout_h + hopper_h - 0.01])
                    cylinder(h = 0.01, d = hopper_top_d);
            }
        }
        translate([-ix/2, -iy/2, -1]) cube([ix, iy, spout_h + 1]);
        translate([0, 0, spout_h])
            hull() {
                translate([-ix/2, -iy/2, -0.01]) cube([ix, iy, 0.01]);
                translate([0, 0, hopper_h + 1])
                    cylinder(h = 0.01, d = hopper_top_d - 2 * hopper_wall);
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
    color("Silver")
        translate([0, 0, end_wall + floor_clear]) wheel();
    color("DimGray")
        translate([0, 0, -axle_stub_bot]) axle();
    color("LightBlue", 0.28)
        housing();
    color("LightSteelBlue", 0.55)
        translate([0, 0, housing_h]) end_cap();
    // Hopper sits on top of the cap boss. Spout enters the cap socket
    // at angular position inlet_angle_deg, radial offset hole_mid_r.
    color("Khaki", 0.55)
        rotate([0, 0, inlet_angle_deg])
            translate([hole_mid_r, 0, housing_h + end_wall])
                hopper();
}

echo(str("housing_h=", housing_h, " hlen=", hlen,
         " paddle_h=", paddle_h,
         " hole=", hole_len, "x", hole_w, " at r=", hole_mid_r,
         " axle_total=", axle_stub_bot + housing_h + end_wall + axle_stub_top));
