extends CanvasLayer

signal battle_completed(won: bool)

@export var is_active: bool = false
var current_correct_answer: String = ""
var current_rock_data: RockData = null
var on_won_callback: Callable
var on_lost_callback: Callable
var can_select: bool = false
var is_abyss_mode: bool = false
var timer_active: bool = false
var time_remaining: float = 7.0
var max_abyss_time: float = 7.0

var game_manager: Node:
	get:
		if is_inside_tree() and get_tree().root:
			return get_tree().root.get_node_or_null("GameManager")
		return null

# Variabel untuk referensi nodenya
@onready var battle_container: Control = $BattleContainer
@onready var background_rect: TextureRect = $BattleContainer/Background
@onready var flash_overlay: ColorRect = $FlashOverlay
@onready var transition_bars: Control = $TransitionBars

# Varibel untuk audio-audionya
@onready var audio_encounter: AudioStreamPlayer = $AudioEncounter
@onready var audio_strike: AudioStreamPlayer = $AudioStrike
@onready var audio_shatter: AudioStreamPlayer = $AudioShatter
@onready var audio_miss: AudioStreamPlayer = $AudioMiss
@onready var audio_select: AudioStreamPlayer = $AudioSelect
@onready var audio_hurt: AudioStreamPlayer = $AudioHurt
@onready var audio_faint: AudioStreamPlayer = $AudioFaint

# Variabel untuk visual aksi math battlenya
@onready var enemy_sprite: TextureRect = $BattleContainer/EnemyArea/EnemySprite
@onready var enemy_name_label: Label = $BattleContainer/EnemyArea/EnemyCard/NameLabel
@onready var enemy_level_label: Label = $BattleContainer/EnemyArea/EnemyCard/LevelLabel
@onready var enemy_hp_bar: ProgressBar = $BattleContainer/EnemyArea/EnemyCard/HpBar
@onready var enemy_card: Control = $BattleContainer/EnemyArea/EnemyCard

@onready var player_sprite: TextureRect = $BattleContainer/PlayerArea/MinerSprite
@onready var player_streak_label: Label = $BattleContainer/PlayerArea/PlayerCard/StreakLabel
@onready var player_card: Control = $BattleContainer/PlayerArea/PlayerCard
@onready var player_hearts: Array = [
	$BattleContainer/PlayerArea/PlayerCard/HeartsRow/H1,
	$BattleContainer/PlayerArea/PlayerCard/HeartsRow/H2,
	$BattleContainer/PlayerArea/PlayerCard/HeartsRow/H3,
	$BattleContainer/PlayerArea/PlayerCard/HeartsRow/H4,
	$BattleContainer/PlayerArea/PlayerCard/HeartsRow/H5
]

@onready var slash_rect: TextureRect = $BattleContainer/EnemyArea/SlashEffect

# Dialogue & Action Box
@onready var timer_bar: ProgressBar = $BattleContainer/BattleBox/VBox/TimerBar
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

# Variabel untuk ngeload texture battlenya
const TEX_BG_CAVE = preload("res://assets/images/battle/battle_background.png")
const TEX_BG_ABYSS = preload("res://assets/images/battle/abyss_background.png")
const TEX_STONE = preload("res://assets/images/battle/rock_stone_battle.png")
const TEX_IRON = preload("res://assets/images/battle/rock_iron_battle.png")
const TEX_HEART_FULL = preload("res://assets/images/hud/heart_full.png")
const TEX_HEART_EMPTY = preload("res://assets/images/hud/heart_empty.png")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	battle_container.visible = false
	flash_overlay.visible = false
	flash_overlay.modulate.a = 0.0
	slash_rect.visible = false
	timer_bar.visible = false
	
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

func _process(delta: float) -> void:
	if is_active and timer_active:
		time_remaining -= delta
		timer_bar.value = max(0.0, time_remaining)
		if time_remaining <= 0.0:
			timer_active = false
			_handle_timeout()

