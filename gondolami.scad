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

$fa=2;
$fs=2;

// Print number of sides from $fa and $fs:

// r = 100;
// tube(h=thickness, od=200, id=m3_diameter/2);
// echo(n=($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5))),a_based=360/$fa,s_based=r*2*PI/$fs);
// r = m3_diameter/2;
// echo(n=($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5))),a_based=360/$fa,s_based=r*2*PI/$fs);

// => 95 sides

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

point88_length = 166;
point88_diameter = 8;
point88_h = hexagon_r_to_h(point88_diameter / 2);

pencil_h = 7.6 / 2;
pencil_diameter = 2 * hexagon_h_to_r(pencil_h);
pencil_length = 80;

// hlinks_y = hexagon_r_to_h(pencil_diameter/2); // = point88 height / 2
hlinks_y = 2*thickness;

arc_bottom_height = 10;

magnet_blocker_length = 15;

squeezer_holder_height = 55;
squeezer_holder_y = -25;

servo_case_width = 58;
servo_case_length = 40;

module h_notch(od=200, arc_width, screw=false) {
    h_notch_position = [od/2-arc_width/2, hlinks_y+thickness/2, 0];
    h_notch_size = [arc_notch, thickness, 2*thickness];
    translate(h_notch_position) 
    if(screw) {
        // cyl(r=m3_screw_head_diameter/2, l=2*thickness);
        cyl(r=m3_diameter/2, l=2*thickness);
    } else {
        cuboid(h_notch_size, anchor=BOTTOM);
    }
}

module v_notch(od=200, width, height, screw=false) {
    v_notch_position = [width/2, height-arc_width/2, 0];
    v_notch_size = [thickness, arc_notch, 2*thickness];
    translate(v_notch_position)
    if(screw) {
        // cyl(r=m3_screw_head_diameter/2, l=2*thickness);
        cyl(r=m3_diameter/2, l=2*thickness);
    } else {
        cuboid(v_notch_size, anchor=BOTTOM);
    }
}

