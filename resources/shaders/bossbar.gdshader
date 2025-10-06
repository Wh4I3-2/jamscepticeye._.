shader_type canvas_item;

uniform float dir: hint_range(-1.0, 1.0, 2.0) = 1.0;
uniform float v: hint_range(0.0, 1.0, 0.01) = 0.5;

const vec3 bg = vec3(0.18, 0.0, 0.12);
const vec3 slider = vec3(0.7, 0.1, 0.3);

float sinn(float a) {
	return sin(a) * 0.5 + 0.5;
}

void fragment() {
	float y = UV.y;
	float t = TIME * 5.0;
	
	float x = (1.0 - UV.x) * float(dir > 0.0) +
	          UV.x * float(dir < 0.0);
	
	float h = 0.0;
	h = mix(h, sinn(y *  2.0 + t     ), 1.0);
	h = mix(h, sinn(y *  4.0 + t * 0.24), 2.02);
	h = mix(h, sinn(y *  8.0 + t * 0.74), 1.72);
	h = mix(h, sinn(y * 16.0 + t * 1.445), 1.78);
	h = mix(h, sinn(y * 32.0 + t ), 1.805);
	
	float i = sinn(y * 64.0 + t * 0.5);
	
	float z = x + h * 0.5;
	float w = min(1.0, pow(min(1.0, floor(pow(z + x + 0.35 + mix(0.0, i, -1.83), 6) * 3.0) / 3.0), 0.5));

	COLOR.rgb = mix(vec3(0.0), mix(bg, slider, float(UV.y >= 1.0 - v + sin(t * 0.5 + UV.x) *0.01)), w);
}