func start_battle(rock_data: RockData, won_cb: Callable, lost_cb: Callable) -> void:
	if is_active:
		return
	is_active = true
	current_rock_data = rock_data
	on_won_callback = won_cb
	on_lost_callback = lost_cb
	can_select = false
	timer_active = false
	
	# Bagian untuk mengecek apakah bioma Abyss (Level 5)
	is_abyss_mode = (game_manager != null and game_manager.current_depth >= 5)
	background_rect.texture = TEX_BG_ABYSS if is_abyss_mode else TEX_BG_CAVE
	
	# Bagian pause world saat battle
	get_tree().paused = true
	visible = true
	battle_container.visible = false
	retry_box.visible = false
	button_grid.visible = false
	timer_bar.visible = is_abyss_mode
	
	# Bagian untuk menentukan nama ore dan sprite batunya
	var ore_raw = "stone"
	if rock_data and rock_data.ore_resource:
		ore_raw = rock_data.ore_resource.name.to_lower().replace("_ore", "").replace(".tres", "")
	
	var is_iron = ore_raw == "iron"
	var is_rare = ore_raw in ["silver", "gold", "amethyst", "diamond"]
	
	if is_iron or is_rare:
		enemy_sprite.texture = TEX_IRON
	else:
		enemy_sprite.texture = TEX_STONE
		
	# Bagian untuk memberikan warna kepada ore yang langka dipertarungan
	match ore_raw:
		"gold": enemy_sprite.modulate = Color(1.2, 1.1, 0.4)
		"diamond": enemy_sprite.modulate = Color(0.6, 1.1, 1.3)
		"amethyst": enemy_sprite.modulate = Color(1.1, 0.5, 1.2)
		"silver": enemy_sprite.modulate = Color(1.1, 1.1, 1.2)
		"coal": enemy_sprite.modulate = Color(0.35, 0.35, 0.4)
		_: enemy_sprite.modulate = Color.WHITE
		
	var display_name = ore_raw.capitalize() + (" Core" if is_abyss_mode else " Node")
	enemy_name_label.text = ("Abyssal " if is_abyss_mode else "Wild ") + display_name
	var lvl = (game_manager.current_depth * 2 + randi_range(0, 2)) if game_manager else 2
	enemy_level_label.text = "Lv. " + str(lvl)
	enemy_hp_bar.value = 100
	enemy_hp_bar.modulate = Color("#4ade80")
	
	_update_player_hearts_display()
	_update_streak_label()
	
	_play_pokemon_encounter_transition()

func _update_player_hearts_display() -> void:
	var cur_hp = game_manager.current_hearts if game_manager else 5
	for i in range(5):
		player_hearts[i].texture = TEX_HEART_FULL if i < cur_hp else TEX_HEART_EMPTY

func _update_streak_label() -> void:
	var s = game_manager.streak if game_manager else 0
	player_streak_label.text = "Beruntun: " + str(s) + " 🔥" if s > 0 else "Beruntun: 0"

func _play_pokemon_encounter_transition() -> void:
	audio_encounter.play()
	flash_overlay.visible = true
	
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
	
	await tween.finished
	flash_overlay.visible = false
	
	var bar_tween = create_tween().set_parallel(true)
	for i in range(bars_list.size()):
		var bar = bars_list[i]
		bar.position.x = -320 if i % 2 == 0 else 320
		bar_tween.tween_property(bar, "position:x", 0.0, 0.35)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await bar_tween.finished
	
	battle_container.visible = true
	_animate_actors_entrance()
	
	var open_tween = create_tween().set_parallel(true)
	for i in range(bars_list.size()):
		var bar = bars_list[i]
		var target_x = 320 if i % 2 == 0 else -320
		open_tween.tween_property(bar, "position:x", target_x, 0.35)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await open_tween.finished
	_present_math_question()

