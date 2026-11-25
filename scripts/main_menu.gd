extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings_menu: PanelContainer = $SettingsMenu
@onready var credits_menu: PanelContainer = $CreditsMenu
@onready var audio_ui: AudioStreamPlayer = $Audio_UI
@onready var main_menu_backsound: AudioStreamPlayer = $MainMenuBacksound

func _ready() -> void:
	settings_menu.visible = false
	credits_menu.visible = false
	main_buttons.visible = true
	main_menu_backsound.playSound()

func show_main_menu() -> void:
	main_buttons.visible = true
	settings_menu.visible = false
	credits_menu.visible = false

func _on_Start_pressed() -> void:
	audio_ui.play_click()
	# Spawn dalam kota
	get_tree().change_scene_to_file("res://scenes/town/town.tscn")
	main_menu_backsound.stopSound()

func _on_settings_pressed() -> void:
	audio_ui.play_click()
	main_buttons.visible = false
	settings_menu.visible = true
	credits_menu.visible = false

func _on_credit_pressed() -> void:
	audio_ui.play_click()
	main_buttons.visible = false
	settings_menu.visible = false
	credits_menu.visible = true

func _on_quit_pressed() -> void:
	audio_ui.play_click()
	get_tree().quit()

func _on_back_pressed() -> void:
	audio_ui.play_click()
	show_main_menu()

func _on_screen_mode_item_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
