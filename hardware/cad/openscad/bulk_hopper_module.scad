// AiPetFeeder — Bulk hopper module (fully printable)
// ---------------------------------------------------------------------------
// REWRITE 2026-05-25 per ADR `2026-05-25-collar-mount-hopper-redesign`:
//
// Mass-flow funnel (active anti-bridge = a vibromotor, mount TBD once the
// motor is known) + modular stackable storage rings + lid. On the cap COLLAR
// (no longer plugs into a socket — no more spout walls narrowing the kibble
// pipe). Bulk hopper bottom outline matches the cap collar inner outline;
// hopper inner bottom opening = cap inlet hole exactly.
//
// Funnel cross-section: HULL from rectangular bottom (= cap hole + walls)
// to round top (= ring inner Ø). No "spout cube" anymore. Rect→round
// transition is integral to the mass-flow cone.
//
// First-iteration target unchanged: funnel + 1 ring + lid ≈ 4.2 L ≈ 1.7 kg.
//
// Parts:
//   part = "funnel"   -> rect-bottom mass-flow funnel + top stacking lip
//                        (vibromotor mount TBD — re-added with the motor)
//   part = "ring"     -> storage ring (stackable; print N copies)
//   part = "lid"      -> top cover with finger handle
//   part = "assembly" -> all stacked for visual fit check
// ===========================================================================

part = "assembly";   // funnel | ring | lid | assembly

/* [Hopper outer geometry] */
bulk_d        = 160;    // outer diameter of every section (mm)
bulk_wall     = 3;      // wall thickness (mm)

/* [Funnel section] */
// 2026-06-05c: user wants to TRY the more-open (shallower) cone — it
// reaches Ø160 early (at cone_top_z) and runs as a straight Ø160 cylinder
// above, giving ~36° from vertical. Wider approach to the bigger 26×34
// throat. (Trade-off vs the steeper ~31° version: more overhang on the
// print, but a more open funnel.)
funnel_h        = 115;
cone_top_z      = 98;   // cone reaches Ø160 at z≈98, straight Ø160 above
cavity_taper_h  = 5;    // top chamfer that supports the lip's first layer

// [Vibromotor mount] removed 2026-06-05 — will be re-added as its own
// feature once the specific motor's dimensions are known. The active
// anti-bridge is still a vibromotor; only the mounting geometry is TBD.

/* [Storage ring] */
ring_h          = 170;  // height per ring; stack as needed

/* [Lid] */
lid_disc_h      = 4;
lid_handle      = true;
lid_handle_d    = 30;
lid_handle_h    = 4;

/* [Stacking joint] */
joint_lip_h     = 10;
join_clear      = 0.3;

/* [Cap hole — MUST match paddle_wheel_module.scad] */
// Bulk hopper bottom opens directly to this rectangular hole. No spout
// in between (the old spout cube is gone in this revision).
// 2026-06-05b: throat extended inward toward the axle (in 14→7) to feed
// the wheel's stirrer cone. Now 33×34. MUST match paddle_wheel_module.scad.
hole_radial_in   = 7;
hole_radial_out  = 40;   // length 33 mm (out = wheel rim)
hole_w           = 34;   // tangential
hole_corner_r    = 2;

/* [Cap collar — MUST match paddle_wheel_module.scad] */
// Bulk hopper outer bottom edge sits INSIDE the cap collar (slip-fit).
// Hopper outer footprint = hole size + 2 × hopper_wall.
// The collar inner outline = hopper outer + 2 × collar_clear.
hopper_wall     = 2;
collar_clear    = 0.5;
cap_collar_h    = 10;   // MUST match collar_h in paddle_wheel_module.scad
                        //   funnel has a straight plug at the bottom that
                        //   fits into this collar (taper starts ABOVE)

/* [Teardrop throat — MUST match paddle_wheel_module.scad cap inlet] */
// 2026-06-06: the funnel throat is now the SAME teardrop as the cap inlet
// (big opening on the inlet side, reaching the axle). The Ø160 top is
// centred over the throat (the throat is shifted +throat_cx so it sits at
// the funnel origin); the funnel is then placed at chassis (-throat_cx).
pw_hr_in        = 40.8;  // = wheel_r 40 + housing_clear 0.8
pw_housing_wall = 3;
pw_td_tip_r     = 18;
pw_td_back      = 22;
pw_inlet_margin = 3;
pw_axle_keep    = 4.8;   // = axle_d/2 + fit_clear + 2
throat_cx       = 28;    // throat centre offset → Ø160 sits over the throat

/* [Quality] */
$fn = 96;

// --- derived ----------------------------------------------------------------
bulk_r_out     = bulk_d / 2;
bulk_r_in      = bulk_r_out - bulk_wall;

