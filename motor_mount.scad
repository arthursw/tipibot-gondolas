include <BOSL2/constants.scad>
include <BOSL2/shapes.scad>
include <BOSL2/screws.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
include <BOSL2/gears.scad>

// All dimensions are from outer ends (i.e. width = from outer left to outer right)
// except when specified differently

// Hexagon: https://fr.wikipedia.org/wiki/Hexagone
// h = side * sqrt(3) / 2 = small radius
// r = side = large radius

function hexagon_h_to_r(h) = h * 2 / sqrt(3);
function hexagon_r_to_h(r) = r * sqrt(3) / 2;

$fa=1;
$fs=0.1;

// Print number of sides from $fa and $fs:

// r = 100;
// tube(h=thickness, od=200, id=m3_diameter/2);
// echo(n=($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5))),a_based=360/$fa,s_based=r*2*PI/$fs);
// r = m3_diameter/2;
// echo(n=($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5))),a_based=360/$fa,s_based=r*2*PI/$fs);

// => 95 sides

thickness = 3;

height = 100;
width = 50;
body_cap_height = 40;

finger_hole_height = 15;
finger_hole_width = 22;

side_width = 20;
side_height = 40;
side_notch_height = 12;
side_notch_spacing = (body_cap_height - 2.0 * side_notch_height) / 3.0;

side_notch_dist_y = side_notch_height + side_notch_spacing;
side_notch_hook = 4;
side_dist_x = 40;

nema_hole_diameter = 24;
nema_hole_y = width/2 - 5;
nema_notch = 10;
nema_screw_diameter = 3.5;
nema_screw_dist = 28;

screw_hole_y = 10;
screw_hole_x_dist = 20;
screw_hole_diameter = 3.5;
screw_head_diameter = 6.5;

// nema_holder_width = 50;
// nema_holder_height = 46;

chain_hole_height = 6;
chain_hole_width = 3;
chain_hole_x_dist = 20;

sensor_diameter = 12;

body_cap_y = -height/2+body_cap_height/2;

module side_notches() {
        mirror_copy(LEFT, side_dist_x/2)
        ycopies(side_notch_dist_y, 2)
        cuboid([thickness, side_notch_height, 2*thickness], anchor=BOTTOM);
}

module body() {
    difference() {
        
        // Main plate
        cuboid([width, height, thickness], anchor=BOTTOM);

        // Sides notches
        fwd(body_cap_y)
        mirror_copy(LEFT, side_dist_x/2)
        #cuboid([thickness, body_cap_height - 2 * side_notch_spacing, 2*thickness], anchor=BOTTOM);
        
        // Finger hole
        fwd(body_cap_y)
        cuboid([finger_hole_width, finger_hole_height, 2*thickness], anchor=BOTTOM);

        // Top screw holes
        fwd(-height/2+screw_hole_y)
        mirror_copy(LEFT, screw_hole_x_dist/2)
        cyl(r=screw_hole_diameter/2, l=2*thickness);

        // Bottom screw holes
        fwd(height/2-screw_hole_y)
        mirror_copy(LEFT, (width - 20)/2)
        cyl(r=screw_hole_diameter/2, l=2*thickness);
    }
}

module nema_holder() {
    difference() {
        
        // Main plate
        cuboid([width, height, thickness], anchor=BOTTOM);

        // Sides notches
        fwd(body_cap_y+side_notch_hook)
        side_notches();
        
        // Nema
        fwd(height/2-nema_hole_y) {
            cyl(r=nema_hole_diameter/2, l=2*thickness);
            mirror_copy(LEFT, nema_screw_dist/2)
            mirror_copy(FRONT, nema_screw_dist/2)
            cyl(r=nema_screw_diameter/2, l=2*thickness);
            
            fwd(nema_hole_y/2+1)
            cuboid([nema_notch, nema_hole_y, 2*thickness], anchor=BOTTOM);
        }

        // Chain holes
        fwd(-height/2+chain_hole_height/2)
        mirror_copy(LEFT, chain_hole_x_dist/2)
        cuboid([chain_hole_width, chain_hole_height, 2*thickness], anchor=BOTTOM);

        // Sensor holder female notch
        fwd(body_cap_y)
        cuboid([sensor_holder_notch, thickness, 2*thickness], anchor=BOTTOM);
    }
}


module body_cap() {
    difference() {
        
        // Main plate
        cuboid([width, body_cap_height, thickness], anchor=BOTTOM);

        // Sides notches
        fwd(-side_notch_hook)
        side_notches();
        
        // Finger hole
        cuboid([finger_hole_width, finger_hole_height, 2*thickness], anchor=BOTTOM);

        // Screw holes
        fwd(-body_cap_height/2+screw_hole_y)
        mirror_copy(LEFT, screw_hole_x_dist/2)
        cyl(r=screw_head_diameter/2, l=2*thickness);
    }
}

sensor_holder_notch = 8;

module side() {
    difference() {

        union() {
            
            // Main plate
            cuboid([side_width, side_height, thickness], anchor=BOTTOM);

            // Sides notche bodies
            zrot_copies(n=2)
            left((side_width + thickness) / 2)
            ycopies(side_notch_dist_y, 2) {
                fwd(side_notch_hook/2)
                cuboid([thickness, side_notch_height - side_notch_hook, thickness], anchor=BOTTOM);
                // Sides notches
                left(thickness)
                cuboid([thickness, side_notch_height, thickness], anchor=BOTTOM);
            }
        }

        // sensor holder notch
        left(-side_width/2+sensor_holder_notch/2)
        cuboid([sensor_holder_notch, thickness, 2*thickness], anchor=BOTTOM);
    }
}

sensor_diameter = 16;

module sensor_holder() {
    union() {
        
        // Main part
        difference() {
            cuboid([side_dist_x-thickness, side_width, thickness], anchor=BOTTOM);
            // fwd(-side_width/2+sensor_diameter/2)
            cyl(r=sensor_diameter/2, l=2*thickness);
        }

        // Side male notches
        fwd(side_width/2-sensor_holder_notch/2)
        mirror_copy(LEFT, side_dist_x/2)
        cuboid([thickness, sensor_holder_notch, thickness], anchor=BOTTOM);

        // Top male notch
        fwd(-side_width/2-thickness/2)
        cuboid([sensor_holder_notch, thickness, thickness], anchor=BOTTOM);
    }
}

// sensor_holder();
// nema_holder();
module viz3d() {
    body();

    up(thickness+side_width+thickness)
    nema_holder();

    fwd(body_cap_y)
    up(thickness) {
        body_cap();

        up(side_width/2+thickness) {
            mirror_copy(LEFT, (side_dist_x + thickness) / 2)
            yrot(90)
            #side();

            fwd(-thickness/2)
            xrot(90)
            #sensor_holder();
        }
    }
    
}


// side();
viz3d();