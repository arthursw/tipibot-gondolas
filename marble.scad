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
