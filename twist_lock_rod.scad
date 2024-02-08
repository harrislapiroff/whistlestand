include <BOSL2/std.scad>

$fa = 1;
$fs = 0.1;

module thread_profile (
    width = 2,
    height = 1,
    bevel_top = 1.5,
    bevel_bottom = 1.5,
) {
    polygon(points = [
        [0, 0],
        [width, bevel_bottom],
        [width, bevel_bottom + height],
        [0, bevel_bottom + height + bevel_top],
    ]);
}

module twist_lock_thread (
    d = 10,
    pins = 4,
    pin_extrude_width = 2,
    pin_arc_angle = 30,
    pin_height = 0.5,
    pin_bevel_height_top = 0.75,
    pin_bevel_height_bottom = 0.75,
    anchor, spin, orient
) {
    between_angle = 360 / pins - pin_arc_angle;
    total_h = pin_height + pin_bevel_height_bottom + pin_bevel_height_top;
    total_d = d + pin_extrude_width * 2;

    attachable(
        anchor, spin, orient,
        d = total_d,
        h = total_h
    ) {
        for (i = [0 : pins - 1]) {
            zrot(i * between_angle + i * pin_arc_angle)
            down(total_h / 2) // center vertically
            rotate_extrude(angle=pin_arc_angle)
            right(d / 2)
            thread_profile(
                width = pin_extrude_width,
                height = pin_height,
                bevel_top = pin_bevel_height_top,
                bevel_bottom = pin_bevel_height_bottom
            );
        };

        children();
    }
};

module twist_lock_rod_insert (
    d = 10,
    h = 10,
    rod_chamfer_top = 0,
    pins = 2,
    pin_extrude_width = 1.5,
    pin_arc_angle = 60,
    pin_height = 0.5,
    pin_bevel_height_top = 1.5,
    pin_bevel_height_bottom = 0,
    pin_from_bottom = 0,
    eps = 0.01,
    anchor, spin, orient
) {
    attachable(
        anchor, spin, orient,
        d = d + pin_extrude_width * 2,
        h = h
    ) {
        cyl(
            d = d,
            h = 10,
            chamfer2 = rod_chamfer_top,
        )
        position(BOTTOM)
        up(pin_from_bottom)
        twist_lock_thread(
            d = d - eps * 2,
            pins = pins,
            pin_extrude_width = pin_extrude_width + eps * 2,
            pin_arc_angle = pin_arc_angle,
            pin_height = pin_height,
            pin_bevel_height_top = pin_bevel_height_top,
            pin_bevel_height_bottom = pin_bevel_height_bottom,
            anchor = BOTTOM
        );
        
        children();
    }
}

// Mask for the hole a twist lock rod goes into
module twist_lock_rod_mask (
    d = 10,
    h = 10,
    rod_chamfer_top = 1.5,
    pins = 2,
    pin_extrude_width = 1,
    pin_arc_angle = 60,
    pin_height = 0.5,
    pin_bevel_height_top = 1.5,
    pin_bevel_height_bottom = 0,
    pin_from_bottom = 0,
    eps = 0.01,
    anchor, spin, orient
) {
    slop = get_slop();
    between_angle = 360 / pins - pin_arc_angle;
    angle_slop = slop * 360 / (d + pin_extrude_width * 2) * PI;

    d_ = d + slop * 2;
    pin_height_ = pin_height + slop;
    pin_from_bottom_ = pin_from_bottom > slop / 2 ? pin_from_bottom - slop / 2 : 0;

    attachable(
        anchor, spin, orient,
        d = max(d + pin_extrude_width * 2 + slop, d + rod_chamfer_top * 2 + slop),
        h = h
    ) {
        union() {
            twist_lock_rod_insert(
                d = d_,
                rod_chamfer_top = -rod_chamfer_top,
                pins = pins,
                pin_extrude_width = pin_extrude_width,
                pin_arc_angle = pin_arc_angle,
                pin_height = pin_height_,
                pin_bevel_height_top = pin_bevel_height_top,
                pin_bevel_height_bottom = pin_bevel_height_bottom,
                pin_from_bottom = pin_from_bottom_,
            )
            position(BOTTOM)
            // Channels
            for (i = [0 : pins - 1]) {
                zrot(i * between_angle + (i + 1) * pin_arc_angle)
                up(pin_from_bottom)
                pie_slice(
                    h = h - pin_from_bottom_,
                    d = d_ + pin_extrude_width * 2,
                    ang = pin_arc_angle + angle_slop * 2,
                );
            }
        }
        
        children();
    }
}

twist_lock_rod_mask(pin_from_bottom = 0) show_anchors();
