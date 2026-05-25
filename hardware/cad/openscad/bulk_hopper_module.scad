// AiPetFeeder — Bulk hopper module (fully printable)
// ---------------------------------------------------------------------------
// Mass-flow funnel with integrated anti-bridge cone + modular stackable
// storage rings + lid. Sits on top of the paddle-wheel housing via the
// existing cap boss-socket — the spout dimensions MUST match those in
// `paddle_wheel_module.scad` (kept in sync manually; see [Spout] block).
//
// First iteration target: funnel + 1 ring + lid ≈ 4.2 L ≈ 1.7 kg capacity.
// Print extra rings to extend storage (modular). All sections fit in the
// AONE2 build volume (190 × 190 × 190 mm).
//
// Parts:
//   part = "funnel"   -> bottom: mass-flow funnel with anti-bridge cone +
//                        rectangular spout that plugs into the paddle-
//                        wheel housing cap socket
//   part = "ring"     -> storage ring section (stackable; print N copies)
//   part = "lid"      -> top cap with finger handle
//   part = "assembly" -> all stacked together for visual fit check
//
// Stacking joint: every section has a 3 mm thick × joint_lip_h tall LIP
// extending upward from the top edge (lip OD < body ID by 2×join_clear).
// Each section's body INTERIOR accepts the lip of the section below.
// Lid has an external skirt that wraps the topmost lip.
//
// Anti-bridge concept (per the coffee-grinder photo, 2026-05-25):
// the funnel narrows toward the spout; a central cone suspended on 4
// radial ribs splits the kibble column into 4 narrow streams that flow
// around the cone — they cannot arch across the wide funnel diameter.
// ===========================================================================

part = "assembly";   // funnel | ring | lid | assembly

/* [Hopper outer geometry] */
bulk_d        = 160;    // outer diameter of every section (mm)
bulk_wall     = 3;      // wall thickness (mm)

/* [Funnel section] */
funnel_wall_deg = 65;   // wall angle from horizontal (mass-flow geometry).
                        //   65° > internal friction of kibble (~33°).
spout_h_outer = 12;     // length of spout sticking out below the funnel
h_transition  = 18;     // height of the rectangle-to-circle hull section

/* [Anti-bridge cone] */
bridge_cone_d   = 40;   // cone top (wide) diameter; tip points down
bridge_cone_h   = 35;   // cone height
bridge_cone_pos = 0.55; // vertical center relative to funnel cone height
                        //   (0.55 = a bit above the middle, where the
                        //    arch would otherwise form)
n_ribs         = 4;     // radial ribs supporting the cone
rib_thick      = 3;     // rib thickness (mm)

/* [Storage ring] */
ring_h        = 170;    // height of one storage ring (mm) — leaves room
                        //   for joint_lip_h on top within the 190 Z bed

/* [Lid] */
lid_disc_h    = 4;      // top disc thickness
lid_handle    = true;   // small finger-pad on top for lifting
lid_handle_d  = 30;
lid_handle_h  = 4;

/* [Stacking joint] */
joint_lip_h   = 10;     // lip height (= insertion depth)
join_clear    = 0.3;    // radial slip-fit clearance per side

/* [Spout — MUST match paddle_wheel_module.scad cap socket] */
// Keep these synced with paddle_wheel_module.scad if you change them
// there. The spout cross-section here is recomputed identically.
hole_radial_in   = 18;
hole_radial_out  = 38;
hole_w           = 22;
boss_flare       = 2;
hopper_join_clear = 0.35;   // distinct from stacking join_clear above

/* [Quality] */
$fn = 96;

// --- derived ----------------------------------------------------------------
bulk_r_out      = bulk_d / 2;
bulk_r_in       = bulk_r_out - bulk_wall;

// Spout dimensions (from paddle_wheel_module.scad spout calculation)
hole_len        = hole_radial_out - hole_radial_in;
socket_x        = hole_len + 2 * boss_flare;
socket_y        = hole_w   + 2 * boss_flare;
spout_x         = socket_x - hopper_join_clear;
spout_y         = socket_y - hopper_join_clear;

// Stacking lip dimensions
lip_or          = bulk_r_in - join_clear;     // lip outer radius
lip_ir          = lip_or - bulk_wall;         // lip inner radius

// Funnel internal dimensions
funnel_r_bot    = max(sqrt(spout_x*spout_x + spout_y*spout_y) / 2 + 2,
                      bulk_r_in * 0.18);      // narrow end (just above the
                                              //   round/rect transition)
                                              //   ≈ enough to clear the
                                              //   rectangular spout corners
funnel_r_top    = bulk_r_in;
funnel_h        = (funnel_r_top - funnel_r_bot) / tan(90 - funnel_wall_deg);

// Z markers (funnel section frame)
z_spout_top     = 0;
z_trans_top     = spout_h_outer + h_transition;   // = end of rect→round hull
z_cone_top      = z_trans_top + funnel_h;         // = top of funnel cone
z_lip_top       = z_cone_top + joint_lip_h;       // = top of funnel section

// Anti-bridge cone position (within the funnel)
cone_z_base     = z_trans_top + funnel_h * bridge_cone_pos
                              - bridge_cone_h / 2;

