shader_type canvas_item;

uniform vec2 parallax_offset = vec2(0.0);

void fragment() {
	vec2 uv = UV + parallax_offset;
	uv.x += sin(UV.y * 13.0 + TIME * 0.12) * 0.0007;
	uv = clamp(uv, vec2(0.004), vec2(0.996));
	vec4 color = texture(TEXTURE, uv);

	float pulse = 1.0 + sin(TIME * 0.65 + UV.x * 4.0) * 0.012;
	float center_light = 1.0 - smoothstep(0.18, 0.78, distance(UV, vec2(0.5, 0.46)));
	float vignette = mix(0.86, 1.03, center_light);
	color.rgb *= pulse * vignette;
	COLOR = color;
}
