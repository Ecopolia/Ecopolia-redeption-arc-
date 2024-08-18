#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define MY_HIGHP_OR_MEDIUMP highp
#else
    #define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec2 scale_fac;
extern MY_HIGHP_OR_MEDIUMP number transition_amount;
extern MY_HIGHP_OR_MEDIUMP number edge_threshold;  // New uniform for controlling edge detection

// Function to detect edges and apply toon shading
MY_HIGHP_OR_MEDIUMP vec4 toonEffect(Image tex, vec2 tc) {
    MY_HIGHP_OR_MEDIUMP vec4 color = Texel(tex, tc);
    
    // Adjust color to create a stepped gradient (toon effect)
    color.rgb = floor(color.rgb * vec3(3.0)) / vec3(3.0);

    return color;
}

// Function to detect edges for outlining
MY_HIGHP_OR_MEDIUMP float detectEdge(Image tex, vec2 tc, vec2 resolution) {
    MY_HIGHP_OR_MEDIUMP vec4 center = Texel(tex, tc);
    MY_HIGHP_OR_MEDIUMP vec4 north = Texel(tex, tc + vec2(0.0, 1.0) / resolution);
    MY_HIGHP_OR_MEDIUMP vec4 east = Texel(tex, tc + vec2(1.0, 0.0) / resolution);
    MY_HIGHP_OR_MEDIUMP vec4 south = Texel(tex, tc - vec2(0.0, 1.0) / resolution);
    MY_HIGHP_OR_MEDIUMP vec4 west = Texel(tex, tc - vec2(1.0, 0.0) / resolution);

    MY_HIGHP_OR_MEDIUMP float edge = 0.0;

    // Calculate edge strength based on color differences
    edge += length(center.rgb - north.rgb);
    edge += length(center.rgb - east.rgb);
    edge += length(center.rgb - south.rgb);
    edge += length(center.rgb - west.rgb);

    return smoothstep(edge_threshold * 0.5, edge_threshold, edge);
}

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
{
    MY_HIGHP_OR_MEDIUMP vec2 resolution = vec2(800.0, 600.0); // You may want to pass this as a uniform

    // Apply the toon shading effect
    MY_HIGHP_OR_MEDIUMP vec4 toon_color = toonEffect(tex, tc * scale_fac);

    // Detect edges and darken them to create outlines
    MY_HIGHP_OR_MEDIUMP float edge = detectEdge(tex, tc * scale_fac, resolution);
    toon_color.rgb *= (1.0 - edge);

    // Apply transition effect (black circle)
    MY_HIGHP_OR_MEDIUMP vec2 screen_center = vec2(0.5, 0.5);
    MY_HIGHP_OR_MEDIUMP float distance_from_center = length(tc - screen_center);
    MY_HIGHP_OR_MEDIUMP float circle_radius = transition_amount; // Transition amount determines the radius
    MY_HIGHP_OR_MEDIUMP float circle_mask = smoothstep(circle_radius - 0.01, circle_radius, distance_from_center);
    
    // Final color with transition mask
    vec4 final_col = vec4(toon_color.rgb * (1.0 - circle_mask), toon_color.a);

    return final_col * color;
}
