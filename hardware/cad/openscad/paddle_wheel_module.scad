// AiPetFeeder — Paddle-wheel rotary-disc dispenser
// ---------------------------------------------------------------------------
// Rewrite 2026-05-25: COLLAR-MOUNT hopper redesign per ADR
// `2026-05-25-collar-mount-hopper-redesign`. Hopper no longer plugs INTO a
// socket — it sits ON TOP of the cap, retained laterally by a low collar
// (fence) that surrounds its outer bottom edge. Kibble flow pipe has no
// wall narrowing and no shelf — the cap inlet hole IS the narrowest cross-
// section in the entire pipe.
//
// Architecture summary (unchanged from previous revision):
// Housing rests on its FLAT circular floor (axle vertical in operation).
// Inlet through the cap (rounded-rect hole at a radial offset). Outlet
// through the floor (same shape hole, 180° apart angularly). Paddles fill
// only the BOTTOM half of the cavity — they sweep kibble along the floor
// from inlet position to outlet position.
//
//        ┌──────────────────────────┐
//        │     hopper / funnel      │     (sits ON TOP of cap;
//        │     (open bottom)        │      no spout into a socket)
//        └────────────┬─────────────┘
//                     │ flow area = hole size (no walls)
//                     │
//        ╔═══╦════════│════════════╦══╗   ← collar walls (fence)
//        ║   ╠════════╧════════════╣  ║      surrounding the hopper
//        ╞═══╧═══════════════════════╡   ← end_cap rim (removable)
//        │     ░░░░░░░░░░░░░░░░░░   │      cavity
//        │  ┌──┐  ┌──┐  ┌──┐ (3×)   │      paddles (bottom half only)
//        ├──┤  ├──┤  ├──┤           │      n_paddles = 3, sweep floor
//        ├──┘  └──┴──┘  └───────────┤      housing floor
//                  │  outlet hole
//                  ▼ → chute → bowl
//
// Parts:
//   part = "wheel"    -> hub + half-height paddles + D-bore
//   part = "axle"     -> through axle
//   part = "housing"  -> cup, floor with outlet hole (rounded corners)
//   part = "end_cap"  -> lid with axle bore + inlet hole (rounded corners)
//                        + COLLAR (rectangular fence) on top, around the
//                        hole, retaining the hopper laterally
//   part = "hopper"   -> small test hopper, open-bottom rect-to-round cone
//   part = "assembly" -> all stacked together for fit check
// ===========================================================================

part = "assembly";   // wheel | axle | housing | end_cap | hopper | assembly

/* [Wheel] */
// 2026-05-28: scaled to wheel_d=120 (was 80) per the bigger-wheel anti-
// bridge approach (ADR pending). Goal: hole 35×35 mm gives a 3:1
// kibble:hole ratio (was ~2:1), much less prone to static bridging.
wheel_d         = 120;   // outer diameter (over paddle tips)
wheel_thickness = 10;    // shorter wheel because the pocket area grew —
                         //   10 × pocket area (n=3) gives ~35 mL ≈ 14 g
n_paddles       = 3;     // sector 120°
paddle_thick    = 2.4;
paddle_fraction = 0.5;
hub_d           = 30;    // scaled proportionally (was 20 with wheel_d=80)

/* [Axle] */
axle_d         = 5.0;
axle_flat      = 0.8;
axle_stub_top  = 8;
axle_stub_bot  = 22;
fit_clear      = 0.30;

/* [Housing] */
housing_clear      = 0.8;
wheel_axial_clear  = 0.5;
floor_clear        = 0.5;
housing_wall       = 3;
end_wall           = 3;

/* [Removable end cap] */
register_d     = 1.5;
step_w         = 1.0;

/* [Inlet / outlet rectangular hole] */
// Rounded-rect, radially aligned. Hole IS the narrowest cross-section in
// the entire kibble pipe (cone narrows down to it directly; no wall
// constriction above or below).
hole_radial_in   = 22;
hole_radial_out  = 57;   // length 35 mm
hole_w           = 35;   // tangential width — 3× kibble (~12 mm), much
                         //   bigger margin than the 28 mm in the Ø80 wheel
