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

import java.util.List;

// lid_idx in {0, 1}, part in {0, 1, 2, 3} (0 = start, 1 = middle, 2 = end, 3 = all)
boolean linePointsCurved(float q, Vec p, float separation_factor, int num_points,
  float angle_extent, Matrix iris_transform, int lid_idx, int part,
  Function<Float, Float> angle_modifier) {
  float ease_q = ease(q, 1 - 0.35);

  float side = lid_idx == 0 ? -1 : 1;
  float r = lerp(pupil_radius_factor, 1, q);
  float angle_extent_adjust = lerp(1, lerp(1, pupil_radius_factor / r, q), separation_factor);
  float angle_change = (1 - 2 * separation_factor * tease(ease_q, 2, 0));

  angle_change =  angle_modifier.apply(angle_extent_adjust * angle_change);

  if (angle_change < 0 && part % 2 == 0) return false;
  if (angle_change >= 0 && part == 1) return false;

  p.set(new Vec(r, 0, 1));
  p.rotate(angle_extent * side * angle_change);

  p.multiply(iris_transform);

  return true;
};

void linePointsCurved(float separation_factor, int num_points, float angle_extent,
  Matrix iris_transform, int lid_idx, int part) {

  // STROKE
  Function<Float, Float> identity = (angle) -> angle;

  for (int i = 0; i < num_points; i++) {
    float q = i * 1.0 / (num_points - 1);
    if (part % 2 == 0)
      q *= 0.5;
    if (part == 2)
      q += 0.5;

    Vec p = new Vec();
    if (!linePointsCurved(q, p, separation_factor, num_points, angle_extent, iris_transform,
      lid_idx, part, identity))
      continue;

    vertex(p);
  }
};

void linePointsCurved(float separation_factor, int num_points, float angle_extent,
  Matrix iris_transform, int lid_idx, int part, Function<Float, Vec> stroke_) {

  // STROKE
  Function<Float, Float> identity = (angle) -> angle;

  for (int i = 0; i < num_points; i++) {
    float q = i * 1.0 / (num_points - 1);
    if (part % 2 == 0)
      q *= 0.5;
    if (part == 2)
      q += 0.5;

    Vec p = new Vec();
    if (!linePointsCurved(q, p, separation_factor, num_points, angle_extent, iris_transform,
      lid_idx, part, identity))
      continue;

    Vec stroke_data = stroke_.apply(q);
    stroke(stroke_data.x);
    strokeWeight(stroke_data.y);
    vertex(p);
  }
};


float smaller_range = 0.1;
void linePointsCurvedLid(float separation_factor, int num_points, float angle_extent,
  Matrix iris_transform, int lid_idx) {

  // FILL
  Function<Float, Float> min_0 = (angle) -> min(0.1, angle); // 0.1 instead of 0 to fix visual bug
  Function<Float, Float> one = (angle) -> 1.0;

  List<Function<Float, Float>> functions = List.of(min_0, one);

  for (int i = 0; i < num_points; i++) {
    float q = lerp(smaller_range, 1 - smaller_range, i * 1.0 / (num_points - 1));

    Vec p = new Vec();
    if (!linePointsCurved(q, p, separation_factor, num_points, angle_extent, iris_transform,
      1 - lid_idx, 3, min_0))
      continue;
    vertex(p);

    if (!linePointsCurved(q, p, separation_factor, num_points, iris_angle*0.5, iris_transform,
      lid_idx, 3, one))
      continue;
    vertex(p);
  }
};

void  fixIrisSegmentEdges(int num_points, Matrix iris_transform) {
  for (int end = 0; end < 2; end++) {
    float r0 = end == 0 ? pupil_radius_factor : 1;
    float r1 = lerp(pupil_radius_factor, 1, abs(end - smaller_range * 1.1));

    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i <= num_points; i++) {
      float q = i * 1.0 / num_points;
      for (int part = 0; part < 2; part++) {
        Vec p = new Vec(part == 0 ? r0 : r1, 0, 1);
        p.rotate(iris_angle * 0.5 * lerp(-1, 1, q));
        p.multiply(iris_transform);
        vertex(p);
      }
    }
    endShape();
  }
}
