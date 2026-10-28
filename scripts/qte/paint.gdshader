shader_type canvas_item;

uniform vec2 prev_pos;
uniform vec2 curr_pos;
uniform float radius;
uniform vec4 color: source_color = vec4(0.8, 0.15, 0.1, 0.35);
uniform bool is_drawing = false;


// Calculates distance from a pixel to a line segment.
float sdSegment(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;

	float ba_length = dot(ba, ba);

	if (ba_length == 0.0) {
		return length(pa);
	}

	float h = clamp(dot(pa, ba) / ba_length, 0.0, 1.0);

	return length(pa - ba * h);
}


void fragment() {
	COLOR = vec4(0.0);

	if (is_drawing) {
		float d = sdSegment(UV, prev_pos, curr_pos);

		if (d <= radius) {
			COLOR = color;
		}
	}
}