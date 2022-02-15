include <BOSL2/constants.scad>
include <BOSL2/shapes.scad>
include <BOSL2/screws.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
include <BOSL2/gears.scad>
include <BOSL2/nema_steppers.scad>
include <BOSL2/rounding.scad>

include <parameters.scad>
include <pen_holder.scad>


$fa=2;
$fs=2;

nema17_width = nema_motor_width(17);

pushing_plate_width = 30;
cable_clamp_thickness = 3;

landing_length = 20;

t8_screw_diameter = 8;
t8_lead_big_diameter = 22;
t8_lead_small_diameter = 10.3;
t8_lead2_big_diameter = 14;
t8_lead2_small_diameter = 10.3;
t8_lead_screw_diameter = 3.6;
t8_lead_big_length = 15;
t8_lead_small_length = 4;
t8_lead2_big_length = 15;
t8_lead2_small_length = 4;
t8_lead_screw_offset = 8;
bulldozer_t8_margin = 1;

pen_nsides = 0;
pen_to_bearing_margin = 3;
gs_ground_to_pen_center = nema17_width/2 + 2*thickness + pen_diameter/2 + t8_lead_big_diameter/2 + pen_to_bearing_margin;
echo("gs_ground_to_pen_center:", gs_ground_to_pen_center);
pen_holder_height = gs_ground_to_pen_center + 20;
sliding_magnet_width = 15;
comb_notch = 5;
// case_width = 140;
case_width = 90;
nema17_depth = 30;
axe_length = 100;
case_length = nema17_depth + axe_length + landing_length;
echo("case_length: ", case_length+20);
case_side_void_h = 20;
case_side_chamfer = 40;
case_side_height = nema17_width + 2*thickness;
case_cap_notch_width = 15;
case_side_bottom_notch_length = 30;

bearing_diameter = 22;
linear_bearings_spacing = 45;

linear_bearings_outer_diameter = 15;
linear_bearings_inner_diameter = 8;
linear_bearings_length = 24;
case_hole_margin = 12;

bulldozer_margin = 1;
bulldozer_width = case_width-4*thickness-2*bulldozer_margin;
bulldozer_body_height = t8_lead_big_diameter;
bulldozer_top_height = pen_diameter + pen_to_bearing_margin;
bulldozer_top_width = pen_diameter + 4 * thickness;

module pen_attachment() {
    cyl(d=pen_diameter+cable_clamp_thickness, h=cable_clamp_thickness);
}

module pen() {
    // Body
    color([0.5, 0.2, 0.1])
    cyl(d=pen_diameter, h=pen_length, anchor=BOTTOM);
    
    // Cap
    up(pen_length)
    color([0.1, 0.5, 0.2])
    cyl(d=pen_cap_diameter, h=pen_cap_length, anchor=BOTTOM);
}

pen_cap_plate_width = 35;
pen_cap_plate_height = pen_diameter + 2 * pen_to_bearing_margin - 1;

module pen_cap_plate() {
    difference() {
        cuboid([pen_cap_plate_width, pen_cap_plate_height, thickness]);
        cyl(d=pen_cap_diameter, h=2*thickness);
        
        mirror_copy(LEFT, (pen_diameter+pen_bulldozer_margin)/2+thickness+magnet_size/2)
        cuboid([magnet_size, magnet_size, magnet_size]);
    }
}

module pen_with_attachment() {
    pen();
    up(pen_length-2*thickness)
    pen_attachment();

    up(pen_length+4*thickness)
    pen_cap_plate();
    // pen_attachment();
}

module bearing_and_sliders() {
    // Bearing
    fwd(-thickness)
    cyl(d=bearing_diameter, h=2*thickness);

    // Sliders
    fwd(-thickness)
    mirror_copy(LEFT, linear_bearings_spacing/2)
    cyl(d=linear_bearings_inner_diameter, h=2*thickness);
}

case_center_length = case_length - nema17_depth - landing_length;
// case_center_length = max_pen_body_length - 4*thickness;