// Stacking lip on top of funnel / on top of each ring
module stacking_lip(z_base) {
    translate([0, 0, z_base])
        difference() {
            cylinder(h = joint_lip_h, r = lip_or);
            translate([0, 0, -1])
                cylinder(h = joint_lip_h + 2, r = lip_ir);
        }
}

// ===========================================================================
// FUNNEL  bottom section, with rectangular spout below, hull transition,
//          mass-flow round frustum cone, anti-bridge cone, top stacking lip
// ===========================================================================
module funnel() {
    // Rib outer radius: reaches into the funnel wall material at all z
    // within the cone height, but never past bulk_r_out (no external
    // protrusion). bulk_r_in - 2 = ~75 mm = well past the cavity radius
    // at cone top (~45 mm) AND well inside the outer wall (80 mm).
    rib_outer_r = bulk_r_in - 2;

    union() {
        // ===== HOLLOWED FUNNEL BODY =====
        difference() {
            union() {
                // Outer body: full-height cylinder
                cylinder(h = z_cone_top, d = bulk_d);
                // Rectangular spout below (z < 0)
                translate([-spout_x/2, -spout_y/2, -spout_h_outer])
                    cube([spout_x, spout_y, spout_h_outer + 1]);
                // Top stacking lip
                stacking_lip(z_cone_top);
            }
            // Mass-flow round frustum (cavity)
            translate([0, 0, z_trans_top])
                cylinder(h = funnel_h + joint_lip_h + 1,
                         r1 = funnel_r_bot, r2 = bulk_r_in);
            // Hull transition: rect spout → round funnel bottom
            hull() {
                translate([-spout_x/2, -spout_y/2, spout_h_outer])
                    cube([spout_x, spout_y, 0.01]);
                translate([0, 0, z_trans_top - 0.01])
                    cylinder(h = 0.01, r = funnel_r_bot);
            }
            // Rectangular spout hole through the bottom
            translate([-spout_x/2, -spout_y/2, -spout_h_outer - 1])
                cube([spout_x, spout_y, spout_h_outer + 2]);
        }

        // ===== ANTI-BRIDGE CONE + RIBS  (added OUTSIDE the difference) =====
        // Cone is hollow-cavity-resident — survives the cavity carving
        // because it's added AFTER (top-level union). Ribs reach into the
        // wall material (cavity_r < r < bulk_r_out) where they fuse
        // structurally with the wall.
        translate([0, 0, cone_z_base])
            union() {
                // Inverted cone: tip points -Z, wide top
                cylinder(h = bridge_cone_h,
                         r1 = 1, r2 = bridge_cone_d / 2);
                // 4 radial ribs supporting the cone
                for (i = [0 : n_ribs - 1])
                    rotate([0, 0, 360 * i / n_ribs + 45])
                        translate([0, -rib_thick / 2, 0])
                            cube([rib_outer_r, rib_thick, bridge_cone_h]);
            }
    }
}

// ===========================================================================
// STORAGE RING  modular cylinder section; same outer profile + top lip;
//                interior accepts the lip of the section below
// ===========================================================================
module ring() {
    difference() {
        union() {
            // Body: cylinder of ring_h, hollow with bulk_wall walls
            cylinder(h = ring_h, d = bulk_d);
            // Top stacking lip
            stacking_lip(ring_h);
        }
        // Hollow interior
        translate([0, 0, -1])
            cylinder(h = ring_h + joint_lip_h + 2, r = bulk_r_in);
    }
}

// ===========================================================================
// LID  top cover with a downward skirt that wraps over the topmost lip
// ===========================================================================
module lid() {
    skirt_h         = joint_lip_h + 4;
    skirt_id        = 2 * bulk_r_in + 2 * join_clear;  // wraps around lip
    skirt_od        = bulk_d;

    union() {
        difference() {
            // Disc + skirt
            union() {
                // Disc on top
                translate([0, 0, skirt_h])
                    cylinder(h = lid_disc_h, d = bulk_d);
                // Downward skirt around the lip
                cylinder(h = skirt_h, d = skirt_od);
            }
            // Hollow inside of skirt (so the lip + ring interior fit in)
            translate([0, 0, -1])
                cylinder(h = skirt_h + 1, d = skirt_id);
        }
        // Finger handle on top
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
    color("LightBlue", 0.6)            funnel();
    color("LightSteelBlue", 0.55)      translate([0, 0, z_cone_top]) ring();
    color("Khaki", 0.7)                translate([0, 0, z_cone_top + ring_h]) lid();
}

echo(str("bulk_d=", bulk_d, " funnel_h=", funnel_h,
         " z_cone_top=", z_cone_top,
         " ring_h=", ring_h, " total_h=", z_cone_top + ring_h + joint_lip_h + 4 + lid_disc_h + lid_handle_h,
         " est_funnel_L=", round((1.0/3.0)*3.14159*(bulk_r_in*bulk_r_in + bulk_r_in*funnel_r_bot + funnel_r_bot*funnel_r_bot)*funnel_h/1000)/1000,
         " est_ring_L=", round(3.14159*bulk_r_in*bulk_r_in*ring_h/1000)/1000));
