shader_type canvas_item;
render_mode unshaded;

uniform float black_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float white_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float print_screen : hint_range(0.0, 0.12) = 0.0;
uniform float seed = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV;
	float fine = hash(floor(uv * vec2(900.0, 506.0)) + seed * 2.71);
	float edge = smoothstep(0.34, 0.82, distance(uv, vec2(0.5, 0.5)) * 1.45);
	float organic_a = sin(uv.x * 34.0 + seed * 1.31) * sin(uv.y * 21.0 - seed * 0.73);
	float organic_b = sin((uv.x + uv.y) * 47.0 + seed * 0.37);
	float stain = smoothstep(0.58, 0.95, organic_a * 0.35 + organic_b * 0.18 + 0.5) * (0.25 + edge * 0.65);
	float scratch_grid = hash(vec2(floor(uv.x * 380.0), floor(uv.y * 26.0)) + seed * 0.51);
	float scratches = step(0.987, scratch_grid);
	float scan = step(0.993, fract(uv.y * 180.0 + fine * 0.7));
	float screen_a = sin((uv.x + uv.y) * 880.0 + seed * 0.17);
	float screen_b = sin((uv.x - uv.y) * 640.0 - seed * 0.11);
	float screen_mark = smoothstep(0.76, 1.0, screen_a * 0.34 + screen_b * 0.22 + 0.5);

	float decay_alpha = black_intensity * (0.012 + edge * 0.095 + stain * 0.038 + scratches * 0.030 + scan * 0.008 + fine * 0.010 + screen_mark * print_screen * 0.32);
	vec3 decay_color = mix(vec3(0.0, 0.012, 0.014), vec3(0.12, 0.13, 0.13), stain);

	float center = 1.0 - smoothstep(0.02, 0.72, distance(uv, vec2(0.5, 0.44)) * 1.2);
	float clarity_alpha = white_intensity * (0.008 + center * 0.035);
	vec3 clarity_color = vec3(0.94, 0.97, 1.0);

	float total_intensity = max(black_intensity + white_intensity, 0.001);
	vec3 color = (decay_color * black_intensity + clarity_color * white_intensity) / total_intensity;
	COLOR = vec4(color, clamp(decay_alpha + clarity_alpha, 0.0, 0.24));
}
