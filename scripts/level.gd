extends Node2D

const FILL_PERCENTAGE: float = 0.35
const ROCK_SCENE = preload("res://scenes/rock.tscn")

const ROCK_STONE = preload("res://data/rocks/stone.tres")
const ROCK_COAL = preload("res://data/rocks/coal.tres")
const ROCK_TIN = preload("res://data/rocks/tin.tres")
const ROCK_IRON = preload("res://data/rocks/iron.tres")
const ROCK_SILVER = preload("res://data/rocks/silver.tres")
const ROCK_GOLD = preload("res://data/rocks/gold.tres")
const ROCK_AMETHYST = preload("res://data/rocks/amethyst.tres")
const ROCK_DIAMOND = preload("res://data/rocks/diamond.tres")

@onready var rock_container : Node2D = $RockContainer
@onready var current_map : Node2D = $Map
@onready var player: Player = $Player
@onready var canvas_modulate: CanvasModulate = $CanvasModulate

@onready var mist_sound : AudioStreamPlayer = $MistSound
@onready var ambient_damp_cave : AudioStreamPlayer = $AmbientDampCave

# Variabel untuk interaksi tangganya
@onready var ladder_up_area: Area2D = $LadderUpArea
@onready var ladder_up_label: Label = $LadderUpArea/PromptLabel
@onready var ladder_down_area: Area2D = $LadderDownArea
@onready var ladder_down_label: Label = $LadderDownArea/PromptLabel

var player_near_ladder_up: bool = false
var player_near_ladder_down: bool = false

var game_manager: Node:
	get:
		if is_inside_tree() and get_tree().root:
			return get_tree().root.get_node_or_null("GameManager")
		return null

func _ready() -> void:
	if game_manager:
		ambient_damp_cave.playSound()
		if game_manager.current_depth < 1:
			game_manager.current_depth = 1
	
	_apply_depth_atmosphere()
	_position_objects()
	_generate_rocks()
	_setup_ladders()
	
	# Bagian yang memberikan banner informasi saat memasuki goa, berganti kedalaman goa dan keluar
	if game_manager:
		var names = ["", "Goa Dangkal (Shallow Mine)", "Goa Besi (Iron Caverns)", "Gua Emas (Golden Grotto)", "Kedalaman Kristal (Crystal Depths)", "THE ABYSS BIOME ☠️"]
		var d = game_manager.current_depth
		var title = "LANTAI %d: %s" % [d, names[min(d, 5)]]
		game_manager.message_shown.emit(title)
		game_manager.stats_changed.emit()

func _apply_depth_atmosphere() -> void:
	var depth = game_manager.current_depth if game_manager else 1
	match depth:
		1:
			mist_sound.stopSound()
			ambient_damp_cave.playSound()
			canvas_modulate.color = Color.WHITE
		2:
			mist_sound.stopSound()
			ambient_damp_cave.playSound()
			canvas_modulate.color = Color(0.85, 0.88, 0.95) # cool stone
		3:
			ambient_damp_cave.stopSound()
			mist_sound.playSound()
			canvas_modulate.color = Color(1.1, 0.95, 0.75) # golden glow
		4:
			ambient_damp_cave.stopSound()
			mist_sound.playSound()
			canvas_modulate.color = Color(0.7, 0.9, 1.15) # crystal blue
		5:
			ambient_damp_cave.stopSound()
			mist_sound.playSound()
			canvas_modulate.color = Color(0.75, 0.45, 0.85) # deep purple Abyss

func _setup_ladders() -> void:
	var depth = game_manager.current_depth if game_manager else 1
	
	# Bagian yang menangani tangga naiknya
	ladder_up_area.body_entered.connect(func(b): if b is Player: player_near_ladder_up = true; ladder_up_label.visible = true)
	ladder_up_area.body_exited.connect(func(b): if b is Player: player_near_ladder_up = false; ladder_up_label.visible = false)
	ladder_up_label.visible = false
	if depth == 1:
		ladder_up_label.text = "[E] Kembali ke Desa"
	else:
		ladder_up_label.text = "[E] Naik ke Lantai %d" % [depth - 1]
		
	# Bagian yang menangani tangga turunnya
	ladder_down_area.body_entered.connect(func(b): if b is Player: player_near_ladder_down = true; ladder_down_label.visible = true)
	ladder_down_area.body_exited.connect(func(b): if b is Player: player_near_ladder_down = false; ladder_down_label.visible = false)
	ladder_down_label.visible = false
	if depth < 5:
		ladder_down_label.text = "[E] Turun ke Lantai %d" % [depth + 1]
	else:
		ladder_down_label.text = "★ Inti Terdalam Abyss ★"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		var depth = game_manager.current_depth if game_manager else 1
		if player_near_ladder_up:
			if depth <= 1:
				if game_manager:
					game_manager.go_to_town(true)
			else:
				if game_manager: 
					game_manager.go_to_mine_level(depth - 1)
		
		elif player_near_ladder_down:
			if depth < 5:
				if game_manager: 
					game_manager.go_to_mine_level(depth + 1)
					
			else:
				if game_manager:
					game_manager.message_shown.emit("Kamu berada di kedalaman terdalam Abyss!")

