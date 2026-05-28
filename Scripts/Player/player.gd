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

var _facing_direction: FacingDirection = FacingDirection.DOWN

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
	if !event.is_action_pressed("interact"):
		return

	for area in interaction_detector.get_overlapping_areas():
		if area.is_in_group("interactable"):
			area.interact()
			return
				
func _update_animation() -> void:
	var animation_name = ""

	if velocity == Vector2.ZERO:
		match _facing_direction:
			FacingDirection.UP:
				animation_name = "idle_up"
			FacingDirection.DOWN:
				animation_name = "idle_down"
			FacingDirection.LEFT:
				animation_name = "idle_left"
			FacingDirection.RIGHT:
				animation_name = "idle_right"
	else:
		match _facing_direction:
			FacingDirection.UP:
				animation_name = "walk_up"
			FacingDirection.DOWN:
				animation_name = "walk_down"
			FacingDirection.LEFT:
				animation_name = "walk_left"
			FacingDirection.RIGHT:
				animation_name = "walk_right"
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
		
func _physics_process(_delta) -> void:
	_get_input()
	_update_direction()
	_update_animation()
	move_and_slide()
