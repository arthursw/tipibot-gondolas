include <BOSL2/constants.scad>
include <BOSL2/shapes.scad>
include <BOSL2/screws.scad>
include <Round-Anything/polyround.scad>
include <BOSL2/std.scad>
include <BOSL2/joiners.scad>
include <BOSL2/gears.scad>

thickness = 3;

gondola_length = 170;
gondola_outer_diameter = 200; // this is the total arc height ; the rail is rail_width bellow, the inner radius is gondola_outer_diameter - arc_width
arc_width = 20;
rail_width = 5;
notch = 10;
gondola_height = 93; // bottom to body top
gondola_width = 70;

holder_margin = thickness;
holder_spacing = gondola_length - 4 * thickness - 2 * holder_margin;
holder_length = holder_spacing + 2 * thickness;
holder_width = 75;
holder_notch = 7.5;
holder_height = 50;

wheel_diameter = 22;

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

module v_notch(od=200, arc_width, width, height, notch=10, screw=false) {
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
        tube(h=thickness, od=od, id=id);

        // horizontal notches
        h_notch(od, arc_width, notch, screw);
        
        xflip()
            h_notch(od, arc_width, notch, screw);
        
        // vertical notches
        v_notch(od, arc_width, width, height, notch, screw);

        xflip()
            v_notch(od, arc_width, width, height, notch, screw);

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
        up(thickness)
        
        // Thin arc
        main_arc_l(od-rail_width,  od-2*arc_width+rail_width, arc_width, notch, width, height, marble_nut, marble_y=od/2-arc_width/2, side_marbles_y=side_marbles_y, side_marbles_x=side_marbles_x, screw=true);
    // }
}

// main_arc(marble_nut=13);

module long_link(length=gondola_length) {

    HSL(h=120,s=0.5,l=0.5)
    difference() {
        cuboid([arc_width, length, thickness], anchor=BOTTOM);
        

        h_notch_size = [notch, thickness, 2*thickness];
        fwd(length/2-thickness/2-thickness)
        right(arc_width/2-notch/2)
            cuboid(h_notch_size, anchor=BOTTOM);
        
        yflip()
        fwd(length/2-thickness/2-thickness)
        right(arc_width/2-notch/2)
            cuboid(h_notch_size, anchor=BOTTOM);
    }

}

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

module long_link2(length=gondola_length, notch=notch) {
    
    screw_length = 20;

    HSL(h=120,s=0.5,l=0.5)
    diff("screw")
    long_link2_body(arc_width=arc_width, length=length, notch=notch) {
        // screw holes
        attach([FRONT, BACK], overlap=0) up(thickness) cuboid([thickness, 2*thickness, screw_length], anchor=TOP, $tags="screw"){
            cuboid([m3_nut_S, 2*thickness, m3_nut_height]);
        };
    };
}

// long_link2();

module long_link_notch(length, width) {
    h_notch_size = [width-notch, thickness, 2*thickness];
    fwd(length/2-thickness/2-thickness)
    right(width/2-h_notch_size[0]/2)
        cuboid(h_notch_size, anchor=BOTTOM);
    
    fwd(length/2-thickness/2)
    right(width/2)
        cuboid(h_notch_size, anchor=BOTTOM);
}

module long_link_screw_notch(length, width, screw_notch=20, screw_pos=40) {
    fwd(screw_pos) {
        right(width/2-screw_notch/2)
        cuboid([screw_notch, thickness, 2*thickness], anchor=BOTTOM);
        
        right(width/2-screw_notch/4)
        cuboid([m3_nut_height, m3_nut_S, 2*thickness], anchor=BOTTOM);

        right(width/2-screw_notch/2)
        cuboid([m3_nut_height, m3_nut_S, 2*thickness], anchor=BOTTOM);
        
        right(width/2-3*screw_notch/4)
        cuboid([m3_nut_height, m3_nut_S, 2*thickness], anchor=BOTTOM);
    }
}

module long_link_notches(length, width, screw_pos) {
    long_link_screw_notch(length=length, width=width, screw_pos=screw_pos);
    long_link_notch(length=length, width=width, screw_pos=screw_pos);
}

module long_link_screw_notch_holder(screw_pos, length, width, screw_holder_width=15) {
    fwd(screw_pos)
    up(thickness)
    difference() {
        cuboid([width, screw_holder_width, thickness], anchor=BOTTOM);
        long_link_screw_notch(length=length, width=width, screw_pos=0);
    }

