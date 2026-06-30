shader_type canvas_item;
render_mode unshaded;

uniform float desaturation : hint_range(0.0, 1.0) = 0.82;
uniform float brightness : hint_range(0.0, 1.4) = 0.88;
uniform float contrast : hint_range(0.4, 1.6) = 0.92;
uniform vec4 tint_color : source_color = vec4(0.01, 0.012, 0.012, 1.0);
uniform float tint_amount : hint_range(0.0, 0.35) = 0.0;
uniform float grain_amount : hint_range(0.0, 0.12) = 0.02;
uniform float ink_bleed : hint_range(0.0, 0.35) = 0.06;
uniform float paper_fade : hint_range(0.0, 0.20) = 0.02;
uniform float edge_burn : hint_range(0.0, 0.35) = 0.08;
uniform float print_screen : hint_range(0.0, 0.12) = 0.012;
uniform float tone_quantize : hint_range(0.0, 1.0) = 0.0;
uniform float screen_scale : hint_range(120.0, 1200.0) = 620.0;
uniform float seed = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV) * COLOR;
	float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 graded = mix(tex.rgb, vec3(lum), desaturation);
	graded = (graded - vec3(0.5)) * contrast + vec3(0.5);
	graded *= brightness;
	graded = mix(graded, tint_color.rgb, tint_amount);

	float coarse = hash(floor(UV * vec2(480.0, 270.0)) + seed * 3.17);
	float fine = hash(floor(UV * vec2(1280.0, 720.0)) + seed * 5.11);
	float paper_noise = (coarse - 0.5) * 0.65 + (fine - 0.5) * 0.35;
	float ink_mask = smoothstep(0.50, 0.96, 1.0 - lum);
	float light_mask = smoothstep(0.25, 0.92, lum);
	float edge = smoothstep(0.52, 1.0, distance(UV, vec2(0.5, 0.5)) * 1.42);
	float screen_a = sin((UV.x + UV.y) * screen_scale + seed * 0.13);
	float screen_b = sin((UV.x - UV.y) * screen_scale * 0.73 - seed * 0.09);
	float screen = screen_a * 0.62 + screen_b * 0.38;
	float screen_mark = smoothstep(0.50, 0.98, screen * 0.5 + 0.5);
	float paper_lift = smoothstep(0.0, 0.18, 1.0 - (screen * 0.5 + 0.5));
	float levels = mix(255.0, 18.0, clamp(tone_quantize, 0.0, 1.0));

	graded += vec3(paper_noise * grain_amount);
	graded = mix(graded, graded * (1.0 - ink_mask * 0.22), ink_bleed);
	graded = mix(graded, mix(graded, vec3(0.94, 0.95, 0.95), light_mask * 0.25), paper_fade);
	graded = mix(graded, floor(graded * levels + 0.5) / levels, tone_quantize * 0.18);
	graded -= vec3(screen_mark * print_screen * (0.18 + ink_mask * 0.58));
	graded += vec3(paper_lift * print_screen * light_mask * 0.10);
	graded *= 1.0 - edge * edge_burn;

	COLOR = vec4(clamp(graded, vec3(0.0), vec3(1.0)), tex.a);
}
