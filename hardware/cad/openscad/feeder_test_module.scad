// AiPetFeeder — Stage 1 auger test module
// ---------------------------------------------------------------------------
// Purpose: validate the FEEDING MECHANISM only (does the auger move kibble
// reliably, without jamming, with a roughly repeatable portion?).
// Throwaway test rig, NOT the final enclosure.
//
// Parts (render one at a time for STL export):
//   part = "auger"    -> the screw, with a through D-bore for the axle
//   part = "axle"     -> the drive axle (round ends + D-flat in the middle)
//   part = "barrel"   -> tube, with a conical inlet funnel + hopper socket
//   part = "hopper"   -> feed cone that plugs into the barrel socket
//   part = "assembly" -> everything together (fit check, do NOT export)
//
// Torque path: motor -> axle (round stub) -> D-flat -> auger -> food.
// The D-flat (one milled/printed flat) keys the axle to the auger so it
// drives instead of spinning free. Use a real 5 mm steel rod as the axle
// if you can — printed axles flex and wear.
// ===========================================================================

part = "assembly";   // auger | axle | barrel | hopper | assembly

/* [Auger] */
auger_len      = 80;    // working length of the screw (mm)
auger_od       = 22;    // flight outer diameter (mm)  <-- key var to sweep
shaft_d        = 9;     // central shaft diameter (mm) — must wrap the axle
pitch          = 20;    // travel per full turn (mm)   <-- key var to sweep
flight_thick   = 1.6;   // helical blade thickness (mm)
handed         = 1;     // +1 right-hand, -1 left-hand (feed direction)

/* [Axle] (separate rod you turn the auger with) */
axle_d         = 5.0;   // axle diameter (mm) — NEMA17 / steel rod = 5 mm
axle_flat      = 0.8;   // D-flat depth: this is the torque key
axle_stub_rear = 22;    // length sticking out the rear (motor coupler side)
axle_stub_front= 12;    // length sticking out the front (bearing/support)
fit_clear      = 0.20;  // print clearance added to mating bores

/* [Barrel / tube] */
barrel_clear   = 0.8;   // radial gap between flight OD and tube bore
wall           = 3;     // tube wall thickness (mm)
end_clear      = 2;     // axial slack at each end of the tube (mm)

/* [Inlet funnel + hopper joint] */
inlet_from_rear= 10;    // inlet start, from the barrel rear face (mm)
inlet_len      = 26;    // inlet length along the tube axis (mm)
inlet_w        = 16;    // inlet width across the tube, at the bore (mm)
inlet_flare    = 7;     // how much the funnel widens toward the mouth (mm)
collar_h       = 12;    // socket collar height, radially outward (mm)
collar_wall    = 2.5;   // socket collar wall thickness (mm)
join_clear     = 0.35;  // hopper-spout <-> collar-socket slip fit (mm)

/* [Feed cone / hopper] */
hopper_top_d   = 70;    // wide food opening at the top of the cone (mm)
hopper_h       = 55;    // cone height (mm)
hopper_wall    = 2;     // cone wall thickness (mm)
spout_h        = 9;     // straight spout that plugs into the collar (mm)

/* [Quality] */
$fn = 96;
slices_per_turn = 60;

// --- derived ------------------------------------------------------------
turns      = auger_len / pitch;
twist_deg  = -handed * 360 * turns;          // OpenSCAD twist is CW = -RH
flight_r   = auger_od / 2;
bore_r     = flight_r + barrel_clear;        // tube inner radius
barrel_or  = bore_r + wall;                  // tube outer radius
barrel_len = auger_len + 2 * end_clear;

mouth_y    = inlet_w  + 2 * inlet_flare;     // funnel/socket size, around tube
mouth_z    = inlet_len + 2 * inlet_flare;    // funnel/socket size, along tube
zc         = inlet_from_rear + inlet_len / 2;// inlet centre (barrel-local z)

// D-profile solid: a cylinder with one side flattened (axle cross-section,
// and also the matching bore). Flat is on +X so axle and bore key together.
module d_solid(d, flat, len) {
    difference() {
        cylinder(h = len, d = d);
        translate([d/2 - flat, -d, -1]) cube([d, 2*d, len + 2]);
    }
}

