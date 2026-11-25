extends Sprite2D
class_name FarmAnimal

@export var move_speed: float = 14.0
@export var pen_min: Vector2 = Vector2(-128, -108)
@export var pen_max: Vector2 = Vector2(128, 108)

enum State { IDLE, WALKING }
var current_state: State = State.IDLE
var state_timer: float = 0.0
var target_pos: Vector2 = Vector2.ZERO
var anim_timer: float = 0.0
var anim_frame: int = 0

func _ready() -> void:
	target_pos = position
	state_timer = randf_range(1.0, 3.5)

func _process(delta: float) -> void:
	state_timer -= delta
	anim_timer += delta
	
	if current_state == State.IDLE:
		# Ketika idle atau bernafas: diantara frames 0 and 1
		if anim_timer >= 0.45:
			anim_timer = 0.0
			anim_frame = (anim_frame + 1) % 2
			frame = anim_frame
			
		if state_timer <= 0.0:
			# Bagian yang mengambil secara random dengan memanipulasi pen_min dan pen_maxnya
			target_pos = Vector2(
				randf_range(pen_min.x, pen_max.x),
				randf_range(pen_min.y, pen_max.y)
			)
			current_state = State.WALKING
			state_timer = randf_range(2.5, 6.0)
			anim_frame = 2
	
	elif current_state == State.WALKING:
		# Ketika bergerak: Diantara frames 2 and 3
		if anim_timer >= 0.22:
			anim_timer = 0.0
			anim_frame = 2 + ((anim_frame - 2 + 1) % 2)
			frame = anim_frame
			
		var dir = (target_pos - position)
		var dist = dir.length()
		if dist > 2.0:
			dir = dir.normalized()
			position += dir * move_speed * delta
			# Wajah binatangnya akan ke kiri sebagai defaultnya.
			# Ketika bergerak ke kanan (dir.x > 0), flip_h harus true untuk bergerak ke keanan.
			# Ketika bergerak ke kiri (dir.x < 0), flip_h harus false untuk bergerak ke kiri.
			if abs(dir.x) > 0.1:
				flip_h = (dir.x > 0)
		else:
			# Bagian yang menangani ketika binatang sudah sampai tempat tujuannya, maka bertukar menjadi idle kembali
			current_state = State.IDLE
			state_timer = randf_range(2.0, 5.0)
			frame = 0
			
		if state_timer <= 0.0:
			current_state = State.IDLE
			state_timer = randf_range(1.5, 4.0)
			frame = 0

	# Bagian yang mengatur, supaya hewan selalu berada di dalam wilayah pen_min dan pen_max
	position.x = clamp(position.x, pen_min.x, pen_max.x)
	position.y = clamp(position.y, pen_min.y, pen_max.y)
