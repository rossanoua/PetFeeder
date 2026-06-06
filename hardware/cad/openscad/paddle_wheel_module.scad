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
// 2026-06-03: scaled BACK to wheel_d=80 (was 120). The Ø120 upscale
// existed only to fight bridging passively; we're switching to an ACTIVE
// anti-bridge (vibromotor on the funnel) + HX711 closed-loop, so the big
// wheel is no longer needed and the whole mechanism shrinks. Portion is
// now set by rotation count, not pocket volume.
wheel_d         = 80;    // outer diameter (over paddle tips)
wheel_thickness = 18;    // axial extent of wheel hub (taller again — the
                         //   pocket area shrank with the smaller wheel)
n_paddles       = 3;     // sector 120°
paddle_thick    = 2.4;
paddle_fraction = 0.5;
hub_d           = 20;    // proportional to wheel_d=80

/* [Active stirrer cone] (2026-06-05, replaces the dead static spider) */
// A frustum on the hub TOP, under the (now bigger, axle-ward) cap inlet.
// 3 proud VANES (continuations of the paddles) ride the cone — because
// they ROTATE with the wheel, they poke/break any arch forming over the
// centre. Kibble also can't rest on a flat top: it slides into pockets.
cone_h        = 11;      // cone height above the hub (clears the cap ~4.5 mm)
cone_top_d    = 8;       // truncated tip Ø (solid above the axle)
vane_proud    = 2.5;     // how far the vanes stand proud of the cone
vane_t        = paddle_thick;  // vane thickness = paddle thickness

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
// 2026-05-29: kibble settling buffer between the wheel TOP and the cap
// INLET. Before this was implicit 0 mm — kibble dropping through the
// cap inlet had no room to spread before hitting the wheel. 15 mm =
// one full kibble (~12 mm) plus clearance; multiple pieces can
// pre-stack in the buffer and settle into pockets as they pass under
// the inlet.
housing_buffer_h   = 15;

/* [Anti-rotation lock — robust rim MERLONS (housing) + cap NOTCHES] */
// 2026-06-05 v5: a v4 merlon snapped off easily (thin 3×8 mm tab, 5 mm
// tall — weak across the print layers). Beefed up so it can't break:
//   • LONGER tangentially (lock_w 8→14) and LOWER (rise 5→4) = far more
//     base area, less leverage.
//   • Thickened INWARD by lock_thick into the buffer (empty there) so the
//     merlon is 6 mm radial, not 3 — much stiffer against a radial knock.
//   • A chamfered ANCHOR ramps that thickening down into the wall below
//     the rim → no thin neck at the base (the usual snap point), and it
//     stays self-supporting to print.
//   • Merlons are unioned AFTER the cavity cut so the inward part isn't
//     carved away. CAP notches match the bigger merlon footprint.
n_lock         = 4;
lock_angle_off = 45;    // diagonal — clear of inlet (180) / outlet (0)
lock_clear     = 0.3;   // merlon <-> notch slip clearance
lock_w         = 14;    // merlon / notch tangential width (was 8)
lock_rise      = 4;     // merlon height above the rim (pokes through cap)
lock_thick     = 3;     // inward radial thickening (into the buffer)
lock_anchor_h  = 4;     // chamfered anchor depth below the rim

