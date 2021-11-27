include <BOSL2/constants.scad>
include <BOSL2/std.scad>
use <BOSL2/shapes.scad>

// include <Round-Anything/polyround.scad>
// include <Round-Anything/MinkowskiRound.scad>

$fa=1;
$fs=0.1;

// 17x35x10mm
bearing_inner_diameter = 17;
bearing_outer_diameter = 35;
bearing_width = 10;
string_holder_notch = 10;


thickness = 4;

// Bearing
module bearing() {
    // color([0.5,0.5,0,0.5])
    tube(h=bearing_width, od=bearing_outer_diameter, id=bearing_inner_diameter);
}

// translate([100,200,0])
//     bearing();
gondola_diameter = 120;
servo_hold_height = 30;

// Gondola
module gondola(diameter=gondola_diameter, inner_tube_inner_diameter = 45, inner_tube_outer_diameter = 95) {
    // minkowskiRound(3, 6, 1, [diameter, diameter, diameter]) {
        difference() {
            union() {
                difference() {
                    tube(h=thickness, od=diameter, id=bearing_inner_diameter);
                    down(1)
                    tube(h=2*thickness, od=inner_tube_outer_diameter, id=inner_tube_inner_diameter);
                }
                cuboid([20,diameter-10,thickness], anchor=BOTTOM);
                difference() {
                    tube(h=thickness, od=diameter, id=bearing_inner_diameter);
                    translate([servo_hold_height,0,-1])
                    cuboid([diameter,diameter,2*thickness], anchor=BOTTOM);
                }
            }
            up(1)
            cyl(l=2*thickness, r=bearing_inner_diameter/2);
            // servo holder ears
            

            left(gondola_diameter/ 2 - servo_hold_height + thickness/2 + servo_height - screw_holder_y) //- servo_height + servo_hold_height)
            ycopies(servo_length+servo_screw_holder_ear, 2)
            down(1)
            cuboid([thickness, servo_screw_holder_ear, 2*thickness], anchor=BOTTOM);
        }
    // }
}

// translate([100,100,0])
    // gondola();

// Holder

// holder_outer_diameter = 45;
// holder_cap_h = 35; // height above center where the shape will be truncated.
module holder(holder_outer_diameter=45, holder_cap_h=35, notch=10) {
    difference() {
        up(thickness/2)
            teardrop(r=holder_outer_diameter/2, h=thickness, ang=30, cap_h=holder_cap_h, orient=BACK);
        cyl(l=2*thickness, r=bearing_outer_diameter/2);
        offsetY = 1;
        translate([0,bearing_outer_diameter/2+notch/2-offsetY/2,0])
            cuboid([thickness,notch+offsetY,2*thickness], anchor=BOTTOM);
    };
}

// translate([0,100,0])
//     holder();

string_hole_width = 1.8;
string_hole_inner_width = 0.8;

module string_holder1(height=40, width=10, notch=string_holder_notch, hole_height = 10, middle=false, fat_string=true) {
    difference() {
        union() {
            cuboid([width, height, thickness], anchor=BOTTOM);
            if(middle) {
                holder_width = width+thickness/2;
                holder_height = height-2*notch-hole_height;
                translate([holder_width/2,-height/2+holder_height/2,0])
                    cuboid([holder_width,holder_height,thickness], anchor=BOTTOM);
            }
        }
        translate([0,(height/2)-(notch/2)-notch,0])
            cuboid([thickness,notch,2*thickness], anchor=BOTTOM);
        hole_width = width/2+thickness/2;
        bottom = height/2; 
        translate([width/2-hole_width/2,bottom-2*notch-hole_height/2,0])
            cuboid([hole_width,hole_height, 2*thickness], anchor=BOTTOM);
        
        m = fat_string ? 2 : 1;
        left(middle ? -bearing_width / 2 - thickness / 2: 0)
        up(thickness/2)
        fwd(hole_height)
        xrot(90) {

            prismoid(size1=[m*string_hole_width,thickness], size2=[m*string_hole_inner_width,thickness], h=2.5);

            translate([0, 0, 2.5])
                prismoid(size1=[m*string_hole_inner_width,thickness], size2=[m*string_hole_width,thickness], h=2.5);

            up(5.0)
                cyl(l=thickness, r=m*string_hole_width/2, orient=FRONT);

        }
    }
}

