extends Area2D

const miningScene = preload("res://mining_mini_game.tscn")

var active_mining_ui: Control = null
var ore_data: OreData
var player = null


@onready var sprite_2d: Sprite2D = $Sprite2D
@export var item: InvItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.texture = ore_data.texture

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Jika data item ternyata kosong, cetak peringatan di konsol agar tidak crash
		if item == null:
			print("Peringatan: Data 'item' pada Ore ini belum diisi!")
			return 
			
		body.collect(item)
		if body.add_ore(ore_data):
			player = body
			queue_free()

# Fungsi ini dipanggil saat pemain memukul batu
func hit() -> void:
	# Jika minigame sudah aktif di layar, jangan buat dobel
	if active_mining_ui != null:
		return
	
	print("Batu Dipukul!")
	# 1. Munculkan UI minigame ke layar/scene utama
	active_mining_ui = miningScene.instantiate()
	get_tree().current_scene.add_child(active_mining_ui)
	
	active_mining_ui.global_position = global_position # atau posisi player
	active_mining_ui.start_mining()
	
	# 2. Panggil fungsi utama untuk memulai permainan minigame-nya
	active_mining_ui.start_mining()
	
	# 3. Sambungkan sinyal hasil (Berhasil / Gagal)
	active_mining_ui.mining_succeeded.connect(_on_mining_success)
	active_mining_ui.mining_failed.connect(_on_mining_failed)

func _on_mining_success() -> void:
	print("Berhasil menambang! Batu hancur.")
	active_mining_ui = null
	queue_free() # Hapus objek batu dari game

func _on_mining_failed() -> void:
	print("Gagal/Waktu habis! Coba pukul batu lagi.")
	active_mining_ui = null
