include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <BOSL2/rounding.scad>
use <mount.scad>

$slop = 0.1;
$fs = $preview ? 2 : 0.5;
$fa = $preview ? 20 : 2;

// Bottom to top -- should sum to 1
leg_height_ratios = [ 0.5, 0.25, 0.25 ];

render_connected = false;

module leg_solid(
    n = 4,
    node_d = 40,
    node_spread = 50,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 12,
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
        down((post_h + cap_inset) / 2)
        right(node_spread * (n - 2) / 2)
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
    node_d = 40,
    node_spread = 50,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 12,
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
                cap_inset = cap_inset,
            );
        };
        children();
    }
}

module bottom_leg(
    n = 4,
    node_d = 40,
    node_spread = 50,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 12,
    cutaway_chamfer = 0.5,
    alignment_post_d = 7,
    supports = true, // Has no effect, no supports needed
    eps = 0.01,
    anchor, spin, orient
) {
    slop = get_slop();
    solid_height = post_h + cap_inset;
    cutaway_d = node_d + 2 * cutaway_chamfer + 2 * slop;
    cutaway_h = solid_height * (1 - leg_height_ratios[0]) + eps;

    tag_scope()
    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            solid_height
        ]
    ) {
        diff("remove")
        leg_with_post_inserts(
            n = n,
            node_d = node_d,
            node_spread = node_spread,
            cap_d = cap_d,
            cap_inset = cap_inset,
            post_d = post_d,
            post_h = post_h
        ){
            tag("remove") difference () {
                // Remove place where it will join the other legs
                position(LEFT + TOP)
                up(eps)
                left(eps + slop + cutaway_chamfer)
                cyl(
                    d = cutaway_d,
                    h = cutaway_h,
                    chamfer1 = cutaway_chamfer,
                    anchor = LEFT + TOP
                );

                // Post to align the other legs
                position(LEFT + TOP)
                right(cutaway_d - cutaway_chamfer - slop - eps)
                down(cutaway_h + eps)
                cyl(
                    d = alignment_post_d,
                    h = cutaway_h,
                    chamfer1 = -cutaway_chamfer,
                    chamfer2 = cutaway_chamfer,
                    anchor = BOTTOM
                );
            }
        }

        children();
    }
}

module middle_leg(
    n = 4,
    node_d = 40,
    node_spread = 50,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 12,
    cutaway_chamfer = 0.5,
    alignment_post_d = 7,
    supports = true,
    eps = 0.01,
    anchor, spin, orient
) {
    slop = get_slop();
    solid_height = post_h + cap_inset;
    cutaway_d = node_d + 2 * cutaway_chamfer + 2 * slop;
    cutaway_h_top = solid_height * leg_height_ratios[2] + slop + eps;
    cutaway_h_bottom = solid_height * leg_height_ratios[0] + slop + eps;

    tag_scope()
    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            solid_height
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
            // Remove portion where bottom leg will slot in
            tag("remove")
            position(LEFT + BOTTOM)
            down(eps)
            left(eps + slop + cutaway_chamfer)
            cyl(
                d = cutaway_d,
                h = cutaway_h_bottom,
                chamfer2 = cutaway_chamfer,
                anchor = LEFT + BOTTOM
            );

            // Remove portion where top leg will slot in
            tag("remove")
            position(LEFT + TOP)
            up(eps)
            left(eps + slop + cutaway_chamfer)
            cyl(
                d = cutaway_d,
                h = cutaway_h_top,
                chamfer1 = cutaway_chamfer,
                anchor = LEFT + TOP
            );

            // Cut out a slot for the alignment post
            tag("remove")
            up(cutaway_h_bottom - eps)
            position(LEFT + BOTTOM)
            zrot(300, cp = [node_d / 2, 0, 0])
            cyl(
                d = alignment_post_d + slop * 2,
                h = (solid_height - cutaway_h_bottom) + eps,
                chamfer1 = -cutaway_chamfer,
                anchor = BOTTOM
            );

            // Supports
            if(supports)
            tag("keep")
            position(LEFT + BOTTOM)
            up(cutaway_h_bottom / 2)
            right(node_d / 2)
            supports(
                d = node_d,
                id = post_d,
                cutout_d = alignment_post_d + slop * 2 + cutaway_chamfer * 2,
                h = cutaway_h_bottom,
                spin = -60
            );
        }

        children();
    }
}