module case_main_simple() {
    difference() {
        cuboid([case_width, case_length, thickness]);

        // Cap notch
        fwd(case_length/2-thickness)
        cuboid([case_width - 2*case_cap_notch_width, 2*thickness, 2*thickness]);
        
        // Motor attachment notch
        fwd(-case_length/2+nema17_depth)
        cuboid([case_width - 2*case_cap_notch_width, 2*thickness, 2*thickness]);
        
        // Side bottom notches
        notch_length = case_length - nema17_depth - case_side_bottom_notch_length - case_side_bottom_notch_length/2;
        fwd(case_length/2-case_side_bottom_notch_length-notch_length/2)
        mirror_copy(LEFT, case_width/2-thickness)
        cuboid([2*thickness, notch_length, 2*thickness]);
        
        // Side bottom motor attachment notches
        motor_notch_length = nema17_depth - case_side_bottom_notch_length/2;
        fwd(-case_length/2+motor_notch_length/2)
        mirror_copy(LEFT, case_width/2-thickness)
        cuboid([2*thickness, motor_notch_length, 2*thickness]);

        // Bottom hole
        fwd(nema17_depth/2)
        cuboid([case_width-4*thickness-2*case_hole_margin, axe_length-2*thickness-2*case_hole_margin, 2*thickness]);
    }
}

module case_side_simple() {
    difference() {
        cuboid([case_side_height, case_length, thickness]);
        // Prism voids
        right(case_side_height/2-case_side_void_h) {
            // Motor void
            fwd(-case_length/2)
            yrot(90)
            prismoid(size1=[thickness, 2*(nema17_depth-thickness)-case_side_chamfer], size2=[thickness, 2*(nema17_depth-thickness)], h=case_side_void_h);
            // Pen void
            void_length = case_length-nema17_depth-3*thickness;
            fwd(case_length/2-void_length/2-2*thickness)
            yrot(90)
            prismoid(size1=[thickness, void_length-case_side_chamfer], size2=[thickness, void_length], h=case_side_void_h);
        }
        // Cap notches
        fwd(case_length/2-thickness)
        xcopies(case_side_height-case_cap_notch_width, 2)
        cuboid([case_cap_notch_width, 2*thickness, 2*thickness]);
        
        // Motor attachment notches
        fwd(-case_length/2+nema17_depth)
        xcopies(case_side_height-case_cap_notch_width, 2)
        cuboid([case_cap_notch_width, 2*thickness, 2*thickness]);

        // Bottom cap notch
        fwd(case_length/2-case_side_bottom_notch_length/2)
        left(case_side_height/2-thickness)
        cuboid([2*thickness, case_side_bottom_notch_length, 2*thickness]);

        // Bottom motor attachment notch
        fwd(-case_length/2+nema17_depth)
        left(case_side_height/2-thickness)
        cuboid([2*thickness, case_side_bottom_notch_length, 2*thickness]);
    }
}

module case_main() {
    color("red")
    difference() {
        cuboid([case_width, case_length, thickness]);

        // Cap notch
        fwd(case_length/2-landing_length+2*thickness)
        ycopies(4*thickness, 2)
        cuboid([case_width - 2*case_cap_notch_width, 2*thickness, 2*thickness]);
        
        // Motor attachment notch
        fwd(-case_length/2+nema17_depth)
        cuboid([case_width - 2*case_cap_notch_width, 2*thickness, 2*thickness]);
        
        // Side bottom notches
        notch_length = case_length - nema17_depth - landing_length - case_side_bottom_notch_length;
        fwd(case_length/2-landing_length-case_center_length/2)
        mirror_copy(LEFT, case_width/2-thickness)
        cuboid([2*thickness, notch_length, 2*thickness]);
        
        // Side cap bottom notches
        cap_notch_length = landing_length - case_side_bottom_notch_length/2 - 4*thickness;
        fwd(case_length/2-cap_notch_length/2)
        mirror_copy(LEFT, case_width/2-thickness)
        cuboid([2*thickness, cap_notch_length, 2*thickness]);

        // Side bottom motor attachment notches
        motor_notch_length = nema17_depth - case_side_bottom_notch_length/2;
        fwd(-case_length/2+motor_notch_length/2)
        mirror_copy(LEFT, case_width/2-thickness)
        cuboid([2*thickness, motor_notch_length, 2*thickness]);

        // Bottom hole
        hole_width = case_width-4*thickness-2*case_hole_margin;
        hole_length = axe_length-2*thickness-case_hole_margin-thickness;
        fwd(-case_length/2+nema17_depth+2*thickness+hole_length/2)
        cuboid([hole_width, hole_length, 2*thickness]);

        // Bottom hole
        landing_hole_length = landing_length-5*thickness-2*thickness;
        fwd(case_length/2-landing_hole_length/2)
        cuboid([hole_width, landing_hole_length, 2*thickness]);
    }
}
pen_bulldozer_margin = 1;

