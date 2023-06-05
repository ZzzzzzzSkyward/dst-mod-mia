//glsl
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

precision highp float;

#define PI 3.141592653589793238

vec3 base_color = vec3(1.0, 0.3, 0.0);

float hash11(float p) {
    return fract(sin(p * 7.11) * 523.7);
}

vec2 hash21(float p) {
    vec3 p3 = fract(vec3(p) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract(vec2((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y));
}

vec3 hash33(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));
    return fract(sin(p) * 43758.5453123);
}

void main() {
    vec2 center = u_resolution.xy / 2.0;

    float c0 = 0.0;

    for (float i = 0.0; i < 50.0; ++i) {
        float t = 4.0 * u_time + hash11(i);

        vec2 v = hash21(i + 50.0 * floor(t));
        t = fract(t);
        v = vec2(sqrt(-2.0 * log(1.0 - v.x)), 6.283185 * v.y);
        v = 20.0 * v.x * vec2(cos(v.y), sin(v.y));

        vec2 p = center + t * v - gl_FragCoord.xy;
        c0 += 4.0 * (1.0 - t) / (1.0 + 0.3 * dot(p, p));

        p = p.yx;
        v = v.yx;
        p = vec2(
            p.x / v.x,
            p.y - p.x / v.x * v.y
        );

        float a = abs(p.x) < 0.1 ? 50.0 / abs(v.x) : 0.0;
        float b0 = max(2.0 - abs(p.y), 0.0);
        float b1 = 0.2 / (1.0 + 0.0001 * p.y * p.y);
        c0 += (1.0 - t) * b0 * a;
    }

    vec3 rgb = c0 * base_color;
    rgb += hash33(vec3(gl_FragCoord.xy, u_time * 256.0)) / 512.0;
    rgb = pow(rgb, vec3(0.4));
    gl_FragColor = vec4(rgb, 1.0);
}