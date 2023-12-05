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
 
// petal cytokinesis
//
// 
// I must admit this code was horrendous when I rediscovered it, so bad that
// it felt like it was encrypted. Anyway I've re-written basically all of it 
// so that it's a bit more readable. 

boolean preview = true, 
    reverse = false;

float t, c;

int n_frames = 130;

float R = 25, cytokinesis_duration = 0.98;

color col1 = #838900,
    col2 = #d1667b,
    bg = #E3E7D3;

//////////////////////////////////////////////////////////////////////////////

void setup() {
    size(720, 720, P2D);
    smooth(8);
    noStroke();
}

void draw() {
    t = preview?(millis()/(20.0*n_frames))%1:mouseX*1.0/width;
    if (reverse) t = 1-t;
    c = mouseY*1.0/height;

    background(bg);
    translate(width*0.5, height*0.5);

    float global_scale = pow(sqrt(2), t);
    float global_angle = QUARTER_PI*t;
    
    int n = 7;

    for (int depth = 0; depth < 3; depth++) {
        // loop through 'depths', i.e. blobs of different
        // sizes. change the length of the loop to understand
        // the difference.

        float scale = pow(sqrt(2)*0.5, depth) * global_scale;
        float ang = QUARTER_PI*depth - global_angle;
        
        for (int a = -n; a < n; a++) {
            for (int b = -n; b < n; b++) {
                // simple 2d grid loop

                int type = abs(a+b)%2; // dictates the colour/orientation of the blob
                fill(type==0?col1:col2);

                PVector p = new PVector(a+0.5, b+0.5).mult(4*R*scale).rotate(ang);
                float time_offset = p.mag()/width * 1.25; // time offset based on distance from center
                float q = t + 0.1 - depth + time_offset;

                draw_cytokinesis(q, 2*R*scale, R*scale, p, type*HALF_PI + ang);
            }
        }
    }
}

void draw_cytokinesis(float q, float max_sep, float rad, PVector center, float ang) {
    if (q < -0.2 || q > 1) return;
    q = c01(q/cytokinesis_duration);
    q = 1-q;

    int np = 20;

    for (int a = 0; a < 2; a++) {
        // loop to draw blob on left and right sides
        beginShape();
        for (int b = 0; b < 2; b++)
            for (int i = 0; i <= np; i++) {
                // loop to draw blob on top and bottom,
                // reverse the parameterisation when b == 1
                PVector p = half_blob_boundary(abs(b-i*1.0/np), q, max_sep, rad);
                if (a==1) p.x *= -1;
                if (b==1) p.y *= -1;

                p.rotate(ang);
                p.add(center);
                vertex(p.x, p.y);
            }
        endShape(CLOSE);
    }
}

PVector half_blob_boundary(float u, float q, float max_sep, float rad) {
    // u: paramterises the boundary, q: time paramter which changes the geometry of blob,
    // max_sep: separation between blobs (distance between centers), rad: radius of blob

    // the moment in [0, 1] when the blobs join
    float join_time = 0.21831186;

    // deform time paramter to make for more organic motion
    q = c01(q);
    q = pow(ease(q, lerp(1, 6, q)), 2);

    float q_apart = cmap(q, 0, join_time, 0, 1); // map q to [0, 1] for when the blobs are separate
    float q_joined = cmap(q, join_time, 1, 0, 1); // map q to [0, 1] for when the blobs are joined

    float sep = -max_sep*(1-q); // distance from blob center to origin
    float sep_edge = lerp(sep+rad, 0, q_apart); // distance from blob's deformed edges to origin

    PVector p = new PVector();

    // depending on the stage of the cytokinesis, the parameterised
    // points should be distributed to maintain equidistance
    float param_weight_split = lerp(0.5, 1, q_joined);

    if (u <= param_weight_split) {
        // this is just a semicircle
        p = new PVector(rad, 0).rotate(PI-HALF_PI*map(u, 0, param_weight_split, 0, 1));
        // shift it from origin to the blob's center
        p.x += sep;
    } else {
        // the morphing part of the blob is drawn as a function y = f(x) then it's mirrored along the x-axis to make a single blob, 
        // then mirrored along the y-axis to make two (merging) blobs. This mirroring is handled in the parent function above
        // 
        // first the x parameter is reparameterized so that points are more
        // equidistant in R^2 (rather than being by default equidistant in x-axis only)
        float x = map(u, param_weight_split, 1, 0, 1);
        x = pow_(x, lerp(2, 1, q_apart));

        // before the blobs merge together the function f interpolates from f1 (quarter circle) to f2
        // after touching, f is the function f3 (and scaled linearly too)
        float y = q < join_time ? 
            lerp(f1(x), f2(x), q_apart)
            : lerp(pow_(q_joined, 3), 1, f3(x, q_joined));

        p = new PVector(lerp(sep, sep_edge, x), rad*y);
    } 

    // float q_ = c01(abs(p.x)/(max_sep+rad));
    // float scale_fac = lerp(1, sqrt(2)*lerp(1-pow(q_, 4), 1, pow(ease(q_joined, 2), 3)), pow(q_joined, 2));
    float scale_fac = lerp(1, sqrt(2), pow(q_joined, 2));
    p.mult(scale_fac);
    return p;
}

float f1(float x) {
    return sqrt(abs(1-sq(x)));
}

float f2(float x) {
    return lerp(f1(x), 1-x, x);
}

float f3(float x, float q) {
    return pow(f2(x), 1+(pow_(q, 3)-0.5*pow(q, 3)) * lerp(0, 2, pow(x, 3-2*q)));
}

float ease(float p, float g) {
    if (p < 0.5)
        return 0.5 * pow(2*p, g);
    else
        return 1 - 0.5 * pow(2*(1 - p), g);
}

float cmap(float x, float a0, float b0, float a1, float b1) {
    return max(min(map(x, a0, b0, a1, b1), max(a1, b1)), min(a1, b1));
}

float pow_(float p, float g) {
    return 1-pow(1-p, g);
}

float c01(float g) {
    return constrain(g, 0, 1);
}
