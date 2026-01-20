extends Node2D

@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect
@onready var salir_area: Area2D = $SalirCasa 

var player_inside: bool = false
var is_fading: bool = false



func _ready() -> void:

	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 1.0
	fade_rect.visible = true


	salir_area.body_entered.connect(_on_salir_body_entered)
	salir_area.body_exited.connect(_on_salir_body_exited)


	await fade_in(1.2)
	

	fade_rect.modulate.a = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_inside and not is_fading:
		start_exit()  

func start_exit() -> void:
	is_fading = true  
	await fade_out(1.0)
	get_tree().change_scene_to_file("res://Escenas/Zonas/primera_zona.tscn")  


func _on_salir_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		player_inside = true
		print("Jugador en área de salida") 

func _on_salir_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		player_inside = false
		print("Jugador salió del área")  


func fade_in(duration: float = 1.0) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished

func fade_out(duration: float = 1.0) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await tween.finished
