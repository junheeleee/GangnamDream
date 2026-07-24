shader_type canvas_item;
render_mode unshaded;

uniform vec4 shade_color : source_color = vec4(0.015, 0.018, 0.022, 0.90);

void fragment() {
	float vertical = smoothstep(0.36, 0.64, UV.y);
	float horizontal = 1.0 - smoothstep(0.54, 0.80, UV.x);
	float footer = smoothstep(0.70, 1.0, UV.y) * 0.12;
	float alpha = shade_color.a * vertical * max(horizontal, footer);
	COLOR = vec4(shade_color.rgb, alpha);
}