// Rectangular hopper bottom dimensions (radial × tangential)
hole_len       = hole_radial_out - hole_radial_in;
hopper_outer_w = hole_w   + 2 * hopper_wall;   // tangential, fits in collar
hopper_outer_len = hole_len + 2 * hopper_wall; // radial

// Stacking lip on top
lip_or         = bulk_r_in - join_clear;
lip_ir         = lip_or - bulk_wall;

// Teardrop throat derived
pw_hr_out      = pw_hr_in + pw_housing_wall;
pw_td_tip_cx   = pw_hr_out + pw_td_back - pw_td_tip_r;

// Z markers
z_funnel_top   = funnel_h;                 // = top of funnel cone
z_lip_top      = z_funnel_top + joint_lip_h;

// --- helpers ----------------------------------------------------------------
// Teardrop outline (2D) + the cap-inlet THROAT, shifted so its centre sits
// at the funnel origin (the Ø160 top is built there). MUST stay in sync
// with paddle_wheel_module.scad's teardrop_2d / inlet_2d.
module teardrop_2d(R, tip_r, tip_cx) {
    hull() {
        circle(r = R, $fn = 96);
        translate([-tip_cx, 0]) circle(r = tip_r, $fn = 48);
    }
}
module throat_2d() {
    translate([throat_cx, 0])
        intersection() {
            offset(-pw_inlet_margin)
                teardrop_2d(pw_hr_in, pw_td_tip_r - pw_housing_wall, pw_td_tip_cx);
            translate([-pw_axle_keep - 200, -100]) square([200, 200]);
        }
}

module rounded_rect(x, y, r, h) {
    hull() {
        for (dx = [-1, 1])
            for (dy = [-1, 1])
                translate([dx * (x/2 - r), dy * (y/2 - r), 0])
                    cylinder(r = r, h = h);
    }
}

module stacking_lip(z_base) {
    translate([0, 0, z_base])
        difference() {
            cylinder(h = joint_lip_h, r = lip_or);
            translate([0, 0, -1])
                cylinder(h = joint_lip_h + 2, r = lip_ir);
        }
}

// ===========================================================================
// FUNNEL  rect bottom → round top, with integrated anti-bridge cone
// ---------------------------------------------------------------------------
// 2026-05-26 rev:
//   • Anti-bridge cone is now TIP-UP (wide base at bottom, point at top).
//     All exposed surfaces are sloped — kibble cannot rest on a flat top.
//   • Radial ribs are CLIPPED to the funnel outer surface via intersection,
//     so they no longer protrude past the funnel exterior.
// ===========================================================================

// Outer funnel shape — straight rect plug at the bottom, mass-flow cone
// in the middle, and a straight Ø bulk_d cylinder over the top
// cavity_taper_h. The straight outer at the top + tapered cavity at the
// top combine to give a thick (6.3 mm) annular wall right at z=funnel_h
// — that solid wall is what supports the lip's first print layer.
module funnel_outer() {
    union() {
        // Teardrop plug (throat + wall) — fits into the cap collar
        linear_extrude(cap_collar_h) offset(hopper_wall) throat_2d();
        // Mass-flow cone — from the teardrop plug to Ø bulk_d at cone_top_z
        // (Ø160 centred at the origin, over the throat).
        hull() {
            translate([0, 0, cap_collar_h])
                linear_extrude(0.5) offset(hopper_wall) throat_2d();
            translate([0, 0, cone_top_z - 0.5])
                cylinder(d = bulk_d, h = 0.5);
        }
        // Straight Ø bulk_d cylinder from cone_top_z to the top.
        translate([0, 0, cone_top_z])
            cylinder(d = bulk_d, h = funnel_h - cone_top_z);
    }
}

