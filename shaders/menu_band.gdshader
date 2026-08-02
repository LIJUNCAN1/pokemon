shader_type canvas_item;

void fragment() {
	float left_fade = smoothstep(0.0, 0.22, UV.x);
	float right_fade = 1.0 - smoothstep(0.78, 1.0, UV.x);
	float top_fade = smoothstep(0.0, 0.12, UV.y);
	float bottom_fade = 1.0 - smoothstep(0.88, 1.0, UV.y);
	float alpha = left_fade * right_fade * top_fade * bottom_fade;
	float center_glow = 1.0 - abs(UV.x - 0.5) * 2.0;
	vec3 tint = mix(vec3(0.005, 0.008, 0.012), vec3(0.015, 0.035, 0.045), center_glow);
	COLOR = vec4(tint, alpha * 0.84);
}
