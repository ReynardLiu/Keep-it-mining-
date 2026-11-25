extends Area2D

var ore_data: OreData
var player = null

@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ore_data:
		sprite_2d.texture = ore_data.texture

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if ore_data:
			body.add_ore(ore_data)
		player = body
		queue_free()
