shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest, repeat_enable;

uniform float pixelate_weight: hint_range(0.0, 1.0, 0.01);
uniform float invert_weight: hint_range(0.0, 1.0, 0.01);
uniform vec2 target_size = vec2(320.0, 180.0);

void fragment() {
	vec2 pixelate_target = mix(target_size, target_size / 4.0, pixelate_weight);
	
	vec2 uv = round(SCREEN_UV * pixelate_target) / pixelate_target;
	
	vec4 screen = texture(SCREEN_TEXTURE, uv);
	vec4 inverted = vec4(vec3(1.0) - vec3(screen.rgb), screen.a);
	
	COLOR = inverted;
	COLOR.a = COLOR.a * invert_weight;
}
