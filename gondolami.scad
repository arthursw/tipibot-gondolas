include <BOSL2/constants.scad>
include <BOSL2/shapes.scad>
include <BOSL2/screws.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
include <BOSL2/gears.scad>

// All dimensions are from outer ends (i.e. width = from outer left to outer right)
// except when specified differently

thickness = 3;

gondola_length = 150;
gondola_outer_diameter = 200; // this is the total arc height ; the rail is rail_width bellow, the inner radius is gondola_outer_diameter - arc_width
arc_width = 20;
rail_depth = 5;
notch = 10;
gondola_height = 93; // bottom to body top
gondola_width = 70;

holder_margin = thickness;
holder_spacing = gondola_length - 4 * thickness - 2 * holder_margin;
holder_length = holder_spacing + 2 * thickness;
holder_width = 65;
holder_notch = 7.5;
holder_height = 50;

body_length = gondola_length - 6 * thickness;

wheel_diameter = 22;

m3_diameter = 3;
m3_radius = 3/2;
m3_nut_height = 2.4;
m3_nut_S = 5.5;
m3_screw_head_diameter = 5.5;

module h_notch(od=200, arc_width, notch=10, screw=false) {
    h_notch_position = [od/2-arc_width/2, thickness+thickness/2, 0];
    h_notch_size = [notch, thickness, 2*thickness];
    translate(h_notch_position) 
    if(screw) {
        cyl(r=m3_screw_head_diameter/2, l=2*thickness, $fs=1);
    } else {
        cuboid(h_notch_size, anchor=BOTTOM);
    }
}

module v_notch(od=200, width, height, notch=10, screw=false) {
    v_notch_position = [width/2, height-arc_width/2, 0];
    v_notch_size = [thickness, notch, 2*thickness];
    translate(v_notch_position)
    if(screw) {
        cyl(r=m3_screw_head_diameter/2, l=2*thickness, $fs=1);
    } else {
        cuboid(v_notch_size, anchor=BOTTOM);
    }
}

module main_arc_l(od=200, id=180, arc_width=20, notch=notch, width=gondola_width, height=gondola_height, marble_nut=0, marble_y=arc_width/2, side_marbles_y=0, side_marbles_x=0, screw=false) {
    difference() {
        back_half(y=0)
        tube(h=thickness, od=od, id=id, $fa=1);

        // horizontal notches
        h_notch(od, arc_width, notch, screw);
        xflip()
            h_notch(od, arc_width, notch, screw);
        
        // vertical notches
        v_notch(od, width, height, notch, screw);

        xflip()
            v_notch(od, width, height, notch, screw);

        if(marble_nut > 0) {
            e = marble_nut*2/sqrt(3);
            back(marble_y)
            cyl(r=e/2, l=2*thickness, $fn=6);
            
            if(side_marbles_y != 0) {
                back(side_marbles_y) {
                    left(side_marbles_x)
                    cyl(r=e/2, l=2*thickness, $fn=6);
                    
                    right(side_marbles_x)
                    cyl(r=e/2, l=2*thickness, $fn=6);
                }
            }
        }
    }
}
// main_arc_l(screw=true);

module main_arc(od=gondola_outer_diameter, arc_width=arc_width, notch=notch, width=gondola_width, height=gondola_height, marble_nut=0, side_marbles_y=0, side_marbles_x=0) {
    // render(){
        // Main / thick arc
        main_arc_l(od, od-2*arc_width, arc_width, notch, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x);
        
        // Thin arc
        color( rands(0,1,3), alpha=1 )
        up(thickness+0.01)
        main_arc_l(od-rail_depth,  od-2*arc_width+rail_depth, arc_width-rail_depth, notch, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, screw=true);
    // }
}

// main_arc(marble_nut=13);

module long_link2_body(s=100, anchor=CENTER, spin=0, orient=UP, arc_width=arc_width, length=gondola_length, notch=notch) {
    
