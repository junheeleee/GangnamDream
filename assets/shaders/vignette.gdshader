shader_type canvas_item;

uniform float stress_norm : hint_range(0.0, 1.0) = 0.0;
uniform float mental_norm : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 uv = UV - 0.5;
	// 세로로 약간 압축해서 자연스러운 비네팅
	float dist = length(uv * vec2(1.0, 1.4));

	// ── 시네마틱 베이스 비네트 — 평상시에도 상시 점등 (누아르 무드) ──
	// 가장자리를 따뜻한 흑갈색으로 눌러 화면에 '필름' 같은 깊이를 준다.
	float base_edge = smoothstep(0.42, 0.95, dist);
	vec4 base_col = vec4(0.02, 0.015, 0.025, base_edge * 0.5);

	// 위급 상태 — 빨간 가장자리. 평상시 긴장 연출과 분리해 바깥쪽에서만 약하게 켠다.
	float stress_edge = smoothstep(0.38, 0.86, dist) * stress_norm;
	// 정신력 — 검은 가장자리 + 약간 파란빛 (낮을수록 진해짐)
	float mental_edge = smoothstep(0.20, 0.68, dist) * (1.0 - mental_norm);

	vec4 stress_col = vec4(0.75, 0.02, 0.02, stress_edge * 0.38);
	vec4 mental_col = vec4(0.01, 0.01, 0.08, mental_edge * 0.68);

	COLOR = clamp(base_col + stress_col + mental_col, vec4(0.0), vec4(1.0));
}
