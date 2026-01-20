extends CanvasLayer

@onready var cartel: AnimatedSprite2D = $Cartel
@onready var label: Label = $TimeLabel

var is_showing: bool = false


const FRAME_ROTATIONS := [
	deg_to_rad(-18), # 0
	deg_to_rad(12), # 1
	deg_to_rad(8), # 2
	deg_to_rad(6),  # 3
	deg_to_rad(4),  # 4
	deg_to_rad(-2),   # 5
	deg_to_rad(-5),   # 6
	deg_to_rad(-8),   # 7
	deg_to_rad(-4),   # 8
	0.0              # 9
]

func _ready() -> void:
	if not cartel:
		push_error("Cartel no encontrado")
		return
	if not label:
		push_error("TimeLabel no encontrado")
		return

	label.visible = false
	label.modulate.a = 0.0
	label.rotation = FRAME_ROTATIONS[0]

	cartel.visible = false
	cartel.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_time_hud") and not is_showing:
		show_time_info()


func show_time_info() -> void:
	is_showing = true

	label.text = "Día %d – %s" % [
		TimeManager.current_day,
		TimeManager.get_period_name()
	]

	cartel.visible = true
	cartel.modulate.a = 1.0
	cartel.frame = 0
	cartel.play("aparecer")

	label.visible = true
	label.modulate.a = 0.0
	label.rotation = FRAME_ROTATIONS[0]

	await cartel.animation_finished

	await get_tree().create_timer(3.0).timeout

	var tween_out := create_tween()
	tween_out.set_parallel(true)
	tween_out.tween_property(label, "modulate:a", 0.0, 0.5)
	tween_out.tween_property(cartel, "modulate:a", 0.0, 0.5)

	await tween_out.finished

	label.visible = false
	cartel.visible = false
	cartel.stop()

	is_showing = false


func _process(_delta: float) -> void:
	if not is_showing:
		return
	if not cartel.is_playing():
		return

	var frame := cartel.frame
	if frame >= FRAME_ROTATIONS.size():
		return

	label.rotation = FRAME_ROTATIONS[frame]

	if frame <= 4:
		label.modulate.a = frame / 4.0
	else:
		label.modulate.a = 1.0


func _get_next_period_name() -> String:
	match TimeManager.current_period:
		TimeManager.DayPeriod.MORNING:
			return "Tarde"
		TimeManager.DayPeriod.AFTERNOON:
			return "Noche"
		TimeManager.DayPeriod.NIGHT:
			return "Mañana (Día %d)" % (TimeManager.current_day + 1)
	return ""
