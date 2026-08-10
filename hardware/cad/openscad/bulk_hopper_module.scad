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
step = 9;            // for part="step": 0..9, cumulative assembly (see the step dispatch)

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
// 150, NOT 170: the ring also grows a stacking_lip (joint_lip_h = 10) on top, so the
// printed part is ring_h + 10. At 170 that is exactly 180 mm = the full bed height,
// with zero margin for brim/first-layer → it does not print. 150 → 160 mm printed
// (20 mm margin). Rings are modular: print one extra ring to recover the old volume.
ring_h          = 150;  // height per ring; stack as needed

/* [Lid] */
// 2 mm = exactly bottom_shell_layers(4) + top_shell_layers(6) at 0.2 mm — i.e. the lid is
// pure shell, no wasted infill core (user). The finger grooves are no longer buried inside a
// thick disc: they EMBOSS, bulging into the lid's inside. That space is over the jar mouth
// and unused, so it costs nothing and saves a lot of plastic and time.
lid_disc_h      = 2;
lid_wall        = 2;       // wall thickness of the embossed groove
// L2 — the lid opens AND lifts by two finger scallops (no knob). Deep enough that a
// fingertip drops in and hooks the far wall to pull the lid up one-handed. On r30, NOT
// r50: diametrically opposite on r30 = 60 mm apart = a thumb+finger pinch a hand can
// span. r50 would be 100 mm apart — impossible to pinch one-handed. 30 mm is still ample
// leverage for the ¼-turn unlock. On the ±Y axis (tangential = the unlock direction).
lid_grip        = true;
lid_grip_r      = 30;      // pinch-spannable one-handed (60 mm apart)
lid_grip_n      = 2;
// GROOVE grips, not round coins. A plain cone let the fingertip slide straight back out —
// nothing to pull against. The groove has three zones up its depth (see lid()):
//   1. UNDERCUT: walls splay OUTWARD by lid_grip_uc per side going deeper, so the mouth is
//      narrower than the belly and the finger HOOKS instead of sliding. Printed flipped this
//      is an overhang of only ~11° from vertical (1 mm over 5 mm) — well inside the 45°
//      self-supporting limit, so no support and no droop. Even 1 mm of catch is enough.
//   2. ROOF at 45°: closes itself as it climbs, so nothing bridges the full width.
//   3. a small Ø-lid_grip_tip apex left over, which bridges trivially.
// Elongated (not round) so a whole fingertip lies in it, and laid tangentially so pushing
// sideways on the wall is exactly the ¼-turn unlock direction.
lid_grip_w      = 13;      // mouth width at the disc face
lid_grip_uc     = 1;       // undercut per side — the "catch"
lid_grip_uc_h   = 5;       // height over which it splays (1 mm / 5 mm = 11° from vertical)
lid_grip_roof_h = 5;       // 45° roof: (w+2*uc - tip)/2 == roof_h
lid_grip_tip    = 5;       // leftover apex, bridges trivially
lid_grip_len    = 36;      // groove length — a whole fingertip
lid_grip_depth  = lid_grip_uc_h + lid_grip_roof_h;   // 10 → disc 12 keeps a 2 mm floor

/* [Stacking joint] */
joint_lip_h     = 10;
join_clear      = 0.3;

/* [Cap hole — MUST match paddle_wheel_module.scad] */
// Bulk hopper bottom opens directly to this rectangular hole. No spout
// in between (the old spout cube is gone in this revision).
// The outlet is the kibble pipe's narrowest point, so hole_len (= out − in) sets the
// flow. It is squeezed from FOUR sides — every one of these was hit at least once:
//   in  > motor r21              (or food lands on the motor)
//   in  > bowl back rim          (or food drops behind the bowl, onto the tray)
//   out < paddle rim ring 38.5   (or the sweeping tip crosses a hole edge and catches)
//   the rounded-rect CORNER (hypot(out−2, hole_w/2−2)+2) < hr_in 40.8, or the outlet
//     breaks through the housing wall — this is why out=38 is NOT allowed (corner 41.0).
// 2026-07-13: in 25→23, out 35→36 together with bowl_cx 112→108. B2 had pushed `in` to 25
// to clear the bowl rim, which collapsed hole_len to 10 → the disc bore ar_bx fell to
// 7.1 mm and kibble jammed on the disc shoulder. Moving the bowl in frees `in` again.
// Now: hole_len 13, ar_bx 10.1 (the pre-B2 value). Margins: housing wall 1.6, wheel rim
// 2.5, motor 2.0, bowl rim 2.5 — nothing under 1.5 mm.
// MUST MATCH hole_radial_in / _out / _w / _corner_r in paddle_wheel_module.scad.
hole_radial_in   = 22;   // 7 → 22 (clear motor) → 25 (B2, clear bowl) → 23 → 22 (widen slit; band 3.5 on tray ramp, motor clr 2.3)
hole_radial_out  = 37;   // 40 → 35 (keep the paddle tip off the hole edge) → 36 → 37 (widen slit; 37 = documented ceiling, corner 40.1<40.8)
hole_w           = 34;   // tangential — FROZEN: feeds cone_top_z only (do NOT retune to widen the outlet)
outlet_w         = 44;   // tangential OUTLET opening (arc-capped). Decoupled from hole_w so the
                         //   food aperture can widen (34→44) WITHOUT moving cone_top_z / unfreezing
                         //   the cone. The arc cap (outer edge on a constant-r circle) keeps every
                         //   point ≤ hole_radial_out=37 → 1.5 mm under the paddle rim ring (38.5),
                         //   3.8 mm under the housing bore (40.8). MUST MATCH outlet_w in paddle_wheel.
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

// 45° bevel on the Ø160 BOTTOM-OUTER edge. On the bottom part it is the foot chamfer
// (lifts the full-Ø edge off the bed → kills elephant-foot); at every stack joint the
// upper part's bevel opens a clean shadow-line reveal over the flush part below, so the
// real parting line reads as an intended groove. 45° face = self-supporting standing.
// Cuts only r∈[bulk_r_out−foot_cham, bulk_r_out] (78..80) → never touches bore/lip (≤76.7).
foot_cham      = 2;
// top=false → bevels the BOTTOM-outer edge (foot / stack-seam reveal, self-supporting
// standing). top=true → mirrors it onto the TOP-outer edge, for a part that prints
// FLIPPED (the lid: crown on the bed → the crown edge is first-layer = support-free).
module seam_bevel(z0, top = false)
    translate([0, 0, z0])
        rotate_extrude($fn = 160)
            polygon(top
                ? [[bulk_r_out - foot_cham,  0.02],
                   [bulk_r_out + 1,          0.02],
                   [bulk_r_out + 1,         -foot_cham],
                   [bulk_r_out,             -foot_cham]]
                : [[bulk_r_out - foot_cham, -0.02],
                   [bulk_r_out + 1,         -0.02],
                   [bulk_r_out + 1,          foot_cham],
                   [bulk_r_out,              foot_cham]]);

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

// ---- J2 BAYONET ----------------------------------------------------------------
// The base's stacking lip spans z_base .. z_base+joint_lip_h, outer radius lip_or. The
// shell's bore (bulk_r_in) drops over it. The tabs live on the shell bore and engage
// slots cut into that lip's OUTER face. (bay_tab_ir / bay_tab_ang / bay_seg are DERIVED
// down in the [Self-locking joints] block, AFTER the bay_* params they depend on — they
// were up here once and evaluated to undef, which made rotate_extrude draw a FULL RING
// instead of a tab.)
// One tab, as it sits on the shell bore (shell-local z; shell bottom = 0). A single
// rotate_extrude of a (r,z) trapezoid: full depth to bulk_r_in at the top, a 45° lead-in
// on the underside (bay_lead) so a STANDING print never bridges it. NO hull() — hull of
// two arcs left tessellation crumbs that read as a collision. The SLOT is widened by a
// whole facet each side (bay_seg) so the tab clears it despite coarse arc facets.
module bay_tab(i)
    rotate([0, 0, i * 360/bay_n])
        rotate_extrude(angle = bay_tab_ang, $fn = 160)
            polygon([[bulk_r_in,  bay_tab_z],                  // outer edge starts at the floor
                     [bulk_r_in,  bay_tab_z + bay_tab_h],      // full-height outer
                     [bay_tab_ir, bay_tab_z + bay_tab_h],      // full-depth top
                     [bay_tab_ir, bay_tab_z + bay_lead]]);     // underside ramps 45° back out
