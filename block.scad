mm = 1;
$fn = 100;
// general dimensions of the basic building block
h = 20 * mm;  // the height of the block (X)
l = 100 * mm; // the length of the block (Y)
w = 6 * mm;   // the width  of the block (Z)
g = 0.5 * mm; // the size of the gaps between parts that slide into each other
d = 0.1 * mm; // overhang for parts that cut off from other solid blocks
z = 10 * mm;  // distance of the gap from the edge of the block
dw = 20 * mm; // door/window width
dh = (h / 4) * mm; // height above the door/window
door_shift = 20 * mm; // distance of the door center from the center of the block

avhw = 5 * mm; // air vent hole width
avhh = 2 * mm; // air vent hole height

edge_rounding_radius = 0.5 * mm;

// the gaps to be removed from the block where the other blocks will slide into
module gap(x = 1, y = 1) {
    translate([x * (3 * h / 8 + d), y * (l / 2 - z), 0])
        cube([h / 4, w + g, w + 2 * d], true);
}

// convert a vector to a rounded version, where the rounding is using minkowski addition with a sphere of raadius edge_rounding_radius
function rounded(x, r = edge_rounding_radius) = [for (k = [0:2]) x[k] - 2 * r];

// round the edges of a block putting a rounded layer around them
module round_edges(r = edge_rounding_radius) {
    minkowski() {
        children();
        sphere(r);
    }
}

// the basic building block
module block() {
    difference() {
        round_edges() cube(rounded([h, l, w], r = edge_rounding_radius), center = true);
        // cut off the four gaps where the perpendicular parts slide into the block
        for (i = [- 1:2:1]) {
            for (j = [- 1:2:2]) {
                gap(i, j);
            }
        }
    }
}

module test_block() {
    block();

    translate([h / 2, - l / 2 + z, - l / 2 + z])
        rotate([90, 0, 0])
            block();
}

// a half block that can be used on the top and the bottom to close the gaps
module halfBlock() {
    difference() {
        block();
        translate([h / 2, 0, 0])
            cube([h + 2 * d, l + 2 * d, w + 2 * d], center = true);
    }
}

module test_halfBlock() {
    halfBlock();

    translate([h / 2, - l / 2 + z, - l / 2 + z])
        rotate([90, 0, 0])
            halfBlock();
}


// a block with a window part cut off
// two blocks can make a tall window, the lower block upside down
module windowBlock() {
    x = h - dh + d;
    y = dw;
    z = w + 2 * d;
    difference() {
        block();
        translate([(h - x) / 2 - dh, 0, 0])
            cube([x, y, z], center = true);
    }
}

module test_windowTopBlock() {
    windowBlock();
}

// Door top cut off from a block
// this is the same as the window top cut off, but the door is shifted to the side
module doorTopBlock() {
    x = h - dh + d;
    y = dw;
    z = w + 2 * d;
    difference() {
        block();
        translate([(h - x) / 2 - dh, door_shift, 0])
            cube([x, y, z], center = true);
    }
}

module test_doorTopBlock() {
    doorTopBlock();
}

// the blocks that are the two sides of a door cut off from a block
module doorSideBlocks() {
    x = h + d;
    y = dw;
    z = w + 2 * d;
    difference() {
        block();
        translate([0, door_shift, 0])
            cube([x, y, z], center = true);
    }
}

module test_doorSideBlocks() {
    doorSideBlocks();
}

module airVentHolesBlock() {
    N = floor((l - 2 * z - 2 * w) / (avhw * 2));
    difference() {
        block();
        for (i = [1:N]) {
            translate([h / 4, - l / 2 + z + w + i * 2 * avhw, 0])
                cube([avhh, avhw, w + 2 * d], center = true);
        }
    }
}

module test_airVentHolesBlock() {
    airVentHolesBlock();
}

module ceiling() {
    translate([0, 0, - l / 2 + z])
        halfBlock();
    translate([0, 0, + l / 2 - z])
        halfBlock();
    translate([- 0.1, 0, 0])
        difference() {
            hull() {
                translate([+ w / 2, 0, 0])
                    cube([w, l, l], center = true);
                translate([+ l / 4, 0, 0])
                    sphere(0.1);
            }
            translate([- w, 0, 0])
                hull() {
                    translate([+ w / 2, 0, 0])
                        cube([w / 2, l - 2 * w, l - 2 * w], center = true);
                    translate([+ l / 4, 0, 0])
                        sphere(0.1);
                }
        }
}

module lay() {
    for (i = [0:$children - 1]) {
        translate([i * (h + 5 * mm), 0, 0])
            children(i);
    }
}