module top_leg(
    n = 4,
    node_d = 40,
    node_spread = 50,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 12,
    cutaway_chamfer = 0.5,
    alignment_post_d = 7,
    supports = true,
    eps = 0.01,
    anchor, spin, orient
) {
    slop = get_slop();
    solid_height = post_h + cap_inset;
    cutaway_d = node_d + 2 * cutaway_chamfer + 2 * slop;
    cutaway_h = solid_height * (1 - leg_height_ratios[2]) + eps;
    
    tag_scope()
    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            solid_height
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
                d = cutaway_d,
                h = cutaway_h,
                chamfer2 = cutaway_chamfer,
                anchor = LEFT + BOTTOM
            );

            // Cut out a slot for the alignment post
            tag("remove")
            up(solid_height / 3 - eps)
            position(LEFT + BOTTOM)
            zrot(60, cp = [node_d / 2, 0, 0])
            cyl(
                d = alignment_post_d + slop * 2,
                h = cutaway_h + eps,
                chamfer2 = -cutaway_chamfer,
                anchor = BOTTOM
            );

            // Supports
            if (supports)
            tag("keep")
            position(LEFT + BOTTOM)
            up(cutaway_h / 2)
            right(node_d / 2)
            supports(
                d = node_d,
                id = post_d,
                cutout_d = alignment_post_d + slop * 2,
                h = cutaway_h,
                spin = 60
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

penny_d = 19.05;
penny_h = 1.55;
magnet_d = 6;
magnet_h = 1.5;

module legs_with_holes (
    leg = "top",
    floor_h = 0.6,
    // Pass thru args
    n = 4,
    node_d = 40,
    node_spread = 50,
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 12,
    cutaway_chamfer = 0.5,
    alignment_post_d = 7,
    supports = true,
    eps = 0.01,
    anchor, spin, orient
) {
    usable_height = post_h - floor_h * 2;
    pennies_count = floor(usable_height / penny_h);
    pennies_height = usable_height; // pennies_count * penny_h; 

    attachable(
        anchor, spin, orient,
        size = [
            node_spread * (n - 1) + node_d,
            node_d,
            post_h + cap_inset
        ]
    ) {
        
        diff("holes") {
            if (leg == "top") {
                top_leg(
                    n = n,
                    node_d = node_d,
                    node_spread = node_spread,
                    cap_d = cap_d,
                    cap_inset = cap_inset,
                    post_d = post_d,
                    post_h = post_h,
                    cutaway_chamfer = cutaway_chamfer,
                    alignment_post_d = alignment_post_d,
                    supports = supports,
                    eps = eps,
                    anchor = anchor,
                    spin = spin,
                    orient = orient
                );
            } else if (leg == "middle") {
                middle_leg(
                    n = n,
                    node_d = node_d,
                    node_spread = node_spread,
                    cap_d = cap_d,
                    cap_inset = cap_inset,
                    post_d = post_d,
                    post_h = post_h,
                    cutaway_chamfer = cutaway_chamfer,
                    alignment_post_d = alignment_post_d,
                    supports = supports,
                    eps = eps,
                    anchor = anchor,
                    spin = spin,
                    orient = orient
                );
            } else if (leg == "bottom") {
                bottom_leg(
                    n = n,
                    node_d = node_d,
                    node_spread = node_spread,
                    cap_d = cap_d,
                    cap_inset = cap_inset,
                    post_d = post_d,
                    post_h = post_h,
                    cutaway_chamfer = cutaway_chamfer,
                    alignment_post_d = alignment_post_d,
                    supports = supports,
                    eps = eps,
                    anchor = anchor,
                    spin = spin,
                    orient = orient
                );
            }
            // Penny holes
            tag("holes")
            position(BOTTOM + RIGHT)
            up(floor_h) {
                for (i = [0 : 1 : n - 3])
                left((node_spread + node_d) / 2 + i * node_spread)
                cyl(
                    d = penny_d,
                    h = pennies_height, 
                    anchor = BOTTOM
                ) {
                    // Magnet holes
                    position(BOTTOM)
                    right(sin(45) * (penny_d + magnet_d) / 2)
                    back(cos(45) * (penny_d + magnet_d) / 2)
                    cyl(
                        d = magnet_d,
                        h = magnet_h, 
                        anchor = BOTTOM
                    );

                    position(TOP)
                    right(sin(45) * (penny_d + magnet_d) / 2)
                    back(cos(45) * (penny_d + magnet_d) / 2)
                    cyl(
                        d = magnet_d,
                        h = magnet_h, 
                        anchor = TOP
                    );

                    position(BOTTOM)
                    right(sin(45) * (penny_d + magnet_d) / 2)
                    fwd(cos(45) * (penny_d + magnet_d) / 2)
                    cyl(
                        d = magnet_d,
                        h = magnet_h, 
                        anchor = BOTTOM
                    );

                    position(TOP)
                    right(sin(45) * (penny_d + magnet_d) / 2)
                    fwd(cos(45) * (penny_d + magnet_d) / 2)
                    cyl(
                        d = magnet_d,
                        h = magnet_h, 
                        anchor = TOP
                    );
                }
            }
        }

        children();
    }
}

// These supports take the form of two pairs of rings:
// One pair supports the outer perimeter of the donut
// and includes a parameter for the cutout for the
// alignment post.
// The other pair supports the inner perimeter of the
// donut.
module supports(
    d = 10,
    id = 5,
    cutout_d = 3,
    h = 10,
    // Expected layer height
    layer_height = 0.2,
    support_separation = 2,
    support_thickness = 0.5,
    support_top_thickness = 0.5,
    EPSILON = 0.001,
    anchor, spin, orient
) {
    // Measurements for the outer support rings
    outer_support_1_d = d - support_thickness;
    outer_support_2_d = d - support_separation * 2 + support_thickness;
    outer_support_mid_d = (outer_support_1_d + outer_support_2_d) / 2;
    cutout_circle_1_d = cutout_d + support_thickness;
    cutout_circle_2_d = cutout_d + support_separation * 2 + support_thickness;
    cutout_circle_mid_d = (cutout_circle_1_d + cutout_circle_2_d) / 2;

    // Measurements for the inner support rings
    inner_support_1_d = id + support_thickness;
    inner_support_2_d = id + support_separation * 2 - support_thickness;
    inner_support_mid_d = (inner_support_1_d + inner_support_2_d) / 2;

    outer_support_1 = difference(
        circle(d = outer_support_1_d),
        left(d / 2, circle(d = cutout_circle_1_d))
    );
    outer_support_2 = difference(
        circle(d = outer_support_2_d),
        left(d / 2, circle(d = cutout_circle_2_d))
    );
    outer_support_mid = difference(
        circle(d = outer_support_mid_d),
        left(d / 2, circle(d = cutout_circle_mid_d))
    );
    inner_support_1 = circle(d = inner_support_1_d);
    inner_support_2 = circle(d = inner_support_2_d);
    inner_support_mid = circle(d = inner_support_mid_d);

    dashpat = [0.5, 0.75];

    attachable(
        anchor, spin, orient,
        d = d,
        h = h,
    ) {
        down(h / 2) {
            // Floor
            cyl(d = d, h = layer_height, anchor = BOTTOM);

            // Outer support 1
            linear_extrude(height = h - layer_height)
            stroke(
                path = outer_support_1,
                width = support_thickness,
                closed = true
            );
            
            // Outer support 2
            linear_extrude(height = h - layer_height)
            stroke(
                path = outer_support_2,
                width = support_thickness,
                closed = true
            );

            // Outer crossbars
            up(h - layer_height - EPSILON)
            linear_extrude(height = layer_height + 2 * EPSILON)
            dashed_stroke(
                path = outer_support_mid,
                width = support_separation,
                dashpat = dashpat,
            );

            // Inner support 1
            linear_extrude(height = h - layer_height)
            stroke(
                path = inner_support_1,
                width = support_thickness,
                closed = true
            );

            // Inner support 2
            linear_extrude(height = h - layer_height)
            stroke(
                path = inner_support_2,
                width = support_thickness,
                closed = true
            );

            // Inner crossbars
            up(h - layer_height - EPSILON)
            linear_extrude(height = layer_height + 2 * EPSILON)
            dashed_stroke(
                path = inner_support_mid,
                width = support_separation,
                dashpat = dashpat,
            );
        }

        children();
    }
}

legs_with_holes("middle", supports = true);