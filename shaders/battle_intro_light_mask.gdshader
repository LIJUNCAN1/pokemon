shader_type canvas_item;
render_mode blend_add;

uniform sampler2D panel_mask : filter_nearest, repeat_disable;
uniform vec2 mask_origin;
uniform vec2 mask_size;
uniform vec2 item_position;
uniform vec2 item_size;

void fragment() {
	vec4 streak = texture(TEXTURE, UV) * COLOR;
	vec2 source_position = item_position + UV * item_size;
	vec2 mask_uv = (source_position - mask_origin) / mask_size;
	float inside_bounds = step(0.0, mask_uv.x) * step(mask_uv.x, 1.0)
		* step(0.0, mask_uv.y) * step(mask_uv.y, 1.0);
	float panel_alpha = texture(panel_mask, clamp(mask_uv, vec2(0.0), vec2(1.0))).a;
	COLOR = vec4(streak.rgb, streak.a * panel_alpha * inside_bounds);
}
