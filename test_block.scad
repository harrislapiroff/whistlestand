include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <mount.scad>

module test_block(
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 30,
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
                post_h + cap_inset
            ],
            chamfer = chamfer
        )
        tag("socket")
        mount_insert(
            cap_d = cap_d,
            cap_inset = cap_inset,
            post_d = post_d,
            post_h = post_h + eps
        );

        children();
    }
}

test_block();