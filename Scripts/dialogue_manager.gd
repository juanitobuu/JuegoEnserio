extends Node


var dialogue_box: CanvasLayer = null


var current_dialogue_data: Array[Dictionary] = []
var current_dialogue_index: int = 0


signal dialogue_started
signal dialogue_ended

func _ready() -> void:

	var dialogue_box_scene := preload("res://Dialogos/dialogue_box.tscn")
	dialogue_box = dialogue_box_scene.instantiate()
	add_child(dialogue_box)
	

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_box.choice_selected.connect(_on_choice_selected)


func start_dialogue(dialogue_data: Array[Dictionary]) -> void:
	if dialogue_data.is_empty():
		push_warning("Diálogo vacío")
		return
	
	current_dialogue_data = dialogue_data
	current_dialogue_index = 0
	
	emit_signal("dialogue_started")
	_show_current_dialogue()


func _show_current_dialogue() -> void:
	if current_dialogue_index >= current_dialogue_data.size():
		_end_dialogue()
		return
	
	var dialogue: Dictionary = current_dialogue_data[current_dialogue_index]
	

	if dialogue.has("condition"):
		var condition: Dictionary = dialogue.condition as Dictionary
		if not _check_condition(condition):
			current_dialogue_index += 1
			_show_current_dialogue()
			return
	

	var text: String = dialogue.get("text", "")
	var character_name: String = dialogue.get("name", "")
	var portrait_path: String = dialogue.get("portrait", "")
	
	var portrait_texture: Texture2D = null
	if portrait_path != "":
		portrait_texture = load(portrait_path)
	
	dialogue_box.show_dialogue(text, character_name, portrait_texture)
	

	if dialogue.has("choices"):
		await dialogue_box.dialogue_finished
		var choices: Array = dialogue.choices as Array
		dialogue_box.show_choices(choices)

func _on_dialogue_finished() -> void:
	current_dialogue_index += 1
	_show_current_dialogue()

func _on_choice_selected(choice_index: int) -> void:
	var dialogue: Dictionary = current_dialogue_data[current_dialogue_index]
	
	if dialogue.has("branches"):
		var branches: Array = dialogue.branches as Array
		var branch: Variant = branches[choice_index]
		

		current_dialogue_index += 1
		

		if branch is Array:
			var branch_array: Array = branch as Array
			for i in range(branch_array.size()):
				var branch_dict: Dictionary = branch_array[i] as Dictionary
				current_dialogue_data.insert(current_dialogue_index + i, branch_dict)
		
		_show_current_dialogue()

func _end_dialogue() -> void:
	dialogue_box.hide_dialogue()
	emit_signal("dialogue_ended")


func _check_condition(condition: Dictionary) -> bool:
	if condition.has("day"):
		if TimeManager.current_day != condition.day:
			return false
	
	if condition.has("period"):
		if TimeManager.current_period != condition.period:
			return false
	
	return true
