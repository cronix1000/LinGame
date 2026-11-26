shader_type canvas_item;

// Animated water. Assign as a ShaderMaterial on the "Lake" TileMapLayer
// (or on any Polygon2D drawn over water). Ripples run in WORLD space so
// they stay seamless across tilemap tiles.

uniform vec4 deep_color : source_color = vec4(0.07, 0.28, 0.55, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.35, 0.75, 0.85, 1.0);
uniform float wave_speed : hint_range(0.0, 4.0) = 0.9;
uniform float wave_scale : hint_range(0.01, 1.0) = 0.12;
uniform float tint_strength : hint_range(0.0, 1.0) = 0.45;
uniform float sparkle_strength : hint_range(0.0, 1.0) = 0.35;

varying vec2 world_pos;

void vertex() {
	// model -> world so the whole lake waves as one body of water
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 tile = texture(TEXTURE, UV);

	// two crossing sine waves = moving ripples (-1..1)
	float w1 = sin(world_pos.x * wave_scale + TIME * wave_speed * 2.0);
	float w2 = sin((world_pos.x + world_pos.y) * wave_scale * 0.7 - TIME * wave_speed * 1.4);
	float ripple = w1 * 0.5 + w2 * 0.5;

	// tint the tile art between deep and shallow along the ripples
	vec3 water = mix(deep_color.rgb, shallow_color.rgb, ripple * 0.5 + 0.5);
	vec3 col = mix(tile.rgb, water, tint_strength);
	col += water * ripple * 0.15; // crest highlight

	// tiny twinkles where the two waves cross
	float twinkle = sin(world_pos.x * 1.4 + TIME * 2.2) * sin(world_pos.y * 1.8 - TIME * 1.7);
	col += vec3(1.0) * smoothstep(0.93, 1.0, twinkle) * sparkle_strength;

	COLOR = vec4(col, tile.a);
}
