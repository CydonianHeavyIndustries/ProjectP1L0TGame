shader_type spatial;

uniform vec3 brick_color : source_color = vec3(0.86, 0.82, 0.74);
uniform vec3 brick_color_alt : source_color = vec3(0.8, 0.76, 0.68);
uniform vec3 mortar_color : source_color = vec3(0.65, 0.62, 0.58);
uniform vec2 uv_scale = vec2(5.0, 5.0);
uniform vec2 brick_size = vec2(1.0, 0.5);
uniform float mortar = 0.08;
uniform float roughness = 0.85;
uniform float metallic = 0.05;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV * uv_scale;
	vec2 grid = uv / brick_size;
	float row = floor(grid.y);
	float offset = mod(row, 2.0) * 0.5;
	float x = grid.x + offset;
	vec2 cell = vec2(fract(x), fract(grid.y));
	float mortar_mask = step(cell.x, mortar) + step(1.0 - mortar, cell.x)
		+ step(cell.y, mortar) + step(1.0 - mortar, cell.y);
	mortar_mask = clamp(mortar_mask, 0.0, 1.0);

	float h = hash21(vec2(floor(x), row));
	vec3 brick = mix(brick_color, brick_color_alt, h * 0.35);
	vec3 color = mix(brick, mortar_color, mortar_mask);
	ALBEDO = color;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
