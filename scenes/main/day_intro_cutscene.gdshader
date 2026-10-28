shader_type canvas_item;

uniform float radius = 0.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
	vec2 pos = UV - center;

	// 16:9 correction
	pos.x *= 16.0 / 9.0;

	float distance_from_center = length(pos);

	float edge = 0.015;

	float alpha = smoothstep(
		radius - edge,
		radius,
		distance_from_center
	);

	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}