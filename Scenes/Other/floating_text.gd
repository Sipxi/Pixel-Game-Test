extends Node2D

@export var float_speed: float = 40.0
@export var lifetime: float = 3.0

var time_passed: float = 0.0

@onready var label: Label = $text_label

func _ready() -> void:
	modulate.a = 1.0 # Ensure the label starts fully visible
	label.add_theme_font_size_override("font_size", 6) 


func set_text(new_text: String) -> void:
	label.text = new_text

func _process(delta: float) -> void:
	
	position.y -= float_speed * delta # Move the label upwards
	time_passed += delta

	var t = time_passed / lifetime

	modulate.a = 1.0 - t # Fade out over time

	if time_passed >= lifetime:
		queue_free() # Remove the label from the scene when its lifetime is over
