extends Control


@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $SettingsMenu
@onready var audio_ui: AudioStreamPlayer = $Audio_UI

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ready():
	options.visible = false

func show_main_menu():
	main_buttons.visible = true
	options.visible = false

func _on_Start_pressed() -> void:
	audio_ui.play_click()
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func _on_settings_pressed() -> void:
	print("Settings pressed")
	audio_ui.play_click()
	main_buttons.visible = false
	options.visible = true

func _on_credit_pressed() -> void:
	audio_ui.play_click()
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	audio_ui.play_click()
	get_tree().quit()

func _on_button_5_pressed() -> void:
	audio_ui.play_click()
	show_main_menu()

func _on_screen_mode_item_selected(index: int) -> void:
	match index:
		0: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
