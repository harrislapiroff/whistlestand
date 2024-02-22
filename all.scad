include <BOSL2/std.scad>
include <BOSL2/threading.scad>

use <mount.scad>
use <test_block.scad>
use <legs.scad>

/* [Dowel Mount] */
// Diameter of the "cap" (widest part of the mount)
cap_d = 30;
// Height of the cap
cap_h = 12.5;
// Diameter of the screw part
post_h = 12;
// Height of the screw part
post_d = 25;

/* [Arms] */
// Note that one slot is shared between all three arms, so if nodes per arm is set to N, then the number of slots total is N * 3 - 2
nodes_per_arm = 2;
// Diameter of each node
node_d = 40;
// Distance between the center of each node
node_spread = 50;
// Depth which the dowel mount cap sinks into the arm
cap_inset = 1;

/* [General] */
// Amount to retract parts that need to fit together by to compensate for overextrusion
$slop = 0.15;
$fs = $preview ? 2 : 0.5;
$fa = $preview ? 20 : 1;

// test_block(
//     cap_d = cap_d,
//     cap_inset = cap_inset,
//     post_d = post_d,
//     post_h = post_h,
//     pad = 2,
//     chamfer = 1
// );

back(40)
mount(
    cap_d = cap_d,
    cap_h = cap_h,
    post_d = post_d,
    post_h = post_h,
    dowel_size = 5 / 8 * INCH,
    crush_rib_size = 1,
    crush_rib_count = 20
);

back(80)
bottom_leg(
    n = nodes_per_arm,
    node_d = node_d,
    node_spread = node_spread,
    cap_d = cap_d,
    cap_inset = cap_inset,
    post_d = post_d,
    post_h = post_h
);

back(140)
middle_leg(
    n = nodes_per_arm,
    node_d = node_d,
    node_spread = node_spread,
    cap_d = cap_d,
    cap_inset = cap_inset,
    post_d = post_d,
    post_h = post_h
);

back(200)
top_leg(
    n = nodes_per_arm,
    node_d = node_d,
    node_spread = node_spread,
    cap_d = cap_d,
    cap_inset = cap_inset,
    post_d = post_d,
    post_h = post_h
);