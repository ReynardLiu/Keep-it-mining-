extends Control

func _ready() -> void:
	hide() # Sembunyikan pause menu saat game mulai

func resume():
	$AnimationPlayer.play_backwards("blur") # Jalankan animasi unblur
	await $AnimationPlayer.animation_finished # Menunggu animasi mundurnya selesai
	# Baru sembunyikan UI dan matikan mode pause game
	hide()
	get_tree().paused = false

func pause():
	get_tree().paused = true # Hidupkan mode pause
	show() # Memunculkan pause menu
	$AnimationPlayer.play("blur") # Jalanin animasi blur

func testEsc():
	if Input.is_action_just_pressed("esc"):
		if not get_tree().paused:
			pause()
		else:
			resume()

func _on_resume_pressed() -> void:
	resume()
	
func _on_restart_pressed() -> void:
	# Matikan pause secara instan tanpa menunggu animasi agar scene langsung reload bersih
	get_tree().paused = false 
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta):
	testEsc()
