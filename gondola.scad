include <BOSL2/constants.scad>
include <BOSL2/std.scad>
use <BOSL2/shapes.scad>

// include <Round-Anything/polyround.scad>
// include <Round-Anything/MinkowskiRound.scad>


// 17x35x10mm
bearing_inner_diameter = 17;
bearing_outer_diameter = 35;
bearing_width = 10;

thickness = 3;

// Bearing
module bearing() {
    // color([0.5,0.5,0,0.5])
    tube(h=bearing_width, od=bearing_outer_diameter, id=bearing_inner_diameter);
}

translate([100,200,0])
    bearing();

// Gondola
module gondola(diameter=120, inner_tube_inner_diameter = 45, inner_tube_outer_diameter = 95, servo_hold_height = 30) {
    // minkowskiRound(3, 6, 1, [diameter, diameter, diameter]) {
        difference() {
            union() {
                difference() {
                    tube(h=thickness, od=diameter, id=bearing_inner_diameter);
                    tube(h=2*thickness, od=inner_tube_outer_diameter, id=inner_tube_inner_diameter);
                }
                cuboid([20,diameter-10,thickness], anchor=BOTTOM);
                difference() {
                    tube(h=thickness, od=diameter, id=bearing_inner_diameter);
                    translate([servo_hold_height,0,0])
                    cuboid([diameter,diameter,thickness], anchor=BOTTOM);
                }
            }
            cyl(l=2*thickness, r=bearing_inner_diameter/2);
        }
    // }
}
translate([100,100,0])
    gondola();

// Holder

// holder_outer_diameter = 45;
// holder_cap_h = 35; // height above center where the shape will be truncated.
module holder(holder_outer_diameter=45, holder_cap_h=35, notch=10) {
    difference() {
        up(thickness/2)
            teardrop(r=holder_outer_diameter/2, h=thickness, ang=30, cap_h=holder_cap_h, orient=BACK);
        cyl(l=2*thickness, r=bearing_outer_diameter/2);
        translate([0,bearing_outer_diameter/2+notch/2,0])
            cuboid([thickness,notch,2*thickness], anchor=BOTTOM);
    };
}

translate([0,100,0])
    holder();

module string_holder1(height=40, width=10, notch=10, hole_height = 10) {
    difference() {
        cuboid([width, height, thickness], anchor=BOTTOM);
        translate([0,(height/2)-(notch/2)-notch,0])
            cuboid([thickness,notch,2*thickness], anchor=BOTTOM);
        hole_width = width/2+thickness/2;
        bottom = height/2; 
        translate([width/2-hole_width/2,bottom-2*notch-hole_height/2,0])
            cuboid([hole_width,hole_height, 2*thickness], anchor=BOTTOM);
        
        up(thickness/2)
        fwd(hole_height)
        xrot(90) {

            prismoid(size1=[1.8,thickness], size2=[0.8,thickness], h=2.5);

            translate([0, 0, 2.5])
                prismoid(size1=[0.8,thickness], size2=[1.8,thickness], h=2.5);

            up(5.0)
                cyl(l=thickness, r=1.8/2, orient=FRONT, $fa=0.2, $fs=0.2);

        }
    }
}

translate([0,200,0])
    string_holder1();


module string_holder2(height=40, width=10, notch=10, hole_height = 10) {
    difference() {
        union() {
            cuboid([width, height, thickness], anchor=BOTTOM);
            holder_width = thickness+width;
            holder_height = height-2*notch-hole_height;
            translate([-holder_width/2-width/2,-height/2+holder_height/2,0])
                cuboid([holder_width,holder_height,thickness], anchor=BOTTOM);
        }
        translate([0,(height/2)-(notch/2)-notch,0])
            cuboid([thickness,notch,2*thickness], anchor=BOTTOM);
        sub_height = height - 2*notch;
        hole_width = width/2+thickness/2;
        bottom = height/2; 
        translate([width/2-hole_width/2,bottom-2*notch-sub_height/2,0])
            cuboid([hole_width,sub_height, 2*thickness], anchor=BOTTOM);
        
        up(thickness/2)
        left(width/2+thickness+width/2)
        fwd(hole_height)
        xrot(90) {

            prismoid(size1=[1.8,thickness], size2=[0.8,thickness], h=2.5);

            translate([0, 0, 2.5])
                prismoid(size1=[0.8,thickness], size2=[1.8,thickness], h=2.5);

            up(5.0)
                cyl(l=thickness, r=1.8/2, orient=FRONT, $fa=0.2, $fs=0.2);

        }
    }
}

translate([0,300,0])
    string_holder2();

module divider(inner_diameter=17, outer_diameter=25) {
    tube(h=thickness, od=outer_diameter, id=inner_diameter);
}

translate([100,300,0])
    divider();

module inside_tube(bearing_inner_diameter=17, max_pen_diameter=15, string_diameter=1, cap=false) {
    difference() {
        cyl(l=thickness, r=bearing_inner_diameter/2);
        fwd(bearing_inner_diameter/2-max_pen_diameter/2)
            cyl(l=thickness, r=max_pen_diameter/2);
        offset_y = 0.2;
        offset_x = 1;
        left(offset_x)
        fwd(-bearing_inner_diameter/2+string_diameter/2+offset_y)
            cyl(l=thickness, r=string_diameter/2, $fa=0.2, $fs=0.2);
        left(-offset_x)
        fwd(-bearing_inner_diameter/2+string_diameter/2+offset_y)
            cyl(l=thickness, r=string_diameter/2, $fa=0.2, $fs=0.2);
        if(cap) {
            fwd(bearing_inner_diameter/2)
                # cuboid([bearing_inner_diameter,bearing_inner_diameter,thickness], anchor=BOTTOM);
        }
    }
}

translate([100,0,0])
    inside_tube();
