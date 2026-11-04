extends Node2D

const FILL_PERCENTAGE: float = 0.4
const ROCK_SCENE = preload("res://scenes/rock.tscn")

@onready var rock_container : Node2D = $RockContainer
@onready var current_map : Node2D = $Map
@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_position_objects()
	_generate_rocks()

func _position_objects() -> void:
	var player_spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.reset(player_spawn.position)

func _generate_rocks() -> void:
	# Clear existing rocks
	for child in rock_container.get_children():
		child.queue_free()
	
	# Get tilemap layers from current map
	var ground_layer : TileMapLayer = current_map.get_node("Ground")
	var props_layer : TileMapLayer = current_map.get_node("Props")
	var ground_cells := ground_layer.get_used_cells()
	var available_cells := []
	
	for cell in ground_cells:
		# Get the tile data for this specific coordinate
		var tile_data = ground_layer.get_cell_tile_data(cell)
	
		# Check if there are any props in the way
		# get_cell_sources returns -1 if the cell is empty
		if props_layer.get_cell_source_id(cell) != -1:
			continue
		
		# Check if this tile has the 'can_spawn_rocks' property set to true
		if tile_data and tile_data.get_custom_data("can_spawn_rocks") == true:
			available_cells.append(cell)
	
	available_cells.shuffle()
	
	var num_rocks := int(available_cells.size() * FILL_PERCENTAGE)
	
	for i in range(num_rocks):
		var cell = available_cells[i]
		var rock = ROCK_SCENE.instantiate()
		
		# Get local position from tilemap
		var local_pos = ground_layer.map_to_local(cell)
		
		rock.global_position = local_pos
		rock_container.add_child(rock)
