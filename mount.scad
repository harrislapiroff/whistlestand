// Dowel diameters: 5/8" (15.876mm) and 7/16" (11.1125mm)'

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

module mount_outer (
    cap_d = 30,
    cap_h = 12.5,
    post_d = 12.5,
    post_h = 25,
    anchor, spin, orient
) {
    // Cylinder geometry attachable
    attachable(
        anchor, spin, orient,
        d = cap_d,
        h = post_h + cap_h
    ) {
        // Move down by half cap height to recenter the entire object
        down(cap_h / 2)
        threaded_rod(
            d = post_d,
            h = post_h,
            pitch = 4,
            bevel1 = 1,
            bevel2 = "reverse"
        )
            attach(TOP)
            cyl(
                d=cap_d,
                h=cap_h,
                texture="diamonds",
                tex_inset = true,
                anchor = BOTTOM
            );
        children();
    }
};

module mount(
    cap_d = 30,
    cap_h = 12.5,
    post_d = 25,
    post_h = 12.5,
    dowel_size = 5 / 8 * INCH,
    crush_rib_size = 1,
    crush_rib_count = 20,
    floor_thickness = 1,
    eps = 0.01,
    anchor, spin, orient
) {
    // Cylinder geometry attachable
    attachable(
        anchor, spin, orient,
        d = cap_d,
        h = post_h + cap_h
    ) {
        xrot(180) // Flip it to get it in print orientation with flat side down
        diff("socket") {
            mount_outer(
                cap_d = cap_d,
                cap_h = cap_h,
                post_d = post_d,
                post_h = post_h
            )
                tag("socket")
                position(TOP)
                up(eps)
                dowel_socket(
                    dowel_size = dowel_size,
                    h = post_h + cap_h - floor_thickness + (floor_thickness == 0 ? 2* eps : 0),
                    crush_rib_size = crush_rib_size,
                    crush_rib_count = crush_rib_count,
                    anchor=TOP
                );
        }
        children();
    }
}

module mount_insert(
    cap_d = 30,
    cap_inset = 1,
    post_d = 25,
    post_h = 30,
    eps = 0.01,
    anchor, spin, orient    
) {
    slop = get_slop();
    attachable(
        anchor, spin, orient,
        d = cap_d,
        h = post_h + cap_inset
    ) {
            // Move down by half cap height to recenter the entire object
            down(cap_inset / 2)
            threaded_rod(
                d = post_d,
                h = post_h,
                pitch = 4,
                internal = true
            )
                attach(TOP)
                down(eps)
                cyl(
                    d = cap_d + 2 * slop,
                    h = cap_inset + slop + eps,
                    anchor = BOTTOM
                );

            children();
    }
}

module dowel_socket(
    dowel_size = 5 / 8 * INCH,
    crush_rib_size = 0.5,
    crush_rib_count = 20,
    h = 30,
    anchor, spin, orient
) {
    // Cylinder geometry attachable
    attachable(
        anchor, spin, orient,
        d = dowel_size + crush_rib_size,
        h = h
    ) {
        union() {
            linear_extrude(h, center=true)
            star(
                n = crush_rib_count,
                d = dowel_size + crush_rib_size * 2 * 0.75,
                id = dowel_size - crush_rib_size * 2 * 0.25
            );

            cyl(
                h = h,
                d = dowel_size - crush_rib_size * 2 * 0.25,
                chamfer2 = -crush_rib_size
            );
        }
        children();
    }
}

mount();