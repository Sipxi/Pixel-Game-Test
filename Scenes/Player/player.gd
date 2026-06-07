extends CharacterBody2D

enum FacingDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var speed: float = 70.0

# ====== Node References =====
@onready var animated_sprite: AnimatedSprite2D = $Sprite
@onready var interaction_detector: Area2D = $InteractionDetector
@onready var inventory_ui = $UI/InventoryUI


var is_inventory_open := false
var _facing_direction: FacingDirection = FacingDirection.DOWN

func _ready() -> void:
	inventory_ui.connect("closed", func(): is_inventory_open = false)
	DialogueManager.dialogue_started.connect(func(_r): is_inventory_open = true)
	DialogueManager.dialogue_ended.connect(func(_r): is_inventory_open = false)
	
func _get_input() -> void:
	var input_direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	velocity = input_direction * speed

func _update_direction() -> void:
	if velocity.x > 0:
		_facing_direction = FacingDirection.RIGHT
		interaction_detector.rotation_degrees = -90
	elif velocity.x < 0:
		_facing_direction = FacingDirection.LEFT
		interaction_detector.rotation_degrees = 90
	elif velocity.y > 0:
		_facing_direction = FacingDirection.DOWN
		interaction_detector.rotation_degrees = 0
	elif velocity.y < 0:
		_facing_direction = FacingDirection.UP
		interaction_detector.rotation_degrees = 180

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for area in interaction_detector.get_overlapping_areas():
			if area.is_in_group("interactable"):
				area.interact()
				return
	if event.is_action_pressed("toggle_inventory"):
		if inventory_ui.visible:
			inventory_ui.close_inventory()
			is_inventory_open = false # Unfreeze player
		else:
			inventory_ui.open_inventory()
			is_inventory_open = true # Freeze player

func _match_idle_animation() -> String:
	match _facing_direction:
		FacingDirection.UP:
			return "idle_up"
		FacingDirection.DOWN:
			return "idle_down"
		FacingDirection.LEFT:
			return "idle_left"
		FacingDirection.RIGHT:
			return "idle_right"
	return "idle_down" # Default fallback

func _match_walk_animation() -> String:
	match _facing_direction:
		FacingDirection.UP:
			return "walk_up"
		FacingDirection.DOWN:
			return "walk_down"
		FacingDirection.LEFT:
			return "walk_left"
		FacingDirection.RIGHT:
			return "walk_right"
	return "walk_down" # Default fallback				
	
func _play_animation(animation_name: String) -> void:
	if animated_sprite.animation != animation_name:
		animated_sprite.animation = animation_name
		animated_sprite.play()

func _update_animation() -> void:
	var animation_name = ""

	if velocity == Vector2.ZERO:
		animation_name = _match_idle_animation()
	else:
		animation_name = _match_walk_animation()
	_play_animation(animation_name)

		
func _physics_process(_delta) -> void:
	if is_inventory_open:
		velocity = Vector2.ZERO
		move_and_slide()
		animated_sprite.animation = _match_idle_animation() # Force idle pose when inventory is open
		_play_animation(animated_sprite.animation)
		return

	_get_input()
	_update_direction()
	_update_animation()
	move_and_slide()
