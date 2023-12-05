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
 
// wave spiral
//

boolean preview = false, 
    reverse = false;

float t, tt, c, 
    l = 120, k = 0.4;

color c1 = #042f4b, 
  c2 = #fff6da;

int n_frames = 200;

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
    background(c1);
    fill(c2);

    translate(width/2, height/2);

    float ease_val = 3.8; // ease value
    float N = 7; // number of rings

    float scale = 80;
    float m = 4.1;

    beginShape();
    for (int k = 0; k < 2; k++) {
        for (int j = 0; j < N; j++) {
            int n = 300; // n points per rotation
            for (int i = 0; i < n; i++) {
                float q = (j + i*1.0/n) / N;
                
                if (k == 0) q = 1 - q; // reverse the order once, so that vertices in the total drawn shape are in the correct order
                q = sqrt(q); // reparameterise the curve, otherwise too many points close to center, not enough far from center
                if (q*N < m) q = pow(q*N/m, lerp(2, 1, c01(q*N/m)))*m/N; // in the first rotation, bring points a bit closer to center
                
                float th = TAU*N*q; // static angle, used for the magnitude, and the dynamic angle
                float phi = -th + TAU*t; // dynamic angle
                phi = (ease(phi/TAU - floor(phi/TAU), ease_val) + floor(phi/TAU))*TAU; // ease to bring phi%TAU closer to 0 and TAU, this line does nothing if ease_val = 1
                
                float magnitude = scale/TAU*th;
                PVector v = new PVector(magnitude, 0).rotate(phi + PI*k);
                vert(v.x, v.y);
            }
        }
    }

    // vertices to close the shape
    for (int i = 0; i < 20; i++) {
        float q = i*1.0/20;
        float th = TAU*N;
        float phi = -th + TAU*t; 
        phi = (ease(phi/TAU - floor(phi/TAU), ease_val) + floor(phi/TAU))*TAU;
        PVector v = new PVector(scale/TAU*th, 0).rotate(phi + PI*(1-q));
        vert(v.x, v.y);
    }
    endShape();
}

float scale;

void vert(float x, float y) {
    vertex(x, y);
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