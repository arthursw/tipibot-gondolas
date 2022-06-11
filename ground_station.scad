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

echo("nema17_width", nema17_width);
pushing_plate_width = 30;
cable_clamp_thickness = 3;

landing_length = 35;

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

sliding_magnet_width = 15;
comb_notch = 5;
// case_width = 140;

nema17_depth = 30;
case_height = 56;
nema17z = case_height - nema17_width / 2;
axe_length = 100;
case_length = nema17_depth + axe_length + landing_length;
echo("case_length: ", case_length+20);
case_side_void_h = 20;
case_side_chamfer = 40;
case_cap_notch_width = 25;
case_side_bottom_notch_length = 30;

penz = case_height + case_to_pen_center;
echo("penz:", penz);


t8_bearing_thickness = 7;
t8_bearing_diameter = 22;
linear_bearings_spacing = 20;
linear_bearings_offset_z = sqrt(3/4) * linear_bearings_spacing;
// x * x = (x/2)*(x/2) + h*h
// h = sqrt(x*x-(x/2)*(x/2)) = sqrt(x*x*(1-1/4)) = sqrt(3/4) * x

linear_bearings_outer_diameter = 12;
linear_bearings_inner_diameter = 6;
linear_bearings_length = 24;
case_hole_margin = 12;

bulldozer_margin = 1;
bulldozer_width = case_width-4*thickness-2*bulldozer_margin;
bulldozer_body_height = linear_bearings_offset_z + t8_lead_big_diameter;
bulldozer_top_to_case_top = case_height - nema17z - t8_lead_big_diameter/2;
bulldozer_top_height = bulldozer_top_to_case_top + pen_diameter + pen_diameter / 2 + pen_case_margin;
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
pen_attachment_margin = 7;
pen_cap_waffle_diameter = pen_cap_diameter+2*thickness;
pen_cap_waffle_diameter_margin = 2;

pen_attachement_inner_margin = 0.3;

module pen_with_attachment(two_d=false) {
    if(two_d) {
        left(40)
        tube(id=pen_diameter-pen_attachement_inner_margin, od=pen_diameter+pen_attachment_margin, h=thickness);
        xrot(90)
        cap_gear();
        left(75)
        xcopies(pen_cap_waffle_diameter+2, 2)
        tube(id=pen_cap_diameter-pen_attachement_inner_margin, od=pen_cap_waffle_diameter, h=thickness);
    } else {
        pen();
        up(pen_length-6.5*thickness)
        tube(id=pen_diameter-pen_attachement_inner_margin, od=pen_diameter+pen_attachment_margin, h=thickness);
        // pen_attachment();

        // pen_cap_plate();
        // fwd(case_length/2-landing_length+2*thickness)
        // up(penz)
        up(pen_length+2*thickness)
        xrot(90)
        {   
            xrot(90)
            up(-thickness/2)
            zcopies(2*thickness, 2)
            tube(id=pen_cap_diameter-pen_attachement_inner_margin, od=pen_cap_waffle_diameter, h=thickness);
            cap_gear();
        }

        // pen_attachment();
    }
    
}

// pen_with_attachment(two_d=true);

module bearing_and_sliders() {
    // Bearing
    // fwd(-2*thickness)
    cyl(d=t8_bearing_diameter, h=2*thickness);

    // Sliders
    fwd(linear_bearings_offset_z)
    mirror_copy(LEFT, linear_bearings_spacing/2)
    cyl(d=linear_bearings_inner_diameter, h=2*thickness);
}

case_center_length = case_length - nema17_depth - landing_length;
// case_center_length = max_pen_body_length - 4*thickness;


// module case_main_simple() {
//     difference() {
//         cuboid([case_width, case_length, thickness]);

//         // Cap notch
//         fwd(case_length/2-thickness)
//         cuboid([case_width - 2*case_cap_notch_width, 2*thickness, 2*thickness]);
        
//         // Motor attachment notch
//         fwd(-case_length/2+nema17_depth)
//         cuboid([case_width - 2*case_cap_notch_width, 2*thickness, 2*thickness]);
        
