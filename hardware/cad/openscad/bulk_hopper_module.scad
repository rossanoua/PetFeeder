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

part = "assembly";   // funnel | spider | ring | lid | assembly

/* [Hopper outer geometry] */
bulk_d        = 160;    // outer diameter of every section (mm)
bulk_wall     = 3;      // wall thickness (mm)

/* [Funnel section] */
// 2026-05-29 v2: 110 → 115 mm. The +5 mm compensates for the new
// `cavity_taper_h = 5` at the top, which narrows the cavity from
// r=(bulk_d/2 - hopper_wall) to r=lip_ir to give the lip's first
// print layer solid support. With the chamfer eating 5 mm, the main
// mass-flow cone is z=10 to z=110 (100 mm) → wall ≈ 31° from vertical
// (well below the kibble mass-flow critical ~33°). Without this
// taper, the lip's first layer printed over empty space (slicer
// flagged it as "floating regions" — confirmed by user with PrusaSlicer/
// OrcaSlicer warning + the first-layer cross-section preview).
funnel_h        = 115;
cavity_taper_h  = 5;

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
// 2026-05-28: scaled to 35×35 (was 22×28) per Ø120 wheel upscale.
hole_radial_in   = 22;
hole_radial_out  = 57;   // length 35 mm
hole_w           = 35;   // tangential — 3× kibble for much less bridging
hole_corner_r    = 2;

/* [Cap collar — MUST match paddle_wheel_module.scad] */
// Bulk hopper outer bottom edge sits INSIDE the cap collar (slip-fit).
// Hopper outer footprint = hole size + 2 × hopper_wall.
// The collar inner outline = hopper outer + 2 × collar_clear.
hopper_wall     = 2;
collar_clear    = 0.5;
cap_collar_h    = 10;   // MUST match collar_h in paddle_wheel_module.scad
                        //   funnel has a straight rect plug at the bottom
                        //   that fits into this collar (taper starts ABOVE)

/* [Spider insert] (separate printable part — anti-bridge cone + ribs) */
// 2026-05-27: split out from the funnel so both parts print without
// supports. The spider drops INTO the funnel from above and settles by
// friction at the z where the cavity equals its outer envelope.
spider_clear    = 0.5;   // radial clearance between spider envelope and
                         //   the funnel cavity wall (slide-in fit)

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
        // Straight rect plug (fits into the cap collar)
        rounded_rect(hopper_outer_len, hopper_outer_w,
                     hole_corner_r + hopper_wall, cap_collar_h);
        // Tapered mass-flow cone — from rect plug to Ø bulk_d at
        // z=(funnel_h - cavity_taper_h). Above this z the outer stays
        // constant at Ø bulk_d (vertical cylinder).
        hull() {
            translate([0, 0, cap_collar_h])
                rounded_rect(hopper_outer_len, hopper_outer_w,
                             hole_corner_r + hopper_wall, 0.5);
            translate([0, 0, funnel_h - cavity_taper_h - 0.5])
                cylinder(d = bulk_d, h = 0.5);
        }
        // Straight Ø bulk_d cylinder over the cavity-taper region.
        // This section is the THICKER wall at the top (up to 6.3 mm)
        // that supports the lip — the outer is constant Ø bulk_d while
        // the cavity below tapers in to r=lip_ir.
        translate([0, 0, funnel_h - cavity_taper_h])
            cylinder(d = bulk_d, h = cavity_taper_h);
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
        // 1. Straight inner bottom (= cap hole shape), extends below z=0
        //    for clean cut-through
        translate([0, 0, -2])
            rounded_rect(hole_len, hole_w, hole_corner_r,
                         cap_collar_h + 2 + 0.5);
        // 2. Cone cavity — top reaches r=(bulk_d/2 - hopper_wall) at
        //    z=(funnel_h - cavity_taper_h) so the wall is uniformly
        //    hopper_wall (= 2 mm) everywhere in the main cone.
        hull() {
            translate([0, 0, cap_collar_h])
                rounded_rect(hole_len, hole_w, hole_corner_r, 0.5);
            translate([0, 0, funnel_h - cavity_taper_h - 0.5])
                cylinder(r = bulk_d/2 - hopper_wall, h = 0.5);
        }
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
    // ===== Hollowed funnel body only =====
    // 2026-05-27: anti-bridge cone + ribs split out into the separate
    // `spider` part so the funnel prints without supports (round opening
    // on the bed → walls slope inward → no overhangs).
    difference() {
        union() {
            funnel_outer();
            stacking_lip(z_funnel_top);
        }
        funnel_cavity();
    }
}

