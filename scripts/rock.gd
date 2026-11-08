extends StaticBody2D
class_name Rock

var health: int
var is_breaking: bool = false

const ORE_SCENE := preload("res://scenes/ore.tscn")
const FLASH_COLOR := Color(2.454, 2.454, 2.454, 1.0)
@export var data: RockData	

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rock_breaking_sound: AudioStreamPlayer2D = $RockBreakingSound
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = data.max_health
	sprite_2d.texture = data.texture 

func take_damage(amount: int) -> void:
	if is_breaking:
		return
		
	health -= amount
	print("Rock damaged. Current HP: ", health)
	_flash()
	
	if health <= 0:
		is_breaking = true
		_trigger_break_encounter()

func _trigger_break_encounter() -> void:
	# Trigger the Pokemon-style math battle encounter screen
	var math_battle = null
	if is_inside_tree():
		var tree = get_tree()
		if tree and tree.root:
			math_battle = tree.root.get_node_or_null("MathBattle")
			if not math_battle:
				math_battle = tree.root.find_child("MathBattle", true, false)
				if not math_battle:
					var mb_scene = load("res://scenes/math_battle/math_battle.tscn")
					if mb_scene:
						math_battle = mb_scene.instantiate()
						tree.root.add_child(math_battle)
				
	if math_battle and math_battle.has_method("start_battle"):
		math_battle.start_battle(data, _on_math_battle_won, _on_math_battle_lost)
	else:
		# Fallback if MathBattle is not loaded
		_drop_ore()
		_destroy()

func _on_math_battle_won() -> void:
	# Successfully solved the math puzzle: shatter rock & yield ore
	_drop_ore()
	_destroy()

func _on_math_battle_lost() -> void:
	# Missed or retreated: rock survives with 1 HP so player can hit it again
	is_breaking = false
	health = 1

func _flash() -> void:
	sprite_2d.modulate = FLASH_COLOR
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)

func _destroy() -> void:
	# Hide rock
	visible = false
	collision_shape_2d.set_deferred("disabled", true)
	if rock_breaking_sound:
		rock_breaking_sound.play()
		await rock_breaking_sound.finished
	queue_free()
	
func _drop_ore() -> void:
	var ore = ORE_SCENE.instantiate()
	ore.position = position
	ore.ore_data = data.ore_resource
	ore.item = data.ore_resource.inventory_item 
	
	var parent_node = get_parent()
	var level_root = parent_node.get_parent() if parent_node else null
	var ore_container = null
	if level_root:
		ore_container = level_root.get_node_or_null("OreContainer")
		if ore_container:
			ore_container.add_child(ore)
		else:
			level_root.add_child(ore)
	elif parent_node:
		parent_node.add_child(ore)
	else:
		get_tree().current_scene.add_child(ore)
	
	# Random horizontal offset
	var random_x = randf_range(-15, 15)
	var target_x = ore.position.x + random_x
	
	var tween = ore.create_tween()
	tween.set_parallel(true) # Run tween simultaneously
	# Vertical Bounce
	tween.tween_property(ore, "position:y", ore.position.y - 6, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(ore, "position:y", ore.position.y, 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.3)
	
	# Horizontal Movement
	tween.tween_property(ore, "position:x", target_x, 0.6)\
		.set_ease(Tween.EASE_OUT)
