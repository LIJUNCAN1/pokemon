shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float brightest = max(color.r, max(color.g, color.b));
	float darkest = min(color.r, min(color.g, color.b));
	float saturation = brightest - darkest;
	float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));

	float is_gray = 1.0 - smoothstep(0.025, 0.09, saturation);
	float above_black = smoothstep(0.16, 0.25, luminance);
	float below_white = 1.0 - smoothstep(0.68, 0.82, luminance);
	float background_mask = is_gray * above_black * below_white;
	color.a *= 1.0 - background_mask;
	COLOR = color;
}
