// Assembly animation for the form-1a tower.
// Each part flies from an exploded approach offset into its SEATED pose along the
// physically-verified insertion vector (see clash_harness.scad + the swept-path
// drivers). Order is bottom-up build order; the lid does a straight drop then a
// +20 deg -> 0 deg bayonet twist to lock.
//
//   xvfb-run -a openscad -o frame.png --animate 120 --imgsize=900,680 \
//       --camera=0,18,104,58,0,26,690 assembly_anim.scad
//
// Preview (throwntogether) render — no CGAL, so it is fast. part="__h__" is the
// sentinel that keeps the included file's own dispatch from drawing anything.
include <bulk_hopper_module.scad>
part = "__h__";
$fn = 48;                     // preview density; plenty for a motion video

// --- seated global poses (mirror clash_harness.scad / funnel() / full_norings) ---
// Colour per part (matches full/step palette) so each piece reads as it seats.
module A(name) {
    if      (name == "shell")         color("Khaki")          translate([0,0,base_h])                       funnel_shell();
    else if (name == "cap")           color("MediumSeaGreen") translate([0,0,base_h - nest_h])              cap_plate();
    else if (name == "cone")          color("Orange")         translate([0,0,base_h + cap_t - nest_h])      funnel_cone();
    else if (name == "spider")        color("MediumPurple")   translate([0,0,base_h + cap_t - nest_h])      spider();
    else if (name == "lid")           color("Tan")            translate([0,0,base_h + z_funnel_top])        lid();
    else if (name == "ring")          color("BurlyWood")      translate([0,0,base_h + z_funnel_top])        ring();          // J2 onto funnel top lip
    else if (name == "lid_on_ring")   color("Tan")            translate([0,0,base_h + z_funnel_top + ring_h]) lid();          // lid caps the ring
    else if (name == "base_motor")    color("Gainsboro")      base_motor();
    else if (name == "base_hopper")   color("Gold")           base_hopper();
    else if (name == "el_tray")       color("SteelBlue")      el_tray_mounted();
    else if (name == "el_panel")      color("Tomato")         el_panel();
    else if (name == "cell_platform") color("Wheat")          cell_platform();
    else if (name == "tray")          color("LightBlue")      tray_mounted();
    else if (name == "housing")       color("LightSteelBlue") translate([0,0,base_motor_h])                 housing();
    else if (name == "wheel")         color("Silver")         translate([throat_cx,0,base_motor_h + 3.5])   wheel();
}

// cosine ease-in-out: 0 before window a, 1 after window b, smooth between.
function prog(a,b) = $t <= a ? 0 : $t >= b ? 1 : (0.5 - 0.5*cos(180*($t-a)/(b-a)));

// place `name`: HIDDEN until its window opens at `a`, then slides from the
// approach offset (ox,oy,oz) into its seat across [a,b]. Progressive build —
// only the in-flight part is aloft, everything earlier is already seated.
module place(name, ox,oy,oz, a,b) {
    if ($t >= a) {
        p = prog(a,b);
        translate([ox*(1-p), oy*(1-p), oz*(1-p)]) A(name);
    }
}

// --- build sequence (windows tile [0,1]); offsets follow the verified vectors ---
A("base_motor");                                        // ground — static
place("base_hopper",    0,  0,  70,   0.00, 0.08);      // drop from above
// Electronics/tray parts (el_tray, el_panel, cell_platform, tray) are intentionally
// omitted from THIS fit-review video — they are peripheral to the refactor under
// review (ring bayonet + base bevels) and their drawer poses clutter the frame.
// The mechanical dosing stack below is what items 1 & 3 actually touch.
place("housing",        0,  0,  80,   0.08, 0.20);      // over the base centre
place("wheel",          0,  0,  80,   0.20, 0.30);      // drop INTO the housing
place("cap",            0,  0,  80,   0.30, 0.42);      // onto the housing top
place("cone",           0,  0,  75,   0.42, 0.54);      // onto the cap
place("shell",          0,  0,  85,   0.54, 0.66);      // big tube down over cone
place("spider",         0,  0,  75,   0.66, 0.74);      // into the cone pockets

// ring (J2, item 1): straight drop onto the funnel top lip, then a +bay_run -> 0
// bayonet twist so its underside tabs sweep the slot channel and seat under the lip.
if ($t >= 0.74) {
    ring_drop  = prog(0.74, 0.82);
    ring_twist = prog(0.82, 0.88);
    translate([0,0, 60*(1-ring_drop)])
        rotate([0,0, bay_run*(1-ring_twist)])
            A("ring");
}

// lid: drops onto the RING (held unlocked at +bay_run), then twists +bay_run -> 0
// to lock its J2 into the ring's top lip.
if ($t >= 0.88) {
    lid_drop  = prog(0.88, 0.94);
    lid_twist = prog(0.94, 1.00);
    translate([0,0, 55*(1-lid_drop)])
        rotate([0,0, bay_run*(1-lid_twist)])
            A("lid_on_ring");
}
