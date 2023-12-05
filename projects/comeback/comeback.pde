/*
 * This work (c) 2023 by jn3008 is licensed under the Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License (CC BY-NC-ND 4.0).
 * 
 * You may view, share, and redistribute this code with attribution for non-commercial purposes,
 * but you may not modify or use it to create derivative works.
 * 
 * License: https://creativecommons.org/licenses/by-nc-nd/4.0/
 * Contact: jn3008@proton.me
 */
 
// come back
//
// move mouse up and down to control mesh geometry detail
// top of canvas : looks bad, fast
// bottom of canvas : looks good, slow
    
boolean preview = true,
    reverse = true,
    colourise = true;

float t, tt, c,
    l = 120, k = 0.4;
    
color c1 = #1c0009,
    c2 = #c70038;

int n_frames = 200;

//////////////////////////////////////////////////////////////////////////////

void setup() {
    size(720, 720, P2D);
    smooth(8);
    blendMode(EXCLUSION);
    fill(255);
    noStroke();
}

void draw() {
    t = preview?(millis()/(20.0*n_frames))%1:mouseX*1.0/width;
    if (reverse) t = 1-t;
    c = mouseY*1.0/height;

    background(0);
    translate(width/2, height/2);

    rotate(-TAU*t/4);
    float q = (2*t)%1;
    scale(pow(3, q));

    int m = 0; // add layers that show a trail with stronger ease
    for (int i = 0; i < 1+2*m; i++)
        draw_shape(floor(2*t), ease(q,1+0.3*i*c));

    if (colourise) do_colours();
}

void draw_shape(int idx, float q) {
    for (int i = 0; i < 4; i++) {
        float A = map(k, 0, 1, (i*1.0+0.5)/4, 0.5);
        float B = map(k, 0, 1, 0.5/4, 0.5);
        float qq = ease(c01(map(q, A-B, A+B, 0, 1)), 2);
        push();
        rotate(HALF_PI*i+HALF_PI);
        translate(-l/2, -l/2 + l*qq*idx);
        if (idx == 0) rotate(HALF_PI*qq);
        float X = l*(1.0-qq/3);
        float Y = -l;
        beginShape();
        vertex(0, 0);
        vertex(0, idx==0?-X:Y);
        vertex(idx==0?-Y:X, idx==0?-X:Y);
        vertex(idx==0?-Y:X, 0);
        endShape(CLOSE);
        pop();
    }
}

void do_colours() {
    // map grayscale pixels to an interpolation
    // of two different colours
    loadPixels();
    for (int i = 0; i < width*height; i++)
        pixels[i] = lerpColor(c1, c2, brightness(pixels[i])*1.0/255);
    updatePixels();
}

float ease(float p, float g) {
    if (p < 0.5)
        return 0.5 * pow(2*p, g);
    else
        return 1 - 0.5 * pow(2*(1 - p), g);
}

float c01(float g) {
    return constrain(g, 0, 1);
}