    attachable(anchor,spin,orient, size=[arc_width, length, thickness]) {
        screw_length = 20;
        cuboid([arc_width, length, thickness], anchor=BOTTOM) {            
            // male notches
            attach([FRONT, BACK], overlap=0) cuboid([notch, thickness, thickness], anchor=BOTTOM, $tags="notch");
        }
        children();
    }
}
// long_link2_body(100) show_anchors(30);

module screw_notch(screw_length, n_nuts=1) {
    cuboid([thickness, 2*thickness, screw_length], anchor=TOP, $tags="screw"){
        step = screw_length/n_nuts;
        down(step/2) zcopies(step, n_nuts) cuboid([m3_nut_S, 2*thickness, m3_nut_height]);
    };
}

module long_link2(length=gondola_length, notch=notch, arc_width=arc_width) {
    
    screw_length = 15;

    color( rands(0,1,3), alpha=1 )
    diff("screw")
    long_link2_body(arc_width=arc_width, length=length, notch=notch) {
        // screw holes
        // attach([FRONT, BACK], overlap=0) up(thickness) cuboid([thickness, 2*thickness, screw_length], anchor=TOP, $tags="screw"){
        //     cuboid([m3_nut_S, 2*thickness, m3_nut_height]);
        // };
        attach([FRONT, BACK], overlap=0) up(thickness) screw_notch(screw_length);
    };
}

// long_link2();


module holder_bridge(width=holder_width, height=holder_height, length=170, prism_width=50, prism_height=30, prism_base=0, notch=holder_notch, notch_zpos=thickness, center_notch=false, leg_height=10) {
    up(height/2)
    xrot(90)
    diff("remove")
        cuboid([width, height, thickness], anchor=BOTTOM){
            if(center_notch) {
                position(FRONT) cuboid([notch, thickness, 2*thickness], anchor=FRONT, $tags="remove");
            } else {
                fwd(height/2-thickness/2-notch_zpos) {
                    attach(RIGHT, overlap=0) cuboid([thickness, 2*thickness, notch], anchor=TOP, $tags="remove");
                    attach(LEFT, overlap=0) cuboid([thickness, 2*thickness, notch], anchor=TOP, $tags="remove");
                }
            }
            fwd(-height/2+leg_height)
            xrot(90)
            prismoid(size1=[prism_width,2*thickness], size2=[prism_base,2*thickness], h=prism_height, $tags="remove");

            fwd(-height/2+leg_height)
            cuboid([prism_width, leg_height, 2*thickness], anchor=FRONT, $tags="remove");
        }
}
// holder_bridge();

rail_thickness = 3.279;
wheel_rail_depth = 2;

module wheel() {
    cyl(l=wheel_thickness, r=wheel_diameter/2-wheel_rail_depth) {
        attach(BOTTOM, overlap=0) cyl(l=(wheel_thickness-rail_thickness)/2, r=wheel_diameter/2, anchor=TOP, $fn=100);
        attach(TOP, overlap=0) cyl(l=(wheel_thickness-rail_thickness)/2, r=wheel_diameter/2, anchor=TOP, $fn=100);
    };
}

interval_between_wheels = arc_width + wheel_diameter - 2 * wheel_rail_depth;
top_wheel_top_to_double_caster_top = 30;
double_caster_height = interval_between_wheels + wheel_diameter + top_wheel_top_to_double_caster_top; // == total double caster height
total_wheel_width = 19;
wheel_thickness = 8;
washer_thickness = 1;
wheel_center_to_side = wheel_thickness/2 + 2 * washer_thickness + 2 * thickness;
axe_diameter = 4.5;

module double_caster_side(assembly_notch=false) {
    difference() {
        cube_height = top_wheel_top_to_double_caster_top + wheel_diameter/2;

        cyl(l=thickness, r=wheel_diameter/2) {
            fwd(interval_between_wheels/2)
            cuboid([wheel_diameter, interval_between_wheels, thickness]);

            fwd(interval_between_wheels+cube_height/2)
            cuboid([wheel_diameter, cube_height, thickness]);
        };
        cyl(l=thickness, r=axe_diameter/2);

        fwd(interval_between_wheels)
        cyl(l=thickness, r=axe_diameter/2);

        if(assembly_notch) {
            fwd(interval_between_wheels + cube_height - notch/2)
            cuboid([thickness, notch, 2*thickness]);
        }
    }
}