// ===========================================================================
// AUGER  (screw + helical flight, with a through D-bore for the axle)
// ===========================================================================
module auger() {
    difference() {
        union() {
            cylinder(h = auger_len, d = shaft_d);
            linear_extrude(height    = auger_len,
                           twist     = twist_deg,
                           slices    = ceil(turns * slices_per_turn),
                           convexity = 10)
                translate([0, -flight_thick / 2])
                    square([flight_r, flight_thick]);
        }
        // through D-bore: axle passes all the way through, keyed by the flat
        translate([0, 0, -1])
            d_solid(axle_d + fit_clear, axle_flat, auger_len + 2);
    }
}

// ===========================================================================
// AXLE  (round stubs at both ends, D-flat over the auger engagement length)
// ===========================================================================
module axle() {
    total = axle_stub_rear + auger_len + axle_stub_front;
    difference() {
        cylinder(h = total, d = axle_d);
        // flat only where the auger grips (middle section)
        translate([axle_d/2 - axle_flat, -axle_d, axle_stub_rear])
            cube([axle_d, 2*axle_d, auger_len]);
    }
}

// ===========================================================================
// BARREL  (tube + conical inlet funnel + rectangular hopper socket collar)
// ===========================================================================
module barrel() {
    difference() {
        union() {
            cylinder(h = barrel_len, d = 2 * barrel_or);
            // socket collar on the -X side, overlapping the barrel by ~4 mm
            translate([ -(barrel_or + collar_h),
                        -(mouth_y/2 + collar_wall),
                        zc - mouth_z/2 - collar_wall ])
                cube([ collar_h + 4,
                       mouth_y + 2*collar_wall,
                       mouth_z + 2*collar_wall ]);
        }

        // bore
        translate([0, 0, -1])
            cylinder(h = barrel_len + 2, d = 2 * bore_r);

        // conical inlet funnel: narrow at the bore, flaring out to the
        // collar mouth. This is also the socket the hopper spout plugs into.
        hull() {
            translate([ -2, -inlet_w/2, inlet_from_rear ])
                cube([ 3, inlet_w, inlet_len ]);                 // at the bore
            translate([ -(barrel_or + collar_h) - 1, -mouth_y/2, zc - mouth_z/2 ])
                cube([ 3, mouth_y, mouth_z ]);                   // collar mouth
        }
    }
    // front face (z = barrel_len) stays fully open = the food outlet.
}

// ===========================================================================
// HOPPER  (round food opening -> rectangular spout that plugs into collar)
// Built along +Z: spout at z=0, cone opening at the top. Local X maps to the
// tube axis once placed (see assembly).
// ===========================================================================
module hopper() {
    sx = mouth_z - join_clear;   // along tube axis after placement
    sy = mouth_y - join_clear;   // around the tube after placement
    ix = sx - 2*hopper_wall;
    iy = sy - 2*hopper_wall;
    difference() {
        union() {
            // straight spout (plugs into the barrel collar socket)
            translate([-sx/2, -sy/2, 0]) cube([sx, sy, spout_h]);
            // cone: rectangle -> round, via hull of two thin slices
            hull() {
                translate([-sx/2, -sy/2, spout_h]) cube([sx, sy, 0.01]);
                translate([0, 0, spout_h + hopper_h - 0.01])
                    cylinder(h = 0.01, d = hopper_top_d);
            }
        }
        // hollow it out (open at both spout bottom and cone top)
        translate([-ix/2, -iy/2, -1]) cube([ix, iy, spout_h + 1]);
        translate([0, 0, spout_h])
            hull() {
                translate([-ix/2, -iy/2, -0.01]) cube([ix, iy, 0.01]);
                translate([0, 0, hopper_h + 1])
                    cylinder(h = 0.01, d = hopper_top_d - 2*hopper_wall);
            }
    }
}

// ===========================================================================
// RENDER
// ===========================================================================
if (part == "auger")  auger();
if (part == "axle")   axle();
if (part == "barrel") barrel();
if (part == "hopper") hopper();
if (part == "assembly") {
    color("Silver")              auger();
    color("DimGray")  translate([0, 0, -axle_stub_rear]) axle();
    color("LightBlue", 0.30) translate([0, 0, -end_clear]) barrel();
    // seat the hopper spout into the collar socket on the -X side
    color("Khaki", 0.55)
        translate([ -(barrel_or - 1),
                    0,
                    zc - end_clear ])
            rotate([0, -90, 0])
                hopper();
}

echo(str("turns=", turns, " twist=", twist_deg,
         " bore_d=", 2*bore_r, " barrel_od=", 2*barrel_or,
         " mouth=", mouth_y, "x", mouth_z,
         " axle_total=", axle_stub_rear + auger_len + axle_stub_front));
