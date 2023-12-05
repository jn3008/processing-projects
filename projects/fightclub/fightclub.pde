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

float t, c;

int numFrames = 160;

// number of tries to optimise bijections between images
float tries = 1e7; 

// invert colours
boolean inv = true;

PVector[][] positions;

String[] inputString = {"black_durden0.txt", "black_durden1.txt"};
int[][] bijection;
int l;

float global_scale = 0.45,
    ang = TAU*0.05;

ArrayList<Dot> dots;

//////////////////////////////////////////////////////////////////////////////

void setup() {
    size(720, 720, P2D);
    smooth(8);
    ellipseMode(RADIUS);
    rectMode(CENTER);
    noFill();

    String[][] lines = {loadStrings(inputString[0]), loadStrings(inputString[1])};

    println(loadStrings(inputString[0]).length);
    println(loadStrings(inputString[1]).length);

    l = min(lines[0].length, lines[1].length);
    positions = new PVector[lines.length][l];
    PVector dims = new PVector();

    for (int i = 0; i < lines.length; i++) {
        PVector mins = new PVector(Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY);
        PVector maxs = new PVector(Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY);
        for (int j = 0; j < l; j++) {
            String[] res = lines[i][j].split(",");
            float x = parse_float(res[0]);
            float y = parse_float(res[1]);
            if (x < mins.x) mins.x = x;
            if (y < mins.y) mins.y = y;
            if (x > maxs.x) maxs.x = x;
            if (y > maxs.y) maxs.y = y;
        }
        dims.x = max(maxs.x-mins.x, dims.x);
        dims.y = max(maxs.y-mins.y, dims.y);

        int counter = 0;
        for (int j = 0; j < l; j++) {
            String[] res = lines[i][j].split(",");

            float x = parse_float(res[0])-mins.x;
            float y = parse_float(res[1])-mins.y;

            positions[i][counter++] = new PVector(x/dims.x, y/dims.y, parse_float(res[2]));
        }
    }

    int n_checkpoints = 20;
    float checkpoint = 1;
    println("0%");
    background(inv?0:255);
    fill(inv?255:0);

    bijection = new int[2][l];
    for (int k = 0; k < 2; k++) { 
        // calculate two bijections: the first is between
        // image 1 and tranformed image 2, then second between 
        // image 2 and transformed image 1

        boolean[] available = new boolean[l];
        for (int i = 0; i < l; i++) available[i] = true;
        for (int i = 0; i < l; i++) {
            PVector p = positions[1-k][i];
            float min_dist = Float.POSITIVE_INFINITY;
            for (int j = 0; j < l; j++) {
                if (!available[j]) continue;
                PVector other = positions[k][j];

                float d = sq(p.x-other.x)+sq(p.y-other.y);
                if (d < min_dist) {
                    bijection[k][i] = j;
                    min_dist = d;
                }
            }
            available[bijection[k][i]] = false;
        }
        // for (int i = 0; i < l; i++) bijection[k][i] = i;

        for (int i = 0; i < tries; i++) {
            int A = round(random(l-1));
            int B = round(random(l-1));
            if (A==B) continue;

            float dA0 = squareDist(A, bijection[k][A], k);
            float dB0 = squareDist(B, bijection[k][B], k);
            float d0 = dA0+dB0;

            float dA1 = squareDist(A, bijection[k][B], k);
            float dB1 = squareDist(B, bijection[k][A], k);
            float d1 = dA1+dB1;

            if (d1 < d0)
                swap(A, B, bijection[k]);

            if (i*0.5/tries + 0.5*k >= checkpoint*.999/n_checkpoints) {
                int pct = round((checkpoint)*1.0/n_checkpoints*100);
                String bar = "=".repeat(pct) + ">" + space(100 - pct);
                String pct_txt = String.valueOf(pct)+"%%";
                for (int j = 0; j < pct_txt.length(); j++) {
                    int middle = round(bar.length()*0.5);
                    bar = bar.substring(0, middle+j) + pct_txt.charAt(j) + bar.substring(middle+j+1);
                }
                System.out.printf(((char) 0x1b) + "[1B\r[" + bar + "]");
                checkpoint++;
            }
        }
    }

    dots = new ArrayList<Dot>();
    for (int i = 0; i < l; i++)
        dots.add(new Dot(i));
}

