shader_type canvas_item;

uniform float cutoff : hint_range(0.0, 1.0);
uniform float scale = 50.0; // controls "blockiness"
uniform vec2 noise_seed = vec2(12.9898, 78.233);

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,noise_seed)) * 43758.5453);
}

void fragment() {
    // UV space scaled up so we get blocky "pixels"
    vec2 uv = floor(UV * scale);
    float noise = rand(uv);

    // If noise value < cutoff, hide this pixel
    if (noise < cutoff) {
        discard;
    }

    // Otherwise, draw black
    COLOR = vec4(0.0, 0.0, 0.0, 1.0);
}
