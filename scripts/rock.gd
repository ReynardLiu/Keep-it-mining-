extends StaticBody2D
class_name Rock
var health: int

const ORE_SCENE := preload("res://scenes/ore.tscn")
const FLASH_COLOR := Color(2.454, 2.454, 2.454, 1.0)
@export var data: RockData	

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rock_breaking_sound: AudioStreamPlayer2D = $RockBreakingSound
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
# @onready var mining_mini_game: Control = $mining_mini_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = data.max_health
	sprite_2d.texture = data.texture 

func take_damage(amount: int) -> void:
	health -= amount
	print(health)
	_flash()
	if health <= 0:
		_drop_ore()
		_destroy()

func _flash() -> void:
	sprite_2d.modulate = FLASH_COLOR
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)


func _destroy() -> void:
	# Hide rock
	visible = false
	collision_shape_2d.set_deferred("disabled", true)
	rock_breaking_sound.play()
	await rock_breaking_sound.finished
	queue_free()
	
func _drop_ore() -> void:
	var ore = ORE_SCENE.instantiate()
	ore.position = position
	ore.ore_data = data.ore_resource
	
	ore.item = data.ore_resource.inventory_item 
	var level_root = get_parent().get_parent()
	@warning_ignore("unused_variable")
	var ore_container = level_root.get_node("OreContainer")
	level_root.add_child(ore)
	
	# Random horizontal offset
	var random_x = randf_range(-15, 15)
	var target_x = ore.position.x + random_x
	
	var tween = ore.create_tween()
	tween.set_parallel(true) # Run tween simultaneously
	# Vertical Bounce
	tween.tween_property(ore, "position:y", ore.position.y - 5, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(ore, "position:y", ore.position.y, 0.3)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_delay(0.3)
	
	# Horizontal Movement
	tween.tween_property(ore, "position:x", target_x, 0.6)\
		.set_ease(Tween.EASE_OUT)
