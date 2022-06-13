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


gondola_length = 120;

thickness = 3;

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

weight_head_height = 6;
weight_neck_radius = 20/2;
weight_radius = 28/2;
weight_body_height = 35;
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
    mirror_copy(FRONT, weight_neck_radius) // 3*thickness/2+thickness)
    xrot(90)
    weight_holder_side_v2();
}

module top_link(length=head_holder_length, hole=false) {
    
    difference() {
        cuboid([weight_holder_width, length, thickness], anchor=BOTTOM);
        
        left(weight_holder_width/4)
        mirror_copy(FRONT, length/2-thickness/2-thickness)
        cuboid([weight_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);

        if(hole) {
            cyl(r=m3_radius, l=2*thickness);
        }
    }
}

module link_v2() {
    difference() {
        cuboid([weight_holder_width, 2 * weight_radius + 2*thickness, thickness], anchor=BOTTOM);
        
        left(weight_holder_width/4)
        mirror_copy(FRONT, weight_radius-thickness/2)
        cuboid([weight_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);
    }
}

// module end_stop_waffle() {
//     tube(ir=,or=washer_radius, l=thickness);
// }

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



// =================== BEGIN CAP =================== //

pulley_thickness = 3 * thickness;
cap_margin = 1;
weight_holder_width_cap = pulley_thickness + 2 * cap_margin;
weight_holder_z_margin_cap = 4 * thickness;
weight_holder_height_cap = 2 * pulley_outer_radius + 2 * weight_holder_z_margin_cap;

module weight_holder_side_cap() {
    offset_y = 0;
    difference() {
        fwd(offset_y)
        cuboid([weight_holder_width, weight_holder_height_cap, thickness], anchor=BOTTOM);

        fwd(offset_y)
        left(weight_holder_width/4)
        mirror_copy(FRONT, weight_holder_height_cap/2-thickness/2-thickness)
        cuboid([weight_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);

        cyl(r=m3_radius, l=2*thickness);
    }
}

module weight_holder_cap() {
    zrot(180)
    mirror_copy(FRONT, weight_holder_width_cap/2)
    xrot(90)
    weight_holder_side_cap();
}

module top_link_cap(length=head_holder_length, hole=false) {
    down(thickness/2)
    difference() {
        cuboid([weight_holder_width, length, thickness], anchor=BOTTOM);
        
        left(weight_holder_width/4)
        mirror_copy(FRONT, length/2-thickness/2-thickness)
        cuboid([weight_holder_width/2, thickness, 2*thickness], anchor=BOTTOM);

        if(hole) {
            cyl(r=m3_radius, l=2*thickness);
        }
    }
}

module top_cap(hole=false) {
    difference() {
        cuboid([weight_holder_width, weight_holder_width_cap, thickness]);
        if(hole) {
            cyl(r=m3_radius, l=2*thickness);
        }
    }
}

module viz3d_cap() {
  
    xrot(90) {
        fake_pulley();
    }
    weight_holder_cap();

    zcopies(weight_holder_height_cap-3*thickness, 2) {
        top_link_cap(length=weight_holder_width_cap+4*thickness, hole=$idx==0);
        down($idx==0 ? thickness: -thickness)
        top_cap(hole=$idx==0);
    }
}

// viz3d_cap();


module export_2d_cap() {
    
    xcopies(weight_holder_width+1, 2){
        weight_holder_side_cap();
        fwd(weight_holder_height_cap/2+weight_holder_width_cap+1)
        top_link_cap(length=weight_holder_width_cap+4*thickness, hole=$idx==0);
        fwd(weight_holder_height_cap/2+2*weight_holder_width_cap+pulley_thickness)
        top_cap(hole=$idx==0);
    }
}

// export_2d_cap();

// =================== END CAP =================== //

// =================== BEGIN FANCY WEIGHTS =================== //

fancy_weight_diameter = 39;
fancy_weight_outer_diameter = fancy_weight_diameter + 4 * thickness;
fancy_weight_height = 45;
n_weights = 2;

fancy_weight_total_height = n_weights * fancy_weight_height + 6 * thickness;
// n_links = 4;
module fancy_weight() {
    cyl(r=fancy_weight_diameter/2, l=fancy_weight_height);
}

module fancy_weight_ring(n_links=2, zrot=90) {
    difference() {
        tube(id=fancy_weight_diameter, od=fancy_weight_outer_diameter, l=thickness);
        // notches
        zrot(zrot)
        zrot_copies(n=n_links)
        fwd(fancy_weight_outer_diameter/2-thickness/2)
        cuboid([thickness, thickness, 2*thickness]);
    }
}

module fancy_weight_top_ring(center_notches=false, n_links=2, zrot=90) {
    difference() {
        cyl(r=fancy_weight_outer_diameter/2, h=thickness);
        // notches
        zrot(zrot)
        zrot_copies(n=n_links)
        fwd(fancy_weight_outer_diameter/2-thickness/2)
        cuboid([thickness, thickness, 2*thickness]);

        if(center_notches) {
            left(fancy_weight_outer_diameter/4)
            mirror_copy(FRONT, weight_holder_width_cap/2)
            cuboid([fancy_weight_outer_diameter/2, thickness, 2*thickness]);
        }
    }
}

// fancy_weight_top_ring(true);

module fancy_weight_link(rings=false) {
    difference() {
        cuboid([fancy_weight_total_height, 2*thickness, thickness]);
        // rings
        if(rings) {
            fwd(thickness/2)
            xcopies(fancy_weight_total_height/n_weights, n_weights)
            xcopies(fancy_weight_height-7*thickness, 2)
            cuboid([thickness, thickness, 2*thickness]);
        }
        
        // top / bottom rings
        fwd(thickness/2)
        xcopies(fancy_weight_total_height-3*thickness, 2)
        cuboid([thickness, thickness, 2*thickness]);
    }
}

module viz3d_fancy_weight(n_links=4, rings=false, zrot=90) {
  
