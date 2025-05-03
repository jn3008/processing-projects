/*
 * This work (c) 2025 by jn3008 is licensed under the Creative Commons
 * Attribution-NonCommercial-NoDerivatives 4.0 International License (CC BY-NC-ND 4.0).
 * 
 * You may view, share, and redistribute this code with attribution for non-commercial purposes,
 * but you may not modify or use it to create derivative works.
 * 
 * License: https://creativecommons.org/licenses/by-nc-nd/4.0/
 * Contact: jn3008@proton.me
 */
 
import java.util.function.Consumer;
import java.util.function.BiConsumer;
import java.util.function.Function;

float ease(float p, float g) {
  if (p < 0.5)
    return 0.5 * pow(2 * p, g);
  else
    return 1 - 0.5 * pow(2 * (1 - p), g);
}

float tease(float p, float g, float w) { // w in [0, 1]
  if (2 * p + w < 1)
    return ease(map(p, 0, 0.5 * (1 - w), 0, 1), g);
  else if (2 * p > 1 + w)
    return ease(map(p, 0.5 * (1 + w), 1, 1, 0), g);
  else
    return 1;
}

float c01(float g) {
  return constrain(g, 0, 1);
}

float pow_(float p, float g) {
  return 1 - pow(1 - p, g);
}

float constrainMap(float x, float a, float b, float y, float z) {
  return constrain(map(x, a, b, y, z), min(y, z), max(y, z));
}

void keyPressed() {
  toggle_param = !toggle_param;
}

void vertex(Vec v) {
  vertex(v.x, v.y, v.z);
}

void setup() {
  size(1080, 1080, P3D);
  smooth(8);
  ortho();

  iris_angle = TAU / n_eyes_per_eye;

  for (int i = 0; i < n_stars; i++)
    stars[i] = new Star(i, n_stars);
}

boolean irisInCameraPath(int depth, int iris_idx) {
  depth %= next_iris_idx.length;
  return next_iris_idx[depth] == iris_idx;
}

float actualDepth(int depth) {
  return depth - current_depth - 1;
}

float getStrokeWeight(int depth) {
  return strw_multiplier * constrain(pow(iris_scale_factor, actualDepth(depth)), 0.7, 2);
}

void draw() {
  if (!toggle_param) {
    c = mouseY * 1.0 / height;
    cc = mouseX * 1.0 / width;
  } else {
    b = mouseY * 1.0 / height;
    bb = mouseX * 1.0 / width;
  }
  if (mousePressed)
    println(c, cc, b, bb);

  t = (millis() / (num_frames * 1000.0 / fps)) % 1;

  float time_offset = 0.66;

  global_detail = 1 - bb;

  current_depth = t * next_iris_idx.length + time_offset;
  background(255);

  push();
  translate(width * 0.5, height * 0.5);
  rotateX(HALF_PI * ease(b, 2));

  Matrix cam = Matrix.identity(4);
  for (int i = 0; i < floor(current_depth)+1; i++) {
    Matrix.multiply_(
      Matrix.inverse(
      nextEyeTransform(next_iris_idx[i % next_iris_idx.length], c01(current_depth-i))
      ), cam);
  }

  Matrix scale = Matrix.S(width * 0.35, width * 0.35, 40);
  drawIrisSegment(0, next_iris_idx[0], scale.times(cam).times(Matrix.inverse(nextEyeTransform())));

  pop();
}

float irisAngle(int iris_idx) {
  return TAU * iris_idx / n_eyes_per_eye;
}

Matrix irisSegmentTransform(int iris_idx, float q) {
  return Matrix.Rz(irisAngle(iris_idx) * q);
}

Matrix irisSegmentTransform(int iris_idx) {
  return irisSegmentTransform(iris_idx, 1);
}

