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
hole_radial_in   = 22;   // 2026-06-26: 7→22 so the outlet clears the central motor (r21) and sits
hole_radial_out  = 35;   //   fully over the front niche (x>20.5) → food drops to the bowl, not the motor
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
pw_td_tip_r     = 26;   // blunt tip — MIRROR of td_tip_r in paddle_wheel_module.scad
pw_td_back      = 22;
pw_inlet_margin = 3;
pw_axle_keep    = 4.8;   // = axle_d/2 + fit_clear + 2
throat_cx       = 0;     // 2026-06-19 RECENTER: 0 → the Ø160 funnel is centred on
                         //   the wheel AXLE (was 28 = centred over the throat lobe).
                         //   The throat stays off-centre toward −X (inlet lobe); the
                         //   cone inside becomes asymmetric but the housing now hides
                         //   under the Ø160 silhouette (user: центр над віссю колеса).

/* [Anti-pressure spider] */
// MODULAR stress body: a rounded PEAR body bears the kibble column and shunts
// that weight into the funnel wall through 3 DETACHABLE blade legs. The legs
// snap into the body (detent) and the assembled spider drops in; each leg LAYS
// on a small INWARD ledge (підставка) on the wall → load goes into the wall,
// no sideways spreading. Small side keys stop rotation. All features are
// inside + gentle (≤1.5 mm, ramped) so kibble flows past and it prints without
// supports. Body has ≥3 mm of material under the sockets to hold the legs.
sp_cx        = -27;  // funnel-local X of the spider centre = over the throat-exit
                     //   centroid (−27.1). 2026-06-23: moved −15→−27 now that the cone
                     //   is reprinted (for the top bortik) — pockets, legs AND body all
                     //   share −27, so the legs are STRAIGHT (no dogleg), 1-long-2-short,
                     //   and the spider sits over the exit.
sp_body_cx   = sp_cx;  // body = pocket centre now (straight legs); kept as an alias.
sp_seat_z    = 36;   // funnel-local Z of the rest plane. Raised 26→36 (+10mm) to
                     //   lift the whole spider 1 cm: the wall pockets move up with
                     //   it and the legs auto-lengthen (cone is wider higher up).
                     //   Body shape unchanged (it just sits higher).
sp_leg_n     = 3;    // 3 legs → 3 wide flow gaps
sp_leg_t     = 3.2;  // leg NECK thickness (the blade)
sp_leg_len   = 95;   // printed blade length (clipped to its wall per angle). 70→95
                     //   so the legs still reach the now-asymmetric cone wall (the
                     //   +X side opens much wider after the recenter).
sp_leg_phase = 0;    // leg rotation (deg) — orient gaps to the inlet/outlet
sp_slip      = 0.35; // slip clearance (snug T-rail slide)
// DOVETAIL / inverted-T capture: each leg is an inverted-T rail — a wide FOOT
// along the bottom + a narrow NECK on top. The body socket is the matching
// T-groove; sliding the leg in RADIALLY captures it vertically (the foot can't
// lift through the narrower neck slot). Holds with NO snap force and NO glue;
// the load path (body socket roof → leg top → wall pocket floor) doesn't touch
// the capture. Both parts print support-free: the leg is wide-to-narrow going up
// (a pyramid, zero overhang); the body's foot-chamber shoulder is a small
// horizontal overhang (~flare wide) that bridges trivially.
sp_foot_flare = 0.8; // how far the foot sticks out past the neck, each side
sp_foot_h     = 2.2; // foot height (the captured lip)
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
// HUB cylinder (houses the sockets at CONSTANT depth) + rounded cone cap on top.
// The sockets live entirely in the straight cylinder, so their cross-section is
// identical at every layer — the socket does NOT narrow going up (the old pear
// dome narrowed into the socket so the leg couldn't seat full-height). The cap
// is only ABOVE the socket roof and just sheds kibble.
sp_body_base_r  = 14.5; // hub (lower/stem) radius = socket outer wall. Ø29.
sp_body_bulb_r  = 26;   // upper bulb max radius. Ø52 (wide kibble-bearing cap).
sp_bulb_rise    = 17;   // height above the hub where the bulb reaches its widest
sp_cap_h        = 42;   // cap height above the hub (was 12; +30 → body 30mm taller)
sp_cap_tip_r    = 10;   // rounded top radius
sp_socket_through = true;  // CHOSEN FINAL = open-top (clean, full-depth slots, no
                           //   slicer fill). true: slot runs through the cap (open
                           //   top, no ceiling). false: roofed dome + dead-end vents
                           //   (full depth + ceiling but messier walls) — kept as an
                           //   option; rejected for the cosmetic mess.
sp_roof_gap     = 2;    // when roofed: socket roof this far above the leg neck.
                        //   Small now — the dead-end VENT holes (below) stop the
                        //   slicer filling the slot, so no big dead zone is needed.
sp_body_floor   = 2.5;  // solid floor below the foot chamber (legs enter RADIALLY
                        //   from the side; the foot rests on this floor at z=rest).
sp_groove_ext   = 2;    // body groove extends this much PAST the foot inner (R6→R4),
                        //   a relief void below the foot so the DEEP foot clears the
                        //   cramped hub centre on the dogleg side legs (2026-06-23).
                        //   Foot grip (R6→14.5) is UNCHANGED; hub core stays R4.
sp_sock_depth   = 8.5;  // leg socket depth into the hub (= base_r − 6 → inner stop
                        //   stays at r6). MUST be < body_base_r so the 3 sockets
                        //   DON'T meet at the centre (at 16
                        //   they overshot → 3 legs collided → couldn't seat → stuck
                        //   out too long → spider hung high & wouldn't descend).
// Radial retention is by the snug T-rail friction (sp_slip) over the ~12 mm
// engagement; the dovetail itself resists gravity in the normal dome-up
// orientation. sp_stop_vslip = the foot chamber is this much taller than the
// foot (assembly play). If legs ever slide out too easily, add a detent here.
sp_stop_vslip   = 0.3;
sp_pockets_on   = true;   // include the 3 spider capture pockets in the funnel

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

