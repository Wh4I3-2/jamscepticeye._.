shader_type canvas_item;

uniform sampler2D stars_a     : filter_nearest, repeat_enable;
uniform sampler2D stars_b     : filter_nearest, repeat_enable;
uniform sampler2D noise       : filter_linear_mipmap, repeat_enable;
uniform sampler2D noise_noise : filter_linear_mipmap, repeat_enable;

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

void fragment() {
	vec3 bg = vec3(0.1, 0.2, 0.22);

	vec3 n = vec3(
		texture(noise, vec2(UV.x, UV.y)).r,
		texture(noise, vec2(UV.x + 0.4, UV.y + 0.4)).r,
		0.0
	);
	vec2 uv = UV + n.rg * 0.1;

	vec3 stars = vec3(0.0);
	stars += layer(uv,              20.0, 1.4, vec3(0.1, 1.0, 1.0), vec3(0.0, 1.0, 0.5), vec2(3.0, 0.0));
	stars += layer(uv + vec2(10.0), 40.0, 1.0, vec3(0.4, 0.5, 1.0), vec3(0.3, 0.5, 0.5), vec2(2.0, 0.0));
	stars += layer(uv + vec2(40.0), 30.0, 0.6, vec3(0.7, 0.5, 1.0), vec3(0.6, 0.5, 0.5), vec2(1.0, 0.0));
	stars += layer(uv + vec2(30.0), 25.0, 0.4, vec3(1.0, 0.5, 1.0), vec3(0.9, 0.5, 0.5), vec2(0.5, 0.0));
	stars += layer(uv + vec2(20.0), 25.0, 4.0, vec3(0.8, 0.5, 1.0), vec3(0.7, 0.5, 0.5), vec2(1.0, 0.0));
	stars += layer(uv + vec2(50.0), 25.0, 4.0, vec3(0.8, 0.5, 1.0), vec3(0.7, 0.5, 0.5), vec2(1.0, 0.0));

	for (int i = 0; i < 10; i++) {
		stars += layer(uv + vec2(float(i) * 0.1), 25.0, 0.3, vec3(0.0, 0.0, 0.2), vec3(0.0, 0.0, 0.1), angle_to_dir(radians(float(i) * 12.0)));
	}

	vec3 cosmic_dust = vec3(0.0);
	cosmic_dust += hsv_to_rgb(vec3(0.94, 1.0, 0.3)) * texture(noise_noise,  uv + vec2(TIME *  0.08)).x;
	cosmic_dust += hsv_to_rgb(vec3(0.08, 1.0, 0.3)) * texture(noise_noise, (uv + vec2(TIME * -0.04) + vec2(0.5)) / 2.0).x;
	cosmic_dust += hsv_to_rgb(vec3(0.51, 1.0, 0.3)) * texture(noise_noise, (uv + vec2(TIME *  vec2(0.03, 0.01)) + vec2(0.75)) / 1.5).x;

	COLOR.rgb = bg + stars + cosmic_dust;
}