Matrix nextEyeTransform(int iris_idx, float q) {
  float translate_x = lerp(pupil_radius_factor, 1, 0.5);
  float scale = pow(iris_scale_factor, q);
  float scale_pct = pow(iris_scale_factor, ease(q, 1));///iris_scale_factor;
  scale_pct = map(scale_pct, 1, iris_scale_factor, 0, 1);
  scale_pct = ease(scale_pct, 2);

  Matrix iris_segment_transform = irisSegmentTransform(iris_idx, 1);

  Matrix extra_rotation = irisAngle(iris_idx) > PI ? Matrix.Rz(-TAU * q) : Matrix.identity(4);

  return Matrix.T(new Vec(translate_x, 0, 0).multiply_ret(iris_segment_transform).mult(scale_pct))
    .times(irisSegmentTransform(iris_idx, q))
    .times(extra_rotation)
    .times(Matrix.S(scale, scale, 0.5));
}

Matrix nextEyeTransform(int iris_idx) {
  return nextEyeTransform(iris_idx, 1);
}

Matrix nextEyeTransform(float q) {
  float scale = pow(iris_scale_factor, q);
  float scale_pct = scale/iris_scale_factor;
  return Matrix.T(lerp(pupil_radius_factor * scale_pct, 1, 0.5) * q, 0, 0)
    .times(Matrix.S(scale, scale, 0.5));
}

Matrix nextEyeTransform() {
  return nextEyeTransform(1f);
}

Matrix lookTransform(float where) { // in [-1, 1] (-1 left, 1 right, 0 at camera)
  float look_angle = where * 1.2 / eyeball_radius_factor;
  return
    new Matrix(new double[][]{
    {cos(look_angle), 0, 0, -sin(look_angle) * eyeball_radius_factor},
    {0, 1, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 0, 1}
    })
    ;
}

boolean irisSegmentInCamera(Matrix transform) {
  Vec[] segment = {new Vec(pupil_radius_factor, 0).rotate(iris_angle*0.5).multiply_ret(transform),
    new Vec(1, 0).rotate(iris_angle*0.5).multiply_ret(transform),
    new Vec(1, 0).rotate(-iris_angle*0.5).multiply_ret(transform),
    new Vec(pupil_radius_factor, 0).rotate(-iris_angle*0.5).multiply_ret(transform)
  };

  float x = 0.5; // vary this to debug
  float minX = -width * x, maxX = width * x;
  float minY = -height * x, maxY = height * x;

  // Check if any vertex is inside the canvas
  for (Vec p : segment)
    if (p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY)
      return true;

  // Define canvas edges
  Vec[][] canvasEdges = {
    {new Vec(minX, minY), new Vec(maxX, minY)}, // Top
    {new Vec(maxX, minY), new Vec(maxX, maxY)}, // Right
    {new Vec(maxX, maxY), new Vec(minX, maxY)}, // Bottom
    {new Vec(minX, maxY), new Vec(minX, minY)}  // Left
  };

  // Check if any polygon edge intersects a canvas edge
  for (int i = 0; i < 4; i++) {
    Vec a1 = segment[i], a2 = segment[(i + 1) % 4]; // Wrap around

    for (Vec[] edge : canvasEdges)
      if (linesIntersect(a1, a2, edge[0], edge[1]))
        return true;
  }

  return false;
}

// Optimized line intersection
boolean linesIntersect(Vec a1, Vec a2, Vec b1, Vec b2) {
  float d1 = cross(b1, b2, a1);
  float d2 = cross(b1, b2, a2);
  float d3 = cross(a1, a2, b1);
  float d4 = cross(a1, a2, b2);

  return (d1 * d2 < 0) && (d3 * d4 < 0);
}

