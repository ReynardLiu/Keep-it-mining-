extends CanvasLayer

signal battle_completed(won: bool)

@export var is_active: bool = false
var streak: int = 0
var current_correct_answer: String = ""
var current_rock_data: RockData = null
var on_won_callback: Callable
var on_lost_callback: Callable
var can_select: bool = false

# Node references
@onready var battle_container: Control = $BattleContainer
@onready var flash_overlay: ColorRect = $FlashOverlay
@onready var transition_bars: Control = $TransitionBars

# Audio
@onready var audio_encounter: AudioStreamPlayer = $AudioEncounter
@onready var audio_strike: AudioStreamPlayer = $AudioStrike
@onready var audio_shatter: AudioStreamPlayer = $AudioShatter
@onready var audio_miss: AudioStreamPlayer = $AudioMiss
@onready var audio_select: AudioStreamPlayer = $AudioSelect

# Battle Visuals
@onready var enemy_sprite: TextureRect = $BattleContainer/EnemyArea/EnemySprite
@onready var enemy_name_label: Label = $BattleContainer/EnemyArea/EnemyCard/NameLabel
@onready var enemy_level_label: Label = $BattleContainer/EnemyArea/EnemyCard/LevelLabel
@onready var enemy_hp_bar: ProgressBar = $BattleContainer/EnemyArea/EnemyCard/HpBar
@onready var enemy_card: Control = $BattleContainer/EnemyArea/EnemyCard

@onready var player_sprite: TextureRect = $BattleContainer/PlayerArea/MinerSprite
@onready var player_streak_label: Label = $BattleContainer/PlayerArea/PlayerCard/StreakLabel
@onready var player_card: Control = $BattleContainer/PlayerArea/PlayerCard

@onready var slash_rect: TextureRect = $BattleContainer/EnemyArea/SlashEffect

# Dialogue & Action Box
@onready var prompt_label: Label = $BattleContainer/BattleBox/VBox/PromptLabel
@onready var question_label: Label = $BattleContainer/BattleBox/VBox/QuestionLabel
@onready var button_grid: GridContainer = $BattleContainer/BattleBox/VBox/ButtonGrid
@onready var btn_1: Button = $BattleContainer/BattleBox/VBox/ButtonGrid/Btn1
@onready var btn_2: Button = $BattleContainer/BattleBox/VBox/ButtonGrid/Btn2
@onready var btn_3: Button = $BattleContainer/BattleBox/VBox/ButtonGrid/Btn3
@onready var btn_4: Button = $BattleContainer/BattleBox/VBox/ButtonGrid/Btn4
@onready var retry_box: HBoxContainer = $BattleContainer/BattleBox/VBox/RetryBox
@onready var btn_retry: Button = $BattleContainer/BattleBox/VBox/RetryBox/BtnRetry
@onready var btn_escape: Button = $BattleContainer/BattleBox/VBox/RetryBox/BtnEscape

var choice_buttons: Array[Button] = []
var bars_list: Array[ColorRect] = []

# Preload Battle Textures
const TEX_STONE = preload("res://assets/images/battle/rock_stone_battle.png")
const TEX_IRON = preload("res://assets/images/battle/rock_iron_battle.png")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	battle_container.visible = false
	flash_overlay.visible = false
	flash_overlay.modulate.a = 0.0
	slash_rect.visible = false
	
	choice_buttons = [btn_1, btn_2, btn_3, btn_4]
	for i in range(choice_buttons.size()):
		var btn = choice_buttons[i]
		btn.pressed.connect(_on_choice_button_pressed.bind(btn))
		btn.mouse_entered.connect(_play_select_sound)
		btn.focus_entered.connect(_play_select_sound)
	
	btn_retry.pressed.connect(_on_retry_pressed)
	btn_escape.pressed.connect(_on_escape_pressed)
	btn_retry.mouse_entered.connect(_play_select_sound)
	btn_escape.mouse_entered.connect(_play_select_sound)
	
	_setup_transition_bars()

func _setup_transition_bars() -> void:
	# 10 horizontal zebra bars covering 320x180 (each 18px high)
	for child in transition_bars.get_children():
		child.queue_free()
	bars_list.clear()
	
	for i in range(10):
		var bar = ColorRect.new()
		bar.color = Color(0.05, 0.05, 0.08, 1.0)
		bar.size = Vector2(320, 18)
		bar.position = Vector2(-320 if i % 2 == 0 else 320, i * 18)
		transition_bars.add_child(bar)
		bars_list.append(bar)

