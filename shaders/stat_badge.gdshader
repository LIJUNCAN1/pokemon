shader_type canvas_item;

uniform vec4 badge_color : source_color = vec4(0.92, 0.16, 0.34, 1.0);

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float lightness = max(source.r, max(source.g, source.b));
	float border = 1.0 - smoothstep(0.12, 0.34, lightness);
	vec3 tinted_fill = badge_color.rgb * mix(0.68, 1.12, lightness);
	vec3 final_rgb = mix(tinted_fill, vec3(0.035), border);
	COLOR = vec4(final_rgb, source.a * COLOR.a);
}