module double_caster_main() {
    double_caster_side(true);
    up(thickness)
    double_caster_side(true);
}

module wheel_axe() {
    
    axe_length = total_wheel_width;
    axe_out_length = axe_length-wheel_thickness;

    wheel();

    // Axe
    up(wheel_thickness/2-axe_length/2)
    cyl(l=axe_length, r=axe_diameter/2);

    // Wheel washer
    up(-wheel_thickness/2-washer_thickness/2)
    cyl(l=washer_thickness, r=8/2);

    // Washers
    up(-wheel_thickness/2-2*washer_thickness-thickness)
    zcopies(2*thickness+washer_thickness)
    cyl(l=washer_thickness, r=9/2);
    
    // Screw head
    screw_head_height = 1;
    up(wheel_thickness/2-axe_length+screw_head_height/2)
    cyl(l=screw_head_height, r=7/2);
}

// wheel_axe();

module double_caster() {

    up(thickness/2)
    double_caster_main();

    up(wheel_center_to_side) {
        wheel_axe();
    }
    
    fwd(interval_between_wheels)
    up(wheel_center_to_side) {
        wheel_axe();
    }
}
// double_caster();
wing_height = 150; // total wing height including wing_ear_height

wing_middle_length = gondola_length - 2*(wheel_center_to_side+thickness/2); // distance between the two notche centers

wing_ear_height = 25;
wing_ear_width = 25;

wing_length = wing_middle_length + wing_ear_width; // distance between the outer ends

// wing_minor_height / wing_height = wing_minor_width / (wing_length/2);
// wing_minor_width = (wing_length/2) - wing_ear_width;
// wing_minor_height = wing_height * wing_minor_width / (wing_length/2);
// wing_thickness_height = wing_height - wing_minor_height;

wing_triangle_height = wing_height - wing_ear_height;
wing_triangle_width = wing_length / 2;

// wing_ear_width / wing_triangle_width = wing_thickness_height / wing_triangle_height;

wing_thickness_height = wing_triangle_height * wing_ear_width / wing_triangle_width;

module half_wing() {

    points = [[0,0], 
    [wing_triangle_width, wing_triangle_height], 
    [wing_triangle_width, wing_triangle_height - wing_thickness_height], [wing_ear_width, 0], 
    [0,0]];

    down(thickness/2)
    difference() {
        union() {
            back(wing_ear_height)
            linear_extrude(thickness)
            polygon(points);
            cube([wing_ear_width,wing_ear_height,thickness], $tags="pos");
        }
        
        // notch
        translate([wing_ear_width/2,notch/2,0])
        cuboid([2*thickness,notch,2*thickness], anchor=BOTTOM, $tags="remove");
    }

}

// half_wing();

module wing() {
    mirror_copy(LEFT, wing_length/2)
    half_wing();
}
// wing();
module double_caster_wing() {
    fwd(double_caster_height-wheel_diameter/2-2*notch)
    zrot(180)
    wing();

    color( rands(0,1,3), alpha=1 )
    mirror_copy(RIGHT, wing_middle_length/2-thickness)
    yrot(90)
    double_caster();
}

// double_caster_wing();

module vlink(length, arc_width=arc_width, body_height=15) {
    color( rands(0,1,3), alpha=1 )
    union() {
        diff("screw") {
            long_link2(length, arc_width=arc_width);
            right(arc_width/2+body_height/2)
            cuboid([body_height, body_length, thickness], anchor=BOTTOM) {
                attach(RIGHT) xcopies(length-6*thickness, 2) screw_notch(15, 2);
            };
        }
    }
}
// vlink(gondola_length-4*thickness);

module holder_simple(length=150, width=holder_width, sliding_magnet_width=20, height=50, end_pos=30, prism_width=50, prism_base=20, prism_height=20, leg_height=29) {
    // render() {
        
