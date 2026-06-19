// AiPetFeeder — Paddle-wheel rotary-disc dispenser
// ---------------------------------------------------------------------------
// Rewrite 2026-05-25: COLLAR-MOUNT hopper redesign per ADR
// `2026-05-25-collar-mount-hopper-redesign`. Hopper no longer plugs INTO a
// socket — it sits ON TOP of the cap, retained laterally by a low collar
// (fence) that surrounds its outer bottom edge. Kibble flow pipe has no
// wall narrowing and no shelf — the cap inlet hole IS the narrowest cross-
// section in the entire pipe.
//
// Architecture summary (unchanged from previous revision):
// Housing rests on its FLAT circular floor (axle vertical in operation).
// Inlet through the cap (rounded-rect hole at a radial offset). Outlet
// through the floor (same shape hole, 180° apart angularly). Paddles fill
// only the BOTTOM half of the cavity — they sweep kibble along the floor
// from inlet position to outlet position.
//
//        ┌──────────────────────────┐
//        │     hopper / funnel      │     (sits ON TOP of cap;
//        │     (open bottom)        │      no spout into a socket)
//        └────────────┬─────────────┘
//                     │ flow area = hole size (no walls)
//                     │
//        ╔═══╦════════│════════════╦══╗   ← collar walls (fence)
//        ║   ╠════════╧════════════╣  ║      surrounding the hopper
//        ╞═══╧═══════════════════════╡   ← end_cap rim (removable)
//        │     ░░░░░░░░░░░░░░░░░░   │      cavity
//        │  ┌──┐  ┌──┐  ┌──┐ (3×)   │      paddles (bottom half only)
//        ├──┤  ├──┤  ├──┤           │      n_paddles = 3, sweep floor
//        ├──┘  └──┴──┘  └───────────┤      housing floor
//                  │  outlet hole
//                  ▼ → chute → bowl
//
// Parts:
//   part = "wheel"    -> hub + half-height paddles + D-bore
//   part = "axle"     -> through axle
//   part = "housing"  -> cup, floor with outlet hole (rounded corners)
//   part = "end_cap"  -> lid with axle bore + inlet hole (rounded corners)
//                        + COLLAR (rectangular fence) on top, around the
//                        hole, retaining the hopper laterally
//   part = "hopper"   -> small test hopper, open-bottom rect-to-round cone
//   part = "assembly" -> all stacked together for fit check
// ===========================================================================

part = "assembly";   // wheel | axle | housing | end_cap | hopper | assembly

/* [Wheel] */
// 2026-06-03: scaled BACK to wheel_d=80 (was 120). The Ø120 upscale
// existed only to fight bridging passively; we're switching to an ACTIVE
// anti-bridge (vibromotor on the funnel) + HX711 closed-loop, so the big
// wheel is no longer needed and the whole mechanism shrinks. Portion is
// now set by rotation count, not pocket volume.
wheel_d         = 80;    // outer diameter (over paddle tips)
wheel_thickness = 18;    // axial extent of wheel hub (taller again — the
                         //   pocket area shrank with the smaller wheel)
n_paddles       = 3;     // sector 120°
paddle_thick    = 2.4;
paddle_fraction = 0.5;
rim_t           = 1.5;   // thin RING along the outer contour tying the 3 paddle
                         //   tips together (0 = no ring). Same radius/height as
                         //   the paddle tips, so it keeps the housing clearance.
hub_d           = 20;    // proportional to wheel_d=80

/* [Active stirrer cone] (2026-06-05, replaces the dead static spider) */
// A frustum on the hub TOP, under the (now bigger, axle-ward) cap inlet.
// 3 proud VANES (continuations of the paddles) ride the cone — because
// they ROTATE with the wheel, they poke/break any arch forming over the
// centre. Kibble also can't rest on a flat top: it slides into pockets.
cone_h        = 11;      // cone height above the hub (clears the cap ~4.5 mm)
cone_top_d    = 8;       // truncated tip Ø (solid above the axle)
vane_proud    = 2.5;     // how far the vanes stand proud of the cone
vane_t        = paddle_thick;  // vane thickness = paddle thickness