    fwd(screw_pos)
    up(thickness)
    yrot(90) {
        screw_height = 30;
        screw("M3", thread="none", head="pan", drive="phillips",length=screw_height);
        up(9)
        nut("M3", m3_nut_S, m3_nut_height);
    }
}

module long_link_top(length=gondola_length, width=1.5*arc_width, screw_pos=40) {

    HSL(h=120,s=0.5,l=0.5)
    difference() {
        cuboid([width, length, thickness], anchor=BOTTOM);
        
        long_link_notches(length=length, width=width, screw_pos=screw_pos);
        yflip()
        long_link_notches(length=length, width=width, screw_pos=screw_pos);
    }
    screw_holder_width = 15;

    long_link_screw_notch_holder(screw_pos, length, width, screw_holder_width);
    yflip()
    long_link_screw_notch_holder(screw_pos, length, width, screw_holder_width);
}

module holder_end(width=holder_width, height=holder_height, length=170, prism_width=50, prism_height=40, prism_base=0, notch=holder_notch, notch_zpos=thickness, center_notch=false) {
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
            fwd(-height/2)
            xrot(90)
            prismoid(size1=[prism_width,2*thickness], size2=[prism_base,2*thickness], h=prism_height, $tags="remove");
        }
}

module holder(length=holder_length, height=holder_height) {
    // render(){
        fwd(2*thickness + holder_margin)
        holder_end(height=height);

        fwd(2*thickness + holder_margin + holder_spacing/2)
        zrot(180)
        holder_end(height=height);

        fwd(2*thickness + holder_margin + holder_spacing)
        zrot(180)
        holder_end(height=height);

        fwd(length/2 + 2*thickness)
        right(holder_width/2-holder_notch)
        up(2*thickness)
        yrot(180)
        long_link(length=length);

        xflip()
        fwd(length/2 + 2*thickness)
        right(holder_width/2-holder_notch)
        up(2*thickness)
        yrot(180)
        long_link(length=length); 
    // }
}

module wheel1(thickness=7.5, diameter=wheel_diameter, rail_depth=4, rail_thickness=3.279) {
    cyl(l=thickness, r=diameter/2-rail_depth) {
        attach(BOTTOM, overlap=0) cyl(l=(thickness-rail_thickness)/2, r=diameter/2, anchor=TOP);
        attach(TOP, overlap=0) cyl(l=(thickness-rail_thickness)/2, r=diameter/2, anchor=TOP);
    };
}


module trolley_tube(wheel_diameter=wheel_diameter, inner_diameter=wheel_diameter/3, height=30, mini_wheel_diameter=20, mini_wheel_space=4, mini_wheel_pos=20, mini_wheel_notch=false, assembly_notch=false) {
    difference() {
        cyl(l=thickness, r=wheel_diameter/2) {
            cube_height = wheel_diameter/2 + height;
            fwd(cube_height/2)
            cuboid([wheel_diameter, cube_height, thickness]);
        };
        cyl(l=thickness, r=inner_diameter/2);

        fwd(mini_wheel_pos)
        cuboid([mini_wheel_diameter, mini_wheel_space, 2*thickness]);

        if(mini_wheel_notch) {
            fwd(mini_wheel_pos+mini_wheel_space/2+1.5*thickness)
            cuboid([mini_wheel_diameter, thickness, 2*thickness]);
            
            fwd(mini_wheel_pos-mini_wheel_space/2-1.5*thickness)
            cuboid([mini_wheel_diameter, thickness, 2*thickness]);
        }

        if(assembly_notch) {
            notch_length = 7.5;
            notch_thickness = 2*thickness;
            fwd(wheel_diameter/2 + height - notch_length/2)
            #cuboid([notch_thickness, notch_length, 2*thickness]);
        }
    }
}

module trolley_tube2(wheel_diameter=wheel_diameter, inner_diameter=wheel_diameter/3, interval_between_wheels=30, top_wheel_center_to_top=30, assembly_notch=false, notch_thickness=2*thickness, notch_length=7.5) {
    difference() {
        cube_height = top_wheel_center_to_top;

        cyl(l=thickness, r=wheel_diameter/2) {
            fwd(interval_between_wheels/2)
            cuboid([wheel_diameter, interval_between_wheels, thickness]);

            fwd(interval_between_wheels+cube_height/2)
            cuboid([wheel_diameter, cube_height, thickness]);
        };
        cyl(l=thickness, r=inner_diameter/2);

        fwd(interval_between_wheels)
        cyl(l=thickness, r=inner_diameter/2);

        if(assembly_notch) {
            fwd(interval_between_wheels + cube_height - notch_length/2)
            cuboid([notch_thickness, notch_length, 2*thickness]);
        }
    }
}

