extends CharacterBody2D

@export var tile_size: int = 16
@export var move_speed: float = 80.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum Direction {
	DOWN,
	UP,
	LEFT,
	RIGHT
}

var facing: Direction = Direction.DOWN
var queued_direction: Direction = Direction.DOWN

var is_moving: bool = false
var target_position: Vector2


func _physics_process(delta: float) -> void:
	update_queued_input()

	if is_moving:
		move_to_tile(delta)
	else:
		process_idle_state()



func update_queued_input() -> void:
	if Input.is_action_just_pressed("arriba"):
		queued_direction = Direction.UP
	elif Input.is_action_just_pressed("abajo"):
		queued_direction = Direction.DOWN
	elif Input.is_action_just_pressed("izquierda"):
		queued_direction = Direction.LEFT
	elif Input.is_action_just_pressed("derecha"):
		queued_direction = Direction.RIGHT

	
	if not is_direction_pressed(queued_direction):
		if Input.is_action_pressed("arriba"):
			queued_direction = Direction.UP
		elif Input.is_action_pressed("abajo"):
			queued_direction = Direction.DOWN
		elif Input.is_action_pressed("izquierda"):
			queued_direction = Direction.LEFT
		elif Input.is_action_pressed("derecha"):
			queued_direction = Direction.RIGHT


func is_any_direction_pressed() -> bool:
	return (
		Input.is_action_pressed("arriba")
		or Input.is_action_pressed("abajo")
		or Input.is_action_pressed("izquierda")
		or Input.is_action_pressed("derecha")
	)


func is_direction_pressed(dir: Direction) -> bool:
	match dir:
		Direction.UP:
			return Input.is_action_pressed("arriba")
		Direction.DOWN:
			return Input.is_action_pressed("abajo")
		Direction.LEFT:
			return Input.is_action_pressed("izquierda")
		Direction.RIGHT:
			return Input.is_action_pressed("derecha")
	return false



func process_idle_state() -> void:
	if not is_any_direction_pressed():
		play_idle_animation()
		return

	if queued_direction != facing:
		facing = queued_direction
		play_idle_animation()
	else:
		start_move()


func start_move() -> void:
	is_moving = true
	target_position = position + direction_to_vector(facing) * tile_size
	play_run_animation()


func move_to_tile(delta: float) -> void:
	var step: float = move_speed * delta
	position = position.move_toward(target_position, step)

	if position.is_equal_approx(target_position):
		position = target_position
		is_moving = false



func direction_to_vector(dir: Direction) -> Vector2:
	match dir:
		Direction.UP:
			return Vector2.UP
		Direction.DOWN:
			return Vector2.DOWN
		Direction.LEFT:
			return Vector2.LEFT
		Direction.RIGHT:
			return Vector2.RIGHT
	return Vector2.ZERO



func play_run_animation() -> void:
	match facing:
		Direction.DOWN:
			sprite.play("RunDown")
			sprite.flip_h = false
		Direction.UP:
			sprite.play("RunUp")
			sprite.flip_h = false
		Direction.LEFT:
			sprite.play("RunLat")
			sprite.flip_h = false
		Direction.RIGHT:
			sprite.play("RunLat")
			sprite.flip_h = true


func play_idle_animation() -> void:
	match facing:
		Direction.DOWN:
			sprite.play("IdleDown")
			sprite.flip_h = false
		Direction.UP:
			sprite.play("IdleUp")
			sprite.flip_h = false
		Direction.LEFT:
			sprite.play("IdleLat")
			sprite.flip_h = false
		Direction.RIGHT:
			sprite.play("IdleLat")
			sprite.flip_h = true
