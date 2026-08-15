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
include <bulk_hopper_module.scad>
part = "__none__";
$fn  = 160;
stub = "tab";          // set via -D stub="lip"

H_TAB = 7;             // tab-coupon height (tabs live z0.5..3.5; a few mm of grip above)

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

if (stub == "tab") tab_stub();
if (stub == "lip") lip_stub();