// Inner cavity shape — three sections:
//   1. straight rect bottom (= cap hole shape, through the plug)
//   2. tapered mass-flow cone (rect → circle r=(bulk_d/2 - hopper_wall)
//      = 78), uniform 2 mm wall against the cone outer
//   3. taper-down chamfer at the top — cavity narrows from r=78 to
//      r=lip_ir (=73.7) over cavity_taper_h (5 mm). This LOCAL inward
//      taper means that at z=funnel_h the cavity edge has moved to
//      r=lip_ir, so the lip wall (r=lip_ir to r=lip_or) sits ENTIRELY
//      ON solid material below. Without this taper, the lip's outer
//      (r=lip_or=76.7) prints over the empty cavity → slicer "floating
//      regions" warning, lip's first layer fails.
//   4. lip cavity above z=funnel_h — straight cylinder r=lip_ir
//
// Cone wall thickness:
//   • z=10  (plug top):                 2 mm
//   • z=funnel_h-cavity_taper_h (=110): 2 mm (last layer with uniform wall)
//   • z=funnel_h (=115):                6.3 mm (max wall, supports lip)
//   • z=funnel_h+ε (lip):               3 mm (lip wall)
// Thickening is LOCAL to the taper region (5 mm) at the very top —
// exactly what the user asked for ("уніформ якомога більше, потовщення
// під кінець").
module funnel_cavity() {
    union() {
        // 1. Teardrop throat (= cap inlet), extends below z=0 for a clean
        //    cut-through.
        translate([0, 0, -2])
            linear_extrude(cap_collar_h + 2 + 0.5) throat_2d();
        // 2. Cone cavity — throat → r=(bulk_d/2 - hopper_wall) at cone_top_z.
        hull() {
            translate([0, 0, cap_collar_h])
                linear_extrude(0.5) throat_2d();
            translate([0, 0, cone_top_z - 0.5])
                cylinder(r = bulk_d/2 - hopper_wall, h = 0.5);
        }
        // 2b. Straight cavity cylinder r=78 from cone_top_z up to the
        //     chamfer start (keeps the 2 mm wall in the straight section).
        translate([0, 0, cone_top_z])
            cylinder(r = bulk_d/2 - hopper_wall,
                     h = (funnel_h - cavity_taper_h) - cone_top_z + 0.01);
        // 3. Top chamfer — cavity narrows from r=78 to r=lip_ir over
        //    cavity_taper_h. Slope ≈ 41° from vertical = 49° from
        //    horizontal — within FDM's self-supporting overhang range
        //    (>45° from horizontal).
        translate([0, 0, funnel_h - cavity_taper_h])
            cylinder(r1 = bulk_d/2 - hopper_wall, r2 = lip_ir,
                     h = cavity_taper_h);
        // 4. Lip cavity — straight cylinder r=lip_ir through the lip
        //    region. Starts 0.5 mm BELOW funnel_h to overlap with the
        //    chamfer's top end and avoid Z-fighting.
        translate([0, 0, funnel_h - 0.5])
            cylinder(r = lip_ir, h = joint_lip_h + 2.5);
    }
}

module funnel() {
    // ===== Hollowed funnel body =====
    // No anti-bridge insert (the spider caused the very bridging it was
    // meant to break). Active anti-bridge will be a vibromotor on an
    // external mount — to be re-added once the motor's dims are known.
    // The funnel prints without supports (round opening on the bed →
    // walls slope inward → no overhangs).
    difference() {
        union() {
            funnel_outer();
            stacking_lip(z_funnel_top);
        }
        funnel_cavity();
    }
}

// ===========================================================================
// STORAGE RING  modular section, stacks via top lip
// ===========================================================================
module ring() {
    difference() {
        union() {
            cylinder(h = ring_h, d = bulk_d);
            stacking_lip(ring_h);
        }
        translate([0, 0, -1])
            cylinder(h = ring_h + joint_lip_h + 2, r = bulk_r_in);
    }
}

// ===========================================================================
// LID  top cover, finger handle
// ===========================================================================
module lid() {
    skirt_h    = joint_lip_h + 4;
    skirt_id   = 2 * bulk_r_in + 2 * join_clear;
    skirt_od   = bulk_d;

    union() {
        difference() {
            union() {
                translate([0, 0, skirt_h])
                    cylinder(h = lid_disc_h, d = bulk_d);
                cylinder(h = skirt_h, d = skirt_od);
            }
            translate([0, 0, -1])
                cylinder(h = skirt_h + 1, d = skirt_id);
        }
        if (lid_handle)
            translate([0, 0, skirt_h + lid_disc_h])
                cylinder(h = lid_handle_h, d = lid_handle_d);
    }
}

// ===========================================================================
// RENDER
// ===========================================================================
if (part == "funnel")   funnel();
if (part == "ring")     ring();
if (part == "lid")      lid();
if (part == "assembly") {
    color("LightBlue", 0.6)         funnel();
    color("LightSteelBlue", 0.55)   translate([0, 0, z_funnel_top]) ring();
    color("Khaki", 0.7)             translate([0, 0, z_funnel_top + ring_h]) lid();
}

echo(str("bulk_d=", bulk_d, " funnel_h=", funnel_h,
         " hopper_outer=", hopper_outer_len, "x", hopper_outer_w,
         " ring_h=", ring_h,
         " total_h=", z_funnel_top + ring_h + joint_lip_h + 4 + lid_disc_h + lid_handle_h,
         " est_ring_L=", round(3.14159 * bulk_r_in * bulk_r_in * ring_h / 1000) / 1000));
