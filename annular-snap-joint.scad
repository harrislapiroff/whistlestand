include <BOSL2/std.scad>

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
    EPSILON = 0.001
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
        down(EPSILON)
        position(BOTTOM)
        for (i = [0 : slot_n - 1])
        zrot(i * 360 / slot_n)
        pie_slice(
            // Multiplying the full diameter by 2 ensures the slot covers the entire cylinder even for small $fn
            d = (od + nub_thickness * 2) * 2,
            h = slot_h,
            ang = slot_ang,
        );
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
    EPSILON = 0.001
) {
    slop = get_slop();

    diff("slots")
    cyl(
        d = od,
        h = h,
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
}


annular_snap_mask();

back(40)
annular_snap_tabs();