// ─── SLICE NOTE (3-part funnel) ───────────────────────────────────────────
// The funnel is THREE separate printed parts so no single part has a double-wall
// void for the slicer to fill (that left a solid slab in the old one-piece funnel):
//   part="shell" — Ø160 tube, geom. wall 3 mm. 0% infill, but wall_loops=4 so the
//                  3 mm wall fills SOLID (2 loops left a hollow core — too empty).
//                  PF_CONFIG_OVERRIDE='{"sparse_infill_density":"0%","wall_loops":"4",...brim}'
//   part="cone"  — single-wall cone insert. 0% infill (it's a hollow vessel; the
//                  bore is air). PF: '{"sparse_infill_density":"0%","wall_loops":"2",...brim}'
//   part="cap"   — small SOLID teardrop disc. DEFAULT profile infill (NOT 0% — at
//                  0% the 6 mm disc prints hollow). PF: just the brim override.
// Why split: any between-walls void inside ONE solid part is "model interior" to
// the slicer → it floors it with bottom shells + infill. Vent tricks (gap+ribs →
// "negative spacing"; holes → still infills) do NOT work. Separate parts do.
// ──────────────────────────────────────────────────────────────────────────
// 2026-06-19 PRODUCT REDESIGN — cylindrical exterior + merged cap.
// The funnel is now a Ø160 CYLINDER outside (the whole tower reads as one clean
// cylinder from the table). Inside: an asymmetric mass-flow cone whose throat is
// OFF-CENTRE (over the inlet lobe) while the Ø160 is CENTRED on the wheel axle
// (throat_cx=0) → the housing hides under the silhouette. The old separate
// end_cap is MERGED into the funnel bottom plate (closes the housing top: axle
// bore + throat inlet). Vase-like DOUBLE WALL: outer SHELL + inner CONE joined
// at the top rim and the bottom plate; the ring between them is hollow (light).
shell_wall   = bulk_wall;             // 3 — Ø160 outer shell wall
cone_wall    = hopper_wall;           // 2 — inner mass-flow cone wall. Kept THIN: a
                                      // funnel wall is solid at 2 perimeters already,
                                      // and thickening it tripled print time (slow
                                      // overhang passes) for no benefit (2026-06-21).
cap_t        = 6;                     // merged-cap bottom plate thickness
pw_axle_d    = 5;                     // axle Ø (= paddle_wheel_module axle_d)
pw_fit_clear = 0.3;
// 3-PART funnel (option A): shell, cone, cap are SEPARATE printed parts (so no
// double-wall void exists in any single part → each slices clean/light; the gap
// between shell and cone is real AIR in assembly). The cone is LOCATED BY THE CAP
// (throat plug into the cap collar), so cone_clear is just a loose containment gap
// to the shell bore (no ribs — they printed in air at the cone top).
cone_clear   = 3;                            // radial gap cone-top → shell bore (air)
// cap throat COLLAR — a raised rim the cone's throat plug drops into so the cap
// centres the cone + holds it against tipping (replaces the deleted shell ribs).
cap_reg_clear = 0.4;                         // slip: cone plug outer ↔ collar inner
cap_reg_wall  = 2;                           // collar wall thickness
cap_reg_h     = 8;                           // collar height = plug register depth
cone_out_top = bulk_r_in - cone_clear;       // 74 — cone outer stops short of the shell
cone_in_top  = cone_out_top - cone_wall;     // 72 — cone inner opening at the top

// Outer Ø160 shell — a tube, OPEN at the bottom (its rim rests on the base).
// The inner bore tapers IN over the top cavity_taper_h so the stacking lip's
// first layer lands on solid wall (same lip-support trick as before).
module shell_tube() {
    difference() {
        cylinder(d = bulk_d, h = funnel_h);
        translate([0, 0, -1])
            cylinder(r = bulk_r_in, h = funnel_h - cavity_taper_h + 1);
        translate([0, 0, funnel_h - cavity_taper_h])
            cylinder(r1 = bulk_r_in, r2 = lip_ir, h = cavity_taper_h + 0.01);
    }
}

// Inner mass-flow CONE wall (asymmetric: throat off to −X, opens to a centred
// Ø). Throat plug (z 0..cap_collar_h) → rounded cone → meets the shell at top.
module cone_wall_solid() {
    difference() {
        union() {
            linear_extrude(cap_collar_h) offset(cone_wall) throat_2d();
            fillet_cone(cone_wall, cone_out_top);
        }
        union() {                                    // kibble passage (hollow)
            translate([0, 0, -1]) linear_extrude(cap_collar_h + 1) throat_2d();
            fillet_cone(0, cone_in_top);
            translate([0, 0, cone_top_z - 0.01]) cylinder(r = cone_in_top, h = funnel_h);
        }
    }
}

nest_clear = 0.4;   // groove↔wall slip clearance (mirror nest_clear in paddle_wheel)
nest_h     = 3.5;   // nest depth — the housing top wall enters this far up

// MERGED cap plate — teardrop disc closing the housing top (throat inlet open,
// axle-bore top guide) with a perimeter teardrop GROOVE on its underside that
// the HOUSING TOP WALL enters → self-centres + anti-rotates (the teardrop keys
// it). The groove is cut UP into the plate (from below), so the funnel still
// prints flat-bottomed — only a narrow teardrop-ring bridge (trivial). This is
// the "низ лійки одягається на housing" joint; the cap is merged in here.
// SEPARATE part (2026-06-20): the cap is NO LONGER merged into the funnel. Merging
// the solid cap with the hollow double-wall funnel made it un-sliceable (15% infill
// fills the void → 20h; 0% infill hollows the cap). Split out: the funnel is a pure
// hollow vessel (0% infill, void = air, light) and the cap is a small SOLID teardrop
// disc printed on its own. It nests on the housing top; the funnel sits over it.
module cap_plate() {
    union() {
        difference() {
            linear_extrude(cap_t) teardrop_2d(pw_hr_out, pw_td_tip_r, pw_td_tip_cx);   // Ø88 cap disc
            // perimeter nest groove (ring slot the housing wall slides into)
            translate([0, 0, -0.01]) linear_extrude(nest_h)
                difference() {
                    offset(nest_clear)                     teardrop_2d(pw_hr_out, pw_td_tip_r, pw_td_tip_cx);
                    offset(-pw_housing_wall - nest_clear)  teardrop_2d(pw_hr_out, pw_td_tip_r, pw_td_tip_cx);
                }
            translate([0, 0, -1]) linear_extrude(cap_t + 2) throat_2d();                 // inlet
            translate([0, 0, -1]) cylinder(h = cap_t + 2, d = pw_axle_d + 2 * pw_fit_clear); // axle bore
        }
        // throat COLLAR (on the cap TOP, OUTSIDE the cone-plug outer so the passage
        // stays fully open): the cone's throat plug drops in → the cap centres the
        // cone and holds it against tipping. A vertical ring → prints clean.
        translate([0, 0, cap_t]) linear_extrude(cap_reg_h)
            difference() {
                offset(cone_wall + cap_reg_clear + cap_reg_wall) throat_2d();
                offset(cone_wall + cap_reg_clear)                throat_2d();
            }
    }
}

// (funnel_outer / funnel_cavity removed 2026-06-19 — replaced by the
//  shell_tube + cone_wall_solid + cap_plate trio above.)