// translate([0,200,0])
//     string_holder1();


module string_holder2(height=40, width=10, notch=string_holder_notch, hole_height = 10, middle=false, fat_string=true) {
    difference() {
        union() {
            cuboid([width, height, thickness], anchor=BOTTOM);
            holder_width = middle ? 2*thickness : thickness+width;
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
        
        m = fat_string ? 2 : 1;

        up(thickness/2)
        left(middle ? bearing_width/2 + thickness/2 : width/2+thickness+width/2)
        fwd(hole_height)
        xrot(90) {

            prismoid(size1=[m*string_hole_width,thickness], size2=[m*string_hole_inner_width,thickness], h=2.5);

            translate([0, 0, 2.5])
                prismoid(size1=[m*string_hole_inner_width,thickness], size2=[m*string_hole_width,thickness], h=2.5);

            up(5.0)
                cyl(l=thickness, r=m*string_hole_width/2, orient=FRONT);

        }
    }
}

// translate([0,300,0])
//     string_holder2();
string_diameter = 1;

module inside_tube(bearing_inner_diameter=17, max_pen_diameter=15, cap=false) {
    difference() {
        cyl(l=thickness, r=bearing_inner_diameter/2);
        down(1)
        fwd(bearing_inner_diameter/2-max_pen_diameter/2-0.1)
            cyl(l=2*thickness, r=max_pen_diameter/2);
        offset_y = 0.5;
        offset_x = 1;
        down(1)
        left(offset_x)
        fwd(-max_pen_diameter/2-string_diameter/2+offset_y)
            cyl(l=2*thickness, r=string_diameter/2);
        down(1)
        left(-offset_x)
        fwd(-max_pen_diameter/2-string_diameter/2+offset_y)
            cyl(l=2*thickness, r=string_diameter/2);
        if(cap) {
            fwd(bearing_inner_diameter/2)
                # cuboid([bearing_inner_diameter,bearing_inner_diameter,thickness], anchor=BOTTOM);
        }
    }
}

// translate([100,0,0])
    // inside_tube();
divider_weight_holder_width = 10;
divider_weight_holder_height = 20;
divider_weight_holder_offset = 2;

module divider(outer_diameter=25, weight=true) {
    union() {
        up(thickness/2)
        inside_tube();
        tube(h=thickness, od=outer_diameter, id=bearing_inner_diameter);
        fwd(outer_diameter/2+divider_weight_holder_height/2-divider_weight_holder_offset)
        if(weight) {
            difference () {
                cuboid([divider_weight_holder_width, divider_weight_holder_height, thickness], anchor=BOTTOM);
                margin = 3;
                fwd(divider_weight_holder_height/2-2*margin)
                down(1)
                cuboid([divider_weight_holder_width-2*margin, 2*margin, 2*thickness], anchor=BOTTOM);
                // cyl(l=2*thickness, r=string_diameter/2);
            }
        }
    }
}

// translate([100,300,0])
    // divider(weight=false);


servo_length = 22.5;
servo_height = 22.7;
servo_thickness = 11.8;
servo_screw_holder_ear = 4.7;
screw_holder_y = 15.9;


module servo9g() {
    length = servo_length;
    height = servo_height; // 22.7;
    thickness = servo_thickness; 
    
    head_height = 4;

    screw_holder_height = 2.5;
    screw_holder_ear = servo_screw_holder_ear;

    cuboid([length, thickness, height], anchor=BOTTOM);

    up(screw_holder_y)
    cuboid([length+2*screw_holder_ear, thickness, screw_holder_height], anchor=BOTTOM);

    left(22.5/2-11.8/2) {
        up(26.7-head_height)
        cyl(h=head_height, r=11.8/2);

        up(26.7)
        cyl(h=3.2, r=4.6/2);
    }
}

module servo_holder() {
    difference() {
        fwd(servo_screw_holder_ear/2 - 0.5*thickness)
        cuboid([servo_length + 2 * servo_screw_holder_ear, servo_thickness + servo_screw_holder_ear + thickness, thickness], anchor=BOTTOM);
        fwd(-0.5*thickness)
        cuboid([servo_length, servo_thickness + thickness, thickness], anchor=BOTTOM);
    }
}

render_index = -1;

module visu2d() {
    string_holder1(middle=true);
    left(12)
    string_holder2(middle=true);

