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
 
// escher's solid
//
//////////////////////////////////////////////////////////////////////////////

import java.util.HashMap;
import java.util.Map;

boolean preview = true, 
    reverse = false;

float t, c, size = 280;

OpenSimplexNoise noise;
Map<String, Integer> face_colour_dict;

int n_frames = 250;

//////////////////////////////////////////////////////////////////////////////

void setup() {
    size(720, 720, P3D);
    smooth(8);
    noise = new OpenSimplexNoise();
    face_colour_dict = new HashMap<>();

    face_colour_dict.put(get_key(0,-1,0,0), 0);
    face_colour_dict.put(get_key(3,-1,1,0), 0);
    face_colour_dict.put(get_key(0,1,0,0), 0);
    face_colour_dict.put(get_key(3,1,1,0), 0);
    face_colour_dict.put(get_key(0,1,1,1), 0);
    face_colour_dict.put(get_key(1,1,0,1), 0);
    face_colour_dict.put(get_key(2,1,1,1), 0);
    face_colour_dict.put(get_key(3,1,0,1), 0);

    face_colour_dict.put(get_key(2,-1,0,0), 0);
    face_colour_dict.put(get_key(1,1,1,0), 0);
    face_colour_dict.put(get_key(2,1,0,2), 0);
    face_colour_dict.put(get_key(1,-1,1,2), 0);
    face_colour_dict.put(get_key(0,-1,1,1), 0);
    face_colour_dict.put(get_key(0,-1,0,1), 0);
    face_colour_dict.put(get_key(2,-1,1,1), 0);
    face_colour_dict.put(get_key(2,-1,0,1), 0);
    
    face_colour_dict.put(get_key(0,-1,0,2), 1);
    face_colour_dict.put(get_key(3,-1,1,2), 1);
    face_colour_dict.put(get_key(0,1,0,2), 1);
    face_colour_dict.put(get_key(3,1,1,2), 1);
    face_colour_dict.put(get_key(0,1,0,1), 1);
    face_colour_dict.put(get_key(1,1,1,1), 1);
    face_colour_dict.put(get_key(2,1,0,1), 1);
    face_colour_dict.put(get_key(3,1,1,1), 1);

    face_colour_dict.put(get_key(2,1,0,0), 1);
    face_colour_dict.put(get_key(1,-1,1,0), 1);
    face_colour_dict.put(get_key(2,-1,0,2), 1);
    face_colour_dict.put(get_key(1,1,1,2), 1);
    face_colour_dict.put(get_key(1,-1,0,1), 1);
    face_colour_dict.put(get_key(1,-1,1,1), 1);
    face_colour_dict.put(get_key(3,-1,0,1), 1);
    face_colour_dict.put(get_key(3,-1,1,1), 1);
    
    for (int i = 0; i < 4; i++)
        for (int j = -1; j <= 1; j+=2)
            for (int k = 0; k < 2; k++)
                for (int l = 0; l < 3; l++)
                    if (!face_colour_dict.containsKey(get_key(i,j,k,l)))
                        face_colour_dict.put(get_key(i,j,k,l), 2);
}

void draw() {
    t = preview?(millis()/(20.0*n_frames))%1:mouseX*1.0/width;
    if (reverse) t = 1-t;
    c = mouseY*1.0/height;

    background(250);
    translate(width*0.5, height*0.5);
    rotate(-PI*0.75*t);
    scale(pow(sqrt(2), t));

    draw_obj(t);
}

void vertex(PVector p) {
    vertex(p.x, p.y, p.z);
}

void draw_obj(float q) {
    for (int i = 0; i < 4; i++) {
        for (int j = -1; j <= 1; j+=2) {
            for (int k = 0; k < 2; k++) {
                for (int l = 0; l < 3; l++) {
                    for (int layer = 0; layer < 2; layer++) { // 0: interior layer, 1: exterior layer

                        PVector[] verts = { // vertices of the triangle (face)
                            new PVector(1, 0, 1).mult(size*(layer==0?0.25:0.5)),
                            new PVector(1, 1, 1).mult(size*0.25),
                            new PVector(1*k, 0, 1*(1-k)).mult(size*0.5)
                        };
                        for (int vert_idx = 0; vert_idx < 3; vert_idx++) {
                            PVector v = verts[vert_idx];
                            if (l == 1) // 4 "diamonds" shrink to the origin
                                v.mult(1-(0.99)*ease(q, 3));
                            v.add(new PVector(1, 0, 1).mult(size*tease(q, 2, 0.0)*0.07));

                            v.y *= j;
                            v = rotY(v, i*HALF_PI);

                            if (l == 1) // make shrinking diamonds spin
                                v = rotY(v, -PI*pow(q, 3));

                            if (l == 1) v = rotX(v, HALF_PI);
                            else if (l == 2) v.rotate(HALF_PI);

                            v = rotY(v, ease(q, 2) * -PI);

                            // squish object in z-axis at the loop point,
                            // comment line to see the difference
                            v.z*=0.0002 + 0.5*tease(q, 1.5, 0);
                            verts[vert_idx] = v;
                        }
                        
                        if (layer==0) fill(#1FDEAC);
                        else {
                            int col_idx = face_colour_dict.get(get_key(i,j,k,l));
                            if (col_idx == 0) fill(21);
                            else if (col_idx == 1) fill(250);
                            else {
                                PVector face_center = PVector.add(verts[0],verts[1]).add(verts[2]).div(3);
                                fill(lerpColor(#F5E20C, #F5470C, map((face_center.z-face_center.y)/(size*sqrt(2)), 1, -1, 0, 1)));
                            }
                        }
                        noStroke();

                        // draw faces
                        beginShape();
                        for (PVector vert : verts) vertex(vert);
                        endShape(CLOSE);

                        // draw edge of each triangle on the exterior with noise
                        if (layer == 1) { 
                            noFill();
                            stroke(30);
                            beginShape();
                            int np = 10;
                            for (int vert_idx = 0; vert_idx < 3; vert_idx++) {
                                for (int u = 0; u < np; u++) { // points drawn on each line
                                    PVector point = PVector.lerp(verts[vert_idx], verts[(vert_idx+1)%3], u*1.0/np);
                                    PVector nv = point.copy().mult(0.017);
                                    float noise_val = (float)noise.eval(nv.x, nv.y, nv.z);
                                    float strw = lerp(0, 3, ease(map(noise_val, -1, 1, 0, 1), 3));
                                    strokeWeight(pow(tease(q, 2, 0.4), 8)*strw);
                                    vertex(point);
                                }
                            }
                            endShape(CLOSE);
                        }
                    }
                }
            }
        }
    }
}

String get_key(int i, int j, int k, int l) {
    return String.format("%d%d%d%d",i,j,k,l);
}

float ease(float p, float g) {
    if (p < 0.5)
        return 0.5 * pow(2*p, g);
    else
        return 1 - 0.5 * pow(2*(1 - p), g);
}

PVector rotX(PVector v, float th) {
    return new PVector(v.x, v.y*cos(th)-v.z*sin(th), v.y*sin(th)+v.z*cos(th));
}

PVector rotY(PVector v, float th) {
    return new PVector(v.x*cos(th)+v.z*sin(th), v.y, v.z*cos(th)-v.x*sin(th));
}

float tease(float p, float g, float w) { // w in [0, 1]
    if (2*p + w < 1)
        return ease(map(p, 0, 0.5*(1-w), 0, 1), g);
    else if (2*p > 1 + w)
        return ease(map(p, 0.5*(1+w), 1, 1, 0), g);
    else
        return 1;
}