module funnel() {
    // Ø160 cylindrical product shell + internal asymmetric mass-flow cone +
    // merged cap plate. The assembled spider still drops in; its capture
    // pockets follow the cone wall via cav() (refit to the new cone).
    // assembly view of the 3 SEPARATE parts together (shell + cone + cap). Each is a
    // single wall → no double-wall void in any one part → slices clean. The gap
    // between shell and cone is real AIR (the cone is located by the cap collar, not
    // the shell). NB: the cone is raised by cap_t here because in the real stack it
    // RESTS on the cap top (the print part funnel_cone() is still at z0 — view-only).
    funnel_shell();
    translate([0, 0, cap_t]) funnel_cone();
    cap_plate();
}
// 3-part funnel — SHELL: the outer Ø160 tube + the stacking lip. A plain tube →
// slices perfectly (one wall, no void, no bottom disc).
module funnel_shell() {
    union() {
        shell_tube();
        stacking_lip(z_funnel_top);
    }
}
// 3-part funnel — CONE insert: the mass-flow cone + spider pockets. The cone is
// LOCATED BY THE CAP (its throat plug drops into the cap collar — see cap_plate),
// not by the shell, so there are no centering ribs (they cantilevered into air at
// the cone top, which prints throat-down). The shell bore just loosely contains it
// (3 mm gap → ≤2° tip). Single wall → slices clean/light.
module funnel_cone() {
    union() {
        cone_wall_solid();
        if (sp_pockets_on) spider_pockets();   // 3 capture pockets (floor + side walls)
        cone_bortik();                         // top rim → snug in the shell bore
    }
}
// Top BORTIK (rim): a flange at the cone top that flares out to the shell bore so
// the cone is located at the TOP too (was only held by the cap collar at the bottom
// + friction). Snug slide-fit (bort_clr to the Ø160 bore); the underside is a ~23°
// ramp so it prints support-free on the throat-down cone.
bort_clr = 0.4;                 // radial slip cone bortik ↔ shell bore
bort_h   = 8;                   // bortik height down from the cone top
module cone_bortik() {
    bo_r = bulk_r_in - bort_clr;          // 76.6 — snug in the Ø154 bore
    rotate_extrude($fn = 160)
        polygon([[cone_out_top - 1,       cone_top_z - bort_h],   // inner, low — on the cone wall
                 [bo_r,                    cone_top_z - 2],        // outer — ramp underside (~23°)
                 [bo_r,                    cone_top_z],            // outer top — vertical snug face
                 [cone_out_top - 1,        cone_top_z]]);          // inner top
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
// BASE  Ø160 product shell that hides the mechanism (2026-06-19, FIRST PASS)
// ---------------------------------------------------------------------------
// The lower Ø160 section. (a) Encloses the housing so the tower reads as one
// clean cylinder; (b) a UNIVERSAL central motor cavity under the axle (specific
// motor TBD — заклади порожнину з запасом); (c) routes the wheel floor OUTLET
// out a SIDE CHUTE to a bowl in FRONT (+X). The funnel stacks on top via the
// same lip joint as the rings, and its cap-plate nests on the housing top.
//
// Vertical stack:  table(0) → motor/chute region (base_motor_h) → housing-rest
// PLATE → housing (pw_housing_h) → base top = funnel bottom.
// NOTE: first pass — internals are deliberately simple (solid rest-plate, open
// chute sides). Lighten + add electronics access once the layout is agreed.
// [Motor — NEMA17 17HS4401, verified from BOM/project-notes]
nema_w        = 42.3;   // frame size (square body)
nema_len      = 40;     // 17HS4401 body length (VERIFY your unit: 34/40/48 variants)
nema_pilot_d  = 22;     // centring boss Ø on the motor face
nema_bolt_sq  = 31;     // M3 mounting-hole square pattern
nema_bolt_d   = 3.4;    // M3 clearance hole
nema_shaft_d  = 5;      // shaft Ø (Ø5 D-axle couples to it; wheel bore already 5mm D)
base_outlet_angle = 0;          // outlet/chute on +X (the "front", bowl side)
pw_housing_h2     = 37;         // = paddle_wheel_module housing_h (keep in sync)
base_floor        = 3;          // bottom floor thickness
motor_mount_t     = 5;          // motor DECK thickness (NEMA17 bolts up to it)
base_plate_t      = 3;          // housing-rest plate thickness
base_deck_z       = base_floor + nema_len;   // 43 — motor face / deck; body hangs below
base_motor_h      = base_deck_z + motor_mount_t;        // 48 — disc top = housing floor (no coupler gap)
base_h            = base_motor_h + pw_housing_h2;       // 85
base_chute_w      = hole_w + 6; // 40 — chute / outlet-drop width
base_mouth_h      = 18;         // front exit opening height
base_mid_r        = (hole_radial_in + hole_radial_out) / 2;   // 21 — outlet centre r
// ANTI-ROTATION key collar: a rounded-rect spigot on the rest-plate that rises into
// the housing's floor outlet (hole_len×hole_w) → keys the housing against motor
// reaction torque + aligns the two outlets. Food drops through its bore (= the plate
// outlet). Top sits 0.5 mm below the housing cavity floor so the paddle clears it.
ar_slip = 0.5;                  // collar ↔ housing-outlet slip
ar_wall = 1.2;                  // collar wall
ar_h    = 2.5;                  // collar height (≈ housing end_wall − 0.5)
ar_ox   = hole_len - ar_slip;             // 27.5 collar outer, radial
ar_oy   = hole_w   - ar_slip;             // 33.5 collar outer, tangential
ar_bx   = ar_ox - 2 * ar_wall;            // 25.1 bore / plate-outlet, radial
ar_by   = ar_oy - 2 * ar_wall;            // 31.1 bore / plate-outlet, tangential
// 2-PART base (2026-06-26): the motor DECK and the housing PLATE are MERGED into ONE
// disc (z43..48). They needed no gap — the wheel sits straight on the Ø5 motor shaft
// (no coupler), so the old chute "connector" ring is gone. The base is now:
//   base_motor  — LEG SHROUD: a plain Ø160 tube (legs + motor cavity), open both ends,
//                 with a SNAP spigot on top. PRINTS STANDING (no support).
//   base_hopper — CORE DISC: the motor bolts to its UNDERSIDE, the housing seats on
//                 top; housing-seat tube + funnel lip grow up. PRINTS disc-on-the-bed.
// The shroud SNAPS up into the disc (a bead springs into a recess groove) → one rigid
// block, print-only, no metal. A −X key aligns the outlet/niche. WHY 2 parts and not
// a single stack: the disc must be a part's bed-floor (or it roofs → support), and so
// must the shroud-side; the shroud-as-standing-tube provides the male snap the disc
// (printed face-down) can't, so they mate directly with no middle ring.
key_ang  = 180;                           // anti-rotation key on −X (away from +X outlet)
// SNAP-joint params (shroud spigot → disc-underside recess)
snap_ir  = bulk_r_in - 1.5;               // 75.5 — snap-spigot inner r
snap_or  = bulk_r_in + 1;                 // 78   — snap-spigot outer r (seats on the wall top)
snap_h   = 3;                             // spigot rise into the disc recess (z43..46)
snap_bead = 0.7;                          // bead radial proud → springs into the recess groove
snap_slip = 0.35;                         // recess ↔ spigot slip
jkey_w   = 5;                             // rotational-key width (tangential)
jkey_pro = 3;                             // rotational-key radial reach
// [Bowl NICHE] — a scallop in the FRONT of the base; the store-bought bowl tucks
// in (under the tower) and the chute drops food straight into it. Above niche_h
// the tower stays full Ø160. Clears the central motor (niche back at x≈30 > r21).
// [Bowl] store-bought, Ø175 × 58 mm — WIDER than the Ø160 tower, so it sits
// mostly in FRONT and only its back nestles into a curved niche in the tower.
bowl_d   = 175;
bowl_h   = 58;
// 2026-06-19 STRAIGHT-DOWN feed (user): food falls vertically from the wheel
// outlet into the bowl BACK, which nestles UNDER the tower front. The tower
// stands on LEGS so the outlet clears the (load-cell-raised) bowl rim. The bowl
// back sits under the outlet (bowl_cx pulled back so back ≈ outlet x).
leg_h    = 28;    // leg foot height (the standoff) — lifts the tower so the outlet
                  //   (z57) clears the load-cell+tray-raised bowl rim (~z52)
// SCREW-IN legs (user): a separate printed leg with a coarse SELF-TAPPING male
// thread screws UP into a plain hole in a base socket-boss. Base prints flat-
// bottomed; legs are separate (replaceable / levelling).
leg_boss_d     = 18;   // socket-boss Ø in the base
leg_socket_h   = 14;   // socket-boss height (thread engagement depth)
leg_thread_d     = 12;  // leg male-thread major Ø
leg_thread_p     = 4;   // pitch (coarse → fewer, cleanly-printable turns)
leg_thread_depth = 1.5; // radial thread depth (root Ø = major − 2·depth = 9)
leg_thread_minor = leg_thread_d - 2 * leg_thread_depth + 0.5;  // 9.5 — plain socket hole
                        //   (root Ø9 + 0.5 slip; the Ø12 crest bites ~1.25 mm → self-taps)
leg_thread_slip  = 0.35;// female-thread radial clearance (socket cut with an oversized tool)
bowl_cx  = 112;   // bowl centre x — back (≈x24) sits UNDER the wheel outlet (x21..35)
niche_z0 = -1;    // scallop runs from the base bottom up (the bowl back nestles in,
                  //   and the food drops down the open niche straight into it)
niche_h  = 58;    // scallop top (just under the outlet level so food falls freely)
niche_cl = 8;     // niche clearance around the bowl (Ø = bowl_d + niche_cl)
// [Load cell + bowl platform] — 1-5 kg straight bar (~80×12.7×12.7), cantilever:
// fixed end anchored to the tower behind the scallop, load end forward under the
// platform; the bowl sits on the platform → its weight deflects the cell (HX711).
lc_l = 80; lc_w = 12.7; lc_h = 12.7;   // bar load cell
lc_z   = 6;       // load-cell bottom z (low, in the scallop)
lc_x0  = 70;      // cell fixed-end x (on the tower-front shelf, behind the bowl)
lc_hole_d = 4.3;  // M4
lc_fix1 = lc_x0 + 6;  lc_fix2 = lc_x0 + 18;     // fixed-end holes (anchor to base shelf)
lc_load1 = lc_x0 + lc_l - 18; lc_load2 = lc_x0 + lc_l - 6;  // load-end holes (to platform)
plat_d = 170;     // bowl platform Ø (holds the Ø175 bowl; low rim)
plat_t = 4;       // tray thickness
plat_z = lc_z + lc_h + 2;   // tray underside z (cell deflection clearance below)

// z-planes:  legs 0 · motor-face 43 · deck-top 48 · plate 57 · plate-top 60 · top 97
deck_top_z = base_deck_z + motor_mount_t;     // 48 — disc top = housing floor (= base_motor_h)

// bowl scallop — cut into every base part it passes through (z−1 .. 58)
module base_niche()
    rotate([0, 0, base_outlet_angle])
        translate([bowl_cx, 0, niche_z0])
            cylinder(d = bowl_d + niche_cl, h = niche_h - niche_z0 + 1, $fn = 120);
// −X rotational key: a radial bar over [z0,z1], radius band [r0,r1]. `g` grows it
// (0 for the lug, +snap_slip for the receiving slot).
module base_keybar(z0, z1, r0, r1, g)
    rotate([0, 0, key_ang]) translate([r0, -(jkey_w + 2*g)/2, z0])
        cube([r1 - r0, jkey_w + 2*g, z1 - z0]);

// PART 1 — LEG SHROUD: a plain Ø160 tube (z0..43), open both ends, around the motor;
// leg sockets at the bottom; a SNAP spigot on top that springs into the disc. PRINTS
// STANDING (z0 on the bed) — a plain tube, no support. Motor inserts from the bottom.
module base_motor() {
    difference() {
        union() {
            difference() {                        // Ø160 tube z0..43, open both ends
                cylinder(d = bulk_d, h = base_deck_z, $fn = 160);
                translate([0, 0, -1]) cylinder(r = bulk_r_in, h = base_deck_z + 1);
            }
            translate([0, 0, base_deck_z])        // SNAP spigot ring (z43..46) rising from the tube top
                difference() {
                    cylinder(r = snap_or, h = snap_h, $fn = 160);
                    translate([0, 0, -1]) cylinder(r = snap_ir, h = snap_h + 2, $fn = 160);
                }
            translate([0, 0, base_deck_z + snap_h - 1.6])   // snap bead: cone lead-in (wide at bottom = the catch)
                difference() {
                    cylinder(r1 = snap_or + snap_bead, r2 = snap_or, h = 1.6, $fn = 160);
                    translate([0, 0, -1]) cylinder(r = snap_ir, h = 3.6, $fn = 160);
                }
            for (a = [60, 135, 225, 300])         // leg socket-bosses (z0..14) — on the bed, short stubs
                rotate([0, 0, a]) translate([bulk_r_out - leg_boss_d/2 - 1, 0, 0])
                    cylinder(d = leg_boss_d, h = leg_socket_h, $fn = 48);
            base_keybar(base_deck_z, base_deck_z + snap_h, snap_or - 1, snap_or + snap_bead, 0);  // −X key lug
        }
        for (a = [60, 135, 225, 300])             // FEMALE-threaded leg sockets (legs screw in from z0)
            rotate([0, 0, a]) translate([bulk_r_out - leg_boss_d/2 - 1, 0, -0.01])
                if ($preview)                     // plain hole in PREVIEW (fast); real thread on EXPORT (F6)
                    cylinder(d = leg_thread_minor, h = leg_socket_h + 1, $fn = 40);
                else
                    thread_hole(leg_thread_d, leg_thread_p, (leg_socket_h - 1) / leg_thread_p);
        for (a = [30, 90, 150, 210, 270, 330])    // 6 relief slots → the spigot flexes as it snaps in
            rotate([0, 0, a]) translate([snap_ir - 0.5, -0.7, base_deck_z - 0.01])
                cube([(snap_or + snap_bead + 1) - (snap_ir - 0.5), 1.4, snap_h + 1]);
        base_niche();
    }
}
// PART 2 — CORE DISC (z43..48): the motor bolts to its UNDERSIDE (face z43), the housing
// seats on top (z48); housing-seat tube + stacking lip grow up. The shroud snaps into a
// recess in its underside. PRINTS disc-on-the-bed (the z43 motor face on the bed).
module base_hopper() {
    difference() {
        union() {
            translate([0, 0, base_deck_z]) cylinder(d = bulk_d, h = motor_mount_t, $fn = 160);   // core disc z43..48
            difference() {                          // housing-seat tube z48..85 + stacking lip
                union() {
                    translate([0, 0, base_motor_h]) cylinder(d = bulk_d, h = base_h - base_motor_h, $fn = 160);
                    stacking_lip(base_h);
                }
                translate([0, 0, base_motor_h - 1]) cylinder(r = bulk_r_in, h = base_h - base_motor_h + 1 - cavity_taper_h + 1);
                translate([0, 0, base_h - cavity_taper_h]) cylinder(r1 = bulk_r_in, r2 = lip_ir, h = cavity_taper_h + 0.01);
            }
            translate([0, 0, base_motor_h]) rotate([0, 0, base_outlet_angle])   // housing key collar (into housing outlet)
                translate([base_mid_r, 0, 0]) rounded_rect(ar_ox, ar_oy, hole_corner_r, ar_h);
        }
        // motor mount on the UNDERSIDE (z43 face): pilot recess, 4× M3, shaft hole
        translate([0, 0, base_deck_z - 1]) cylinder(d = nema_shaft_d + 3, h = motor_mount_t + 2);  // shaft Ø8 through
        translate([0, 0, base_deck_z])     cylinder(d = nema_pilot_d + 1, h = 3);                  // pilot recess (z43, opens down)
        for (sx = [-1, 1]) for (sy = [-1, 1])     // 4× M3 (motor bolts up from below)
            translate([sx*nema_bolt_sq/2, sy*nema_bolt_sq/2, base_deck_z - 1]) cylinder(d = nema_bolt_d, h = motor_mount_t + 2);
        rotate([0, 0, base_outlet_angle]) translate([base_mid_r, 0, base_deck_z - 1])    // food outlet through the disc
            rounded_rect(ar_bx, ar_by, hole_corner_r, motor_mount_t + ar_h + 2);
        // SNAP recess (annular) in the disc underside + bead groove + −X key slot
        translate([0, 0, base_deck_z - 0.01])     // recess receiving the spigot (keeps the disc centre solid)
            difference() {
                cylinder(r = snap_or + snap_slip, h = snap_h + 0.6, $fn = 160);
                translate([0, 0, -1]) cylinder(r = snap_ir - snap_slip, h = snap_h + 2.6, $fn = 160);
            }
        translate([0, 0, base_deck_z + snap_h - 1.7])   // bead groove (undercut on the recess outer wall)
            difference() {
                cylinder(r = snap_or + snap_bead + snap_slip, h = 1.2, $fn = 160);
                translate([0, 0, -1]) cylinder(r = snap_or + snap_slip, h = 3.2, $fn = 160);
            }
        base_keybar(base_deck_z - 0.01, base_deck_z + snap_h, snap_or - 1 - snap_slip, snap_or + snap_bead + snap_slip + 1, snap_slip);  // −X key slot
        base_niche();
    }
}
// assembly view — the 2 snapped parts in place (used by the full/chassis renders)
module base() { base_motor(); base_hopper(); }

// ===========================================================================
// BOWL PLATFORM  separate part — holds the Ø175 bowl, bolted to the load cell's
// LOAD end at the back; free-floating otherwise so the bowl weight goes only
// through the cell (HX711). Without a cell, bolt the same holes straight to the
// base boss (rigid, same look).
// ===========================================================================
module bowl_platform() {
    rotate([0, 0, base_outlet_angle]) difference() {
        union() {
            translate([bowl_cx, 0, plat_z])                       // tray + low rim
                difference() {
                    cylinder(d = plat_d, h = 8, $fn = 120);
                    translate([0, 0, plat_t]) cylinder(d = plat_d - 6, h = 9, $fn = 120);
                }
            for (hx = [lc_load1, lc_load2])                       // 2 mount bosses to the load end
                translate([hx, 0, lc_z + lc_h])
                    cylinder(d = 11, h = plat_z - (lc_z + lc_h) + plat_t);
        }
        for (hx = [lc_load1, lc_load2])                           // bolt holes
            translate([hx, 0, lc_z + lc_h - 1]) cylinder(d = lc_hole_d, h = plat_z + 4);
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
    // Pocket holds only the NECK (the wide foot is inner-only, inside the body),
    // so this stays as narrow as before → the already-printed funnel still fits.
    chan_w = sp_leg_t + 2 * sp_slip;
    slot_w = chan_w + 2 * sp_wall_t;                        // floor/walls footprint
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
                sp_wedge(i, chan_w);
                translate([-200, -200, sp_rest_z]) cube([400, 400, sp_wall_h + 30]);
            }
        }
}

