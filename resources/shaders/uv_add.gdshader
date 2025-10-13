shader_type canvas_item;

uniform sampler2D sampler : repeat_enable, filter_linear;
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 time_scale = vec2(1.0);

uniform vec2 min_value;
uniform vec2 max_value = vec2(1.0);

void fragment() {
	vec2 sample_value = texture(sampler, (UV + TIME * time_scale) / uv_scale).rg;
	sample_value = mix(min_value, max_value, sample_value);
	sample_value = clamp(sample_value, min_value, max_value);
	
	vec2 uv = UV + sample_value;
	COLOR = texture(TEXTURE, uv);
}