//         // Side bottom notches
//         notch_length = case_length - nema17_depth - case_side_bottom_notch_length - case_side_bottom_notch_length/2;
//         fwd(case_length/2-case_side_bottom_notch_length-notch_length/2)
//         mirror_copy(LEFT, case_width/2-thickness)
//         cuboid([2*thickness, notch_length, 2*thickness]);
        
//         // Side bottom motor attachment notches
//         motor_notch_length = nema17_depth - case_side_bottom_notch_length/2;
//         fwd(-case_length/2+motor_notch_length/2)
//         mirror_copy(LEFT, case_width/2-thickness)
//         cuboid([2*thickness, motor_notch_length, 2*thickness]);

//         // Bottom hole
//         fwd(nema17_depth/2)
//         cuboid([case_width-4*thickness-2*case_hole_margin, axe_length-2*thickness-2*case_hole_margin, 2*thickness]);
//     }
// }

// module case_side_simple() {
//     difference() {
//         cuboid([case_height, case_length, thickness]);
//         // Prism voids
//         right(case_height/2-case_side_void_h) {
//             // Motor void
//             fwd(-case_length/2)
//             yrot(90)
//             prismoid(size1=[thickness, 2*(nema17_depth-thickness)-case_side_chamfer], size2=[thickness, 2*(nema17_depth-thickness)], h=case_side_void_h);
//             // Pen void
//             void_length = case_length-nema17_depth-3*thickness;
//             fwd(case_length/2-void_length/2-2*thickness)
//             yrot(90)
//             prismoid(size1=[thickness, void_length-case_side_chamfer], size2=[thickness, void_length], h=case_side_void_h);
//         }
//         // Cap notches
//         fwd(case_length/2-thickness)
//         xcopies(case_height-case_cap_notch_width, 2)
//         cuboid([case_cap_notch_width, 2*thickness, 2*thickness]);
        
//         // Motor attachment notches
//         fwd(-case_length/2+nema17_depth)
//         xcopies(case_height-case_cap_notch_width, 2)
//         cuboid([case_cap_notch_width, 2*thickness, 2*thickness]);

//         // Bottom cap notch
//         fwd(case_length/2-case_side_bottom_notch_length/2)
//         left(case_height/2-thickness)
//         cuboid([2*thickness, case_side_bottom_notch_length, 2*thickness]);

//         // Bottom motor attachment notch
//         fwd(-case_length/2+nema17_depth)
//         left(case_height/2-thickness)
//         cuboid([2*thickness, case_side_bottom_notch_length, 2*thickness]);
//     }
// }

module case_main() {
    color("red")
    difference() {
        cuboid([case_width, case_length, thickness]);

        // Cap notch
        fwd(case_length/2-landing_length+2*thickness)
        ycopies(6*thickness, 2)
        cuboid([case_width - case_cap_notch_width, 2*thickness, 2*thickness]);
        
        // Motor attachment notch
        fwd(-case_length/2+nema17_depth)
        cuboid([case_width - case_cap_notch_width, 2*thickness, 2*thickness]);
        
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
    color("blue")
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
            fwd(-bulldozer_body_height/2-bulldozer_top_height+pen_diameter)
            cyl(d=pen_diameter+pen_bulldozer_margin, h=2*thickness);
            
            fwd(-bulldozer_body_height/2-bulldozer_top_height+pen_diameter/2)
            cuboid([pen_diameter+pen_bulldozer_margin, pen_diameter, thickness]);
            
            // // Magnets
            // if(!small)
            // fwd(-bulldozer_body_height/2-bulldozer_top_height+pen_diameter/2)
            // mirror_copy(LEFT, (pen_diameter+pen_bulldozer_margin)/2+thickness+magnet_size/2)
            // cuboid([magnet_size, magnet_size, magnet_size]);
        }

