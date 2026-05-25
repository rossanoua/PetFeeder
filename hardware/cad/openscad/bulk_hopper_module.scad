// AiPetFeeder — Bulk hopper module (fully printable)
// ---------------------------------------------------------------------------
// REWRITE 2026-05-25 per ADR `2026-05-25-collar-mount-hopper-redesign`:
//
// Mass-flow funnel with integrated anti-bridge cone + modular stackable
// storage rings + lid. Sits on top of the rotary-disc cap via the COLLAR
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
//   part = "funnel"   -> rect-bottom mass-flow funnel + anti-bridge cone
//                        + top stacking lip
//   part = "ring"     -> storage ring (stackable; print N copies)
//   part = "lid"      -> top cover with finger handle
//   part = "assembly" -> all stacked for visual fit check
// ===========================================================================

part = "assembly";   // funnel | ring | lid | assembly

/* [Hopper outer geometry] */
bulk_d        = 160;    // outer diameter of every section (mm)
bulk_wall     = 3;      // wall thickness (mm)

/* [Funnel section] */
funnel_h        = 140;  // total funnel height (was derived; now fixed so we
                        //   keep the same overall envelope as v1)

/* [Anti-bridge cone] */
bridge_cone_d   = 40;   // cone top diameter; tip down
bridge_cone_h   = 35;
bridge_cone_pos = 0.55; // vertical center as fraction of funnel_h
n_ribs          = 4;
rib_thick       = 3;

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
hole_radial_in   = 18;
hole_radial_out  = 40;
hole_w           = 28;
hole_corner_r    = 2;

/* [Cap collar — MUST match paddle_wheel_module.scad] */
// Bulk hopper outer bottom edge sits INSIDE the cap collar (slip-fit).
// Hopper outer footprint = hole size + 2 × hopper_wall.
// The collar inner outline = hopper outer + 2 × collar_clear.
hopper_wall     = 2;
collar_clear    = 0.5;

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

// Z markers
z_funnel_top   = funnel_h;                 // = top of funnel cone
z_lip_top      = z_funnel_top + joint_lip_h;

// Anti-bridge cone position
cone_z_base    = funnel_h * bridge_cone_pos - bridge_cone_h / 2;

// --- helpers ----------------------------------------------------------------
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
// ===========================================================================
module funnel() {
    rib_outer_r = bulk_r_in - 2;  // ribs reach into the wall material

    union() {
        // ===== Hollowed funnel body =====
        difference() {
            union() {
                // Outer: hull from rect bottom (outer) to round top
                hull() {
                    translate([0, 0, 0])
                        rounded_rect(hopper_outer_len, hopper_outer_w,
                                     hole_corner_r + hopper_wall, 0.5);
                    translate([0, 0, funnel_h - 0.5])
                        cylinder(d = bulk_d, h = 0.5);
                }
                // Top stacking lip
                stacking_lip(z_funnel_top);
            }
            // Inner cavity: hull from rect bottom (= hole) to round inner
            // (= bulk_r_in). Extends past funnel top and bottom to fully
            // open both ends.
            hull() {
                translate([0, 0, -2])
                    rounded_rect(hole_len, hole_w, hole_corner_r, 0.5);
                translate([0, 0, funnel_h + joint_lip_h + 2])
                    cylinder(r = bulk_r_in, h = 0.5);
            }
        }

        // ===== Anti-bridge cone + radial ribs =====
        // Sits inside the cavity; ribs span from cone center out into the
        // wall material (cavity_r < r < bulk_r_out) where they fuse with
        // the wall. The cone+ribs are added OUTSIDE the difference so the
        // cavity carving doesn't subtract them.
        translate([0, 0, cone_z_base])
            union() {
                // Inverted cone (tip down)
                cylinder(h = bridge_cone_h,
                         r1 = 1, r2 = bridge_cone_d / 2);
                // Radial ribs
                for (i = [0 : n_ribs - 1])
                    rotate([0, 0, 360 * i / n_ribs + 45])
                        translate([0, -rib_thick / 2, 0])
                            cube([rib_outer_r, rib_thick, bridge_cone_h]);
            }
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
