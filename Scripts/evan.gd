extends CharacterBody2D

@export var move_speed: float = 80.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum Direction {
	DOWN,
	UP,
	LEFT,
	RIGHT
}

var facing: Direction = Direction.DOWN
var is_moving: bool = false
var last_pressed_action: String = ""  # NUEVO: Rastrear última tecla presionada

# ====== Sistema de caída ======
var is_falling: bool = false
var last_safe_position: Vector2
var is_in_pit_area: bool = false
var original_sprite_offset: Vector2

func _ready() -> void:
	# Guardar posición inicial como segura
	last_safe_position = position
	
	# Guardar offset original del sprite
	original_sprite_offset = sprite.offset
	
	# Conectar señal de animación terminada
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Si está cayendo, no procesar movimiento
	if is_falling:
		return
	
	# Guardar posición segura solo si no está en área de caída
	if not is_in_pit_area:
		last_safe_position = position
	
	# Obtener dirección de input (última tecla presionada gana)
	var input_vector := get_input_vector_last_pressed()
	
	if input_vector != Vector2.ZERO:
		# Hay movimiento
		update_facing_direction(input_vector)
		velocity = input_vector * move_speed
		is_moving = true
		play_run_animation()
	else:
		# Sin movimiento
		velocity = Vector2.ZERO
		is_moving = false
		play_idle_animation()
	
	# Mover el personaje
	move_and_slide()

# ====== Función llamada por el Area2D ======
# ====== Función llamada por el Area2D ======
func fall_into_pit() -> void:
	if is_falling:
		return
	
	is_falling = true
	velocity = Vector2.ZERO
	
	# Calcular posición segura con offset hacia atrás
	var safe_offset := Vector2.ZERO
	match facing:
		Direction.DOWN:
			safe_offset = Vector2.UP * 32  # 32 píxeles hacia arriba
		Direction.UP:
			safe_offset = Vector2.DOWN * 32  # 32 píxeles hacia abajo
		Direction.LEFT:
			safe_offset = Vector2.RIGHT * 32  # 32 píxeles a la derecha
		Direction.RIGHT:
			safe_offset = Vector2.LEFT * 32  # 32 píxeles a la izquierda
	
	# Guardar posición segura ajustada
	last_safe_position = position + safe_offset
	
	# Mover sprite hacia abajo
	sprite.offset.y = original_sprite_offset.y + 8
	
	# Reproducir animación de caída
	sprite.play("caida")

# ====== Cuando termina la animación ======
func _on_animation_finished() -> void:
	if sprite.animation == "caida":
		# Iniciar transición de pixelado
		await _pixelate_transition()
		
		# Teletransportar a última posición segura
		position = last_safe_position
		is_falling = false
		is_in_pit_area = false
		velocity = Vector2.ZERO
		
		# Restaurar offset original
		sprite.offset = original_sprite_offset
		
		# Volver a animación idle
		play_idle_animation()

# ====== Transición de pixelado ======
func _pixelate_transition() -> void:
	var transition_layer := get_node_or_null("../PixelateTransition")
	
	if transition_layer == null:
		push_warning("PixelateTransition no encontrado")
		await get_tree().create_timer(2.0).timeout
		return
	
	# Pixelar entrada
	transition_layer.pixelate_in()
	await get_tree().create_timer(2.0).timeout
	
	# Pixelar salida
	transition_layer.pixelate_out()

# ====== NUEVO: Sistema de última tecla presionada ======
func get_input_vector_last_pressed() -> Vector2:
	var input := Vector2.ZERO
	
	# Detectar última tecla presionada
	if Input.is_action_just_pressed("arriba"):
		last_pressed_action = "arriba"
	elif Input.is_action_just_pressed("abajo"):
		last_pressed_action = "abajo"
	elif Input.is_action_just_pressed("izquierda"):
		last_pressed_action = "izquierda"
	elif Input.is_action_just_pressed("derecha"):
		last_pressed_action = "derecha"
	
	# Aplicar movimiento según última tecla presionada
	match last_pressed_action:
		"arriba":
			if Input.is_action_pressed("arriba"):
				input.y = -1
			else:
				last_pressed_action = ""  # Resetear si ya no está presionada
		"abajo":
			if Input.is_action_pressed("abajo"):
				input.y = 1
			else:
				last_pressed_action = ""
		"izquierda":
			if Input.is_action_pressed("izquierda"):
				input.x = -1
			else:
				last_pressed_action = ""
		"derecha":
			if Input.is_action_pressed("derecha"):
				input.x = 1
			else:
				last_pressed_action = ""
	
	# Si la última tecla ya no está presionada, buscar otra que esté activa
	if input == Vector2.ZERO:
		if Input.is_action_pressed("arriba"):
			input.y = -1
			last_pressed_action = "arriba"
		elif Input.is_action_pressed("abajo"):
			input.y = 1
			last_pressed_action = "abajo"
		elif Input.is_action_pressed("derecha"):
			input.x = 1
			last_pressed_action = "derecha"
		elif Input.is_action_pressed("izquierda"):
			input.x = -1
			last_pressed_action = "izquierda"
	
	return input

# ====== Actualizar dirección según movimiento ======
func update_facing_direction(input_vector: Vector2) -> void:
	if input_vector.y < 0:
		facing = Direction.UP
	elif input_vector.y > 0:
		facing = Direction.DOWN
	elif input_vector.x > 0:
		facing = Direction.RIGHT
	elif input_vector.x < 0:
		facing = Direction.LEFT

# ====== Animaciones ======
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