func _position_objects() -> void:
	var player_spawn: Marker2D = current_map.get_node_or_null("PlayerSpawn")
	var spawn_pos = Vector2(200, -8)
	if player_spawn:
		spawn_pos = player_spawn.position
	player.reset(spawn_pos)
	
	# Bagian yang menyetel posisi tangga pada bagian yang bisa dilewati dalam tambangnya
	ladder_up_area.position = Vector2(200, -32)
	ladder_down_area.position = Vector2(200, 184)
	
	# Bagian yang mengatur batasan Camera2D agar kamera tetap berada di dalam ruang goa!
	var cam = player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_left = 0
		cam.limit_top = -64
		cam.limit_right = 460
		cam.limit_bottom = 224

func _get_rock_data_for_depth(depth: int) -> RockData:
	var roll = randf() * 100.0
	if game_manager and game_manager.has_special_item("Ancient Cave Compass"):
		roll = min(99.0, roll + 15.0) # Meningkatkan peluang ore yang lebih langka ketika memiliki item spesial "Ancient Cave Compass"
	match depth:
		1: # Level 1 (Shallow Mine): 60% Stone, 25% Coal, 15% Tin
			if roll < 60: return ROCK_STONE
			elif roll < 85: return ROCK_COAL
			else: return ROCK_TIN
		2: # Level 2 (Iron Caverns): 35% Stone, 25% Coal, 25% Tin, 15% Iron
			if roll < 35: return ROCK_STONE
			elif roll < 60: return ROCK_COAL
			elif roll < 85: return ROCK_TIN
			else: return ROCK_IRON
		3: # Level 3 (Golden Grotto): 25% Iron, 35% Silver, 25% Gold, 15% Coal
			if roll < 25: return ROCK_IRON
			elif roll < 60: return ROCK_SILVER
			elif roll < 85: return ROCK_GOLD
			else: return ROCK_COAL
		4: # Level 4 (Crystal Depths): 25% Silver, 30% Gold, 30% Amethyst, 15% Diamond
			if roll < 25: return ROCK_SILVER
			elif roll < 55: return ROCK_GOLD
			elif roll < 85: return ROCK_AMETHYST
			else: return ROCK_DIAMOND
		5: # Level 5 (The Abyss Biome): 35% Diamond, 35% Amethyst, 20% Gold, 10% Silver
			if roll < 35: return ROCK_DIAMOND
			elif roll < 70: return ROCK_AMETHYST
			elif roll < 90: return ROCK_GOLD
			else: return ROCK_SILVER
		_:
			return ROCK_STONE

func _generate_rocks() -> void:
	for child in rock_container.get_children():
		child.queue_free()
	
	var ground_layer : TileMapLayer = current_map.get_node("Ground")
	var props_layer : TileMapLayer = current_map.get_node("Props")
	var ground_cells := ground_layer.get_used_cells()
	var available_cells := []
	
	var up_cell = ground_layer.local_to_map(ladder_up_area.position)
	var down_cell = ground_layer.local_to_map(ladder_down_area.position)
	var spawn_cell = ground_layer.local_to_map(player.position)
	
	for cell in ground_cells:
		var tile_data = ground_layer.get_cell_tile_data(cell)
		if props_layer.get_cell_source_id(cell) != -1:
			continue
		# Bagian yang memastikan ore tidak muncul di tempat player spawn
		if cell.distance_to(up_cell) <= 2.2 or cell.distance_to(down_cell) <= 2.2 or cell.distance_to(spawn_cell) <= 2.0:
			continue
		if tile_data and tile_data.get_custom_data("can_spawn_rocks") == true:
			available_cells.append(cell)
	
	available_cells.shuffle()
	var depth = game_manager.current_depth if game_manager else 1
	var num_rocks := int(available_cells.size() * FILL_PERCENTAGE)
	
	for i in range(num_rocks):
		var cell = available_cells[i]
		var rock = ROCK_SCENE.instantiate()
		var chosen_data = _get_rock_data_for_depth(depth)
		rock.set_rock_data(chosen_data)
		
		var local_pos = ground_layer.map_to_local(cell)
		rock.global_position = local_pos
		rock_container.add_child(rock)