        // T8 screw
        fwd(-bulldozer_body_height/2+t8_lead_big_diameter/2) {
            cyl(d=t8_screw_diameter+bulldozer_t8_margin, h=2*thickness);
            
            zrot_copies(n=4)
            left(t8_lead_screw_offset)
            cyl(d=t8_lead_screw_diameter, h=2*thickness);

            // Linear bearings
            fwd(linear_bearings_offset_z)
            mirror_copy(LEFT, linear_bearings_spacing/2)
            cyl(d=linear_bearings_outer_diameter, h=2*thickness);
        }
    }
}
// bulldozer();
planetary_gears_screw_spacing_diameter = 28;

module case_wall(bearings=true, pen_print=false, cap_activator=false, pen_cap_waffle=false) {
    color("blue")
    difference() {
        case_wall_top = penz + pen_diameter - case_height;
        union() {
            cuboid([case_width, case_height, thickness]);

            if(pen_print)
            fwd(-case_height/2-case_wall_top/2)
            cuboid([bulldozer_width, case_wall_top, thickness]);
        }
        
        // Side notches
        // fwd(-thickness)
        mirror_copy(LEFT, case_width/2-thickness)
        cuboid([2*thickness, case_cap_notch_width, 2*thickness]);

        // Bottom notches
        fwd(case_height/2-thickness)
        mirror_copy(LEFT, case_width/2-case_cap_notch_width/4)
        cuboid([case_cap_notch_width/2, 2*thickness, 2*thickness]);

        // Bearings and sliders holes
        if(bearings)
        fwd(case_height/2-nema17z)
        bearing_and_sliders();

        // Nema 17
        if(bearings && !pen_print && !cap_activator) {
            fwd(case_height/2-nema17z)
            nema_mount_holes(size=17, depth=3*thickness, l=0);

            // Planetary gears mount screw holes
            fwd(case_height/2-nema17z)
            zrot_copies(n=4, sa=45)
            left(planetary_gears_screw_spacing_diameter/2)
            cyl(d=3, h=2*thickness);
        }

        if(pen_print)
        union() {
            // Pen notch
            pen_min_z = cap_activator ? pen_diameter : pen_diameter + pen_diameter/2;
            fwd(-case_height/2-case_wall_top + pen_min_z)
            cyl(d=pen_diameter+pen_bulldozer_margin, h=2*thickness);
            fwd(-case_height/2-case_wall_top+pen_min_z/2)
            cuboid([pen_diameter+pen_bulldozer_margin, pen_min_z, 2*thickness]);
            
            // Pen cap Waffle
            if(pen_cap_waffle)
            fwd(-case_height/2-case_wall_top + pen_min_z)
            cyl(d=pen_cap_waffle_diameter+pen_cap_waffle_diameter_margin, h=2*thickness);

            // Magnets
            // if(bearings)
            // fwd(-case_height/2-case_wall_top + pen_diameter)
            // mirror_copy(LEFT, (pen_diameter+pen_bulldozer_margin)/2+thickness+magnet_size/2)
            // cuboid([magnet_size, magnet_size, magnet_size]);
        }

        // whth = pen_diameter/2;
        // if(pen_print)
        // fwd(-case_height/2-whth/2)
        // left(bulldozer_width/2-bulldozer_width/6)
        // cuboid([bulldozer_width/3, whth, 2*thickness]);
    }
}

