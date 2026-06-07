extends Control

@onready var slot_grid: GridContainer = $Background/MarginContainer/SlotGrid
@onready var cursor: Control = $Cursor

signal closed

# Dynamically set these in _ready based on the UI node
var grid_width: int = 5
var grid_height: int = 5

var current_selection := Vector2i.ZERO:
	set(value):
		var new_x = clampi(value.x, 0, grid_width - 1)
		var new_y = clampi(value.y, 0, grid_height - 1)
		var new_selection = Vector2i(new_x, new_y)
		
		var new_index = (new_selection.y * grid_width) + new_selection.x
		if new_index >= slot_grid.get_child_count():
			return # Reject the movement
			
		if current_selection != new_selection:
			current_selection = new_selection
			update_highlight()

func _ready() -> void:
	# 5. Dynamically grab the grid dimensions directly from the node!
	if slot_grid is GridContainer:
		grid_width = slot_grid.columns
		grid_height = ceil(slot_grid.get_child_count() / float(grid_width))
		
	call_deferred("update_highlight")

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return 

	var move_dir := Vector2i.ZERO
	
	if event.is_action_pressed("move_right", true): move_dir.x += 1
	elif event.is_action_pressed("move_left", true): move_dir.x -= 1
	elif event.is_action_pressed("move_down", true): move_dir.y += 1
	elif event.is_action_pressed("move_up", true): move_dir.y -= 1

	if move_dir != Vector2i.ZERO:
		current_selection += move_dir

	if event.is_action_pressed("interact"):
		_use_item()
		close_inventory()

func _use_item() -> void:
	var current_slot = _get_current_slot()
	if current_slot == null:
		return
	if current_slot.item_data != null:
		print("Used item: ", current_slot.item_data.name)
	else:
		print("No item in the selected slot to use.")

func update_highlight() -> void:
	var slot_index = (current_selection.y * grid_width) + current_selection.x
	
	if slot_index >= 0 and slot_index < slot_grid.get_child_count():
		var target_slot = slot_grid.get_child(slot_index)
		cursor.global_position = target_slot.global_position
		cursor.size = target_slot.size
	else:
		push_error("Tried to highlight an invalid slot index: ", slot_index)

func _get_current_slot() -> Control:
	var slot_index = (current_selection.y * grid_width) + current_selection.x
	if slot_index >= 0 and slot_index < slot_grid.get_child_count():
		return slot_grid.get_child(slot_index)
	return null

func open_inventory() -> void:
	show()
	current_selection = Vector2i.ZERO 
	call_deferred("update_highlight")

func close_inventory() -> void:
	hide()
	closed.emit()