/* [Axle] */
axle_d         = 5.0;
axle_flat      = 0.8;
axle_stub_top  = 8;
axle_stub_bot  = 22;
fit_clear      = 0.30;

/* [Housing] */
housing_clear      = 0.8;
wheel_axial_clear  = 0.5;
floor_clear        = 0.5;
housing_wall       = 3;
end_wall           = 3;
// 2026-05-29: kibble settling buffer between the wheel TOP and the cap
// INLET. Before this was implicit 0 mm — kibble dropping through the
// cap inlet had no room to spread before hitting the wheel. 15 mm =
// one full kibble (~12 mm) plus clearance; multiple pieces can
// pre-stack in the buffer and settle into pockets as they pass under
// the inlet.
housing_buffer_h   = 15;

/* [TEARDROP top] — round bottom (wheel) flares to a teardrop top + cap */
// 2026-06-06: user test — the funnel with the biggest opening flows best.
// To make the cap inlet bigger, the housing stays ROUND at the bottom
// (where the round wheel turns) and flares to a TEARDROP at the top, the
// tip pointing BACK toward the inlet/funnel. The cap is the same teardrop
// and seats only one way → the SHAPE itself keys the cap (anti-rotation),
// so the old (snapping) merlons are GONE.
td_back    = 22;        // teardrop tip reach beyond hr_out, toward the inlet
td_tip_r   = 18;        // teardrop tip radius
td_flare_z = 5;         // z where the round→teardrop flare starts (above recess)
// FEED RAMP filling the teardrop-tip lobe. Without it the lobe floor is a flat
// shelf at td_flare_z, BELOW the wheel rim/paddle top — kibble lands there, can't
// get over the rim into a sector, and the spinning rim grinds it → JAM. The ramp
// raises that shelf into a slope: low at the wheel edge (just over the rim top)
// rising to the tip, so kibble slides over the rim into the wheel. (No housing
// height increase.)
ramp_lo    = 13;        // ramp top at the wheel edge (≈ rim top 12.5 + 0.5)
ramp_hi    = 32;        // ramp top at the teardrop tip (< wheel cone top 32.5)
td_clear   = 0.4;       // cap-over-housing teardrop slip clearance
// td_tip_cx is derived below (needs hr_out)

/* [Cap inlet] — big opening on the INLET (back) side, reaching the axle.
   It hugs the teardrop cavity (no rectangle) but stops at the axle: the
   FRONT of the cap (over the floor outlet) stays solid, with the axle
   bore. The OUTLET (floor) keeps the hole_* params. */
inlet_margin = 3;       // rim between the inlet edge and the cavity wall
axle_keep    = axle_d/2 + fit_clear + 2;  // solid cap kept around the axle bore

/* [Cap rebate joint — the cap nests into a CUT in the housing rim] */
// 2026-06-06: connect housing↔cap with a REBATE, not pins/holes. The rim
// is cut down on the inside to a ledge, leaving the outer teardrop LIP;
// the cap is inset so it drops into that cut and is captured laterally
// (the teardrop keeps it from rotating).
rab_d     = 3;          // rebate depth (how deep the cap nests into the lip)
rab_w     = 2;          // teardrop lip width (the un-cut outer rim)
cap_clear = 0.4;        // cap <-> lip slip clearance

/* [Inlet / outlet rectangular hole] */
// Rounded-rect, radially aligned. Hole IS the narrowest cross-section in
// the entire kibble pipe (cone narrows down to it directly; no wall
// constriction above or below).
hole_radial_in   = 7;    // (floor OUTLET; the cap inlet is the teardrop).
hole_radial_out  = 35;   // 2026-06-06: out pulled IN from the rim (40→35) so
hole_w           = 34;   //   the paddle TIP sweeps solid floor near the rim
hole_corner_r    = 2;    //   and never crosses a hole edge there.
out_cham         = 3;    // tangential lead-in: the two edges the paddle
                         //   crosses are SLOPED (wider at the wheel side), a
                         //   ramp instead of a 90° edge.
inlet_angle_deg  = 180;
outlet_angle_deg = 0;

