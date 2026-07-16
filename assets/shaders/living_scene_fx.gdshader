shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform int effect_mode = 0;
uniform float intensity : hint_range(0.0, 0.65) = 0.0;
uniform float motion_scale : hint_range(0.0, 1.25) = 1.0;
uniform float seed = 0.0;
uniform float moral_black : hint_range(0.0, 1.0) = 0.0;
uniform float moral_white : hint_range(0.0, 1.0) = 0.0;
uniform float afterimage_strength : hint_range(0.0, 0.10) = 0.0;
uniform float portrait_safe : hint_range(0.0, 1.0) = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), u.x),
		mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fog_field(vec2 uv, float t) {
	vec2 p = uv * vec2(2.6, 1.7) + vec2(t * 0.025, -t * 0.008) + seed * 9.0;
	float n = value_noise(p) * 0.58;
	n += value_noise(p * 2.05 + 7.3) * 0.28;
	n += value_noise(p * 4.10 - 3.7) * 0.14;
	return smoothstep(0.47, 0.78, n);
}

float rain_field(vec2 uv, float t) {
	vec2 tilted = uv;
	tilted.x += uv.y * 0.16;
	vec2 p = tilted * vec2(62.0, 23.0);
	p.y += t * 8.5;
	vec2 cell = floor(p);
	vec2 f = fract(p);
	float lane = hash21(cell + seed * 193.0);
	float character = hash21(cell * vec2(0.73, 1.31) + seed * 71.0);
	float thickness = mix(0.012, 0.030, character);
	float length = mix(0.18, 0.52, hash21(cell + seed * 37.0));
	float thin = 1.0 - smoothstep(thickness, thickness + 0.018, abs(f.x - lane));
	float tail = 1.0 - smoothstep(length, min(length + 0.14, 0.96), f.y);
	float sparse = step(0.72, character);
	return thin * tail * sparse * mix(0.55, 1.0, character);
}

float snow_layer(vec2 uv, float t, float columns, float fall_speed, float layer_seed) {
	vec2 p = uv * vec2(columns, columns * 0.58);
	p.y += t * fall_speed;
	vec2 cell = floor(p);
	vec2 f = fract(p);
	float rnd = hash21(cell + vec2(layer_seed, seed * 113.0));
	vec2 center = vec2(0.18 + rnd * 0.64, 0.18 + hash21(cell + layer_seed * 2.7) * 0.64);
	center.x += sin((cell.y + t * 0.55 + layer_seed) * 0.73) * 0.10;
	float radius = mix(0.028, 0.060, rnd);
	float flake = 1.0 - smoothstep(radius * 0.48, radius, distance(f, center));
	return flake * step(0.68, rnd);
}

float city_field(vec2 uv, float t) {
	float column = floor(uv.x * 74.0);
	float rnd = hash21(vec2(column, seed * 211.0));
	float line = 1.0 - smoothstep(0.006, 0.022, abs(fract(uv.x * 74.0) - 0.5));
	float pulse = 0.40 + 0.60 * sin(t * (0.12 + rnd * 0.18) + rnd * 18.0) * 0.5 + 0.30;
	float vertical = (1.0 - smoothstep(0.42, 0.78, uv.y)) * smoothstep(0.10, 0.34, uv.y);
	return line * vertical * step(0.82, rnd) * clamp(pulse, 0.0, 1.0);
}

