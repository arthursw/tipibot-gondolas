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
pen_holder_width = 65;
holder_height = 50;

body_length = gondola_length - 6 * thickness;

wheel_diameter = 22;

m3_diameter = 3;
m3_radius = 3/2;
m3_nut_height = 2.4;
m3_nut_S = 5.5;
m3_screw_head_diameter = 5.5;

arc_notch = 14;

pen_front_offset = 20;
pen_holder_center_to_pen_tip = body_length/2 + pen_front_offset;

front_arc_out_to_wall = 26; // approximately, can be changed with marble screw
pen_tip_to_wall = gondola_length / 2 + front_arc_out_to_wall - pen_holder_center_to_pen_tip;       // approximately, can be changed with marble screw

pen_rest_position = 0;
pen_wall_position = pen_tip_to_wall;
pen_back_position = -15;

pen_position = pen_back_position;

flask_height = 120;
flask_diameter = 38;

link_length = gondola_length - 4 * thickness;
side_comb_pos = link_length / 2 - 7 * thickness;
vlink_height = 15;

module h_notch(od=200, arc_width, screw=false) {
    h_notch_position = [od/2-arc_width/2, thickness+thickness/2, 0];
    h_notch_size = [arc_notch, thickness, 2*thickness];
    translate(h_notch_position) 
    if(screw) {
        cyl(r=m3_screw_head_diameter/2, l=2*thickness, $fs=1);
    } else {
        cuboid(h_notch_size, anchor=BOTTOM);
    }
}

module v_notch(od=200, width, height, screw=false) {
    v_notch_position = [width/2, height-arc_width/2, 0];
    v_notch_size = [thickness, arc_notch, 2*thickness];
    translate(v_notch_position)
    if(screw) {
        cyl(r=m3_screw_head_diameter/2, l=2*thickness, $fs=1);
    } else {
        cuboid(v_notch_size, anchor=BOTTOM);
    }
}