        // sliding magnets
        up(height-thickness)
        sliding_magnet(length, sliding_magnet_width, n_magnets);
        
        mirror_copy(FRONT, length/2-end_pos)
        up(height)
        zflip()
        holder_bridge(width=width, height=height, center_notch=true, notch=sliding_magnet_width, prism_width=prism_width, prism_base=prism_base, prism_height=prism_height, leg_height=leg_height);

    // }
}

module servo9g() {
    length = 22.5;
    height = 22.7;
    thickness = 11.8; 
    
    head_height = 4;

    screw_holder_y = 15.9;
    screw_holder_height = 2.5;
    screw_holder_ear = 4.7;

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

module servo_holder_dovetail(dx, dy, dz, dt_width, dt_spacing, n) {

    diff("remove")
    cuboid([dx, dy, dz], anchor=BOTTOM){
        attach(BACK) xcopies(dt_spacing, n) dovetail("female", angle=0, slide=dz, width=dt_width, height=dz, $tags="remove");

        attach(FRONT) xcopies(dt_spacing, n) dovetail("female", angle=0, slide=dz, width=dt_width, height=dz, $tags="remove");

        mirror_copy(FRONT, dy/2-m3_radius) {
            mirror_copy(LEFT, dx/2-m3_radius) {
                screw_hole();
            }
        }
    }
}

module servo_case_side(dx, dy, dz, dt_width, dt_spacing, n) {

    cuboid([dx-2*m3_diameter, dy, dz], anchor=BOTTOM){
        attach(BOTTOM) xcopies(dt_spacing, n) dovetail("male", angle=0, slide=dy, width=dt_width, height=dy);
        attach(TOP) xcopies(dt_spacing, n) dovetail("male", angle=0, slide=dy, width=dt_width, height=dy);
    }
}

rack_n_teeth = 12;
gear_n_teeth = 16;
pitch = 5;
rack_length = rack_n_teeth * pitch;

module servo_gears(position=-1) {
    
    rack_height = 15;
    helical = 0;

    pr = pitch_radius(pitch=pitch, teeth=gear_n_teeth); // 12.7324
    down(pr) {
        right(position > 0 ? rack_length/2+pitch : -rack_length/2+pitch)
        rack(pitch=pitch, teeth=rack_n_teeth, thickness=thickness, height=rack_height, helical=helical);

        up(pr) yrot(180.0-$t*360/gear_n_teeth)
        spur_gear(pitch=pitch, teeth=gear_n_teeth, thickness=thickness, helical=helical, shaft_diam=5, orient=BACK);
    }

}
// servo_gears();

module servo_case_raw() {
    width = servo_case_width;
    length = servo_case_length;

    y_offset = 11.125;
    
    fwd(y_offset) {
        servo9g();

        // Gear

        left(22.5/2-11.8/2)
        up(26.7)
        xrot(90)
        servo_gears();
    }

    servo_width = 11.8;
    servo_length = 22.5;
    servo_holder_y = 15.9 + 2.5;

    servo_holder_length = length; //servo_length + 2 * 20;
    servo_holder_width = width; //servo_width + 2 * 30;
    
    dovetail_spacing = 20;
    dovetail_width = 10;
    n_dovetails = 2;
    
    // Servo holder
    color( rands(0,1,3), alpha=1 )
    up(servo_holder_y)
    difference() {

        // Create servo holder board with dovetails
        servo_holder_dovetail(servo_holder_length, servo_holder_width, thickness, dovetail_width, dovetail_spacing, n_dovetails);
        
        // Remove servo print
        fwd(y_offset) {
            cuboid([servo_length+1, servo_width+1, 2*thickness], anchor=BOTTOM);

            left(servo_length/2+4.7-2.3)
            cyl(l=2*thickness, r=1, $fs=1);

            right(servo_length/2+4.7-2.3)
            cyl(l=2*thickness, r=1, $fs=1);
        }
    };

    side_height = 10;

