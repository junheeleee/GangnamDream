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
	float base_alpha = base_edge * 0.5;

	// 위급 상태 — 빨간 가장자리. 평상시 긴장 연출과 분리해 바깥쪽에서만 약하게 켠다.
	float stress_edge = smoothstep(0.38, 0.86, dist) * stress_norm;
	// 정신력 — 검은 가장자리 + 약간 파란빛 (낮을수록 진해짐)
	float mental_edge = smoothstep(0.20, 0.68, dist) * (1.0 - mental_norm);

	float stress_alpha = stress_edge * 0.38;
	float mental_alpha = mental_edge * 0.68;

	// Compose the three edges by their own coverage. Adding straight-alpha
	// colors directly made the red channel survive even when stress_alpha was
	// zero, so an ordinary low-Mental vignette painted the whole screen red.
	// Keeping the weighted color and coverage paired makes red an actual crisis
	// signal again while preserving the noir and low-Mental edges.
	float total_alpha = clamp(
		base_alpha + stress_alpha + mental_alpha, 0.0, 1.0);
	vec3 weighted_rgb =
		vec3(0.02, 0.015, 0.025) * base_alpha
		+ vec3(0.75, 0.02, 0.02) * stress_alpha
		+ vec3(0.01, 0.01, 0.08) * mental_alpha;
	vec3 straight_rgb = weighted_rgb / max(total_alpha, 0.0001);
	COLOR = vec4(clamp(straight_rgb, vec3(0.0), vec3(1.0)), total_alpha);
}
