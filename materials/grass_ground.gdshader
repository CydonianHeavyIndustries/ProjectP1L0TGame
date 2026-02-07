shader_type spatial;

uniform vec3 base_color : source_color = vec3(0.05, 0.22, 0.09);
uniform vec3 grass_color : source_color = vec3(0.12, 0.38, 0.16);
uniform vec3 dirt_color : source_color = vec3(0.04, 0.16, 0.06);
uniform vec2 uv_scale = vec2(6.0, 6.0);
uniform float roughness = 0.95;
uniform float metallic = 0.0;

float hash12(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.6;
	for (int i = 0; i < 4; i++) {
		value += amp * noise(p);
		p *= 2.1;
		amp *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 uv = UV * uv_scale;
	float base_noise = fbm(uv * 0.9);
	float grass_noise = fbm(uv * 1.8 + vec2(12.3, 4.7));
	float patches = smoothstep(0.2, 0.7, base_noise);
	float blades = smoothstep(0.45, 0.85, grass_noise);
	vec3 base = mix(dirt_color, base_color, patches);
	vec3 color = mix(base, grass_color, blades * 0.65);
	ALBEDO = color;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
