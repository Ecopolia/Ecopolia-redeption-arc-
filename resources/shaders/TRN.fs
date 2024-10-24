#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define MY_HIGHP_OR_MEDIUMP highp
#else
    #define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP number transition_amount; // Controls the radius of the transition

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
{
    // Transition effect (black circle expanding from the center)
    MY_HIGHP_OR_MEDIUMP vec2 screen_center = vec2(0.5, 0.5);
    MY_HIGHP_OR_MEDIUMP float distance_from_center = length(tc - screen_center);
    MY_HIGHP_OR_MEDIUMP float circle_radius = transition_amount; // Transition amount determines the radius
    MY_HIGHP_OR_MEDIUMP float circle_mask = smoothstep(circle_radius - 0.01, circle_radius, distance_from_center);
    
    // Get the texture color
    vec4 tex_color = Texel(tex, tc);

    // Apply the transition mask
    vec4 transition_col = vec4(tex_color.rgb * (1.0 - circle_mask), tex_color.a);

    return transition_col;
}
