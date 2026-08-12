shader_type canvas_item;

uniform vec4 row_color : source_color = vec4(0.46, 0.43, 0.78, 1.0);

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float value = max(source.r, max(source.g, source.b));
	vec3 tinted = row_color.rgb * value;
	COLOR = vec4(tinted, source.a * COLOR.a);
}
