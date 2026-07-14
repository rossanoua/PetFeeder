// Interference / fit checks. MUST live NEXT TO the module: include<> resolves relative to
// the INCLUDING FILE, not the cwd — a check file in /tmp silently gets undef everything
// and every intersection comes out empty, which reads as "clear". It bit me once.
include <bulk_hopper_module.scad>
use <paddle_wheel_module.scad>
part = "none";
chk = "";
module tabs(rot=0) rotate([0,0,rot]) translate([0,0,base_h]) for(i=[0:bay_n-1]) bay_tab(i);

// --- form-1a fit (RE-RUN: the originals were run from /tmp and were bogus) ---
if (chk=="tray_motor")  intersection() { tray_mounted(); base_motor(); }
if (chk=="tray_disc")   intersection() { tray_mounted(); base_hopper(); }
if (chk=="plat_motor")  intersection() { cell_platform(); base_motor(); }
if (chk=="cell_nema")   intersection() { cell_mock(); motor_mock(base_deck_z); }
if (chk=="ped_nema")    intersection() { cell_pedestal(); motor_mock(base_deck_z); }
if (chk=="sole_nema")   intersection() { base_sole(); motor_mock(base_deck_z); }
if (chk=="tray_eltray") intersection() { tray_mounted(); el_tray_mounted(); }
if (chk=="eltray_motor")intersection() { el_tray_mounted(); base_motor(); }
if (chk=="panel_motor") intersection() { el_panel(); base_motor(); }
if (chk=="eltray_nema") intersection() { el_tray_mounted(); motor_mock(base_deck_z); }

// --- J2 bayonet ---
if (chk=="bay_entry")   intersection() { base_hopper(); tabs(0); }          // want EMPTY
if (chk=="bay_locktab") intersection() { base_hopper(); tabs(-bay_run); }   // want EMPTY
if (chk=="bay_lockover")                                                    // want NON-empty
    intersection() {
        base_hopper();
        rotate([0,0,-bay_run]) translate([0,0,base_h]) for(i=[0:bay_n-1])
            rotate([0,0,i*360/bay_n]) rotate_extrude(angle=bay_tab_ang, $fn=160)
                translate([bay_tab_ir, bay_tab_z+bay_tab_h+bay_slip]) square([bay_tab_r, 3]);
    }
if (chk=="bay_detent")  intersection() { base_hopper(); tabs(-bay_run/2); } // want NON-empty
if (chk=="shell_lip")   intersection() { translate([0,0,base_h]) funnel_shell(); base_hopper(); }
// J4 detents attached to cap? intersect the detent band with the rest of the cap
if(chk=="cap_nestdet") intersection() {
    cap_plate();
    translate([0,0,nest_h-1.4]) linear_extrude(0.7)
        difference() { offset(nest_clear) teardrop_2d(pw_hr_out,pw_td_tip_r,pw_td_tip_cx);
                       offset(nest_clear-nest_det) teardrop_2d(pw_hr_out,pw_td_tip_r,pw_td_tip_cx); }
}

// --- L1 lid bayonet onto the ring lip ---
module lid_tabs(rot=0) rotate([0,0,rot]) translate([0,0,ring_h]) for(i=[0:bay_n-1]) bay_tab_lid(i);
if(chk=="lid_entry")  intersection() { ring(); lid_tabs(0); }         // want EMPTY (tab in channel)
if(chk=="lid_locktab")intersection() { ring(); lid_tabs(-bay_run); }  // want EMPTY (tab in the run)
if(chk=="lid_lockover")                                               // want NON-empty (roof over tab)
    intersection() {
        ring();
        rotate([0,0,-bay_run]) translate([0,0,ring_h]) for(i=[0:bay_n-1])
            rotate([0,0,i*360/bay_n]) rotate_extrude(angle=bay_tab_ang, $fn=160)
                translate([bay_tab_ir, bay_tab_z+bay_tab_h+bay_slip]) square([bay_tab_r, 3]);
    }
