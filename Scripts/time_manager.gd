extends Node


@export var seconds_per_period: float = 120.0
@export var max_days: int = 4


enum DayPeriod {
	MORNING,
	AFTERNOON,
	NIGHT
}


var current_day: int = 1
var current_period: DayPeriod = DayPeriod.MORNING
var period_timer: float = 0.0


signal period_changed(day: int, period: DayPeriod)
signal day_changed(day: int)


var lighting_overlay: ColorRect = null

func _ready() -> void:
	
	lighting_overlay = get_node_or_null("../Tiempoenpantalla/LightingOverlay")
	
	if lighting_overlay == null:
		push_warning("LightingOverlay no encontrado. Buscando en toda la escena...")
		lighting_overlay = get_tree().current_scene.find_child("LightingOverlay", true, false)
	
	if lighting_overlay:
		
		lighting_overlay.set_period(current_period)
	else:
		push_error("No se pudo encontrar LightingOverlay")

func _process(delta: float) -> void:
	period_timer += delta
	
	if period_timer >= seconds_per_period:
		period_timer = 0.0
		advance_period()
	
	_print_time_debug()

# 
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("time_forward"):
		skip_time_forward()
	elif event.is_action_pressed("time_backward"):
		skip_time_backward()

func skip_time_forward() -> void:
	
	period_timer = 0.0
	
	
	match current_period:
		DayPeriod.MORNING:
			current_period = DayPeriod.AFTERNOON
		DayPeriod.AFTERNOON:
			current_period = DayPeriod.NIGHT
		DayPeriod.NIGHT:
			current_period = DayPeriod.MORNING
			advance_day()
	
	_update_lighting()
	emit_signal("period_changed", current_day, current_period)
	_print_time_debug(true)

func skip_time_backward() -> void:
	period_timer = 0.0
	
	match current_period:
		DayPeriod.MORNING:
			current_period = DayPeriod.NIGHT
			current_day -= 1
			if current_day < 1:
				current_day = max_days
			emit_signal("day_changed", current_day)
		DayPeriod.AFTERNOON:
			current_period = DayPeriod.MORNING
		DayPeriod.NIGHT:
			current_period = DayPeriod.AFTERNOON
	
	_update_lighting()
	emit_signal("period_changed", current_day, current_period)
	_print_time_debug(true)


func advance_period() -> void:
	match current_period:
		DayPeriod.MORNING:
			current_period = DayPeriod.AFTERNOON
		DayPeriod.AFTERNOON:
			current_period = DayPeriod.NIGHT
		DayPeriod.NIGHT:
			current_period = DayPeriod.MORNING
			advance_day()
	
	_update_lighting()
	emit_signal("period_changed", current_day, current_period)

func advance_day() -> void:
	current_day += 1
	if current_day > max_days:
		current_day = 1
	emit_signal("day_changed", current_day)


func _update_lighting() -> void:
	if lighting_overlay:
		lighting_overlay.set_period(current_period)


func get_period_name() -> String:
	match current_period:
		DayPeriod.MORNING:
			return "Mañana"
		DayPeriod.AFTERNOON:
			return "Tarde"
		DayPeriod.NIGHT:
			return "Noche"
	return ""

func _print_time_debug(force: bool = false) -> void:
	if force:
		print_time()
	elif int(period_timer) % 5 == 0:
		print_time()

func print_time() -> void:
	print(
		"[TIEMPO] Día ",
		current_day,
		" | ",
		get_period_name(),
		" | ",
		"Progreso: ",
		round(period_timer),
		"/",
		seconds_per_period,
		" s"
	)