module trolley_tubes(wheel_diameter=wheel_diameter, inner_diameter=wheel_diameter/3, interval_between_wheels=30, top_wheel_center_to_top=30, assembly_notch=false, notch_thickness=2*thickness, notch_length=7.5) {
    trolley_tube2(wheel_diameter=wheel_diameter, inner_diameter=inner_diameter, interval_between_wheels=interval_between_wheels, top_wheel_center_to_top=top_wheel_center_to_top, assembly_notch=assembly_notch, notch_thickness=notch_thickness, notch_length=notch_length);
    up(thickness)
    trolley_tube2(wheel_diameter=wheel_diameter, inner_diameter=inner_diameter, interval_between_wheels=interval_between_wheels, top_wheel_center_to_top=top_wheel_center_to_top, assembly_notch=false, notch_thickness=notch_thickness, notch_length=notch_length);
}

module wheel_axe(wheel_center_to_side = 12) {

    wheel_thickness = 7.5;
    axe_length = wheel_center_to_side + wheel_thickness / 2;
    
    wheel1(thickness=wheel_thickness, diameter=wheel_diameter);
    
    inner_diameter = wheel_diameter/3;

    up(wheel_thickness/2-axe_length/2)
    cyl(l=axe_length, r=inner_diameter/2-0.3);
}

// wheel_axe();

module trolley_tube_wheel() {
    interval_between_wheels = 30;

    up(thickness/2)
    trolley_tubes(interval_between_wheels=interval_between_wheels, assembly_notch=true);

    wheel_center_to_side = 12;

    up(wheel_center_to_side) {
        wheel_axe(wheel_center_to_side);
    }
    
    fwd(interval_between_wheels)
    up(wheel_center_to_side) {
        wheel_axe(wheel_center_to_side);
    }
}

// trolley_tube_wheel();


module mini_wheel_axe_holder(wheel_diameter, wheel_thickness, mini_wheel_diameter, mini_wheel_margin, screw_axe_pos) {
    difference() {
        screw_axe_to_external_trolley_tube = screw_axe_pos-4*thickness;
        cuboid([wheel_diameter+mini_wheel_margin, 2*thickness+2*screw_axe_to_external_trolley_tube, thickness]);
        cyl(l=2*thickness, r=3/2, $fs=1);
    }
}

module trolley(wheel_thickness=7.5, wheel_diameter=wheel_diameter) {
    render(){
        wheel1(thickness=wheel_thickness, diameter=wheel_diameter);
        
        inner_diameter = wheel_diameter/3;

        axe_thickness = 8;
        down(wheel_thickness/2+axe_thickness/2)
        cyl(l=axe_thickness, r=inner_diameter/2-0.3);

        trolley_height = 40;
        
        mini_wheel_diameter = 20;
        mini_wheel_thickness = 4;
        mini_wheel_pos = trolley_height/3;
        screw_height = 24;
        mini_wheel_margin = 3;

        down(2.5*thickness)
        
        trolley_tube(wheel_diameter=1.5*wheel_diameter, inner_diameter=inner_diameter, height=trolley_height, mini_wheel_diameter=mini_wheel_diameter+mini_wheel_margin, mini_wheel_space=mini_wheel_thickness+mini_wheel_margin/2, mini_wheel_pos=mini_wheel_pos+mini_wheel_thickness/2+2*thickness, assembly_notch=true);

        down(3.5*thickness)
        difference() {
            trolley_tube(wheel_diameter=1.5*wheel_diameter, inner_diameter=inner_diameter, height=trolley_height, mini_wheel_diameter=mini_wheel_diameter+mini_wheel_margin, mini_wheel_space=mini_wheel_thickness+mini_wheel_margin/2, mini_wheel_pos=mini_wheel_pos+mini_wheel_thickness/2+2*thickness, mini_wheel_notch=true);
            screw_hole_height = (trolley_height+wheel_diameter/2);
            fwd(mini_wheel_pos+screw_hole_height/2-2*thickness)
            cuboid([2*3, screw_hole_height, 2*thickness]);
        }

        // mini_wheel_ensemble:
        screw_axe_pos = 2*thickness+mini_wheel_diameter/2;
        down(screw_axe_pos)
        fwd(mini_wheel_pos)
        xrot(90) {
            
            // mini_wheel:
            up(2*thickness) {
                tube(h=4, od=8, id=3, $fa=1, $fs=1);
                up(0.5)
                tube(h=thickness, od=wheel_diameter, id=8, $fa=1, $fs=1);
            }

            // screw:
            up(-thickness) {
                screw("M3", thread="none", head="pan", drive="phillips",length=screw_height);
                nut("M3", 5.5, 2.4);

                up(1.25*thickness)
                mini_wheel_axe_holder(wheel_diameter, wheel_thickness, mini_wheel_diameter, mini_wheel_margin, screw_axe_pos);

                up(2*thickness)
                nut("M3", 5.5, 2.4);
                up(5*thickness)
                nut("M3", 5.5, 2.4);
                
                up(6.1*thickness)
                mini_wheel_axe_holder(wheel_diameter, wheel_thickness, mini_wheel_diameter, mini_wheel_margin, screw_axe_pos);

                up(7*thickness)
                nut("M3", 5.5, 2.4);
            }
            
        }
    }
    
}