module bulldozer(top=true, small=false) {
    difference() {
        union() {
            cuboid([bulldozer_width, bulldozer_body_height, thickness]);
            
            if(top)
            fwd(-bulldozer_body_height/2-bulldozer_top_height/2)
            cuboid([small ? bulldozer_top_width : bulldozer_width, bulldozer_top_height, thickness]);
        }
        // Pen
        if(top)
        union() {
            fwd(-bulldozer_body_height/2-pen_to_bearing_margin-pen_diameter/2)
            cyl(d=pen_diameter+pen_bulldozer_margin, h=2*thickness);
            
            fwd(-bulldozer_body_height/2-3*bulldozer_top_height/4)
            cuboid([pen_diameter+pen_bulldozer_margin, bulldozer_top_height/2, thickness]);
            
            if(!small)
            fwd(-bulldozer_body_height/2-pen_to_bearing_margin-(pen_diameter+pen_bulldozer_margin)/2)
            mirror_copy(LEFT, (pen_diameter+pen_bulldozer_margin)/2+thickness+magnet_size/2)
            cuboid([magnet_size, magnet_size, magnet_size]);
        }

        // T8 screw
        cyl(d=t8_screw_diameter+bulldozer_t8_margin, h=2*thickness);
        
        zrot_copies(n=4)
        left(t8_lead_screw_offset)
        cyl(d=t8_lead_screw_diameter, h=2*thickness);

        // Linear bearings
        mirror_copy(LEFT, linear_bearings_spacing/2)
        cyl(d=linear_bearings_outer_diameter, h=2*thickness);
    }
}
// bulldozer();

module case_wall(bearings=true, pen_print=false) {
    color("blue")
    difference() {
        union() {
            cuboid([case_width, case_side_height, thickness]);

            if(pen_print)
            fwd(-case_side_height/2-pen_diameter/4)
            cuboid([bulldozer_width, pen_diameter/2, thickness]);
        }
        
        // Side notches
        // fwd(-thickness)
        mirror_copy(LEFT, case_width/2-thickness)
        cuboid([2*thickness, case_cap_notch_width, 2*thickness]);

        // Bottom notches
        fwd(case_side_height/2-thickness)
        mirror_copy(LEFT, case_width/2-case_cap_notch_width/2)
        cuboid([case_cap_notch_width, 2*thickness, 2*thickness]);

        if(bearings)
        bearing_and_sliders();

        if(pen_print)
        left(-linear_bearings_spacing/4)
        union() {
            fwd(-case_side_height/2)
            xcopies(linear_bearings_spacing/2, 2)
            cyl(d=pen_diameter+pen_bulldozer_margin, h=2*thickness);
            fwd(-case_side_height/2-pen_diameter/4)
            xcopies(linear_bearings_spacing/2, 2)
            cuboid([pen_diameter+pen_bulldozer_margin, pen_diameter/2, 2*thickness]);

        }

        whth = pen_diameter/2;
        if(pen_print)
        fwd(-case_side_height/2-whth/2)
        left(bulldozer_width/2-bulldozer_width/6)
        cuboid([bulldozer_width/3, whth, 2*thickness]);
    }
}

// case_wall(bearings=true, pen_print=true);

// left(100)
// case_motor_cap();


// color("green")
// fwd(-case_length/2+nema17_depth/2)
// cuboid([10, nema17_depth, 100]);

// color("red")
// fwd(-case_length/2+nema17_depth+axe_length/2)
// cuboid([10, axe_length, 100]);

// color("blue")
// fwd(-case_length/2+nema17_depth+axe_length+landing_length/2)
// cuboid([10, landing_length, 100]);

