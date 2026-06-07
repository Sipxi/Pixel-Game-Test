extends Area2D
@export var object_name: String = "Interactable Object"
@export var floating_text_scene: PackedScene
@export var dialogue_file: DialogueResource
@export var dialogue_start: String = "start"

func interact() -> void:
	if dialogue_file:
		DialogueManager.show_dialogue_balloon(dialogue_file, dialogue_start)
		return
	# Fallback to floating text if no dialogue assigned
	var floating_text = floating_text_scene.instantiate()
	get_tree().current_scene.add_child(floating_text)
	floating_text.set_text("You interacted with: %s" % object_name)
	floating_text.global_position = $TextSpawnPoint.global_position
