extends CanvasLayer

@onready var heart_icons: Array = [
	$HUDContainer/TopLeft/Margin/VBox/HeartsRow/H1,
	$HUDContainer/TopLeft/Margin/VBox/HeartsRow/H2,
	$HUDContainer/TopLeft/Margin/VBox/HeartsRow/H3,
	$HUDContainer/TopLeft/Margin/VBox/HeartsRow/H4,
	$HUDContainer/TopLeft/Margin/VBox/HeartsRow/H5,
	$HUDContainer/TopLeft/Margin/VBox/HeartsRow/H6
]

@onready var level_label: Label = $HUDContainer/TopLeft/Margin/VBox/LevelRow/LevelLabel
@onready var coin_label: Label = $HUDContainer/TopLeft/Margin/VBox/CoinRow/CoinLabel
@onready var pickaxe_label: Label = $HUDContainer/TopLeft/Margin/VBox/PickaxeRow/PickaxeLabel
@onready var pickaxe_icon: TextureRect = $HUDContainer/TopLeft/Margin/VBox/PickaxeRow/PickaxeIcon
@onready var depth_label: Label = $HUDContainer/TopRight/DepthLabel
@onready var btn_open_inv: BaseButton = $HUDContainer/BtnBackpack

# Iventori versi Modal
@onready var inv_modal: Control = $InventoryModal
@onready var modal_coins_label: Label = $InventoryModal/Panel/VBox/BottomRow/CoinsLabel
@onready var btn_close_inv: Button = $InventoryModal/Panel/VBox/EquipmentHeader/BtnClose
@onready var equip_icon: TextureRect = $InventoryModal/Panel/VBox/EquipContent/PickaxeSlotFrame/EquippedIcon
@onready var equip_name: Label = $InventoryModal/Panel/VBox/EquipContent/EquipDetails/EquippedName
@onready var equip_power: Label = $InventoryModal/Panel/VBox/EquipContent/EquipDetails/EquippedPower

@onready var ore_labels: Dictionary = {
	"stone": $InventoryModal/Panel/VBox/Grid/OreStone/HBox/Count,
	"coal": $InventoryModal/Panel/VBox/Grid/OreCoal/HBox/Count,
	"tin": $InventoryModal/Panel/VBox/Grid/OreTin/HBox/Count,
	"iron": $InventoryModal/Panel/VBox/Grid/OreIron/HBox/Count,
	"silver": $InventoryModal/Panel/VBox/Grid/OreSilver/HBox/Count,
	"gold": $InventoryModal/Panel/VBox/Grid/OreGold/HBox/Count,
	"amethyst": $InventoryModal/Panel/VBox/Grid/OreAmethyst/HBox/Count,
	"diamond": $InventoryModal/Panel/VBox/Grid/OreDiamond/HBox/Count,
}

# Untuk audionya
@onready var audio_upgrade: AudioStreamPlayer = $AudioUpgrade
@onready var audio_coin: AudioStreamPlayer = $AudioCoin

# Nontifikasi Bannernya
@onready var banner_panel: PanelContainer = $BannerPanel
@onready var banner_label: Label = $BannerPanel/MarginContainer/BannerLabel

const TEX_HEART_FULL = preload("res://assets/images/hud/heart_full.png")
const TEX_HEART_EMPTY = preload("res://assets/images/hud/heart_empty.png")

var is_inv_open: bool = false

var gm: Node:
	get:
		if is_inside_tree() and get_tree().root:
			return get_tree().root.get_node_or_null("GameManager")
		return null

func set_hud_visible(show: bool) -> void:
	$HUDContainer.visible = show

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	inv_modal.visible = false
	banner_panel.visible = false
	
	if not btn_open_inv.pressed.is_connected(toggle_inventory): btn_open_inv.pressed.connect(toggle_inventory)
	if not btn_close_inv.pressed.is_connected(toggle_inventory): btn_close_inv.pressed.connect(toggle_inventory)
	
	if gm:
		gm.stats_changed.connect(refresh_hud)
		gm.inventory_changed.connect(refresh_inventory_modal)
		gm.player_fainted.connect(_on_player_fainted)
		gm.message_shown.connect(show_banner)
		gm.special_item_unlocked.connect(_on_special_item_unlocked)
		refresh_hud()
		refresh_inventory_modal()
	
	_check_scene_visibility()
	if is_inside_tree() and get_tree() != null: get_tree().node_added.connect(func(_n): _check_scene_visibility())

