shader_type canvas_item;
render_mode unshaded;

uniform float desaturation : hint_range(0.0, 1.0) = 0.82;
uniform float brightness : hint_range(0.0, 1.4) = 0.88;
uniform float contrast : hint_range(0.4, 1.6) = 0.92;
uniform vec4 tint_color : source_color = vec4(0.01, 0.012, 0.012, 1.0);
uniform float tint_amount : hint_range(0.0, 0.35) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV) * COLOR;
	float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 graded = mix(tex.rgb, vec3(lum), desaturation);
	graded = (graded - vec3(0.5)) * contrast + vec3(0.5);
	graded *= brightness;
	graded = mix(graded, tint_color.rgb, tint_amount);
	COLOR = vec4(clamp(graded, vec3(0.0), vec3(1.0)), tex.a);
}
