shader_type canvas_item;

uniform sampler2D stars_a : filter_nearest, repeat_enable;
uniform sampler2D stars_b : filter_nearest, repeat_enable;
uniform sampler3D noise   : filter_nearest, repeat_enable;
uniform float noise_depth;

vec3 rgb_to_hsv(vec3 c) {
    const vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    const float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
    const vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

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


vec3 layer(vec2 uv, float rot, float scale, vec3 hsv_start, vec3 hsv_end, vec2 move) {
	float t = (TIME + uv.x + uv.y) * 0.01;
	
	move = rotated(vec2(0), move, mix(0.0, rot, 0.97));
	uv = rotated(vec2(0.5), uv, rot);
	
	uv = (uv + move * t) * 2.0 / scale;
	
	float a = texture(stars_a, uv).x;
	float b = texture(stars_b, uv).x;
	
	float w = mix(a, b, clamp(sin(TIME) + 0.5, 0.0, 1.0));
	
	return hsv_to_rgb(mix(hsv_end, hsv_start, w)) * w;
}

vec4 texture3D(sampler3D sampler, float depth, vec3 uv) {
	float za = floor(uv.z * depth) / depth;
	float zb = (floor(uv.z * depth) + 1.0) / depth;
	vec4 a = texture(sampler, vec3(uv.x, uv.y, za));
	vec4 b = texture(sampler, vec3(uv.x, uv.y, zb));
	
	return mix(a, b , 0.5);
}

void fragment() {
	vec3 bg = vec3(0.1, 0.2, 0.22);

	vec3 n = texture3D(noise, noise_depth, vec3(UV.x, UV.y, TIME * 0.01)).rgb * 2.0 - vec3(1.0);
	vec2 uv = UV + n.rg * 0.1;

	vec3 stars = vec3(0.0);
	stars += layer(uv,              20.0, 1.4, vec3(0.1, 1.0, 1.0), vec3(0.0, 1.0, 0.5), vec2(3.0, 0.0));
	stars += layer(uv + vec2(10.0), 40.0, 1.0, vec3(0.4, 0.5, 1.0), vec3(0.3, 0.5, 0.5), vec2(2.0, 0.0));
	stars += layer(uv + vec2(40.0), 30.0, 0.6, vec3(0.7, 0.5, 1.0), vec3(0.6, 0.5, 0.5), vec2(1.0, 0.0));
	stars += layer(uv + vec2(30.0), 25.0, 0.4, vec3(1.0, 0.5, 1.0), vec3(0.9, 0.5, 0.5), vec2(0.5, 0.0));
	stars += layer(uv + vec2(20.0), 25.0, 4.0, vec3(0.8, 0.5, 1.0), vec3(0.7, 0.5, 0.5), vec2(1.0, 0.0));
	stars += layer(uv + vec2(50.0), 25.0, 4.0, vec3(0.8, 0.5, 1.0), vec3(0.7, 0.5, 0.5), vec2(1.0, 0.0));
	
	COLOR.rgb = bg + stars;
	
	COLOR.rgb = texture3D(noise, noise_depth, vec3(UV.x, UV.y, TIME)).rgb;
}