func _check_scene_visibility() -> void:
	if not is_inside_tree() or get_tree() == null: return
	var cur = get_tree().current_scene
	if cur and (cur.name == "MainMenu" or "MainMenu" in cur.name):
		$HUDContainer.visible = false
	else:
		$HUDContainer.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("i"):
		toggle_inventory()
	elif is_inv_open and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle_inventory()

func toggle_inventory() -> void:
	is_inv_open = !is_inv_open
	inv_modal.visible = is_inv_open
	if is_inv_open:
		refresh_inventory_modal()

func refresh_hud() -> void:
	if not is_inside_tree() or not gm: return
	
	# Bagain untuk memperbarui hatinya (Mendukung sampai 6 hati jika memiliki item spesial "Heart Amulet")
	var max_h = gm.max_hearts
	for i in range(heart_icons.size()):
		var icon: TextureRect = heart_icons[i]
		if i < max_h:
			icon.visible = true
			if i < gm.current_hearts:
				icon.texture = TEX_HEART_FULL
			else:
				icon.texture = TEX_HEART_EMPTY
		else:
			icon.visible = false
	
	# Bagian untuk meningkatkan levelnya dan XPnya
	if level_label:
		var req_xp = gm.get_xp_required_for_level(gm.player_level)
		level_label.text = "⭐ Lv. %d (XP: %d/%d)" % [gm.player_level, gm.player_xp, req_xp]
	
	# Bagian untuk memperbarui koin player
	coin_label.text = str(gm.money)
	
	# Bagian untuk memperbarui peningkatan beliung dan buff elixirnya
	var p_info = gm.PICKAXE_TIERS.get(gm.pickaxe_tier, gm.PICKAXE_TIERS[1])
	if gm.regen_buff_timer > 0.0:
		var mins = int(gm.regen_buff_timer) / 60
		var secs = int(gm.regen_buff_timer) % 60
		pickaxe_label.text = "%s (Kekuatan: %d) | 🌿 Regen: %02d:%02d" % [p_info["name"], p_info["power"], mins, secs]
	else:
		pickaxe_label.text = p_info["name"] + " (Kekuatan: " + str(p_info["power"]) + ")"
	if ResourceLoader.exists(p_info["icon"]):
		pickaxe_icon.texture = load(p_info["icon"])
	
	# Bagian untuk memperbarui kedalaman tambangnya
	if gm.current_depth == 0:
		depth_label.text = "🏘️ Kota Penambang"
		depth_label.modulate = Color("#e2e8f0")
	elif gm.current_depth == 5:
		depth_label.text = "☠️ Lantai 5: BIOMA ABYSS"
		depth_label.modulate = Color("#f43f5e")
	else:
		depth_label.text = "⛏️ Goa Tambang - Lantai " + str(gm.current_depth)
		depth_label.modulate = Color("#e2e8f0")

func _on_special_item_unlocked(npc_name: String, item_name: String, desc: String) -> void:
	show_banner("💖 7 HATI PERSAHABATAN TERCAPAI!\n%s memberimu: [%s]!\n%s" % [npc_name, item_name, desc], 5.0)

func refresh_inventory_modal() -> void:
	if not is_inside_tree() or not gm: return
	modal_coins_label.text = "🪙 Koin: " + str(gm.money)
	
	# Bagian yang memperbarui jumlah ore
	for ore in ore_labels.keys():
		var lbl: Label = ore_labels.get(ore)
		if lbl:
			lbl.text = "x " + str(gm.get_ore_count(ore))
	
	# Bagian untuk memperbarui perlengkapan player (Hanya slot toolsnya, tidak ada armor)
	var tier = gm.pickaxe_tier
	var cur_info = gm.PICKAXE_TIERS.get(tier, gm.PICKAXE_TIERS[1])
	if ResourceLoader.exists(cur_info["icon"]):
		equip_icon.texture = load(cur_info["icon"])
	equip_name.text = cur_info["name"] + " (Tingkat " + str(tier) + "/5)"
	equip_power.text = "⛏️ Kekuatan Gali: " + str(cur_info["power"])

func _on_player_fainted(penalty: int) -> void:
	show_banner("💀 Kamu pingsan di dalam goa tambang!\nBiaya pengobatan: -" + str(penalty) + " Koin. Kembali ke Desa.", 3.5)
	await get_tree().create_timer(2.0).timeout
	if gm:
		gm.go_to_town()

func show_banner(text: String, duration: float = 2.5) -> void:
	banner_label.text = text
	banner_panel.visible = true
	banner_panel.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_property(banner_panel, "modulate:a", 0.0, 0.4)
	await tween.finished
	banner_panel.visible = false