hole_corner_r    = 2;    // rounded corners — no piece-corner catch points
inlet_angle_deg  = 180;
outlet_angle_deg = 0;

/* [Hopper collar on the cap] (replaces the old boss-socket) */
collar_h     = 10;     // collar wall height above the cap surface
collar_wall  = 2.0;    // collar wall thickness
collar_clear = 0.5;    // hopper outer <-> collar inner slip-fit clearance
hopper_wall  = 2;      // wall thickness of the test/bulk hopper

/* [Test hopper] (the small bench hopper; bulk hopper is a separate file) */
hopper_top_d   = 70;
hopper_h       = 55;

/* [Quality] */
$fn = 96;

// --- derived ----------------------------------------------------------------
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

// Hopper outer bottom (sits on the cap, around the hole)
hopper_outer_w     = hole_w + 2 * hopper_wall;
hopper_outer_len   = hole_len + 2 * hopper_wall;

// Collar inner outline (surrounds the hopper outer bottom)
collar_inner_w     = hopper_outer_w + 2 * collar_clear;
collar_inner_len   = hopper_outer_len + 2 * collar_clear;
collar_outer_w     = collar_inner_w + 2 * collar_wall;
collar_outer_len   = collar_inner_len + 2 * collar_wall;

// --- helpers ----------------------------------------------------------------
// Rounded rectangle extruded along z (centered on origin in X/Y)
module rounded_rect(x, y, r, h) {
    hull() {
        for (dx = [-1, 1])
            for (dy = [-1, 1])
                translate([dx * (x/2 - r), dy * (y/2 - r), 0])
                    cylinder(r = r, h = h);
    }
}

// D-shape (axle + matching bore)
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
            cylinder(h = wheel_thickness, d = hub_d);
            for (i = [0 : n_paddles - 1])
                rotate([0, 0, 360 * i / n_paddles])
                    translate([hub_r - 0.1, -paddle_thick/2, 0])
                        cube([wheel_r - hub_r + 0.1,
                              paddle_thick,
                              paddle_h]);
        }
        translate([0, 0, -1])
            d_solid(axle_d + fit_clear, axle_flat, wheel_thickness + 2);
    }
}

// ===========================================================================
// AXLE
// ===========================================================================
module axle() {
    total = axle_stub_bot + housing_h + end_wall + axle_stub_top;
    engage_z0 = axle_stub_bot + end_wall + floor_clear;
    difference() {
        cylinder(h = total, d = axle_d);
        translate([axle_d/2 - axle_flat, -axle_d, engage_z0])
            cube([axle_d, 2*axle_d, wheel_thickness]);
    }
}

// ===========================================================================
// HOUSING  cup with closed floor; outlet is a ROUNDED-RECT hole
// ===========================================================================
module housing() {
    difference() {
        cylinder(h = housing_h, d = 2 * hr_out);

        // wheel cavity
        translate([0, 0, end_wall])
            cylinder(h = housing_h - end_wall + 1, d = 2 * hr_in);

        // central axle bore
        translate([0, 0, -1])
            cylinder(h = end_wall + 2, d = axle_d + fit_clear * 2);

        // rim recess for cap lip
        translate([0, 0, housing_h - register_d])
            cylinder(h = register_d + 1, d = 2 * (hr_in + step_w));

        // OUTLET — rounded-rect hole through floor
        rotate([0, 0, outlet_angle_deg])
            translate([hole_mid_r, 0, -1])
                rounded_rect(hole_len, hole_w, hole_corner_r,
                             end_wall + 2);
    }
}