module case_side() {
    color("green")
    difference() {
        cuboid([case_side_height, case_length, thickness]);
        // Prism voids
        right(case_side_height/2-case_side_void_h) {
            // Motor void
            fwd(-case_length/2)
            yrot(90)
            prismoid(size1=[2*thickness, 2*(nema17_depth-thickness)-case_side_chamfer], size2=[2*thickness, 2*(nema17_depth-thickness)], h=case_side_void_h);
            // Pen void
            void_length = case_length-nema17_depth-2*thickness-landing_length;
            fwd(-case_length/2+nema17_depth+axe_length/2)
            yrot(90)
            prismoid(size1=[2*thickness, axe_length-2*thickness-case_side_chamfer], size2=[2*thickness, axe_length-2*thickness], h=case_side_void_h);

            // Cap void
            fwd(case_length/2)
            yrot(90)
            prismoid(size1=[2*thickness, 2*(landing_length-5*thickness)-case_side_chamfer], size2=[2*thickness, 2*(landing_length-5*thickness)], h=case_side_void_h);
        }
        // Cap notches
        fwd(case_length/2-landing_length+2*thickness)
        ycopies(4*thickness, 2)
        xcopies(case_side_height-case_cap_notch_width, 2)
        cuboid([case_cap_notch_width, 2*thickness, 2*thickness]);
        
        // Motor attachment notches
        fwd(-case_length/2+nema17_depth)
        xcopies(case_side_height-case_cap_notch_width, 2)
        cuboid([case_cap_notch_width, 2*thickness, 2*thickness]);

        // Bottom cap notch
        fwd(case_length/2-landing_length+2*thickness)
        left(case_side_height/2-thickness)
        cuboid([2*thickness, case_side_bottom_notch_length+4*thickness, 2*thickness]);

        // Bottom motor attachment notch
        fwd(-case_length/2+nema17_depth)
        left(case_side_height/2-thickness)
        cuboid([2*thickness, case_side_bottom_notch_length, 2*thickness]);
    }
}

// right(60)
// case_side();

// module case() {
//     fwd(-case_length/2+nema17_depth-thickness)
//     up(nema17_width/2+2*thickness)
//     xrot(90)
//     nema17_stepper();

//     up(thickness)
//     zcopies(thickness, 2)
//     case_main();
    
//     // Motor attachment
//     fwd(-case_length/2+nema17_depth)
//     up(nema17_width/2+thickness)
//     xrot(90)
//     zcopies(thickness, 2)
//     case_wall();

//     // Case cap
//     fwd(case_length/2-landing_length)
//     up(nema17_width/2+thickness)
//     xrot(90)
//     up(2*thickness)
//     zcopies(thickness, 2)
//     zcopies(4*thickness, 2)
//     case_wall($idx==0, pen_print=true);

//     // Sides
//     mirror_copy(LEFT, case_width/2)
//     up(nema17_width/2+thickness)
//     yrot(-90)
//     down(thickness)
//     zcopies(thickness, 2)
//     case_side();
// }

module import_case() {
    fwd(-case_length/2+nema17_depth-thickness)
    up(nema17_width/2+2*thickness)
    xrot(90)
    import_part("gs_nema17_stepper");

    up(thickness)
    zcopies(thickness, 2)
    // case_main();
    import_part("gs_case_main");
    
    // Motor attachment
    fwd(-case_length/2+nema17_depth)
    up(nema17_width/2+thickness)
    xrot(90)
    zcopies(thickness, 2)
    // case_wall();
    import_part("gs_case_wall_motor");

    // Case cap
    fwd(case_length/2-landing_length)
    up(nema17_width/2+thickness)
    xrot(90)
    up(2*thickness)
    zcopies(thickness, 2)
    zcopies(4*thickness, 2)
    // case_wall($idx==0, pen_print=true);
    import_part($idx==0 ? "gs_case_wall_cap" : "gs_case_wall_end");

    // Sides
    mirror_copy(LEFT, case_width/2)
    up(nema17_width/2+thickness)
    yrot(-90)
    down(thickness)
    zcopies(thickness, 2)
    // case_side();
    import_part("gs_case_side");
}

coupler_length = 25;
coupler_diameter = 19;
remaining_length = axe_length - t8_lead_big_length - coupler_length - 6*thickness;
echo("remaining_length: ", remaining_length);

