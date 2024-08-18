#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define MY_HIGHP_OR_MEDIUMP highp
#else
    #define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec2 scale_fac;
extern MY_HIGHP_OR_MEDIUMP number noise_fac;
extern MY_HIGHP_OR_MEDIUMP number transition_amount; // Uniform for transition effect

#define BLUR_RADIUS 5

// Function to apply a blur effect to simulate watercolor bleeding
MY_HIGHP_OR_MEDIUMP vec4 watercolorBlur(Image tex, vec2 tc, vec2 resolution) {
    MY_HIGHP_OR_MEDIUMP vec4 sum = vec4(0.0);
    MY_HIGHP_OR_MEDIUMP vec2 tex_offset = vec2(1.0) / resolution; // Texture size-dependent offset

    for (int x = -BLUR_RADIUS; x <= BLUR_RADIUS; x++) {
        for (int y = -BLUR_RADIUS; y <= BLUR_RADIUS; y++) {
            MY_HIGHP_OR_MEDIUMP vec2 offset = vec2(float(x), float(y)) * tex_offset;
            sum += Texel(tex, tc + offset);
        }
    }

    sum /= float((BLUR_RADIUS * 2 + 1) * (BLUR_RADIUS * 2 + 1));
    return sum;
}

// Main shader function
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
{
    // Apply watercolor effect by blurring the texture
    MY_HIGHP_OR_MEDIUMP vec2 resolution = vec2(800.0, 600.0); // You may want to pass this as a uniform
    MY_HIGHP_OR_MEDIUMP vec4 watercolor_col = watercolorBlur(tex, tc * scale_fac, resolution);

    // Add some noise for a more dynamic watercolor texture
    MY_HIGHP_OR_MEDIUMP number noise = (fract(sin(dot(tc, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * noise_fac;
    watercolor_col.rgb += noise * vec3(0.1, 0.1, 0.1);

    // Apply transition effect (black circle)
    MY_HIGHP_OR_MEDIUMP vec2 screen_center = vec2(0.5, 0.5);
    MY_HIGHP_OR_MEDIUMP float distance_from_center = length(tc - screen_center);
    MY_HIGHP_OR_MEDIUMP float circle_radius = transition_amount; // Transition amount determines the radius
    MY_HIGHP_OR_MEDIUMP float circle_mask = smoothstep(circle_radius - 0.01, circle_radius, distance_from_center);
    
    // Final color with transition mask
    vec4 final_col = vec4(watercolor_col.rgb * (1.0 - circle_mask), watercolor_col.a);

    return final_col * color;
}