func _animate_actors_entrance() -> void:
	enemy_sprite.position = Vector2(320, 30)
	enemy_card.position = Vector2(320, 20)
	var e_tween = create_tween().set_parallel(true)
	e_tween.tween_property(enemy_sprite, "position", Vector2(212, 42), 0.5)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	e_tween.tween_property(enemy_card, "position", Vector2(175, 12), 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	player_sprite.position = Vector2(-80, 85)
	player_card.position = Vector2(-150, 68)
	var p_tween = create_tween().set_parallel(true)
	p_tween.tween_property(player_sprite, "position", Vector2(40, 85), 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	p_tween.tween_property(player_card, "position", Vector2(15, 68), 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _present_math_question() -> void:
	can_select = false
	timer_active = false
	retry_box.visible = false
	button_grid.visible = false
	
	prompt_label.text = "Sebuah " + enemy_name_label.text.replace("Wild ", "").replace("Abyssal ", "") + " berdiri di depanmu!"
	question_label.text = "Selesaikan pertanyaannya untuk menghacurkan batu itu!"
	
	await get_tree().create_timer(1.0).timeout
	if not is_active: return
	
	# Bagian untuk menentukan tingkat kesulitannya
	var depth = game_manager.current_depth if game_manager else 1
	var problem = _generate_math_problem(depth)
	current_correct_answer = str(problem["answer"])
	
	prompt_label.text = "⛏️ " + ("⚡ TANTANGAN ABYSS:" if is_abyss_mode else "MATH BATTLE:")
	question_label.text = problem["question"]
	
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
	
	# Mode Abyss: Mengaktifkan timer
	if is_abyss_mode:
		var bonus_time = 3.0 if (game_manager and game_manager.has_special_item("Bob's Mining Lantern")) else 0.0
		time_remaining = max_abyss_time + bonus_time
		timer_bar.max_value = time_remaining
		timer_bar.value = time_remaining
		timer_bar.visible = true
		timer_active = true

func _generate_math_problem(depth: int) -> Dictionary:
	var q_text = ""
	var ans = 0
	var pool = []
	
	# Mengkategorikan sesuai kedalaman goa (1 sampai 5)
	if depth <= 1:
		# Sekolah dasar: penambahan dan pengurangan simple
		if randf() > 0.5:
			var a = randi_range(10, 40)
			var b = randi_range(5, 35)
			ans = a + b
			q_text = "%d + %d = ?" % [a, b]
		else:
			var a = randi_range(20, 65)
			var b = randi_range(5, a - 2)
			ans = a - b
			q_text = "%d - %d = ?" % [a, b]
	elif depth <= 3:
		# Sekolah sadar: Perkalian dan pembagian
		var cat = randi_range(0, 2)
		if cat == 0:
			var a = randi_range(4, 9)
			var b = randi_range(3, 10)
			ans = a * b
			q_text = "%d × %d = ?" % [a, b]
		elif cat == 1:
			var b = randi_range(3, 9)
			var result = randi_range(4, 11)
			ans = result
			q_text = "%d ÷ %d = ?" % [b * result, b]
		else:
			var a = randi_range(15, 60)
			var b = randi_range(15, 60)
			ans = a + b
			q_text = "%d + %d = ?" % [a, b]
	elif depth == 4:
		# Sekolah Dasar / Sekolah Menengah Pertama: Persamaan linear
		var cat = randi_range(0, 2)
		if cat == 0:
			var x_val = randi_range(5, 25)
			var b = randi_range(12, 35)
			ans = x_val
			q_text = "x + %d = %d   (x = ?)" % [b, x_val + b]
		elif cat == 1:
			var coeff = randi_range(3, 7)
			var x_val = randi_range(4, 15)
			ans = x_val
			q_text = "%dx = %d   (x = ?)" % [coeff, coeff * x_val]
		else:
			var a = randi_range(3, 8)
			var b = randi_range(4, 9)
			var c = randi_range(5, 20)
			ans = (a * b) + c
			q_text = "%d × %d + %d = ?" % [a, b, c]
	else:
		# Bioma Abyss (Level 5): Math Battle tersulit!
		var cat = randi_range(0, 3)
		if cat == 0:
			# Persamaan linear
			var a = randi_range(2, 5)
			var x_val = randi_range(4, 14)
			var b = randi_range(5, 18)
			ans = x_val
			q_text = "%dx + %d = %d   (x = ?)" % [a, b, (a * x_val) + b]
		elif cat == 1:
			# Perpangkatan
			var base = randi_range(4, 11)
			var add = randi_range(5, 25)
			ans = (base * base) + add
			q_text = "%d² + %d = ?" % [base, add]
		elif cat == 2:
			# Angka negatif dan urutan operasinya
			var a = randi_range(15, 35)
			var b = randi_range(4, 8)
			var c = randi_range(5, 9)
			ans = (b * c) - a
			q_text = "%d × %d - %d = ?" % [b, c, a]
		else:
			# Pembagian dan penjumlahan 2 langkah
			var d = randi_range(3, 8)
			var q = randi_range(5, 12)
			var add = randi_range(10, 30)
			ans = q + add
			q_text = "(%d ÷ %d) + %d = ?" % [d * q, d, add]

	pool.append(ans)
	var possible_offsets = [-1, 1, -2, 2, -10, 10, -5, 5, -3, 3]
	possible_offsets.shuffle()
	
	for offset in possible_offsets:
		var fake = ans + offset
		if fake != ans and not (fake in pool):
			pool.append(fake)
		if pool.size() >= 4:
			break
			
	while pool.size() < 4:
		var fake = ans + randi_range(-12, 12)
		if fake != ans and not (fake in pool):
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
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1: _on_choice_button_pressed(btn_1)
		elif event.keycode == KEY_2: _on_choice_button_pressed(btn_2)
		elif event.keycode == KEY_3: _on_choice_button_pressed(btn_3)
		elif event.keycode == KEY_4: _on_choice_button_pressed(btn_4)

func _on_choice_button_pressed(btn: Button) -> void:
	if not can_select:
		return
	can_select = false
	timer_active = false
	var chosen_val = btn.get_meta("choice_val", "")
	
	if chosen_val == current_correct_answer:
		btn.modulate = Color("#4ade80")
		_handle_correct_answer()
	else:
		btn.modulate = Color("#f87171")
		_handle_incorrect_answer()

func _handle_timeout() -> void:
	if not can_select: return
	can_select = false
	prompt_label.text = "⌛ WAKTU HABIS DI ABYSS!"
	question_label.text = "Kamu terlalu lambat! Jawaban yang benar adalah: " + current_correct_answer
	_handle_incorrect_answer()

func _handle_correct_answer() -> void:
	audio_strike.play()
	if game_manager:
		game_manager.streak += 1
		var depth = game_manager.current_depth
		game_manager.add_xp(15 + depth * 10)
	_update_streak_label()
	
	prompt_label.text = "✨ SUPER EFEKTIF! Serangan Kritikal!"
	question_label.text = "Itu benar! " + current_correct_answer + "!"
	
	# Ayunan dari penambang
	var p_orig = player_sprite.position
	var p_tween = create_tween()
	p_tween.tween_property(player_sprite, "position", p_orig + Vector2(25, -10), 0.1)
	p_tween.tween_property(player_sprite, "position", p_orig, 0.2)
	
	# Dampak serangannya (Slash)
	slash_rect.visible = true
	slash_rect.modulate = Color.WHITE
	var s_tween = create_tween()
	s_tween.tween_property(slash_rect, "scale", Vector2(1.8, 1.8), 0.25).from(Vector2(0.5, 0.5))
	s_tween.tween_property(slash_rect, "modulate:a", 0.0, 0.1)
	await s_tween.finished
	slash_rect.visible = false
	
	# Getaran dan pecahan musuhnya
	audio_shatter.play()
	var hp_tween = create_tween()
	hp_tween.tween_property(enemy_hp_bar, "value", 0.0, 0.4)
	
	var orig_pos = enemy_sprite.position
	var shake_tween = create_tween()
	for i in range(6):
		var offset = Vector2(randf_range(-6, 6), randf_range(-4, 4))
		shake_tween.tween_property(enemy_sprite, "position", orig_pos + offset, 0.04)
	shake_tween.tween_property(enemy_sprite, "position", orig_pos, 0.04)
	
	var fade_tween = create_tween()
	fade_tween.tween_property(enemy_sprite, "modulate:a", 0.0, 0.35)
	fade_tween.tween_property(enemy_sprite, "position:y", orig_pos.y + 15, 0.35)
	
	await fade_tween.finished
	
	prompt_label.text = "🎉 Batu itu hancur berkeping-keping!"
	question_label.text = "Menerima hadiah material!"
	
	await get_tree().create_timer(1.2).timeout
	_finish_battle(true)

func _handle_incorrect_answer() -> void:
	audio_hurt.play()
	
	# Player menerima kerusakan 1 hati!
	var fainted = false
	if game_manager:
		fainted = game_manager.take_damage(1)
	_update_player_hearts_display()
	_update_streak_label()
	
	# Flash red on hearts row
	var h_tween = create_tween()
	for h in player_hearts:
		h.modulate = Color("#ef4444")
	h_tween.tween_interval(0.3)
	h_tween.tween_callback(func():
		for h in player_hearts: h.modulate = Color.WHITE
	)
	
	if fainted:
		audio_faint.play()
		prompt_label.text = "💀 KAMU KEHILANGAN KE-5 HATI!"
		question_label.text = "Kamu pingsan di dalam goa! Diselamatkan ke kota..."
		button_grid.visible = false
		retry_box.visible = false
		await get_tree().create_timer(2.5).timeout
		_finish_battle(false)
		return
		
	# Still has hearts left
	var orig_pos = enemy_sprite.position
	var shake_tween = create_tween()
	shake_tween.tween_property(enemy_sprite, "position", orig_pos + Vector2(-3, 0), 0.05)
	shake_tween.tween_property(enemy_sprite, "position", orig_pos + Vector2(3, 0), 0.05)
	shake_tween.tween_property(enemy_sprite, "position", orig_pos, 0.05)
	
	prompt_label.text = "❌ SALAH! Kehilangan 1 Hati (-1 ❤️)"
	question_label.text = "Jawaban yang benar adalah: " + current_correct_answer
	
	button_grid.visible = false
	retry_box.visible = true
	btn_retry.grab_focus()

func _on_retry_pressed() -> void:
	_present_math_question()

func _on_escape_pressed() -> void:
	prompt_label.text = "💨 Kamu kabur dengan selamat!"
	question_label.text = "Batu itu tetap utuh."
	await get_tree().create_timer(0.8).timeout
	_finish_battle(false)

func _finish_battle(won: bool) -> void:
	timer_active = false
	
	var bar_tween = create_tween().set_parallel(true)
	for i in range(bars_list.size()):
		var bar = bars_list[i]
		bar.position.x = -320 if i % 2 == 0 else 320
		bar_tween.tween_property(bar, "position:x", 0.0, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
	await bar_tween.finished
	
	battle_container.visible = false
	is_active = false
	enemy_sprite.modulate = Color.WHITE
	
	get_tree().paused = false
	
	var open_tween = create_tween().set_parallel(true)
	for i in range(bars_list.size()):
		var bar = bars_list[i]
		var target_x = 320 if i % 2 == 0 else -320
		open_tween.tween_property(bar, "position:x", target_x, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
	await open_tween.finished
	visible = false
	
	if won and on_won_callback.is_valid():
		on_won_callback.call()
	elif not won and on_lost_callback.is_valid():
		on_lost_callback.call()
		
	battle_completed.emit(won)

func _play_select_sound() -> void:
	if visible and audio_select:
		audio_select.play()
