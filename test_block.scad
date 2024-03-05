include <BOSL2/std.scad>
use <mount.scad>

$slop = 0.1;
$fs = $preview ? 2 : 0.1;
$fa = $preview ? 20 : 0.5;

/* [Dowel Mount] */
// Diameter of the "cap" (widest part of the mount)
cap_d = 30;
// Height of the cap
cap_h = 12.5;
// Diameter of the screw part
post_h = 12;
// Height of the screw part
post_d = 25;
// Depth which the dowel mount cap sinks into the arm
cap_inset = 1;

module test_block(
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 10,
    pad = 2,
    chamfer = 1,
    eps = 0.01,
    anchor, spin, orient
) {
    slop = get_slop();
    attachable(
        anchor, spin, orient,
        size = [cap_d + pad * 2, cap_d + pad * 2, post_h + cap_inset]
    ) {
        diff("socket")
        cuboid(
            [
                cap_d + pad * 2,
                cap_d + pad * 2,
                post_h + cap_inset - eps
            ],
            chamfer = chamfer
        )
        tag("socket")
        position(TOP)
        up(eps)
        mount_insert(
            cap_d = cap_d,
            cap_inset = cap_inset,
            post_d = post_d,
            post_h = post_h + eps,
            anchor = TOP
        );

        children();
    }
}

test_block(
    cap_d = cap_d,
    cap_inset = cap_inset,
    post_d = post_d,
    post_h = post_h,
    anchor = BOTTOM,
);

back(40)
mount(
    cap_d = cap_d,
    post_d = post_d,
    post_h = post_h,
    cap_h = cap_h,
    tab_count = 4,
    tab_thickness = 1,
    anchor = BOTTOM,
);