// case_wall(pen_print=true, cap_activator=true, pen_cap_waffle=true);

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
        cuboid([case_height, case_length, thickness]);
        // Prism voids
        right(case_height/2-case_side_void_h) {
            // Motor void
            fwd(-case_length/2)
            yrot(90)
            prismoid(size1=[2*thickness, 2*(nema17_depth-thickness)-case_side_chamfer], size2=[2*thickness, 2*(nema17_depth-thickness)], h=case_side_void_h);
            
            // Pen void
            void_length = case_length-nema17_depth-2*thickness-landing_length;
            // fwd(-case_length/2+nema17_depth+axe_length/2)
            // yrot(90)
            // prismoid(size1=[2*thickness, axe_length-2*thickness-case_side_chamfer], size2=[2*thickness, axe_length-2*thickness], h=case_side_void_h);

            // Cap void
            fwd(case_length/2+thickness)
            yrot(90)
            prismoid(size1=[2*thickness, 2*(landing_length-5*thickness)-case_side_chamfer], size2=[2*thickness, 2*(landing_length-5*thickness)], h=case_side_void_h);
        }
        // Cap notches
        fwd(case_length/2-landing_length+2*thickness)
        ycopies(6*thickness, 2)
        xcopies(case_height-(case_height - case_cap_notch_width)/2, 2)
        cuboid([(case_height - case_cap_notch_width)/2, 2*thickness, 2*thickness]);
        
        // Motor attachment notches
        fwd(-case_length/2+nema17_depth)
        xcopies(case_height-(case_height - case_cap_notch_width)/2, 2)
        cuboid([(case_height - case_cap_notch_width)/2, 2*thickness, 2*thickness]);

        // Bottom cap notch
        fwd(case_length/2-landing_length+2*thickness)
        left(case_height/2-thickness)
        cuboid([2*thickness, case_side_bottom_notch_length+4*thickness, 2*thickness]);

        // Bottom motor attachment notch
        fwd(-case_length/2+nema17_depth)
        left(case_height/2-thickness)
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
    up(nema17z)
    import_part_gs("gs_nema17_stepper");

    up(thickness)
    zcopies(thickness, 2)
    // case_main();
    import_part_gs("gs_case_main");
    
    // Motor attachment
    // left(1)
    fwd(-case_length/2+nema17_depth)
    up(case_height/2)
    xrot(90)
    zcopies(thickness, 2)
    // case_wall();
    import_part_gs("gs_case_wall_motor");

    // Case cap
    // if(0)
    fwd(case_length/2-landing_length)
    up(case_height/2)
    xrot(90)
    up(2*thickness)
    mirror_copy(TOP, 3*thickness)
    zcopies(thickness, 2)
    // case_wall(true, pen_print=true, cap_activator=true, pen_cap_waffle=$idx==0);
    import_part_gs($idx==0 ? "gs_case_wall_cap" : "gs_case_wall_end");

    // Sides
    mirror_copy(LEFT, case_width/2)
    up(case_height/2)
    yrot(-90)
    down(thickness)
    zcopies(thickness, 2)
    // case_side();
    import_part_gs("gs_case_side");
}

axe_offset_y = 20;
coupler_length = 25;
coupler_diameter = 19;
remaining_length = axe_length - t8_lead_big_length - coupler_length - 6*thickness;


echo("remaining_length: ", remaining_length);

planetary_gears_diameter = 36;
planetary_gears_length = 42.7;
planetary_gears_axe_length = 20;
planetary_gears_axe_diameter = 6;

module planetary_gears() {
    xrot(90) {
        cyl(h=planetary_gears_length, d=planetary_gears_diameter, anchor=BOTTOM);
        up(planetary_gears_length)
        cyl(h=planetary_gears_axe_length, d=planetary_gears_axe_diameter, anchor=BOTTOM);
    }
}


module axe_and_guides(two_d) {
    if(two_d) {
        xrot(90)
        xcopies(40, 2)
        t8_gear();
    } else {
        // Coupler (axe holder)
        fwd(-case_length/2+nema17_depth+coupler_length/2)
        xrot(90)
        cyl(d=coupler_diameter, h=coupler_length);
        
        // T8 bearing
        fwd(case_length/2-landing_length-2*thickness)
        xrot(90)
        tube(od=t8_bearing_diameter, id=t8_screw_diameter, h=t8_bearing_thickness);
        
        // T8 screw and guides
        fwd(-case_length/2+nema17_depth+axe_length/2)
        xrot(90){
            // T8 screw
            up(axe_offset_y)
            cyl(d=t8_screw_diameter, h=axe_length);
            
            // Guides
            fwd(linear_bearings_offset_z)
            mirror_copy(LEFT, linear_bearings_spacing/2)
            cyl(d=linear_bearings_inner_diameter, h=axe_length);
        }
        
        // T8 lead and linear bearings
        fwd(case_length/2-landing_length-9*thickness)
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
            fwd(linear_bearings_offset_z)
            mirror_copy(LEFT, linear_bearings_spacing/2)
            tube(od=linear_bearings_outer_diameter, id=linear_bearings_inner_diameter, h=linear_bearings_length);
        }

