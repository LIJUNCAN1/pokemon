shader_type canvas_item;

uniform vec4 accent_color : source_color = vec4(0.9, 0.15, 0.2, 1.0);

vec3 rgb_to_hsv(vec3 color) {
	vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.bg, k.wz), vec4(color.gb, k.xy), step(color.b, color.g));
	vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 color) {
	vec3 p = abs(fract(color.xxx + vec3(0.0, 1.0 / 3.0, 2.0 / 3.0)) * 6.0 - 3.0);
	return color.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), color.y);
}

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	vec3 hsv = rgb_to_hsv(source.rgb);
	// Preserve the PSD's white card surface and gray edge pixels. Only authored
	// accent pixels are recolored, retaining their original shading and alpha.
	if (hsv.y > 0.08) {
		float target_peak = max(accent_color.r, max(accent_color.g, accent_color.b));
		vec3 target = accent_color.rgb / max(target_peak, 0.0001);
		vec3 recolored = mix(vec3(hsv.z), target * hsv.z, hsv.y);
		COLOR = vec4(recolored, source.a);
	} else {
		COLOR = source;
	}
}
