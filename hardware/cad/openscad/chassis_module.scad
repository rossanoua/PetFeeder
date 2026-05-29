// AiPetFeeder — Lower body chassis (C-shape, with internal chute)
// ---------------------------------------------------------------------------
// First iteration of the integrated feeder body. C-shape architecture:
//   • Top:     circular recess that seats the rotary-disc housing
//   • Inside:  internal slanted CHUTE that catches kibble from the
//              housing floor outlet (+X side) and routes it to a front
//              exit window above the bowl
//   • Front:   BOWL NICHE — a 130 × 160 × 80 mm pocket the bowl slides into
//   • Back/floor: ELECTRONICS BAY — large hollow region for motor + ESP32 +
//              driver + HX711 + DC jack (cutouts in panels in next iter)
//
// Coordinate convention:
//   +X = FRONT (toward bowl), -X = BACK (electronics access panel)
//   +Y / -Y = left / right (symmetric)
//   +Z = UP
//   Chassis bottom face at z = 0
//
// CRITICAL: this design assumes the rotary-disc housing is configured with
// outlet_angle_deg = 0 (outlet faces +X = front) and inlet_angle_deg = 180
// (hopper above sits offset to the back). The paddle_wheel_module.scad was
// updated in the same commit.
//
// Parts:
//   part = "chassis"  -> the body alone
//   part = "assembly" -> chassis + rotary housing + cap + wheel + funnel
//                        + storage ring + lid, all stacked
// ===========================================================================

use <paddle_wheel_module.scad>
use <bulk_hopper_module.scad>

part = "chassis";   // chassis | assembly

/* [Chassis envelope] */
// 2026-05-28: depth grew 220→240 because the bulk hopper top (Ø160)
// centered at x=-39.5 would otherwise overhang the back by ~10 mm.
chassis_d   = 240;   // depth (X dimension, front-to-back)
chassis_w   = 200;   // width (Y dimension, side-to-side)
chassis_h   = 160;   // height (Z dimension)

/* [Bowl niche] (carved from FRONT face) */
bowl_niche_d = 130;  // depth into chassis (along X from front face)
bowl_niche_w = 160;  // width (Y)
bowl_niche_h = 80;   // height (Z, from bottom of chassis)

/* [Rotary-disc housing seat] (carved into TOP face, centered) */
// Recess that locates the housing — housing OD slips into it.
// 2026-05-28: scaled up to Ø127.6 with wheel_d=120 (was Ø87.6 with wheel_d=80).
housing_outer_d  = 127.6; // = 2 × hr_out in paddle_wheel_module.scad
housing_height   = 30.5;  // = housing_h in paddle_wheel_module.scad
                          //   (wheel_thickness 10 + housing_buffer_h 15
                          //    + 0.5+0.5+3+1.5 clearances and walls)
recess_clear     = 0.5;
recess_depth     = 4;

/* [Internal chute] (catches kibble from housing outlet -> front exit) */
// The housing outlet is at (+X-relative-to-housing-center, y=0) at radial
// distance hole_mid_r ≈ 39.5 mm. Inlet of the chute is directly below.
// 2026-05-28: chute inlet enlarged for the new 35×35 rounded-rect hole.
chute_inlet_w_x  = 40;    // radial extent (= hole_len 35 + 5 catch margin)
chute_inlet_w_y  = 40;    // tangential extent (= hole_w 35 + 5 catch margin)
chute_outlet_w_y = 55;    // chute mouth width at the front exit
chute_outlet_w_z = 45;    // chute mouth height at the front exit (kibble
                          //   stream got wider with the bigger outlet)
chute_outlet_top_above_bowl = 12;  // gap above bowl niche top for the chute mouth

/* [Electronics bay opening] (carved from BACK face) — outline only this iter */
el_bay_d = 60;       // depth into chassis from back face (X)
el_bay_w = 170;      // width (Y)
el_bay_h = 80;       // height (Z, from chassis bottom up to the chute level)

/* [Quality] */
$fn = 64;

// --- derived ----------------------------------------------------------------
// Housing outlet position in chassis frame (housing center = chassis (0,0,top))
housing_outlet_x = 39.5; // ≈ hole_mid_r = (hole_radial_in+hole_radial_out)/2 = (22+57)/2
housing_outlet_z = chassis_h;  // kibble enters chassis from above at top

// Chute outlet position (front face)
chute_outlet_z_center = bowl_niche_h + chute_outlet_top_above_bowl
                       + chute_outlet_w_z / 2;