// Shrunk cavity (0.5 mm radial clearance) — used to clip the spider so it
// has slide-in clearance with the real funnel cavity. Envelope top
// matches the cone cavity hull top (= z=funnel_h - cavity_taper_h with
// r=(bulk_d/2 - hopper_wall - spider_clear)). The chamfer + lip region
// above the cone hull top isn't relevant for the spider, which sits at
// cone_z_base+(bridge_cone_h) = ~80 mm, below the chamfer (which starts
// at z=110 for funnel_h=115).
module spider_envelope() {
    hull() {
        translate([0, 0, -2])
            rounded_rect(hole_len - 2 * spider_clear,
                         hole_w - 2 * spider_clear,
                         max(hole_corner_r - spider_clear, 0.5), 0.5);
        translate([0, 0, funnel_h - cavity_taper_h - 0.5])
            cylinder(r = bulk_d/2 - hopper_wall - spider_clear, h = 0.5);
    }
}

// ===========================================================================
// SPIDER  separate insert — anti-bridge cone + 4 ribs, no outer ring.
// Ribs extend radially past the cavity walls; the intersection with
// `spider_envelope` clips the rib outer ends to match the funnel cavity
// shape (minus spider_clear). Spider drops into the funnel from above
// and settles at the z where the cavity equals its envelope.
//
// When rendered as `part = "spider"`, the spider is translated so its
// bottom sits at z = 0, ready for printing flat (wide cone base on bed).
// Prints without supports because all surfaces slope inward going up
// (cone narrows; rib outer ends follow the gentle cavity taper).
// ===========================================================================
module spider() {
    intersection() {
        // Envelope (clipped cavity) — limits the spider's outer extent
        spider_envelope();
        // Vertical z clip — restrict spider to its design height
        translate([0, 0, cone_z_base])
            cylinder(h = bridge_cone_h, r = bulk_d);
        // Cone + ribs structure (extending past cavity; clipped above)
        translate([0, 0, cone_z_base])
            union() {
                // Tip-up cone: wide base at z=cone_z_base, tip at top
                cylinder(h = bridge_cone_h,
                         r1 = bridge_cone_d / 2, r2 = 1);
                // 4 radial ribs (over-extended; clipped to envelope)
                for (i = [0 : n_ribs - 1])
                    rotate([0, 0, 360 * i / n_ribs + 45])
                        translate([0, -rib_thick / 2, 0])
                            cube([bulk_r_out + 5,
                                  rib_thick,
                                  bridge_cone_h]);
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
if (part == "spider")
    // Translate to z=0 for printing (bottom of spider on the bed)
    translate([0, 0, -cone_z_base]) spider();
if (part == "ring")     ring();
if (part == "lid")      lid();
if (part == "assembly") {
    color("LightBlue", 0.6)         funnel();
    // Spider sits at its functional z inside the funnel
    color("DimGray", 0.85)          spider();
    color("LightSteelBlue", 0.55)   translate([0, 0, z_funnel_top]) ring();
    color("Khaki", 0.7)             translate([0, 0, z_funnel_top + ring_h]) lid();
}

echo(str("bulk_d=", bulk_d, " funnel_h=", funnel_h,
         " hopper_outer=", hopper_outer_len, "x", hopper_outer_w,
         " ring_h=", ring_h,
         " total_h=", z_funnel_top + ring_h + joint_lip_h + 4 + lid_disc_h + lid_handle_h,
         " est_ring_L=", round(3.14159 * bulk_r_in * bulk_r_in * ring_h / 1000) / 1000));
