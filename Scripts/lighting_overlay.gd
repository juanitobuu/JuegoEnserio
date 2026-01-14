extends ColorRect

@export var morning_color: Color = Color(1.0, 1.0, 1.0, 0.0)
@export var afternoon_color: Color = Color(1.0, 0.7, 0.5, 0.25)
@export var night_color: Color = Color(0.1, 0.15, 0.3, 0.45)

@export var transition_time: float = 1.5

var tween: Tween


func _ready() -> void:
	color = morning_color


func set_period(period: int) -> void:
	var target_color: Color

	match period:
		0: # MORNING
			target_color = morning_color
		1: # AFTERNOON
			target_color = afternoon_color
		2: # NIGHT
			target_color = night_color
		_:
			return

	_smooth_transition(target_color)


func _smooth_transition(target: Color) -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.tween_property(self, "color", target, transition_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
