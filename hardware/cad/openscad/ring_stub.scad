// THROWAWAY bayonet (bay_*) test coupons — the ring↔shell J2 joint, minimised.
// The real ring is a 150 mm storage tube; printing it whole to test the ¼-turn lock
// is wasteful, so these are two short coupons built from the SAME bay_* modules the
// real parts use (bay_tab / stacking_lip / bay_slot / bay_detent) — identical radii,
// angles, slip, detent, lead-in. One pair validates the whole stack (shell↔base,
// ring↔shell, lid↔ring all share bay_*).
//
// BOTH coupons print STANDING (bottom on the bed, native) — the same orientation the
// shell and ring print in — so there is no standing-vs-flat Ø divergence between them
// (that divergence is what killed the old snap; the lid↔ring pair, lid flipped, is the
// only one that would need a separate flipped coupon — not covered here).
//   TAB : a short ring-bore wall + 3 tabs. The 45° lead-in is on the tab UNDERSIDE
//         (bay_tab), so printed standing each tab builds as a self-supporting inward
//         overhang — no bridging, no support.
//   LIP : the exact funnel_shell top lip — stacking_lip + 3 detents − 3 L-slots. Plain
//         vertical annular wall with voids cut in; the only bridge is each L-run roof
//         (~20° span at z≈3.6), identical to the real standing shell, so if it sags here
//         it sags there — that is the point of the coupon.
//
// FIT: the TAB coupon (bore bulk_r_in=77, tabs inward to bay_tab_ir=75.5, outer 80)
// drops OVER the LIP coupon (lip_or=76.7, 0.3 clearance); the tabs pass through the
// slots, then a ~20° CW twist (bay_run) slides them under the L-run roof and clicks
// past the detent. Lift-proof after the twist.
// LIDSKIRT: the third coupon — the lid's MALE side (skirt bore + bay_tab_lid tabs),
// printed FLIPPED exactly like the real lid (lid_print: disc on the bed, skirt + tabs
// up). This is the one joint case the standing tab/lip pair does NOT cover: the lid's
// skirt bore prints as flipped upper-layer walls, so its real Ø diverges from a
// STANDING-printed lip differently than a standing bore does — the exact divergence
// mode that killed the old snap. Its FEMALE mate is the SAME lip as ring↔shell, so it
// twist-tests against the already-printed `ring_lip` coupon — no reprint of the lip.
include <bulk_hopper_module.scad>
part = "__none__";
$fn  = 160;
stub = "tab";          // set via -D stub="lip"  |  -D stub="lidskirt"

H_TAB = 7;             // tab-coupon height (tabs live z0.5..3.5; a few mm of grip above)
LID_CAP = 3;           // thin disc slice kept as the flipped bed-face + handle

// TAB side: ring-bore wall (bulk_r_in..bulk_r_out) + the 3 underside-lead tabs.
// (seam_bevel omitted — it is a cosmetic reveal on the ring foot, not part of the fit.)
module tab_stub() union() {
    difference() {
        cylinder(h = H_TAB, d = bulk_d);                 // outer wall r80
        translate([0, 0, -1]) cylinder(h = H_TAB + 2, r = bulk_r_in);  // bore r77
    }
    for (i = [0 : bay_n - 1]) bay_tab(i);                // 3 tabs, inward to r75.5
}

// LIP side: funnel_shell's top lip, verbatim (see funnel_shell() L618-623), placed at z0.
module lip_stub() difference() {
    union() {
        stacking_lip(0);                                 // annulus lip_ir..lip_or × joint_lip_h
        for (i = [0 : bay_n - 1]) bay_detent(i, 0);      // anti-unscrew bumps in the runs
    }
    for (i = [0 : bay_n - 1]) bay_slot(i, 0);            // vertical entry + 20° L-run
}

// LID skirt (male): faithful to lid()'s skirt block (L718-725) — disc cap + skirt,
// hollowed to skirt_id, + bay_tab_lid tabs (45° lead on the model-TOP = bed face when
// flipped). Modelled skirt-DOWN (disc up), then flipped disc-on-bed exactly as lid_print.
skirt_h  = joint_lip_h + 4;      // 14 — must clear the full lip (matches lid())
skirt_id = 2 * bulk_r_in;        // bore slips over the lip; inner face = bulk_r_in so tabs fuse
skirt_od = bulk_d;
// The real lid caps this with a solid Ø160 disc; for a THROWAWAY coupon that disc is
// pure ballast (~30 g of solid infill that has nothing to do with the joint). So cap it
// with a RING instead: keep the outer Ø160 edge (that IS the skirt base — the first-layer
// condition whose Ø-divergence vs the standing lip is what we're testing) plus a ~10 mm
// flange for grip/adhesion, and open the centre. The joint (skirt bore + tabs) is byte-for-
// byte unchanged; only dead disc mass is removed.
cap_id = 120;                    // ring-cap inner Ø (r60) — flange r60..r80, centre open
module lidskirt_body() union() {
    difference() {
        union() {
            translate([0, 0, skirt_h]) cylinder(h = LID_CAP, d = bulk_d);  // cap (bed face flipped)
            cylinder(h = skirt_h, d = skirt_od);                           // skirt
        }
        translate([0, 0, -1]) cylinder(h = skirt_h + 1, d = skirt_id);     // hollow the skirt
        translate([0, 0, skirt_h - 1]) cylinder(h = LID_CAP + 2, d = cap_id); // hollow cap centre → ring
    }
    for (i = [0 : bay_n - 1]) bay_tab_lid(i);                              // lid-variant tabs
}
// print pose: flip disc-on-bed, skirt + tabs up (same transform shape as lid_print)
module lidskirt_stub() translate([0, 0, skirt_h + LID_CAP]) rotate([180, 0, 0]) lidskirt_body();

if (stub == "tab")      tab_stub();
if (stub == "lip")      lip_stub();
if (stub == "lidskirt") lidskirt_stub();
