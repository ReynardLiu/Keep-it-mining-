extends Area2D

var ore_data: OreData
var player = null

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var item: InvItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ore_data:
		sprite_2d.texture = ore_data.texture

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if item == null:
			print("Peringatan: Data 'item' pada Ore ini belum diisi!")
			return 
			
		body.collect(item)
		if body.add_ore(ore_data):
			player = body
			queue_free()
