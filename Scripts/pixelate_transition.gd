extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

var pixelate_shader: Shader
var tween: Tween

func _ready() -> void:
	pixelate_shader = preload("res://Shaders/pixelate.gdshader")
	
	if color_rect:
		var shader_material := ShaderMaterial.new()
		shader_material.shader = pixelate_shader
		color_rect.material = shader_material
		
		shader_material.set_shader_parameter("pixel_size", 1.0)
		color_rect.visible = false

func pixelate_in() -> void:
	if not color_rect:
		return
	
	color_rect.visible = true
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(
		_set_pixel_size,
		1.0,    
		128.0,   
		0.5       
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func pixelate_out() -> void:
	if not color_rect:
		return
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(
		_set_pixel_size,
		128.0,  
		1.0,   
		0.5     
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	color_rect.visible = false

func _set_pixel_size(value: float) -> void:
	if color_rect and color_rect.material:
		color_rect.material.set_shader_parameter("pixel_size", value)