// LID variant of the tab: identical footprint + L-engagement, but the 45° lead-in is on
// the TOP face instead of the bottom. The lid prints UPSIDE-DOWN (disc on the bed, skirt
// up), so the tab's bed-facing overhang is its MODEL-TOP face — the ramp must live there
// or it bridges. Everything else (radius, angle, slot, detent) is shared, not duplicated.
module bay_tab_lid(i)
    rotate([0, 0, i * 360/bay_n])
        rotate_extrude(angle = bay_tab_ang, $fn = 160)
            polygon([[bulk_r_in,  bay_tab_z],
                     [bulk_r_in,  bay_tab_z + bay_tab_h],
                     [bay_tab_ir, bay_tab_z + bay_tab_h - bay_lead],   // TOP face ramps 45°
                     [bay_tab_ir, bay_tab_z]]);
// The matching L-slot, cut into the lip at global z_base. Vertical channel runs the FULL
// lip height (the tab has to travel down past all of it), then an L-run at the bottom.
module bay_slot(i, z_base) {
    zr0 = z_base + bay_tab_z - bay_slip;            // run floor
    zr1 = z_base + bay_tab_z + bay_tab_h + bay_slip; // run ceiling
    r0  = bay_tab_ir - bay_slip;
    r1  = lip_or + 1;                               // out through the lip's outer face
    // widen the slot by a whole facet each side so the coarsely-facetted tab clears it
    rotate([0, 0, i * 360/bay_n - bay_seg]) {
        rotate_extrude(angle = bay_tab_ang + 2*bay_seg, $fn = 160)   // vertical entry channel
            translate([r0, zr0]) square([r1 - r0, joint_lip_h + 2]);
        rotate([0, 0, -bay_run])                    // L-run: twist CW to lock
            rotate_extrude(angle = bay_tab_ang + 2*bay_seg + bay_run, $fn = 160)
                translate([r0, zr0]) square([r1 - r0, zr1 - zr0]);
    }
}
// Detent left standing in the run: the tab must ride over it, so the tower will not
// unscrew itself. Sits just inside the run's far (locked) end.
module bay_detent(i, z_base)
    rotate([0, 0, i * 360/bay_n - bay_run + 1.5])
        rotate_extrude(angle = 3, $fn = 160)
            translate([bay_tab_ir - bay_slip, z_base + bay_tab_z - bay_slip])
                square([lip_or - (bay_tab_ir - bay_slip), bay_det]);

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
cone_clear   = 3;                            // (legacy) old loose gap, superseded below
cone_snug_clr = 0.4;                         // radial slip: cone top ↔ shell bore
// cap throat COLLAR — a raised rim the cone's throat plug drops into so the cap
// centres the cone + holds it against tipping (replaces the deleted shell ribs).
cap_reg_clear = 0.4;                         // slip: cone plug outer ↔ collar inner
cap_reg_wall  = 2;                           // collar wall thickness
cap_reg_h     = 8;                           // collar height = plug register depth
// 74 — one straight wall angle, stopping at the LOOSE containment gap above. A bortik ring
// used to flare the last 8 mm out to 76.6 to touch the bore: its inner edge sat at r73 while
// the cone there was only r67.3, so it began 5.7 mm OUT IN MID-AIR and printed into nothing
// (user saw it). Deleted — it was the same mistake as the ribs this design already removed
// for printing in air at the cone top, and it contradicted the 3-part scheme: the cone is
// located by the CAP, so its top must stay free of the shell, not snug against it.
// The cone reaches the SNUG radius on its own, in ONE straight wall. Any late flare — the
// old bortik, or the small lip I tried — jumps the radius several mm inside a single 0.2 mm
// layer (measured: r73.2 -> r76.4 between layers 404 and 405), and that ring prints in mid
// air. The cone falls away as it rises, so a widening feature at the top can never be
// supported; the only way to land on the bore is to aim there from the bottom.
// This costs the 3 mm air gap the old 3-part note describes, and gains the top location the
// cone otherwise lacks (it is still carried by the cap collar below).
cone_out_top = bulk_r_in - cone_snug_clr;    // 76.6 — lands on the bore, no add-on ring
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
        seam_bevel(0);   // reveal groove over the base_hopper↔funnel seam; also the funnel's foot on the bed
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

/* [Self-locking joints — no glue, no metal] ================================
   The lower stack (motor / wheel / housing / shroud / disc) was already positively
   located. The UPPER stack was a slippery gravity pile. These add the retention.

   J1 (wheel axial capture) NEEDED NO WORK — verified, do not "fix" it:
     the wheel's top is not the Ø20 hub (18 tall) but its central stirrer boss, which
     reaches local z29 → global 80.5. The cap underside is at 81.5. So the wheel is
     ALREADY captured with a 1.0 mm gap, and the contact face is the boss at r<10 —
     i.e. the narrow, low-friction land near the axis that a counterbore would have
     added. Shaft engagement is 15.5 mm; lifting the full 1.0 mm still leaves 14.5 mm.
     It cannot climb off the shaft.
*/
// J2 — BAYONET, shell → base (the critical one). The shell used to just rest its rim on
// the base with 0.3 mm of slip: lift the lid and the whole tower came with it. Now 3 tabs
// on the shell's inner bore ride down 3 full-height channels in the base's stacking lip,
// then twist ~20° into an L-run and click past a detent.
bay_n     = 3;      // tabs / slots
bay_tab_w = 8;      // tab width, tangential (mm at the lip radius)
bay_tab_h = 3;      // tab height (vertical)
bay_tab_r = 1.5;    // tab radial depth (protrudes inward from the shell bore)
bay_tab_z = 0.5;    // tab bottom, above the shell's bottom rim
bay_slip  = 0.35;   // slot ↔ tab clearance
bay_run   = 20;     // horizontal travel of the L (degrees)
bay_det   = 0.35;   // detent bump proud (rides over it → will not back off on its own)
bay_lead  = 1.5;    // 45° lead-in under the tab → prints support-free on the standing shell
bay_tab_ir  = bulk_r_in - bay_tab_r;                 // 75.5 — tab inner radius
bay_tab_ang = bay_tab_w / (bulk_r_in * PI / 180);    // 5.95 — tab angular width at the bore
bay_seg     = 360 / 160;                             // one $fn=160 facet (slot over-width)
// J3 — housing clicks onto the disc's anti-rotation collar (it was held down only by the
// weight of the tower above; pull the funnel and housing+cap fell out in your hand).
ar_bead   = 0.35;   // bead proud on the collar's outer walls → friction/snap into the
                    //   housing floor outlet. Small on purpose: it must not need a tool.
