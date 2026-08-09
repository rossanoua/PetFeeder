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
module A(name) {
    if      (name == "shell")         translate([0,0,base_h])                       funnel_shell();
    else if (name == "cap")           translate([0,0,base_h - nest_h])              cap_plate();
    else if (name == "cone")          translate([0,0,base_h + cap_t - nest_h])      funnel_cone();
    else if (name == "spider")        translate([0,0,base_h + cap_t - nest_h])      spider();
    else if (name == "lid")           translate([0,0,base_h + z_funnel_top])        lid();
    else if (name == "base_motor")    base_motor();
    else if (name == "base_hopper")   base_hopper();
    else if (name == "el_tray")       el_tray_mounted();
    else if (name == "el_panel")      el_panel();
    else if (name == "cell_platform") cell_platform();
    else if (name == "tray")          tray_mounted();
    else if (name == "housing")       translate([0,0,base_motor_h])                 housing();
    else if (name == "wheel")         translate([throat_cx,0,base_motor_h + 3.5])   wheel();
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
place("el_tray",        0,  0,  70,   0.06, 0.14);      // down into el_rails
place("el_panel",     -60,  0,   0,   0.12, 0.20);      // radially in (+x)
place("cell_platform",120,  0,   0,   0.18, 0.28);      // drawer in (-x)
place("tray",         130,  0,   0,   0.26, 0.36);      // drawer over platform
place("housing",        0,  0,  80,   0.34, 0.44);      // over the base centre
place("wheel",          0,  0,  80,   0.42, 0.50);      // drop INTO the housing
place("cap",            0,  0,  80,   0.50, 0.58);      // onto the housing top
place("cone",           0,  0,  75,   0.57, 0.66);      // onto the cap
place("shell",          0,  0,  85,   0.65, 0.76);      // big tube down over cone
place("spider",         0,  0,  75,   0.75, 0.83);      // into the cone pockets

// lid: appears at 0.83, straight drop (held unlocked at +20 deg), then twist
// +20 -> 0 to lock the bayonet.
if ($t >= 0.83) {
    lid_drop  = prog(0.83, 0.92);
    lid_twist = prog(0.92, 1.00);
    translate([0,0, 70*(1-lid_drop)])
        rotate([0,0, 20*(1-lid_twist)])
            A("lid");
}