float firework_burst(vec2 uv, vec2 center, float phase, float t) {
	float age = fract(t * 0.075 + phase);
	float fade = smoothstep(0.01, 0.12, age) * (1.0 - smoothstep(0.58, 1.0, age));
	float sparks = 0.0;
	for (int i = 0; i < 10; i++) {
		float fi = float(i);
		float jitter = hash21(vec2(fi + phase * 31.0, seed * 97.0));
		float angle = 6.2831853 * hash21(vec2(fi * 7.3 + phase * 31.0, seed * 83.0));
		float speed = mix(0.10, 0.37, hash21(vec2(fi * 2.7, phase * 53.0 + seed)));
		float spark_age = max(age - jitter * 0.20, 0.0);
		float active = step(jitter * 0.20, age);
		vec2 direction = vec2(cos(angle), sin(angle));
		vec2 spark_pos = center + direction * spark_age * speed;
		spark_pos.y += spark_age * spark_age * 0.075;
		vec2 trail_pos = spark_pos - direction * 0.010 * (0.35 + spark_age);
		float radius = mix(0.0030, 0.0010, spark_age);
		float point = 1.0 - smoothstep(radius, radius * 2.2,
			distance(uv * vec2(1.78, 1.0), spark_pos * vec2(1.78, 1.0)));
		float trail = 1.0 - smoothstep(radius * 0.70, radius * 2.4,
			distance(uv * vec2(1.78, 1.0), trail_pos * vec2(1.78, 1.0)));
		sparks += (point + trail * 0.26) * active;
	}
	return clamp(sparks, 0.0, 1.0) * fade;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * motion_scale;
	float field = 0.0;
	vec3 fx_color = vec3(0.72, 0.79, 0.88);

	if (effect_mode == 1) {
		field = rain_field(uv, t);
		fx_color = vec3(0.64, 0.72, 0.82);
	} else if (effect_mode == 2) {
		field = snow_layer(uv, t, 20.0, 0.42, 3.1) * 0.54;
		field += snow_layer(uv, t, 34.0, 0.66, 9.7) * 0.46;
		field += snow_layer(uv, t, 50.0, 0.92, 17.3) * 0.30;
		fx_color = vec3(0.92, 0.95, 1.0);
	} else if (effect_mode == 3) {
		field = fog_field(uv, t) * 0.72;
		fx_color = vec3(0.66, 0.72, 0.76);
	} else if (effect_mode == 4) {
		field = city_field(uv, t);
		fx_color = vec3(0.94, 0.70, 0.34);
	} else if (effect_mode == 5) {
		field = firework_burst(uv, vec2(0.28 + seed * 0.12, 0.30), 0.12 + seed * 0.23, t);
		field += firework_burst(uv, vec2(0.63 - seed * 0.08, 0.23), 0.57 + seed * 0.19, t) * 0.78;
		fx_color = mix(vec3(1.0, 0.67, 0.18), vec3(0.88, 0.20, 0.16), step(0.5, fract(seed * 7.0)));
	}

	float dialogue_safe = 1.0 - smoothstep(0.60, 0.84, uv.y);
	float portrait_zone = smoothstep(0.64, 0.84, uv.x)
		* smoothstep(0.08, 0.22, uv.y) * (1.0 - smoothstep(0.70, 0.87, uv.y));
	float cinematic_face_safe = 1.0;
	if (effect_mode == 5) {
		cinematic_face_safe = 1.0 - smoothstep(0.60, 0.82, uv.x) * 0.88;
	}
	float safe_mask = dialogue_safe * (1.0 - portrait_zone * portrait_safe * 0.74) * cinematic_face_safe;
	float air_alpha = clamp(field * intensity * safe_mask, 0.0, 0.34);

	float color_luma = dot(fx_color, vec3(0.299, 0.587, 0.114));
	fx_color = mix(fx_color, vec3(color_luma), moral_black * 0.84);
	fx_color = mix(fx_color, fx_color * vec3(1.02, 1.04, 1.06), moral_white * 0.28);

	vec2 echo_offset = vec2(0.0016 + seed * 0.0008, -0.0007) * (0.55 + moral_black);
	vec3 echo_color = texture(screen_texture, SCREEN_UV + echo_offset).rgb;
	float echo_mask = (0.30 + fog_field(uv * 0.82, t * 0.42) * 0.70) * dialogue_safe;
	float echo_alpha = afterimage_strength * echo_mask;
	float total_alpha = clamp(air_alpha + echo_alpha, 0.0, 0.38);
	vec3 out_color = fx_color;
	if (total_alpha > 0.0001) {
		out_color = mix(fx_color, echo_color, clamp(echo_alpha / total_alpha, 0.0, 1.0));
	}
	COLOR = vec4(out_color, total_alpha);
}
