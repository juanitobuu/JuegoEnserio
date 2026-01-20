extends CanvasLayer


@onready var panel: Panel = $Panel
@onready var portrait: TextureRect = $Panel/Portrait
@onready var name_label: Label = $Panel/NameLabel
@onready var text_label: RichTextLabel = $Panel/TextLabel
@onready var continue_indicator: AnimatedSprite2D = $Panel/AnimatedSprite2D
@onready var choices_container: VBoxContainer = $ChoicesContainer


@export var typewriter_speed: float = 0.05
@export var fast_typewriter_speed: float = 0.01  


var current_text: String = ""
var current_character_index: int = 0
var is_typing: bool = false
var is_waiting_for_input: bool = false
var typewriter_timer: float = 0.0
var current_speed: float = 0.05


signal dialogue_finished
signal choice_selected(choice_index: int)

func _ready() -> void:
	hide_dialogue()
	continue_indicator.visible = false
	

	_animate_continue_indicator()

func _process(delta: float) -> void:
	if is_typing:
		typewriter_timer += delta
		
		if typewriter_timer >= current_speed:
			typewriter_timer = 0.0
			_show_next_character()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		if is_typing:

			_complete_text()
		elif is_waiting_for_input:

			emit_signal("dialogue_finished")


func show_dialogue(text: String, character_name: String = "", portrait_texture: Texture2D = null) -> void:
	current_text = text
	current_character_index = 0
	is_typing = true
	is_waiting_for_input = false
	current_speed = typewriter_speed
	

	visible = true
	panel.visible = true
	text_label.text = ""
	continue_indicator.visible = false
	choices_container.visible = false
	

	if character_name != "":
		name_label.text = character_name
		name_label.visible = true
	else:
		name_label.visible = false
	

	if portrait_texture:
		portrait.texture = portrait_texture
		portrait.visible = true
	else:
		portrait.visible = false


func show_choices(choices: Array) -> void:

	for child in choices_container.get_children():
		child.queue_free()
	

	for i in range(choices.size()):
		var button := Button.new()
		button.text = choices[i]
		button.pressed.connect(_on_choice_pressed.bind(i))
		choices_container.add_child(button)
	
	choices_container.visible = true
	is_waiting_for_input = false

func _on_choice_pressed(choice_index: int) -> void:
	choices_container.visible = false
	emit_signal("choice_selected", choice_index)


func hide_dialogue() -> void:
	visible = false
	panel.visible = false
	choices_container.visible = false
	is_typing = false
	is_waiting_for_input = false

func _show_next_character() -> void:
	if current_character_index < current_text.length():
		text_label.text += current_text[current_character_index]
		current_character_index += 1
		

	else:

		_on_typing_finished()

func _complete_text() -> void:
	text_label.text = current_text
	current_character_index = current_text.length()
	_on_typing_finished()

func _on_typing_finished() -> void:
	is_typing = false
	is_waiting_for_input = true
	continue_indicator.visible = true


func _animate_continue_indicator() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(continue_indicator, "modulate:a", 0.3, 0.5)
	tween.tween_property(continue_indicator, "modulate:a", 1.0, 0.5)
