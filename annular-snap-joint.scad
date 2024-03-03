include <BOSL2/std.scad>

$slop = 0.1;
$fs = $preview ? 2 : 0.1;
$fa = $preview ? 20 : 0.5;

module snap_nub (
    d = 11,
    h = 1,
    thickness = 1,
    bevel_top = 1.5,
    bevel_bottom = 1.5,
    anchor, spin, orient
) {
    full_h = h + bevel_top + bevel_bottom;
    full_d = d + thickness;

    attachable(
        anchor, spin, orient,
        d = full_d,
        h = full_h
    ) {
        down(full_h / 2)
        rotate_extrude() 
        right(d / 2)
        polygon([
            [0, 0],
            [0, full_h],
            [thickness, bevel_bottom + h],
            [thickness, bevel_bottom],
        ]);

        children();
    }

}

module annular_snap_tabs (
    id = 10,
    od = 11,
    h = 20,
    slot_n = 4,
    slot_h = 15,
    slot_ang = 5,
    nub_z = 0,
    nub_thickness = 1,
    nub_height = 1,
    nub_bevel_top = 1.5,
    nub_bevel_bottom = 1.5,
    EPSILON = 0.001,
    anchor, spin, orient
) {
    attachable(
        anchor, spin, orient,
        d = od + nub_thickness * 2,
        h = h
    ) {
        diff("slots")
        tube(
            id = id,
            od = od,
            h = h,
        ) {
            // Nubs
            position(BOTTOM)
            up(nub_z)
            snap_nub(
                d = od - EPSILON,
                h = nub_height,
                thickness = nub_thickness,
                bevel_top = nub_bevel_top,
                bevel_bottom = nub_bevel_bottom,
                anchor = BOTTOM
            );

            //Slots
            tag("slots")
            // Repeat n times, evenly spaced around the tube
            for (i = [0 : slot_n - 1])
            zrot(i * 360 / slot_n)
            // Move down to bottom of tube
            down((h - slot_h) / 2 + EPSILON)
            // Center the angle on the axis
            zrot(-slot_ang / 2)
            // Make wedge vertical
            yrot(90)
            position(CENTER)
            // Create a wedge of the appropriate length and angle to remove from the tube to
            // produce tabs
            wedge(
                [
                    slot_h,
                    // This will safely cover the entire tab and nub
                    od + nub_thickness * 2,
                    // Calculates the outer edge of the wedge to produce the correct angle. Trigonometry!
                    tan(slot_ang) * (od + nub_thickness * 2)
                ],
                anchor = BACK + BOTTOM
            );
        }

        children();
    }
}

module annular_snap_mask(
    id = 10,
    od = 11,
    h = 20,
    slot_n = 4,
    slot_h = 15,
    slot_ang = 5,
    nub_z = 0,
    nub_thickness = 1,
    nub_height = 1,
    nub_bevel_top = 1.5,
    nub_bevel_bottom = 1.5,
    chamfer1 = 0,
    chamfer2 = -1,
    EPSILON = 0.001,
    anchor, spin, orient
) {
    slop = get_slop();

    attachable(
        anchor, spin, orient,
        d = od + nub_thickness * 2 + slop * 2,
        h = h
    ) {
        diff("slots")
        cyl(
            d = od + slop * 2,
            h = h,
            chamfer1 = chamfer1,
            chamfer2 = chamfer2,
        )
            // Nubs
            position(BOTTOM)
            up(nub_z)
            snap_nub(
                d = od - EPSILON,
                h = nub_height + slop * 2,
                thickness = nub_thickness + slop,
                bevel_top = nub_bevel_top,
                bevel_bottom = nub_bevel_bottom,
                anchor = BOTTOM
            );

        children();
    }
}


annular_snap_mask();

back(40)
annular_snap_tabs();