float cross(Vec a, Vec b, Vec c) {
  return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

// before applying T, iris radius is assumed to be 1
void drawIris(int depth, int iris_idx, Matrix iris_transform) {
  if (depth >= max_eye_depth) return; // exit recursion at max depth

  int n_circle = round(100 * global_detail * constrainMap(actualDepth(depth), 0, 3, 3, 0.5));
  BiConsumer<Float, Float> draw_circle = (r, z) -> {
    beginShape();
    for (int i = 0; i < n_circle; i++) {
      Vec p = new Vec(r, 0, z).rotate(i * TAU / n_circle);
      p.multiply(iris_transform);
      vertex(p);
    }
    endShape(CLOSE);
  };

  noFill();
  stroke(255);
  strokeWeight(getStrokeWeight(depth));

  draw_circle.accept(pupil_radius_factor, 1.1);

  Matrix star_transform = Matrix.mult(Matrix.T(0, 0, 1.1), iris_transform);

  noStroke();
  fill(255);
  for (Star s : stars)
    s.show(star_transform, depth, iris_idx);

  draw_circle.accept(0.95, -2.0);

  fill(0);
  draw_circle.accept(pupil_radius_factor * 1.01, 0.0);

  for (int next_iris_idx = 0; next_iris_idx < n_eyes_per_eye; next_iris_idx++) {
    Matrix iris_segment_transform = irisSegmentTransform(next_iris_idx);
    Matrix next_transform = iris_transform.times(iris_segment_transform);

    if (!irisInCameraPath(depth, next_iris_idx) && !irisSegmentInCamera(next_transform)) continue;

    drawIrisSegment(depth, next_iris_idx, next_transform);
  }
}

void drawIrisSegment(int depth, int iris_idx, Matrix iris_transform) {

  float th = TAU * iris_idx / n_eyes_per_eye;
  float separation_factor = sin(TAU * t + th * 3) * 0.5 + 0.5;
  float look_val = sin(TAU * t + th * 7);

  if (irisInCameraPath(depth, iris_idx)) {
    float focus = ease(pow_(c01(-actualDepth(depth)), 2), 1);
    float open_eye = 0.1 * ease(c01((-actualDepth(depth) - 0.9) / 0.6), 2);
    separation_factor = lerp(separation_factor, 1, focus) + open_eye;

    look_val *= 1 - focus;
  }

  float actual_depth = actualDepth(depth);
  int num_points = round(0.95 * constrainMap(actual_depth, 0, 4, 60, 1) * global_detail);

  float angle_extent = 0.4 * iris_angle;

  float default_strokeweight = getStrokeWeight(depth);
  strokeWeight(default_strokeweight);
  noFill();
  stroke(255);

  // Eyelid lines (stroke)
  for (int lid_idx = 0; lid_idx < 2; lid_idx++) {
    Function<Float, Float> function_stroke = (q) -> 255f;
    Function<Float, Float> function_weight = (q) ->
      default_strokeweight *
      tease(q, 2, 0) *
      lerp(0.3, 1.8,
      ease(lerp(0.12, 0.8, noise(actual_depth * 20 + q* 10, iris_idx * 500, q * 3)), 2));
    Function<Float, Vec> stroke_data = (q) -> new Vec(
      function_stroke.apply(q), function_weight.apply(q));
    beginShape();
    for (int part = 0; part < 3; part++) {
      linePointsCurved(separation_factor, num_points, angle_extent, iris_transform,
        lid_idx, part, stroke_data);
    }
    endShape();
  }

  // Eyelid filled
  noStroke();
  fill(0);

  for (int lid_idx = 0; lid_idx < 2; lid_idx++) {
    beginShape(TRIANGLE_STRIP);
    linePointsCurvedLid(separation_factor, num_points, angle_extent, iris_transform, lid_idx);
    endShape();
  }

  // Do the inner and outer edges of this iris segment to account for "smaller_range" in Curves.pde
  fixIrisSegmentEdges(num_points, iris_transform);

  Matrix look = lookTransform(look_val);

  if (separation_factor < 0.5) return; // hide next iris when current eye is closed
  if (actualDepth(depth) > 3.5) return;

  // Draw next iris
  drawIris(depth + 1, iris_idx, iris_transform.times(nextEyeTransform()).times(look));
}
