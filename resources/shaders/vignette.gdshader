shader_type canvas_item;

uniform sampler2D noise_a: repeat_enable;
uniform vec2 offset;

vec2 rotated(vec2 c, vec2 v, float a) {
	vec2 p = v - c;
	p = vec2(
		p.x * cos(a) - p.y * sin(a),
		p.x * sin(a) + p.y * cos(a)
	);
	return p + c;
}

vec2 dir_to(vec2 from, vec2 to) {
	vec2 v = normalize(to - from);
	float r = acos(
		dot(v, normalize(vec2(0.0, -1.0))) /
		length(v)
	);
	return vec2(cos(r), sin(r));
}

vec2 angle_to_dir(float r) {
	return vec2(cos(r), sin(r));
}

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	
	float t = (TIME) * 0.02;
	
	vec2 off = offset / screen_size;
	
	vec2 uv = rotated(vec2(0.5), UV, radians(t*100.0)) + off;

	float a1 = radians(mod(t * -200.0,         360.0));
	float a2 = radians(mod(t * -200.0 + 180.0, 360.0));

	vec2 c1 = angle_to_dir(a1) * 0.8 * 0.5 + 0.5 + off;
	vec2 c2 = angle_to_dir(a2) * 0.8 * 0.5 + 0.5 + off;

	float cd = mix(distance(uv, c1), distance(uv, c2), 0.5);

	vec2 n_uv = dir_to(c1, uv) + dir_to(c2, uv);

	float noise = (
		texture(noise_a, mix(uv, uv + n_uv, 1.0 - cd)).x
	);

	float dist = distance(uv, vec2(0.5) + off) - 0.15;

	float lines = texture(noise_a, (dir_to(vec2(0.5) + off, uv)) * 0.5).x * max(min(1.0, dist - 0.2), 0.0) * 5.0;
	float v = ((dist + texture(noise_a, (uv + vec2(t, 0.0))).x * 0.1) - 0.5) * 3.0;
	COLOR.a = (ceil((noise + v + lines) * 5.0) / 5.0 * 2.0) * COLOR.a;
	//COLOR.a = lines;
}