// trolley();

wing_height = gondola_length;
wing_width = 20;

module wing(width=20, height=130, length=180, ear=15) {

    points = [[0,0,0], [0,width,0], [length/2,height,0], [length/2,height-width,0], [0,0,0]];
    
    left(length/2)
    union() {
        linear_extrude(thickness)
            polygon(polyRound(points, 20));
        translate([-ear,0,0])
        cube([ear,width,thickness]);
    }

}

module wings(width=20, height=130, length=180, ear=15) {
    wing(width, height, length, ear);
    xflip()
    wing(width, height, length, ear);
}
// main_arc(marble_nut=13, side_marbles_y=16, side_marbles_x=2);
module three_d() {

    fwd(2*thickness)
    zrot(180)
    xrot(90)
    main_arc();


    fwd(gondola_length-2*thickness)
    xrot(90)
        main_arc(marble_nut=13);

    // render(){
        // H links
        up(thickness)
        right(gondola_outer_diameter/2-arc_width/2)
        xflip()
        fwd(gondola_length/2)
        long_link2(gondola_length-4*thickness);

        xflip()
        up(thickness)
        right(gondola_outer_diameter/2-arc_width/2)
        xflip()
        fwd(gondola_length/2)
        long_link2(gondola_length-4*thickness);

        // V links
        up(gondola_height-arc_width/2)
        right(gondola_width/2-thickness/2)
        yrot(90)
        fwd(gondola_length/2)
        // long_link_top(gondola_length, 1.5*arc_width, 40);
        long_link2(gondola_length-4*thickness);

        xflip()
        up(gondola_height-arc_width/2)
        right(gondola_width/2-thickness/2)
        yrot(90)
        fwd(gondola_length/2)
        // long_link_top(gondola_length, 1.5*arc_width, 40);
        long_link2(gondola_length-4*thickness);
    // }

    // up(holder_height)
    // yrot(180)
    fwd(gondola_length/2)
    holder_simple();

    wheel_center_to_side = 12;

    right(gondola_outer_diameter/2-arc_width-wheel_diameter/2)
    up(15)
    fwd(-wheel_center_to_side+3*thickness/2)
    yrot(-105)
    xrot(90) {
        // trolley();
        trolley_tube_wheel();
    }

    fwd(gondola_length-3*thickness)
    right(gondola_outer_diameter/2-arc_width-wheel_diameter/2)
    up(15)
    fwd(1.5*thickness)
    yrot(-105)
    zrot(180)
    xrot(90) {
        // trolley();
        trolley_tube_wheel();
    }

    right(gondola_outer_diameter/2-arc_width-wheel_diameter/2 + 50)
    xflip()
    up(25)
    fwd(gondola_length/2)
    yrot(15)
    zrot(90)
    wings(length=gondola_length-6*thickness, ear=8*thickness, width=25);

    fwd(gondola_length/2)
    up(50+thickness)
    body();

    fwd(gondola_length-2*thickness)
    up(gondola_outer_diameter/2-arc_width/2)
    xrot(90)
    marble();

    // Plateau
    // slider_width = 30;
    // slider_offset_x = 26;