    // Case sides
    up(servo_holder_y+thickness) {
        fwd(servo_holder_width/2-thickness/2)
        servo_case_side(servo_holder_length, thickness, side_height, dovetail_width, dovetail_spacing, n_dovetails);
        back(servo_holder_width/2-thickness/2)
        servo_case_side(servo_holder_length, thickness, side_height, dovetail_width, dovetail_spacing, n_dovetails);
    }

    
}

// servo_case_raw();

module servo_case() {
    up(34)
    xrot(180) {
        servo_case_raw();
    }
}

module screw_hole(od=8) {
    cyl(r=od/2, l=thickness, $fs=1);
    cyl(r=m3_radius, l=2*thickness, $tags="remove", $fs=1);
}

module body_slider(slider_width, servo_case_width, servo_case_length, slider_offset_x) {
    diff("remove")
    cuboid([slider_width, body_length, thickness], anchor=BOTTOM){

        left(servo_case_width/2-slider_offset_x-thickness/2)
        zrot(90)
        attach(TOP) {
            xcopies(20, 2)
            dovetail("female", angle=0, slide=thickness, width=10, height=thickness, $tags="remove");
            xcopies(servo_case_length-2*m3_radius, 2) {
                down(thickness/2) screw_hole();
            }
        }

        
        position(LEFT) right(m3_radius) mirror_copy(FRONT, (body_length-4*thickness) / 2) {
            screw_hole();
        };

    }
}

body_width = gondola_width;

sliding_magnet_plate_width = 20;
sliding_magnet_top_width = 30;

slider_margin = 2;
slider_spacing = sliding_magnet_plate_width + slider_margin;
slider_width = (body_width - slider_spacing) / 2;

slider_offset_x = (body_width - slider_width) / 2;

servo_case_width = 58;
servo_case_length = 40;
body_sliders_link = 5;
sliding_magnet_length = rack_length;

magnet_spacing = 10;
magnet_size = 5;
n_magnets = 6;

module sliding_magnet(length, width, n_magnets) {
    difference() {
        cuboid([width, length, thickness], anchor=BOTTOM);
        ycopies(magnet_spacing, n_magnets)
        cuboid([magnet_size, magnet_size, magnet_size], anchor=BOTTOM);
    }
}

blocker_length = 15;
module blocker() {
    diff("remove") {
        cuboid([body_width, blocker_length, thickness], anchor=BOTTOM);
        
        back(blocker_length/2-2*thickness)
        mirror_copy(LEFT, body_width/2-m3_radius)
        up(thickness/2)
        screw_hole();
    }
}
// blocker();

module main_body_plate() {
    union () {
        mirror_copy(LEFT, slider_offset_x) body_slider(slider_width, servo_case_width, servo_case_length, slider_offset_x);
        
        mirror_copy(FRONT, body_length/2-body_sliders_link/2) cuboid([gondola_width/2, body_sliders_link, thickness], anchor=BOTTOM);
    }
}

module body() {

    main_body_plate();

    mirror_copy(FRONT, body_length/2-20)
    up(notched_wedge_height/2-thickness)
    mirror_copy(LEFT, body_width/2-notched_wedge_width/2+3*thickness)
    xrot(-90)
    notched_wedge();

    zrot(90) servo_case();

    // Sliding magnet
    fwd(sliding_magnet_length/2)
    union() {
        sliding_magnet(sliding_magnet_length, sliding_magnet_plate_width, n_magnets);
        up(thickness)
        sliding_magnet(sliding_magnet_length, sliding_magnet_top_width, n_magnets);
    }

    down(thickness)
    back(body_length/2-blocker_length/2)
    blocker();
}

// body();

module marble() {
    ball_holder_height = 17-2.5;
    ball_holder_y = 15;
    ball_holder_radius = 22/2;
    ball_radius = 12/2;
    up(ball_holder_y+ball_holder_height/2)
    cyl(l=ball_holder_height, r=ball_holder_radius);
    up(ball_holder_y+17-ball_radius)
    sphere(r=ball_radius);
    up(ball_holder_y/2)
    cyl(l=ball_holder_y, r=8/2-0.5);

