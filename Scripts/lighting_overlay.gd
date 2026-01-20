extends ColorRect

@export var morning_color: Color = Color(1.0, 1.0, 1.0, 0.0)
@export var afternoon_color: Color = Color(1.0, 0.7, 0.5, 0.25)
@export var night_color: Color = Color(0.1, 0.15, 0.3, 0.45)

@export var transition_time: float = 1.5

var tween: Tween


func _ready() -> void:
	set_period(TimeManager.current_period, true)

	if not TimeManager.period_changed.is_connected(_on_period_changed):
		TimeManager.period_changed.connect(_on_period_changed)


func _exit_tree() -> void:
	if TimeManager.period_changed.is_connected(_on_period_changed):
		TimeManager.period_changed.disconnect(_on_period_changed)


func _on_period_changed(day: int, period: int) -> void:
	set_period(period)


func set_period(period: int, instant: bool = false) -> void:
	var target_color: Color

	match period:
		TimeManager.DayPeriod.MORNING:
			target_color = morning_color
		TimeManager.DayPeriod.AFTERNOON:
			target_color = afternoon_color
		TimeManager.DayPeriod.NIGHT:
			target_color = night_color
		_:
			return

	if instant:
		color = target_color
	else:
		_smooth_transition(target_color)


func _smooth_transition(target: Color) -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "color", target, transition_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
