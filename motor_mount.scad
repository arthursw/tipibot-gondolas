include <BOSL2/constants.scad>
include <BOSL2/shapes.scad>
include <BOSL2/screws.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
include <BOSL2/gears.scad>
include <BOSL2/nema_steppers.scad>

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

height = 90;
width = 50;
body_cap_height = 50;

notch_tolerance = 0.5;
finger_hole_height = 15;
finger_hole_width = 22;

gondola_length = 120;
// side_width = gondola_length / 2 + 22.5;
side_width = gondola_length / 2 + 10;
side_height = 40;
side_notch_height = 12;
side_notch_spacing = (body_cap_height - 2.0 * side_notch_height) / 3.0;

side_notch_dist_y = side_notch_height + side_notch_spacing;
side_hook_length = 4;
side_dist_x = 38;

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

sensor_diameter = 12 + 1;

body_cap_y = -height/2+body_cap_height/2;

module side_notches(tolerance=false) {
        mirror_copy(LEFT, side_dist_x/2)
        ycopies(side_notch_dist_y, 2)
        cuboid([2*thickness+(tolerance ? 2 * notch_tolerance : 0), side_notch_height, 2*thickness], anchor=BOTTOM);
}

module body(finger_hole=false) {
    difference() {
        
        // Main plate
        cuboid([width, height, thickness], anchor=BOTTOM);

        // Sides notches
        fwd(body_cap_y - side_hook_length/2)
        mirror_copy(LEFT, side_dist_x/2)
        cuboid([2*thickness+2*notch_tolerance, body_cap_height - 2 * side_notch_spacing + side_hook_length, 2*thickness], anchor=BOTTOM);

        // Finger hole
        if(finger_hole) {
            fwd(body_cap_y)
            cuboid([finger_hole_width, finger_hole_height, 2*thickness], anchor=BOTTOM);
        }

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

// body();

end_stop_width = 27;
end_stop_height = 21;
end_stop_screw_x_spacing = 19;
end_stop_screw_y = 17;
m3_radius = 3/2;

module nema_holder() {
    difference() {
        
        // Main plate
        union() {
            cuboid([width, height, thickness], anchor=BOTTOM);
            // End stop holder
            fwd(height/2+end_stop_height/2)
            difference() {
                cuboid([width, end_stop_height, thickness], anchor=BOTTOM);
                fwd(-end_stop_height/2+end_stop_screw_y)
                xcopies(end_stop_screw_x_spacing, 2)
                cyl(r=m3_radius, h=2*thickness);
            }
        }

        // Sides notches
        fwd(body_cap_y+side_hook_length)
        side_notches();
        
        // Nema
        fwd(height/2-nema_hole_y) {

            nema_mount_holes(size=17, depth=3*thickness, l=0);

            // #cyl(r=nema_hole_diameter/2, l=2*thickness);
            // mirror_copy(LEFT, nema_screw_dist/2)
            // mirror_copy(FRONT, nema_screw_dist/2)
            // #cyl(r=nema_screw_diameter/2, l=2*thickness);
            
            fwd(nema_hole_y/2+end_stop_height/2+1)
            cuboid([nema_notch, nema_hole_y+end_stop_height, 2*thickness], anchor=BOTTOM);
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


module body_cap(finger_hole=false) {
    difference() {
        
        // Main plate
        cuboid([width, body_cap_height, thickness], anchor=BOTTOM);

        // Sides notches
        fwd(-side_hook_length)
        side_notches(true);
        
        // Finger hole
        if(finger_hole) {
            cuboid([finger_hole_width, finger_hole_height, 2*thickness], anchor=BOTTOM);
        }

        // Screw holes
        fwd(-body_cap_height/2+screw_hole_y)
        mirror_copy(LEFT, screw_hole_x_dist/2)
        cyl(r=screw_head_diameter/2, l=2*thickness);
    }
}
// fwd(body_cap_y)
// up(thickness)
// body_cap();

sensor_holder_notch = 8;

module side_hook(additional_height=0) {
    ycopies(side_notch_dist_y, 2) {
        fwd(side_hook_length/2)
        cuboid([thickness+additional_height+notch_tolerance, side_notch_height - side_hook_length, thickness], anchor=BOTTOM);
        // Sides notches
        left(thickness+additional_height/2+notch_tolerance/2)
        cuboid([thickness, side_notch_height, thickness], anchor=BOTTOM);
    }
}

module side() {
    difference() {

        union() {
            
            // Main plate
            cuboid([side_width, side_height, thickness], anchor=BOTTOM);

            // Nema hook
            left((side_width + 2*thickness+notch_tolerance) / 2)
            side_hook(thickness);
            
            // Wall hook
            zrot(180)
            left((side_width + thickness+notch_tolerance) / 2)
            side_hook(0);
        }

        // sensor holder notch
        left(-side_width/2+sensor_holder_notch/2)
        cuboid([sensor_holder_notch, thickness, 2*thickness], anchor=BOTTOM);
    }
}

// side();
// sensor_diameter = 16;
sensor_to_nema_holder = 5;

module sensor_holder() {
    union() {
        
        // Main part
        difference() {
            cuboid([side_dist_x-2*thickness, side_width, thickness], anchor=BOTTOM);
            fwd(-side_width/2+sensor_diameter/2+sensor_to_nema_holder)
            cyl(r=sensor_diameter/2, l=2*thickness);
        }

        // Side male notches
        fwd(side_width/2-sensor_holder_notch/2)
        mirror_copy(LEFT, side_dist_x/2)
        cuboid([2*thickness, sensor_holder_notch, thickness], anchor=BOTTOM);

        // Top male notch
        fwd(-side_width/2-thickness/2)
        cuboid([sensor_holder_notch, thickness, thickness], anchor=BOTTOM);
    }
}

// sensor_holder();
// nema_holder();
module viz3d() {
    body();

    up(thickness+side_width+thickness+thickness/2)
    zcopies(thickness, 2)
    nema_holder();

    fwd(body_cap_y)
    up(thickness) {
        body_cap();

        up(side_width/2+thickness) {
            mirror_copy(LEFT, (side_dist_x + thickness) / 2)
            yrot(90)
            {
                up(-thickness/2)
                side();
                up(thickness/2)
                side();
            }

            fwd(-thickness/2)
            xrot(90)
            sensor_holder();
        }
    }
    
}


// body();
// nema_holder();
// body_cap();
// side();
// sensor_holder();

part = "";

module export_part() {
    if(part == "mm_body") {
        body();
    }
    if(part == "mm_nema_holder") {
        nema_holder();
    }
    if(part == "mm_body_cap") {
        body_cap();
    }
    if(part == "mm_side") {
        side();
    }
    if(part == "mm_sensor_holder") {
        sensor_holder();
    }
    if(part == "mm_all") {
        viz3d();
    }
}

// part = "mm_side";
module export_part_2d_no_render() {
    if(part == "mm_body") {
        body();
    }
    if(part == "mm_nema_holder") {
        nema_holder();
    }
    if(part == "mm_body_cap") {
        body_cap();
    }
    if(part == "mm_side") {
        mirror_copy(LEFT, (side_width+4*(thickness+notch_tolerance)+1)/2)
        side();
    }
    if(part == "mm_sensor_holder") {
        sensor_holder();
    }
}

// export_part_2d_no_render();
kerf_width = 0.2;

module export_part_2d() {
    $fa=1;
    $fs=0.5;
    render() {
        offset(delta=kerf_width/2) {
            projection() {
                export_part_2d_no_render();
            }
        }
    }
}

// export_part_2d();

command = "";

module export_command() {
    if(command == "3d") {
        export_part();
    }
    if(command == "2d") {
        export_part_2d();
    }
}

export_command();
if(command == "") {
    viz3d();
}

// TODO: cross holes in the wall board to be able to measure from motor center