// J4 — the cap↔housing nest and the cone↔collar register were pure slip fits.
nest_det  = 0.4;    // detent in the cap's nest groove → clicks onto the housing top wall
cone_det  = 0.4;    // detent in the cap's throat collar → clicks onto the cone's plug
// J5 — the service panel could not fall OUT (it has a flange) but nothing stopped it
// falling IN. Two nibs on its side edges snap into dimples in the window reveal.
pan_nib   = 0.4;
// J6 — a shallow ring on the platform so the tray self-centres and does not shuffle when
// kibble lands (a shuffling tray corrupts the weight reading).
loc_h     = 1.2;    // locator ring height
loc_slip  = 0.5;    // ring ↔ tray outer clearance
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
        // J4 — DETENT RIDGE inside the throat collar: the cone's plug clicks past it, so
        // the cap+cone stay together in your hand before the shell goes over them.
        translate([0, 0, cap_t + cap_reg_h - 1.6]) linear_extrude(0.8)
            difference() {
                offset(cone_wall + cap_reg_clear)             throat_2d();
                offset(cone_wall + cap_reg_clear - cone_det)  throat_2d();
            }
        // J4 — DETENT LIP in the NEST groove (added AFTER the groove is cut, or the cut
        // would delete it): a thin ridge near the groove mouth that the housing's top
        // wall snaps past, so the cap stays on the housing while you handle it.
        translate([0, 0, nest_h - 1.4]) linear_extrude(0.7)
            difference() {
                offset(nest_clear)            teardrop_2d(pw_hr_out, pw_td_tip_r, pw_td_tip_cx);
                offset(nest_clear - nest_det) teardrop_2d(pw_hr_out, pw_td_tip_r, pw_td_tip_cx);
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
    // the shell). Print parts are all modelled at z0; the offsets here are VIEW-ONLY
    // and reproduce the real stack when funnel() is placed at base_h:
    //   shell  z0        — its rim rests on the base top rim (= housing top = base_h)
    //   cap   z-nest_h   — DROPS DOWN over the housing top wall, which enters the cap's
    //                      underside groove (depth nest_h). Was at z0 → the wall entered
    //                      0 mm, i.e. the cap sat on nothing and the joint did not key.
    //   cone  z(cap_t-nest_h) — RESTS ON THE CAP TOP (cap spans -nest_h .. cap_t-nest_h)
    //                      and its throat plug drops into the cap collar. Was at cap_t →
    //                      it floated nest_h above the cap.
    funnel_shell();
    translate([0, 0, -nest_h])          cap_plate();
    translate([0, 0, cap_t - nest_h])   funnel_cone();
}
// 3-part funnel — SHELL: the outer Ø160 tube + the stacking lip. A plain tube →
// slices perfectly (one wall, no void, no bottom disc).
module funnel_shell() {
    difference() {
        union() {
            shell_tube();
            stacking_lip(z_funnel_top);
            for (i = [0 : bay_n - 1]) bay_tab(i);                 // tabs (down) → base lip
            for (i = [0 : bay_n - 1]) bay_detent(i, z_funnel_top);// detents in the TOP lip → ring/lid
        }
        // L-slots in the TOP lip so a ring or the lid can bayonet straight onto the funnel
        for (i = [0 : bay_n - 1]) bay_slot(i, z_funnel_top);
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
    }
}
// Top BORTIK (rim): a flange at the cone top that flares out to the shell bore so
// the cone is located at the TOP too (was only held by the cap collar at the bottom
// + friction). Snug slide-fit (bort_clr to the Ø160 bore); the underside is a ~23°
// ramp so it prints support-free on the throat-down cone.
// No top lip and no bortik: both flared outward at the end and printed into air. The cone
// itself now ends at the bore radius (see cone_out_top), so its top rim IS the stop.

// cone_bortik() REMOVED (user, 2026-07). It was a ring that flared the cone's last 8 mm out
// to the snug radius — but its inner edge started at r73 where the cone was only r67.3, i.e.
// 5.7 mm out in mid-air, so the printer laid it into nothing. The cone now reaches the snug
// radius by itself in one straight 38.4° wall (see cone_out_top), so no add-on ring is needed.

// ===========================================================================
// STORAGE RING  modular section, stacks via top lip
// ===========================================================================
// BUGFIX 2026-07-02: the bore used to run the FULL height (ring_h + joint_lip_h + 2) at
// r = bulk_r_in. But lip_or = bulk_r_in - join_clear < bulk_r_in, so the bore swallowed
// the whole stacking lip — the ring printed as a bare tube and rings COULD NOT STACK.
// Now bored like shell_tube(): straight to (ring_h - cavity_taper_h), then a taper up to
// lip_ir so the lip's first layer lands on solid wall instead of printing in air.
module ring() {
    union() {
        difference() {
            union() {
                cylinder(h = ring_h, d = bulk_d);
                stacking_lip(ring_h);
                for (i = [0 : bay_n - 1]) bay_detent(i, ring_h);   // J2 — click for the lid/next tab
            }
            translate([0, 0, -1])
                cylinder(h = ring_h - cavity_taper_h + 1, r = bulk_r_in);
            translate([0, 0, ring_h - cavity_taper_h])
                cylinder(r1 = bulk_r_in, r2 = lip_ir, h = cavity_taper_h + 0.01);
            // J2 — L-slots in this ring's TOP lip so a lid (or the next shell's tabs) can
            // bayonet on. The channel is just a void; rings still slip-stack through it.
            for (i = [0 : bay_n - 1]) bay_slot(i, ring_h);
            seam_bevel(0);   // reveal groove over the seam below; also the ring's foot on the bed
        }
        // J2 — UNDERSIDE tabs, added AFTER the bore (like funnel_shell) so they survive it.
        // Without these a ring only slip-stacked; now it ¼-turn-locks into the bay_slot of
        // the base/funnel/ring lip below. 45° lead is on the tab underside → support-free
        // on the standing print. Outer edge = bulk_r_in, so they fuse to the bored wall.
        for (i = [0 : bay_n - 1]) bay_tab(i);
    }
}

// ===========================================================================
// LID  top cover — J2 BAYONET onto the ring/shell lip + finger-grip scallops.
// Modelled skirt-DOWN (disc on top) = the working pose on the jar. Prints UPSIDE-DOWN
// (see lid_print): disc on the bed, skirt up, scallops face the bed (shallow cavities in
// the first layers), tabs use bay_tab_lid (ramp on the model-top = bed face when flipped).
// ===========================================================================
// Finger-groove cut for the lid (see the [Lid] params). Built from two stacked hulls so it
// is an elongated slot, not a round hole: an UNDERCUT zone whose walls splay outward going
// deeper (the finger hooks on it), then a 45° roof that closes itself. Cut downward from
// face_z. Printed lid-flipped, the undercut is an ~11° overhang and the roof is self-
// supporting, so the whole grip needs no support and bridges only the small apex.
module lid_groove(face_z, sh = 0) {
    off   = (lid_grip_len - lid_grip_w) / 2;      // hull centres
    w     = lid_grip_w + 2 * sh;                  // mouth
    belly = lid_grip_w + 2 * lid_grip_uc + 2 * sh;
    tip   = max(0.5, lid_grip_tip + 2 * sh);
    // 1. undercut: mouth (narrow) at face_z, belly (wide) lid_grip_uc_h deeper
    hull() for (s = [-1, 1])
        translate([s * off, 0, face_z - lid_grip_uc_h])
            cylinder(d1 = belly, d2 = w, h = lid_grip_uc_h + 0.01, $fn = 40);
    // 2. roof: from the belly down to the small apex at 45°
    hull() for (s = [-1, 1])
        translate([s * off, 0, face_z - lid_grip_depth - sh])
            cylinder(d1 = tip, d2 = belly, h = lid_grip_roof_h + sh + 0.01, $fn = 40);
}

