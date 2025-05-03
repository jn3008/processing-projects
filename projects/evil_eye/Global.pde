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
 
float global_detail = 1;

int n_eyes_per_eye = 18;
int max_eye_depth = 5;

float pupil_radius_factor = 0.5;
float eyeball_radius_factor = 1.7;
// factor of the radius of the circles in the iris, relative to iris radius
float iris_scale_factor = 0.1;

// in the iris, how far is the max separation of each pair of circles?
// 0 = no separation, 1 = touching, no intersection
float max_circle_separation = 0.5;
float iris_angle;

float fps = 60.0;
int num_frames = 340;

float t, tt, c, cc, b, bb, cameraZ;
boolean toggle_param;

float current_depth = 0;

float strw_multiplier = 2.45;

int[] next_iris_idx = { 14 };

int n_stars = 37;
Star[] stars = new Star[n_stars];