    nut("M8", 13, 7.8);
}

notched_wedge_width = 10*thickness;
notched_wedge_height = 12*thickness;

module notched_wedge() {
    notch_length = notched_wedge_width - thickness;
    diff("remove") {
        cuboid([notched_wedge_width, notched_wedge_height, thickness]);

        translate([notched_wedge_width/2-notch_length/2, notched_wedge_height/2-thickness/2 - thickness, 0])
        cuboid([notch_length, thickness, 2*thickness], $tags="remove");

        translate([4*thickness, 4*thickness, 0])
        translate([notched_wedge_width/2-notch_length/2, -notched_wedge_height/2+thickness/2, 0])
        line_of([thickness,thickness], n=9) cuboid([notch_length, thickness, 2*thickness], $tags="remove");
    }
}

// notched_wedge();

module three_d_structure() {

    fwd(-gondola_length/2+2*thickness)
    zrot(180)
    xrot(90)
    main_arc();

    fwd(gondola_length/2-2*thickness)
    xrot(90)
    main_arc(marble_nut=13);

    // H links
    mirror_copy(LEFT, gondola_outer_diameter/2-arc_width/2)
    up(thickness)
    long_link2(gondola_length-4*thickness);

    // V links
    mirror_copy(LEFT, gondola_width/2)
    up(gondola_height-arc_width/2)
    yrot(90)
    vlink(gondola_length-4*thickness);

}

squeezer_length = 140;
squeezer_diameter = 45;

module three_d_inside() {

    // squeezer holder
    // fwd(gondola_length/2+front_arc_out_to_wall-squeezer_length/2)
    down(25)
    holder_simple(length=squeezer_length, height=55);

    // Point 88 holder
    // down(4)
    // holder_simple(length=150, width=30, sliding_magnet_width=20, height=20, end_pos=30, prism_width=18, prism_base=0, prism_height=10, leg_height=0);

    front_arc_out_to_wall = 26; // approximately, can be changed with marble screw
    // Pen
    
    //   Squeezer
    color( rands(0,1,3), alpha=1 )
    fwd(gondola_length/2+front_arc_out_to_wall-squeezer_length/2)
    xrot(90)
    cyl(l=squeezer_length, r=squeezer_diameter/2);
    
    // //   Stabilo point 88
    stabilo_point_88_length = 166;
    stabilo_point_88_diameter = 8;
    color( rands(0,1,3), alpha=1 )
    fwd(gondola_length/2+front_arc_out_to_wall-stabilo_point_88_length/2)
    xrot(90)
    cyl(l=stabilo_point_88_length, r=stabilo_point_88_diameter/2, $fn=6);

    up(30+thickness)
    body();
}

module three_d() {

    three_d_structure();

    three_d_inside();

    mirror_copy(LEFT, 0)
    yrot(-45)
    right(gondola_outer_diameter/2-arc_width-wheel_diameter/2+wheel_rail_depth)
    zrot(90)
    double_caster_wing();

    fwd(gondola_length/2-2*thickness)
    up(gondola_outer_diameter/2-arc_width/2)
    xrot(90)
    marble();
}

// marble();

// Todo
// - stronger pen holder 
// - double caster axe end?
// - screw to attach double caster to wing
// - screw for double caster?
// - screws for sliding magnet and rack?
// - switch between pos
// - 3 marbles
// - real squeezer
// - switch between squeezer and point88
// - compute body heights with different pens?
// - 2D view
// - pen alignment helper on pen holder!
// - targets to see home position
// - weights (find empty plastic flask)
// - shopping list

// V2
// - add solenoid
//   - add 4 wheels
//   - increase height
//   - double rack
//   - springboard
//   - solenoid holder
//   - solenoid / slider attachment

// V3
// - put motors on the wings
//   - put raspberry pi and arduino + ramps

// V4
// - multiple pens on the gondola

// #cuboid([gondola_width, gondola_length, gondola_height], anchor=BOTTOM);
three_d();