        // T8 gears
        fwd(case_length/2-landing_length+2*thickness)
        ycopies(thickness, 2)
        t8_gear();
    }
}
// axe_and_guides();
pitch = 5;
helical = 0;

module cap_gear(shaft_diam=pen_cap_diameter-pen_attachement_inner_margin, teeth=30, spin=5) {
    difference() {
        spur_gear(pitch=pitch, teeth=teeth, thickness=thickness, helical=helical, shaft_diam=shaft_diam, spin=spin, orient=BACK);
        // yrot_copies(n=14)
        // mirror_copy(LEFT, (pen_diameter+pen_bulldozer_margin)/2+thickness+magnet_size/2)
        // cuboid([magnet_size, magnet_size, magnet_size]);
    }
}

module t8_gear(shaft_diam=t8_screw_diameter, teeth=22, spin=0) {
    spur_gear(pitch=pitch, teeth=teeth, thickness=thickness, helical=helical, shaft_diam=shaft_diam, spin=spin, orient=BACK);
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
//     up(penz)
//     xrot(90)
//     pen_with_attachment();
// }

// visualization();

module import_part_gs(name) {
    color( rands(0,1,3), alpha=1 )
    import(str("exports/ground_station_parts_length", gondola_length, "_3d/", name, ".stl"));
}

module import_ground_station() {
    up(nema17z)
    // axe_and_guides();
    import_part_gs("gs_axe_and_guides");

    import_case();

    fwd(case_length/2-landing_length-6*thickness)
    up(nema17z-bulldozer_body_height/2+t8_lead_big_diameter/2)
    xrot(90) {
        zcopies(thickness, 2)
        zcopies(4*thickness, 2)
        // bulldozer(true, $idx==0);
        import_part_gs("gs_bulldozer");

        zcopies(thickness, 2)
        // bulldozer(false);
        import_part_gs("gs_bulldozer_spacer");
    }

    fwd(case_length/2-landing_length-pen_length)
    up(penz)
    xrot(90)
    // pen_with_attachment();
    import_part_gs("gs_pen_with_attachment");

    // left(linear_bearings_spacing/2)
    up(penz-ground_to_pen_center)
    // fwd(case_length/2+18)
    // pen_holder();
    import_part_gs("gs_pen_holder");
}

part = "";


module export_part(part=part, two_d=false) {
    if(part == "gs_case_main") {
        case_main();
    }
    if(part == "gs_case_wall_motor") {
        case_wall();
    }
    if(part == "gs_case_wall_cap") {
        case_wall(true, pen_print=true, cap_activator=true, pen_cap_waffle=true);
    }
    if(part == "gs_case_wall_end") {
        case_wall(true, pen_print=true, cap_activator=true, pen_cap_waffle=false);
    }
    if(part == "gs_case_side") {
        case_side();
    }
    if(part == "gs_nema17_stepper" && !two_d) {
        fwd(-planetary_gears_length) {
            planetary_gears();
            xrot(90)
            nema17_stepper();
        }
    }
    if(part == "gs_bulldozer") {
        bulldozer();
    }
    if(part == "gs_bulldozer_spacer") {
        bulldozer(false);
    }
    if(part == "gs_pen_with_attachment") {
       pen_with_attachment(two_d=two_d);
    }
    if(part == "gs_axe_and_guides") {
        axe_and_guides(two_d=two_d);
    }
    if(part == "gs_pen_holder") {
        pen_holder(two_d=two_d);
    }
    if(part == "gs_pen_cap_plate") {
        pen_cap_plate();
    }
}
module export_part_2d_no_render() {
     export_part(part=part, two_d=true);
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

command_gs = "";

module export_command_gs() {
    if(command_gs == "3d") {
        export_part();
    }
    if(command_gs == "2d") {
        export_part_2d();
    }
}

export_command_gs();


if(command_gs == "" && !gs_imported_from_gondolami) {
    import_ground_station();
}
// pen_holder(two_d=true);

// pen_with_attachment(two_d=true);