    // left(slider_offset_x)
    // up(gondola_height-arc_width/2-20)
    // fwd(gondola_length/2)
    // cuboid([slider_width, gondola_length-4*thickness, thickness], anchor=BOTTOM);
    
    // xflip()
    // left(slider_offset_x)
    // up(gondola_height-arc_width/2-20)
    // fwd(gondola_length/2)
    // cuboid([slider_width, gondola_length-4*thickness, thickness], anchor=BOTTOM);

    // fwd(20)
    // up(gondola_height+10)
    // xrot(180)
    // servo9g();

    // // cuboid([gondola_width, gondola_length-4*thickness, thickness], anchor=BOTTOM);

    // holder_magnet_plate_width = 20;
    // holder_magnet_top_width = 30;

    // up(gondola_height-arc_width/2-20)
    // fwd(gondola_length/2)
    // union() {
    //     cuboid([holder_magnet_plate_width, gondola_length-4*thickness, thickness], anchor=BOTTOM);
    //     up(thickness)
    //     cuboid([holder_magnet_top_width, gondola_length-4*thickness, thickness], anchor=BOTTOM);
    // }
}

module holder_simple(length=150, width=20, height=50, end_pos=30) {
    render() {
        up(height-thickness)
        cuboid([width, length, thickness], anchor=BOTTOM);
        
        fwd(length/2-end_pos)
        up(height)
        zflip()
        holder_end(height=height, center_notch=true, notch=width);

        yflip()
        fwd(length/2-end_pos)
        up(height)
        zflip()
        holder_end(height=height, center_notch=true, notch=width);
    }
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

module ear_holder_dovetail(dx, dy, dz, dt_width, dt_spacing, n) {

    diff("remove")
    cuboid([dx, dy, dz], anchor=BOTTOM){
        attach(BACK) xcopies(dt_spacing, n) dovetail("female", angle=0, slide=dz, width=dt_width, height=dz, $tags="remove");

        attach(FRONT) xcopies(dt_spacing, n) dovetail("female", angle=0, slide=dz, width=dt_width, height=dz, $tags="remove");
    }
}

module servo_case_side(dx, dy, dz, dt_width, dt_spacing, n) {

    cuboid([dx, dy, dz], anchor=BOTTOM){
        attach(BOTTOM) xcopies(dt_spacing, n) dovetail("male", angle=0, slide=dy, width=dt_width, height=dy);
        attach(TOP) xcopies(dt_spacing, n) dovetail("male", angle=0, slide=dy, width=dt_width, height=dy);
    }
}

module servo_gears(teeth1 = 16, teeth2 = 16, pitch = 5) {
    // tube(h=thickness, od=20, id=4.6);
    // rack(pitch=5, teeth=10, thickness=5, height=5, pressure_angle=20);

    
    thick = thickness; helical = 0;
    pr = pitch_radius(pitch=pitch, teeth=teeth2); // 12.7324
    down(pr) {

        right(pr*2*PI/teeth2*$t) rack(pitch=pitch, teeth=teeth1, thickness=thick, height=5, helical=helical);
        up(pr) yrot(180.0-$t*360/teeth2)
        spur_gear(pitch=pitch, teeth=teeth2, thickness=thick, helical=helical, shaft_diam=5, orient=BACK);
    }

}
// servo_gears();

// module servo_gears2(teeth1 = 16, teeth2 = 16, pitch = 5, i=0) {
//     // tube(h=thickness, od=20, id=4.6);
//     // rack(pitch=5, teeth=10, thickness=5, height=5, pressure_angle=20);

    
//     thick = thickness; helical = 0;
//     pr = pitch_radius(pitch=pitch, teeth=teeth2); // 12.7324
//     down(pr) {

//         // right(pr*2*PI/teeth2*$t)
//         length = pitch*teeth1;
//         right(-length/2+i*length)
//         rack(pitch=pitch, teeth=teeth1, thickness=thick, height=5, helical=helical);
//         up(pr) yrot(-360.0*i+180.0-$t*360/teeth2)
//         difference() {
//             spur_gear(pitch=pitch, teeth=teeth2, thickness=thick, helical=helical, shaft_diam=5, orient=BACK);
//             translate([-pr, -thickness/2, pr-2])
//             #cube([2*pr, thickness, 5]);
//         } 
//     }

// }

// ni = 5.0;
// for( i = [0 : ni]) {
//     fwd(60*i/ni)
//     servo_gears2(16,16,5,i/ni);
// }

module servo_case_raw(width=70, length=40) {

