extends Node2D

@onready var protagonista := $EvanCinematica
@onready var prota_sprite := $EvanCinematica/AnimatedSprite2D

@onready var npc := $Viejito1
@onready var npc_sprite := $Viejito1/AnimatedSprite2D

@onready var fade_rect: ColorRect = $FadeLayer/FadeRect

@export var dialogue_intro: DialogueData
@export var npc_speed: float = 60.0


func _ready() -> void:
	start_cinematica()


func start_cinematica() -> void:

	await fade_in()

	prota_sprite.play("Durmiendo")

	await get_tree().create_timer(4.0).timeout

	npc.visible = true
	npc_sprite.play("RunUp")

	prota_sprite.play("sentadocama")

	npc_sprite.play("RunUp")
	await mover_npc(Vector2.UP, 32)

	npc_sprite.play("RunLat")
	await mover_npc(Vector2.LEFT, 64)

	npc_sprite.play("RunUp")
	await mover_npc(Vector2.UP, 50)

	npc_sprite.play("IdleUp")

	if dialogue_intro:
		DialogueManager.start_dialogue(dialogue_intro.lines)

		await DialogueManager.dialogue_ended

	await fade_out()

	get_tree().change_scene_to_file("res://Escenas/Casas/casa_inicio.tscn")


func mover_npc(direccion: Vector2, distancia: float) -> void:
	var inicio: Vector2 = npc.position
	var destino: Vector2 = inicio + direccion.normalized() * distancia

	while npc.position.distance_to(destino) > 1.0:
		npc.position += direccion.normalized() * npc_speed * get_process_delta_time()
		await get_tree().process_frame

	npc.position = destino



func fade_out(duration: float = 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await tween.finished


func fade_in(duration: float = 1.0) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
	