module lid() {
    skirt_h    = joint_lip_h + 4;                       // 14 — skirt must clear the full lip
    // bore = 2*bulk_r_in (= 2*(lip_or+join_clear)): the skirt slips over the lip with
    // join_clear, AND its inner face lands exactly on bulk_r_in so the bay_tab_lid tabs
    // (outer edge = bulk_r_in) FUSE to it. The old +2*join_clear left the tabs floating.
    skirt_id   = 2 * bulk_r_in;
    skirt_od   = bulk_d;
    top_z      = skirt_h + lid_disc_h;                  // outer disc face
    difference() {
        union() {
            difference() {
                union() {
                    translate([0, 0, skirt_h]) cylinder(h = lid_disc_h, d = bulk_d);   // disc
                    cylinder(h = skirt_h, d = skirt_od);                                // skirt
                }
                translate([0, 0, -1]) cylinder(h = skirt_h + 1, d = skirt_id);          // hollow skirt
            }
            for (i = [0 : bay_n - 1]) bay_tab_lid(i);   // J2 — fillet on the model-TOP = the bed face
            // when the lid prints FLIPPED (disc on the bed, skirt up). See lid_print.
            // Grip SHELL: the same groove grown by lid_wall, so after the groove itself is cut
            // below, a lid_wall-thick skin is left wrapping it. That skin bulges DOWN into the
            // lid's inside (over the jar mouth — unused space), instead of the groove being
            // buried in a thick disc. Lid stays a 2 mm shell: far less plastic and time.
            if (lid_grip)
                for (i = [0 : lid_grip_n - 1])
                    rotate([0, 0, 90 + i * 360/lid_grip_n])
                        translate([lid_grip_r, 0, 0]) rotate([0, 0, 90])
                            lid_groove(top_z, lid_wall);
        }
        // L2 — finger GROOVES: elongated, with an UNDERCUT so the fingertip hooks instead of
        // sliding out (a plain cone let it slip). Mouth 13 → belly 15 (1 mm undercut per side =
        // 11° from vertical, self-supporting), then a 45° roof closing to a Ø5 apex. Tangential,
        // so pushing sideways on the wall is the ¼-turn unlock direction. Now EMBOSSED rather
        // than sunk: see the grip shell above.
        if (lid_grip)
            for (i = [0 : lid_grip_n - 1])
                rotate([0, 0, 90 + i * 360/lid_grip_n])
                    translate([lid_grip_r, 0, 0])
                        rotate([0, 0, 90])          // groove runs tangentially = unlock direction
                            lid_groove(top_z);
        seam_bevel(top_z, true);   // matching 45° reveal on the crown edge (top=true → the
                                   // lid's first-layer face when flipped, so support-free)
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
base_chute_w      = outlet_w + 6; // 50 — chute / outlet-drop width (documentary; no geometry consumer)
base_mouth_h      = 18;         // front exit opening height
base_mid_r        = (hole_radial_in + hole_radial_out) / 2;   // 21 — outlet centre r
// ANTI-ROTATION key collar: a rounded-rect spigot on the rest-plate that rises into
// the housing's floor outlet (hole_len×hole_w) → keys the housing against motor
// reaction torque + aligns the two outlets. Food drops through its bore (= the plate
// outlet). Top sits 0.5 mm below the housing cavity floor so the paddle clears it.
// Anti-rotation KEY COLLAR: a short rounded-rect tube that stands up out of the disc and
// plugs INTO the housing floor outlet, keying the housing against spinning. Because it
// plugs in, its OUTER size is bound to the housing outlet (hole_len × hole_w) — so its
// BORE, ar_bx × ar_by, is necessarily (2·ar_wall + ar_slip) = 2.9 mm narrower than the
// outlet. That bore is the kibble pipe's true narrowest point. It CANNOT be widened by
// clamping ar_bx up to hole_len: the bore would exceed ar_ox and the collar's radial
// walls would vanish (no key at all). The only way to open it is to grow hole_len.
// (Derived — do not hand-write numbers here; they went stale twice already.)
ar_slip = 0.5;                  // collar ↔ housing-outlet slip
ar_wall = 1.2;                  // collar wall
ar_h    = 2.5;                  // collar height (≈ housing end_wall − 0.5)
ar_ox   = hole_len - ar_slip;             // collar outer, radial      = hole_len − 0.5
ar_oy   = outlet_w - ar_slip;             // collar outer, tangential  = 43.5 (was hole_w-based)
ar_bx   = ar_ox - 2 * ar_wall;            // bore / disc outlet, radial     ← THE narrowest
ar_by   = ar_oy - 2 * ar_wall;            // bore / disc outlet, tangential = 31.1
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
// [FEED TRAY] — form 1a: the tower stands FLAT on the ground (no legs) and the food
// lands in a SHALLOW pull-out tray that nests in the front scallop, sitting on a
// load-cell platform. Depth is hard-limited: the outlet leaves the disc at z43, and
// under it we must stack ground + cell (12.7) + platform (4) + the tray itself. That
// leaves ~20 mm of tray, not the 32 first sketched — 32 mm cannot exist here.
tray_d   = 150;   // shallow tray Ø (pulls FORWARD out of the scallop; its back is
                  //   under the disc, so it cannot lift straight up)
// 16, not 20: the tray must also SLIDE OUT under the scallop's roof (niche_h = 40).
// With the cell (12.7) + a 2 mm deflection gap + the 4 mm platform, the tray floor lands
// at z21.7 — so at 20 mm deep its rim (z41.7) would foul the scallop roof and the tray
// could never come out. 16 leaves 2.3 mm to slide and 5.3 mm for the food to drop.
tray_h   = 16;    // tray depth. Ø150 × 16 ≈ 280 ml — a generous single meal.
tray_t   = 2.5;   // tray wall / floor
tray_rim = 3;     // low rim so kibble does not bounce out
bowl_cx  = 98;    // tray centre x. Back = 98 − 75 = 23, so the outlet (x25..36) drops
                  //   fully INSIDE the tray with 2 mm to spare.
// The scallop. niche_z0 is 4, NOT 0: the base now has a real FLOOR (base_sole) at z0..3
// that carries the load cell, and the niche must not eat it. niche_h is 40, NOT 58:
// at 58 the scallop cut straight through the DISC (z43..48) — it destroyed the food
// outlet AND the anti-rotation key collar, and left the housing's front half sitting on
// nothing. Keeping the niche under the disc restores all three.
niche_z0 = 4;
niche_h  = 40;    // scallop top — under the disc (43), so the disc is the tray's roof
niche_cl = 8;     // clearance around the tray (scallop Ø = tray_d + niche_cl)
// [Base sole] — an annular floor so the tower has a footprint AND something to bolt the
// load cell to (it used to be an open tube with nothing inside). The bore stays clear of
// the NEMA17 (Ø42.3, corner r29.9) so the motor still drops in from BELOW.
sole_t   = 3;     // floor thickness (z0..3)
sole_ir  = 32;    // floor inner radius — clears the motor corner (29.9) by 2 mm
// [Load cell] — 1..5 kg straight bar (80 × 12.7 × 12.7), cantilever: fixed end bolted
// DOWN onto a pedestal on the sole, load end forward carrying the tray platform.
lc_l = 80; lc_w = 12.7; lc_h = 12.7;
lc_z   = 3;       // cell underside — sits on the sole (z0..3)
lc_x0  = 25;      // cell fixed-end x (on the pedestal, under the tower)
lc_hole_d = 4.3;  // M4
lc_fix1  = lc_x0 + 6;   lc_fix2  = lc_x0 + 18;              // fixed end -> pedestal
lc_load1 = lc_x0 + lc_l - 18; lc_load2 = lc_x0 + lc_l - 6;  // load end  -> platform
ped_w  = 30;      // cell pedestal width (Y)
ped_l  = 30;      // pedestal length (X), from lc_x0 - 3
// tray platform on the cell load end
plat_d = 120;     // platform Ø (under the Ø150 tray; smaller so the tray lifts off easily)
plat_t = 4;
plat_z = lc_z + lc_h + 2;   // platform underside (2 mm of cell deflection gap)

// z-planes:  legs 0 · motor-face 43 · deck-top 48 · plate 57 · plate-top 60 · top 97
deck_top_z = base_deck_z + motor_mount_t;     // 48 — disc top = housing floor (= base_motor_h)

// bowl scallop — cut into every base part it passes through (z−1 .. 58)
// The tray scallop. Cuts base_motor ONLY (z4..40) — it must NOT reach the disc (z43) or
// it destroys the outlet + key collar and unseats the housing (that was the old bug).
module base_niche()
    rotate([0, 0, base_outlet_angle])
        translate([bowl_cx, 0, niche_z0])
            cylinder(d = tray_d + niche_cl, h = niche_h - niche_z0 + 1, $fn = 120);
// SOLE — annular floor (z0..sole_t) giving the tower a real footprint and a place to
// bolt the load cell. Bore r=sole_ir clears the NEMA17 corner so the motor still enters
// from below. Prints as the FIRST layers on the bed → no overhang.
module base_sole()
    difference() {
        cylinder(r = bulk_r_out, h = sole_t, $fn = 160);
        translate([0, 0, -1]) cylinder(r = sole_ir, h = sole_t + 2, $fn = 120);
    }
// PEDESTAL the load cell's FIXED end bolts down onto (sits on the sole, inside the
// scallop, under the tower). Vertical block → prints clean standing.
module cell_pedestal()
    rotate([0, 0, base_outlet_angle]) difference() {
        translate([lc_x0 - 3, -ped_w/2, 0]) cube([ped_l, ped_w, lc_z]);
        for (hx = [lc_fix1, lc_fix2])                       // M4 anchor holes
            translate([hx, 0, -1]) cylinder(d = lc_hole_d, h = lc_z + 2, $fn = 24);
    }
// −X rotational key: a radial bar over [z0,z1], radius band [r0,r1]. `g` grows it
// (0 for the lug, +snap_slip for the receiving slot).
module base_keybar(z0, z1, r0, r1, g)
    rotate([0, 0, key_ang]) translate([r0, -(jkey_w + 2*g)/2, z0])
        cube([r1 - r0, jkey_w + 2*g, z1 - z0]);

/* [Electronics bay — A3] ====================================================
   The bay is the annulus inside the Ø160 tube: r ≈30 (NEMA17 body corner) .. 77,
   z 0..base_deck_z. It is only base_deck_z (43) mm TALL — the motor hangs the full
   height — so a 110×70 tray does NOT fit. The boards ride on ONE VERTICAL tray.
   PRINTABILITY (base_motor prints STANDING, so a horizontal shelf inside it would be
   a ceiling → supports): everything added here is vertical —
     · rails  = ribs running along Z  → zero overhang
     · slots  = vertical grooves      → zero overhang
     · panel opening = 45° GABLE roof → self-supporting, no bridge over the window
   The tray itself is a SEPARATE part printed FLAT with its standoffs pointing UP.
   Placement: el_sector = 180° — opposite the +X food outlet, and it slots between the
   leg bosses (nearest boss edge is 37.6° off the sector axis; the rails sit at ~34°).
*/
el_sector  = 180;   // bay centre angle (opposite the +X outlet)
el_tray_t  = 3;     // tray plate thickness
el_tray_w  = 80;    // tray width  (chord, → global Y). ESP32 52 + a 22-wide column
el_tray_h  = 38;    // tray height (→ global Z). Must stay under base_deck_z (43)
el_x       = 58;    // tray mid-plane distance from the axis. Corners land at
                    // hypot(58,40)=70.4 < bulk_r_in; and 56.5 − 29.9 = 26 mm off the motor
el_z0      = 3;     // tray bottom. The rail slot STARTS here, so its floor is the tray stop
el_slip    = 0.4;   // tray ↔ slot slip
rail_y0    = 33;    // rail inner edge (Y)
rail_y1    = 44;    // rail outer edge (Y). Slot ends at 40.4 → the 40.4..44 material is
                    // the lateral stop. Rail stays clear of the leg bosses (see above).
rail_x0    = 54;    // rail inner face (X) — the cheek in front of the tray
el_slot_w  = el_tray_t + el_slip;          // 3.4
el_slot_y1 = el_tray_w/2 + el_slip;        // 40.4 — slot outer edge
// service window in the Ø160 wall + its removable panel
panel_w     = 46;              // window width (chord)
panel_z0    = 4;               // window bottom
panel_hs    = 14;             // straight part height (DC jack Ø8 + USB live here)
panel_gable = panel_w/2;      // 45° roof: rise == half-width → self-supporting
panel_clr   = 0.35;           // panel ↔ window slip
panel_flange = 2.5;           // inner flange width — the panel cannot fall outward
dc_jack_d   = 8;
usb_slot    = [12, 6];
// boards (VERIFY against your actual modules — hole patterns differ per vendor)
esp_c = [-13,  0];  esp_holes = [48, 24];
drv_c = [ 27, 10];  drv_holes = [15, 10];
hx_c  = [ 27,-10];  hx_holes  = [17, 11];
standoff_d = 8; standoff_h = 4; standoff_hole = 2.3;   // Ø2.3 → M2.5 self-tap

// vertical U-channel rails the tray slides DOWN into. Clipped to the bore so their outer
// face IS the wall inner surface → they merge into the wall on union.
module el_rails() {
    rotate([0, 0, el_sector])
        for (s = [-1, 1])
            intersection() {
                translate([rail_x0, s > 0 ? rail_y0 : -rail_y1, 0])
                    cube([bulk_r_out, rail_y1 - rail_y0, base_deck_z]);
                cylinder(r = bulk_r_in, h = base_deck_z, $fn = 160);
            }
}
// the groove cut out of each rail. Open at the TOP (tray drops in), closed at el_z0 —
// that floor is the tray's bottom stop, so no separate stop lug is needed.
module el_rail_slots() {
    rotate([0, 0, el_sector])
        for (s = [-1, 1])
            translate([el_x - el_slot_w/2, s > 0 ? rail_y0 - 1 : -el_slot_y1, el_z0])
                cube([el_slot_w, el_slot_y1 - (rail_y0 - 1), base_deck_z]);
}
// service window through the wall. Rectangle + 45° GABLE roof (hull to a ridge), so the
// window has no horizontal ceiling to bridge — it self-supports on a standing print.
module el_window(grow = 0) {
    // ridge is a near-zero-width LINE (not a 1 mm plank) so the gabled ceiling meets at a
    // sharp crest = two 45° skates, self-supporting. A flat-topped ridge left a shallow
    // ceiling that pulled support even at the lowest threshold.
    rotate([0, 0, el_sector])
        hull() {
            translate([bulk_r_in - 1, -(panel_w/2 + grow), panel_z0 - grow])
                cube([bulk_wall + 6, panel_w + 2*grow, panel_hs]);
            translate([bulk_r_in - 1, -0.01, panel_z0 + panel_hs + panel_gable + grow])
                cube([bulk_wall + 6, 0.02, 0.02]);
        }
}
// J5 — the nibs / their dimples, as ONE solid used by both the panel (added) and the
// base window (subtracted, grown by a slip). The panel could already not fall OUT (it has
// an inner flange) but nothing stopped it falling IN — it would rattle or drop into the
// bay. Two nibs on its side edges click into the window reveal.
module el_nibs(g = 0)
    rotate([0, 0, el_sector])
        for (s = [-1, 1])
            translate([bulk_r_in + bulk_wall/2, s * (panel_w/2 - panel_clr), panel_z0 + panel_hs/2])
                rotate([0, 90, 0])
                    cylinder(r = pan_nib + g, h = bulk_wall + 2, center = true, $fn = 16);
// PRINT: removable service panel — a curved wall segment (prints STANDING like the tube,
// its gable roof self-supports). An inner FLANGE laps the wall from inside so it cannot
// fall outward; it is fitted from inside and pins the tray behind it.
module el_panel() {
    union() {
    el_nibs(0);                                          // J5 — side nibs (click into the reveal)
    intersection() {
        union() {
            difference() {                                   // wall-thickness segment
                el_window(-panel_clr);
                cylinder(r = bulk_r_in, h = base_deck_z + 10, $fn = 160);
            }
            difference() {                                   // inner flange (laps the wall)
                el_window(panel_flange);
                cylinder(r = bulk_r_in - 1.5, h = base_deck_z + 10, $fn = 160);
                el_window(-panel_clr);                       // keep only the lapping ring
            }
        }
        cylinder(r = bulk_r_out, h = base_deck_z + 10, $fn = 160);
        // connector holes
        rotate([0, 0, el_sector]) difference() {
            cylinder(r = bulk_r_out + 1, h = base_deck_z + 10, $fn = 160);
            translate([bulk_r_in - 4, -14, panel_z0 + panel_hs/2])
                rotate([0, 90, 0]) cylinder(d = dc_jack_d, h = 20, $fn = 32);
            translate([bulk_r_in - 4, 6 - usb_slot[0]/2, panel_z0 + panel_hs/2 - usb_slot[1]/2])
                cube([20, usb_slot[0], usb_slot[1]]);
        }
    }
    }
}
// PRINT: electronics tray — FLAT on the bed, standoffs UP (zero overhang). Slides down
// the base rails on edge. Plate centred on z so its mid-plane lands on el_x in assembly.
// Each standoff is a solid column from the plate's BOTTOM (z=-el_tray_t/2) up through the
// plate and out standoff_h above it — NOT a pin sitting on the plate's top face. Why: a
// pin that starts at the top surface is sliced as a separate object printed ONTO a
// finished top-solid skin — it welds to nothing and snaps off at a touch (the real cause,
// not flow). Running the column from the bed means it prints as one body with the plate
// from layer 1, and the plate's top surface fills AROUND it. Blind hole (1 mm floor left)
// so the M2.5 screw bites and doesn't poke out the back.
// Standoff = solid column from the plate BOTTOM up through the plate and out standoff_h,
// with a THROUGH bore. Running it from the bed (not sitting on the top face) makes it one
// body with the plate from layer 1; the through bore keeps its centre a ring, not a solid
// disc for a top-skin to form on. Ø8 (was 6): double the weld area at the base — a thin
// top skin, if the slicer still lays one, can't pop an 8 mm column off. M2.5 self-taps.
module el_tray_standoffs(c, hp) {
    base_z = -el_tray_t/2;
    for (sx = [-1, 1], sy = [-1, 1])
        translate([c[0] + sx*hp[0]/2, c[1] + sy*hp[1]/2, 0])
            difference() {
                translate([0, 0, base_z]) cylinder(d = standoff_d, h = el_tray_t + standoff_h, $fn = 32);
                translate([0, 0, base_z - 1]) cylinder(d = standoff_hole, h = el_tray_t + standoff_h + 2, $fn = 20);
            }
}
module el_tray() {
    difference() {
        union() {
            translate([0, 0, -el_tray_t/2])                       // plate, centred on z=0
                cube([el_tray_w, el_tray_h, el_tray_t], center = true);
            el_tray_standoffs(esp_c, esp_holes);                  // ESP32
            el_tray_standoffs(drv_c, drv_holes);                  // A4988 / DRV8825
            el_tray_standoffs(hx_c,  hx_holes);                   // HX711
        }
        // wiring pass-throughs (also cut plastic/print time)
        for (x = [-30, 0, 30])
            translate([x, -el_tray_h/2 + 4, 0])
                cube([10, 5, el_tray_t + 2], center = true);
        translate([el_tray_w/2 - 6, el_tray_h/2 - 5, 0])
            cube([8, 6, el_tray_t + 2], center = true);
    }
}
// the tray as SEATED in the base (view only): its plate mid-plane lands on el_x, its
// width runs along the chord (global Y) and its standoffs face INWARD (−X, toward the
// motor: 26 mm clear there vs 19 mm to the wall).
module el_tray_mounted()
    rotate([0, 0, el_sector])
        multmatrix([[0, 0, -1, el_x],
                    [1, 0,  0, 0],
                    [0, 1,  0, el_z0 + el_tray_h/2],
                    [0, 0,  0, 1]])
            el_tray();
// PART 1 — LEG SHROUD: a plain Ø160 tube (z0..43), open both ends, around the motor;
// leg sockets at the bottom; a SNAP spigot on top that springs into the disc. PRINTS
// STANDING (z0 on the bed) — a plain tube, no support. Motor inserts from the bottom.
module base_motor() difference() {
  union() {
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
            base_keybar(base_deck_z, base_deck_z + snap_h, snap_or - 1, snap_or + snap_bead, 0);  // −X key lug
            el_rails();                           // electronics-tray rails (vertical ribs)
        }
        el_rail_slots();                          // the tray grooves (open top, floor = stop)
        el_window();                              // service window (gabled → self-supporting)
        el_nibs(0.25);                            // J5 — dimples the panel's nibs click into
        // NOTE: these 6 relief slots are for the SNAP SPIGOT's flex (base_motor ↔ base_hopper),
        // NOT for any leg thread — they stay even though the legs are gone.
        for (a = [30, 90, 150, 210, 270, 330])
            rotate([0, 0, a]) translate([snap_ir - 0.5, -0.7, base_deck_z - 0.01])
                cube([(snap_or + snap_bead + 1) - (snap_ir - 0.5), 1.4, snap_h + 1]);
        base_niche();
    }
    // added AFTER the niche cut so the scallop cannot eat them
    base_sole();
    cell_pedestal();
  }
  seam_bevel(0);          // 45° foot chamfer on the tower's bottom-outer edge
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
                    for (i = [0 : bay_n - 1]) bay_detent(i, base_h);   // J2 — ride-over detents
                }
                translate([0, 0, base_motor_h - 1]) cylinder(r = bulk_r_in, h = base_h - base_motor_h + 1 - cavity_taper_h + 1);
                translate([0, 0, base_h - cavity_taper_h]) cylinder(r1 = bulk_r_in, r2 = lip_ir, h = cavity_taper_h + 0.01);
                for (i = [0 : bay_n - 1]) bay_slot(i, base_h);         // J2 — L-slots in the lip
            }
            translate([0, 0, base_motor_h]) rotate([0, 0, base_outlet_angle])   // housing key collar (into housing outlet)
                // ARC CAP: the wider ar_oy pushes the tangential corners past the housing bore;
                // intersect with a concentric cylinder at the collar's outer radial edge so the
                // outer edge follows the wall (constant r) and no corner exceeds it. Radial slip
                // to the housing outlet is preserved (same edge radius as before).
                intersection() {
                    translate([base_mid_r, 0, 0]) union() {
                        rounded_rect(ar_ox, ar_oy, hole_corner_r, ar_h);
                        // J3 — 2 beads on the collar's tangential faces: the housing floor's
                        // outlet presses over them and stays put when the funnel comes off.
                        for (s = [-1, 1])
                            translate([0, s * (ar_oy/2 - ar_bead/2), ar_h - 1.2])
                                rotate([0, 90, 0])
                                    cylinder(r = ar_bead, h = ar_ox - 4, center = true, $fn = 16);
                    }
                    translate([0, 0, -1]) cylinder(r = base_mid_r + ar_ox/2, h = ar_h + 2, $fn = 160);
                }
        }
        // motor mount on the UNDERSIDE (z43 face): pilot recess, 4× M3, shaft hole
        translate([0, 0, base_deck_z - 1]) cylinder(d = nema_shaft_d + 3, h = motor_mount_t + 2);  // shaft Ø8 through
        translate([0, 0, base_deck_z])     cylinder(d = nema_pilot_d + 1, h = 3);                  // pilot recess (z43, opens down)
        for (sx = [-1, 1]) for (sy = [-1, 1])     // 4× M3 (motor bolts up from below)
            translate([sx*nema_bolt_sq/2, sy*nema_bolt_sq/2, base_deck_z - 1]) cylinder(d = nema_bolt_d, h = motor_mount_t + 2);
        rotate([0, 0, base_outlet_angle])    // food outlet through the disc — ARC CAP: outer edge hugs the wall
            intersection() {
                translate([base_mid_r, 0, base_deck_z - 1])
                    rounded_rect(ar_bx, ar_by, hole_corner_r, motor_mount_t + ar_h + 2);
                translate([0, 0, base_deck_z - 2])
                    cylinder(r = base_mid_r + ar_bx/2, h = motor_mount_t + ar_h + 4, $fn = 160);
            }
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
        seam_bevel(base_deck_z);   // reveal groove over the base_motor↔base_hopper seam (z43); also its own foot on the bed
        // NO base_niche() here — deliberately. The scallop used to be cut through the disc
        // too (niche_h was 58 > the disc's z43..48), which deleted the food outlet AND the
        // anti-rotation key collar and left the housing's front half unsupported. The niche
        // now stops at z40, under the disc; the disc is the tray's roof.
    }
}
// assembly view — the 2 snapped parts in place (used by the full/chassis renders)
module base() { base_motor(); base_hopper(); }