    fwd(42) {
        string_holder1(middle=false);
        left(12)
        string_holder2(middle=false);
    }
    back(10)
    left(35)
    divider(weight=true);
    fwd(35)
    left(38)
    divider(weight=true);
    back(2)
    right(20)
    divider(weight=false);
    fwd(50)
    right(30)
    holder();

    back(0)
    right(56)
    zrot(180)
    holder();
    
    back(32)
    xcopies(bearing_inner_diameter+bearing_outer_diameter+2, 3)
    left(3*thickness/2+thickness)
    xcopies(bearing_inner_diameter+1, 3)
    inside_tube();

    fwd(40)
    left(112)
    gondola();

    fwd(-35)
    left(110)
    servo_holder();
}



module render2d(render_index = -1) {
    projection_renderer(render_index, kerf_width) {
        string_holder1(middle=true);
        left(12)
        string_holder2(middle=true);

        fwd(42) {
            string_holder1(middle=false);
            left(12)
            string_holder2(middle=false);
        }
        back(10)
        left(35)
        divider(weight=true);
        fwd(35)
        left(38)
        divider(weight=true);
        back(2)
        right(20)
        divider(weight=false);
        fwd(50)
        right(30)
        holder();

        back(0)
        right(56)
        zrot(180)
        holder();
        
        back(32)
        xcopies(bearing_inner_diameter+bearing_outer_diameter+2, 3)
        left(3*thickness/2+thickness)
        xcopies(bearing_inner_diameter+1, 3)
        inside_tube();

        fwd(40)
        left(112)
        gondola();

        fwd(-35)
        left(110)
        servo_holder();
    }
}

// render2d(render_index);

kerf_width = 0.0;

module compute_2D() {
    render() {
        offset(delta=kerf_width/2) {
            projection() {
                render2d();
            }
        }
    }
}

module projection_renderer(render_index = -1, kerf_width = kerf_width) {
    echo(num_components=$children);
    offset(delta=kerf_width/2) {
        projection() {
            if(render_index >= 0) {
                // Only include a single child, the one at index "render_index"
                children(render_index);
            } else {
                children();
            }
        }
    }
} 

// compute_2D();
module render3d() {

    left(bearing_width+thickness) {

        xrot(30)
        up(2*string_holder_notch + bearing_outer_diameter/2)
        left(bearing_width / 2 + thickness)
        zrot(180)
        xrot(-90)
        down(thickness/2)
        string_holder1(middle=true);

        xrot(-30)
        up(2*string_holder_notch + bearing_outer_diameter/2)
        left(1.5*bearing_width+2*thickness)
        zrot(180)
        xrot(-90)
        down(thickness/2)
        string_holder2(middle=true);

        // left(bearing_width/2+thickness/2)
        // xcopies(bearing_width+thickness, 2)
        // xrot(90)
        // yrot(-90)
        // divider();

        left(bearing_width+thickness)
        xrot(90)
        yrot(-90)
        divider(weight=true);

        left(2*bearing_width+2*thickness)
        xrot(90)
        yrot(-90)
        divider(weight=true);

        left(0)
        xrot(90)
        yrot(-90)
        divider(weight=false);

        left((thickness + bearing_width)/2)
        xrot(120)
        yrot(-90)
        holder();
        
        left((thickness + bearing_width)/2 + bearing_width + thickness)
        xrot(60)
        yrot(-90)
        holder();
        
        left(thickness)
        xcopies(bearing_width+thickness, 3)
        yrot(-90)
        #bearing();

        left(0)
        xcopies(bearing_width+thickness, 3)
        left(3*thickness/2+thickness)
        xcopies(thickness, 3)
        xrot(90)
        yrot(-90)
        inside_tube();
    }

    yrot(-90)
    gondola();

    left(thickness + servo_thickness / 2)
    down(servo_height + gondola_diameter/ 2 - servo_hold_height)
    zrot(-90) {
        servo9g();
        up(screw_holder_y-thickness)
        servo_holder();
    }
}

render3d();
// visu2d();