func start_battle(rock_data: RockData, won_cb: Callable, lost_cb: Callable) -> void:
	if is_active:
		return
	is_active = true
	current_rock_data = rock_data
	on_won_callback = won_cb
	on_lost_callback = lost_cb
	can_select = false
	
	# Pause world
	get_tree().paused = true
	visible = true
	battle_container.visible = false
	retry_box.visible = false
	button_grid.visible = false
	
	# Configure enemy visuals
	var is_iron = false
	if rock_data and rock_data.ore_resource:
		var rname = rock_data.ore_resource.name.to_lower()
		if "iron" in rname or (rock_data.texture and "iron" in rock_data.texture.resource_path.to_lower()):
			is_iron = true
	
	enemy_sprite.texture = TEX_IRON if is_iron else TEX_STONE
	var ore_name = "Iron Ore" if is_iron else "Stone"
	enemy_name_label.text = "Wild " + ore_name
	enemy_level_label.text = "Lv. " + str(randi_range(3, 8) if is_iron else randi_range(1, 4))
	enemy_hp_bar.value = 100
	enemy_hp_bar.modulate = Color("#4ade80")
	
	player_streak_label.text = "Streak: " + str(streak) + " 🔥" if streak > 0 else "Streak: 0"
	
	# Start Pokemon battle sequence
	_play_pokemon_encounter_transition()

func _play_pokemon_encounter_transition() -> void:
	audio_encounter.play()
	flash_overlay.visible = true
	
	# Phase 1: Rapid white/black Pokemon flashes
	var tween = create_tween()
	flash_overlay.color = Color.WHITE
	tween.tween_property(flash_overlay, "modulate:a", 0.9, 0.08)
	tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.08)
	
	tween.tween_callback(func(): flash_overlay.color = Color.BLACK)
	tween.tween_property(flash_overlay, "modulate:a", 0.9, 0.08)
	tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.08)
	
	tween.tween_callback(func(): flash_overlay.color = Color.WHITE)
	tween.tween_property(flash_overlay, "modulate:a", 1.0, 0.08)
	tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.08)
	
	# Phase 2: Sliding zebra transition bars
	await tween.finished
	flash_overlay.visible = false
	
	var bar_tween = create_tween().set_parallel(true)
	for i in range(bars_list.size()):
		var bar = bars_list[i]
		bar.position.x = -320 if i % 2 == 0 else 320
		bar_tween.tween_property(bar, "position:x", 0.0, 0.35)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await bar_tween.finished
	
	# Phase 3: Setup Battle Arena & Slide bars off
	battle_container.visible = true
	_animate_actors_entrance()
	
	var open_tween = create_tween().set_parallel(true)
	for i in range(bars_list.size()):
		var bar = bars_list[i]
		var target_x = 320 if i % 2 == 0 else -320
		open_tween.tween_property(bar, "position:x", target_x, 0.35)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await open_tween.finished
	
	# Show Dialogue & Math Question
	_present_math_question()

