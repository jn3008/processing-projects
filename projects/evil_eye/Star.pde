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
 
Vec getStarPos(int index, int N) {
  float golden_angle = 0.7639320225; // golden angle

  float radius = sqrt(float(index) + 0.5) / sqrt(float(N)); // normalized radius (0 to 1)
  radius = lerp(radius, pow_(radius, 2), 0.8);
  float angle = index * golden_angle;

  return new Vec(radius * 0.44, 0.0).rotate(angle);
}

void drawStar(Vec pos, float size, float angle, Matrix transform, int num_points) {
  beginShape();
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < num_points; j++) {
      Vec v = new Vec(1, 0).rotate((j * 1.0 / num_points - i) * HALF_PI);
      v.add(new Vec(1, 1).rotate(-i * HALF_PI + PI) );
      v.y *= 1.3;
      v.mult(size);
      v.rotate(angle);
      v.add(pos);
      v.multiply(transform);
      vertex(v);
    }
  }
  endShape(CLOSE);
}

class Star {
  int i, N;
  Vec init_pos;
  float init_pos_mag;

  Star(int i_, int N_) {
    i = i_;
    N = N_;

    init_pos = getStarPos(i, N);
    init_pos_mag = init_pos.mag();
  }

  void show(Matrix transform, int depth, int iris_idx) {
    float actual_depth = actualDepth(depth);

    Vec tmp = new Vec(1, 0);
    Vec tmp_ = new Vec();
    tmp.multiply(transform);
    tmp_.multiply(transform);
    float correct_angle = atan2(tmp.y - tmp_.y, tmp.x - tmp_.x);

    Vec pos = init_pos.copy();

    float actual_depth_offset = actual_depth + init_pos_mag * 1.8;
    float rotation_angle = -0.03467345 * TAU * (actual_depth_offset);
    float rotation_progress = (actual_depth_offset + 2 + iris_idx) / 0.74 + 0.788;
    rotation_progress += lerp(-1, 1, lerp(0.13, 0.85, noise(actual_depth * 2 * 0.05, i * 100))) * 0.46;
    rotation_angle -= 0.24 * TAU * (floor(rotation_progress) + ease(rotation_progress % 1, 2));

    pos.rotate(rotation_angle);

    float noise_speed = 4;

    float star_size = 0.06;
    star_size *= 1 - pow_(c01(pos.mag() / 0.55), 1);
    star_size *= lerp(0.1, 1.25,
      ease(pow(
      lerp(0.1, 0.9, noise(i * 300 - 100, actual_depth * noise_speed + init_pos_mag))
      , 1.3), 3)
      );

    int num_points = round(6 * global_detail);
    drawStar(pos, star_size, -correct_angle, transform, num_points);
  }
}
