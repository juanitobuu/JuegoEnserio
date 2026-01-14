extends CanvasLayer

@onready var label: Label = $TimeLabel
var is_showing: bool = false

func _ready() -> void:
	label.visible = false
	label.modulate.a = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_time_hud") and not is_showing:
		show_time_info()

func show_time_info() -> void:
	is_showing = true
	
	
	var time_remaining: float = TimeManager.seconds_per_period - TimeManager.period_timer
	var minutes: int = int(time_remaining / 60)
	var seconds: int = int(time_remaining) % 60
	
	
	var next_period: String = _get_next_period_name()
	
	
	label.text = "Día %d – %s\nSiguiente: %s en %d:%02d" % [
		TimeManager.current_day,
		TimeManager.get_period_name(),
		next_period,
		minutes,
		seconds
	]
	
	label.visible = true
	
	
	var tween_in := create_tween()
	tween_in.tween_property(label, "modulate:a", 1.0, 0.3)
	await tween_in.finished
	
	
	await get_tree().create_timer(3.0).timeout
	
	
	var tween_out := create_tween()
	tween_out.tween_property(label, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	
	label.visible = false
	is_showing = false

func _get_next_period_name() -> String:
	match TimeManager.current_period:
		TimeManager.DayPeriod.MORNING:
			return "Tarde"
		TimeManager.DayPeriod.AFTERNOON:
			return "Noche"
		TimeManager.DayPeriod.NIGHT:
			return "Mañana (Día %d)" % (TimeManager.current_day + 1)
	return ""
