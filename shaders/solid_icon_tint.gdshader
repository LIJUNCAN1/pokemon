shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0);

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	COLOR = vec4(tint_color.rgb, source.a * COLOR.a);
}
