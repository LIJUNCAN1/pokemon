shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	vec3 top_color = vec3(0.025, 0.34, 0.48);
	vec3 bottom_color = vec3(0.015, 0.16, 0.24);
	vec3 color = mix(top_color, bottom_color, uv.y);
	float horizon = smoothstep(0.23, 0.7, uv.y);
	float center_light = 1.0 - smoothstep(0.0, 0.56, distance(uv, vec2(0.5, 0.58)));
	color += vec3(0.01, 0.18, 0.21) * center_light * horizon;
	vec2 grid_uv = vec2(uv.x * 18.0, uv.y * 10.0);
	float vertical = 1.0 - smoothstep(0.0, 0.035, abs(fract(grid_uv.x) - 0.5));
	float horizontal = 1.0 - smoothstep(0.0, 0.035, abs(fract(grid_uv.y) - 0.5));
	float grid = max(vertical, horizontal) * smoothstep(0.32, 0.95, uv.y);
	color += vec3(0.02, 0.17, 0.2) * grid * 0.22;
	float vignette = smoothstep(0.75, 0.2, distance(uv, vec2(0.5, 0.52)));
	color *= mix(0.7, 1.0, vignette);
	COLOR = vec4(color, 1.0);
}
