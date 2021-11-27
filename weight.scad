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
$fs=1;

// Print number of sides from $fa and $fs:

// r = 100;
// tube(h=thickness, od=200, id=m3_diameter/2);
// echo(n=($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5))),a_based=360/$fa,s_based=r*2*PI/$fs);
// r = m3_diameter/2;
// echo(n=($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5))),a_based=360/$fa,s_based=r*2*PI/$fs);

// => 95 sides

thickness = 4;

m3_diameter = 3;
m3_radius = 3/2;
m3_nut_height = 2.4;
m3_nut_S = 5.5;
m3_screw_head_diameter = 5.5;


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

weight_head_height = 5;
weight_neck_radius = 16/2;
weight_radius = 25/2;
weight_body_height = 40;
weight_height = weight_body_height + 2 * weight_head_height;

weight_holder_width = 25;
weight_holder_top_margin = 2 * thickness + 3;
weight_holder_bottom_margin = weight_head_height + 2 * thickness + 3;
weight_holder_height = 2 * pulley_outer_radius + weight_holder_top_margin + weight_holder_bottom_margin;
weight_holder_bottom_margin_v2 = weight_head_height + weight_holder_top_margin + thickness;
weight_holder_height_v2 = 2 * pulley_outer_radius + weight_holder_top_margin + weight_holder_bottom_margin_v2;

washer_radius = 5;

module washer() {
    difference() {
        cyl(r=washer_radius, l=thickness);
        cyl(r=m3_radius, l=2*thickness);
    }
}

module fake_pulley() {
    cyl(r=pulley_chain_radius, l=thickness);
    mirror_copy(TOP, thickness)
    cyl(r=pulley_outer_radius, l=thickness);
}

module weight() {
    down(weight_head_height) {
        cyl(r=weight_radius, l=weight_body_height);
        up(weight_body_height/2+weight_head_height/2)
        cyl(r=weight_neck_radius, l=weight_head_height);
        up(weight_body_height/2+weight_head_height/2+weight_head_height)
        cyl(r=weight_radius, l=weight_head_height);
    }
}

module weight_holder_side() {
    
    offset_y = - weight_holder_top_margin/2 + weight_holder_bottom_margin/2;
    difference() {
        fwd(offset_y)
        cuboid([weight_holder_width, weight_holder_height, thickness], anchor=BOTTOM);

        fwd(offset_y)
        left(weight_holder_width/4)
        mirror_copy(FRONT, weight_holder_height/2-thickness/2-thickness)
        cuboid([weight_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);

        cyl(r=m3_radius, l=2*thickness);
    }
}
// weight_holder_side();

module weight_holder_side_v2() {
    offset_y = - weight_holder_top_margin/2 + weight_holder_bottom_margin_v2/2;
    difference() {
        fwd(offset_y)
        cuboid([weight_holder_width, weight_holder_height_v2, thickness], anchor=BOTTOM);

        left(weight_holder_width/4)
        mirror_copy(FRONT, pulley_outer_radius + weight_holder_top_margin - 3 * thickness / 2)
        cuboid([weight_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);

        weight_holder_side_v2_notch_length = weight_holder_width-thickness;
        left(weight_holder_width/2-weight_holder_side_v2_notch_length/2)
        fwd(pulley_outer_radius + weight_holder_bottom_margin_v2 - weight_head_height - thickness / 2)
        cuboid([weight_holder_side_v2_notch_length, weight_head_height, 2*thickness], anchor=BOTTOM);

        cyl(r=m3_radius, l=2*thickness);
    }
}
// weight_holder_side_v2();

head_holder_margin = thickness;
head_holder_neck_margin = 2;
head_holder_length = 2 * weight_radius + 2 * (2 * thickness + head_holder_neck_margin);
head_holder_width = 2 * weight_radius + 2 * head_holder_margin;

module head_holder() {
    difference() {
        cuboid([head_holder_width, head_holder_length, thickness], anchor=BOTTOM);
        cyl(r=weight_neck_radius, l=2*thickness);
        left(head_holder_width/2-weight_neck_radius)
        cuboid([2*weight_neck_radius, 2*weight_neck_radius, 2*thickness], anchor=BOTTOM);

        mirror_copy(FRONT, weight_radius + head_holder_neck_margin + thickness/2)
        left(head_holder_width/4)
        cuboid([head_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);
    }
}
// up(weight_height/2-weight_head_height-thickness)
// head_holder();
// weight();
// weight_holder_side();

module weight_holder() {
    zrot(180)
    mirror_copy(FRONT, weight_radius + head_holder_neck_margin)
    xrot(90)
    weight_holder_side();
}

module weight_holder_v2() {
    zrot(180)
    mirror_copy(FRONT, 3*thickness/2+thickness)
    xrot(90)
    weight_holder_side_v2();
}

module top_link() {
    difference() {
        cuboid([weight_holder_width, head_holder_length, thickness], anchor=BOTTOM);
        
        left(weight_holder_width/4)
        mirror_copy(FRONT, head_holder_length/2-thickness/2-thickness)
        cuboid([weight_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);
    }
}

module link_v2() {
    difference() {
        cuboid([weight_holder_width, 9*thickness, thickness], anchor=BOTTOM);
        
        left(weight_holder_width/4)
        mirror_copy(FRONT, 3*thickness)
        cuboid([weight_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);
    }
}

module viz3d_v1() {
    down(weight_holder_height/2+weight_body_height/2-2*thickness- weight_holder_top_margin/2 + weight_holder_bottom_margin/2) {
        up(weight_height/2-weight_head_height-thickness)
        head_holder();
        weight();
    }


    xrot(90) {
        fake_pulley();
        
        mirror_copy(TOP, 3 * thickness - thickness/2) {
            zcopies(thickness+1, 2)
            washer();
        }
    }
    weight_holder();

    up(pulley_outer_radius + weight_holder_top_margin-2*thickness)
    top_link();
}

module viz3d_v2() {
    down(weight_holder_height_v2/2+weight_body_height/2) {
        weight();
    }


    xrot(90) {
        fake_pulley();
        
        mirror_copy(TOP, 2 * thickness) {
            washer();
        }
    }
    weight_holder_v2();

    mirror_copy(TOP, pulley_outer_radius + weight_holder_top_margin-2*thickness)
    link_v2();
}

// top_link();
viz3d_v2();