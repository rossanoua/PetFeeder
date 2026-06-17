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
//   part = "spider"     -> drop-in anti-pressure stress cone (prints alone)
//   part = "spider_fit" -> spider + funnel + wheel, half-cut clearance check
// ===========================================================================

use <paddle_wheel_module.scad>   // wheel() for the spider_fit clearance render

part = "assembly";   // funnel | ring | lid | assembly | spider | spider_fit

/* [Hopper outer geometry] */
bulk_d        = 160;    // outer diameter of every section (mm)
bulk_wall     = 3;      // wall thickness (mm)

/* [Funnel section] */
// 2026-06-08: funnel cone angle is now a first-class parameter. The wall
// angle is measured FROM VERTICAL, nominal cone from the throat opening
// (hole_w/2) out to Ø160 (cavity radius) — the same convention that gave
// the previous ~36°. cone_top_z (where the cone reaches Ø160, straight
// Ø160 above) is DERIVED from it. Bigger angle = more open / shallower.
funnel_wall_angle = 40;  // ← cone half-angle from vertical (was ~36° @ z98)
funnel_h        = 115;
cavity_taper_h  = 5;    // top chamfer that supports the lip's first layer
throat_fillet   = 8;    // 2026-06-06: ROUND the plug→cone inner corner so
                        //   kibble slides smoothly (tangent to the vertical
                        //   plug at the bottom, blends into the cone)

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
hole_radial_out  = 35;   // (floor outlet only; funnel uses the teardrop)
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

/* [Anti-pressure spider] */
// MODULAR stress body: a rounded PEAR body bears the kibble column and shunts
// that weight into the funnel wall through 3 DETACHABLE blade legs. The legs
// snap into the body (detent) and the assembled spider drops in; each leg LAYS
// on a small INWARD ledge (підставка) on the wall → load goes into the wall,
// no sideways spreading. Small side keys stop rotation. All features are
// inside + gentle (≤1.5 mm, ramped) so kibble flows past and it prints without
// supports. Body has ≥3 mm of material under the sockets to hold the legs.
sp_cx        = 4;    // funnel-local X of the body/leg centre (over throat lobe)
sp_seat_z    = 26;   // funnel-local Z of the rest plane (ledge top = leg underside)
sp_leg_n     = 3;    // 3 legs → 3 wide flow gaps
sp_leg_t     = 3.6;  // leg blade thickness
sp_leg_len   = 70;   // printed blade length (clipped to its wall per angle)
sp_leg_phase = 0;    // leg rotation (deg) — orient gaps to the inlet/outlet
sp_slip      = 0.6;  // slip clearance
sp_key_h     = 14;   // leg-blade height (in the body socket)
sp_rest_z    = sp_seat_z;   // legs rest on the pocket floor at this z
// CAPTURE POCKETS (replace the old lay-on ledges): each leg tip drops INTO a
// slot = ramped floor (load + no fall) + 2 tall side walls (anti-rotation) +
// the funnel wall itself as radial backstop. The leg is caught on all sides so
// the spider can't spin off or slide into the outlet. Floor underside is ramped
// (≥proud over the rise → ≤45°) so it still prints without supports.
sp_pocket_proud = 7;   // radial depth of the floor/side-walls inward from the wall
sp_ledge_ramp   = 8;   // floor-underside ramp rise (≥ proud → ≤45°, printable)
sp_wall_t       = 2.5; // each side-wall thickness (tangential)
sp_wall_h       = 11;  // side-wall height above the rest plane (leg is sp_key_h tall)
// pear/dome body + its leg sockets
sp_body_base_r  = 15;   // flat base radius (on the bed when printed dome-up)
sp_body_belly_r = 20;   // pear belly (max) radius
sp_body_belly_z = 8;    // belly-centre height above the base
sp_body_top_r   = 6;    // rounded top radius
sp_body_h       = 32;   // body height
sp_body_floor   = 0;    // NO floor — sockets open at the bottom so the body drops
                        //   straight down onto the 3 legs (legs enter from below,
                        //   ribs slide up the vertical grooves). Radial insertion is
                        //   gone, so the dome narrowing at the top no longer blocks a
                        //   square-cornered leg from seating to full depth.
