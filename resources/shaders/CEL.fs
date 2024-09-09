extern vec2 pixel_size; // Control pixelation size

// Function to apply toon shading
vec3 toonShade(vec3 color, float intensity) {
    // Define toon shading levels
    float threshold1 = 0.2;
    float threshold2 = 0.5;
    float threshold3 = 0.8;

    vec3 shade1 = vec3(0.2, 0.2, 0.2); // Darkest shade
    vec3 shade2 = vec3(0.5, 0.5, 0.5); // Medium shade
    vec3 shade3 = vec3(0.8, 0.8, 0.8); // Lightest shade

    vec3 result_color;

    if (intensity < threshold1) {
        result_color = shade1;
    } else if (intensity < threshold2) {
        result_color = shade2;
    } else {
        result_color = shade3;
    }

    return result_color;
}

// Main shader function
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {
    vec2 pixelated_coord = floor(tc / pixel_size) * pixel_size;
    vec3 sampled_color = Texel(tex, pixelated_coord).rgb;
    
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
    vec3 shaded_color = toonShade(sampled_color, intensity);

    return vec4(shaded_color, 1.0) * color;
}
