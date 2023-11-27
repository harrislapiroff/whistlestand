include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <BOSL2/rounding.scad>
use <mount.scad>

// TODO Check that the rotation of threads on the middle section align
// TODO slope the external pegs so they don't break off
// TODO lower the thread pitch so they lock? or find a better way to lock the legs together?

$slop = 0.1;
$fs = $preview ? 2 : 0.5;
$fa = $preview ? 20 : 2;

module leg_solid(
    n = 4,
    node_d = 50,
    node_spread = 70,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 9,
    anchor, spin, orient
) {
    shadow = union([
        for (i = [0 : 1 : n - 2])
        left(i * node_spread, glued_circles(d = node_d, spread = node_spread))
    ]);

    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            post_h + cap_inset
        ]
    ) {
        right(node_spread * (n - 2) / 2)
        down((post_h + cap_inset) / 2)
        offset_sweep(
            shadow,
            height = post_h + cap_inset,
            top = os_chamfer(1),
            bottom = os_chamfer(1)
        );
        children();
    }
}

module leg_with_post_inserts(
    n = 4,
    node_d = 50,
    node_spread = 70,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 9,
    post_rotate = 0,
    eps = 0.01,
    anchor, spin, orient
) {
    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            post_h + cap_inset
        ]
    ) {
        diff("sockets")
        leg_solid(
            n = n,
            node_d = node_d,
            node_spread = node_spread,
            cap_d = cap_d,
            cap_inset = cap_inset,
            post_d = post_d,
            post_h = post_h
        )
        tag("sockets")
        position(LEFT) {
            for (i = [0 : 1 : n - 1])
            right(node_d / 2 + i * node_spread)
            zrot(post_rotate)
            mount_insert(
                post_d = post_d,
                post_h = post_h + 2 * eps,
                cap_d = cap_d,
                cap_inset = cap_inset
            );
        };
        children();
    }
}

module bottom_leg(
    n = 4,
    node_d = 50,
    node_spread = 70,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 9,
    eps = 0.01,
    anchor, spin, orient
) {
    slop = get_slop();
    
    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            post_h + cap_inset
        ]
    ) {
        diff("remove", "keep")
        leg_with_post_inserts(
            n = n,
            node_d = node_d,
            node_spread = node_spread,
            cap_d = cap_d,
            cap_inset = cap_inset,
            post_d = post_d,
            post_h = post_h
        )
        {
            // Remove 2/3 of place where it will join the other legs
            tag("remove")
            position(LEFT + TOP)
            up(eps)
            left(eps + slop)
            cyl(
                d = node_d + 2 * eps + 2 * slop,
                h = (post_h + cap_inset) * 2 / 3 + eps,
                anchor = LEFT + TOP
            );

            // Pegs to join the legs
            tag("keep")
            position(LEFT + BOTTOM)
            right(node_d / 2)
            up((post_h + cap_inset) / 3 - eps)
            zrot(-90)
            pegs(
                h = 1,
                d = 3,
                spread_d = (node_d + post_d) / 2,
                anchor = BOTTOM
            );

            tag("remove")
            position(LEFT + BOTTOM)
            right(node_d / 2)
            up((post_h + cap_inset) / 3 + eps)
            zrot(90)
            pegs(
                h = 1,
                d = 3 + slop * 2,
                spread_d = (node_d + post_d) / 2,
                anchor = TOP
            );
        }
        children();
    }
}

