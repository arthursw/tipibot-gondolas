
module squeezer_holder() {
    up(squeezer_holder_y)
    pen_holder(height=squeezer_holder_height, bridge_pos=18);

    up(squeezer_holder_height+squeezer_holder_y)
    fwd(body_length/2)
    yrot(180)
    pen_wedge();
}

// squeezer_holder();

module squeezer_holder_2d() {

    pen_holder_2d(height=squeezer_holder_height, bridge_pos=18);

}

// squeezer_holder_2d();

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

module squeezer_ensemble_2d() {
    squeezer_holder_2d();
}

// squeezer_ensemble_2d();

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