// --- modular spider: pear/dome body + detachable inverted-T legs ------------
// Inverted-T (dovetail) RAIL for leg i, as placed: a wide FOOT along the bottom
// + a narrow NECK on top, a radial prism from x0 (inner) to x1 (outer). `extra`
// grows every dimension (0 for the leg rail itself; +sp_slip for the body
// T-groove). Sliding the leg radially into the groove captures it vertically —
// the foot can't lift out through the narrower neck slot. `htop` caps the neck
// height (sp_key_h for the leg; a touch more for the groove so the slot is open
// to the socket roof).
module sp_trail(i, x0, x1, extra, htop) {
    nhw = sp_leg_t / 2 + extra;                          // neck half-width
    fhw = sp_leg_t / 2 + sp_foot_flare + extra;          // foot half-width
    fh  = sp_foot_h + (extra > 0 ? sp_stop_vslip : 0);   // groove foot chamber a bit taller
    translate([sp_body_cx, 0, 0]) rotate([0, 0, i * 360 / sp_leg_n + sp_leg_phase]) {  // body groove at −27
        translate([x0, -fhw, sp_rest_z])        cube([x1 - x0, 2 * fhw, fh]);          // foot
        translate([x0, -nhw, sp_rest_z + sp_foot_h]) cube([x1 - x0, 2 * nhw, htop - sp_foot_h]); // neck
    }
}
// A plain radial bar for leg i from an explicit centre cx (X radial from cx,
// half-width hw tangential, z0..z0+h).
module sp_bar_at(cx, i, x0, x1, hw, z0, h) {
    translate([cx, 0, 0]) rotate([0, 0, i * 360 / sp_leg_n + sp_leg_phase])
        translate([x0, -hw, z0]) cube([x1 - x0, 2 * hw, h]);
}
// Bar from the POCKET centre (sp_cx = −15) — the cone-facing default.
module sp_bar(i, x0, x1, hw, z0, h) sp_bar_at(sp_cx, i, x0, x1, hw, z0, h);
// Body: a rounded pear (no flat tops → sheds kibble), flat base at the rest
// plane, with 3 radial sockets the leg blades slide into + detent dimples.
module spider_body() {
    difference() {
        intersection() {
            // hub_top = local z where the HUB cylinder ends and the cap begins.
            // Roofed build raises it sp_roof_gap above the leg neck so the solid
            // roof (and the slicer's top layers under it) sit clear of the leg.
            let (hub_top = sp_key_h + (sp_socket_through ? 0 : sp_roof_gap))
            translate([sp_body_cx, 0, sp_rest_z]) union() {   // body hub at −27 (over the exit)
                // straight HUB cylinder: extends sp_body_floor BELOW the rest plane
                // (solid floor under the foot chamber → the foot can't drop out) and
                // up to hub_top → constant-depth sockets.
                translate([0, 0, -sp_body_floor])
                    cylinder(r = sp_body_base_r, h = sp_body_floor + hub_top, $fn = 72);
                // cap ABOVE the sockets (kibble-shedding). ROOFED build uses a DOME
                // (vertical at its base → minimal slicer top-fill above the socket
                // roof); open-top build keeps the gentle cone (slot runs through it).
                translate([0, 0, hub_top])
                    if (sp_socket_through)
                        hull() {                               // stem → wide bulb → rounded top
                            cylinder(r = sp_body_base_r, h = 0.01, $fn = 72);
                            translate([0, 0, sp_bulb_rise]) cylinder(r = sp_body_bulb_r, h = 0.01, $fn = 72);
                            translate([0, 0, sp_cap_h - sp_cap_tip_r]) sphere(sp_cap_tip_r, $fn = 48);
                        }
                    else
                        intersection() {                       // hemisphere dome (steep base)
                            sphere(sp_body_base_r, $fn = 72);
                            cylinder(r = sp_body_base_r + 1, h = sp_body_base_r, $fn = 72);
                        }
            }
        }
        // 3 inverted-T grooves. The neck slot runs ALL THE WAY THROUGH THE CAP
        // (open top) — NOT capped at sp_key_h — so the slicer doesn't see a roofed
        // pocket and fill it with top/solid infill (that was closing the socket in
        // the gcode from ~5 mm below the cap). The capture is the foot under the
        // shoulders (z≈28), independent of the top, so an open top is fine. The
        // foot chamber + shoulders still capture the leg foot vertically.
        for (i = [0 : sp_leg_n - 1])
            sp_trail(i, sp_body_base_r - sp_sock_depth - sp_groove_ext, 400, sp_slip,
                     sp_socket_through ? sp_key_h + sp_cap_h + 2   // through the cap (open)
                                       : sp_key_h + sp_roof_gap);  // roofed, clear of the leg
        // ROOFED build: vent each slot's inner DEAD-END straight up through the
        // dome with a small hole, so it's not a closed pocket — the slicer was
        // filling that dead-end with solid infill ~6 mm down from any roof,
        // eating the slot depth right above the leg. The vent keeps the slot full
        // to the roof; the dome stays closed apart from 3 small central holes.
        if (!sp_socket_through)
            for (i = [0 : sp_leg_n - 1])
                translate([sp_body_cx, 0, 0]) rotate([0, 0, i * 360 / sp_leg_n + sp_leg_phase])
                    translate([sp_body_base_r - sp_sock_depth + 1, 0, sp_rest_z - 1])
                        cylinder(r = 1.4, h = sp_key_h + sp_cap_h + 40, $fn = 24);  // r<neck/2 → clear of the leg
    }
}
// One leg as placed in the funnel: a STRAIGHT radial blade from the body socket
// (inner, captured foot) out into the wall pocket (neck, clipped at the cone wall).
// Pocket, foot and body all share sp_cx = −27, so no dogleg — the spider sits over
// the exit and the legs come out 1-long-2-short on the asymmetric wall.
module spider_leg_placed(i) {
    inner   = sp_body_base_r - sp_sock_depth;          // inner stop radius
    foot_x1 = inner + sp_sock_depth + 4;               // foot = the captured in-body part
    intersection() {
        union() {
            // NECK blade (rest → key_h): narrow, rests in the wall pocket
            sp_bar(i, inner, inner + 70, sp_leg_t / 2, sp_rest_z, sp_key_h);
            // FOOT (wide lip), inner-only → inverted-T captured by the body shoulders
            sp_bar(i, inner, foot_x1, sp_leg_t / 2 + sp_foot_flare, sp_rest_z, sp_foot_h);
        }
        // clip the outer end vertically at the cone wall on the rest plane → vertical
        // edge, no overhang; the pocket floor + walls catch it at z = rest.
        translate([0, 0, sp_rest_z - 1])
            linear_extrude(height = sp_key_h + 2)
                projection(cut = true) translate([0, 0, -sp_rest_z]) cav(sp_slip);
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
// All 3 legs laid out on the bed. Spacing 32: the DOGLEG legs are ~14 mm wide
// (the bent ones splay sideways) and legs 1 & 2 bend toward each other, so the
// old sp_key_h+6 (=20) overlapped them into one blob. 32 leaves a clear gap.
module spider_legs() {
    for (i = [0 : sp_leg_n - 1])
        translate([0, i * 32, 0]) spider_leg_flat(i);
}

// Assembled spider (body + 3 legs) in funnel-local coordinates.
module spider() {
    spider_body();
    for (i = [0 : sp_leg_n - 1]) spider_leg_placed(i);
}

// ===========================================================================
// RENDER
// ===========================================================================
if (part == "funnel")   funnel();      // assembly view of the 3 parts together
if (part == "shell")    funnel_shell();// PRINT: Ø160 outer tube + stacking lip (0% infill, clean)
if (part == "cone")     funnel_cone();   // PRINT: cone insert + spider pockets. NATIVE 0°
                                       // for the tilted printer (flipped 180° from the
                                       // earlier rotate on 2026-06-22 — matches housing).
if (part == "cap")      cap_plate();   // PRINT: separate solid cap disc (nests on housing)
if (part == "ring")     ring();
if (part == "lid")      lid();
if (part == "base")        base();                       // assembly preview (2 snapped parts)
if (part == "base_motor")  base_motor();                 // PRINT: leg shroud, standing
if (part == "base_hopper") base_hopper();                // PRINT: core disc, disc-on-the-bed
if (part == "base_cut")                                  // DEBUG: vertical half-cut, colour-coded
    intersection() {
        union() {
            color("Tomato")    base_motor();
            color("Gold")      base_hopper();
        }
        translate([-200, 0, -10]) cube([400, 200, 300]);
    }
// crude NEMA17 stand-in for assembly guides: Ø42 body + pilot boss + Ø5 shaft,
// placed so the mount face is at z (body hangs below, shaft pokes up).
module motor_mock(face_z) translate([0, 0, face_z]) {
    color("#2c2c2c") translate([-21.15, -21.15, -nema_len]) cube([42.3, 42.3, nema_len]);
    color("#444")    translate([0, 0, -0.1]) cylinder(d = nema_pilot_d, h = 2.5, $fn = 40);
    color("Silver")  cylinder(d = nema_shaft_d, h = 24, $fn = 24);
}
if (part == "x_base") {        // EXPLODED base sub-assembly (assembly guide)
    color("DimGray")   translate([0, 0, -40]) legs_mounted();   // 4 legs, screw up from below
    motor_mock(base_deck_z - 70);                                // motor, inserts UP from below
    color("Tomato")    base_motor();                            // leg shroud (legs + motor cavity)
    color("Gold")      translate([0, 0, 45]) base_hopper();     // core disc (motor under, housing over)
}
if (part == "x_tower") {       // EXPLODED full tower (assembly guide)
    e = 40;
    color("Gainsboro")            base();
    color("DimGray")              translate([0, 0, -34]) legs_mounted();
    color("LightSteelBlue")       translate([0, 0, base_motor_h + e]) housing();
    color("Silver")               translate([throat_cx, 0, base_motor_h + 3.5 + e]) wheel();
    color("Khaki")                translate([0, 0, base_h + 2*e]) funnel();
    color("BurlyWood")            translate([0, 0, base_h + z_funnel_top + 3*e]) ring();
    color("Tan")                  translate([0, 0, base_h + z_funnel_top + ring_h + 4*e]) lid();
    color("Wheat")                translate([0, 0, 1.2*e]) { wp_foot(); wp_tray(); }
    color("LightBlue", 0.5)       translate([0, 0, 1.2*e]) bowl_mock();
}
if (part == "x_funnel") {      // EXPLODED funnel sub-assembly (assembly guide)
    e = 55;
    color("Khaki", 0.30)    funnel_shell();                             // Ø160 outer tube (see-through)
    color("Orange")         translate([0, 0, cap_t + 1.2*e]) funnel_cone();  // mass-flow cone insert
    color("Crimson")        translate([0, 0, cap_t + 2.1*e]) spider();        // anti-pressure spider (into cone)
    color("MediumSeaGreen") translate([0, 0, -0.7*e]) cap_plate();      // cap — nests on the housing top
}
if (part == "full" || part == "full_norings") {
    // whole product: tower (base+housing+wheel+funnel[+ring+lid]) on screw-in legs
    // + standalone weighing platform (foot+cell+tray) + bowl, under the food drop.
    color("Gainsboro")            base();
    color("DimGray")              legs_mounted();
    color("LightSteelBlue", 0.45) translate([0, 0, base_motor_h]) housing();   // hidden inside
    color("Silver")               translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
    color("Khaki")                translate([0, 0, base_h]) funnel();
    if (part == "full") {
        color("BurlyWood")        translate([0, 0, base_h + z_funnel_top]) ring();
        color("Tan")              translate([0, 0, base_h + z_funnel_top + ring_h]) lid();
    } else {
        color("BurlyWood")        translate([0, 0, base_h + z_funnel_top]) lid();   // lid straight on funnel
    }
    color("Sienna")               wp_foot();
    color("DimGray") rotate([0, 0, base_outlet_angle]) translate([22, -lc_w/2, wp_cell_z]) cube([lc_l, lc_w, lc_h]);
    color("Wheat")                wp_tray();
    color("LightBlue", 0.4)       bowl_mock();
}
if (part == "full_cut") {
    difference() {
        union() {
            color("Gainsboro")            base();
            color("DimGray")              legs_mounted();
            color("LightSteelBlue")       translate([0, 0, base_motor_h]) housing();
            color("Silver")               translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
            color("Khaki")                translate([0, 0, base_h]) funnel();
            color("Tan")                  translate([0, 0, base_h + z_funnel_top]) lid();
            color("Wheat")                wp_tray();
            color("LightBlue", 0.5)       bowl_mock();
        }
        translate([-400, -500, -200]) cube([900, 500, 900]);   // remove y < 0
    }
}
if (part == "chassis") {
    // full lower stack: base + housing (on the rest-plate) + funnel (cap nests
    // on the housing top). Shows the Ø160 silhouette hiding the housing + the
    // front chute. Wheel + axle included for the food-path sanity check.
    color("Gainsboro")            base();
    color("LightBlue", 0.85)      translate([0, 0, base_motor_h]) housing();
    color("Silver")               translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
    color("Khaki", 0.45)          translate([0, 0, base_h]) funnel();
}
// PRINTABLE coarse MALE thread. Built by sweeping the r-z tooth profile HELICALLY
// (a stack of small rotate_extrude arcs), NOT a twisted thin fin. Printed
// AXIS-VERTICAL, the overhanging LOWER flank is ~38° from vertical (well under
// 45°), so it needs no supports. The leg self-taps this into a plain base hole.
//   profile (r,z) over one pitch: root → 45°-ish lower flank up to the Ø12 crest
//   → small crest flat → upper flank back to root (upper flank faces up = free).
module printable_thread(maj_d, pitch, turns) {
    maj    = maj_d / 2;
    depth  = leg_thread_depth;
    root   = maj - depth;
    lflank = depth * 1.3;            // lower-flank z-rise → atan(depth/lflank)=37.6° overhang
    crest  = 0.5;
    seg    = 20;                      // helix slices per turn
    H      = pitch * turns;
    n      = ceil((turns + 1) * seg);
    union() {
        cylinder(r = root + 0.1, h = H, $fn = 48);                              // core
        intersection() {                                                        // clip helix to 0..H
            union() {
                for (i = [0 : n - 1])
                    rotate([0, 0, i * 360/seg]) translate([0, 0, i * pitch/seg - pitch])
                        rotate_extrude(angle = 360/seg + 1.5, $fn = 72)
                            polygon([[root - 0.8, 0], [maj, lflank], [maj, lflank + crest], [root - 0.8, pitch]]);
            }
            cylinder(r = maj + 1, h = H, $fn = 48);
        }
    }
}
// FEMALE thread tool — subtract from a boss to cut a threaded hole. Same profile as
// the leg's male thread but radially oversized by leg_thread_slip so it screws in.
module thread_hole(maj_d, pitch, turns)
    printable_thread(maj_d + 2 * leg_thread_slip, pitch, turns);
// SCREW-IN leg: a foot + the printable male thread on top that screws UP into the
// base's FEMALE-threaded socket (thread_hole). Print foot-down / thread-up.
module leg() {
    foot_d = leg_boss_d + 6;
    union() {
        cylinder(d1 = foot_d, d2 = foot_d - 5, h = leg_h, $fn = 48);   // foot (slight taper)
        translate([0, 0, leg_h - 1.5])                                  // overlap into the foot
            printable_thread(leg_thread_d, leg_thread_p, (leg_socket_h - 1) / leg_thread_p);
    }
}
// the 4 legs as screwed into the base (for assembly views): thread up into the
// socket, foot below. Placed at the socket angles/radius.
module legs_mounted() {
    for (a = [60, 135, 225, 300])
        rotate([0, 0, a]) translate([bulk_r_out - leg_boss_d/2 - 1, 0, 0])
            translate([0, 0, -leg_h]) leg();
}
// Standalone WEIGHING PLATFORM (independent of the tower): a bar load cell
// cantilever — fixed end on a back FOOT on the table, load end carries the bowl
// TRAY; the bowl weight deflects the cell (HX711). Sits under the food drop.
wp_cell_z = -leg_h + 4;                 // cell bottom (on the back foot)
wp_tray_z = wp_cell_z + lc_h + 1;       // tray underside (above the cell, deflection gap)
module wp_foot() {                       // PRINT: back foot, anchors the cell fixed end
    difference() {
        translate([18, -16, -leg_h]) cube([28, 32, wp_cell_z + leg_h]);
        for (hx = [25, 38]) translate([hx, 0, -leg_h - 1]) cylinder(d = lc_hole_d, h = leg_h + 6, $fn = 24);
    }
}
module wp_tray() {                        // PRINT: bowl tray on the cell LOAD end
    rotate([0, 0, base_outlet_angle]) difference() {
        union() {
            translate([bowl_cx, 0, wp_tray_z])                       // tray + low rim
                difference() {
                    cylinder(d = plat_d, h = 8, $fn = 120);
                    translate([0, 0, plat_t]) cylinder(d = plat_d - 6, h = 9, $fn = 120);
                }
            for (hx = [82, 94]) translate([hx, 0, wp_cell_z + lc_h])  // bolt bosses to the load end
                cylinder(d = 11, h = wp_tray_z - (wp_cell_z + lc_h) + plat_t);
        }
        for (hx = [82, 94]) translate([hx, 0, wp_cell_z + lc_h - 1]) cylinder(d = lc_hole_d, h = 12, $fn = 24);
    }
}
module bowl_mock() {
    rotate([0, 0, base_outlet_angle]) translate([bowl_cx, 0, wp_tray_z + plat_t])
        difference() {
            cylinder(d1 = bowl_d - 34, d2 = bowl_d, h = bowl_h, $fn = 120);
            translate([0, 0, 3]) cylinder(d1 = bowl_d - 40, d2 = bowl_d - 6, h = bowl_h, $fn = 120);
        }
}
if (part == "leg")      leg();          // PRINT: one screw-in leg (thread up)
if (part == "wp_foot")  wp_foot();      // PRINT: weighing-platform back foot
if (part == "wp_tray")  wp_tray();      // PRINT: weighing-platform bowl tray
if (part == "station") {
    // tower on SCREW-IN LEGS + standalone WEIGHING PLATFORM (foot + cell + tray)
    // under the front; food drops STRAIGHT DOWN the open niche into the bowl.
    color("Gainsboro")        base();
    color("DimGray")          legs_mounted();
    color("Tan")              wp_foot();
    color("DimGray") rotate([0, 0, base_outlet_angle])           // load cell (mock)
                              translate([22, -lc_w/2, wp_cell_z]) cube([lc_l, lc_w, lc_h]);
    color("Khaki")            wp_tray();
    color("LightBlue", 0.4)   bowl_mock();
}
if (part == "station_cut") {
    difference() {
        union() {
            color("Gainsboro")      base();
            color("Silver")         translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
            color("LightBlue", 0.5) bowl_mock();
        }
        translate([-300, -400, -300]) cube([800, 400, 700]);   // remove y < 0 (see the drop on +X)
    }
}
if (part == "chassis_cut") {
    difference() {
        union() {
            color("Gainsboro")        base();
            color("LightBlue", 0.9)   translate([0, 0, base_motor_h]) housing();
            color("Silver")           translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
            color("Khaki", 0.5)       translate([0, 0, base_h]) funnel();
        }
        translate([-200, -400, -300]) cube([400, 400, 700]);   // remove y < 0
    }
}
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
if (part == "spider_hsec")   // DEBUG: horizontal slab at the SNAP plane (top view)
    intersection() {
        translate([-sp_cx, 0, -sp_rest_z]) spider();
        translate([-200, -200, sp_foot_h / 2 - 0.6]) cube([400, 400, 1.2]);
    }
if (part == "spider_tsec")   // DEBUG: Y-Z cross-slab through leg-0 inside the body
    intersection() {         //        → see the foot captured UNDER the body shoulders
        translate([-sp_cx, 0, -sp_rest_z]) spider();
        translate([10, -50, -50]) cube([1.5, 100, 100]);
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
            translate([-200, -200, sp_seat_z - 2]) cube([400, 400, sp_key_h + sp_cap_h]);
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
if (part == "nest_check") {
    // verify the housing top WALL seats in the funnel cap-plate GROOVE (vertical
    // half-cut). pw_housing_h = paddle_wheel housing_h (end_wall+floor_clear+
    // wheel_thickness+wheel_axial_clear+housing_buffer_h = 3+0.5+18+0.5+15).
    pw_housing_h = 37;
    difference() {
        union() {
            color("LightBlue")  housing();
            color("Tomato")     translate([0, 0, pw_housing_h]) cap_plate();
        }
        translate([-200, -400, -250]) cube([400, 400, 500]);   // remove y < 0
    }
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