// ===========================================================================
// END_CAP  disc + lip + axle bore + inlet ROUNDED-RECT hole +
//          rectangular COLLAR (fence) around the hole on top
//
// Collar replaces the old boss-socket. The hopper sits ON the cap top
// surface (around the hole), with the collar surrounding its outer edge.
// No socket, no shelf, no wall narrowing of the kibble flow.
// Collar is intersected with the cap disc so its corners cannot overhang
// the cap OD.
// ===========================================================================
module end_cap() {
    lip_d = 2 * (hr_in + step_w - fit_clear);
    difference() {
        union() {
            // disc body
            cylinder(h = end_wall, d = 2 * hr_out);
            // register lip on underside
            translate([0, 0, -register_d])
                cylinder(h = register_d, d = lip_d);
            // collar on top, around the hole — clipped to the cap OD so
            // its tangential corners never overhang the disc edge
            intersection() {
                rotate([0, 0, inlet_angle_deg])
                    translate([hole_mid_r, 0, end_wall])
                        rounded_rect(collar_outer_len, collar_outer_w,
                                     hole_corner_r + collar_wall + collar_clear,
                                     collar_h);
                // limit collar to within cap OD
                cylinder(h = end_wall + collar_h + 1, d = 2 * hr_out);
            }
        }

        // central axle bore
        translate([0, 0, -register_d - 1])
            cylinder(h = end_wall + register_d + 2,
                     d = axle_d + fit_clear * 2);

        // INLET — rounded-rect hole through cap, AND collar interior cavity
        // (same outline above the cap: cavity that accepts the hopper outer
        // bottom edge with collar_clear clearance)
        rotate([0, 0, inlet_angle_deg])
            translate([hole_mid_r, 0, -register_d - 1]) {
                // through-hole (cap thickness): exactly the flow area
                rounded_rect(hole_len, hole_w, hole_corner_r,
                             end_wall + register_d + 2);
                // collar interior above cap top — wider, accepts hopper
                translate([0, 0, end_wall + register_d + 0.5])
                    rounded_rect(collar_inner_len, collar_inner_w,
                                 hole_corner_r + collar_clear,
                                 collar_h + 1);
            }
    }
}

// ===========================================================================
// HOPPER  small test hopper — open-bottom rect-to-round cone.
//         Bottom inner = hole size (= flow area). Sits ON the cap, inside
//         the collar. No spout cube below.
// ===========================================================================
module hopper() {
    // 2026-05-28 fix: added a straight rect plug at the bottom that fits
    // INTO the cap collar (which has straight vertical walls of height
    // collar_h). The taper used to start at z=0, conflicting with the
    // collar geometry immediately above z=0.
    overshoot = 2;
    difference() {
        union() {
            // Straight rect plug (height = collar_h) — slides into the cap collar
            rounded_rect(hopper_outer_len, hopper_outer_w,
                         hole_corner_r + hopper_wall, collar_h);
            // Tapered cone above the collar height
            hull() {
                translate([0, 0, collar_h])
                    rounded_rect(hopper_outer_len, hopper_outer_w,
                                 hole_corner_r + hopper_wall, 0.5);
                translate([0, 0, hopper_h - 0.5])
                    cylinder(d = hopper_top_d, h = 0.5);
            }
        }
        // Inner cavity (open at both ends)
        union() {
            // Straight inner bottom (= cap hole shape)
            translate([0, 0, -overshoot])
                rounded_rect(hole_len, hole_w, hole_corner_r,
                             collar_h + overshoot + 0.5);
            // Tapered inner above
            hull() {
                translate([0, 0, collar_h])
                    rounded_rect(hole_len, hole_w, hole_corner_r, 0.5);
                translate([0, 0, hopper_h + overshoot - 0.5])
                    cylinder(d = hopper_top_d - 2 * hopper_wall, h = 0.5);
            }
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
    // hopper sits ON the cap (z = housing_h + end_wall = cap top),
    // offset to inlet_angle_deg, radial offset hole_mid_r
    color("Khaki", 0.55)
        rotate([0, 0, inlet_angle_deg])
            translate([hole_mid_r, 0, housing_h + end_wall])
                hopper();
}

echo(str("hole=", hole_len, "x", hole_w, " r=", hole_corner_r,
         " at r_mid=", hole_mid_r,
         " collar_outer=", collar_outer_len, "x", collar_outer_w,
         " hopper_outer=", hopper_outer_len, "x", hopper_outer_w,
         " pocket_mL~", round((wheel_r*wheel_r - hub_r*hub_r) * 3.14159 / n_paddles * wheel_thickness / 1000)));
