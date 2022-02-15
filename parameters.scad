// General
thickness = 3;

// Gondolami
gondola_length = 120;

// Body
body_z = 20;
body_length = gondola_length - 6 * thickness;
magnet_blocker_length = 15;
blocker_margin = 5;

// Pen
pen_diameter = 15;
pen_length = 112;
pen_cap_length = 29;
pen_cap_diameter = 14;

// Pen holder
pen_holder_legs_spacing = 30;
magnet_spacing = 10;
magnet_size = 3;
n_magnets = 4;
pen_holder_length = pen_length;
pen_holder_length = body_length - magnet_blocker_length - blocker_margin;
pen_holder_width = 40;
pen_holder_height = ground_to_pen_center + body_z;
