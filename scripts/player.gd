extends CharacterBody2D
class_name Player

const SPEED = 100.0
var is_mining: bool = false
var hitbox_offset: Vector2
var last_direction: Vector2 = Vector2.RIGHT
var detected_rocks: Array = []
var pickaxe_strenghth: int = 1


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var mining_timer: Timer = $MiningTimer
@onready var pickaxe_hit_sound: Node = get_node_or_null("../PickaxeHitSound")

func _ready() -> void:
	hitbox_offset =  hitbox.position

func reset(pos: Vector2) -> void:
	position = pos

func _physics_process(_delta: float) -> void:
	# Yang ngecek apakah ada Input mining
	if Input.is_action_pressed("mining") and mining_timer.is_stopped():
		use_pickaxe()
	
	# Ngecek kalau lagi mining, gerakannya berhenti
	if is_mining:
		velocity = Vector2.ZERO
		return
		
	process_movement()
	process_animation()
	move_and_slide()

# Untuk pergerakannya
func process_movement() -> void: 
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction	= direction
		update_hitbox_position()
	else:
		velocity = Vector2.ZERO

func process_animation() -> void:
	# Menghilangkan hitboxnya
	hitbox.monitoring = false

	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")
		
# Bagian yang menangani pembaruan hitbox offsetnya
func update_hitbox_position() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
			hitbox_collision_shape_2d.rotation_degrees = 0
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
			hitbox_collision_shape_2d.rotation_degrees = 0
		Vector2.DOWN:
			hitbox.position = Vector2(y,x)
			hitbox_collision_shape_2d.rotation_degrees = 90
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
			hitbox_collision_shape_2d.rotation_degrees = 90
	

# Bagian yang menangani ketika player mining
func use_pickaxe() -> void:
	detected_rocks.clear()
	is_mining =  true 
	hitbox.monitoring = true
	mining_timer.start()
	play_animation("swing_pickaxe", last_direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_mining:
		is_mining = false
		var rock_to_hit = get_most_overlapping_rock()
		if rock_to_hit:
			var current_power = pickaxe_strenghth
			var gm = get_node_or_null("/root/GameManager")
			if gm:
				current_power = gm.get_pickaxe_power()
			rock_to_hit.take_damage(current_power)
			if pickaxe_hit_sound and pickaxe_hit_sound.has_method("pickaxe_sound"):
				pickaxe_hit_sound.pickaxe_sound()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Rock:
		detected_rocks.append(body)

func get_most_overlapping_rock() -> Rock:
	var valid_rocks = detected_rocks.filter(func(r): return is_instance_valid(r))
	if valid_rocks.is_empty():
		return null
	var best_rock = valid_rocks[0]
	var best_dist = hitbox.global_position.distance_to(best_rock.global_position)
	
	for rock in valid_rocks:
		var dist = hitbox.global_position.distance_to(rock.global_position)
		if dist < best_dist:
			best_dist = dist
			best_rock = rock
	
	return best_rock

func add_ore(data: OreData) -> bool:
	var gm = get_node_or_null("/root/GameManager")
	if data and gm:
		var raw_name = data.name.to_lower().replace("_ore", "").replace(".tres", "")
		gm.add_ore(raw_name, 1)
	return true

func player():
	pass

func collect(_item):
	pass
