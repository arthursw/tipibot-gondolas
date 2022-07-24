include <BOSL2/nema_steppers.scad>

// General
thickness = 3;

// Gondolami
gondola_length = 120;
arc_bottom_height = 40;
ground_to_pen_center = arc_bottom_height;

// Body
body_z = 20;
body_length = gondola_length - 6 * thickness;
magnet_blocker_length = 15;
blocker_margin = 5;

// Pen
pen_diameter = 15.5;
pen_length = 112;
pen_cap_length = 29;
pen_cap_diameter = 15;

// Nema
nema17_width = nema_motor_width(17);

// Ground station
case_width = nema17_width + 4*thickness;

// Pen holder
pen_case_margin = 2; //50;
pen_holder_legs_spacing = 30;
magnet_spacing = 10;
magnet_size = 3;
n_magnets = 4;
// pen_holder_length = pen_length;
pen_holder_length = body_length - magnet_blocker_length - blocker_margin;
pen_holder_width = 40;
pen_holder_bottom_margin = 5;
pen_holder_case_margin = 3;
pen_holder_bottom_width = case_width + 2 * pen_holder_case_margin + 2 * pen_holder_bottom_margin;
case_to_pen_center = pen_diameter / 2 + pen_case_margin + 3;
pen_holder_bottom_height = ground_to_pen_center - case_to_pen_center + pen_holder_bottom_margin + pen_holder_case_margin;
pen_holder_bottom_hole_width = case_width + 2 * pen_holder_case_margin;
pen_holder_bottom_hole_height = ground_to_pen_center - case_to_pen_center + pen_holder_case_margin;
pen_holder_height = ground_to_pen_center + body_z;

sliding_magnet_width = 15;
comb_notch = 2 * thickness;

command_gs = "";

marble_nut = 10;
m3_diameter = 3;
m3_radius = 3/2;
m3_nut_height = 2.4;
m3_nut_S = 5.5;
m3_nut_e = 6.01;
m3_screw_head_diameter = 5.5;