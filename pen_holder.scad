include <BOSL2/constants.scad>
include <BOSL2/shapes.scad>
include <BOSL2/screws.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
include <BOSL2/gears.scad>

include <parameters.scad>


module pen_holder_bridge(pen_diameter = pen_diameter, pen_nsides=0) {

    translate([0, pen_holder_height/2, 0])
    difference() {
        union() {
            // Main body
            cuboid([pen_holder_width, pen_holder_height, thickness]);
            // Bottom body
            fwd(pen_holder_height/2-pen_holder_bottom_height/2)
            cuboid([pen_holder_bottom_width, pen_holder_bottom_height, thickness]);
            
            // Bottom legs
            fwd(pen_holder_height/2+pen_holder_bottom_hole_height/2)
            cuboid([pen_holder_bottom_width, pen_holder_bottom_hole_height, thickness]);
        }
        // #fwd(pen_holder_height/2)
        // xrot(-90)
        // prismoid([pen_holder_bottom_width,thickness], [pen_holder_width,thickness], h=pen_holder_height)

        // Legs hole
        translate([0, -pen_holder_height/2+ground_to_pen_center/2, 0])
        cuboid([pen_diameter, ground_to_pen_center, 2*thickness]);
        
        // Case hole
        translate([0, -pen_holder_height/2+pen_holder_bottom_hole_height/2, 0])
        cuboid([pen_holder_bottom_hole_width, pen_holder_bottom_hole_height, 2*thickness]);
        
        // Bottom leg hole
        translate([0, -pen_holder_height/2-pen_holder_bottom_hole_height/2, 0])
        cuboid([pen_holder_bottom_hole_width, pen_holder_bottom_hole_height, 2*thickness]);

        // Pen hole
        translate([0, -pen_holder_height/2+ground_to_pen_center, 0])
        cyl(r=pen_diameter/2, l=2*thickness, $fn=pen_nsides > 0 ? pen_nsides : $fn);

        // Center notch
        translate([0, pen_holder_height/2 - thickness/2, 0])
        cuboid([sliding_magnet_width, thickness, 2*thickness]);

        // Side notches
        translate([0, -pen_holder_height/2+ground_to_pen_center, 0])
        mirror_copy(LEFT, pen_holder_width/2-comb_notch/2)
        #cuboid([comb_notch, thickness, 2*thickness]);
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

module pen_holder(pen_diameter=pen_diameter, pen_nsides=0, two_d=false) {
    if(two_d) {
        pen_holder_2d(pen_diameter=pen_diameter, pen_nsides=pen_nsides);
    } else {
        up(pen_holder_height-thickness)
        sliding_magnet(pen_holder_length, sliding_magnet_width, n_magnets, notches=true);

        ycopies(pen_holder_legs_spacing, 2)
        xrot(90)
        pen_holder_bridge();
    }
}
// pen_holder();

module comb(length=pen_holder_length, notch=comb_notch, width = -1) {
    width = width < 0 ? 2 * notch : width;

    n_notches = floor((length / thickness) / 2);
    notches_length = n_notches * 2 * thickness;
    difference() {
        cuboid([width, length, thickness]);
        
        left(width/2-notch/2)
        ycopies(notches_length/n_notches, n_notches) 
        cuboid([notch, thickness, thickness]);
    }
}

module pen_holder_2d(pen_diameter=pen_diameter, pen_nsides=0) {

    xcopies(pen_holder_bottom_width+1, 2)
    pen_holder_bridge(pen_diameter=pen_diameter, pen_nsides=pen_nsides);

    // Comb

    // translate([pen_holder_width+1+2*comb_notch+1, -ground_to_pen_center + pen_holder_length/2, 0])
    // translate([-23, body_z+comb_notch+9, 0])
    fwd(70)
    zrot(90)
    mirror_copy(LEFT, comb_notch+1)
    comb();
    // pen_holder_comb_wheel_2d();

    // translate([pen_holder_bottom_width+1+sliding_magnet_width+thickness, -ground_to_pen_center + pen_holder_length/2, -thickness/2])
    fwd(45)
    zrot(90)
    sliding_magnet(pen_holder_length, sliding_magnet_width, n_magnets, notches=true);
}

// pen_holder_2d();

module point88() {
    //   Stabilo point 88
    color( rands(0,1,3), alpha=1 )
    xrot(90)
    cyl(l=point88_length, r=point88_diameter/2, $fn=6);
}

module pencil() {
    color( rands(0,1,3), alpha=1 )
    xrot(90)
    cyl(l=pencil_length, r=pencil_diameter/2, $fn=6);
}

// pencil_holder_margin = 2 * thickness;
// pencil_holder_length = hlink_width + pencil_holder_margin;

// module pencil_holder_2d() { 
//     difference() {
//         cube([pencil_holder_length, arc_bottom_height + bottom_hlinks_y + thickness + pencil_holder_margin, thickness]);

//         // top notch
//         left(pencil_holder_margin)
//         back(arc_bottom_height + bottom_hlinks_y)
//         cube([pencil_holder_length, thickness, 2*thickness]);

//         // pencil hole
//         translate([(hlink_width)/2, arc_bottom_height, 0])
//         cyl(l=pencil_length, r=pencil_diameter/2, $fn=6);
//     }
// }

// // pencil_holder_2d();

// module pencil_holder() { 
//     down(arc_bottom_height)
//     left(hlink_width/2)
//     xrot(90)
//     pencil_holder_2d();
// }

// // pencil_holder();

pen_ring_thickness = 3*thickness;
pen_ring_width = pen_diameter+2*pen_ring_thickness;
pen_ring_bottom_height = pen_ring_thickness; //m3_nut_height + 2*thickness;
pen_ring_height = pen_ring_bottom_height+pen_diameter+pen_ring_thickness;

module pen_ring(screw_hole=true) {
    difference() {
        fwd(pen_ring_height/2-pen_ring_bottom_height-pen_diameter/2)
        cuboid([pen_ring_width, pen_ring_height, thickness]);

        // Screw hole
        if(screw_hole) {
            fwd(-pen_diameter/2-pen_ring_bottom_height/2)
            cuboid([thickness, pen_ring_bottom_height+thickness, 2*thickness]);
        }

        // Pen hole
        cyl(d=pen_diameter+0.2, h=2*thickness);

        // Screw notch
        fwd(-pen_diameter/2-pen_ring_bottom_height/2)
        cuboid([m3_nut_S, m3_nut_height, 2*thickness]);

        // Bottom notch
        left(pen_ring_width/2-thickness)
        fwd(-pen_diameter/2-pen_ring_bottom_height/2+thickness/2)
        ycopies(thickness,2)
        #cuboid([2*thickness, thickness, 2*thickness]);
    }
}
// pen_ring();

module pen_ring_ortho_bottom() {
    difference() {
        cuboid([pen_ring_width, 4*thickness+m3_nut_S, thickness]);
        zrot(30)
        cyl(d=m3_nut_e, h=2*thickness, $fn=6);
        width = pen_ring_width - 2*thickness;
        right(pen_ring_width/2-width/2)
        cuboid([width, thickness, 2*thickness]);
    }
}

// fwd(-28)
// pen_ring_ortho_bottom();

module pen_ring_bottom() {
    difference() {
        cuboid([pen_ring_width, pen_ring_bottom_height, thickness]);
        cuboid([m3_nut_S, m3_nut_height, 2*thickness]);
    }
}
// fwd(-45)
// pen_ring_bottom();