func _animate_actors_entrance() -> void:
	# Enemy slides from top right
	enemy_sprite.position = Vector2(320, 30)
	enemy_card.position = Vector2(320, 20)
	var e_tween = create_tween().set_parallel(true)
	e_tween.tween_property(enemy_sprite, "position", Vector2(212, 42), 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	e_tween.tween_property(enemy_card, "position", Vector2(175, 12), 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Player slides from bottom left
	player_sprite.position = Vector2(-80, 85)
	player_card.position = Vector2(-150, 75)
	var p_tween = create_tween().set_parallel(true)
	p_tween.tween_property(player_sprite, "position", Vector2(40, 85), 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	p_tween.tween_property(player_card, "position", Vector2(20, 75), 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _present_math_question() -> void:
	can_select = false
	retry_box.visible = false
	button_grid.visible = false
	
	prompt_label.text = "A wild " + enemy_name_label.text.replace("Wild ", "") + " stands in your way!"
	question_label.text = "Solve the math equation to shatter the stone!"
	
	await get_tree().create_timer(1.2).timeout
	if not is_active: return
	
	# Generate Math Problem
	var is_iron = "Iron" in enemy_name_label.text
	var problem = _generate_math_problem(is_iron)
	current_correct_answer = str(problem["answer"])
	
	prompt_label.text = "⛏️ MATH PUZZLE (Select the correct answer):"
	question_label.text = problem["question"]
	
	# Populate 4 choice buttons
	var choices: Array = problem["choices"]
	for i in range(choice_buttons.size()):
		var btn = choice_buttons[i]
		var prefix = ["A) ", "B) ", "C) ", "D) "][i]
		btn.text = prefix + str(choices[i])
		btn.set_meta("choice_val", str(choices[i]))
		btn.modulate = Color.WHITE
		btn.disabled = false
	
	button_grid.visible = true
	can_select = true
	btn_1.grab_focus()

func _generate_math_problem(is_hard: bool) -> Dictionary:
	var q_text = ""
	var ans = 0
	var pool = []
	
	# Difficulty: Elementary (Grade 1-4) vs Middle School (Grade 5-8)
	var category = randi_range(0, 3) if not is_hard else randi_range(2, 5)
	
	match category:
		0: # Elementary Addition (12 + 25)
			var a = randi_range(8, 45)
			var b = randi_range(5, 38)
			ans = a + b
			q_text = "%d + %d = ?" % [a, b]
		1: # Elementary Subtraction (45 - 18)
			var a = randi_range(20, 75)
			var b = randi_range(6, a - 2)
			ans = a - b
			q_text = "%d - %d = ?" % [a, b]
		2: # Multiplication Table (3x4 up to 9x9 or 12x12)
			var a = randi_range(3, 9) if not is_hard else randi_range(6, 12)
			var b = randi_range(3, 9) if not is_hard else randi_range(4, 12)
			ans = a * b
			q_text = "%d × %d = ?" % [a, b]
		3: # Exact Division (56 / 8)
			var b = randi_range(3, 9) if not is_hard else randi_range(4, 12)
			var result = randi_range(3, 9) if not is_hard else randi_range(5, 12)
			var a = b * result
			ans = result
			q_text = "%d ÷ %d = ?" % [a, b]
		4: # Middle School Algebra (x + 14 = 32 -> x = ?)
			var x_val = randi_range(4, 25)
			var b = randi_range(8, 30)
			var sum_val = x_val + b
			ans = x_val
			if randf() > 0.5:
				q_text = "x + %d = %d   (x = ?)" % [b, sum_val]
			else:
				var coeff = randi_range(2, 6)
				var prod = coeff * x_val
				q_text = "%dx = %d   (x = ?)" % [coeff, prod]
		5: # Middle School Order of Operations (4 x 5 + 7)
			var a = randi_range(2, 7)
			var b = randi_range(3, 8)
			var c = randi_range(3, 15)
			ans = (a * b) + c
			q_text = "%d × %d + %d = ?" % [a, b, c]

	# Generate 3 plausible distractors
	pool.append(ans)
	var possible_offsets = [-1, 1, -2, 2, -10, 10, -5, 5, -3, 3]
	possible_offsets.shuffle()
	
	for offset in possible_offsets:
		var fake = ans + offset
		if fake > 0 and fake != ans and not (fake in pool):
			pool.append(fake)
		if pool.size() >= 4:
			break
			
	while pool.size() < 4:
		var fake = ans + randi_range(-8, 8)
		if fake > 0 and not (fake in pool):
			pool.append(fake)

	pool.shuffle()
	return {
		"question": q_text,
		"answer": ans,
		"choices": pool
	}

func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not can_select:
		return
	
	# Support direct 1, 2, 3, 4 keyboard shortcuts
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			_on_choice_button_pressed(btn_1)
		elif event.keycode == KEY_2:
			_on_choice_button_pressed(btn_2)
		elif event.keycode == KEY_3:
			_on_choice_button_pressed(btn_3)
		elif event.keycode == KEY_4:
			_on_choice_button_pressed(btn_4)

func _on_choice_button_pressed(btn: Button) -> void:
	if not can_select:
		return
	can_select = false
	var chosen_val = btn.get_meta("choice_val", "")
	
	if chosen_val == current_correct_answer:
		btn.modulate = Color("#4ade80")
		_handle_correct_answer()
	else:
		btn.modulate = Color("#f87171")
		_handle_incorrect_answer()

func _handle_correct_answer() -> void:
	audio_strike.play()
	streak += 1
	player_streak_label.text = "Streak: " + str(streak) + " 🔥"
	
	prompt_label.text = "✨ SUPER EFFECTIVE! Critical strike!"
	question_label.text = "That is correct! " + current_correct_answer + "!"
	
	# 1. Miner swing / dash forward
	var p_orig = player_sprite.position
	var p_tween = create_tween()
	p_tween.tween_property(player_sprite, "position", p_orig + Vector2(25, -10), 0.1)
	p_tween.tween_property(player_sprite, "position", p_orig, 0.2)
	
	# 2. Pickaxe Slash impact on stone
	slash_rect.visible = true
	slash_rect.modulate = Color.WHITE
	var s_tween = create_tween()
	s_tween.tween_property(slash_rect, "scale", Vector2(1.8, 1.8), 0.25).from(Vector2(0.5, 0.5))
	s_tween.tween_property(slash_rect, "modulate:a", 0.0, 0.1)
	await s_tween.finished
	slash_rect.visible = false
	
	# 3. Enemy stone shake, flash red, and HP bar drops to 0
	audio_shatter.play()
	var hp_tween = create_tween()
	hp_tween.tween_property(enemy_hp_bar, "value", 0.0, 0.4)
	
	var orig_pos = enemy_sprite.position
	var shake_tween = create_tween()
	for i in range(6):
		var offset = Vector2(randf_range(-6, 6), randf_range(-4, 4))
		shake_tween.tween_property(enemy_sprite, "position", orig_pos + offset, 0.04)
	shake_tween.tween_property(enemy_sprite, "position", orig_pos, 0.04)
	
	# 4. Stone crumbles / fades
	var fade_tween = create_tween()
	fade_tween.tween_property(enemy_sprite, "modulate:a", 0.0, 0.35)
	fade_tween.tween_property(enemy_sprite, "position:y", orig_pos.y + 15, 0.35)
	
	await fade_tween.finished
	
	prompt_label.text = "🎉 The " + enemy_name_label.text.replace("Wild ", "") + " shattered into pieces!"
	question_label.text = "Obtained mineral rewards!"
	
	await get_tree().create_timer(1.2).timeout
	_finish_battle(true)

func _handle_incorrect_answer() -> void:
	audio_miss.play()
	streak = 0
	player_streak_label.text = "Streak: 0"
	
	# Rock shrugs off hit with mini shake
	var orig_pos = enemy_sprite.position
	var shake_tween = create_tween()
	shake_tween.tween_property(enemy_sprite, "position", orig_pos + Vector2(-3, 0), 0.05)
	shake_tween.tween_property(enemy_sprite, "position", orig_pos + Vector2(3, 0), 0.05)
	shake_tween.tween_property(enemy_sprite, "position", orig_pos, 0.05)
	
	prompt_label.text = "❌ Oh no! The pickaxe slipped!"
	question_label.text = "The correct answer was: " + current_correct_answer
	
	button_grid.visible = false
	retry_box.visible = true
	btn_retry.grab_focus()

func _on_retry_pressed() -> void:
	_present_math_question()

func _on_escape_pressed() -> void:
	prompt_label.text = "💨 You escaped back to safety!"
	question_label.text = "The stone remains intact."
	await get_tree().create_timer(0.8).timeout
	_finish_battle(false)

func _finish_battle(won: bool) -> void:
	# Slide zebra bars closed
	var bar_tween = create_tween().set_parallel(true)
	for i in range(bars_list.size()):
		var bar = bars_list[i]
		bar.position.x = -320 if i % 2 == 0 else 320
		bar_tween.tween_property(bar, "position:x", 0.0, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
	await bar_tween.finished
	
	# Reset states
	battle_container.visible = false
	is_active = false
	enemy_sprite.modulate.a = 1.0
	
	# Unpause tree
	get_tree().paused = false
	
	# Slide zebra bars open to reveal map
	var open_tween = create_tween().set_parallel(true)
	for i in range(bars_list.size()):
		var bar = bars_list[i]
		var target_x = 320 if i % 2 == 0 else -320
		open_tween.tween_property(bar, "position:x", target_x, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
	await open_tween.finished
	visible = false
	
	# Execute callbacks
	if won and on_won_callback.is_valid():
		on_won_callback.call()
	elif not won and on_lost_callback.is_valid():
		on_lost_callback.call()
		
	battle_completed.emit(won)

func _play_select_sound() -> void:
	if visible and audio_select:
		audio_select.play()
