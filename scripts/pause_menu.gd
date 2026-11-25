extends Control

@onready var audio_ui: AudioStreamPlayer = $pauseAudio_UI

func _ready():
	hide()
	$PanelContainer/VBoxContainer/Restart.disabled = true # Memastikan button reset tidak langsung aktif 

func resume():
	$AnimationPlayer.play_backwards("blur")
	# await $AnimationPlayer.animation_finished # Menunggu animasi mundurnya selesai
	
	# Sembunyikan UI dan matikan mode pause game
	hide()
	get_tree().paused = false

func pause():
	get_tree().paused = true # Hidupkan mode pause
	show() # Memunculkan pause menu
	$PanelContainer/VBoxContainer/Restart.disabled = false
	$AnimationPlayer.play("blur") # Jalanin animasi blur

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	audio_ui.play_click()
	resume()
	
func _on_restart_pressed() -> void:
	audio_ui.play_click()
	get_viewport().gui_release_focus()
	
	$AnimationPlayer.play("RESET")
	$ColorRect.material.set_shader_parameter("lod", 0.0)
	get_tree().paused = false 
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	audio_ui.play_click()
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_quit_pressed() -> void:
	audio_ui.play_click()
	get_tree().quit()

func _process(delta):
	testEsc()
