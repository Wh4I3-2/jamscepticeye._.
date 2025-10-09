shader_type canvas_item;

uniform sampler2D stars_a      : filter_nearest, repeat_enable;
uniform sampler2D stars_b      : filter_nearest, repeat_enable;
uniform sampler2D noise        : filter_linear, repeat_enable;
uniform sampler2D nebula_noise : filter_linear, repeat_enable;

vec3 hsv_to_rgb(vec3 c) {
	const vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Rotate a vector around a point in radians
vec2 rotated(vec2 center, vec2 vector, float angle) {
	vec2 p = vector - center; // Move vector so that center is 0.0
	// Basic trig. This is why you might sometimes hear me bitch about school not teaching me "trig"
	p = vec2(
		p.x * cos(angle) - p.y * sin(angle),
		p.x * sin(angle) + p.y * cos(angle)
	);
	return p + center; // Undo the initial offset 
}

// Converts an angle in radians to a normalized vector (a vector of length 1)
vec2 angle_to_dir(float r) {
	// Even more basic trig
	return vec2(cos(r), sin(r));
}

vec3 layer(vec2 uv, float rot, float scale, vec3 hsv_start, vec3 hsv_end, vec2 move) {
	float t = (TIME + uv.x + uv.y) * 0.01;
	
	move = rotated(vec2(0), move, mix(0.0, rot, 0.97));
	uv = rotated(vec2(0.5), uv, rot);
	
	uv = (uv + move * t) * 2.0 / scale; // With UVs dividing actually scales the resulting image
	
	float a = texture(stars_a, uv).x;
	float b = texture(stars_b, uv).x;
	
	// we mix between stars_a and stars_b to get the pulsing effect on the stars
	float w = mix(a, b, clamp(sin(TIME) + 0.5, 0.0, 1.0));
	
	return hsv_to_rgb(mix(hsv_end, hsv_start, w)) * w; // We multiply by w to make the mix value double as a sort of alpha
}

void fragment() {
	vec3 bg = vec3(0.1, 0.2, 0.22);
	
	// This is the noise that warps the stars around
	vec2 n = vec2(
		texture(noise, vec2(UV.x, UV.y)).x,
		texture(noise, vec2(UV.x, UV.y) + vec2(0.4)).x // + vec2(0.4) makes X and Y not be in sync
	);
	
	vec2 uv = UV + n * 0.1;
	
	// If you want a different look you will mostly be editing these big chunks
	// Adding uniforms for that is really bulky and annoying, so it's just hard-coded
	vec3 stars = vec3(0.0);
	stars += layer(uv,              20.0, 1.4, vec3(0.1, 1.0, 1.0), vec3(0.0, 1.0, 0.5), vec2(3.0, 0.0));
	stars += layer(uv + vec2(10.0), 40.0, 1.0, vec3(0.4, 0.5, 1.0), vec3(0.3, 0.5, 0.5), vec2(2.0, 0.0));
	stars += layer(uv + vec2(40.0), 30.0, 0.6, vec3(0.7, 0.5, 1.0), vec3(0.6, 0.5, 0.5), vec2(1.0, 0.0));
	stars += layer(uv + vec2(30.0), 25.0, 0.4, vec3(1.0, 0.5, 1.0), vec3(0.9, 0.5, 0.5), vec2(0.5, 0.0));
	stars += layer(uv + vec2(20.0), 25.0, 4.0, vec3(0.8, 0.5, 1.0), vec3(0.7, 0.5, 0.5), vec2(1.0, 0.0));
	stars += layer(uv + vec2(50.0), 25.0, 4.0, vec3(0.8, 0.5, 1.0), vec3(0.7, 0.5, 0.5), vec2(1.0, 0.0));
	
	// For loops aren't that bad
	for (int i = 0; i < 10; i++) {
		stars += layer(
			uv + vec2(float(i) * 0.1),
			25.0, 0.3,
			vec3(0.0, 0.0, 0.2), 
			vec3(0.0, 0.0, 0.0), 
			angle_to_dir(radians(float(i) * 12.0)));
		}
	// What you do have to look out for are if statements because they chug the GPU
	// That doesn't mean you can't have conditional stuff
	// Just that usually calculating both branches is typically faster
	
	vec3 nebulae = vec3(0.0);
	nebulae += hsv_to_rgb(vec3(0.94, 1.0, 0.3)) * texture(nebula_noise,  uv + vec2(TIME *  0.08)).x;
	nebulae += hsv_to_rgb(vec3(0.08, 1.0, 0.3)) * texture(nebula_noise, (uv + vec2(TIME * -0.04) + vec2(0.5)) / 2.0).x;
	nebulae += hsv_to_rgb(vec3(0.51, 1.0, 0.3)) * texture(nebula_noise, (uv + vec2(TIME *  vec2(0.03, 0.01)) + vec2(0.75)) / 1.5).x;
	
	// Addative mixing
	COLOR.rgb = bg + stars + nebulae;
}