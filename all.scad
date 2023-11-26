include <BOSL2/std.scad>
include <BOSL2/threading.scad>

use <mount.scad>
use <test_block.scad>
use <legs.scad>

show_cutout = false;

$slop = 0.1;
$fs = $preview ? 2 : 0.5;
$fa = $preview ? 20 : 5;

cap_h = 12.5;
cap_d = 30;
cap_inset = 1;
post_h = 12.5;
post_d = 25;
nodes_per_arm = 4;
node_d = 40;
node_spread = 50;

if (show_cutout) {
    color("gray")
    projection(cut=true) yrot(0) {
        test_block(
            cap_d = cap_d,
            cap_inset = 1,
            post_d = post_d,
            post_h = post_h,
            pad = 2,
            chamfer = 1,
            orient=BACK,
            anchor=BOTTOM
        );

        yrot(180)
        xrot(180)
        mount(
            cap_d = cap_d,
            cap_h = cap_h,
            post_d = post_d,
            post_h = post_h,
            dowel_size = 5 / 8 * INCH,
            crush_rib_size = 1,
            crush_rib_count = 20,
            orient=BACK,
            anchor=TOP
        );
    }
} else {
    test_block(
        cap_d = cap_d,
        cap_inset = cap_inset,
        post_d = post_d,
        post_h = post_h,
        pad = 2,
        chamfer = 1
    );

    back(40)
    mount(
        cap_d = cap_d,
        cap_h = cap_h,
        post_d = post_d,
        post_h = post_h,
        dowel_size = 5 / 8 * INCH,
        crush_rib_size = 1,
        crush_rib_count = 20
    );

    back(80)
    bottom_leg(
        n = nodes_per_arm,
        node_d = node_d,
        node_spread = node_spread,
        cap_d = cap_d,
        cap_inset = cap_inset,
        post_d = post_d,
        post_h = post_h
    );

    back(140)
    middle_leg(
        n = nodes_per_arm,
        node_d = node_d,
        node_spread = node_spread,
        cap_d = cap_d,
        cap_inset = cap_inset,
        post_d = post_d,
        post_h = post_h
    );

    back(200)
    top_leg(
        n = nodes_per_arm,
        node_d = node_d,
        node_spread = node_spread,
        cap_d = cap_d,
        cap_inset = cap_inset,
        post_d = post_d,
        post_h = post_h
    );
}