module axe_and_guides() {
    fwd(-case_length/2+nema17_depth+coupler_length/2)
    xrot(90)
    cyl(d=coupler_diameter, h=coupler_length);
    
    // T8 screw and guides
    fwd(-case_length/2+nema17_depth+axe_length/2)
    xrot(90){
        // T8 screw
        cyl(d=8, h=axe_length);
        // Guides
        mirror_copy(LEFT, linear_bearings_spacing/2)
        cyl(d=linear_bearings_inner_diameter, h=axe_length);
    }
    
    // T8 lead and linear bearings
    fwd(case_length/2-landing_length-7*thickness)
    xrot(90) {
        // T8 lead
        xrot(180) {
            difference() {
                cyl(d=t8_lead_big_diameter, h=t8_lead_small_length, anchor=BOTTOM);
                zrot_copies(n=4)
                left(t8_lead_screw_offset)
                cyl(d=t8_lead_screw_diameter, h=2*thickness, anchor=BOTTOM);
            }
            cyl(d=t8_lead_small_diameter, h=t8_lead_big_length, anchor=BOTTOM);
        }

        // Linear bearings
        mirror_copy(LEFT, linear_bearings_spacing/2)
        tube(od=linear_bearings_outer_diameter, id=linear_bearings_inner_diameter, h=linear_bearings_length);
    }
}



// module visualization() {
//     up(2*thickness + nema17_width/2)
//     axe_and_guides();

//     case();

//     fwd(case_length/2-landing_length-4*thickness)
//     up(2*thickness+nema17_width/2)
//     xrot(90) {
//         zcopies(4*thickness, 2)
//         zcopies(thickness, 2)
//         bulldozer();

//         zcopies(thickness, 2)
//         bulldozer(false);
//     }

//     fwd(case_length/2-pen_length-landing_length)
//     up(gs_ground_to_pen_center)
//     xrot(90)
//     pen_with_attachment();
// }

// visualization();

module import_part(name) {
    color( rands(0,1,3), alpha=1 )
    import(str("exports/ground_station_parts_length", gondola_length, "_3d/", name, ".stl"));
}

module load_visualization() {
    up(2*thickness + nema17_width/2)
    // axe_and_guides();
    import_part("gs_axe_and_guides");

    import_case();

    fwd(case_length/2-landing_length-4*thickness)
    up(2*thickness+nema17_width/2)
    xrot(90) {
        zcopies(thickness, 2)
        zcopies(4*thickness, 2)
        // bulldozer(true, $idx==0);
        import_part("gs_bulldozer");

        zcopies(thickness, 2)
        // bulldozer(false);
        import_part("gs_bulldozer_spacer");
    }

    fwd(case_length/2-landing_length+pen_length)
    up(gs_ground_to_pen_center)
    xrot(-90)
    pen_with_attachment();
    // import_part("gs_pen_with_attachment");

    // left(linear_bearings_spacing/2)
    fwd(case_length/2+18)
    pen_holder();
    // import_part("gs_pen_holder");
}

part = "";


module export_part(part=part) {
    if(part == "gs_case_main") {
        case_main();
    }
    if(part == "gs_case_wall_motor") {
        case_wall();
    }
    if(part == "gs_case_wall_cap") {
        case_wall(true, true);
    }
    if(part == "gs_case_wall_end") {
        case_wall(false, true);
    }
    if(part == "gs_case_side") {
        case_side();
    }
    if(part == "gs_nema17_stepper") {
        nema17_stepper();
    }
    if(part == "gs_bulldozer") {
        bulldozer();
    }
    if(part == "gs_bulldozer_spacer") {
        bulldozer(false);
    }
    if(part == "gs_pen_with_attachment") {
       pen_with_attachment();
    }
    if(part == "gs_axe_and_guides") {
        axe_and_guides();
    }
    if(part == "gs_pen_holder") {
        pen_holder();
    }
    if(part == "gs_pen_cap_plate") {
        pen_cap_plate();
    }
}
module export_part_2d_no_render() {
     export_part(part=part);
}

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
    load_visualization();
}


// - Import pen holder
// - Set length
// - Set width
// - Bearings

// - Magnets plate
// - Set height