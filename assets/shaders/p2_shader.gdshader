shader_type canvas_item;

void fragment() {
	int x = int(FRAGCOORD.x);
	int y = int(FRAGCOORD.y);
	bool show_pixel = ((x + y) % 2) == 0;

	if (show_pixel) {
		COLOR = texture(TEXTURE, UV) * COLOR;
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}
