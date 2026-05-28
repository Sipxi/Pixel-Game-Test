extends Area2D

@export var object_name: String = "Interactable Object"

# This function will be called when the player interacts with this object
func interact() -> void:
	print("Interacted with: " + object_name)