/* [Inlet / outlet rectangular hole] */
// Rounded-rect, radially aligned. Hole IS the narrowest cross-section in
// the entire kibble pipe (cone narrows down to it directly; no wall
// constriction above or below).
hole_radial_in   = 7;    // 2026-06-05: extended inward toward the axle so
hole_radial_out  = 40;   //   kibble drops onto the stirrer cone. r=7 leaves
hole_w           = 34;   //   ~4 mm to the axle bore. out=40 is the wheel rim.
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
           + wheel_axial_clear + housing_buffer_h;
                            // no register_d any more — cap sits flat on
                            // top rim, located by axle + 4 merlon/notch locks
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
    // 2026-05-28 v2: paddle tip rounded in BOTH plan view AND side view.
    // v1 (earlier today) rounded only the plan-view tip with a Z-axis
    // cylinder — but the top-outer and bottom-outer edges (sharp 90°
    // when seen from the side) were still wedge points for kibble.
    //
    // Now: hull of a hub-side slab + 2 spheres at the outer tip's top
    // and bottom centers. Result:
    //   plan view  — rectangle with semicircular outer cap (r=1.2 mm)
    //   side view  — rectangle with rounded outer-top and outer-bottom
    //                fillets (r=1.2 mm)
    // Outer envelope unchanged: paddle still sweeps to wheel_r at the
    // sphere tangent points.
    rp = paddle_thick / 2;
    cone_top_r = cone_top_d / 2;
    difference() {
        union() {
            cylinder(h = wheel_thickness, d = hub_d);
            for (i = [0 : n_paddles - 1])
                rotate([0, 0, 360 * i / n_paddles])
                    hull() {
                        // Hub-side slab — overlaps INTO the hub for a
                        // solid join. No rounding at this end so the
                        // root keeps full paddle_h height against the
                        // hub cylinder.
                        translate([hub_r - 0.5, -paddle_thick/2, 0])
                            cube([0.5, paddle_thick, paddle_h]);
                        // Outer-tip: 2 spheres at the 4 tip corners
                        // (top-outer + bottom-outer get rounded in 3D).
                        translate([wheel_r - rp, 0, rp])
                            sphere(r = rp, $fn = 16);
                        translate([wheel_r - rp, 0, paddle_h - rp])
                            sphere(r = rp, $fn = 16);
                    }
            // Active stirrer: frustum on the hub top (base = hub_d).
            translate([0, 0, wheel_thickness])
                cylinder(h = cone_h, r1 = hub_r, r2 = cone_top_r);
            // 3 proud VANES on the cone (aligned with the paddles). Each
            // is a thin radial wall clipped to a cone vane_proud larger
            // than the core cone → a fin that hugs the cone and stands
            // vane_proud above it. Prints support-free (leans in going up).
            for (i = [0 : n_paddles - 1])
                rotate([0, 0, 360 * i / n_paddles])
                    intersection() {
                        // start at r=2 (not the axis) so the 3 vanes never
                        // overlap at the centre (that made it non-manifold)
                        translate([2, -vane_t/2, wheel_thickness])
                            cube([hub_r + vane_proud - 2, vane_t, cone_h]);
                        translate([0, 0, wheel_thickness])
                            cylinder(h = cone_h,
                                     r1 = hub_r + vane_proud,
                                     r2 = cone_top_r + vane_proud);
                    }
        }
        // axle D-bore — goes ALL THE WAY THROUGH (incl. the cone tip), so
        // the axle hole is obvious and the axle can pass up to the cap's
        // bore (top guide). The tip becomes a thin Ø(cone_top_d) ring.
        translate([0, 0, -1])
            d_solid(axle_d + fit_clear, axle_flat,
                    wheel_thickness + cone_h + 2);
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
    // 2026-06-05 v5: 4 robust rim MERLONS — raised, thickened inward, and
    // anchored below the rim so they can't snap. Unioned AFTER the cavity
    // cut so the inward thickening survives.
    union() {
        difference() {
            cylinder(h = housing_h, d = 2 * hr_out);

            // wheel cavity — plain full-width cylinder (full-width buffer)
            translate([0, 0, end_wall])
                cylinder(h = housing_h - end_wall + 1, d = 2 * hr_in);

            // central axle bore
            translate([0, 0, -1])
                cylinder(h = end_wall + 2, d = axle_d + fit_clear * 2);

            // OUTLET — rounded-rect hole through floor
            rotate([0, 0, outlet_angle_deg])
                translate([hole_mid_r, 0, -1])
                    rounded_rect(hole_len, hole_w, hole_corner_r,
                                 end_wall + 2);
        }

        // 4 robust MERLONS (added after the cavity cut)
        for (i = [0 : n_lock - 1])
            rotate([0, 0, lock_angle_off + 360 * i / n_lock])
                merlon();
    }
}

// One robust merlon, centred on +X. Raised block (radial hr_in-lock_thick
// .. hr_out) + a chamfered inward anchor that ramps the thickening down
// into the wall below the rim (self-supporting, no thin neck).
module merlon() {
    // raised block
    translate([hr_in - lock_thick, -lock_w/2, housing_h])
        cube([lock_thick + housing_wall, lock_w, lock_rise]);
    // chamfered inward anchor below the rim
    hull() {
        translate([hr_in - lock_thick, -lock_w/2, housing_h - 0.01])
            cube([lock_thick, lock_w, 0.01]);
        translate([hr_in - 0.01, -lock_w/2, housing_h - lock_anchor_h])
            cube([0.01, lock_w, 0.01]);
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
    // 2026-06-04 v4: 4 radial NOTCHES in the disc edge replace the v3
    // outward tabs. The housing's rim merlons poke up through them → no
    // protruding feature on either part; everything within the wall OD.
    // Notches are full-thickness edge gaps → print disc-down, no overhang.
    difference() {
        union() {
            // disc body
            cylinder(h = end_wall, d = 2 * hr_out);
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
        translate([0, 0, -1])
            cylinder(h = end_wall + 2,
                     d = axle_d + fit_clear * 2);

        // INLET — rounded-rect hole through cap, AND collar interior cavity
        // (same outline above the cap: cavity that accepts the hopper outer
        // bottom edge with collar_clear clearance)
        rotate([0, 0, inlet_angle_deg])
            translate([hole_mid_r, 0, -1]) {
                // through-hole (cap thickness): exactly the flow area
                rounded_rect(hole_len, hole_w, hole_corner_r,
                             end_wall + 2);
                // collar interior above cap top — wider, accepts hopper
                translate([0, 0, end_wall + 0.5])
                    rounded_rect(collar_inner_len, collar_inner_w,
                                 hole_corner_r + collar_clear,
                                 collar_h + 1);
            }

        // 4 anti-rotation NOTCHES — sized to the merlon footprint (radial
        // hr_in-lock_thick .. hr_out, tangential lock_w) + clearance. The
        // robust merlons poke up through these.
        for (i = [0 : n_lock - 1])
            rotate([0, 0, lock_angle_off + 360 * i / n_lock])
                translate([hr_in - lock_thick - lock_clear,
                           -(lock_w/2 + lock_clear), -1])
                    cube([(hr_out + 1) - (hr_in - lock_thick - lock_clear),
                          lock_w + 2 * lock_clear, end_wall + 2]);
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
