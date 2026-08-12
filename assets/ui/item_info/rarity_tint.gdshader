shader_type canvas_item;

uniform vec4 rarity_color : source_color = vec4(0.77, 0.35, 0.85, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.8;
uniform float brightness : hint_range(0.2, 1.4) = 1.0;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float lightness = max(source.r, max(source.g, source.b));
	vec3 tinted = rarity_color.rgb * mix(0.58, 1.24, lightness);
	vec3 shaded = mix(vec3(lightness), tinted, tint_strength) * brightness;
	COLOR = vec4(shaded, source.a * rarity_color.a);
}
