include <BOSL2/constants.scad>
include <BOSL2/shapes.scad>
include <BOSL2/screws.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
include <BOSL2/gears.scad>


include <parameters.scad>
// All dimensions are from outer ends (i.e. width = from outer left to outer right)
// except when specified differently

$fa=1;
$fs=1;

thickness = 3;

gondola_inner_diameter = 36;
gondola_middle_diameter = 54;
pen_margin = 0.25;

module gondola_ring() {
    tube(id=pen_diameter+pen_margin, od=gondola_inner_diameter, l=thickness);
}

// gondola_ring();

servo_width = 40;
servo_height = 40;

m3_radius = 3/2;

servo_holder_inner_diameter = 22;

module gondola_servo_holder() {
    union() {
        difference() {
            tube(id=servo_holder_inner_diameter, od=gondola_middle_diameter, l=thickness);
            ycopies(27, 2)
            xcopies(33, 2)
            #cyl(r=m3_radius, h=2*thickness, anchor=BOTTOM);
        }
        fwd(servo_height/2+gondola_inner_diameter/2)
        cuboid([servo_width, servo_height, thickness], anchor=BOTTOM);
    }
}

// gondola_servo_holder();
servo_arm_length = 30;
module servo_arm() {
    difference() {
        cuboid([servo_arm_length, 2*thickness, 2*thickness], anchor=BOTTOM, rounding=thickness, edges=[LEFT+FRONT, LEFT+BACK, RIGHT+FRONT, RIGHT+BACK]);
        left(servo_arm_length/2-thickness)
        cyl(r=m3_radius, h=2*thickness, anchor=BOTTOM);
    }
}

// servo_arm();

module export_part() {

}

part = "";

module export_part_2d_no_render() {
    if(part == "gmarker_ring") {
        gondola_ring();
    }
    if(part == "gmarker_servo_holder") {
        gondola_servo_holder();
    }
    if(part == "gmarker_servo_arm") {
        servo_arm();
    }
}

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
    gondola_ring();
    gondola_servo_holder();
    servo_arm();
}