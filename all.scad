include <BOSL2/std.scad>
include <BOSL2/threading.scad>

use <mount.scad>
use <test_block.scad>

show_cutout = false;

$slop = 0.1;
$fs = $preview ? 2 : 0.5;
$fa = $preview ? 20 : 5;

post_h = 9;
cap_h = 15;

if (show_cutout) {
    color("gray")
    projection(cut=true) yrot(0) {
        test_block(
            cap_d = 30,
            cap_inset = 1,
            post_d = 25,
            post_h = post_h,
            pad = 2,
            chamfer = 1,
            orient=BACK,
            anchor=BOTTOM
        );

        yrot(180)
        xrot(180)
        mount(
            cap_d = 30,
            cap_h = cap_h,
            post_d = 25,
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
        cap_d = 30,
        cap_inset = 1,
        post_d = 25,
        post_h = post_h,
        pad = 2,
        chamfer = 1
    );

    back(40)
    mount(
        cap_d = 30,
        cap_h = cap_h,
        post_d = 25,
        post_h = post_h,
        dowel_size = 5 / 8 * INCH,
        crush_rib_size = 1,
        crush_rib_count = 20
    );
}