module main_arc_l(od=200, id=180, arc_width=20, width=gondola_width, height=gondola_height, marble_nut=0, marble_y=arc_width/2, side_marbles_y=0, side_marbles_x=0, side_marbles_angle=0, screw=false, pencil_holes=false, screw_holes=true) {
    arc_middle_radius = (od + id) / 4;
    difference() {
        union() {
            back_half(y=0)
            tube(h=thickness, od=od, id=id);
            fwd(arc_bottom_height)
            mirror_copy(LEFT, arc_middle_radius + arc_width / 2)
            cube([arc_width, arc_bottom_height, thickness]);
        }

        // horizontal notches
        h_notch(od, arc_width, screw);
        xflip()
            h_notch(od, arc_width, screw);
        
        // vertical notches
        v_notch(od, width, height, screw);

        xflip()
            v_notch(od, width, height, screw);
        
        // marbles
        if(marble_nut > 0) {
            e = marble_nut * 2 / sqrt(3);
            // e = hexagon_h_to_r(marble_nut);
            back(marble_y)
            cyl(r=e/2, l=2*thickness, $fn=6);
            
            if(side_marbles_y != 0) {
                back(side_marbles_y) {
                    mirror_copy(LEFT, side_marbles_x)
                    zrot(side_marbles_angle)
                    cyl(r=e/2, l=2*thickness, $fn=6);
                }
            }
        }

        // pencil hole
        if(pencil_holes) {
            mirror_copy(LEFT, arc_middle_radius)
            cyl(r=pencil_diameter/2, l=2*thickness, $fn=6);
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

module main_arc(od=gondola_outer_diameter, arc_width=arc_width, width=gondola_width, height=gondola_height, marble_nut=0, side_marbles_y=0, side_marbles_x=0, side_marbles_angle=0, targets=false, pencil_holes=false) {
    // render(){
        // Main / thick arc
        union() {
            main_arc_l(od, od-2*arc_width, arc_width, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, side_marbles_angle=side_marbles_angle, pencil_holes=pencil_holes);
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
        main_arc_l(od-rail_depth,  od-2*arc_width+rail_depth, arc_width-rail_depth, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, side_marbles_angle=side_marbles_angle, screw=true, pencil_holes=pencil_holes);
    // }
}

// main_arc(marble_nut=13, targets=true);

module main_arc_2D(od=gondola_outer_diameter, arc_width=arc_width, width=gondola_width, height=gondola_height, marble_nut=0, side_marbles_y=0, side_marbles_x=0, side_marbles_angle=0, targets=false, pencil_holes=false) {
    // render(){
        // Main / thick arc
        union() {
            main_arc_l(od, od-2*arc_width, arc_width, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, side_marbles_angle=side_marbles_angle, pencil_holes=pencil_holes);
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
        fwd(70)
        main_arc_l(od-rail_depth,  od-2*arc_width+rail_depth, arc_width-rail_depth, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, side_marbles_angle=side_marbles_angle, screw=true, pencil_holes=pencil_holes);
    // }
}
// main_arc_2D();


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
            cuboid([hlink_width, hlink_weight_length + 2 * hlink_margin, thickness], anchor=BOTTOM, rounding=(hlink_width)/2, edges=[FRONT+LEFT, BACK+LEFT,BACK+RIGHT]);

            // front cube for pencil_holder
            front_cube_length = (link_length - hlink_weight_length) / 2;
            front_cube_width = (hlink_width - arc_width) / 2;
            fwd(link_length/2)
            right(arc_width/2)
            cube([front_cube_width, front_cube_length, thickness]);

            // front comb
            comb_length = front_cube_length+flask_diameter/2;
            comb_width = notch;
            up(thickness/2)
            fwd(link_length / 2 - comb_length / 2)
            right(arc_width / 2 + comb_width + front_cube_width / 2)
            xflip()
            comb(comb_length, comb_width / 2);
        }

        // Interior hole
        cuboid([flask_diameter, hlink_weight_length, 2*thickness], anchor=BOTTOM, rounding=flask_diameter/2, edges=[FRONT+LEFT,FRONT+RIGHT, BACK+LEFT,BACK+RIGHT]);

        // Screw sliders
        mirror_copy(LEFT, hlink_width/2-hlink_margin/2)
        cuboid([m3_diameter, hlink_weight_length-flask_diameter+m3_diameter, 2*thickness], anchor=BOTTOM, rounding=m3_diameter/2, edges=[FRONT+LEFT,FRONT+RIGHT, BACK+LEFT,BACK+RIGHT]);
    }
}
// hlink();

module hlink_cap() {
    difference() {
        tube(h=thickness, od=hlink_width, id=flask_diameter);
        
        // Screw holes
        mirror_copy(LEFT, hlink_width/2-hlink_margin/2)
        cyl(r=m3_radius, l=2*thickness);
    }
}

module hlink_ensemble() {
    hlink();
    up(thickness)
    hlink_cap();
}

module hlink_ensemble_2D() {
    hlink();
    fwd(link_length/2-flask_diameter/2-10)
    left(hlink_width)
    hlink_cap();
}


// hlink_ensemble_2D();

rail_thickness = 3.279;
wheel_rail_depth = 2;

module wheel() {
    cyl(l=wheel_thickness, r=wheel_diameter/2-wheel_rail_depth) {
        attach(BOTTOM, overlap=0) cyl(l=(wheel_thickness-rail_thickness)/2, r=wheel_diameter/2, anchor=TOP);
        attach(TOP, overlap=0) cyl(l=(wheel_thickness-rail_thickness)/2, r=wheel_diameter/2, anchor=TOP);
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

        // Screw hole
        fwd(interval_between_wheels /2)
        cyl(l=2*thickness, r=m3_diameter/2);

        fwd(interval_between_wheels)
        cyl(l=thickness, r=axe_diameter/2);

        // Screw hole
        fwd(interval_between_wheels + wheel_diameter/2 + double_caster_screw_y)
        cyl(l=2*thickness, r=m3_diameter/2);

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

module double_caster_2D() {
    xcopies(wheel_diameter+2, 2)
    double_caster_side(true);
}

// double_caster_2D();

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
        cyl(l=2*thickness, r=string_hole_diameter/2, orient=FRONT);
        cuboid([string_hole_thin, 2*thickness, string_hole_length], anchor=BOTTOM);
        up(string_hole_length)
        cyl(l=2*thickness, r=string_hole_thin/2, orient=FRONT);
        
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

module double_caster_wing_2D() {

    wing();

    back(60)
    mirror_copy(RIGHT, 15)
    xrot(90)
    double_caster_wing_attachment();
    
    back(40)
    mirror_copy(RIGHT, wheel_diameter+2)
    double_caster_2D();
}

// double_caster_wing_2D();

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


module vlink_with_comb_2D(length=link_length, arc_width=arc_width) {
    vlink();
    side_comb_height = thickness*21;
    side_comb_notch = notch/2;
    side_comb_width = 3*side_comb_notch;

    left(vlink_height+5)
    mirror_copy(FRONT, side_comb_pos-15)
    comb(side_comb_height, side_comb_notch, side_comb_width);
}

// vlink_with_comb_2D();

// Comb
module comb(length, notch, width = -1) {
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

// comb(squeezer_length, notch, 30);

blocker_margin = 5;
sliding_magnet_width = 20;

module pen_holder_bridge(width=pen_holder_width, height=holder_height, length=170, prism_width=50, prism_height=30, prism_base=0, comb_notch_z=3*thickness, center_notch=sliding_magnet_width, side_notches=-1, leg_height=10, elastic_notch_x=-1, elastic_notch_size=-1, clamp_comb_notch=-1) {
    elastic_notch_size = elastic_notch_size < 0 ? 3 : elastic_notch_size;
    elastic_notch_x = elastic_notch_x < 0 ? width / 2 - 12 : elastic_notch_x;
    up(height/2)
    xrot(90)
    diff("remove")
        cuboid([width, height, thickness], anchor=BOTTOM){
            // Center notch
            if(center_notch > 0) {
                position(FRONT) cuboid([center_notch, thickness, 2*thickness], anchor=FRONT, $tags="remove");
            }

            // Clamp comb notch
            if(clamp_comb_notch > 0) {
                back(thickness)
                position(FRONT) cuboid([thickness, clamp_comb_notch, 2*thickness], anchor=FRONT, $tags="remove");
            }

            // Elastic notches
            fwd(height/2-elastic_notch_size/2) {
                mirror_copy(LEFT, elastic_notch_x)
                cuboid([elastic_notch_size, elastic_notch_size, 2*thickness], $tags="remove");
            }

            // Side notches
            if(side_notches > 0) {
                fwd(height/2-thickness/2-comb_notch_z) {
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
// pen_holder_bridge(side_notches=8, clamp_comb_notch=4);
pen_holder_length = body_length - magnet_blocker_length - blocker_margin;

module pen_holder(width = pen_holder_width, height=50, bridge_pos=30, prism_width=46, prism_base=20, prism_height=16, leg_height=32, comb_notch_z = 3 * thickness, comb_notch_size = 8, elastic_notch_x=-1, clamp_comb_notch=-1) {
    
    length = pen_holder_length;

    // render() {
        // sliding magnets
        fwd(magnet_blocker_length/2+blocker_margin/2)
        up(height-thickness)
        sliding_magnet(length, sliding_magnet_width, n_magnets);
        
        // Holder bridge
        mirror_copy(FRONT, length/2-bridge_pos)
        up(height)
        zflip()
        ycopies(10, 2)
        pen_holder_bridge(width=width, height=height, side_notches=comb_notch_size, comb_notch_z=comb_notch_z, prism_width=prism_width, prism_base=prism_base, prism_height=prism_height, leg_height=leg_height, elastic_notch_x=elastic_notch_x, clamp_comb_notch=clamp_comb_notch);
        
        // Comb
        mirror_copy(LEFT, -width/2+comb_notch_size)
        up(height-comb_notch_z-thickness/2)
        comb(length, comb_notch_size);
    // }
}

module pen_holder_2D(width = pen_holder_width, height=50, bridge_pos=30, prism_width=46, prism_base=20, prism_height=16, leg_height=32, comb_notch_z = 3 * thickness, comb_notch_size = 8, elastic_notch_x=-1, clamp_comb_notch=-1) {
    
    length = pen_holder_length;

    // Holder bridge
    up(thickness)
    mirror_copy(FRONT, 2)
    xcopies(width+2, 2)
    xrot(90)
    pen_holder_bridge(width=width, height=height, side_notches=comb_notch_size, comb_notch_z=comb_notch_z, prism_width=prism_width, prism_base=prism_base, prism_height=prism_height, leg_height=leg_height, elastic_notch_x=elastic_notch_x, clamp_comb_notch=clamp_comb_notch);
    
    // Comb
    fwd(height + sliding_magnet_width / 2 + 2 * comb_notch_size + 6)
    zrot(90)
    {
        sliding_magnet(length, sliding_magnet_width, n_magnets);
        mirror_copy(LEFT, sliding_magnet_width / 2 + comb_notch_size + 2)
        up(thickness/2)
        comb(length, comb_notch_size);
    }
}

// pen_holder_2D(height=squeezer_holder_height, bridge_pos=18);

module squeezer_holder() {
    up(squeezer_holder_y)
    pen_holder(height=squeezer_holder_height, bridge_pos=18);

    up(squeezer_holder_height+squeezer_holder_y)
    fwd(body_length/2)
    yrot(180)
    pen_wedge();
}

// squeezer_holder();

module squeezer_holder_2D() {

    pen_holder_2D(height=squeezer_holder_height, bridge_pos=18);

}

// squeezer_holder_2D();

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

module squeezer_ensemble_2D() {
    squeezer_holder_2D();
}

// squeezer_ensemble_2D();

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

pencil_holder_margin = 2 * thickness;
pencil_holder_length = hlink_width + pencil_holder_margin;

module pencil_holder() { 
    down(arc_bottom_height)
    left(hlink_width/2)
    xrot(90) {
    difference() {
        cube([pencil_holder_length, arc_bottom_height + hlinks_y + thickness + pencil_holder_margin, thickness]);

        // top notch
        left(pencil_holder_margin)
        back(arc_bottom_height + hlinks_y)
        cube([pencil_holder_length, thickness, 2*thickness]);

        // pencil hole
        translate([(hlink_width)/2, arc_bottom_height, 0])
        cyl(l=pencil_length, r=pencil_diameter/2, $fn=6);
    }
    }

}

// pencil_holder();

module pencil_holder_2D() { 
    difference() {
        cube([pencil_holder_length, arc_bottom_height + hlinks_y + thickness + pencil_holder_margin, thickness]);

        // top notch
        left(pencil_holder_margin)
        back(arc_bottom_height + hlinks_y)
        cube([pencil_holder_length, thickness, 2*thickness]);

        // pencil hole
        translate([(hlink_width)/2, arc_bottom_height, 0])
        cyl(l=pencil_length, r=pencil_diameter/2, $fn=6);
    }
}

// pencil_holder_2D();

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

module servo_gears(position=0, two_d=false) {
    
    rack_height = 15;
    helical = 0;
    // rack_x = position > 0.5 ? rack_length/2+pitch : position < -0.5 ? -rack_length/2+pitch : pitch;
    rack_x = position+pitch;
    pr = pitch_radius(pitch=pitch, teeth=gear_n_teeth); // 12.7324
    down(pr) {
        right(rack_x)
        rack(pitch=pitch, teeth=rack_n_teeth, thickness=thickness, height=rack_height, helical=helical);

        // up(pr) yrot(180.0-$t*360/gear_n_teeth)
        up(two_d ? pr + 2 : pr) yrot(-180 * rack_x / pr / PI)
        spur_gear(pitch=pitch, teeth=gear_n_teeth, thickness=thickness, helical=helical, shaft_diam=5, orient=BACK);
    }

}

// arc_length = angle*r;
// angle = arc_length / r;

// servo_gears((0.25*$t-rack_n_teeth/2)*pitch);
// servo_gears(pen_back_position);

servo_y_offset = 11.125;

servo_width = 11.8;
servo_length = 22.5;
servo_holder_y = 15.9 + 2.5;

servo_holder_length = servo_case_length; //servo_length + 2 * 20;
servo_pen_holder_width = servo_case_width; //servo_width + 2 * 30;

servo_dovetail_spacing = 20;
servo_dovetail_width = 10;
servo_n_dovetails = 2;

servo_side_height = 10;

module servo_holder() {

    difference() {

        // Create servo holder board with dovetails
        servo_holder_dovetail(servo_holder_length, servo_pen_holder_width, thickness, servo_dovetail_width, servo_dovetail_spacing, servo_n_dovetails);
        
        // Remove servo print
        fwd(servo_y_offset) {
            cuboid([servo_length+1, servo_width+1, 2*thickness], anchor=BOTTOM);

            left(servo_length/2+4.7-2.3)
            cyl(l=2*thickness, r=1);

            right(servo_length/2+4.7-2.3)
            cyl(l=2*thickness, r=1);
        }
    };
}

module servo_case_raw() {
    
    fwd(servo_y_offset) {
        servo9g();

        // Gear

        left(22.5/2-11.8/2)
        up(26.7)
        xrot(90)
        servo_gears(-pen_position);
    }
    
    // Servo holder
    color( rands(0,1,3), alpha=1 )
    up(servo_holder_y)
    servo_holder();

    // Case sides
    up(servo_holder_y+thickness) {
        fwd(servo_pen_holder_width/2-thickness/2)
        servo_case_side(servo_holder_length, thickness, servo_side_height, servo_dovetail_width, servo_dovetail_spacing, servo_n_dovetails);
        back(servo_pen_holder_width/2-thickness/2)
        servo_case_side(servo_holder_length, thickness, servo_side_height, servo_dovetail_width, servo_dovetail_spacing, servo_n_dovetails);
    }

    
}

// servo_case_raw();

module servo_case_raw_2D() {
    
    xrot(90)
    servo_gears(-pen_position-pitch, two_d=true);
    
    right(12)
    back(50)
    zrot(90)
    servo_holder();
    
    right(32)
    fwd(2)
    ycopies(18, 2)
    xrot(90)
    servo_case_side(servo_holder_length, thickness, servo_side_height, servo_dovetail_width, servo_dovetail_spacing, servo_n_dovetails);
}

// servo_case_raw_2D();

module servo_case() {
    up(34)
    xrot(180) {
        servo_case_raw();
    }
}

module servo_case_2D() {
    servo_case_raw_2D();
}

module screw_hole(od=8) {
    cyl(r=od/2, l=thickness);
    cyl(r=m3_radius, l=2*thickness, $tags="remove");
}

// TODO: 
// improve cap: it should not be able to move from side to side along the axis, ears should be longer and a notch should enable to clip the cap to the sides
// fix main body plate: collision between dovetail and screw_hole!!

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

cap_rotating_side_width = 6;
cap_rotating_side_height = 20;
cap_holding_side_height = 16;
cap_holding_side_width = 10;
cap_holding_side_offset_y = 4;
cap_holding_side_notch = cap_holding_side_width/2;
cap_rotating_side_offset_y = 4;
cap_height = 10;
cap_radius = 5;
cap_holder_offset_y = 6;
cap_margin = 2;
cap_n_slice = 8;
piano_string_diameter = 1;

module main_body_plate() {
    difference() {
        union () {
            // Sides
            mirror_copy(LEFT, slider_offset_x) 
            body_slider(slider_width, servo_case_width, servo_case_length, slider_offset_x);
            
            // Front & back links
            mirror_copy(FRONT, body_length/2-body_sliders_link/2) 
            cuboid([gondola_width/2, body_sliders_link, thickness], anchor=BOTTOM);
        }
        // Cap holder notches
        // placed at the center of the body sliders
        mirror_copy(LEFT, slider_offset_x)
        fwd(body_length/2-cap_holding_side_notch/2)
        cuboid([thickness, cap_holding_side_notch, 2*thickness], anchor=BOTTOM);
    }
}

// main_body_plate();

module cap_slice(hole=true, ears=false) {
    difference() {
        final_cap_ear_width = 2*(cap_radius+cap_margin)+(ears?2*(cap_ear_width-cap_radius-cap_margin):0);
        cuboid([final_cap_ear_width, (cap_radius+cap_margin)*2, thickness], anchor=BOTTOM);
        if(hole) {
            cyl(l=cap_height, r=cap_radius);
        }
        mirror_copy(LEFT, 0)
        mirror_copy(FRONT, 0)
        translate([cap_radius, cap_radius, 0])
        cyl(l=cap_height, r=piano_string_diameter);
        
        if(ears) {
            mirror_copy(LEFT, cap_radius+cap_margin+magnet_size/2)
            cuboid([magnet_size, magnet_size, 2*thickness], anchor=BOTTOM);
        }
    }
}

module cap_holder_holding_sides() {
    diff("remove") {
        cuboid([cap_holding_side_height, cap_holding_side_width, thickness], anchor=BOTTOM);
        
        translate([cap_holding_side_height/2 - 3*thickness/2, cap_holding_side_width/2 - cap_holding_side_notch/2, 0]) 
        cuboid([thickness, cap_holding_side_notch, 2*thickness], anchor=BOTTOM, $tags="remove");

        left(cap_holding_side_height/2-cap_holding_side_offset_y) fwd(cap_holding_side_width/2) up(thickness/2) screw_hole();
    }
}

module cap_holder_rotating_sides() {
    diff("remove") {
        cuboid([cap_rotating_side_width, cap_rotating_side_height, thickness], anchor=BOTTOM);
        fwd(cap_rotating_side_height/2) up(thickness/2) screw_hole();
    }
}

cap_ear_width = slider_offset_x-thickness/2;

module cap_holder() {

    // holding sides
    fwd(body_length/2-cap_holding_side_width/2)
    up(cap_holding_side_height/2-thickness)
    mirror_copy(LEFT, slider_offset_x+thickness/2) // cap_radius+cap_margin+thickness+20)
    yrot(90)
    cap_holder_holding_sides();

    // rotating sides
    up(cap_rotating_side_height/2-thickness-2*(cap_rotating_side_height-cap_holding_side_height))
    fwd(body_length/2)
    mirror_copy(LEFT, cap_ear_width-thickness)
    zrot(90)
    xrot(-90)
    cap_holder_rotating_sides();
    
    // // Cap
    fwd(body_length/2)
    down(4) {
        // xrot(90) {
        //     cyl(l=cap_height, r=cap_radius);
        // }

        // mirror_copy(FRONT, 0)
        ycopies(thickness, cap_n_slice)
        xrot(90)
        cap_slice(true, $idx==3);
        
        fwd(thickness * (cap_n_slice + 1)/2)
        xrot(90)
        cap_slice(false);
    }
}

// cap_holder();

module cap_holder_2d() {

    right(cap_holding_side_width/2 + 4)
    ycopies(cap_holding_side_width + 4 + 1, 2)
    cap_holder_holding_sides();

    left(cap_rotating_side_width + 4)
    xcopies(cap_rotating_side_width + 4, 2)
    cap_holder_rotating_sides();
    
    fwd( (cap_radius + cap_margin) * cap_n_slice)
    left(5*cap_rotating_side_width)
    ycopies(2 * (cap_radius + cap_margin) + 1, cap_n_slice)
    cap_slice(true, $idx==3 || $idx==4);

    fwd(cap_rotating_side_height + (cap_radius + cap_margin))
    left(2*cap_rotating_side_width)
    cap_slice(false);
}

// cap_holder_2d();

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

module body_2D() {

    main_body_plate();

    fwd(14)
    right(56)
    servo_case_2D();

    // Sliding magnet
    fwd(50)
    right(68)
    zrot(90)
    sliding_magnet(sliding_magnet_length, sliding_magnet_plate_width, n_magnets);
    
    fwd(84)
    zrot(90)
    sliding_magnet(sliding_magnet_length, sliding_magnet_top_width, n_magnets);

    // down(thickness)
    // back(body_length/2-magnet_blocker_length/2)
    // magnet_blocker();
}

// body_2D();

module marble() {
    ball_holder_height = 17-2.5;
    ball_holder_y = 15;
    ball_holder_radius = 22/2;
    ball_radius = 12/2;
    
    // ball holder
    up(ball_holder_y+ball_holder_height/2)
    cyl(l=ball_holder_height, r=ball_holder_radius);

    // ball
    up(ball_holder_y+17-ball_radius)
    sphere(r=ball_radius);
    
    // M8 screw
    up(ball_holder_y/2)
    cyl(l=ball_holder_y, r=8/2);
    
    // M8 nut
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

side_marbles_y = 20;
side_marbles_x = gondola_outer_diameter / 2 - arc_width / 2 - 2.25;
side_marbles_angle = 17;

module structure_3D(arcs=true, hlinks=true, vlinks=true, flasks=true, top_marble=true, side_marbles=true, pencil_holders=true, pencils=true) {


    if(arcs) {

        fwd(-gondola_length/2+2*thickness)
        zrot(180)
        xrot(90)
        main_arc();

        fwd(gondola_length/2-2*thickness)
        xrot(90)
        if(side_marbles) {
            main_arc(marble_nut=13, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, side_marbles_angle=side_marbles_angle, pencil_holes=true);
        } else {
            main_arc(marble_nut=13, pencil_holes=true);
        }
    }

    
    fwd(gondola_length/2-2*thickness) {
        if(top_marble) {
            up(gondola_outer_diameter/2-arc_width/2) xrot(90) marble();
        }
        
        if(side_marbles) {
            up(side_marbles_y)
            mirror_copy(LEFT, side_marbles_x)
            xrot(90) marble();
        }
    }

    // H links
    if(hlinks) {
        mirror_copy(LEFT, gondola_outer_diameter/2-arc_width/2)
        up(hlinks_y)
        hlink_ensemble();
    }

    if(pencil_holders) {
        fwd(33.5)
        mirror_copy(LEFT, gondola_outer_diameter/2-arc_width/2)
        pencil_holder();
    }

    // V links
    if(vlinks) {
        mirror_copy(LEFT, gondola_width/2)
        up(gondola_height-arc_width/2)
        yrot(90)
        vlink_with_comb();
    }

    if(flasks) {
        mirror_copy(LEFT, gondola_outer_diameter/2-arc_width/2)
        flask2();
    }

    if(pencils) {
        mirror_copy(LEFT, gondola_outer_diameter / 2 - arc_width / 2)
        fwd(gondola_length/2+front_arc_out_to_wall-pencil_length/2)
        pencil();
    }
}

module structure_2D(arcs=true, hlinks=true, vlinks=true, top_marble=true, side_marbles=true, pencil_holders=true) {

    if(arcs) {

        main_arc_2D();

        left(gondola_outer_diameter + arc_width + 5)
        if(side_marbles) {
            main_arc_2D(marble_nut=13, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, side_marbles_angle=side_marbles_angle, pencil_holes=true);
        } else {
            main_arc_2D(marble_nut=13, pencil_holes=true);
        }
    }

    // H links
    fwd(60)
    zrot(90)
    if(hlinks) {   
        hlink_ensemble_2D();
        left(2*hlink_width)
        yflip()
        xflip()
        hlink_ensemble_2D();
    }

    if(pencil_holders) {
        fwd(22)
        left(145)
        xcopies(230, 2)
        pencil_holder_2D();
    }

    // V links
    if(vlinks) {
        fwd(80)
        left(gondola_outer_diameter+25)
        zrot(90)
        xcopies(55, 2)
        vlink_with_comb_2D();
    }
}

// structure_2D();

squeezer_diameter = 45;

module clamp_comb(length, notch, clamp_comb_space_height=1, clamp_comb_space_length=51, center_notch=false, side_notches=true) {
    difference() {
        comb(length, notch);

        // Side notches
        if(side_notches) {
            right(notch-clamp_comb_space_height/2)
            mirror_copy(FRONT, length / 2 - clamp_comb_space_length / 2)
            cuboid([clamp_comb_space_height, clamp_comb_space_length, 2 * thickness]);
        }

        if(center_notch) {
            right(notch-clamp_comb_space_height/2)
            cuboid([clamp_comb_space_height, clamp_comb_space_length, 2 * thickness]);
        }
    }
}

// clamp_comb(100, 10);

module point88_ensemble() {

    ground_to_pen_bottom = 5;
    clamp_comb_notch = 2;
    point88_holder_height = 25;
    ground_to_pen_center = point88_h+ground_to_pen_bottom;

    // Point 88 holder
    down(ground_to_pen_center)
    pen_holder(width=40, height=point88_holder_height, prism_width=point88_diameter, prism_base=point88_diameter / 2, prism_height=point88_h, leg_height=point88_h+ground_to_pen_bottom, comb_notch_z=12, comb_notch_size=5, elastic_notch_x=15, clamp_comb_notch=clamp_comb_notch);

    // Clamp comb
    // up(point88_holder_height-ground_to_pen_bottom-clamp_comb_notch-thickness)
    up(point88_holder_height-ground_to_pen_center-2*clamp_comb_notch-thickness)
    yrot(-90)
    clamp_comb(pen_holder_length, 2*clamp_comb_notch, clamp_comb_space_length=25, center_notch=true, side_notches=true);

    // Point 88
    color( rands(0,1,3), alpha=1 )
    // fwd(gondola_length/2+front_arc_out_to_wall-squeezer_length)
    fwd(body_length/2-point88_length/2+pen_front_offset)
    point88();
}

// point88_ensemble();

module point88_ensemble_2D() {

    ground_to_pen_bottom = 5;
    clamp_comb_notch = 2;
    point88_holder_height = 25;
    ground_to_pen_center = point88_h+ground_to_pen_bottom;

    // Point 88 holder
    down(ground_to_pen_center)
    pen_holder_2D(width=40, height=point88_holder_height, prism_width=point88_diameter, prism_base=point88_diameter / 2, prism_height=point88_h, leg_height=point88_h+ground_to_pen_bottom, comb_notch_z=12, comb_notch_size=5, elastic_notch_x=15, clamp_comb_notch=clamp_comb_notch);

    // Clamp comb
    // up(point88_holder_height-ground_to_pen_bottom-clamp_comb_notch-thickness)
    fwd(80)
    zrot(90)
    clamp_comb(pen_holder_length, 2*clamp_comb_notch, clamp_comb_space_length=25, center_notch=true, side_notches=true);

}

// point88_ensemble_2D();

module inside_3D(type="point88") {

    // squeezer holder
    fwd(pen_position) 
    if(type == "point88") {
        point88_ensemble();
    } else if(type == "squeezer") {
        squeezer_ensemble();
    } else {
        point88_ensemble();
    }

    // Pen
    squeezer_body_height = gondola_height-vlink_height-arc_width-8*thickness;
    point88_body_height = gondola_height-vlink_height-arc_width-13*thickness;
    up(type == "squeezer" ? squeezer_body_height : type == "point88" ? point88_body_height : point88_body_height)
    body();
}

// inside_3D();

module inside_2D(type="point88") {

    // squeezer holder
    fwd(pen_position) 
    if(type == "point88") {
        point88_ensemble_2D();
    } else if(type == "squeezer") {
        fwd(30)
        squeezer_ensemble_2D();
    } else {
        point88_ensemble_2D();
    }

    zrot(type == "squeezer" ? 180 : 0)
    back(type == "squeezer" ? 17 : 10)
    right(type == "squeezer" ? -90 : 86)
    pen_wedge_2D();

    back(80)
    zrot(90)
    body_2D();
}

// inside_2D(type="point88");

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

module pen_wedge_side(two_d=false) {
    side_size = pen_wedge_side_size;
    // Sides
    union() {
        
        mirror_copy(LEFT,  two_d ? -1 : pen_wedge_width / 2) {
            yrot(two_d ? 90 : 0) {
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
}

module pen_wedge() {
    fwd(pen_wedge_total_length-thickness-pen_wedge_inclusion) {
        pen_wedge_bottom();

        pen_wedge_blocker();

        pen_wedge_side();
    }
}
// pen_wedge();

module pen_wedge_2D() {
    pen_wedge_bottom();
    fwd(5)
    xrot(90)
    pen_wedge_blocker();
    back(5)
    left(24)
    zrot(90)
    pen_wedge_side(two_d=true);
}

// pen_wedge_2D();

module marble_spacer_rings() {
    ycopies(15, 2)
    xcopies(15, 3)
    tube(h=thickness, od=13, id=8/2);
}

// marble_spacer_rings();

module nema17_axe() {
    nema17_axe_diameter = 5;
    back_half(y=-4/2)
    cyl(r=nema17_axe_diameter/2, l=10);
}

// bead chain specs:
bead_spacing = 12;
chain_thickness = 2;
real_bead_diameter = 4.7625;
bead_diameter = 5;

pulley_n_intervals = 8;

pulley_perimeter = 8 * 12;
// = 2*PI*radius

pulley_radius = pulley_perimeter / (2 * PI);

// inner_radius = radius - bead_diameter / 2;
pulley_chain_radius = pulley_radius - chain_thickness / 2;
pulley_outer_radius = pulley_radius + bead_diameter / 2;

module bead() {
    cyl(r=bead_diameter/2, l=2*thickness);
    fwd(bead_diameter/2)
    cuboid([bead_diameter, bead_diameter, 2*thickness]);
}

// bead();
module pulley_middle() {
    difference() {
        cyl(r=pulley_chain_radius, l=thickness);

        zrot_copies(n=pulley_n_intervals)
        fwd(pulley_radius)
        bead();

        nema17_axe();
    }
}

module pulley_side() {
    difference() {
        cyl(r=pulley_outer_radius, l=thickness);

        zrot_copies(n=pulley_n_intervals)
        fwd(pulley_radius)
        bead();

        nema17_axe();
    }
}

module pulley() {
    pulley_middle();

    mirror_copy(TOP, thickness)
    pulley_side();
}

// pulley();

module pulley_2D() {
    pulley_middle();

    fwd(2*pulley_radius-8)
    mirror_copy(LEFT, 2*pulley_radius)
    pulley_side();
}

// ycopies(2.5*pulley_radius, 2)
// pulley_2D();

module tests() {
    length = 140;
    width = 20;
    
    // Test bench
    difference() {
        cuboid([width, length, thickness]);

        // pencil hole
        back(20)
        cyl(l=2*thickness, r=pencil_diameter/2, $fn=6);

        // point88 hole
        back(30)
        cyl(l=2*thickness, r=point88_diameter/2, $fn=6);

        // Screw hole
        cyl(l=2*thickness, r=m3_diameter/2);
        
        // Screw head
        fwd(8)
        cyl(l=2*thickness, r=m3_screw_head_diameter/2);

        // M3 nut
        fwd(16)
        cyl(l=2*thickness, r=m3_nut_S/2, $fn=6);

        // M8 nut
        marble_nut = 13;
        e = marble_nut * 2 / sqrt(3);
        fwd(28)
        cyl(r=e/2, l=2*thickness, $fn=6);
        
        // Magnet hole
        fwd(40)
        cuboid([magnet_size, magnet_size, 2*thickness]);

        // Notch
        left(5)
        back(10)
        cuboid([notch, thickness, 2*thickness]);
        
        // Notch to put notches perfectly
        back(length/2-10)
        zrot(90) {
            cuboid([2*notch, m3_nut_S, 2*thickness]);   
            left(notch)
            cuboid([2*notch, thickness, 2*thickness]);
        }

        // Screw notch
        fwd(length/2)
        xrot(90)
        screw_notch(15, n_nuts=2);
    }

    // Tiny notch
    fwd(length/2+8)
    difference() {
        cuboid([width, 10, thickness]);
        left(5)
        cuboid([notch, thickness, 2*thickness]);
    }

    // Gears
    fwd(length/2+28)
    zrot(90)
    xrot(90)
    servo_gears(-pen_position-pitch, two_d=true);

}

// tests();

module visualization() {
    $fa=10;
    $fs=1;

    structure_3D();

    inside_3D();

    mirror_copy(LEFT, 0) yrot(-45) right(gondola_outer_diameter/2-arc_width-wheel_diameter/2+wheel_rail_depth) zrot(90) double_caster_wing();
}

// visualization();

part = "double-caster";

module export_part() {
    if(part == "double-caster") {
        mirror_copy(LEFT, 0) yrot(-45) right(gondola_outer_diameter/2-arc_width-wheel_diameter/2+wheel_rail_depth) zrot(90) double_caster_wing();
    } else if(part == "inside") {
        inside_3D();
    } else if(part == "structure") {
        structure_3D();
    }
}

// export_part();

// Todo

// - normal hlinks!
// - sliders with other magnets (circular)?
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
// structure_3D(vlinks=false, side_marbles=true, top_marble=false);
// body();
// inside_3D();
// visualization();

module flat() {
    structure_2D();
    fwd(90)
    right(170)
    inside_2D();

    right(486)
    zrot(90) {
        double_caster_wing_2D();
        left(gondola_length / 2 + wing_ear_width)
        back(wing_height + wing_ear_height - 10)
        yflip()
        double_caster_wing_2D();
    }

    fwd(300)
    tests();

    left(100)
    fwd(300)
    marble_spacer_rings();
    
    right(100)
    fwd(300)
    ycopies(2.5*pulley_radius, 2)
    pulley_2D();

    fwd(-100)
    left(-340)
    cap_holder_2d();
}

flat();

kerf_width = 0.2;

module compute_2D() {
    render() {
        offset(delta=kerf_width/2) {
            projection() {
                flat();
            }
        }
    }
}

// compute_2D();

// WING MI : Wing with motor included

pulley_thickness = 3 * thickness;
pulley_hole_margin = 2;
pulley_hole_width = pulley_thickness + 2 * pulley_hole_margin;
pulley_hole_length = 2 * pulley_outer_radius + 2 * pulley_hole_margin;

big_wheel_offset_x = 3 * thickness;
big_wheel_radius = 80;
small_wheel_radius = 10;
big_wheel_hole_width = thickness + 2 * pulley_hole_margin;
big_wheel_hole_length = pulley_outer_radius + pulley_hole_margin + big_wheel_radius + pulley_hole_margin + 2 * small_wheel_radius + pulley_hole_margin;

wing_plate_margin = 10;
wing_plate_width = pulley_hole_width + big_wheel_offset_x + big_wheel_hole_width + 2 * wing_plate_margin;
wing_plate_length = big_wheel_hole_length + wing_plate_margin;

module fake_pulley() {
    cyl(r=pulley_chain_radius, l=thickness);
    mirror_copy(TOP, thickness)
    cyl(r=pulley_outer_radius, l=thickness);
}

pulley_holder_width = 20;
// pulley_holder_x_spacing = pulley_hole_width + big_wheel_hole_width + 2 * thickness + thickness;
pulley_holder_margin = 3;
pulley_holder_height = pulley_outer_radius + 2 * thickness + pulley_holder_margin;

module pulley_holder() {
    difference() {
        cuboid([pulley_holder_height, pulley_holder_width, thickness]);
        left(pulley_holder_height/2-thickness-thickness/2)
        fwd(pulley_holder_width/4)
        cuboid([thickness, pulley_holder_width/2, 2*thickness]);
    }
}

motor_holder_width = 30; // TODO check nema width
motor_holder_height = pulley_holder_height;

module motor_holder() {
    difference() {
        cuboid([motor_holder_height, motor_holder_width, thickness]);
        left(motor_holder_height/2-thickness-thickness/2)
        back(motor_holder_width/4)
        cuboid([thickness, motor_holder_width/2, 2*thickness]);
    }
}

module motor_holder_rot() {
    yrot(90)
    motor_holder();
}

module pulley_holder_rot() {
    yrot(90)
    pulley_holder();
}

// pulley_holder_rot();

wing_pulley_y = wing_height-pulley_hole_length/2;
wing_pulley_z = pulley_holder_height/2-thickness-thickness/2;

pulley_holder_left_x = pulley_hole_width+thickness+thickness/2;
pulley_holder_middle_x = -big_wheel_offset_x/2;
pulley_holder_right_x = -big_wheel_offset_x-big_wheel_hole_width-thickness-thickness/2;

big_wheel_x = -big_wheel_offset_x-big_wheel_hole_width/2;
pulley_y = -big_wheel_offset_x-big_wheel_hole_width/2;
small_wheel_y = wing_pulley_y - big_wheel_radius - small_wheel_radius;


sensor_radius = 14/2;
sensor_length = 50;

module sensor() {
    xrot(90)
    cyl(r=sensor_radius, l=sensor_length);
}

sensor_holder_margin = 3;
sensor_holder_width = 2 * sensor_radius + 2 * sensor_holder_margin;
sensor_holder_height = pulley_radius + 2 * thickness + sensor_radius + sensor_holder_margin;
sensor_y = wing_height-pulley_hole_length-sensor_length/2;
sensor_holder_x = 10;
sensor_holder_y = wing_height-pulley_hole_length - sensor_holder_x;

module sensor_holder() {
    difference() {
        cuboid([sensor_holder_width, sensor_holder_height, thickness]);
        
        fwd(sensor_holder_height/2-sensor_holder_margin-sensor_radius-thickness/2)
        cyl(r=sensor_radius, l=2*thickness);

        // invert
        // fwd(sensor_holder_height/2-thickness-thickness/2)
        // xcopies(pulley_hole_width - thickness, 2)
        // #cuboid([thickness, thickness, 2*thickness]);

        // Sensor holder inside hole
        back(sensor_holder_height/2-thickness-thickness/2)
        cuboid([pulley_hole_width-2*thickness, thickness, 2*thickness]);

        // Sensor holder outside holes
        sensor_holder_hole_width = (sensor_holder_width - pulley_hole_width) / 2;
        sensor_holder_hole_spacing = pulley_hole_width + sensor_holder_hole_width;
        back(sensor_holder_height/2-thickness-thickness/2)
        xcopies(sensor_holder_hole_spacing, 2)
        cuboid([sensor_holder_hole_width, thickness, 2*thickness]);
    }
}
// sensor_holder();
module sensor_holder_rot() {
    xrot(90)
    sensor_holder();
}

pulley_holder_notch_length = pulley_outer_radius;

module pulley_holder_notch() {
    cuboid([thickness, pulley_holder_notch_length, 2*thickness]);
}

module wing_mi() {
    difference() {
        
        union() {
            mirror_copy(LEFT, wing_length/2)
            half_wing();

            left(wing_plate_width/2-big_wheel_offset_x-big_wheel_hole_width-wing_plate_margin)
            back(wing_height-wing_plate_length/2)
            cuboid([wing_plate_width, wing_plate_length, thickness]);
        }

        // pulley hole
        left(pulley_hole_width/2)
        back(wing_pulley_y)
        cuboid([pulley_hole_width, pulley_hole_length, 2*thickness]);

        // Sensor holes
        left(pulley_hole_width/2)
        back(wing_height-pulley_hole_length - sensor_holder_x/2-thickness/4)
        xcopies(pulley_hole_width - thickness, 2)
        cuboid([thickness, sensor_holder_x+thickness/2, 2*thickness]);

        // big wheel hole
        left(big_wheel_x)
        back(wing_height-big_wheel_hole_length/2)
        cuboid([big_wheel_hole_width, big_wheel_hole_length, 2*thickness]);

        // Pulley holder notches
        back(wing_height-pulley_holder_notch_length/2) {
            left(pulley_holder_left_x)
            pulley_holder_notch();
            left(pulley_holder_middle_x)
            pulley_holder_notch();
            left(pulley_holder_right_x)
            pulley_holder_notch();
        }

        motor_holder_notch_length = wing_plate_length - pulley_outer_radius - big_wheel_radius - small_wheel_radius;
        // Motor holder notch
        back(small_wheel_y-motor_holder_notch_length/2) {
            left(pulley_holder_right_x)
            cuboid([thickness, motor_holder_notch_length, 2*thickness]);
        }
    }
}

module wing_mi_viz() {

    // Pulley holders
    back(wing_pulley_y)
    down(wing_pulley_z) {
        // left(-pulley_hole_width-thickness-thickness/2)
        left(pulley_holder_left_x)
        pulley_holder_rot();
        left(pulley_holder_middle_x)
        pulley_holder_rot();
        left(pulley_holder_right_x)
        pulley_holder_rot();
    }

    // Motor holder
    left(pulley_holder_right_x)
    back(small_wheel_y)
    down(wing_pulley_z) {
        #motor_holder_rot();
    }

    // Sensor holder
    down(sensor_holder_height/2-thickness-thickness/2)
    left(pulley_hole_width/2)
    back(sensor_holder_y)
    sensor_holder_rot();

    // Sensor
    down(pulley_radius)
    left(pulley_hole_width/2)
    back(sensor_y)
    #sensor();

    // Wing
    wing_mi();

    // Wheels & pulley
    down(pulley_radius) {
        // Pulley
        left(pulley_hole_width/2)
        back(wing_pulley_y)
        yrot(90)
        fake_pulley();

        // Big wheel
        left(big_wheel_x)
        back(wing_pulley_y)
        yrot(90)
        cyl(r=big_wheel_radius, l=thickness);

        // Small wheel
        left(big_wheel_x)
        back(small_wheel_y)
        yrot(90)
        cyl(r=small_wheel_radius, l=thickness);
    }

}

// TODO:
// - model axes
// - offset the y position of pulley (and every attached pieces) to control where the string arrives in the wing
// - double motor holder thickness to make it stronger (and other parts)
// - model wheels / gears
// - model nema 17 with holes
// - fix dimensions

// wing_mi_viz();
// pulley_holder_rot();

// visualization();