String space(int x) {
    return x ==  0 ? "" : " ".repeat(x);
}

void swap(int idx1, int idx2, int[] list) {
    int temp = list[idx1];
    list[idx1] = list[idx2];
    list[idx2] = temp;
}

float parse_float(String s) {
    return Float.parseFloat(s);
}

float squareDist(int a, int b, int k) {
    // returns the square distance between points with indices a
    // and b in images k and 1-k respectively
    PVector pa = positions[k][a];
    PVector pb = positions[1-k][b];
    PVector pc = transform(pb.x, pb.y);
    return sq(pa.x-pc.x)+sq(pa.y-pc.y);
}

PVector transform(float x, float y) {
    // rotate point around the square
    // (rotate around a circle close to the center, rotate around 
    // the boundary of the square near the boundary)
    PVector ret = new PVector(x, y);
    ret.sub(0.5, 0.5);
    ret.mult(2);

    float th = ret.heading();
    float amt = c01(ret.mag());
    ret.rotate(-ang);
    ret.mult(lerp(1, sqrBoundDist(th-ang)/sqrBoundDist(th-ang), pow(amt, 10)));

    ret.div(2);
    ret.add(0.5, 0.5);
    return ret;
}

float sqrBoundDist(float th) {
    // distance from a point on the boundary of a 
    // square [-1, 1]^2 to the origin, given the angle
    // the point makes with the origin.
    return 1/(max(abs(cos(th)), abs(sin(th))));
}

void draw() {
    background(inv?0:255);
    t = (millis()/(20.0*numFrames))%1;
    c = mouseY*1.0/height;
    // t = mouseX*1.0/width;

    push();
    translate(width*0.5, height*0.5);

    for (Dot d : dots)
        d.show(t+1);

    pop();
}



class Dot {
    PVector p;
    float strw, str;

    int idx;
    Dot(int idx_) {
        idx = idx_;
        p = new PVector();
        strw = 1;
        str = 255;
    }

    void show(float q) {
        updatePos(q);
        strokeWeight(this.strw);
        stroke(this.str);
        show("p");
    }
    void show(String type) {
        PVector pp = this.p.copy().sub(0.5, 0.5).mult(2*global_scale*min(width, height));
        char ch = type.toLowerCase().charAt(0);
        if (ch == 'v')
            vertex(pp);
        else if (ch == 'p')
            point(pp);
        else if (ch == 'c')
            curveVertex(pp);
    }

    void updatePos(float q) {
        float e = 3;
        int moves = 10;

        // find future steps
        int tempidx = idx;
        ArrayList<PVector> pos = new ArrayList<PVector>();
        for (int m = 0; m < moves; m++) {
            PVector p = m%2==0?positions[0][tempidx]:positions[1][tempidx];
            pos.add(p);
            tempidx = bijection[m%2][tempidx];
        }

        //////////////////////////////////////////////////////////////////////

        // simulate to find lag
        PVector pt = pos.get(0).copy();
        float T = q*2;

        for (int m = 0; m < moves; m++) {
            float TT = ease(T%1, e);
            pt = PVector.lerp(pos.get(floor(T)), pos.get(floor(T)+1), TT);
        }

        //////////////////////////////////////////////////////////////////////

        pt.sub(0.5, 0.5);
        float lag = 1-sqrt(0.5*(sq(pt.x)+sq(pt.y)))*2;

        float t_ = T + lag*3*c;

        PVector new_p = pos.get(0).copy();
        for (int m = 0; m < moves; m++) {
            float tt_ = ease(t_%1, e);
            new_p = PVector.lerp(pos.get(floor(t_)), pos.get(floor(t_)+1), tt_);
        }

        //////////////////////////////////////////////////////////////////////

        // update position
        this.p = new_p;

        // update stroke and strokeweight
        this.strw = 1.8+1.7*lerp(1, 0, pow_(p.z, 1));
        this.str = lerp(lerp(100, 255, 0.35), 255, 1-p.z);
        if (!inv) {
            this.strw*=2;
            this.str = 255-this.str;
        }
    }
}

void point(PVector p) {
    point(p.x, p.y);
}

void vertex(PVector p) {
    vertex(p.x, p.y);
}

void curveVertex(PVector p) {
    curveVertex(p.x, p.y);
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

float pow_(float p, float g) {
    return 1-pow(1-p, g);
}