module main_arc_l(od=200, id=180, arc_width=20, width=gondola_width, height=gondola_height, marble_nut=0, marble_y=arc_width/2, side_marbles_y=0, side_marbles_x=0, screw=false) {
    difference() {
        back_half(y=0)
        tube(h=thickness, od=od, id=id, $fa=1);

        // horizontal notches
        h_notch(od, arc_width, screw);
        xflip()
            h_notch(od, arc_width, screw);
        
        // vertical notches
        v_notch(od, width, height, screw);

        xflip()
            v_notch(od, width, height, screw);

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
target_width = 3*thickness;
target_height = 2*notch;

module target() {
    back(target_height/2)
    difference() {
        cuboid([target_width, target_height, thickness], anchor=BOTTOM);
        back(target_height/2-notch/2)
        cuboid([thickness, notch, thickness], anchor=BOTTOM);
    }
}

// target();

module main_arc(od=gondola_outer_diameter, arc_width=arc_width, width=gondola_width, height=gondola_height, marble_nut=0, side_marbles_y=0, side_marbles_x=0, targets=false) {
    // render(){
        // Main / thick arc
        union() {
            main_arc_l(od, od-2*arc_width, arc_width, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x);
            if(targets) {
                // top target
                back(gondola_outer_diameter/2)
                target();

                back(target_width/2)
                mirror_copy(LEFT, gondola_outer_diameter/2-2)
                zrot(90)
                target();
            }
        }
        
        // Thin arc
        color( rands(0,1,3), alpha=1 )
        up(thickness+0.01)
        main_arc_l(od-rail_depth,  od-2*arc_width+rail_depth, arc_width-rail_depth, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, screw=true);
    // }
}

// main_arc(marble_nut=13, targets=true);

link_screw_length = 15;

module long_link2_body(s=100, anchor=CENTER, spin=0, orient=UP, arc_width=arc_width, length=gondola_length) {
    
    attachable(anchor,spin,orient, size=[arc_width, length, thickness]) {
        cuboid([arc_width, length, thickness], anchor=BOTTOM) {            
            // male notches
            attach([FRONT, BACK], overlap=0) cuboid([arc_notch, thickness, thickness], anchor=BOTTOM, $tags="notch");
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

module long_link2(length=link_length, arc_width=arc_width) {
    
    

    color( rands(0,1,3), alpha=1 )
    diff("screw")
    long_link2_body(arc_width=arc_width, length=length) {
        // screw holes
        // attach([FRONT, BACK], overlap=0) up(thickness) cuboid([thickness, 2*thickness, link_screw_length], anchor=TOP, $tags="screw"){
        //     cuboid([m3_nut_S, 2*thickness, m3_nut_height]);
        // };
        attach([FRONT, BACK], overlap=0) up(thickness) screw_notch(link_screw_length);
    };
}

// long_link2();
hlink_margin = 10;
hlink_weight_length = link_length - 2 * link_screw_length - 2 * hlink_margin;
hlink_width = flask_diameter + 2 * hlink_margin;

module hlink() {
    difference() {
        
        // Ring body
        union() {
            long_link2();
            cuboid([hlink_width, hlink_weight_length + 2 * hlink_margin, thickness], anchor=BOTTOM, rounding=(hlink_width)/2, edges=[FRONT+LEFT,FRONT+RIGHT, BACK+LEFT,BACK+RIGHT]);
        }

        // Interior hole
        cuboid([flask_diameter, hlink_weight_length, 2*thickness], anchor=BOTTOM, rounding=flask_diameter/2, edges=[FRONT+LEFT,FRONT+RIGHT, BACK+LEFT,BACK+RIGHT]);

        // Screw sliders
        mirror_copy(LEFT, hlink_width/2-hlink_margin/2)
        cuboid([m3_diameter, hlink_weight_length-flask_diameter+m3_diameter, 2*thickness], anchor=BOTTOM, rounding=m3_diameter/2, edges=[FRONT+LEFT,FRONT+RIGHT, BACK+LEFT,BACK+RIGHT],$fn=10);
    }
}

module hlink_cap() {
    difference() {
        tube(h=thickness, od=hlink_width, id=flask_diameter, $fn=30);
        
        // Screw holes
        mirror_copy(LEFT, hlink_width/2-hlink_margin/2)
        cyl(r=m3_radius, l=2*thickness, $fn=10);
    }
}

module hlink_ensemble() {
    hlink();
    up(thickness)
    hlink_cap();
}

module holder_bridge(width=pen_holder_width, height=holder_height, length=170, prism_width=50, prism_height=30, prism_base=0, notch_zpos=3*thickness, center_notch=-1, side_notches=-1, leg_height=10) {
    up(height/2)
    xrot(90)
    diff("remove")
        cuboid([width, height, thickness], anchor=BOTTOM){
            // center notch
            if(center_notch > 0) {
                position(FRONT) cuboid([center_notch, thickness, 2*thickness], anchor=FRONT, $tags="remove");
            }
            if(side_notches > 0) {
                fwd(height/2-thickness/2-notch_zpos) {
                    attach(RIGHT, overlap=0) cuboid([thickness, 2*thickness, side_notches], anchor=TOP, $tags="remove");
                    attach(LEFT, overlap=0) cuboid([thickness, 2*thickness, side_notches], anchor=TOP, $tags="remove");
                }
            }
            // Prism
            fwd(-height/2+leg_height)
            xrot(90)
            prismoid(size1=[prism_width,2*thickness], size2=[prism_base,2*thickness], h=prism_height, $tags="remove");

            // Legs
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
axe_diameter = 4.4;

double_caster_screw_y = 5;

module double_caster_side(assembly_notch=false) {
    difference() {
        cube_height = top_wheel_top_to_double_caster_top + wheel_diameter/2;

        // Main part
        cyl(l=thickness, r=wheel_diameter/2) {
            fwd(interval_between_wheels/2)
            cuboid([wheel_diameter, interval_between_wheels, thickness]);

            fwd(interval_between_wheels+cube_height/2-wheel_diameter/4)
            cuboid([wheel_diameter, cube_height-wheel_diameter/2, thickness]);

            fwd(interval_between_wheels+cube_height-wheel_diameter/2) cyl(l=thickness, r=wheel_diameter/2);
        };

        // Axe holes
        cyl(l=thickness, r=axe_diameter/2);

        fwd(interval_between_wheels)
        cyl(l=thickness, r=axe_diameter/2);

        // Screw hole
        fwd(interval_between_wheels + wheel_diameter/2 + double_caster_screw_y)
        cyl(l=2*thickness, r=m3_diameter/2, $fn=15);

        // Assembly notch
        if(assembly_notch) {
            fwd(interval_between_wheels + cube_height - notch/2)
            cuboid([thickness, notch, 2*thickness]);
        }
        
        // Subnotch
        mirror_copy(LEFT, thickness)
        fwd(interval_between_wheels + cube_height - 2 * notch + wing_subnotch_y)
        cuboid([thickness, thickness, 2*thickness]);
    }
}

// double_caster_side(true);

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

wing_ear_height = 25;
wing_ear_width = 25;
wing_notch_x = 10;

wing_middle_length = gondola_length + 2 * (wheel_center_to_side-2.5*thickness); // distance between the two notche centers

wing_length = wing_middle_length + 2 * wing_notch_x; // distance between the outer ends

// wing_minor_height / wing_height = wing_minor_width / (wing_length/2);
// wing_minor_width = (wing_length/2) - wing_ear_width;
// wing_minor_height = wing_height * wing_minor_width / (wing_length/2);
// wing_thickness_height = wing_height - wing_minor_height;

wing_triangle_height = wing_height - wing_ear_height;
wing_triangle_width = wing_length / 2;

// wing_ear_width / wing_triangle_width = wing_thickness_height / wing_triangle_height;

wing_thickness_height = wing_triangle_height * wing_ear_width / wing_triangle_width;
wing_subnotch_y = notch + thickness / 2;
wing_subnotch_length = 0.5*notch;

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
        translate([wing_notch_x,notch/2,0])
        cuboid([2*thickness,notch,2*thickness], anchor=BOTTOM, $tags="remove");
        
        // subnotch
        translate([wing_ear_width-wing_subnotch_length/2, wing_subnotch_y, 0])
        cuboid([wing_subnotch_length,thickness,2*thickness], anchor=BOTTOM, $tags="remove");
    }

}

// half_wing();
string_hole_length = 15;
string_hole_y = 5;
string_hole_margin = 6;
string_hole_diameter = 6;
string_hole_thin = 2.5;
string_hole_width = string_hole_thin + 2 * string_hole_margin;

module string_hole() {
    xrot(-90)
    union() {
        cyl(l=2*thickness, r=string_hole_diameter/2, orient=FRONT, $fn=20);
        cuboid([string_hole_thin, 2*thickness, string_hole_length], anchor=BOTTOM);
        up(string_hole_length)
        cyl(l=2*thickness, r=string_hole_thin/2, orient=FRONT, $fn=10);
        
    }
}
module wing() {
    difference() {
        union() {
            mirror_copy(LEFT, wing_length/2) half_wing();
            
            // string hole sides
            back(wing_height-string_hole_y-string_hole_length/2)
            cuboid([string_hole_width,string_hole_length+2*string_hole_margin,thickness]);
        }
    
        // string hole
        back(wing_height-string_hole_length-string_hole_y)
        string_hole();
    }
}

// wing();

module double_caster_wing_attachment() {
    double_caster_wing_attachment_width = 3*thickness;
    difference() {
        cuboid([wing_ear_width, thickness, double_caster_wing_attachment_width]){
            position(RIGHT) cuboid([wing_ear_width-wing_notch_x-thickness, thickness, double_caster_wing_attachment_width+2*thickness], anchor=RIGHT);
        };
        // notch
        left(wing_subnotch_length)
        cuboid([wing_ear_width, thickness, thickness]);
    }
}

module wing_with_attachment() {
    wing();
    mirror_copy(RIGHT, -wing_length/2+wing_ear_width/2)
    back(wing_subnotch_y)
    double_caster_wing_attachment();
}
// wing_with_attachment();

module double_caster_wing() {
    fwd(double_caster_height-wheel_diameter/2-2*notch)
    zrot(180)
    wing_with_attachment();

    color( rands(0,1,3), alpha=1 )
    mirror_copy(RIGHT, wing_middle_length/2+thickness)
    yrot(-90)
    double_caster();
}

// double_caster_wing();

module vlink(length=link_length, arc_width=arc_width) {
    
    total_height = vlink_height+arc_width;

    color( rands(0,1,3), alpha=1 )
    union() {
        diff("screw") {
            long_link2(length, arc_width=arc_width);
            right(arc_width/2+vlink_height/2)
            cuboid([vlink_height, body_length, thickness], anchor=BOTTOM) {
                attach(RIGHT) xcopies(length-6*thickness, 2) screw_notch(15, 2);
            };

            n_notches = ceil((total_height / thickness) / 2);
            comb_height = n_notches * 2 * thickness;
            left(-arc_width/2-vlink_height+comb_height/2+thickness/2)
            mirror_copy(FRONT, side_comb_pos)
            xcopies(comb_height / n_notches, n_notches)
            {
                cuboid([thickness, thickness, 2*thickness], $tags="screw");
                right(thickness)
                back(2*thickness)
                cuboid([thickness, thickness, 2*thickness], $tags="screw");
            }
        }
    }
}

module vlink_with_comb(length=link_length, arc_width=arc_width) {
    vlink();
    side_comb_height = thickness*21;
    side_comb_notch = notch/2;
    side_comb_width = 3*side_comb_notch;

    down(thickness)
    left(-arc_width/2-vlink_height-side_comb_height/2+12*thickness)
    mirror_copy(FRONT, side_comb_pos)
    xrot(-90)
    zrot(90)
    comb(side_comb_height, side_comb_notch, side_comb_width);

}

// vlink_with_comb();

// Comb
module comb(length, notch, width = -1) {
    width = width < 0 ? 2 * notch : width;
    echo(width);
    n_notches = floor((length / thickness) / 2);
    notches_length = n_notches * 2 * thickness;
    difference() {
        cuboid([width, length, thickness]);
        
        left(width/2-notch/2)
        ycopies(notches_length/n_notches, n_notches) 
        cuboid([notch, thickness, thickness]);
    }
}

// comb(squeezer_length, notch, 30);

blocker_margin = 5;
sliding_magnet_width = 20;

module pen_holder(length=body_length-magnet_blocker_length-blocker_margin, height=50, bridge_pos=30, prism_width=46, prism_base=20, prism_height=16, leg_height=32) {
    // render() {
        holder_notch = 8;
        notch_zpos = 3 * thickness;
        width = pen_holder_width;
        // sliding magnets
        fwd(magnet_blocker_length/2+blocker_margin/2)
        up(height-thickness)
        sliding_magnet(length, sliding_magnet_width, n_magnets);
        
        mirror_copy(FRONT, length/2-bridge_pos)
        up(height)
        zflip()
        ycopies(10, 2)
        holder_bridge(width=width, height=height, center_notch=sliding_magnet_width, side_notches=holder_notch, notch_zpos=notch_zpos, prism_width=prism_width, prism_base=prism_base, prism_height=prism_height, leg_height=leg_height);

        mirror_copy(LEFT, -width/2+holder_notch)
        up(height-notch_zpos-thickness/2)
        comb(length, holder_notch);
    // }
}

module squeezer_holder() {
    squeezer_holder_height = 55;
    squeezer_holder_y = -25;
    up(squeezer_holder_y)
    pen_holder(height=squeezer_holder_height, bridge_pos=18);

    up(squeezer_holder_height+squeezer_holder_y)
    fwd(body_length/2)
    yrot(180)
    pen_wedge();
}

// squeezer_holder();

module squeezer_ensemble() {
    squeezer_holder();

    //   Squeezer
    color( rands(0,1,3), alpha=1 )
    // fwd(gondola_length/2+front_arc_out_to_wall-squeezer_length)
    fwd(body_length/2-squeezer_length+pen_front_offset)
    xrot(90)
    squeezer();
}
// squeezer_ensemble();
// down(25) pen_holder(length=squeezer_length, height=55);

squeezer_length = 140;

module squeezer() {
    squeezer_inner_diameter = 40;
    points = [
        [0,0],
        [squeezer_diameter/2,0],
        [squeezer_diameter/2,25],
        [squeezer_inner_diameter/2,34],
        [squeezer_inner_diameter/2,83],
        [squeezer_diameter/2,91],
        [squeezer_diameter/2,110],
        [squeezer_inner_diameter/2,115],
        [squeezer_inner_diameter/2,117],
        [30/2,117],
        [30/2,137],
        [30/4,139],
        [0,squeezer_length]
        ];
    rotate_extrude($fn=30)
    polygon(points=points);
}

// color( rands(0,1,3), alpha=1 )
// fwd(gondola_length/2+front_arc_out_to_wall-squeezer_length/2)
// xrot(90)
// squeezer();

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

module servo_gears(position=0) {
    
    rack_height = 15;
    helical = 0;
    // rack_x = position > 0.5 ? rack_length/2+pitch : position < -0.5 ? -rack_length/2+pitch : pitch;
    rack_x = position+pitch;
    pr = pitch_radius(pitch=pitch, teeth=gear_n_teeth); // 12.7324
    down(pr) {
        right(rack_x)
        rack(pitch=pitch, teeth=rack_n_teeth, thickness=thickness, height=rack_height, helical=helical);

        // up(pr) yrot(180.0-$t*360/gear_n_teeth)
        up(pr) yrot(-180 * rack_x / pr / PI)
        spur_gear(pitch=pitch, teeth=gear_n_teeth, thickness=thickness, helical=helical, shaft_diam=5, orient=BACK);
    }

}

// arc_length = angle*r;
// angle = arc_length / r;

// servo_gears((0.25*$t-rack_n_teeth/2)*pitch);
// servo_gears(pen_back_position);

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
        servo_gears(-pen_position);
    }

    servo_width = 11.8;
    servo_length = 22.5;
    servo_holder_y = 15.9 + 2.5;

    servo_holder_length = length; //servo_length + 2 * 20;
    servo_pen_holder_width = width; //servo_width + 2 * 30;
    
    dovetail_spacing = 20;
    dovetail_width = 10;
    n_dovetails = 2;
    
    // Servo holder
    color( rands(0,1,3), alpha=1 )
    up(servo_holder_y)
    difference() {

        // Create servo holder board with dovetails
        servo_holder_dovetail(servo_holder_length, servo_pen_holder_width, thickness, dovetail_width, dovetail_spacing, n_dovetails);
        
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
        fwd(servo_pen_holder_width/2-thickness/2)
        servo_case_side(servo_holder_length, thickness, side_height, dovetail_width, dovetail_spacing, n_dovetails);
        back(servo_pen_holder_width/2-thickness/2)
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

magnet_blocker_length = 15;
module magnet_blocker() {
    diff("remove") {
        cuboid([body_width, magnet_blocker_length, thickness], anchor=BOTTOM);
        
        back(magnet_blocker_length/2-2*thickness)
        mirror_copy(LEFT, body_width/2-m3_radius)
        up(thickness/2)
        screw_hole();
    }
}
// magnet_blocker();

module main_body_plate() {
    union () {
        mirror_copy(LEFT, slider_offset_x) body_slider(slider_width, servo_case_width, servo_case_length, slider_offset_x);
        
        mirror_copy(FRONT, body_length/2-body_sliders_link/2) cuboid([gondola_width/2, body_sliders_link, thickness], anchor=BOTTOM);
    }
}

module body() {

    main_body_plate();

    zrot(90) servo_case();

    // Sliding magnet
    fwd(pen_position)
    union() {
        sliding_magnet(sliding_magnet_length, sliding_magnet_plate_width, n_magnets);
        up(thickness)
        sliding_magnet(sliding_magnet_length, sliding_magnet_top_width, n_magnets);
    }

    down(thickness)
    back(body_length/2-magnet_blocker_length/2)
    magnet_blocker();
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
    main_arc(marble_nut=13, targets=true);

    // H links
    mirror_copy(LEFT, gondola_outer_diameter/2-arc_width/2)
    up(thickness)
    hlink_ensemble();

    // V links
    mirror_copy(LEFT, gondola_width/2)
    up(gondola_height-arc_width/2)
    yrot(90)
    vlink_with_comb();

    left(gondola_outer_diameter/2-arc_width/2)
    flask2();
}

// three_d_structure();


squeezer_diameter = 45;

module three_d_inside() {

    // squeezer holder
    fwd(pen_position)
    squeezer_ensemble();

    // Point 88 holder
    // down(4)
    // pen_holder(width=30, sliding_magnet_width=20, height=20, end_pos=30, prism_width=18, prism_base=0, prism_height=10, leg_height=0);

    // Pen
    
    // //   Stabilo point 88
    stabilo_point_88_length = 166;
    stabilo_point_88_diameter = 8;
    color( rands(0,1,3), alpha=1 )
    fwd(gondola_length/2+front_arc_out_to_wall-stabilo_point_88_length/2)
    xrot(90)
    cyl(l=stabilo_point_88_length, r=stabilo_point_88_diameter/2, $fn=6);

    up(gondola_height-vlink_height-arc_width-8*thickness)
    body();
}

module flask1() {
    flask_base = 45;
    flask_height = 152;
    flask_cap_height = 23;
    flask_cap_diameter = 23;
    cuboid([flask_base, flask_base, flask_height-flask_cap_height], anchor=BOTTOM);
    up(flask_cap_height/2+flask_height-flask_cap_height)
    cyl(l=flask_cap_height, r=flask_cap_diameter/2);
}

module flask2() {
    flask_cap_height = 23;
    flask_cap_diameter = 23;
    up((flask_height-flask_cap_height)/2)
    cyl(l=flask_height-flask_cap_height, r=flask_diameter/2);
    up(flask_cap_height/2+flask_height-flask_cap_height)
    cyl(l=flask_cap_height, r=flask_cap_diameter/2);
}

// Flask laid
// back(flask_height/2)
// xrot(90)
// left(gondola_outer_diameter/2)
// flask2();

pen_wedge_length = pen_front_offset;
pen_wedge_height = 60;
pen_wedge_inclusion = 10;
pen_wedge_total_length = pen_wedge_length + pen_wedge_inclusion + thickness;
pen_wedge_width = sliding_magnet_width + 20;
pen_wedge_side_size = 20;


module pen_wedge_bottom() {
    color( rands(0,1,3), alpha=1 )
    back(pen_wedge_total_length/2-thickness)
    difference() {
        cuboid([pen_wedge_width, pen_wedge_total_length, thickness], anchor=BOTTOM);
        back(pen_wedge_total_length/2-pen_wedge_inclusion/2)
        cuboid([sliding_magnet_width, pen_wedge_inclusion, 2*thickness], anchor=BOTTOM);

        // front notches
        front_notch_length = (pen_wedge_width - sliding_magnet_width)/2;
        fwd(pen_wedge_total_length/2-thickness/2)
        mirror_copy(LEFT, pen_wedge_width/2-front_notch_length/2)
        cuboid([front_notch_length, thickness, 2*thickness], anchor=BOTTOM);

        // side notches
        fwd(pen_wedge_total_length/2-thickness-pen_wedge_side_size/2)
        mirror_copy(LEFT, pen_wedge_width/2-thickness/2)
        cuboid([thickness, notch, 2*thickness], anchor=BOTTOM);
    }
}
// pen_wedge_bottom();

module pen_wedge_blocker() {
    color( rands(0,1,3), alpha=1 )
    fwd(thickness/2)
    difference() {
        cuboid([pen_wedge_width, thickness, pen_wedge_height], anchor=BOTTOM, rounding=pen_wedge_width/2, edges=[TOP+LEFT,TOP+RIGHT]);
        
        // bottom notch
        cuboid([sliding_magnet_width, 2*thickness, thickness], anchor=BOTTOM);

        // side notches
        up(thickness + pen_wedge_side_size/2-notch/2)
        mirror_copy(LEFT, pen_wedge_width/2-thickness/2)
        cuboid([thickness, 2*thickness, notch], anchor=BOTTOM);
    }
}

module pen_wedge_side() {
    side_size = pen_wedge_side_size;
    // Sides
    union() {
        
        mirror_copy(LEFT, pen_wedge_width/2) {
            up(thickness)
            cuboid([thickness, side_size, side_size], anchor=BOTTOM+LEFT+FRONT, rounding=side_size/2, edges=[TOP+BACK]);

            // bottom male notch
            fwd(thickness)
            mirror_copy(BOTTOM+BACK, 0)
            back(side_size/2-notch/2+thickness)
            cuboid([thickness, notch, thickness], anchor=BOTTOM+LEFT+FRONT);
        }
    }
}

module pen_wedge() {
    fwd(pen_wedge_total_length-thickness-pen_wedge_inclusion) {
        pen_wedge_bottom();

        pen_wedge_blocker();

        pen_wedge_side();
    }
}
// pen_wedge();



module three_d() {

    three_d_structure();

    three_d_inside();

    mirror_copy(LEFT, 0)
    yrot(-45)
    right(gondola_outer_diameter/2-arc_width-wheel_diameter/2+wheel_rail_depth)
    zrot(90)
    double_caster_wing();

    fwd(gondola_length/2-2*thickness) up(gondola_outer_diameter/2-arc_width/2) xrot(90) marble();
}

// marble();


// Todo
// - targets to see home position

// - switch between pos
// - 3 marbles
// - switch between squeezer and point88
// - compute body heights with different pens!
// - add circle precision (for example double caster axe holes)
// - 2D view
// - shopping list
// - prepare tests : axe_diameter, notches, etc.

// - sliders with other magners (circular)?
// - screws for sliding magnet and rack? = cut many instances and glue

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