/* [Hopper collar on the cap] (replaces the old boss-socket) */
collar_h     = 10;     // collar wall height above the cap surface
collar_wall  = 2.0;    // collar wall thickness
collar_clear = 0.5;    // hopper outer <-> collar inner slip-fit clearance
hopper_wall  = 2;      // wall thickness of the test/bulk hopper

/* [Test hopper] (the small bench hopper; bulk hopper is a separate file) */
hopper_top_d   = 70;
hopper_h       = 55;

/* [Quality] */
$fn = 96;

// --- derived ----------------------------------------------------------------
wheel_r    = wheel_d / 2;
hub_r      = hub_d   / 2;
hr_in      = wheel_r + housing_clear;
hr_out     = hr_in + housing_wall;
td_tip_cx  = hr_out + td_back - td_tip_r;   // teardrop tip centre offset (-x)
housing_h  = end_wall + floor_clear + wheel_thickness
           + wheel_axial_clear + housing_buffer_h;
                            // no register_d any more — cap sits flat on
                            // top rim, located by axle + 4 merlon/notch locks
hlen       = housing_h + end_wall;

paddle_h   = wheel_thickness * paddle_fraction;
hole_len   = hole_radial_out - hole_radial_in;
hole_mid_r = (hole_radial_in + hole_radial_out) / 2;

// Hopper outer bottom (sits on the cap, around the hole)
hopper_outer_w     = hole_w + 2 * hopper_wall;
hopper_outer_len   = hole_len + 2 * hopper_wall;

// Collar inner outline (surrounds the hopper outer bottom)
collar_inner_w     = hopper_outer_w + 2 * collar_clear;
collar_inner_len   = hopper_outer_len + 2 * collar_clear;
collar_outer_w     = collar_inner_w + 2 * collar_wall;
collar_outer_len   = collar_inner_len + 2 * collar_wall;

// --- helpers ----------------------------------------------------------------
// Rounded rectangle extruded along z (centered on origin in X/Y)
module rounded_rect(x, y, r, h) {
    hull() {
        for (dx = [-1, 1])
            for (dy = [-1, 1])
                translate([dx * (x/2 - r), dy * (y/2 - r), 0])
                    cylinder(r = r, h = h);
    }
}

// D-shape (axle + matching bore)
module d_solid(d, flat, len) {
    difference() {
        cylinder(h = len, d = d);
        translate([d/2 - flat, -d, -1]) cube([d, 2*d, len + 2]);
    }
}

// Teardrop outline (2D): a circle of radius R with a rounded tip bulging
// toward -X (the inlet side). tip_cx = how far back the tip centre sits.
module teardrop_2d(R, tip_r, tip_cx) {
    hull() {
        circle(r = R, $fn = 96);
        translate([-tip_cx, 0]) circle(r = tip_r, $fn = 48);
    }
}

// Cap inlet outline (2D): the teardrop cavity (inset by a rim) but only
// the BACK side, cut off just behind the axle → a big inlet that reaches
// the axle while the front of the cap stays solid (axle bore + outlet
// cover).
module inlet_2d() {
    intersection() {
        offset(-inlet_margin)
            teardrop_2d(hr_in, td_tip_r - housing_wall, td_tip_cx);
        translate([-axle_keep - 200, -100]) square([200, 200]);  // x <= -axle_keep
    }
}

// Cap outline (2D): the housing teardrop inset so the cap drops inside the
// housing rebate lip (with cap_clear slip).
module cap_outline() {
    offset(-(rab_w + cap_clear)) teardrop_2d(hr_out, td_tip_r, td_tip_cx);
}

