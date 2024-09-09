extern vec2 pixel_size; // Control pixelation size

const vec3 palette[216] = vec3[](
    // Loop through red, green, and blue intensities
    vec3(0.0, 0.0, 0.0), vec3(0.0, 0.0, 0.2), vec3(0.0, 0.0, 0.4), vec3(0.0, 0.0, 0.6), vec3(0.0, 0.0, 0.8), vec3(0.0, 0.0, 1.0),
    vec3(0.0, 0.2, 0.0), vec3(0.0, 0.2, 0.2), vec3(0.0, 0.2, 0.4), vec3(0.0, 0.2, 0.6), vec3(0.0, 0.2, 0.8), vec3(0.0, 0.2, 1.0),
    vec3(0.0, 0.4, 0.0), vec3(0.0, 0.4, 0.2), vec3(0.0, 0.4, 0.4), vec3(0.0, 0.4, 0.6), vec3(0.0, 0.4, 0.8), vec3(0.0, 0.4, 1.0),
    vec3(0.0, 0.6, 0.0), vec3(0.0, 0.6, 0.2), vec3(0.0, 0.6, 0.4), vec3(0.0, 0.6, 0.6), vec3(0.0, 0.6, 0.8), vec3(0.0, 0.6, 1.0),
    vec3(0.0, 0.8, 0.0), vec3(0.0, 0.8, 0.2), vec3(0.0, 0.8, 0.4), vec3(0.0, 0.8, 0.6), vec3(0.0, 0.8, 0.8), vec3(0.0, 0.8, 1.0),
    vec3(0.0, 1.0, 0.0), vec3(0.0, 1.0, 0.2), vec3(0.0, 1.0, 0.4), vec3(0.0, 1.0, 0.6), vec3(0.0, 1.0, 0.8), vec3(0.0, 1.0, 1.0),
    
    vec3(0.2, 0.0, 0.0), vec3(0.2, 0.0, 0.2), vec3(0.2, 0.0, 0.4), vec3(0.2, 0.0, 0.6), vec3(0.2, 0.0, 0.8), vec3(0.2, 0.0, 1.0),
    vec3(0.2, 0.2, 0.0), vec3(0.2, 0.2, 0.2), vec3(0.2, 0.2, 0.4), vec3(0.2, 0.2, 0.6), vec3(0.2, 0.2, 0.8), vec3(0.2, 0.2, 1.0),
    vec3(0.2, 0.4, 0.0), vec3(0.2, 0.4, 0.2), vec3(0.2, 0.4, 0.4), vec3(0.2, 0.4, 0.6), vec3(0.2, 0.4, 0.8), vec3(0.2, 0.4, 1.0),
    vec3(0.2, 0.6, 0.0), vec3(0.2, 0.6, 0.2), vec3(0.2, 0.6, 0.4), vec3(0.2, 0.6, 0.6), vec3(0.2, 0.6, 0.8), vec3(0.2, 0.6, 1.0),
    vec3(0.2, 0.8, 0.0), vec3(0.2, 0.8, 0.2), vec3(0.2, 0.8, 0.4), vec3(0.2, 0.8, 0.6), vec3(0.2, 0.8, 0.8), vec3(0.2, 0.8, 1.0),
    vec3(0.2, 1.0, 0.0), vec3(0.2, 1.0, 0.2), vec3(0.2, 1.0, 0.4), vec3(0.2, 1.0, 0.6), vec3(0.2, 1.0, 0.8), vec3(0.2, 1.0, 1.0),

    vec3(0.4, 0.0, 0.0), vec3(0.4, 0.0, 0.2), vec3(0.4, 0.0, 0.4), vec3(0.4, 0.0, 0.6), vec3(0.4, 0.0, 0.8), vec3(0.4, 0.0, 1.0),
    vec3(0.4, 0.2, 0.0), vec3(0.4, 0.2, 0.2), vec3(0.4, 0.2, 0.4), vec3(0.4, 0.2, 0.6), vec3(0.4, 0.2, 0.8), vec3(0.4, 0.2, 1.0),
    vec3(0.4, 0.4, 0.0), vec3(0.4, 0.4, 0.2), vec3(0.4, 0.4, 0.4), vec3(0.4, 0.4, 0.6), vec3(0.4, 0.4, 0.8), vec3(0.4, 0.4, 1.0),
    vec3(0.4, 0.6, 0.0), vec3(0.4, 0.6, 0.2), vec3(0.4, 0.6, 0.4), vec3(0.4, 0.6, 0.6), vec3(0.4, 0.6, 0.8), vec3(0.4, 0.6, 1.0),
    vec3(0.4, 0.8, 0.0), vec3(0.4, 0.8, 0.2), vec3(0.4, 0.8, 0.4), vec3(0.4, 0.8, 0.6), vec3(0.4, 0.8, 0.8), vec3(0.4, 0.8, 1.0),
    vec3(0.4, 1.0, 0.0), vec3(0.4, 1.0, 0.2), vec3(0.4, 1.0, 0.4), vec3(0.4, 1.0, 0.6), vec3(0.4, 1.0, 0.8), vec3(0.4, 1.0, 1.0),

    vec3(0.6, 0.0, 0.0), vec3(0.6, 0.0, 0.2), vec3(0.6, 0.0, 0.4), vec3(0.6, 0.0, 0.6), vec3(0.6, 0.0, 0.8), vec3(0.6, 0.0, 1.0),
    vec3(0.6, 0.2, 0.0), vec3(0.6, 0.2, 0.2), vec3(0.6, 0.2, 0.4), vec3(0.6, 0.2, 0.6), vec3(0.6, 0.2, 0.8), vec3(0.6, 0.2, 1.0),
    vec3(0.6, 0.4, 0.0), vec3(0.6, 0.4, 0.2), vec3(0.6, 0.4, 0.4), vec3(0.6, 0.4, 0.6), vec3(0.6, 0.4, 0.8), vec3(0.6, 0.4, 1.0),
    vec3(0.6, 0.6, 0.0), vec3(0.6, 0.6, 0.2), vec3(0.6, 0.6, 0.4), vec3(0.6, 0.6, 0.6), vec3(0.6, 0.6, 0.8), vec3(0.6, 0.6, 1.0),
    vec3(0.6, 0.8, 0.0), vec3(0.6, 0.8, 0.2), vec3(0.6, 0.8, 0.4), vec3(0.6, 0.8, 0.6), vec3(0.6, 0.8, 0.8), vec3(0.6, 0.8, 1.0),
    vec3(0.6, 1.0, 0.0), vec3(0.6, 1.0, 0.2), vec3(0.6, 1.0, 0.4), vec3(0.6, 1.0, 0.6), vec3(0.6, 1.0, 0.8), vec3(0.6, 1.0, 1.0),

    vec3(0.8, 0.0, 0.0), vec3(0.8, 0.0, 0.2), vec3(0.8, 0.0, 0.4), vec3(0.8, 0.0, 0.6), vec3(0.8, 0.0, 0.8), vec3(0.8, 0.0, 1.0),
    vec3(0.8, 0.2, 0.0), vec3(0.8, 0.2, 0.2), vec3(0.8, 0.2, 0.4), vec3(0.8, 0.2, 0.6), vec3(0.8, 0.2, 0.8), vec3(0.8, 0.2, 1.0),
    vec3(0.8, 0.4, 0.0), vec3(0.8, 0.4, 0.2), vec3(0.8, 0.4, 0.4), vec3(0.8, 0.4, 0.6), vec3(0.8, 0.4, 0.8), vec3(0.8, 0.4, 1.0),
    vec3(0.8, 0.6, 0.0), vec3(0.8, 0.6, 0.2), vec3(0.8, 0.6, 0.4), vec3(0.8, 0.6, 0.6), vec3(0.8, 0.6, 0.8), vec3(0.8, 0.6, 1.0),
    vec3(0.8, 0.8, 0.0), vec3(0.8, 0.8, 0.2), vec3(0.8, 0.8, 0.4), vec3(0.8, 0.8, 0.6), vec3(0.8, 0.8, 0.8), vec3(0.8, 0.8, 1.0),
    vec3(0.8, 1.0, 0.0), vec3(0.8, 1.0, 0.2), vec3(0.8, 1.0, 0.4), vec3(0.8, 1.0, 0.6), vec3(0.8, 1.0, 0.8), vec3(0.8, 1.0, 1.0),

    vec3(1.0, 0.0, 0.0), vec3(1.0, 0.0, 0.2), vec3(1.0, 0.0, 0.4), vec3(1.0, 0.0, 0.6), vec3(1.0, 0.0, 0.8), vec3(1.0, 0.0, 1.0),
    vec3(1.0, 0.2, 0.0), vec3(1.0, 0.2, 0.2), vec3(1.0, 0.2, 0.4), vec3(1.0, 0.2, 0.6), vec3(1.0, 0.2, 0.8), vec3(1.0, 0.2, 1.0),
    vec3(1.0, 0.4, 0.0), vec3(1.0, 0.4, 0.2), vec3(1.0, 0.4, 0.4), vec3(1.0, 0.4, 0.6), vec3(1.0, 0.4, 0.8), vec3(1.0, 0.4, 1.0),
    vec3(1.0, 0.6, 0.0), vec3(1.0, 0.6, 0.2), vec3(1.0, 0.6, 0.4), vec3(1.0, 0.6, 0.6), vec3(1.0, 0.6, 0.8), vec3(1.0, 0.6, 1.0),
    vec3(1.0, 0.8, 0.0), vec3(1.0, 0.8, 0.2), vec3(1.0, 0.8, 0.4), vec3(1.0, 0.8, 0.6), vec3(1.0, 0.8, 0.8), vec3(1.0, 0.8, 1.0),
    vec3(1.0, 1.0, 0.0), vec3(1.0, 1.0, 0.2), vec3(1.0, 1.0, 0.4), vec3(1.0, 1.0, 0.6), vec3(1.0, 1.0, 0.8), vec3(1.0, 1.0, 1.0)
);

