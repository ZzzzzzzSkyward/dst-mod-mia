//shadertoy
const vec3 base_color = vec3(1.0, 0.3, 0.0);

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 center = iResolution.xy/2.;

    float c0 = 0.;

    for(float i = 0.; i < 50.; ++i) {
        float t = 4.*iTime + hash11(i);

        vec2 v = hash21(i + 50.*floor(t));
        t = fract(t);
        v = vec2(sqrt(-2.*log(1.-v.x)), 6.283185*v.y);
        v = 20.*v.x*vec2(cos(v.y), sin(v.y));

        vec2 p = center + t*v - fragCoord;
        c0 += 4.*(1.-t)/(1. + 0.3*dot(p,p));

        p = p.yx;
        v = v.yx;
        p = vec2(
            p.x/v.x,
            p.y - p.x/v.x*v.y
        );

        float a = abs(p.x) < 0.1 ? 50./abs(v.x) : 0.;
        float b0 = max(2. - abs(p.y), 0.);
        float b1 = 0.2/(1.+0.0001*p.y*p.y);
        c0 += (1.-t)*b0*a;
    }

    vec3 rgb = c0*base_color;
    rgb += hash33(vec3(fragCoord,iTime*256.))/512.;
    rgb = pow(rgb, vec3(0.4));
    fragColor = vec4(rgb,1.);
}