// ===========================================================================
// WHEEL  full-height hub + N radial paddles on the bottom half
// ===========================================================================
module wheel() {
    // 2026-05-28 v2: paddle tip rounded in BOTH plan view AND side view.
    // v1 (earlier today) rounded only the plan-view tip with a Z-axis
    // cylinder — but the top-outer and bottom-outer edges (sharp 90°
    // when seen from the side) were still wedge points for kibble.
    //
    // Now: hull of a hub-side slab + 2 spheres at the outer tip's top
    // and bottom centers. Result:
    //   plan view  — rectangle with semicircular outer cap (r=1.2 mm)
    //   side view  — rectangle with rounded outer-top and outer-bottom
    //                fillets (r=1.2 mm)
    // Outer envelope unchanged: paddle still sweeps to wheel_r at the
    // sphere tangent points.
    rp = paddle_thick / 2;
    cone_top_r = cone_top_d / 2;
    difference() {
        union() {
            cylinder(h = wheel_thickness, d = hub_d);
            for (i = [0 : n_paddles - 1])
                rotate([0, 0, 360 * i / n_paddles])
                    hull() {
                        // Hub-side slab — overlaps INTO the hub for a
                        // solid join. No rounding at this end so the
                        // root keeps full paddle_h height against the
                        // hub cylinder.
                        translate([hub_r - 0.5, -paddle_thick/2, 0])
                            cube([0.5, paddle_thick, paddle_h]);
                        // Outer-tip: 2 spheres at the 4 tip corners
                        // (top-outer + bottom-outer get rounded in 3D).
                        translate([wheel_r - rp, 0, rp])
                            sphere(r = rp, $fn = 16);
                        translate([wheel_r - rp, 0, paddle_h - rp])
                            sphere(r = rp, $fn = 16);
                    }
            // Connecting RIM: a thin ring at the outer contour joining the 3
            // paddle tips (rigidises them). r = wheel_r (paddle-tip envelope),
            // height = paddle_h, wall = rim_t. Keeps the same housing clearance.
            if (rim_t > 0)
                difference() {
                    cylinder(h = paddle_h, r = wheel_r);
                    translate([0, 0, -1]) cylinder(h = paddle_h + 2, r = wheel_r - rim_t);
                }
            // Active stirrer: frustum on the hub top (base = hub_d).
            translate([0, 0, wheel_thickness])
                cylinder(h = cone_h, r1 = hub_r, r2 = cone_top_r);
            // 3 proud VANES on the cone (aligned with the paddles). Each
            // is a thin radial wall clipped to a cone vane_proud larger
            // than the core cone → a fin that hugs the cone and stands
            // vane_proud above it. Prints support-free (leans in going up).
            for (i = [0 : n_paddles - 1])
                rotate([0, 0, 360 * i / n_paddles])
                    intersection() {
                        // start at r=2 (not the axis) so the 3 vanes never
                        // overlap at the centre (that made it non-manifold)
                        translate([2, -vane_t/2, wheel_thickness])
                            cube([hub_r + vane_proud - 2, vane_t, cone_h]);
                        translate([0, 0, wheel_thickness])
                            cylinder(h = cone_h,
                                     r1 = hub_r + vane_proud,
                                     r2 = cone_top_r + vane_proud);
                    }
        }
        // axle D-bore — goes ALL THE WAY THROUGH (incl. the cone tip), so
        // the axle hole is obvious and the axle can pass up to the cap's
        // bore (top guide). The tip becomes a thin Ø(cone_top_d) ring.
        translate([0, 0, -1])
            d_solid(axle_d + fit_clear, axle_flat,
                    wheel_thickness + cone_h + 2);
    }
}

// ===========================================================================
// AXLE
// ===========================================================================
module axle() {
    total = axle_stub_bot + housing_h + end_wall + axle_stub_top;
    engage_z0 = axle_stub_bot + end_wall + floor_clear;
    difference() {
        cylinder(h = total, d = axle_d);
        translate([axle_d/2 - axle_flat, -axle_d, engage_z0])
            cube([axle_d, 2*axle_d, wheel_thickness]);
    }
}