// ===========================================================================
// TRAY PLATFORM + FEED TRAY  (form 1a — the tower stands flat; the tray is the bowl)
// The platform bolts to the load cell's LOAD end and floats free otherwise, so the
// tray + kibble weight goes only through the cell (HX711). The TRAY just sits on the
// platform and PULLS FORWARD out of the scallop to be washed — it cannot lift straight
// up, because its back tucks under the disc.
// ===========================================================================
module cell_platform() {                 // PRINT: flat on the bed
    rotate([0, 0, base_outlet_angle]) difference() {
        union() {
            translate([bowl_cx, 0, plat_z]) cylinder(d = plat_d, h = plat_t, $fn = 120);
            // J6 — LOCATOR RING: the tray drops inside it, so it self-centres and cannot
            // shuffle when kibble lands (a shuffling tray corrupts the weight reading).
            translate([bowl_cx, 0, plat_z + plat_t - 0.01])
                difference() {
                    cylinder(d = plat_d, h = loc_h, $fn = 120);
                    translate([0, 0, -1]) cylinder(d = plat_d - 2 * (plat_d - tray_d)/2 - 2*loc_slip - 4,
                                                   h = loc_h + 2, $fn = 120);
                }
            for (hx = [lc_load1, lc_load2])                  // 2 bosses down to the cell load end
                translate([hx, 0, lc_z + lc_h])
                    cylinder(d = 11, h = plat_z - (lc_z + lc_h) + plat_t, $fn = 32);
        }
        for (hx = [lc_load1, lc_load2])                      // M4 bolt holes
            translate([hx, 0, lc_z + lc_h - 1]) cylinder(d = lc_hole_d, h = plat_z + 4, $fn = 24);
    }
}
// The tray's BACK wall is a problem the geometry cannot design away. The outlet starts at
// hole_radial_in (x23) but the tray's inner floor cannot start before x25.5: its outer back
// (x23) is already only 1.9 mm off the NEMA17 body (r21.15), so the tray cannot move back,
// and pushing the outlet forward instead would collapse hole_len and jam the bore. So a
// 2.5 mm band of kibble lands ON the back wall. Fix: that back wall is CUT DOWN and given a
// 45 deg inward RAMP — anything that lands there slides into the tray instead of sitting on
// a ledge or bouncing out. Printed open-side-up the ramp grows outward layer by layer, so
// it is self-supporting.
tray_ramp_a = 46;    // angular half-width of the cut-down back sector (deg, about -X)
tray_ramp_h = 6;     // back wall height at the ramp (vs tray_h elsewhere)
module tray() {                          // PRINT: flat on the bed, open side up
    ri = tray_d/2 - tray_t;              // inner floor radius
    difference() {
        union() {
            difference() {
                cylinder(d = tray_d, h = tray_h, $fn = 140);
                translate([0, 0, tray_t]) cylinder(r = ri, h = tray_h, $fn = 140);  // open top
            }
            // the ramp itself: a 45 deg fillet from the floor up the inner back wall
            intersection() {
                rotate_extrude($fn = 140)
                    polygon([[ri - tray_ramp_h, tray_t],
                             [ri,               tray_t],
                             [ri,               tray_t + tray_ramp_h]]);
                rotate([0, 0, 180 - tray_ramp_a])
                    rotate_extrude(angle = 2 * tray_ramp_a, $fn = 140)
                        translate([0, 0]) square([tray_d, tray_h + 1]);
            }
        }
        // cut the back wall down to tray_ramp_h over that same sector
        rotate([0, 0, 180 - tray_ramp_a])
            rotate_extrude(angle = 2 * tray_ramp_a, $fn = 140)
                translate([ri, tray_ramp_h]) square([tray_t + 1, tray_h]);
    }
}
// the tray as SEATED on the platform (view only)
module tray_mounted()
    rotate([0, 0, base_outlet_angle])
        translate([bowl_cx, 0, plat_z + plat_t]) tray();
