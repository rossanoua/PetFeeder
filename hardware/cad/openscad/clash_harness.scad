// Assembly interference harness for the form-1a tower.
// Places each printed part in its ASSEMBLED global pose (mirrors funnel()/full),
// then exports either one part (mode="solo") or the intersection of two
// (mode="pair"). A driver measures the intersection volume per pair.
//
//   openscad -o out.stl -D 'part="__h__"' -D 'mode="solo"' -D 'a="cone"' clash_harness.scad
//   openscad -o out.stl -D 'part="__h__"' -D 'mode="pair"' -D 'a="cone"' -D 'b="shell"' clash_harness.scad
//
// part="__h__" is a sentinel so the included file's own dispatch renders nothing.
include <bulk_hopper_module.scad>

mode = "solo";
a = "";
b = "";

// Coarser tessellation than the print file (global was 96) — plenty for clash
// detection and much faster CGAL booleans. Textually after the include, so it
// wins the global; module-local $fn=160 bayonet features keep their own density.
$fn = 64;

// Assembled pose of each part in GLOBAL coordinates.
// Funnel stack (authoritative = module funnel()): shell z0, cap -nest_h,
// cone cap_t-nest_h; the whole funnel is placed at base_h in full/full_norings.
module A(name) {
    if      (name == "shell")         translate([0,0,base_h])                 funnel_shell();
    else if (name == "cap")           translate([0,0,base_h - nest_h])        cap_plate();
    else if (name == "cone")          translate([0,0,base_h + cap_t - nest_h]) funnel_cone();
    else if (name == "spider")        translate([0,0,base_h + cap_t - nest_h]) spider();
    else if (name == "lid")           translate([0,0,base_h + z_funnel_top])  lid();
    else if (name == "base_motor")    base_motor();
    else if (name == "base_hopper")   base_hopper();
    else if (name == "el_tray")       el_tray_mounted();
    else if (name == "el_panel")      el_panel();
    else if (name == "cell_platform") cell_platform();
    else if (name == "tray")          tray_mounted();
    else if (name == "housing")       translate([0,0,base_motor_h])                 housing();
    else if (name == "wheel")         translate([throat_cx,0,base_motor_h + 3.5])   wheel();
    else echo(str("UNKNOWN PART: ", name));
}

// path mode: displace the MOVING part a by [tx,ty,tz] from its seated pose and
// intersect against the seated obstacle b. Sampling [tx,ty,tz] along the
// insertion vector traces the assembly trajectory — a volume spike at a
// non-seated sample means the part jams on the way in (swept-path collision).
tx = 0; ty = 0; tz = 0;

// spin mode: rotate the moving part a about global Z by `ang` degrees (bayonet
// lock/unlock travel) and intersect against the seated obstacle b. A volume
// spike at a non-seated angle = tabs jam mid-twist.
ang = 0;

if (mode == "solo")      A(a);
else if (mode == "pair") intersection() { A(a); A(b); }
else if (mode == "path") intersection() { translate([tx,ty,tz]) A(a); A(b); }
else if (mode == "spin") intersection() { rotate([0,0,ang]) A(a); A(b); }
