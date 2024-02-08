include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <mount.scad>

$slop = 0.2;
$fa = 1;
$fs = 0.25;

cap_d = 30;
cap_inset = 1;
post_d = 25;
post_h = 10;

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
                post_h + cap_inset + pad
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
);

back(40)
mount(
    cap_d = cap_d,
    post_d = post_d,
    post_h = post_h,
    cap_h = 5
);