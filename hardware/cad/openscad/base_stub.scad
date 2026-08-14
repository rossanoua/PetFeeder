// THROWAWAY breech-lock test coupons — z-band intersections of the real base parts.
// Does NOT touch frozen tract or the base modules; just clips them to the joint zone.
// Printability: each coupon must have a SOLID first-layer footprint under every
// feature — otherwise a cut-exposed downward overhang prints over air and peels.
//   MOTOR : male ring + 3 lug heads point UP (good). Base ring starts at z43 and
//           the heads cantilever inward (45deg) over the bore -> a solid base ring
//           z40..43 grounds everything before the first male layer.
//   HOPPER: the female pocket (channels + keyholes) is cut UPWARD into the z43 face,
//           so as-modelled it opens DOWNWARD and its z46.4..48 roof would bridge a
//           ~3.4 mm void and peel. FLIP 180deg so the solid roof (orig z48) is the
//           first layer and the pocket opens UP.
include <bulk_hopper_module.scad>
part = "__none__";
$fn  = 160;
stub = "motor";        // set via -D stub="hopper"
zc   = 40;             // motor cut floor (just above the niche top at z40)
ri   = 68;             // annulus inner r — drops the dead solid centre; keeps the full ring + all 3 lugs
ro   = 82;             // annulus outer r — clipped to the real Ø160 wall (r80) by the intersection

module band(z0,h) intersection() {           // z-slab ∩ full-360° annulus (keeps all 3 lugs + keyholes)
    translate([0,0,z0]) cylinder(r=ro, h=h);
    difference() { cylinder(r=ro, h=200, center=true); cylinder(r=ri, h=202, center=true); }
}
// Solid annular base ring — grounds cantilevered features (fills the hollow bore
// zone under the male lugs). ir/or = inner/outer radius; z0/h = band.
module puck(z0, h, ir, orr) translate([0,0,z0])
    difference() { cylinder(r=orr, h=h); translate([0,0,-1]) cylinder(r=ir, h=h+2); }

// base_motor joint zone: z43..46 = 360° base ring (z43..44, r75.6..77.6) + 3 male
// lug heads (z44..46, r74.2..77.6, inward 45° overhang). Band z40..47 captures it on
// a solid base ring z40..43 (r72..80) so the inward lug flanks never print over the bore.
module motor_stub() translate([0,0,-zc]) union() {
    intersection() { base_motor(); band(zc, 7); }
    puck(zc, base_deck_z - zc, 72, 80);       // z40..43 solid r72..80
}
// base_hopper joint zone: the whole joint disc z43..48 = female pocket + 3 twist
// channels + 3 keyholes (cut z43..46.4) under a solid roof (z46.4..48). Pocket opens
// downward -> FLIP 180° about X so the roof (orig z48) is the bed face and the pocket
// opens UP. After translate(-43) the band is z0..5; rotate(180) -> z-5..0; translate
// (FLIP_H) lands orig z48 on the bed and orig z43 (pocket mouth) on top.
//   Knife-edge note: seam_bevel(z43) feathers only the z43 outer edge (r78->80 over
//   z43..45). After the flip that feather sits at the TOP (z3..5), NOT the bed — the
//   first layer is clean solid roof, so no knife-edge foot to peel (unlike the v3 snap).
FLIP_H = 5.0;                      // orig z48 -> bed 0 ; orig z43 -> top 5.0
module hopper_stub() union() {
    translate([0,0,FLIP_H]) rotate([180,0,0]) translate([0,0,-base_deck_z])
        intersection() { base_hopper(); band(base_deck_z, 5); }   // orig z43..48 (full joint disc)
    puck(0, 1.5, 68, 80);          // ground the flipped roof; stays below the z1.6 roof underside
}

if (stub=="motor")  motor_stub();
if (stub=="hopper") hopper_stub();