// Function to quantize the color based on the fixed palette
vec3 quantizeColor(vec3 color) {
    float min_distance = 10000.0;
    vec3 closest_color = vec3(0.0);
    for (int i = 0; i < 256; i++) {
        float distance = length(color - palette[i]);
        if (distance < min_distance) {
            min_distance = distance;
            closest_color = palette[i];
        }
    }
    return closest_color;
}

// Function to apply toon shading
vec3 toonShade(vec3 color, float intensity) {
    // Define light levels for toon shading
    float level = smoothstep(0.7, 0.8, intensity);
    vec3 shade = mix(vec3(0.2, 0.2, 0.2), color, level);
    return shade;
}

// Main shader function
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {
    vec2 pixelated_coord = floor(tc / pixel_size) * pixel_size;
    vec3 sampled_color = Texel(tex, pixelated_coord).rgb;
    
    // Quantize color to a fixed palette
    vec3 quantized_color = quantizeColor(sampled_color);
    
    // Calculate normal from adjacent pixel differences
    vec3 color_left = Texel(tex, pixelated_coord + vec2(-pixel_size.x, 0.0)).rgb;
    vec3 color_right = Texel(tex, pixelated_coord + vec2(pixel_size.x, 0.0)).rgb;
    vec3 color_up = Texel(tex, pixelated_coord + vec2(0.0, -pixel_size.y)).rgb;
    vec3 color_down = Texel(tex, pixelated_coord + vec2(0.0, pixel_size.y)).rgb;

    vec3 normal = vec3(
        length(color_right - color_left),
        length(color_up - color_down),
        1.0
    );
    float intensity = length(normal); // Compute intensity from the normal vector length
    
    // Apply toon shading
    vec3 shaded_color = toonShade(quantized_color, intensity);

    return vec4(shaded_color, 1.0) * color;
}
