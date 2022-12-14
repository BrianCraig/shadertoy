#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>
#include <functions/near_step.glsl>
#include <functions/noise.glsl>

layout(location = 0) out vec4 fragColor;

layout(location = 0) uniform vec2 i_resolution;
layout(location = 1) uniform mat4 i_transformation;
layout(location = 2) uniform float i_time;

const int steps = 7;

const int BAR_H = 40;
const int BAR_M = 60;
const int BAR_H_TIME = 4;

vec4 drawBar(vec4 origin) {
    vec2 i_coord = FlutterFragCoord();
    if(i_coord.y > i_resolution.y - BAR_H - BAR_M &&
        i_coord.y < i_resolution.y - BAR_M &&
        i_coord.x > BAR_M &&
        i_coord.x < i_resolution.x - BAR_M) {
        float x = (i_coord.x - BAR_M) / (i_resolution.x - (BAR_M * 2));
        if(i_coord.y > i_resolution.y - BAR_H_TIME - BAR_M) {
            return mix(vec4(0.0, 1.0, 0.0, 1.0), vec4(1.0, 0.0, 0.0, 1.0), step(0.0, (mod(i_time, float(steps)) / steps) - x));
        }
        return mix(origin, vec4(0.0, 0.0, 0.0, 1.0), step(0.0, (ceil(mod(i_time, float(steps))) / steps) - x) * 0.4);
    }
    return origin;
}

bool isStep(int step) {
    return ceil(mod(i_time, float(steps))) == step;
}

float fractPerc(float value, float mult, float perc) {
    return smoothstep(0.0, 1.0, perc * 50 - fract(value * mult) * 50);
}

void main() {
    //  Center the UV to x: [-.5, .5], y: [-.5, .5]
    vec2 uv = FlutterFragCoord() / i_resolution - 0.5;

    // multiply uv.y for the aspect ratio, stretching or making it small
    // mantaining the rendered width stable
    uv = vec2(uv.x, uv.y * (i_resolution.y / i_resolution.x));

    // multiply by projection matrix
    uv = (vec4(uv.x, uv.y, 0.0, 1.0) * i_transformation).xy;

    float noise2_glsl_vec2 = noise2D(uv);

    vec3 mv3 = vec3(uv.x, uv.y, i_time);
    float noise_vec3 = noise(vec3(uv.x, uv.y, i_time * 0.02));

    float noise_vec3_smooth = noise_smooth(vec3(uv.x, uv.y, i_time * 0.02));

    float noise_fgpt = gpt_noise(vec3(uv.x, uv.y, i_time));

    float ann = another_noise(vec3(uv.x, uv.y, i_time));

    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    if(isStep(1)) {
        color = vec4(noise2_glsl_vec2, noise2_glsl_vec2, noise2_glsl_vec2, 1.0);
    }
    if(isStep(2)) {
        color = vec4(noise_vec3, noise_vec3, noise_vec3, 1.0);
    }
    if(isStep(3)) {
        color = vec4(noise_vec3_smooth, noise_vec3_smooth, noise_vec3_smooth, 1.0);
    }
    if(isStep(4)) {
        color = vec4(noise_fgpt, noise_fgpt, noise_fgpt, 1.0);
    }
    if(isStep(5)) {
        color = vec4(ann, ann, ann, 1.0);
    }
    if(isStep(6)) {
        float xx = fractPerc(noise_vec3_smooth, 15, 0.05);
        color = vec4(xx, xx, xx, 1.0);
    }
    if(isStep(7)) {
        float xx = fractPerc(noise_vec3, 15, 0.05);
        color = vec4(xx, xx, xx, 1.0);
    }

    fragColor = drawBar(color);
}