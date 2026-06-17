shader_type canvas_item;

uniform float stress_norm : hint_range(0.0, 1.0) = 0.0;
uniform float mental_norm : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 uv = UV - 0.5;
	// 세로로 약간 압축해서 자연스러운 비네팅
	float dist = length(uv * vec2(1.0, 1.5));

	// 스트레스 — 빨간 가장자리 (스트레스 높을수록 진해짐)
	float stress_edge = smoothstep(0.25, 0.72, dist) * stress_norm;
	// 정신력 — 검은 가장자리 + 약간 파란빛 (낮을수록 진해짐)
	float mental_edge = smoothstep(0.20, 0.68, dist) * (1.0 - mental_norm);

	vec4 stress_col = vec4(0.75, 0.02, 0.02, stress_edge * 0.62);
	vec4 mental_col = vec4(0.01, 0.01, 0.08, mental_edge * 0.68);

	COLOR = clamp(stress_col + mental_col, vec4(0.0), vec4(1.0));
}
