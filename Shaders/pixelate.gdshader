shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 256.0) = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// Obtener tamaño de pantalla
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	
	// Calcular tamaño de pixel
	vec2 pixelated_uv = floor(uv * screen_size / pixel_size) * pixel_size / screen_size;
	
	// Samplear textura usando el uniform
	COLOR = texture(screen_texture, pixelated_uv);
}