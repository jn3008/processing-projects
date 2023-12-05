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
 
// torus / sphere
//
// move mouse up and down to control mesh geometry detail
// top of canvas : looks bad, fast
// bottom of canvas : looks good, slow

boolean preview = true,
    flip_dir = false;

int n_frames = 180;
    
float t, c, scale, ang,
    R, r, sphere_r,
    col1 = 25, col2 = 250;
    
PGraphics G;

void setup() {
    size(1200, 900, P3D);
    G = createGraphics(width, height, P3D);
    R = 232; // major radius of torus
    r = R*0.4; // minor radius of torus
    sphere_r = sq(R-r)/(R+r); // radius of sphere
    G.sphereDetail(30);

    G.smooth(8);
}

void draw() {
    G.beginDraw();
    G.noStroke();
    G.ortho();
    G.translate(width/2, height/2);
    
    t = preview ? (millis()/(20.0*n_frames))%1 : mouseX*1.0/width;
    c = mouseY*1.0/height;
    float detail = lerp(0.2, 0.9, c);

    // while t goes from 0 to 1 once, q does it twice
    float q = (2*t)%1; 

    // boolan value used for inverting colours etc.
    // true for the first half, false for second half
    boolean interval = 2*t<1; 

    float pct = map(cos(TAU*ease(q, 0.8)), 1, -1, 1, interval?0.35:0);
    
    G.background(interval?col1:col2);
    G.fill(interval?col2:lerp(col1, 65, pow(1-pct, 1)));
    // G.stroke(255, 0, 0); //un-comment this line to see the mesh faces

    //torus made by revolving a circle of radius r along the circumference of a larger circle of radius R
    scale = pow((R+r)/(R-r), q);

    // basic shading
    my_lights(pct);
    torus_mesh(R*scale, r*scale, detail, interval?1:flip_dir?-1:1, q);

    if (2*q > 1) //sphere appears after the donut has completed a 1/4 revolution about the x-axis
        G.sphere(sphere_r*scale);

    G.noLights();
    G.endDraw();
    // draw PGraphics G in main canvas
    image(G, 0, 0); 
}

void torus_mesh(float R, float r, float detail, int rotate_direction, float q) {
    int nR = round(500*detail); //number of segments on the circle R
    int nr = round(400*detail); //number of segments on the circle r

    for (int i = 0; i < nR; i++) {
        //draw mesh by making triangle strips
        G.beginShape(TRIANGLE_STRIP);

        for (int j = 0; j <= nr; j++) {
            //angle on the circle r            
            float ang_r = (j)*TAU/nr;

            for (int k = 0; k < 2; k++) {
                //angle on the circle R
                float ang_R = (i+k)*TAU/nR;
                float R_ = R-r*cos(ang_r);

                PVector v = new PVector(R_*cos(ang_R), R_*sin(ang_R), r*sin(ang_r));
                // rotate torus about x-axis
                v = rotX(v, -PI*ease(q, 1.25)*rotate_direction);
                vertex(v);
            }
        }
        G.endShape();
    }
}

void vertex(PVector v) {
    G.vertex(v.x, v.y, v.z);
}

void my_lights(float q) {
    float k = 255;
    G.ambientLight(q*k, q*k, q*k);
    G.directionalLight((1-q)*k, (1-q)*k, (1-q)*k, 0, 0, -1);
    G.lightFalloff(1, 0, 0);
    G.lightSpecular(0, 0, 0);
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