// ===========================================================================
// HOUSING  round cup (wheel) that FLARES to a teardrop top; closed floor
//          with a rounded-rect OUTLET. The teardrop top widens the inlet.
// ===========================================================================
// Feed ramp: the teardrop-tip lobe (everything beyond the round wheel cup),
// filled from the floor up to a sloped top — low (over the rim) at the wheel
// edge, high at the tip — so kibble slides over the rim into the wheel instead
// of dead-resting on a flat shelf and jamming the spinning rim.
module lobe_ramp() {
    intersection() {
        linear_extrude(housing_h + 1)
            difference() {
                teardrop_2d(hr_in, td_tip_r - housing_wall, td_tip_cx);
                circle(r = hr_in, $fn = 96);          // keep the round wheel cup clear
            }
        hull() {
            translate([-hr_in, -hr_out - 1, 0]) cube([0.1, 2*hr_out + 2, ramp_lo]);
            translate([-(hr_out + td_back), -hr_out - 1, 0]) cube([0.1, 2*hr_out + 2, ramp_hi]);
        }
        // clip to the housing OUTER envelope so the ramp can't float past the
        // walls (the teardrop tip doesn't exist below td_flare_z).
        union() {
            cylinder(h = td_flare_z, d = 2 * hr_out);
            hull() {
                translate([0, 0, td_flare_z]) cylinder(d = 2 * hr_out, h = 0.1);
                translate([0, 0, housing_h - 0.1])
                    linear_extrude(0.1) teardrop_2d(hr_out, td_tip_r, td_tip_cx);
            }
        }
    }
}

module housing() {
  union() {
    lobe_ramp();
    difference() {
        // OUTER: round bottom → teardrop top
        union() {
            cylinder(h = td_flare_z, d = 2 * hr_out);
            hull() {
                translate([0, 0, td_flare_z])
                    cylinder(d = 2 * hr_out, h = 0.1);
                translate([0, 0, housing_h - 0.1])
                    linear_extrude(0.1) teardrop_2d(hr_out, td_tip_r, td_tip_cx);
            }
        }

        // CAVITY: round bottom (round wheel clearance) → teardrop-inner top
        union() {
            translate([0, 0, end_wall])
                cylinder(h = td_flare_z - end_wall + 0.1, d = 2 * hr_in);
            hull() {
                translate([0, 0, td_flare_z])
                    cylinder(d = 2 * hr_in, h = 0.1);
                translate([0, 0, housing_h + 1])
                    linear_extrude(0.1)
                        teardrop_2d(hr_in, td_tip_r - housing_wall, td_tip_cx);
            }
        }

        // central axle bore
        translate([0, 0, -1])
            cylinder(h = end_wall + 2, d = axle_d + fit_clear * 2);

        // OUTLET — rounded-rect hole through floor. The two TANGENTIAL edges
        // (the ones the paddle crosses as it sweeps) are SLOPED: nominal at
        // the exit (bottom), wider tangentially at the top (wheel side), so
        // the paddle/kibble ride a ramp. The radial edges stay vertical; the
        // outer edge is at r=35 (clear of the rim) so the paddle tip never
        // meets it.
        rotate([0, 0, outlet_angle_deg])
            translate([hole_mid_r, 0, 0])
                hull() {
                    translate([0, 0, -1])
                        rounded_rect(hole_len, hole_w, hole_corner_r, 0.5);
                    translate([0, 0, end_wall + 0.5])
                        rounded_rect(hole_len, hole_w + 2*out_cham,
                                     hole_corner_r, 0.5);
                }

        // REBATE — cut the inner rim down to a ledge, leaving the outer
        // teardrop LIP (rab_w wide) at full height. The cap nests in here.
        translate([0, 0, housing_h - rab_d])
            linear_extrude(rab_d + 1)
                offset(-rab_w) teardrop_2d(hr_out, td_tip_r, td_tip_cx);
    }
  }
}