// the load-cell bar itself (bought part — mock, for the fit check)
module cell_mock()
    rotate([0, 0, base_outlet_angle])
        translate([lc_x0, -lc_w/2, lc_z]) cube([lc_l, lc_w, lc_h]);

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
if (part == "lid")      lid();            // working pose (skirt down, on the jar)
if (part == "lid_print")                 // PRINT pose: flipped disc-on-bed, skirt + tabs up
    translate([0, 0, lid_disc_h + joint_lip_h + 4]) rotate([180, 0, 0]) lid();
if (part == "lid_on_ring_cut") {         // DEBUG: lid bayoneted onto a ring, half-cut
    // zoom on the lip joint only (z-slab), keep x<0 half, contrasting colours
    intersection() {
        difference() {
            union() {
                color("#2E6FA8") ring();                                             // jar = blue
                color("#E0781E") rotate([0, 0, -bay_run]) translate([0, 0, ring_h]) lid();  // lid = orange
            }
            translate([-300, -300, -60]) cube([300, 600, 400]);   // keep x<0 (view the cut face)
        }
        translate([0, 0, ring_h - 4]) cylinder(r = bulk_r_out + 1, h = joint_lip_h + 12, $fn = 160);
    }
}
if (part == "base")        base();                       // assembly preview (2 snapped parts)
if (part == "base_motor")  base_motor();                 // PRINT: leg shroud, standing
if (part == "base_hopper") base_hopper();                // PRINT: core disc, disc-on-the-bed
if (part == "el_tray")     el_tray();                    // el_tray modelled flat (standoffs up)
if (part == "el_tray_print")                             // PRINT ON EDGE: plate vertical, pins
    // horizontal → each pin prints INSIDE the plate's wall layers (one body, no top-skin
    // between pin and plate — the flat-print failure). Cost: light support under the pins.
    rotate([90, 0, 0]) translate([0, 0, el_tray_h/2]) el_tray();