// ===========================================================================
// CHASSIS
// ===========================================================================
module chassis() {
    difference() {
        // Outer body — solid rectangular block (sharp edges; chamfers later)
        translate([-chassis_d / 2, -chassis_w / 2, 0])
            cube([chassis_d, chassis_w, chassis_h]);

        // ---- Bowl niche (carved from +X / front face) ----
        translate([chassis_d / 2 - bowl_niche_d,
                   -bowl_niche_w / 2,
                   0])
            cube([bowl_niche_d + 1, bowl_niche_w, bowl_niche_h]);

        // ---- Top recess for rotary housing (centered) ----
        translate([0, 0, chassis_h - recess_depth])
            cylinder(h = recess_depth + 1,
                     d = housing_outer_d + 2 * recess_clear);

        // ---- Vertical hole through chassis top for housing axle/bottom ----
        // (Provides clearance for motor coupler going UP into housing axle stub)
        translate([0, 0, chassis_h - 30])
            cylinder(h = 30 + 1, d = 25);

        // ---- Internal chute (slanted tunnel: housing outlet → front mouth) ----
        // Hulled cavity between two thin slabs: top slab at housing outlet
        // position; bottom slab at front face above bowl niche.
        hull() {
            // Top inlet slab (at the housing outlet position)
            translate([housing_outlet_x - chute_inlet_w_x / 2,
                       -chute_inlet_w_y / 2,
                       chassis_h - recess_depth - 0.5])
                cube([chute_inlet_w_x, chute_inlet_w_y, 1]);
            // Front outlet slab (at chassis front face, above bowl niche)
            translate([chassis_d / 2 - 1,
                       -chute_outlet_w_y / 2,
                       chute_outlet_z_center - chute_outlet_w_z / 2])
                cube([3, chute_outlet_w_y, chute_outlet_w_z]);
        }

        // ---- Electronics bay (carved from -X / back face) ----
        translate([-chassis_d / 2 - 1,
                   -el_bay_w / 2,
                   chassis_h - 4 - el_bay_h])
            cube([el_bay_d + 1, el_bay_w, el_bay_h]);
    }
}

// ===========================================================================
// ASSEMBLY  full feeder visual: chassis + rotary + hopper stack
// ===========================================================================
module assembly() {
    // Chassis
    color("LightGray") chassis();

    // Rotary-disc housing on top of chassis (in the recess)
    z_housing_bottom = chassis_h - recess_depth;
    translate([0, 0, z_housing_bottom])
        color("LightBlue", 0.75) housing();

    // Wheel inside the housing
    // (paddle_wheel_module.scad's wheel sits at end_wall + floor_clear in housing-local frame)
    translate([0, 0, z_housing_bottom + 3.5])
        color("Silver") wheel();

    // Axle through the wheel (extends below to chassis + above through cap)
    translate([0, 0, z_housing_bottom - 22])
        color("DimGray") axle();

    // End cap on top of housing rim
    translate([0, 0, z_housing_bottom + housing_height])
        color("LightSteelBlue", 0.75) end_cap();

    // Bulk hopper: funnel sits ON the cap (collar-mount; no socket).
    // Funnel bottom is offset to (-hole_mid_r, 0) so its rect bottom
    // aligns with the cap inlet hole. The cap collar surrounds the
    // funnel outer bottom edge.
    z_cap_top = z_housing_bottom + housing_height + 3 /*end_wall*/;
    translate([-39.5, 0, z_cap_top])
        color("LightBlue", 0.5) funnel();

    // Storage ring on top of funnel (funnel_h = 115 mm in new design)
    z_funnel_top = z_cap_top + 115;
    translate([-39.5, 0, z_funnel_top])
        color("LightSteelBlue", 0.5) ring();

    // Lid on top of ring (ring_h = 170 mm)
    z_ring_top = z_funnel_top + 170;
    translate([-39.5, 0, z_ring_top])
        color("Khaki", 0.6) lid();
}

// ===========================================================================
// RENDER
// ===========================================================================
if (part == "chassis")  chassis();
if (part == "assembly") assembly();

echo(str("chassis ", chassis_d, "x", chassis_w, "x", chassis_h,
         " bowl_niche ", bowl_niche_d, "x", bowl_niche_w, "x", bowl_niche_h,
         " chute_outlet_z=", chute_outlet_z_center,
         " total_tower_z=", chassis_h + housing_height + 3 + 12 + 153 + 170 + 24));
