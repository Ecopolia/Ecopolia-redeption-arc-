extern vec2 resolution; // Screen resolution
extern vec2 light_position; // Position of the light source (or camera)
extern float fog_density; // Control fog intensity
extern vec3 fog_color; // Fog color

// Main function to calculate distance-based fog effect
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Normalize coordinates to [-1, 1]
    vec2 uv = screen_coords / resolution * 2.0 - 1.0;
    
    // Calculate distance from light source (or camera)
    float distance = length(uv - (light_position / resolution * 2.0 - 1.0));

    // Increase fog effect based on distance from light source
    float fog_factor = 1.0 - exp(-distance * fog_density);

    // Get the original color from the texture
    vec4 tex_color = Texel(texture, texture_coords);

    // Mix the texture color with the fog color based on fog intensity
    vec3 final_color = mix(tex_color.rgb, fog_color, fog_factor);
    
    return vec4(final_color, tex_color.a); // Output with original alpha
}
