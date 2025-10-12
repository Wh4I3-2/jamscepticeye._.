shader_type canvas_item;

uniform float top_left = 4.0;
uniform float top_right = 4.0;
uniform float bottom_left = 4.0;
uniform float bottom_right = 4.0;
uniform float texture_scale = 1.0;

float corner(vec2 uv, float radius, vec2 size, vec2 dir) {
	vec2 s = size * (dir + vec2(1.0)) / 2.0;
	float r = max(radius, 0.01);
	
	vec2 ca = vec2(r, r) * dir;
	vec2 cb = ca * 0.5;
	float d = distance(uv + ca, vec2(s.x, s.y));
	float w = 1.0 - floor(d / r);
	float a = mix(1.0, w, 
		ceil((uv.x - s.x + cb.x) / cb.x) +
		ceil((uv.y - s.y + cb.y) / cb.y)
	);
	
	return mix(1.0, a, ceil(clamp(radius, 0.0, 1.0)));
}

void fragment() {
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE * texture_scale;
	vec2 uv = UV * size;
	
	COLOR.a = 
		corner(uv, top_left,     size, vec2(-1.0, -1.0)) * 
		corner(uv, top_right,    size, vec2( 1.0, -1.0)) * 
		corner(uv, bottom_left,  size, vec2(-1.0,  1.0)) * 
		corner(uv, bottom_right, size, vec2( 1.0,  1.0))
	;
}
