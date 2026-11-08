extends Control

signal mining_succeeded
signal mining_failed

# PENGATURAN POSISI & UKURAN (SESUAI REFERENSI)
const RING_RADIUS: float = 48.0
const RING_THICKNESS: float = 8.0
const BAR_SIZE := Vector2(110, 10)

@export var auto_start: bool = false # Otomatis aktif saat game mulai (atau tekan E)
@export var ring_offset := Vector2(0, -45) # Posisi lingkaran di atas kepala
@export var bar_offset := Vector2(0, 12)   # Posisi bar kuning di badan karakter

# PENGATURAN MEKANIK & WAKTU
@export var cursor_speed: float = 140.0
@export var mining_time_drain: float = 8.0 # Kecepatan waktu/bar berkurang per detik
@export var green_hit_reward: float = 22.0
@export var math_time_limit: float = 7.0   # Batas waktu jawab soal matematika

# STATE VARIABEL
var is_mining: bool = false
var is_paused_for_math: bool = false
var cursor_angle: float = -90.0
var direction: int = 1
var mining_progress: float = 55.0

var green_zone_1 := Vector2(-95.0, -55.0)
var red_zone := Vector2(-55.0, -35.0)
var green_zone_2 := Vector2(-35.0, -5.0)

# TEKSTUR SPRITE OTOMATIS (TANPA FILE EKSTERNAL)
var pickaxe_tex: Texture2D
var star_tex: Texture2D

# UI SOAL MATEMATIKA
var math_panel: PanelContainer
var math_label: Label
var math_timer_label: Label
var math_input: LineEdit
var current_answer: int = 0
var math_time_left: float = 0.0

# Data SVG Balon Beliung & Bintang di dalam kode
const PICKAXE_SVG := """<svg width="64" height="72" viewBox="0 0 16 18" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges"><path d="M3 0h10v1h2v2h1v10h-1v2h-2v1H9v1H8v1H7v-2H3v-1H1v-2H0V3h1V1h2V0z" fill="#d0d4d8"/><path d="M3 1h10v1h1v10h-1v2H9v1H8v1H7v-2H3v-2H2V2h1V1z" fill="#ffffff"/><rect x="11" y="2" width="2" height="2" fill="#b8bcc0"/><path d="M6 3h3v1h2v1h1v2h-1v2h-1V6H9V5H6V4H5V3h1z" fill="#4a3b32"/><path d="M8 6h1v1H8V6zM7 7h1v1H7V7zM6 8h1v1H6V8zM5 9h1v1H5V9zM4 10h1v1H4v-1z" fill="#3a2818"/></svg>"""
const STAR_SVG := """<svg width="20" height="20" viewBox="0 0 7 7" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges"><path d="M3 0h1v2h2v1h1v1H5v2H4v1H3V5H1V4H0V3h2V1h1V0z" fill="#d97706"/><path d="M3 1h1v2h2v1H4v2H3V4H1V3h2V1z" fill="#fef08a"/><rect x="3" y="3" width="1" height="1" fill="#ffffff"/></svg>"""

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 100
	_generate_sprites()
	_create_math_popup()
	if auto_start:
		start_mining()

# Mengubah teks SVG menjadi gambar secara otomatis
func _generate_sprites() -> void:
	var img_pick := Image.new()
	img_pick.load_svg_from_string(PICKAXE_SVG)
	pickaxe_tex = ImageTexture.create_from_image(img_pick)

	var img_star := Image.new()
	img_star.load_svg_from_string(STAR_SVG)
	star_tex = ImageTexture.create_from_image(img_star)

# Panggil fungsi ini (atau tekan E) untuk memulai mining
func start_mining() -> void:
	is_mining = true
	is_paused_for_math = false
	mining_progress = 55.0
	cursor_angle = -90.0
	cursor_speed = 140.0
	math_panel.visible = false
	print("Mining Dimunculkan")
	_randomize_zones()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	# Tekan E untuk mulai menambang jika sedang tidak aktif
	if not is_mining:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
			start_mining()
		return

	if is_paused_for_math:
		return

	# Deteksi Spasi atau Klik Kiri (sekali tekan, tidak spam saat ditahan)
	var is_click: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var is_space: bool = event.is_action_pressed("ui_accept")
	if is_click or is_space:
		_check_hit()

func _process(delta: float) -> void:
	if not is_mining:
		return

	if is_paused_for_math:
		_process_math_timer(delta)
		return

	# 1. Esensi Waktu: Bar kuning berkurang terus-menerus
	mining_progress = clamp(mining_progress - (mining_time_drain * delta), 0.0, 100.0)
	if mining_progress <= 0.0:
		is_mining = false
		mining_failed.emit()
		print("Waktu Habis! Gagal Menambang. (Tekan E untuk coba lagi)")
		queue_redraw()
		return

	# 2. Pergerakan Kursor Bintang bolak-balik
	cursor_angle += cursor_speed * direction * delta
	if cursor_angle >= 15.0:
		cursor_angle = 15.0
		direction = -1
	elif cursor_angle <= -115.0:
		cursor_angle = -115.0
		direction = 1

	queue_redraw()

func _check_hit() -> void:
	var in_green_1 := cursor_angle >= green_zone_1.x and cursor_angle <= green_zone_1.y
	var in_green_2 := cursor_angle >= green_zone_2.x and cursor_angle <= green_zone_2.y
	var in_red := cursor_angle > red_zone.x and cursor_angle < red_zone.y

	if in_green_1 or in_green_2:
		mining_progress = clamp(mining_progress + green_hit_reward, 0.0, 100.0)
		cursor_speed += 8.0
		_randomize_zones()
		if mining_progress >= 100.0:
			is_mining = false
			mining_succeeded.emit()
			print("TAMBANG HANCUR! (Tekan E untuk menambang lagi)")
			queue_redraw()
	elif in_red:
		_trigger_math_penalty(true)
	else:
		_trigger_math_penalty(false)

