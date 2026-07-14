// Gallery / section views for the assembly guide. NOT a printable part.
// Each coloured piece is cut INDIVIDUALLY. Wrapping one intersection() around a
// multi-colour union makes OpenCSG flatten the whole thing to a single hue.
include <bulk_hopper_module.scad>
use <paddle_wheel_module.scad>
// AFTER the include: it re-assigns part="assembly" and would draw its own assembly on
// top of every view here. Last assignment wins, so this kills that dispatch.
part = "none";

view = "product";
cut  = "none";        // none | slab | xhalf | yhalf

module CUT() {
    if (cut == "none")  translate([-300, -300, -300]) cube([600, 600, 600]);
    if (cut == "slab")  translate([-120, -120, 14])   cube([240, 240, 8]);   // through the bay
    if (cut == "xhalf") translate([-300, -300, -60])  cube([300, 600, 400]); // keep x<0
    if (cut == "yhalf") translate([-300, -300, -60])  cube([600, 300, 400]); // keep y<0
}
module piece(c, a = 1) { color(c, a) intersection() { children(); CUT(); } }

module product_pieces() {
    piece("#B9BFC6")       base();                                     // base_motor + base_hopper
    piece("#2E6FA8")       el_tray_mounted();                          // electronics tray
    piece("#C0432B")       el_panel();                                 // service panel
    piece("#8FA6BC", 0.8)  translate([0, 0, base_motor_h]) housing();  // rotary housing
    piece("#9AA0A6")       translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
    piece("#D9C88A", 0.85) translate([0, 0, base_h]) funnel();         // shell + cone + cap
    piece("#B23A48", 0.9)  translate([0, 0, base_h + cap_t - nest_h + cap_collar_h]) spider();
    piece("#C7A96B")       translate([0, 0, base_h + z_funnel_top]) ring();
    piece("#A88756")       translate([0, 0, base_h + z_funnel_top + ring_h]) lid();
    piece("#4A4F55")       cell_mock();                                // load cell (bought)
    piece("#E0D4B4")       cell_platform();
    piece("#6FA8C7", 0.85) tray_mounted();                             // feed tray
    piece("#3A3F45", 0.9)  motor_mock(base_deck_z);                    // NEMA17 (bought)
}
module base_pieces() {
    piece("#B9BFC6")       base();
    piece("#2E6FA8")       el_tray_mounted();
    piece("#C0432B")       el_panel();
    piece("#3A3F45", 0.9)  motor_mock(base_deck_z);
    piece("#4A4F55")       cell_mock();
    piece("#E0D4B4")       cell_platform();
    piece("#6FA8C7", 0.85) tray_mounted();
}

// food path: base + mechanism + funnel, no ring/lid (so the cut zooms in on the drop)
module food_pieces() {
    piece("#B9BFC6")       base();
    piece("#8FA6BC", 0.8)  translate([0, 0, base_motor_h]) housing();
    piece("#9AA0A6")       translate([throat_cx, 0, base_motor_h + 3.5]) wheel();
    piece("#D9C88A", 0.85) translate([0, 0, base_h]) funnel();
    piece("#4A4F55")       cell_mock();
    piece("#E0D4B4")       cell_platform();
    piece("#6FA8C7", 0.85) tray_mounted();
    piece("#3A3F45", 0.9)  motor_mock(base_deck_z);
}
if (view == "product") product_pieces();
if (view == "base")    base_pieces();
if (view == "food")    food_pieces();

// J2 bayonet close-up: shell tabs + base L-slots, exploded a little
module bayonet_pieces() {
    piece("#C7A96B", 0.30) translate([0, 0, base_h + 18]) funnel_shell();   // shell lifted, tabs visible
    piece("#B9BFC6")       base();                                          // base with the slotted lip
}
if (view == "bayonet") bayonet_pieces();

// tray alone, cut across Y, to show the low back ramp wall
if (view == "trayramp") color("#6FA8C7") intersection() { tray(); translate([-200,-200,-5]) cube([400,200,60]); }
