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

module nema17_axe() {
    nema17_axe_diameter = 5;
    back_half(y=-4/2)
    cyl(r=nema17_axe_diameter/2, l=10);
}

module bead() {
    cyl(r=bead_diameter/2, l=2*thickness);

    xrot(90)
    prismoid(size1=[bead_diameter, 2*thickness], size2=[1.5*bead_diameter, 2*thickness], h=bead_diameter);
    // cuboid([bead_diameter, bead_diameter, 2*thickness]);
}

// bead();
module pulley_middle() {
    difference() {
        cyl(r=pulley_chain_radius, l=thickness);

        zrot_copies(n=pulley_n_intervals)
        fwd(pulley_radius)
        bead();

        // Formula taken from https://www.mathopenref.com/polygonsides.html
        side = 2 * pulley_radius * sin(180 / pulley_n_intervals);

        zrot(180/pulley_n_intervals)
        zrot_copies(n=pulley_n_intervals/2)
        fwd(pulley_radius)
        cuboid([side, bead_diameter, 2*thickness]);

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
// pulley_middle();
module pulley() {
    pulley_middle();
    mirror_copy(TOP, thickness)
    pulley_side();
}

pulley();

module pulley_2D() {
    pulley_middle();

    fwd(2*pulley_radius-8)
    mirror_copy(LEFT, 2*pulley_radius)
    pulley_side();
}