module middle_leg(
    n = 4,
    node_d = 50,
    node_spread = 70,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 9,
    eps = 0.01,
    anchor, spin, orient
) {
    slop = get_slop();
    
    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            post_h + cap_inset
        ]
    ) {
        diff("remove", "keep")
        leg_with_post_inserts(
            n = n,
            node_d = node_d,
            node_spread = node_spread,
            cap_d = cap_d,
            cap_inset = cap_inset,
            post_d = post_d,
            post_h = post_h,
            post_rotate = 120
        )
        {
            // Remove 2/3 of place where it will join the other legs
            tag("remove")
            position(LEFT + BOTTOM)
            down(eps)
            left(eps + slop)
            cyl(
                d = node_d + 2 * eps + 2 * slop,
                h = (post_h + cap_inset) / 3 + eps,
                anchor = LEFT + BOTTOM
            );

            tag("remove")
            position(LEFT + TOP)
            up(eps)
            left(eps + slop)
            cyl(
                d = node_d + 2 * eps + 2 * slop,
                h = (post_h + cap_inset) / 3 + eps,
                anchor = LEFT + TOP
            );

            // Pegs to join the legs
            tag("keep")
            position(LEFT + BOTTOM)
            right(node_d / 2)
            up((post_h + cap_inset) / 3 - 1 + eps)
            zrot(90)
            pegs(
                h = 1,
                d = 3,
                spread_d = (node_d + post_d) / 2,
                anchor = BOTTOM
            );

            tag("remove")
            position(LEFT + BOTTOM)
            right(node_d / 2)
            up((post_h + cap_inset) / 3 - eps)
            zrot(-90)
            pegs(
                h = 1,
                d = 3 + slop * 2,
                spread_d = (node_d + post_d) / 2,
                anchor = BOTTOM
            );

            tag("keep")
            position(LEFT + TOP)
            right(node_d / 2)
            down((post_h + cap_inset) / 3 - 1 + eps)
            zrot(90)
            pegs(
                h = 1,
                d = 3,
                spread_d = (node_d + post_d) / 2,
                anchor = TOP
            );

            tag("remove")
            position(LEFT + TOP)
            right(node_d / 2)
            down((post_h + cap_inset) / 3 - eps)
            zrot(-90)
            pegs(
                h = 1,
                d = 3 + slop * 2,
                spread_d = (node_d + post_d) / 2,
                anchor = TOP
            );
        }
        children();
    }
}

module top_leg(
    n = 4,
    node_d = 50,
    node_spread = 70,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 9,
    eps = 0.01,
    anchor, spin, orient
) {
    slop = get_slop();
    
    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            post_h + cap_inset
        ]
    ) {
        diff("remove", "keep")
        leg_with_post_inserts(
            n = n,
            node_d = node_d,
            node_spread = node_spread,
            cap_d = cap_d,
            cap_inset = cap_inset,
            post_d = post_d,
            post_h = post_h,
            post_rotate = 240
        )
        {
            // Remove 2/3 of place where it will join the other legs
            tag("remove")
            position(LEFT + BOTTOM)
            down(eps)
            left(eps + slop)
            cyl(
                d = node_d + 2 * eps + 2 * slop,
                h = (post_h + cap_inset) * 2 / 3 + eps,
                anchor = LEFT + BOTTOM
            );

            // Pegs to join the legs
            tag("keep")
            position(LEFT + TOP)
            right(node_d / 2)
            down((post_h + cap_inset) / 3 - eps)
            zrot(-90)
            pegs(
                h = 1,
                d = 3,
                spread_d = (node_d + post_d) / 2,
                anchor = TOP
            );

            tag("remove")
            position(LEFT + TOP)
            right(node_d / 2)
            down((post_h + cap_inset) / 3 + eps)
            zrot(90)
            pegs(
                h = 1,
                d = 3 + slop * 2,
                spread_d = (node_d + post_d) / 2,
                anchor = BOTTOM
            );
        }
        children();
    }
}

module pegs(
    n = 3,
    d = 3,
    h = 3,
    spread_d = 10,
    anchor, spin, orient
) {
    attachable(
        anchor, spin, orient,
        d = spread_d + d,
        h = h
    ) {
        zrot_copies(n = n)
        back(spread_d / 2)
        cyl(d = d, h = h);

        children();
    }
}

top_leg(
    n = 2,
    node_d = 40,
    node_spread = 50,
    anchor = BOTTOM + LEFT
);

back(100)
middle_leg(
    n = 2,
    node_d = 40,
    node_spread = 50,
    anchor = BOTTOM + LEFT
);

back(200)
bottom_leg(
    n = 2,
    node_d = 40,
    node_spread = 50,
    anchor = BOTTOM + LEFT
);