    xrot(90) {
        fake_pulley();
    }
    weight_holder_cap();
    
    up(weight_holder_height_cap/2-thickness-thickness/2)
    top_link_cap(length=weight_holder_width_cap+4*thickness, hole=false);
    up(weight_holder_height_cap/2-thickness/2)
    top_cap(hole=false);

    down(weight_holder_height_cap/2-thickness-thickness/2)
    fancy_weight_top_ring(true, n_links);

    zrot(zrot)
    zrot_copies(n=n_links)
    back(fancy_weight_diameter/2+thickness)
    down(weight_holder_height_cap/2-3*thickness+fancy_weight_total_height/2)
    yrot(zrot)
    fancy_weight_link(rings);

    down(weight_holder_height_cap/2+fancy_weight_height)
    zcopies(n_weights*fancy_weight_height/2, n_weights)
    fancy_weight();
    
    if(rings) {
        down(weight_holder_height_cap/2+fancy_weight_height+thickness/2)
        zcopies(fancy_weight_total_height/n_weights, n_weights)
        zcopies(fancy_weight_height-7*thickness, 2)
        fancy_weight_ring(n_links);
    }

    down(weight_holder_height_cap/2+fancy_weight_total_height-4.5*thickness)
    fancy_weight_top_ring(false, n_links);
}


module export_2d_fancy_weight(n_links=2, rings=false) {
    fwd(weight_holder_height_cap/2+weight_holder_width_cap+10)
    top_link_cap(length=weight_holder_width_cap+4*thickness, hole=false);
    fwd(weight_holder_height_cap/2+2*weight_holder_width_cap+pulley_thickness+20)
    top_cap(hole=false);
    xcopies(weight_holder_width+1, 2){
        weight_holder_side_cap();
    }
    fwd(-weight_holder_height_cap/2-fancy_weight_outer_diameter/2-10)
    xcopies(fancy_weight_outer_diameter, 2)
    fancy_weight_top_ring($idx==0, n_links);

    fwd(-weight_holder_height_cap/2-fancy_weight_outer_diameter-2*n_links*thickness-10)
    ycopies(2*thickness+1, n_links)
    fancy_weight_link(rings);
    
    if(rings) {
        left(3*fancy_weight_outer_diameter/2+10)
        ycopies(fancy_weight_outer_diameter+1, n_links)
        fancy_weight_ring(n_links);
    }
}

// export_2d_fancy_weight(4, false);
// export_2d_fancy_weight(2, true);
// viz3d_fancy_weight(2, true);
// viz3d_fancy_weight(4, false);

// fancy_weight_link();
// fancy_weight();

// =================== END FANCY WEIGHTS =================== //


module export_2d_v1() {
    head_holder();

    back(weight_holder_height)
    xcopies(weight_holder_width+1, 2)
    weight_holder_side();

    fwd(weight_holder_height-10)
    top_link();
}
module export_2d_v2() {
    xcopies(weight_holder_width+1, 2)
    weight_holder_side_v2();
    fwd(weight_holder_height)
    xcopies(weight_holder_width+1, 2)
    link_v2();
}

module export_part_2d_no_render() {
    if(part == "weight_v1") {
        export_2d_v1();
    }
    if(part == "weight_v2") {
        export_2d_v2();
    }
    if(part == "weight_cap") {
        export_2d_cap();
    }
    if(part == "fancy_weight_cap4") {
        export_2d_fancy_weight(4, false);
    }
    if(part == "fancy_weight_cap2") {
        export_2d_fancy_weight(2, true);
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

// viz3d_v1();

module export_part(part=part) {
    if(part == "weight_v1") {
        viz3d_v1();
    }
    if(part == "weight_v2") {
        viz3d_v2();
    }
    if(part == "weight_cap") {
        viz3d_cap();
    }
    if(part == "fancy_weight_cap4") {
        viz3d_fancy_weight(4, false);
    }
    if(part == "fancy_weight_cap2") {
        viz3d_fancy_weight(2, true);
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

module import_part(name) {
    color( rands(0,1,3), alpha=1 )
    import(str("exports/weight_parts_length", gondola_length, "_3d/", name, ".stl"));
}

if(command == "") {
    // import_part("weight_v2");
}

// export_2d_v1();
// export_2d_v2();
// top_link();
// viz3d_v1();
// viz3d_v2();

// - Anneaux gondola ok
// - Servo holder gondola ok
// - Weight holder gondola ok
// - Motor mounts heads ok