    y_offset = 15;
    
    teeth1 = 16; 
    teeth2 = 16;
    pitch = 5; 
    fwd(y_offset) {
        servo9g();

        // Gear

        left(22.5/2-11.8/2)
        up(26.7)
        xrot(90)
        servo_gears(teeth1, teeth2, pitch);
    }

    // Ear holder
    servo_width = 11.8;
    servo_length = 22.5;
    ear_holder_y = 15.9 + 2.5;

    ear_holder_length = length; //servo_length + 2 * 20;
    ear_holder_width = width; //servo_width + 2 * 30;
    
    dovetail_spacing = 20;
    dovetail_width = 10;
    n_dovetails = 2;

    HSL(120,50,50)
    up(ear_holder_y)
    difference() {
        // cuboid([ear_holder_length, ear_holder_width, thickness], anchor=BOTTOM);
        ear_holder_dovetail(ear_holder_length, ear_holder_width, thickness, dovetail_width, dovetail_spacing, n_dovetails);
        fwd(y_offset) {
            cuboid([servo_length+1, servo_width+1, 2*thickness], anchor=BOTTOM);

            left(servo_length/2+4.7-2.3)
            cyl(l=2*thickness, r=1, $fs=1);

            right(servo_length/2+4.7-2.3)
            cyl(l=2*thickness, r=1, $fs=1);
        }
    };

    side_height = 10;

    up(ear_holder_y+thickness) {
        fwd(ear_holder_width/2-thickness/2)
        servo_case_side(ear_holder_length, thickness, side_height, dovetail_width, dovetail_spacing, n_dovetails);
        back(ear_holder_width/2-thickness/2)
        servo_case_side(ear_holder_length, thickness, side_height, dovetail_width, dovetail_spacing, n_dovetails);
    }

    
}

// servo_case_raw();

module servo_case(width=70, length=40) {
    up(34)
    xrot(180) {
        servo_case_raw(width=width, length=length);
    }
}


// module dovetail_board(dx, dy, dz, males, females, n_fingers, spacing=-1) {
//     if(spacing < 0) {
//         spacing = 
//     }
//     diff("remove")
//     cuboid([dx, dy, dz]){
//         for (f=males) {
//             attach(f) xcopies(20,2) dovetail("male", angle=0, slide=dz, width=10, height=thickness);
//         }
//         attach(FRONT) xcopies(20,2) dovetail("male", angle=0, slide=thickness, width=10, height=thickness);

//         attach(FRONT) xcopies(20,2) dovetail("female", angle=0, slide=thickness, width=10, height=thickness,$tags="remove");
//     }
// }

// dovetail_board(10,10,10, 3, [TOP,LEFT], [RIGHT, BACK])


module body_slider(slider_width, servo_case_width, slider_offset_x) {
    diff("remove")
    cuboid([slider_width, gondola_length-4*thickness, thickness], anchor=BOTTOM){
        left(servo_case_width/2-slider_offset_x-thickness/2) zrot(90) attach(TOP) xcopies(20, 2) dovetail("female", angle=0, slide=thickness, width=10, height=thickness, $tags="remove");
    }
}

module body() {

    slider_width = 30;
    slider_offset_x = 26;
    
    servo_case_width = 70;
    servo_case_length = 40;

    // 2 sliders
    left(slider_offset_x)
    body_slider(slider_width, servo_case_width, slider_offset_x);
    

    xflip()
    left(slider_offset_x)
    body_slider(slider_width, servo_case_width, slider_offset_x);
    // cuboid([slider_width, gondola_length-4*thickness, thickness], anchor=BOTTOM);

    zrot(90)
    servo_case(width=servo_case_width, length=servo_case_length);

    // holder_magnet

    holder_magnet_plate_width = 20;
    holder_magnet_top_width = 30;

    union() {
        cuboid([holder_magnet_plate_width, gondola_length-4*thickness, thickness], anchor=BOTTOM);
        up(thickness)
        cuboid([holder_magnet_top_width, gondola_length-4*thickness, thickness], anchor=BOTTOM);
    }
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

// marble();


fwd(-gondola_length/2) three_d();


// Todo
// - marble
// - better troley
// - fix arc
// - finish body:
//   - replace screws by notches
//   - slide stop
//   - design magnets
//   - hold case with screws
// - small pen holder
// - targets
// - weights

// V2
// - add solenoid

// V3
// - put motors on the wings

// V4
// - multiple pens on the gondola