func _randomize_zones() -> void:
	var start_angle := randf_range(-105.0, -70.0)
	green_zone_1 = Vector2(start_angle, start_angle + 30.0)
	red_zone = Vector2(green_zone_1.y, green_zone_1.y + 18.0)
	green_zone_2 = Vector2(red_zone.y, red_zone.y + 28.0)

# LOGIKA SOAL MATEMATIKA
func _trigger_math_penalty(is_hard: bool) -> void:
	is_paused_for_math = true
	math_time_left = math_time_limit
	math_panel.visible = true
	math_input.text = ""
	math_input.grab_focus()

	var a := randi_range(5, 15) if not is_hard else randi_range(12, 25)
	var b := randi_range(3, 12) if not is_hard else randi_range(6, 15)

	if is_hard:
		current_answer = a * b
		math_label.text = "ZONA MERAH!\n%d × %d = ?" % [a, b]
	else:
		current_answer = a + b
		math_label.text = "MISS CLICK!\n%d + %d = ?" % [a, b]

func _process_math_timer(delta: float) -> void:
	math_time_left -= delta
	math_timer_label.text = "%.1f dtk" % max(0.0, math_time_left)
	if math_time_left <= 0.0:
		_resolve_math(false)

func _on_math_submitted(new_text: String) -> void:
	_resolve_math(new_text.strip_edges().to_int() == current_answer)

func _resolve_math(is_correct: bool) -> void:
	is_paused_for_math = false
	math_panel.visible = false
	if not is_correct:
		mining_progress = clamp(mining_progress - 25.0, 0.0, 100.0)
	_randomize_zones()

# PENGGAMBARAN SEMUA VISUAL SECARA OTOMATIS
func _draw() -> void:
	if not is_mining:
		return

	# 1. Gambar Balon Beliung Putih (Di lapisan paling belakang)
	if pickaxe_tex:
		var bubble_pos := ring_offset - Vector2(pickaxe_tex.get_width() / 2.0, RING_RADIUS + 20.0)
		draw_texture(pickaxe_tex, bubble_pos)

	# 2. Gambar Lingkaran Gelap Transparan & Garis Tepi (Menimpa bagian bawah balon)
	draw_circle(ring_offset, RING_RADIUS, Color(0.08, 0.08, 0.08, 0.85))
	draw_arc(ring_offset, RING_RADIUS, 0, TAU, 64, Color("#686c70"), 4.0)
	draw_arc(ring_offset, RING_RADIUS - 2, 0, TAU, 64, Color("#2b2d2f"), 2.0)

	# 3. Gambar Busur Zona Hijau - Merah - Hijau
	_draw_zone_arc(ring_offset, green_zone_1.x, green_zone_1.y, Color("#4ade80"), Color("#166534"))
	_draw_zone_arc(ring_offset, red_zone.x, red_zone.y, Color("#f87171"), Color("#991b1b"))
	_draw_zone_arc(ring_offset, green_zone_2.x, green_zone_2.y, Color("#4ade80"), Color("#166534"))

	# 4. Gambar Kursor Bintang Kuning (Di atas busur hijau/merah)
	if star_tex:
		var rad := deg_to_rad(cursor_angle)
		var star_center := ring_offset + Vector2(cos(rad), sin(rad)) * RING_RADIUS
		var star_pos := star_center - (star_tex.get_size() / 2.0)
		draw_texture(star_tex, star_pos)

	# 5. Gambar Progress Bar Kuning di Bawah
	var bar_pos := bar_offset - (BAR_SIZE / 2.0)
	draw_rect(Rect2(bar_pos - Vector2(2, 2), BAR_SIZE + Vector2(4, 4)), Color("#4a4a4a"))
	draw_rect(Rect2(bar_pos, BAR_SIZE), Color("#1a1817"))

	var fill_width := (mining_progress / 100.0) * BAR_SIZE.x
	if fill_width > 0:
		draw_rect(Rect2(bar_pos, Vector2(fill_width, BAR_SIZE.y)), Color("#eab308"))
		draw_rect(Rect2(bar_pos, Vector2(fill_width, 3)), Color("#fef08a"))

func _draw_zone_arc(center: Vector2, start_deg: float, end_deg: float, fill_col: Color, border_col: Color) -> void:
	var start_rad := deg_to_rad(start_deg)
	var end_rad := deg_to_rad(end_deg)
	draw_arc(center, RING_RADIUS, start_rad, end_rad, 24, border_col, RING_THICKNESS + 3.0)
	draw_arc(center, RING_RADIUS, start_rad, end_rad, 24, fill_col, RING_THICKNESS)

func _create_math_popup() -> void:
	math_panel = PanelContainer.new()
	math_panel.visible = false
	math_panel.custom_minimum_size = Vector2(120, 75)
	math_panel.position = ring_offset - Vector2(60, 37)

	var vbox := VBoxContainer.new()
	math_label = Label.new()
	math_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	math_timer_label = Label.new()
	math_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	math_timer_label.modulate = Color("#f87171")

	math_input = LineEdit.new()
	math_input.placeholder_text = "Jawaban..."
	math_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	math_input.text_submitted.connect(_on_math_submitted)

	vbox.add_child(math_label)
	vbox.add_child(math_timer_label)
	vbox.add_child(math_input)
	math_panel.add_child(vbox)
	add_child(math_panel)
