// AiPetFeeder — Stage 1 auger test module
// ---------------------------------------------------------------------------
// Purpose: validate the FEEDING MECHANISM only (does the auger move kibble
// reliably, without jamming, with a roughly repeatable portion?).
// This is intentionally a throwaway test part, NOT the final enclosure.
//
// Print several variants by changing `auger_od` and `pitch`, test each with
// the real cat food, then record results in docs/mechanical-tests.md.
//
// Render one part at a time for export:
//   part = "auger"    -> the screw
//   part = "barrel"   -> the tube it turns inside
//   part = "assembly" -> both, for visual fit check (do not export this)
// ===========================================================================

part = "assembly";   // "auger" | "barrel" | "assembly"

/* [Auger] */
auger_len      = 80;    // working length of the screw (mm)
auger_od       = 22;    // flight outer diameter (mm)  <-- key variable to sweep
shaft_d        = 8;     // central shaft diameter (mm)
pitch          = 20;    // travel per full turn (mm)   <-- key variable to sweep
flight_thick   = 1.6;   // thickness of the helical blade (mm), ~4 perimeters
handed         = 1;     // +1 right-hand, -1 left-hand (sets feed direction)

/* [Motor coupling] (bore in the rear of the shaft) */
coupling_d     = 5.0;   // motor shaft diameter (NEMA17 = 5 mm)
coupling_len   = 14;    // how deep the bore goes
coupling_flat  = 0.5;   // D-shaft flat depth; 0 = plain round bore
fit_clear      = 0.20;  // added to bore for printer fit (tune per printer)

/* [Barrel / tube] */
barrel_clear   = 0.8;   // radial gap between flight OD and tube bore (mm)
wall           = 3;     // tube wall thickness (mm)
inlet_w        = 24;    // inlet opening size along the tube axis (mm)
inlet_from_rear= 6;     // inlet start, measured from the rear face (mm)
end_clear      = 2;     // axial slack at each end of the tube (mm)

/* [Quality] */
$fn = 96;
slices_per_turn = 60;   // helix smoothness

// --- derived ------------------------------------------------------------
turns       = auger_len / pitch;
twist_deg   = -handed * 360 * turns;          // OpenSCAD twist is CW = -RH
flight_r    = auger_od / 2;
shaft_r     = shaft_d / 2;
bore_r      = flight_r + barrel_clear;        // tube inner radius
barrel_or   = bore_r + wall;                  // tube outer radius
barrel_len  = auger_len + 2 * end_clear;

// ===========================================================================
// AUGER
// ===========================================================================
module auger() {
    difference() {
        union() {
            // central shaft
            cylinder(h = auger_len, d = shaft_d);

            // helical flight: a flat radial blade extruded with twist
            linear_extrude(height      = auger_len,
                            twist       = twist_deg,
                            slices      = ceil(turns * slices_per_turn),
                            convexity   = 10)
                translate([0, -flight_thick / 2])
                    square([flight_r, flight_thick]);
        }

        // motor coupling bore in the rear (z = 0) end of the shaft
        translate([0, 0, -0.01])
            difference() {
                cylinder(h = coupling_len, d = coupling_d + fit_clear);
                if (coupling_flat > 0)
                    // flatten one side for a D-shaft
                    translate([ (coupling_d + fit_clear)/2 - coupling_flat,
                                -coupling_d, -1 ])
                        cube([coupling_d, 2*coupling_d, coupling_len + 2]);
            }
    }
}

// ===========================================================================
// BARREL (tube the auger turns inside)
// ===========================================================================
module barrel() {
    difference() {
        // outer body
        cylinder(h = barrel_len, d = 2 * barrel_or);

        // inner bore
        translate([0, 0, -1])
            cylinder(h = barrel_len + 2, d = 2 * bore_r);

        // top inlet (food drops in here from the hopper)
        translate([ -barrel_or - 1,
                    -inlet_w / 2,
                    inlet_from_rear ])
            cube([ barrel_or + 1, inlet_w, inlet_w ]);
    }
    // NOTE: the front face (z = barrel_len) is left fully open = the outlet.
}

// ===========================================================================
// RENDER
// ===========================================================================
if (part == "auger")  auger();
if (part == "barrel") barrel();
if (part == "assembly") {
    color("Silver")               auger();
    color("LightBlue", 0.35) translate([0, 0, -end_clear]) barrel();
}

echo(str("turns=", turns, "  twist_deg=", twist_deg,
         "  bore_d=", 2*bore_r, "  barrel_od=", 2*barrel_or,
         "  barrel_len=", barrel_len));
