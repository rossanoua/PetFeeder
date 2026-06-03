// AiPetFeeder — Bulk hopper module (fully printable)
// ---------------------------------------------------------------------------
// REWRITE 2026-05-25 per ADR `2026-05-25-collar-mount-hopper-redesign`:
//
// Mass-flow funnel (active anti-bridge = external vibromotor pad near the
// throat) + modular stackable storage rings + lid. Sits on the cap COLLAR
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
//   part = "funnel"   -> rect-bottom mass-flow funnel + vibromotor pad
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

/* [Vibromotor mount] (active anti-bridge — replaces the old spider/cone) */
// 2026-06-03: the passive anti-bridge spider was the bridge SOURCE and is
// gone. A small vibration motor on the cone near the throat breaks arches
// actively. This is a flat external mounting pad placeholder — finalize
// the cradle/holes once the motor (coin ERM Ø/thickness, or cylindrical)
// is known. Pad face is flat & vertical for an adhesive/screw mount.
vibro_angle    = 90;    // which side of the cone (deg)
vibro_z        = 13;    // pad bottom height (just above the cap collar)
vibro_h        = 22;    // pad height
vibro_w        = 18;    // pad width (tangential)
vibro_face_r   = 42;    // radius of the flat outer mounting face
vibro_foot_r   = 22;    // ramp foot radius (≈ cone OD at vibro_z; self-support)
vibro_screw_d  = 2.2;   // pilot holes (M2 self-tap)
vibro_screw_dx = 11;    // pilot hole spacing (tangential)
vibro_screw_dz = 0;     // pilot holes at pad mid-height (0 = centered)

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
// 2026-06-03: scaled BACK to 22×28 (Ø80 wheel). Cone is a bit steeper
// now (smaller bottom, same Ø160 top) — acceptable because the vibromotor
// is the active anti-bridge. MUST match paddle_wheel_module.scad.
hole_radial_in   = 18;
hole_radial_out  = 40;   // length 22 mm
hole_w           = 28;   // tangential
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
    // ===== Hollowed funnel body + external vibromotor pad =====
    // 2026-06-03: no anti-bridge insert any more (the spider caused the
    // very bridging it was meant to break). Active anti-bridge = a small
    // vibration motor on the external pad near the throat. The funnel
    // still prints without supports (round opening on the bed → walls
    // slope inward; the vibro pad has a self-supporting chamfered foot).
    difference() {
        union() {
            funnel_outer();
            stacking_lip(z_funnel_top);
            vibro_pad();
        }
        funnel_cavity();   // also hollows the pad's inner side → leaves a boss
        vibro_holes();     // pilot holes drilled into the flat pad face
    }
}

// ===========================================================================
// VIBROMOTOR PAD  external flat mount on the cone near the throat.
// Built as a radial slab from inside the cone wall out to vibro_face_r,
// with a self-supporting chamfered underside (foot at vibro_foot_r ≈ the
// cone OD at vibro_z, so the bottom doesn't overhang). funnel_cavity()
// carves the inner side, leaving a solid wall-thickening + external pad.
// Placeholder geometry — finalize cradle once the motor is known.
// ===========================================================================
module vibro_pad() {
    rotate([0, 0, vibro_angle])
        hull() {
            // flat outer slab (raised by the chamfer)
            translate([0, -vibro_w/2, vibro_z + (vibro_face_r - vibro_foot_r)])
                cube([vibro_face_r, vibro_w,
                      vibro_h - (vibro_face_r - vibro_foot_r)]);
            // ramp foot — narrower, at the pad bottom (self-supporting ~45°)
            translate([0, -vibro_w/2, vibro_z])
                cube([vibro_foot_r, vibro_w, 0.1]);
        }
}

module vibro_holes() {
    rotate([0, 0, vibro_angle])
        for (s = [-1, 1])
            translate([vibro_face_r + 1,
                       s * vibro_screw_dx / 2,
                       vibro_z + vibro_h/2 + vibro_screw_dz])
                rotate([0, -90, 0])
                    cylinder(d = vibro_screw_d, h = 7);
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