sp_sock_depth   = 9;    // leg socket depth into the body. MUST be < body_base_r
                        //   so the 3 sockets/legs DON'T meet at the centre (at 16
                        //   they overshot → 3 legs collided → couldn't seat → stuck
                        //   out too long → spider hung high & wouldn't descend).
// snap detent (holds the leg in the body socket WITHOUT glue): a bump on each
// leg face that clicks into a dimple in each socket wall.
sp_det_d        = 3.2;  // detent diameter
sp_det_h        = 0.8;  // bump proud height / dimple depth
sp_det_x        = sp_body_base_r - sp_sock_depth + 5;  // radial pos from sp_cx (near socket bottom)

/* [Quality] */
$fn = 96;

// --- derived ----------------------------------------------------------------
bulk_r_out     = bulk_d / 2;
bulk_r_in      = bulk_r_out - bulk_wall;

// Funnel cone top z from the wall angle (nominal throat→Ø160, from vertical).
cone_top_z     = cap_collar_h
               + (bulk_d / 2 - hopper_wall - hole_w / 2) / tan(funnel_wall_angle);

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

// Cone from the straight plug (at z=cap_collar_h, profile = throat_2d offset
// by prof_off) up to a Ø(2*r_top) circle at cone_top_z, with the bottom
// corner ROUNDED (a fillet tangent to the vertical plug, blending into the
// cone). Used for both the outer and the cavity so the wall stays uniform.
module fillet_cone(prof_off, r_top) {
    amax = 45; n = 4; fil = throat_fillet;
    for (i = [0 : n - 1])
        hull() {
            translate([0, 0, cap_collar_h + fil * sin(amax * i / n)])
                linear_extrude(0.02)
                    offset(prof_off + fil * (1 - cos(amax * i / n))) throat_2d();
            translate([0, 0, cap_collar_h + fil * sin(amax * (i + 1) / n)])
                linear_extrude(0.02)
                    offset(prof_off + fil * (1 - cos(amax * (i + 1) / n))) throat_2d();
        }
    hull() {
        translate([0, 0, cap_collar_h + fil * sin(amax)])
            linear_extrude(0.02)
                offset(prof_off + fil * (1 - cos(amax))) throat_2d();
        translate([0, 0, cone_top_z - 0.5]) cylinder(r = r_top, h = 0.5);
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
        // Mass-flow cone with a ROUNDED plug→cone corner, to Ø160 at cone_top_z.
        fillet_cone(hopper_wall, bulk_d / 2);
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
        // 2. Cone cavity with the SAME rounded plug→cone corner (wall stays
        //    uniform): throat → r=(bulk_d/2 - hopper_wall) at cone_top_z.
        fillet_cone(0, bulk_d/2 - hopper_wall);
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
    // ===== Hollowed funnel body + 3 small INWARD ledges (підставки) =====
    // The assembled spider drops in; each leg LAYS on a small inward ledge
    // (the load goes into the wall, no sideways spreading). Small side keys
    // stop rotation. Everything is inside + gentle (≤1.5 mm, ramped) so kibble
    // flows past and it prints without supports.
    union() {
        difference() {
            union() {
                funnel_outer();
                stacking_lip(z_funnel_top);
            }
            funnel_cavity();
        }
        spider_pockets();           // 3 capture pockets (floor + side walls)
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
// ANTI-PRESSURE SPIDER  drop-in stress cone, KEYED into funnel-wall slots
// ---------------------------------------------------------------------------
// cav(d): the funnel inner void, offset inward by d. Booleaning against this
// lets the bosses/slots/legs conform to the teardrop wall automatically
// (no need to know the wall radius at each leg angle).
module cav(d) {
    union() {
        translate([0, 0, -3]) linear_extrude(cap_collar_h + 3) offset(-d) throat_2d();
        fillet_cone(-d, bulk_d / 2 - hopper_wall - d);
        translate([0, 0, cone_top_z - 0.01])
            cylinder(r = bulk_d / 2 - hopper_wall - d, h = funnel_h);
    }
}
// Radial slab at leg i's angle (around the spider centre), tangential width w.
module sp_wedge(i, w) {
    translate([sp_cx, 0, 0]) rotate([0, 0, i * 360 / sp_leg_n + sp_leg_phase])
        translate([-1, -w / 2, 0]) cube([400, w, 400]);
}
// Two tangential strips flanking leg i (for the anti-rotation side keys).
module sp_strips(i, w_out, w_in) {
    difference() { sp_wedge(i, w_out); sp_wedge(i, w_in); }
}
// A small INWARD wedge of material at the wall (thickness `proud` into the
// cavity), gently ramped over sp_ledge_ramp so it prints support-free and
// kibble flows past. `topz` = its top; `wedge` = the angular region.
module inward_ramp(proud, topz, region_mod_args) {
    // (region passed via children) — hull of a proud slab on top and a flush
    // slab at the bottom of the ramp.
    hull() {
        intersection() { difference() { cav(0); cav(proud); } children(0);
            translate([-200, -200, topz - 0.8]) cube([400, 400, 0.8]); }
        intersection() { difference() { cav(0); cav(0.25); } children(0);
            translate([-200, -200, sp_rest_z - sp_ledge_ramp]) cube([400, 400, 0.4]); }
    }
}
// 3 CAPTURE POCKETS the leg tips drop into. Each = a ramped floor (the leg
// rests on it) + 2 tall side walls hugging the wall (anti-rotation), with the
// funnel wall as the radial backstop. The leg channel is open at the top and
// toward the centre so the assembled spider just drops in. Prints support-free.
module spider_pockets() {
    slot_w = sp_leg_t + 2 * sp_slip + 2 * sp_wall_t;       // floor/walls footprint
    for (i = [0 : sp_leg_n - 1])
        difference() {
            union() {
                // ramped floor (flush below → proud at the rest plane)
                inward_ramp(sp_pocket_proud, sp_rest_z) sp_wedge(i, slot_w);
                // side-wall block: a proud shell band hugging the wall, rest → rest+wall_h
                intersection() {
                    difference() { cav(0); cav(sp_pocket_proud); }
                    sp_wedge(i, slot_w);
                    translate([-200, -200, sp_rest_z]) cube([400, 400, sp_wall_h]);
                }
            }
            // carve the leg channel (open top + open toward centre) → leaves the
            // floor below and the two side walls flanking it
            intersection() {
                sp_wedge(i, sp_leg_t + 2 * sp_slip);
                translate([-200, -200, sp_rest_z]) cube([400, 400, sp_wall_h + 30]);
            }
        }
}

// --- modular spider: pear/dome body + detachable blade legs ----------------
// Snap detent: a VERTICAL half-round rib on each ±Y face of leg i (BUMP on the
// leg, GROOVE in the socket), running the full blade height. Because the rib
// runs along Z — the build direction when the leg is printed ON EDGE, and the
// socket-wall direction when the body is printed dome-up — BOTH the rib and the
// groove print with NO overhang. `dia` = rib Ø, `prot` = how far it stands proud
// of the face. The leg slides in radially; the rounded rib rides the wall and
// snaps into the groove → glueless hold.
module sp_detents(i, dia, prot) {
    translate([sp_cx, 0, 0]) rotate([0, 0, i * 360 / sp_leg_n + sp_leg_phase])
        translate([sp_det_x, 0, sp_rest_z])
            for (s = [-1, 1])
                translate([0, s * (sp_leg_t / 2 + prot - dia / 2), 0])
                    cylinder(d = dia, h = sp_key_h, $fn = 24);
}
// Body: a rounded pear (no flat tops → sheds kibble), flat base at the rest
// plane, with 3 radial sockets the leg blades slide into + detent dimples.
module spider_body() {
    difference() {
        intersection() {
            translate([sp_cx, 0, sp_rest_z]) hull() {
                cylinder(r = sp_body_base_r, h = 0.01);                            // base ref
                translate([0, 0, sp_body_belly_z]) sphere(sp_body_belly_r, $fn = 72); // belly
                translate([0, 0, sp_body_h - sp_body_top_r]) sphere(sp_body_top_r, $fn = 48); // top
            }
            translate([-200, -200, sp_rest_z - sp_body_floor]) cube([400, 400, 400]); // flat base, 3mm floor below sockets
        }
        for (i = [0 : sp_leg_n - 1])                                           // 3 leg sockets
            intersection() {
                sp_wedge(i, sp_leg_t + 2 * sp_slip);
                translate([-200, -200, sp_rest_z]) cube([400, 400, sp_key_h]);
                translate([sp_cx, 0, 0]) rotate([0, 0, i * 360 / sp_leg_n + sp_leg_phase])
                    translate([sp_body_base_r - sp_sock_depth, -50, -50]) cube([400, 100, 400]);
            }
        for (i = [0 : sp_leg_n - 1])                                           // detent grooves
            sp_detents(i, sp_det_d + 0.8, sp_det_h + 0.4);
    }
}
// One leg as placed in the funnel (for the assembled / fit views): a radial
// blade from inside the body socket out into the wall pocket.
module spider_leg_placed(i) {
    union() {
        intersection() {
            translate([sp_cx, 0, 0]) rotate([0, 0, i * 360 / sp_leg_n + sp_leg_phase])
                translate([sp_body_base_r - sp_sock_depth + sp_slip, -sp_leg_t / 2, sp_rest_z])
                    cube([sp_leg_len, sp_leg_t, sp_key_h]);
            // clip the outer end VERTICALLY at the wall radius on the REST plane
            // (not down the sloped cone wall) → the blade's outer edge is vertical,
            // so printed on edge it has NO overhang. Above z=rest it just clears the
            // (wider) wall; the pocket floor + side walls catch it at the rest plane.
            translate([0, 0, sp_rest_z - 1])
                linear_extrude(height = sp_key_h + 2)
                    projection(cut = true) translate([0, 0, -sp_rest_z]) cav(sp_slip);
        }
        sp_detents(i, sp_det_d, sp_det_h);   // snap rib (both faces)
    }
}
// One leg STANDING ON ITS EDGE for printing (blade height sp_key_h → Z). Layers
// run across the blade → strong against the bending load; the detents end up on
// the vertical side faces so they aren't crushed flat on the bed. Just undo the
// funnel placement (angle + offset) — the leg already sits on its bottom edge at
// z=0..sp_key_h, no lay-down rotation. Each leg is cut to its own wall length.
module spider_leg_flat(i) {
    rotate([0, 0, -(i * 360 / sp_leg_n + sp_leg_phase)])
        translate([-sp_cx, 0, -sp_rest_z])
            spider_leg_placed(i);
}
// All 3 legs laid out on the bed.
module spider_legs() {
    for (i = [0 : sp_leg_n - 1])
        translate([0, i * (sp_key_h + 6), 0]) spider_leg_flat(i);
}

// Assembled spider (body + 3 legs) in funnel-local coordinates.
module spider() {
    spider_body();
    for (i = [0 : sp_leg_n - 1]) spider_leg_placed(i);
}

// ===========================================================================
// RENDER
// ===========================================================================
if (part == "funnel")   funnel();
if (part == "ring")     ring();
if (part == "lid")      lid();
if (part == "spider")           // assembled view (not for printing directly)
    translate([-sp_cx, 0, -sp_rest_z]) spider();
if (part == "spider_body")      // PRINT: pear body, dome up, flat base on bed
    translate([-sp_cx, 0, -sp_rest_z]) spider_body();
if (part == "spider_leg")       // one flat blade leg (leg 0)
    spider_leg_flat(0);
if (part == "spider_legs")      // PRINT: all 3 leg blades laid out on the bed
    spider_legs();
if (part == "spider_sec")    // DEBUG: vertical half-cut of the assembled spider
    difference() {           //        → see leg-0 seated in its body socket + detent
        translate([-sp_cx, 0, -sp_rest_z]) spider();
        translate([-200, -400, -250]) cube([400, 400, 500]);   // remove y<0
    }
if (part == "spider_hsec")   // DEBUG: horizontal slab at the socket plane (top view)
    intersection() {
        translate([-sp_cx, 0, -sp_rest_z]) spider();
        translate([-200, -200, sp_rest_z + sp_key_h/2 - 0.6 - sp_rest_z])
            cube([400, 400, 1.2]);
    }
if (part == "spider_fit") {
    // half-cut (keep y ≥ 0) to see the cone / legs / wall / wheel clearance.
    // wheel sits at funnel-local [throat_cx, 0, 3.5 − 40] (see chassis assembly).
    difference() {
        union() {
            color("LightBlue", 0.40)  funnel();
            color("Tomato")           spider();
            color("Silver")           translate([throat_cx, 0, 3.5 - 40]) wheel();
        }
        translate([-200, -400, -250]) cube([400, 400, 500]);   // remove y < 0
    }
}
xsec_z = sp_rest_z + sp_key_h / 2;   // override with -D xsec_z=NN
if (part == "funnel_xsec")
    // debug: horizontal wall section → 3 slots show as inner notches + outer
    // bosses at the slot level; a plain ring above the boss (no holes).
    projection(cut = true) translate([0, 0, -xsec_z]) funnel();
if (part == "funnel_vsec")
    // debug: VERTICAL section at y=0 (through leg-0's +x boss) → see the boss
    // ramp profile + slot + overhang angle.
    projection(cut = true) rotate([90, 0, 0]) funnel();
if (part == "funnel_cut")
    // debug: funnel cross-sectioned through leg-0's slot (on the +x wall, y=0).
    difference() {
        funnel();
        translate([-200, -400, -250]) cube([400, 400, 500]);   // remove y < 0
    }
if (part == "key_zoom") {
    // debug: a z-slab around the seat, half-cut, so --viewall frames the
    // boss / slot / leg-tab engagement at a readable scale.
    difference() {
        intersection() {
            union() { color("LightBlue") funnel(); color("Tomato") spider(); }
            translate([-200, -200, sp_seat_z - 2]) cube([400, 400, sp_key_h + sp_body_h]);
        }
        translate([-200, -400, -250]) cube([400, 400, 500]);   // remove y < 0
    }
}
if (part == "spider_cover") {
    // top-down 2D: throat opening (green) vs spider footprint (red).
    // Green showing through = open flow gaps; red over centre = roofed column.
    color("LightGreen")       throat_2d();
    color("Tomato", 0.65)     projection() spider();
}
if (part == "assembly") {
    color("LightBlue", 0.6)         funnel();
    color("LightSteelBlue", 0.55)   translate([0, 0, z_funnel_top]) ring();
    color("Khaki", 0.7)             translate([0, 0, z_funnel_top + ring_h]) lid();
}

echo(str("bulk_d=", bulk_d, " funnel_h=", funnel_h,
         " wall_angle=", funnel_wall_angle, "deg cone_top_z=", round(cone_top_z*10)/10,
         " hopper_outer=", hopper_outer_len, "x", hopper_outer_w,
         " ring_h=", ring_h,
         " total_h=", z_funnel_top + ring_h + joint_lip_h + 4 + lid_disc_h + lid_handle_h,
         " est_ring_L=", round(3.14159 * bulk_r_in * bulk_r_in * ring_h / 1000) / 1000));
