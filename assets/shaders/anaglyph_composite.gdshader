shader_type canvas_item;

uniform sampler2D left_camera;
uniform sampler2D right_camera;
uniform vec3 tint_left : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 tint_right : source_color = vec3(0.0, 1.0, 1.0);

void fragment() {
	vec4 left = texture(left_camera, UV);
	vec4 right = texture(right_camera, UV);

	// masks from luminance (white -> 0, black -> 1)
	float lum_left = dot(left.rgb, vec3(0.299, 0.587, 0.114));
	float mask_left = lum_left;
	float lum_right = dot(right.rgb, vec3(0.299, 0.587, 0.114));
	float mask_right = lum_right;

	// per-channel contributions: red channel from left, green+blue from right
	vec3 out_rgb;
	out_rgb.r = tint_left.r * mask_left;
	out_rgb.g = tint_right.g * mask_right;
	out_rgb.b = tint_right.b * mask_right;

	// opaque composite so both channels are visible
	COLOR = vec4(out_rgb, 1.0);
}