if (part == "el_panel")    el_panel();                   // PRINT: service panel, standing (curved segment)
if (part == "el_fit") {                                  // DEBUG: bay fit — tray + panel in the shroud
    color("Gainsboro", 0.35) base_motor();
    color("SteelBlue")       el_tray_mounted();
    color("Tomato")          el_panel();
    color("DimGray", 0.5)    motor_mock(base_deck_z);
}
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
    motor_mock(base_deck_z - 70);                               // motor, inserts UP from below
    color("Tomato")    base_motor();                           // shell + sole + scallop + el bay
    color("Gold")      translate([0, 0, 45]) base_hopper();    // core disc (motor under, housing over)
}
if (part == "x_tower") {       // EXPLODED full tower (assembly guide)
    e = 40;
    color("Gainsboro")            base();
    color("LightSteelBlue")       translate([0, 0, base_motor_h + e]) housing();
    color("Silver")               translate([throat_cx, 0, base_motor_h + 3.5 + e]) wheel();
    color("Khaki")                translate([0, 0, base_h + 2*e]) funnel();
    color("BurlyWood")            translate([0, 0, base_h + z_funnel_top + 3*e]) ring();
    color("Tan")                  translate([0, 0, base_h + z_funnel_top + ring_h + 4*e]) lid();
    color("DimGray")              translate([0, 0, 0.4*e]) cell_mock();
    color("Wheat")                translate([0, 0, 0.8*e]) cell_platform();
    color("LightBlue", 0.6)       translate([0, 0, 1.4*e]) tray_mounted();
}
if (part == "x_funnel") {      // EXPLODED funnel sub-assembly (assembly guide)
    e = 55;
    color("Khaki", 0.30)    funnel_shell();                             // Ø160 outer tube (see-through)
    color("Orange")         translate([0, 0, cap_t + 1.2*e]) funnel_cone();  // mass-flow cone insert
    color("Crimson")        translate([0, 0, cap_t + 2.1*e]) spider();        // anti-pressure spider (into cone)
    color("MediumSeaGreen") translate([0, 0, -0.7*e]) cap_plate();      // cap — nests on the housing top
}
if (part == "full" || part == "full_norings") {
    // whole product (form 1a): the tower stands FLAT on its sole — no legs, no external
    // stand. The feed tray pulls out of the front scallop and rides the load cell.
    color("Gainsboro")            base();
    color("SteelBlue")            el_tray_mounted();                           // electronics tray
    color("Tomato")               el_panel();                                  // service panel
    color("LightSteelBlue", 0.45) translate([0, 0, base_motor_h]) housing();   // hidden inside
    color("Silver")               translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
    color("Khaki")                translate([0, 0, base_h]) funnel();
    if (part == "full") {
        color("BurlyWood")        translate([0, 0, base_h + z_funnel_top]) ring();
        color("Tan")              translate([0, 0, base_h + z_funnel_top + ring_h]) lid();
    } else {
        color("BurlyWood")        translate([0, 0, base_h + z_funnel_top]) lid();   // lid straight on funnel
    }
    color("DimGray")              cell_mock();          // load cell in the scallop
    color("Wheat")                cell_platform();
    color("LightBlue", 0.4)       tray_mounted();       // shallow pull-out feed tray
}
if (part == "full_cut") {
    difference() {
        union() {
            color("Gainsboro")            base();
            color("SteelBlue")            el_tray_mounted();
            color("Tomato")               el_panel();
            color("LightSteelBlue")       translate([0, 0, base_motor_h]) housing();
            color("Silver")               translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
            color("Khaki")                translate([0, 0, base_h]) funnel();
            color("Tan")                  translate([0, 0, base_h + z_funnel_top]) lid();
            color("DimGray")              cell_mock();
            color("Wheat")                cell_platform();
            color("LightBlue", 0.5)       tray_mounted();
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
// (REMOVED 2026-07-13 — form 1a scope reset: the tower now stands FLAT on the ground.
//  Deleted: printable_thread(), thread_hole(), leg(), legs_mounted(), parts "leg"/"legs4",
//  and the whole EXTERNAL weighing station wp_foot()/wp_tray()/"station"/"station_cut"
//  plus the deep Ø175 bowl_mock(). Weighing now lives IN the front scallop: base_sole()
//  carries cell_pedestal(), the cell carries cell_platform(), and tray() sits on it.)

// PRINT parts of the feeding station
if (part == "tray")          tray();            // PRINT: shallow pull-out feed tray, flat
// PRINT FLIPPED: modelled with the two Ø11 bosses hanging DOWN off the Ø120 disc, so
// printing it as modelled leaves the whole disc bridging between two thin posts — 11116 mm2
// of 90° overhang at z17.7 (measured). Upside-down the disc/locator ring lies flat on the
// bed and the bosses point up as plain columns: 0 mm2 unsupported.
if (part == "cell_platform")
    translate([0, 0, plat_z + plat_t + loc_h]) rotate([180, 0, 0]) cell_platform();
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
if (part == "bay_zoom") {
    // debug: J2 bayonet, LOCKED. A z-slab isolates the lip band; the base lip (blue) shows
    // its 3 L-slots, the shell (translucent orange) is dropped on and twisted -bay_run so
    // its 3 tabs sit in the LOCKED leg of the L (under the lip roof), not the entry channel.
    // Render top-down (rx=0) to read the tabs-in-slots; iso/side for the roof overlap.
    // pre-rotate +bay_run so the locked tab (twists to -bay_run) lands on +X, then keep a
    // ±26° wedge + z-slab = a big zoom on ONE tab-in-slot. Shell translucent so the tab
    // shows through, sitting under the lip roof.
    rotate([0, 0, bay_run])
    intersection() {
        union() {
            color("#2E6FA8")        base_hopper();
            color("#E0781E", 0.55)  rotate([0, 0, -bay_run]) translate([0, 0, base_h]) funnel_shell();
        }
        translate([0, 0, base_h - 2]) cylinder(r = bulk_r_out + 1, h = joint_lip_h + 5, $fn = 160);
        rotate([0, 0, -26]) rotate_extrude(angle = 52, $fn = 160)
            translate([bulk_r_in - 8, base_h - 2]) square([14, joint_lip_h + 5]);
    }
}
// STEP-BY-STEP assembly. step 0..9, cumulative — each value adds the next part in the
// §3 HANDOFF order. For rendering a picture-per-step build instruction.
module _step_stack(step) {
    if (step >= 1) color("#444")          motor_mock(base_deck_z);                       // 1 motor
    if (step >= 1) color("Gold")          base_hopper();                                 // 1 disc
    if (step >= 2) color("Silver")        translate([throat_cx, 0, base_motor_h + 3.5]) wheel();  // 2 wheel
    if (step >= 3) color("LightSteelBlue")translate([0, 0, base_motor_h]) housing();     // 3 housing
    if (step >= 4) color("SteelBlue")     el_tray_mounted();                             // 4 electronics
    if (step >= 4) color("Tomato")        el_panel();
    if (step >= 5) color("Gainsboro", 0.55) base_motor();                                // 5 shroud snaps on
    if (step >= 6) color("#4A4F55")       cell_mock();                                   // 6 weigh
    if (step >= 6) color("Wheat")         cell_platform();
    if (step >= 6) color("LightBlue", 0.6)tray_mounted();
    if (step >= 7) color("MediumSeaGreen")translate([0, 0, base_h - nest_h]) cap_plate();// 7 cap+cone
    if (step >= 7) color("Orange", 0.8)   translate([0, 0, base_h + cap_t - nest_h]) funnel_cone();
    if (step >= 8) color("Khaki", 0.5)    translate([0, 0, base_h]) funnel_shell();      // 8 shell bayonet
    if (step >= 9) color("BurlyWood")     translate([0, 0, base_h + z_funnel_top]) ring();          // 9 ring+lid
    if (step >= 9) color("Tan")           translate([0, 0, base_h + z_funnel_top + ring_h]) lid();
}
if (part == "step") _step_stack(step);

echo(str("bulk_d=", bulk_d, " funnel_h=", funnel_h,
         " wall_angle=", funnel_wall_angle, "deg cone_top_z=", round(cone_top_z*10)/10,
         " hopper_outer=", hopper_outer_len, "x", hopper_outer_w,
         " ring_h=", ring_h,
         " total_h=", z_funnel_top + ring_h + joint_lip_h + 4 + lid_disc_h,
         " est_ring_L=", round(3.14159 * bulk_r_in * bulk_r_in * ring_h / 1000) / 1000));