// ===========================================================================
// END_CAP  disc + lip + axle bore + inlet ROUNDED-RECT hole +
//          rectangular COLLAR (fence) around the hole on top
//
// Collar replaces the old boss-socket. The hopper sits ON the cap top
// surface (around the hole), with the collar surrounding its outer edge.
// No socket, no shelf, no wall narrowing of the kibble flow.
// Collar is intersected with the cap disc so its corners cannot overhang
// the cap OD.
// ===========================================================================
module end_cap() {
    // 2026-06-06: TEARDROP cap that NESTS into the housing rebate. Its
    // teardrop is inset by (rab_w + cap_clear) so it drops inside the
    // housing lip; the disc is (end_wall + rab_d) thick so its bottom rab_d
    // sits in the cut while its top stays flush with the old rim height
    // (collar/funnel unchanged). The teardrop blocks rotation; the lip
    // captures it laterally. No pins, no holes.
    cap_t = end_wall + rab_d;
    difference() {
        union() {
            // inset teardrop disc (nests into the rebate)
            linear_extrude(cap_t) cap_outline();
            // collar fence around the inlet (clipped within the inset disc)
            intersection() {
                translate([0, 0, cap_t])
                    linear_extrude(collar_h)
                        difference() {
                            offset(hopper_wall + collar_clear + collar_wall) inlet_2d();
                            offset(hopper_wall + collar_clear) inlet_2d();
                        }
                linear_extrude(cap_t + collar_h + 1) cap_outline();
            }
        }

        // central axle bore (in the solid front of the cap — top guide)
        translate([0, 0, -1])
            cylinder(h = cap_t + 2, d = axle_d + fit_clear * 2);

        // INLET through-hole
        translate([0, 0, -1])
            linear_extrude(cap_t + 2) inlet_2d();
        // collar interior above the cap — accepts the funnel plug
        translate([0, 0, cap_t + 0.5])
            linear_extrude(collar_h + 1)
                offset(hopper_wall + collar_clear) inlet_2d();
    }
}

// ===========================================================================
// HOPPER  small test hopper — open-bottom rect-to-round cone.
//         Bottom inner = hole size (= flow area). Sits ON the cap, inside
//         the collar. No spout cube below.
// ===========================================================================
module hopper() {
    // 2026-05-28 fix: added a straight rect plug at the bottom that fits
    // INTO the cap collar (which has straight vertical walls of height
    // collar_h). The taper used to start at z=0, conflicting with the
    // collar geometry immediately above z=0.
    overshoot = 2;
    difference() {
        union() {
            // Straight rect plug (height = collar_h) — slides into the cap collar
            rounded_rect(hopper_outer_len, hopper_outer_w,
                         hole_corner_r + hopper_wall, collar_h);
            // Tapered cone above the collar height
            hull() {
                translate([0, 0, collar_h])
                    rounded_rect(hopper_outer_len, hopper_outer_w,
                                 hole_corner_r + hopper_wall, 0.5);
                translate([0, 0, hopper_h - 0.5])
                    cylinder(d = hopper_top_d, h = 0.5);
            }
        }
        // Inner cavity (open at both ends)
        union() {
            // Straight inner bottom (= cap hole shape)
            translate([0, 0, -overshoot])
                rounded_rect(hole_len, hole_w, hole_corner_r,
                             collar_h + overshoot + 0.5);
            // Tapered inner above
            hull() {
                translate([0, 0, collar_h])
                    rounded_rect(hole_len, hole_w, hole_corner_r, 0.5);
                translate([0, 0, hopper_h + overshoot - 0.5])
                    cylinder(d = hopper_top_d - 2 * hopper_wall, h = 0.5);
            }
        }
    }
}

// ===========================================================================
// RENDER
// ===========================================================================
if (part == "wheel")   wheel();
if (part == "axle")    axle();
if (part == "housing") housing();
if (part == "end_cap") end_cap();
if (part == "hopper")  hopper();
if (part == "assembly") {
    color("Silver")
        translate([0, 0, end_wall + floor_clear]) wheel();
    color("DimGray")
        translate([0, 0, -axle_stub_bot]) axle();
    color("LightBlue", 0.28)
        housing();
    color("LightSteelBlue", 0.55)
        translate([0, 0, housing_h - rab_d]) end_cap();  // nests into the rebate
    // hopper sits ON the cap (z = housing_h + end_wall = cap top),
    // offset to inlet_angle_deg, radial offset hole_mid_r
    color("Khaki", 0.55)
        rotate([0, 0, inlet_angle_deg])
            translate([hole_mid_r, 0, housing_h + end_wall])
                hopper();
}

echo(str("hole=", hole_len, "x", hole_w, " r=", hole_corner_r,
         " at r_mid=", hole_mid_r,
         " collar_outer=", collar_outer_len, "x", collar_outer_w,
         " hopper_outer=", hopper_outer_len, "x", hopper_outer_w,
         " pocket_mL~", round((wheel_r*wheel_r - hub_r*hub_r) * 3.14159 / n_paddles * wheel_thickness / 1000)));
