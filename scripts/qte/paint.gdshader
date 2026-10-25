shader_type canvas_item;

uniform sampler2D canvas: hint_default_black;
uniform vec2 prev_pos;
uniform vec2 curr_pos;
uniform float radius;
uniform vec4 color: source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform bool is_drawing = false;

// Calculates distance from a pixel (p) to a line segment (a to b)
float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

void fragment() {
    vec4 curr_color = texture(canvas, UV);
    
    if (is_drawing) {
        // Check distance to the line swept by the mouse this frame
        float d = sdSegment(UV, prev_pos, curr_pos);
        
        if (d <= radius) {
            curr_color = mix(curr_color, color, color.a);
        }
    }
    
    COLOR = curr_color;
}