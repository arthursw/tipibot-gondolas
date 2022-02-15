include <parameters.scad>


module pen_holder_bridge(pen_diameter = pen_diameter, pen_nsides=0) {

    translate([0, pen_holder_height/2, 0])
    difference() {
        cuboid([pen_holder_width, pen_holder_height, thickness]);

        // Legs hole
        translate([0, -pen_holder_height/2+ground_to_pen_center/2, 0])
        cuboid([pen_diameter, ground_to_pen_center, 2*thickness]);

        // Pen hole
        translate([0, -pen_holder_height/2+ground_to_pen_center, 0])
        cyl(r=pen_diameter/2, l=2*thickness, $fn=pen_nsides > 0 ? pen_nsides : $fn);

        // Center notch
        translate([0, pen_holder_height/2 - thickness/2, 0])
        cuboid([sliding_magnet_width, thickness, 2*thickness]);

        // Side notches
        translate([0, -pen_holder_height/2+ground_to_pen_center, 0])
        mirror_copy(LEFT, pen_holder_width/2-thickness/2)
        cuboid([thickness, comb_notch, 2*thickness]);
    }
}

// pen_holder_bridge();



module sliding_magnet(length, width, n_magnets, notches=false) {
    difference() {
        cuboid([notches ? width + 2 * thickness : width, length, thickness], anchor=BOTTOM);
        ycopies(magnet_spacing, n_magnets)
        cuboid([magnet_size, magnet_size, magnet_size], anchor=BOTTOM);
        if(notches) {
            mirror_copy(LEFT, width / 2 + thickness / 2)
            ycopies(2 * thickness, floor(0.5 * length / thickness))
            cuboid([thickness, thickness, thickness], anchor=BOTTOM);
        }
    }
}

module pen_holder(pen_diameter=pen_diameter, pen_nsides=0) {
    up(pen_holder_height-thickness)
    sliding_magnet(pen_holder_length, sliding_magnet_width, n_magnets, notches=true);

    ycopies(pen_holder_legs_spacing, 2)
    xrot(90)
    pen_holder_bridge();
}
