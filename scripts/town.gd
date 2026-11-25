extends Node2D

@onready var player: Player = $Player
@onready var mine_entrance_area: Area2D = $MineEntranceArea
@onready var mine_prompt: Label = $MineEntranceArea/PromptLabel

@onready var town_backsound: AudioStreamPlayer = $TownBackSound
@onready var shop_backsound: AudioStreamPlayer = $ShopBackSound

# Variabel untuk quest dan interaksi NPC modalnya
@onready var modal_backdrop: ColorRect = $TownCanvas/ModalBackdrop
@onready var quest_modal: Control = $TownCanvas/QuestModal
@onready var npc_name_label: Label = $TownCanvas/QuestModal/VBox/Header/Names/NPCName
@onready var npc_role_label: Label = $TownCanvas/QuestModal/VBox/Header/Names/NPCRole
@onready var npc_portrait: TextureRect = $TownCanvas/QuestModal/VBox/Header/PortraitBox/Portrait
@onready var favorability_label: Label = $TownCanvas/QuestModal/VBox/Header/Names/FavHearts
@onready var special_item_info: Label = $TownCanvas/QuestModal/VBox/Header/Names/SpecialItemLabel

# Variabel view container
@onready var talk_view: VBoxContainer = $TownCanvas/QuestModal/VBox/TalkView
@onready var quest_view: VBoxContainer = $TownCanvas/QuestModal/VBox/QuestView
@onready var gift_view: VBoxContainer = $TownCanvas/QuestModal/VBox/GiftView

# Variabel elemen percakapan viewnya
@onready var dialog_text: Label = $TownCanvas/QuestModal/VBox/TalkView/DialogBox/DialogText
@onready var btn_next_talk: Button = $TownCanvas/QuestModal/VBox/TalkView/TalkActions/BtnNextTalk
@onready var btn_open_quest: Button = $TownCanvas/QuestModal/VBox/TalkView/TalkActions/BtnOpenQuest
@onready var btn_open_gift: Button = $TownCanvas/QuestModal/VBox/TalkView/TalkActions/BtnOpenGift
@onready var btn_npc_action: Button = $TownCanvas/QuestModal/VBox/TalkView/TalkActions/BtnAction
@onready var btn_npc_action2: Button = $TownCanvas/QuestModal/VBox/TalkView/TalkActions/BtnAction2
@onready var btn_close_talk: Button = $TownCanvas/QuestModal/VBox/TalkView/TalkActions/BtnClose

# Variabel untuk percakapan apothecary modal (Nenek Martha)
@onready var apothecary_modal: Control = $TownCanvas/ApothecaryModal
@onready var apothecary_coins: Label = $TownCanvas/ApothecaryModal/VBox/HeaderRow/Coins
@onready var btn_buy_bandage: Button = $TownCanvas/ApothecaryModal/VBox/CardsRow/CardBandage/VBox/BtnBuyBandage
@onready var btn_buy_medkit: Button = $TownCanvas/ApothecaryModal/VBox/CardsRow/CardMedkit/VBox/BtnBuyMedkit
@onready var btn_buy_elixir: Button = $TownCanvas/ApothecaryModal/VBox/CardsRow/CardElixir/VBox/BtnBuyElixir
@onready var apothecary_feedback: Label = $TownCanvas/ApothecaryModal/VBox/Feedback
@onready var btn_close_apothecary: Button = $TownCanvas/ApothecaryModal/VBox/BtnCloseApothecary

# Variabel untuk percakapan ore shop modal (Blacksmith Ivan)
@onready var ore_shop_modal: Control = $TownCanvas/OreShopModal
@onready var ore_shop_coins: Label = $TownCanvas/OreShopModal/VBox/HeaderRow/Coins
@onready var ore_shop_list: VBoxContainer = $TownCanvas/OreShopModal/VBox/Scroll/OreList
@onready var ore_shop_feedback: Label = $TownCanvas/OreShopModal/VBox/Feedback
@onready var btn_close_ore_shop: Button = $TownCanvas/OreShopModal/VBox/BtnCloseOreShop

# Variabel untuk percakapan craft modal (Blacksmith Ivan Anvil)
@onready var craft_modal: Control = $TownCanvas/CraftModal
@onready var craft_coins: Label = $TownCanvas/CraftModal/VBox/HeaderRow/Coins
@onready var mat_ore_label: Label = $TownCanvas/CraftModal/VBox/Content/LeftBox/MatOre
@onready var mat_coin_label: Label = $TownCanvas/CraftModal/VBox/Content/LeftBox/MatCoin
@onready var next_pickaxe_preview: TextureRect = $TownCanvas/CraftModal/VBox/Content/LeftBox/AnvilArea/NextPickaxePreview
@onready var btn_craft: Button = $TownCanvas/CraftModal/VBox/Content/LeftBox/BtnCraft
@onready var target_title: Label = $TownCanvas/CraftModal/VBox/Content/RightBox/TargetTitle
@onready var target_power: Label = $TownCanvas/CraftModal/VBox/Content/RightBox/TargetPower
@onready var target_desc: Label = $TownCanvas/CraftModal/VBox/Content/RightBox/TargetDesc
@onready var target_status: Label = $TownCanvas/CraftModal/VBox/Content/RightBox/TargetStatus
@onready var craft_feedback: Label = $TownCanvas/CraftModal/VBox/Feedback
@onready var btn_close_craft: Button = $TownCanvas/CraftModal/VBox/BtnCloseCraft

# Variabel elemen questviewnya
@onready var quest_title: Label = $TownCanvas/QuestModal/VBox/QuestView/QuestBox/TitleRow/Title
@onready var quest_diff_badge: Label = $TownCanvas/QuestModal/VBox/QuestView/QuestBox/TitleRow/Badge
@onready var quest_desc: Label = $TownCanvas/QuestModal/VBox/QuestView/QuestBox/Desc
@onready var quest_target: Label = $TownCanvas/QuestModal/VBox/QuestView/QuestBox/TargetProgress
@onready var quest_timer_label: Label = $TownCanvas/QuestModal/VBox/QuestView/QuestBox/TimerLabel
@onready var quest_rewards: Label = $TownCanvas/QuestModal/VBox/QuestView/QuestBox/RewardsLabel
@onready var btn_accept_quest: Button = $TownCanvas/QuestModal/VBox/QuestView/QuestActions/BtnAccept
@onready var btn_complete_quest: Button = $TownCanvas/QuestModal/VBox/QuestView/QuestActions/BtnComplete
@onready var btn_back_from_quest: Button = $TownCanvas/QuestModal/VBox/QuestView/QuestActions/BtnBackFromQuest
@onready var btn_close_quest: Button = $TownCanvas/QuestModal/VBox/QuestView/QuestActions/BtnCloseQuest

# Variabel element gift viewnya
@onready var gift_intro: Label = $TownCanvas/QuestModal/VBox/GiftView/GiftIntro
@onready var gift_feedback: Label = $TownCanvas/QuestModal/VBox/GiftView/GiftFeedback
@onready var gift_grid: HFlowContainer = $TownCanvas/QuestModal/VBox/GiftView/GiftScroll/GiftGrid
@onready var btn_back_from_gift: Button = $TownCanvas/QuestModal/VBox/GiftView/GiftActions/BtnBackFromGift
@onready var btn_close_gift: Button = $TownCanvas/QuestModal/VBox/GiftView/GiftActions/BtnCloseGift

# Variabel untuk percakapan ore exchange shop modal (Barnaby)
@onready var shop_modal: NinePatchRect = $TownCanvas/ShopModal
@onready var shop_total_label: Label = $TownCanvas/ShopModal/VBox/TotalLabel
@onready var btn_sell_all: Button = $TownCanvas/ShopModal/VBox/BtnSellAll
@onready var btn_close_shop: Button = $TownCanvas/ShopModal/VBox/BtnCloseShop

# Variabel untuk audio-audionya
@onready var audio_coin: AudioStreamPlayer = $TownCanvas/AudioCoin
@onready var audio_fanfare: AudioStreamPlayer = $TownCanvas/AudioFanfare
@onready var audio_quest: AudioStreamPlayer = $TownCanvas/AudioQuest

var current_npc_near: String = ""
var is_near_mine: bool = false
var active_npc_id: String = ""
var current_talk_index: int = 0

# Bagian list NPC untuk animasi idle atau berjalan-jalan
@onready var npc_nodes: Dictionary = {
	"mayor": $NPCs/Mayor,
	"blacksmith": $NPCs/Blacksmith,
	"elder": $NPCs/Elder,
	"herbalist": $NPCs/Herbalist,
	"farmer": $NPCs/Farmer,
	"miner_bob": $NPCs/MinerBob,
	"villager_lily": $NPCs/VillagerLily,
	"villager_lucas": $NPCs/VillagerLucas,
	"villager_evelyn": $NPCs/VillagerEvelyn
}

# Bagian collision untuk NPC yang bergerak, supaya tidak menabrak pagar ataupun bangunan
const TOWN_OBSTACLES: Array[Rect2] = [
	Rect2(-60, -140, 120, 95),  # Town Hall
	Rect2(-190, -60, 95, 85),   # Blacksmith Forge
	Rect2(95, -90, 95, 85),     # Merchant Stand
	Rect2(-190, 70, 95, 90),    # Herbalist Cottage
	Rect2(0, 85, 100, 80),      # Farm Pasture & Fences
	Rect2(230, -30, 90, 90)     # Mine Entrance
]

func _is_point_blocked(pt: Vector2) -> bool:
	for obs in TOWN_OBSTACLES:
		if obs.has_point(pt):
			return true
	return false

# Bagian data batas pergerakan untuk setiap NPC (Biar tidak keluar dari kota ataupun masuk mining)
var npc_wander_data: Dictionary = {}

var npc_anim_timer: float = 0.0
var npc_frame_idx: int = 0

var _gm_override: Node = null
var game_manager: Node:
	get:
		if _gm_override != null and is_instance_valid(_gm_override):
			return _gm_override
		if is_inside_tree() and get_tree().root:
			return get_tree().root.get_node_or_null("GameManager")
		return null
	set(val):
		_gm_override = val

# Bagian data konversasi NPC
const NPC_CONVERSATIONS = {
	"mayor": [
		"👑 'Selamat datang di Balai Kota Desa Penambang! Senang melihat penambang muda yang rajin memajukan desa kita.'",
		"👑 'Perdagangan mineral di desa kita berjalan tertib berkat kerja keras para warga.'",
		"👑 'Konon katanya di lantai paling bawah goa tambang terdapat The Abyss yang menyimpan permata berharga.'",
		"👑 'Bila kamu membantu dan meningkatkan persahabatan kita mencapai 7 Hati, akan ada hadiah kehormatan rahasia untukmu!'"
	],
	"merchant": [
		"🏪 'Halo, kawan! Sedang butuh koin? Di sini tempat terbaik menukar hasil galianmu!'",
		"🏪 'Harga mineral sedang stabil hari ini. Bawa hasil galianmu kemari!'",
		"🏪 'Jangan lupa untuk cek Tas [I] dan menaikkan kekuatan beliungmu agar mempermudah kamu menambang.'",
		"🏪 'Kalau persahabatan kita sudah mencapai 7 Hati, aku punya perhiasan rahasia yang akan membantumu!'"
	],
	"blacksmith": [
		"⚒️ 'Jangan kamu lupa! Beliung adalah alat paling penting, pastikan beliungmu selalu terawat!'",
		"⚒️ 'Batu besi dan emas di goa sangat keras. Beliung kayu biasa tidak akan mempan menghadapinya!'",
		"⚒️ 'Pastikan kamu membawa bijih-bijih langkah untuk material beliung barumu.'",
		"⚒️ 'Teruslah mengasah kemampuanmu! Di 7 Hati persahabatan, ada pusaka tempa rahasia menantimu!'"
	],
	"elder": [
		"📜 'Hohoho... selamat datang, anak muda. Kakek sudah meneliti goa tambang ini sejak masih muda.'",
		"📜 'Pertarungan matematika di goa menguji kecerdasan pikiranmu. Jaga 5 hatimu dengan hati-hati!'",
		"📜 'Lantai 1 goa dangkal, Lantai 3 goa emas, dan Lantai 5 adalah Abyss dengan batas waktu cepat!'",
		"📜 'Jika persahabatan kita mencapai 7 Hati, kakek akan mewariskan artefak kuno rahasia peninggalan leluhur.'"
	],
	"herbalist": [
		"🌿 'Halo anak manis! Jangan lupa istirahat ya, menambang di goa gelap itu sangat menguras tenaga.'",
		"🌿 'Nenek meracik salep dan ramuan herbal dari tanaman desa. Kalau hatimu berkurang, nenek akan obati!'",
		"🌿 'Ingat, jawaban salah di goa mengurangi 1 hati darahmu. Jangan sampai pingsan kehabisan darah ya!'",
		"🌿 'Rawatlah hubungan baik dengan nenek hingga 7 Hati, nenek sedang meracik jimat rahasia untukmu!'"
	],
	"farmer": [
		"🌾 'Segarnya aroma tanah dan rumput di peternakan! Hewan-hewanku sangat lincah hari ini.'",
		"🌾 'Sapi, babi, domba, dan ayam sangat suka garam mineral dari goa untuk menjaga kesehatan mereka.'",
		"🌾 'Terkadang pagar peternakan perlu diperbaiki dengan timah supaya ternakku tidak masuk ke dalam perkebunan.'",
		"🌾 'Bila kita akrab hingga 7 Hati, aku akan memberikan jimat keberuntungan rahasia dari padang rumput!'"
	],
	"miner_bob": [
		"⛏️ 'Halo, kawan penambang! Pintu masuk goa ada di sebelahku. Sudah siap menaklukkan goa?'",
		"⛏️ 'Aturan nomor satu di dalam goa: hitung cepat dan tepat! Di Abyss, timer berjalan sangat cepat!'",
		"⛏️ 'Semakin dalam kamu turun, semakin langka dan berkilau bijih mineral yang bisa kamu temukan.'",
		"⛏️ 'Kerja samalah denganku hingga 7 Hati, ada lentera tambang rahasia yang akan kuberikan padamu!'"
	]
}

func _set_game_hud_visible(show: bool) -> void:
	if not is_inside_tree() or get_tree() == null: return
	var root_node = get_tree().root
	if root_node:
		var hud = root_node.get_node_or_null("GameHUD")
		if hud and hud.has_method("set_hud_visible"):
			hud.set_hud_visible(show)

func _play_sfx(sfx: AudioStreamPlayer) -> void:
	if sfx and is_inside_tree() and sfx.stream:
		sfx.play()

func _ready() -> void:
	if game_manager:
		town_backsound.playSound()
		game_manager.current_depth = 0 # Town
		game_manager.stats_changed.emit()
		if not game_manager.quests_updated.is_connected(_on_quests_updated): game_manager.quests_updated.connect(_on_quests_updated)
		game_manager.message_shown.emit("SELAMAT DATANG DI DESA PENAMBANG!", 2.5)
		if game_manager.spawn_at_ladder:
			game_manager.spawn_at_ladder = false
			if player:
				player.position = Vector2(230, 35)
	
	_close_all_modals()
	mine_prompt.visible = false
	
	# Bagian yang mengatur NPC supaya tidak menabrak collision 
	npc_wander_data = {
		"mayor": {
			"home": Vector2(-10, -24),
			"min_pos": Vector2(-40, -30),
			"max_pos": Vector2(40, 0),
			"state": "idle",
			"timer": randf_range(2.0, 5.0),
			"target": Vector2(0, -25)
		},
		"merchant": {
			"home": Vector2(140, -10),
			"min_pos": Vector2(115, -25),
			"max_pos": Vector2(165, 15),
			"state": "idle",
			"timer": randf_range(2.0, 5.0),
			"target": Vector2(140, -10)
		},
		"blacksmith": {
			"home": Vector2(129, -60),
			"min_pos": Vector2(129, -60),
			"max_pos": Vector2(129, -60),
			"state": "idle",
			"timer": randf_range(2.0, 5.0),
			"target": Vector2(129, -60)
		},
		"elder": {
			"home": Vector2(-150, 53),
			"min_pos": Vector2(-155, 50),
			"max_pos": Vector2(-145, 56),
			"state": "idle",
			"timer": randf_range(2.0, 5.0),
			"target": Vector2(-151, 51)
		},
		"herbalist": {
			"home": Vector2(-179, -23),
			"min_pos": Vector2(-190, -25),
			"max_pos": Vector2(-150, 0),
			"state": "idle",
			"timer": randf_range(2.0, 5.0),
			"target": Vector2(-180, -20)
		},
		"farmer": {
			"home": Vector2(-144, 119),
			"min_pos": Vector2(-145, 100),
			"max_pos": Vector2(-120, 130),
			"state": "idle",
			"timer": randf_range(2.0, 5.0),
			"target": Vector2(-130, 115)
		},
		"miner_bob": {
			"home": Vector2(135, 25),
			"min_pos": Vector2(115, 20),
			"max_pos": Vector2(145, 30),
			"state": "idle",
			"timer": randf_range(2.0, 5.0),
			"target": Vector2(138, 27)
		}
	}
	
	if player:
		var cam = player.get_node_or_null("Camera2D")
		if cam:
			cam.limit_left = -260
			cam.limit_top = -200
			cam.limit_right = 460
			cam.limit_bottom = 280
			
	if modal_backdrop:
		modal_backdrop.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed:
				_close_all_modals()
		)
	
	# Bagian untuk menyambungkan navigasi dan tombol aksi dengan aman
	if not btn_close_talk.pressed.is_connected(_close_all_modals): btn_close_talk.pressed.connect(_close_all_modals)
	if not btn_close_quest.pressed.is_connected(_close_all_modals): btn_close_quest.pressed.connect(_close_all_modals)
	if not btn_close_gift.pressed.is_connected(_close_all_modals): btn_close_gift.pressed.connect(_close_all_modals)
	if not btn_close_shop.pressed.is_connected(_close_all_modals): btn_close_shop.pressed.connect(_close_all_modals)
	
	if not btn_next_talk.pressed.is_connected(_on_next_talk_pressed): btn_next_talk.pressed.connect(_on_next_talk_pressed)
	if not btn_open_quest.pressed.is_connected(_show_quest_view): btn_open_quest.pressed.connect(_show_quest_view)
	if not btn_open_gift.pressed.is_connected(_show_gift_view): btn_open_gift.pressed.connect(_show_gift_view)
	if not btn_back_from_quest.pressed.is_connected(_show_talk_view): btn_back_from_quest.pressed.connect(_show_talk_view)
	if not btn_back_from_gift.pressed.is_connected(_show_talk_view): btn_back_from_gift.pressed.connect(_show_talk_view)
	
	if not btn_sell_all.pressed.is_connected(_on_sell_all_pressed): btn_sell_all.pressed.connect(_on_sell_all_pressed)
	if not btn_accept_quest.pressed.is_connected(_on_accept_quest_pressed): btn_accept_quest.pressed.connect(_on_accept_quest_pressed)
	if not btn_complete_quest.pressed.is_connected(_on_complete_quest_pressed): btn_complete_quest.pressed.connect(_on_complete_quest_pressed)
	if not btn_npc_action.pressed.is_connected(_on_npc_action_pressed): btn_npc_action.pressed.connect(_on_npc_action_pressed)
	if not btn_npc_action2.pressed.is_connected(_on_npc_action2_pressed): btn_npc_action2.pressed.connect(_on_npc_action2_pressed)
	
	if not btn_close_apothecary.pressed.is_connected(_close_all_modals): btn_close_apothecary.pressed.connect(_close_all_modals)
	if not btn_close_ore_shop.pressed.is_connected(_close_all_modals): btn_close_ore_shop.pressed.connect(_close_all_modals)
	if not btn_close_craft.pressed.is_connected(_close_all_modals): btn_close_craft.pressed.connect(_close_all_modals)
	
	if not btn_buy_bandage.pressed.is_connected(_on_buy_bandage_pressed): btn_buy_bandage.pressed.connect(_on_buy_bandage_pressed)
	if not btn_buy_medkit.pressed.is_connected(_on_buy_medkit_pressed): btn_buy_medkit.pressed.connect(_on_buy_medkit_pressed)
	if not btn_buy_elixir.pressed.is_connected(_on_buy_elixir_pressed): btn_buy_elixir.pressed.connect(_on_buy_elixir_pressed)
	if not btn_craft.pressed.is_connected(_on_craft_pickaxe_pressed): btn_craft.pressed.connect(_on_craft_pickaxe_pressed)
	
	if not mine_entrance_area.body_entered.is_connected(_on_mine_entered): mine_entrance_area.body_entered.connect(_on_mine_entered)
	if not mine_entrance_area.body_exited.is_connected(_on_mine_exited): mine_entrance_area.body_exited.connect(_on_mine_exited)
	
	# Bagian yang menghubungkan semua pemicu intereaksi NPC
	for npc_id in npc_nodes.keys():
		var node = npc_nodes[npc_id]
		if node:
			_setup_npc(node, npc_id)

func _process(delta: float) -> void:
	# Bagian yang mengatur animasi diam dan berjalan
	npc_anim_timer += delta
	var do_frame_step = false
	if npc_anim_timer >= 0.22:
		npc_anim_timer = 0.0
		npc_frame_idx = (npc_frame_idx + 1) % 6
		do_frame_step = true
		
	for npc_id in npc_nodes.keys():
		var node = npc_nodes[npc_id]
		if not node: continue
		var spr: Sprite2D = node.get_node_or_null("Sprite2D")
		if not spr: continue
		var w_data = npc_wander_data.get(npc_id)
		if not w_data: continue
		
		# Bagian yang mengatur ketika player berinteraksi dengan NPC atau pemain ada di dalam jarak interaksinya
		var is_interacting = (quest_modal.visible and active_npc_id == npc_id) or (shop_modal.visible and active_npc_id == npc_id)
		var is_near = (current_npc_near == npc_id)
		
		if is_interacting or is_near:
			w_data["state"] = "idle"
			if do_frame_step:
				spr.frame = npc_frame_idx % 4 # Idle frames 0..3
			if player:
				spr.flip_h = (player.global_position.x < node.global_position.x)
			continue
		
		w_data["timer"] -= delta
		
		if w_data["state"] == "idle":
			if do_frame_step:
				spr.frame = npc_frame_idx % 4
			if w_data["timer"] <= 0.0:
				var candidate = Vector2.ZERO
				for attempt in range(8):
					candidate = Vector2(
						randf_range(w_data["min_pos"].x, w_data["max_pos"].x),
						randf_range(w_data["min_pos"].y, w_data["max_pos"].y)
					)
					if not _is_point_blocked(candidate):
						break
				w_data["target"] = candidate
				w_data["state"] = "walking"
				w_data["timer"] = randf_range(2.0, 4.0)
		elif w_data["state"] == "walking":
			if do_frame_step:
				spr.frame = 6 + (npc_frame_idx % 6) # Walking frames 6..11
				
			var diff: Vector2 = w_data["target"] - node.position
			var dist: float = diff.length()
			if dist > 2.0:
				var move_dir = diff.normalized()
				var next_pos = node.position + move_dir * 18.0 * delta
				if _is_point_blocked(next_pos):
					w_data["state"] = "idle"
					w_data["timer"] = randf_range(2.0, 5.0)
					spr.frame = 0
				else:
					node.position = next_pos
					if abs(move_dir.x) > 0.1:
						spr.flip_h = (move_dir.x < 0)
			else:
				w_data["state"] = "idle"
				w_data["timer"] = randf_range(3.0, 6.0)
				spr.frame = 0
				
			if w_data["timer"] <= 0.0:
				w_data["state"] = "idle"
				w_data["timer"] = randf_range(2.0, 5.0)
				spr.frame = 0
				
		# Bagian yang membuat NPC tetap di dalam kota dan tidak masuk ke dalam goa
		node.position.x = clampf(node.position.x, w_data["min_pos"].x, w_data["max_pos"].x)
		node.position.y = clampf(node.position.y, w_data["min_pos"].y, w_data["max_pos"].y)
	
	var time_ms = Time.get_ticks_msec()
	var bob_offset = sin(time_ms * 0.007) * 2.0
	for q_id in ["mayor", "blacksmith", "elder", "herbalist", "farmer", "miner_bob"]:
		var q_node = npc_nodes.get(q_id)
		if not q_node: continue
		var marker = q_node.get_node_or_null("QuestMarker")
		if not marker: continue
		marker.position.y = -24.0 + bob_offset
		if game_manager and game_manager.npcs.has(q_id):
			var q_data = game_manager.npcs[q_id]
			var quest = q_data.get("current_quest")
			if quest != null and not quest.get("is_accepted", false) and not quest.get("is_completed", false):
				marker.visible = true
				var diff = quest.get("difficulty", "Common")
				match diff:
					"Common":
						marker.add_theme_color_override("font_color", Color(0.13, 0.8, 0.35, 1.0)) # Hijau = biasa
					"Uncommon", "Rare":
						marker.add_theme_color_override("font_color", Color(0.23, 0.55, 0.98, 1.0)) # Biru = langka
					"Epic", "Legendary", "Abyssal":
						marker.add_theme_color_override("font_color", Color(0.95, 0.22, 0.22, 1.0)) # Merah = hardcore
					_:
						marker.add_theme_color_override("font_color", Color(0.13, 0.8, 0.35, 1.0))
			else:
				marker.visible = false
		else:
			marker.visible = false

	# Bagian yang memperbarui timer untuk modal quest ketika dibuka
	if quest_modal.visible and active_npc_id != "" and quest_view.visible:
		_refresh_quest_timer_label()

func _close_all_modals() -> void:
	quest_modal.visible = false
	shop_modal.visible = false
	if apothecary_modal: apothecary_modal.visible = false
	if ore_shop_modal: ore_shop_modal.visible = false
	if craft_modal: craft_modal.visible = false
	if modal_backdrop:
		modal_backdrop.visible = false
	_set_game_hud_visible(true)

func _setup_npc(npc_node: Node2D, npc_id: String) -> void:
	var area = npc_node.get_node_or_null("Area2D")
	var prompt = npc_node.get_node_or_null("Prompt")
	if prompt:
		prompt.visible = false
	if area:
		area.body_entered.connect(func(b):
			if b is Player:
				current_npc_near = npc_id
				if prompt: prompt.visible = true
		)
		area.body_exited.connect(func(b):
			if b is Player:
				if current_npc_near == npc_id:
					current_npc_near = ""
				if prompt: prompt.visible = false
				if quest_modal.visible and active_npc_id == npc_id:
					_close_all_modals()
				elif shop_modal.visible:
					_close_all_modals()
		)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if is_near_mine:
				if game_manager:
					town_backsound.stopSound()
					game_manager.go_to_mine_level(1)
			elif current_npc_near != "":
				_open_npc_dialog(current_npc_near)
		elif event.keycode == KEY_ESCAPE:
			_close_all_modals()
		elif event.keycode == KEY_F5:
			if game_manager:
				if game_manager.player_level < 50:
					game_manager.set_player_level(50)
				else:
					game_manager.set_player_level(1)

func _on_mine_entered(body: Node2D) -> void:
	if body is Player:
		is_near_mine = true
		mine_prompt.visible = true

func _on_mine_exited(body: Node2D) -> void:
	if body is Player:
		is_near_mine = false
		mine_prompt.visible = false

# Bagian yang mengatur interaksi NPC dan window perbicaraannya
func _translate_ore_name(ore: String) -> String:
	match ore.to_lower():
		"stone": return "Batu"
		"coal": return "Batu Bara"
		"tin": return "Timah"
		"iron": return "Besi"
		"silver": return "Perak"
		"gold": return "Emas"
		"amethyst": return "Kecubung"
		"diamond": return "Berlian"
		_: return ore.capitalize()

func _translate_difficulty(diff: String) -> String:
	match diff:
		"Common": return "BIASA"
		"Uncommon": return "MENENGAH"
		"Rare": return "LANGKA"
		"Epic": return "EPIK"
		"Legendary": return "LEGENDARIS"
		_: return diff.to_upper()

func _open_npc_dialog(npc_id: String) -> void:
	if not game_manager or not game_manager.npcs.has(npc_id): return
	active_npc_id = npc_id
	current_talk_index = 0
	shop_modal.visible = false
	
	var npc = game_manager.npcs[npc_id]
	npc_name_label.text = npc["name"]
	npc_role_label.text = npc["title"] + " • " + npc["role"]
	
	# Bagian yang mengatur potret diam yang menghadap ke depan (Ukurang bingkainya 32 x 32)
	if ResourceLoader.exists(npc["sprite"]):
		var tex = load(npc["sprite"])
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = tex
		atlas_tex.region = Rect2(0, 0, 32, 32)
		npc_portrait.texture = atlas_tex
		
	# Display untuk tingkat kesukaan/persahabatan (Dari 0 sampai 7 hati)
	_refresh_favorability_header()
	
	# Bagian tombol aksi NPC spesial dan per-izinan hadiah
	var is_cit = npc.get("is_citizen", false)
	if is_cit:
		btn_open_quest.visible = false
		btn_open_gift.visible = false
		btn_npc_action.visible = false
		btn_npc_action2.visible = false
	elif npc_id == "blacksmith":
		btn_open_quest.visible = true
		btn_open_gift.visible = false # Blacksmith Ivan menukarkan ore, bukan memberi!
		btn_npc_action.visible = true
		btn_npc_action.text = "💰 TOKO BIJIH"
		btn_npc_action2.visible = true
		btn_npc_action2.text = "🔨 TEMPA BELIUNG"
	elif npc_id == "herbalist":
		btn_open_quest.visible = true
		btn_open_gift.visible = true
		btn_npc_action.visible = true
		btn_npc_action.text = "🌿 APOTEK"
		btn_npc_action2.visible = false
	else:
		btn_open_quest.visible = true
		btn_open_gift.visible = true
		btn_npc_action.visible = false
		btn_npc_action2.visible = false
		
	# Untuk dibuka tepat dalam pembicaraan (Ngobrol dulu)
	_show_talk_view()
	
	_set_game_hud_visible(false)
	shop_modal.visible = false
	if apothecary_modal: apothecary_modal.visible = false
	if ore_shop_modal: ore_shop_modal.visible = false
	if craft_modal: craft_modal.visible = false
	quest_modal.visible = true
	if modal_backdrop:
		modal_backdrop.visible = true

func _refresh_favorability_header() -> void:
	if not game_manager or active_npc_id == "": return
	var npc = game_manager.npcs[active_npc_id]
	var is_cit = npc.get("is_citizen", false)
	if is_cit:
		favorability_label.text = "Penduduk Desa"
		special_item_info.text = ""
		special_item_info.visible = false
		return
	if active_npc_id == "blacksmith":
		favorability_label.text = "Pandai Besi Desa (Jual Biji & Upgrade)"
		special_item_info.text = ""
		special_item_info.visible = false
		return
		
	var fav: float = npc.get("favorability", 0.0)
	favorability_label.text = "♥ Persahabatan: %.1f / 7.0 Hati" % fav
	special_item_info.visible = true
	
	var claimed = npc.get("special_item_claimed", false)
	if claimed:
		special_item_info.text = "✨ Hadiah: " + npc.get("special_item_name", "")
	else:
		special_item_info.text = "🔒 Hadiah Spesial: Terbuka di 7 Hati"

func _show_talk_view() -> void:
	talk_view.visible = true
	quest_view.visible = false
	gift_view.visible = false
	_display_current_talk_line()

func _display_current_talk_line() -> void:
	var lines = NPC_CONVERSATIONS.get(active_npc_id, ["'Halo, senang bertemu denganmu!'"])
	if current_talk_index >= lines.size():
		current_talk_index = 0
	dialog_text.text = lines[current_talk_index]

func _on_next_talk_pressed() -> void:
	if audio_coin and is_inside_tree() and audio_coin.stream:
		_play_sfx(audio_coin)
	var lines = NPC_CONVERSATIONS.get(active_npc_id, ["'Halo!'"])
	current_talk_index = (current_talk_index + 1) % lines.size()
	_display_current_talk_line()

func _show_quest_view() -> void:
	talk_view.visible = false
	quest_view.visible = true
	gift_view.visible = false
	_refresh_quest_view()

func _show_gift_view() -> void:
	talk_view.visible = false
	quest_view.visible = false
	gift_view.visible = true
	_refresh_gift_view()

# Bagian yang mengatur sistem "Gifting"
func _refresh_gift_view() -> void:
	if not game_manager or active_npc_id == "": return
	var npc = game_manager.npcs[active_npc_id]
	gift_intro.text = "Pilih bijih atau uang untuk dihadiahkan kepada %s:" % npc["name"]
	gift_feedback.text = ""
	
	# Untuk menghapus tombol "Gift" sebelumnya
	for child in gift_grid.get_children():
		child.queue_free()
		
	# 1. Tombol "Gift" koin
	var btn_coin_50 = Button.new()
	btn_coin_50.custom_minimum_size = Vector2(76, 16)
	btn_coin_50.add_theme_font_size_override("font_size", 6)
	btn_coin_50.text = "🪙 50 Koin"
	if game_manager.money >= 50:
		btn_coin_50.pressed.connect(_on_give_gift_pressed.bind("coins", 50))
	else:
		btn_coin_50.disabled = true
		btn_coin_50.modulate = Color(0.6, 0.6, 0.6, 1)
	gift_grid.add_child(btn_coin_50)
	
	var btn_coin_100 = Button.new()
	btn_coin_100.custom_minimum_size = Vector2(76, 16)
	btn_coin_100.add_theme_font_size_override("font_size", 6)
	btn_coin_100.text = "🪙 100 Koin"
	if game_manager.money >= 100:
		btn_coin_100.pressed.connect(_on_give_gift_pressed.bind("coins", 100))
	else:
		btn_coin_100.disabled = true
		btn_coin_100.modulate = Color(0.6, 0.6, 0.6, 1)
	gift_grid.add_child(btn_coin_100)
	
	# 2. Tombol "Gift" ore
	var ore_emojis = {
		"stone": "🪨",
		"coal": "⬛",
		"tin": "🪙",
		"iron": "⛓️",
		"silver": "🥈",
		"gold": "🥇",
		"amethyst": "🔮",
		"diamond": "💎"
	}
	
	var has_any_ore = false
	for ore in ["stone", "coal", "tin", "iron", "silver", "gold", "amethyst", "diamond"]:
		var count = game_manager.get_ore_count(ore)
		if count > 0:
			has_any_ore = true
			var btn_ore = Button.new()
			btn_ore.custom_minimum_size = Vector2(80, 16)
			btn_ore.add_theme_font_size_override("font_size", 6)
			var emo = ore_emojis.get(ore, "⛏️")
			btn_ore.text = "%s %s (x%d)" % [emo, _translate_ore_name(ore), count]
			btn_ore.pressed.connect(_on_give_gift_pressed.bind(ore, 1))
			gift_grid.add_child(btn_ore)
			
	if not has_any_ore and game_manager.money < 50:
		var empty_lbl = Label.new()
		empty_lbl.add_theme_font_size_override("font_size", 6)
		empty_lbl.add_theme_color_override("font_color", Color("#991b1b"))
		empty_lbl.text = "Kamu belum memiliki koin atau bijih untuk dihadiahkan!"
		gift_grid.add_child(empty_lbl)

func _on_give_gift_pressed(gift_type: String, amount: int) -> void:
	if not game_manager or active_npc_id == "": return
	var res = game_manager.give_gift_to_npc(active_npc_id, gift_type, amount)
	if res.get("success", false):
		var reaction = res.get("reaction", "neutral")
		if reaction in ["loved", "liked"]:
			_play_sfx(audio_coin)
			gift_feedback.modulate = Color("#15803d") # Emerald Green
		elif reaction == "disliked":
			gift_feedback.modulate = Color("#991b1b") # Red
		else:
			_play_sfx(audio_coin)
			gift_feedback.modulate = Color("#3730a3") # Indigo
			
		gift_feedback.text = res["message"]
		_refresh_favorability_header()
		_refresh_gift_view()
		
		if res.get("special_unlocked", false):
			_play_sfx(audio_fanfare)
			game_manager.message_shown.emit("✨ SELAMAT! Persahabatan 7 Hati tercapai!\nHadiah Rahasia Terbuka: " + res["special_name"] + "!", 4.0)

# Bagian yang memberikan detail view quest
func _refresh_quest_view() -> void:
	if not game_manager or active_npc_id == "": return
	var quest = game_manager.get_npc_quest(active_npc_id)
	if quest.is_empty():
		quest_title.text = "Tidak ada quest yang tersedia"
		quest_diff_badge.text = ""
		quest_desc.text = ""
		quest_target.text = ""
		quest_timer_label.text = ""
		quest_rewards.text = ""
		btn_accept_quest.disabled = true
		btn_complete_quest.disabled = true
		return
		
	quest_title.text = quest["title"]
	quest_diff_badge.text = "[" + _translate_difficulty(quest["difficulty"]) + "]"
	
	match quest["difficulty"]:
		"Common": quest_diff_badge.modulate = Color("#475569")
		"Uncommon": quest_diff_badge.modulate = Color("#15803d")
		"Rare": quest_diff_badge.modulate = Color("#1d4ed8")
		"Epic": quest_diff_badge.modulate = Color("#7e22ce")
		"Legendary": quest_diff_badge.modulate = Color("#b45309")
		
	quest_desc.visible = false
	
	var target_ore = quest.get("target_ore", "")
	var target_count = quest.get("target_count", 0)
	var owned_count = game_manager.get_ore_count(target_ore)
	quest_target.text = "🎯 Target: Kumpulkan %d %s (Dimiliki: %d)" % [target_count, _translate_ore_name(target_ore), owned_count]
	if owned_count >= target_count:
		quest_target.modulate = Color("#15803d")
	else:
		quest_target.modulate = Color("#991b1b")
		
	quest_rewards.text = "🎁 Hadiah: 🪙 +%d Koin  |  ⭐ +%d XP  |  ❤️ +1 Hati" % [quest["reward_coins"], quest["reward_xp"]]
	_refresh_quest_timer_label()
	
	var is_mayor = (active_npc_id == "mayor")
	if not quest["is_accepted"]:
		btn_accept_quest.visible = true
		btn_complete_quest.visible = false
		if is_mayor and game_manager.player_level < 50:
			btn_accept_quest.text = "⚠️ BUTUH LEVEL 50"
			btn_accept_quest.disabled = true
			btn_accept_quest.modulate = Color(0.7, 0.7, 0.7, 1)
		else:
			btn_accept_quest.text = "📋 TERIMA QUEST"
			btn_accept_quest.disabled = false
			btn_accept_quest.modulate = Color.WHITE
	else:
		btn_accept_quest.visible = false
		btn_complete_quest.visible = true
		
		if owned_count >= target_count:
			btn_complete_quest.text = "🎉 SELESAIKAN!"
			btn_complete_quest.disabled = false
			btn_complete_quest.modulate = Color.WHITE
		else:
			btn_complete_quest.text = "❌ BELUM CUKUP"
			btn_complete_quest.disabled = true
			btn_complete_quest.modulate = Color(0.7, 0.7, 0.7, 1)

func _refresh_quest_timer_label() -> void:
	if not game_manager or active_npc_id == "": return
	var npc = game_manager.npcs.get(active_npc_id)
	if not npc: return
	var quest = npc.get("current_quest")
	if not quest: return
	
	if not quest["is_accepted"]:
		var unacc_time = max(0.0, npc["unaccepted_timer"])
		var m = int(unacc_time) / 60
		var s = int(unacc_time) % 60
		quest_timer_label.text = "⏱️ Waktu: %d mnt (Ganti dlm %02d:%02d jika tak diambil)" % [int(quest["time_limit"] / 60), m, s]
		quest_timer_label.modulate = Color("#3730a3")
	else:
		var rem = quest["time_remaining"]
		if rem > 0.0:
			var m = int(rem) / 60
			var s = int(rem) % 60
			quest_timer_label.text = "⏱️ Sisa Waktu: %02d:%02d  (+1 Hati tepat waktu)" % [m, s]
			quest_timer_label.modulate = Color("#1e3a8a")
		else:
			quest_timer_label.text = "⏱️ WAKTU HABIS - TERLAMBAT!  (+0.5 Hati jika selesai)"
			quest_timer_label.modulate = Color("#991b1b")

func _on_accept_quest_pressed() -> void:
	if active_npc_id == "mayor" and game_manager.player_level < 50:
		return
			
	if game_manager.accept_quest(active_npc_id):
		_play_sfx(audio_coin)
		_refresh_quest_view()

func _on_complete_quest_pressed() -> void:
	if not game_manager: return
	var res = game_manager.complete_quest(active_npc_id)
	if res.get("success", false):
		_play_sfx(audio_quest)
		if res.get("special_unlocked", false):
			_play_sfx(audio_fanfare)
		game_manager.message_shown.emit("🎉 QUEST SELESAI: %s! (+%d Koin, +%.1f Hati)" % [res["title"], res["coins"], res["heart_award"]], 3.5)
		_open_npc_dialog(active_npc_id)

func _on_npc_action_pressed() -> void:
	if active_npc_id == "herbalist":
		_open_apothecary()
	elif active_npc_id == "blacksmith":
		_open_ore_shop()

func _on_npc_action2_pressed() -> void:
	if active_npc_id == "blacksmith":
		_open_craft()

func _on_quests_updated() -> void:
	if quest_modal.visible and active_npc_id != "" and quest_view.visible:
		_refresh_quest_view()

# Bagian yang mengatur perbincangan dan shop di apochetary modal (Nenek Martha)
func _open_apothecary() -> void:
	quest_modal.visible = false
	town_backsound.stopSound()
	shop_backsound.playSound()
	_refresh_apothecary_modal()
	_set_game_hud_visible(false)
	if apothecary_modal: apothecary_modal.visible = true
	if modal_backdrop: modal_backdrop.visible = true

func _refresh_apothecary_modal() -> void:
	if not game_manager: return
	apothecary_coins.text = "🪙 Koin: " + str(game_manager.money)
	btn_buy_bandage.disabled = game_manager.money < 15 or game_manager.current_hearts >= game_manager.max_hearts
	btn_buy_medkit.disabled = game_manager.money < 40 or game_manager.current_hearts >= game_manager.max_hearts
	btn_buy_elixir.disabled = game_manager.money < 100

func _on_buy_bandage_pressed() -> void:
	if not game_manager: return
	if game_manager.money < 15:
		apothecary_feedback.text = "❌ Koin tidak cukup! Butuh 15 Koin."
		apothecary_feedback.modulate = Color("#dc2626")
		return
	game_manager.money -= 15
	game_manager.heal_hearts(2)
	_play_sfx(audio_coin)
	apothecary_feedback.text = "✅ Membeli Perban Herbal! (+2 Hati Pulih ❤️)"
	apothecary_feedback.modulate = Color("#15803d")
	_refresh_apothecary_modal()
	_refresh_favorability_header()

func _on_buy_medkit_pressed() -> void:
	if not game_manager: return
	if game_manager.money < 40:
		apothecary_feedback.text = "❌ Koin tidak cukup! Butuh 40 Koin."
		apothecary_feedback.modulate = Color("#dc2626")
		return
	game_manager.money -= 40
	game_manager.heal_full()
	_play_sfx(audio_coin)
	apothecary_feedback.text = "💖 Membeli Kotak Obat P3K! Darah pulih 100%!"
	apothecary_feedback.modulate = Color("#15803d")
	_refresh_apothecary_modal()
	_refresh_favorability_header()

func _on_buy_elixir_pressed() -> void:
	if not game_manager: return
	if game_manager.money < 100:
		apothecary_feedback.text = "❌ Koin tidak cukup! Butuh 100 Koin."
		apothecary_feedback.modulate = Color("#dc2626")
		return
	game_manager.money -= 100
	game_manager.apply_elixir()
	_play_sfx(audio_fanfare)
	apothecary_feedback.text = "✨ Meminum Elixir Kehidupan! 100% Darah + Buff Regen 3 Menit Aktif!"
	apothecary_feedback.modulate = Color("#7c3aed")
	_refresh_apothecary_modal()
	_refresh_favorability_header()

func _on_btn_close_apothecary_pressed() -> void:
	shop_backsound.stopSound()
	town_backsound.playSound()

# Bagian yang mengatur pembicaraan dan shop ore modal (Blacksmith Ivan)
func _open_ore_shop() -> void:
	quest_modal.visible = false
	_refresh_ore_shop_modal()
	_set_game_hud_visible(false)
	if ore_shop_modal: ore_shop_modal.visible = true
	if modal_backdrop: modal_backdrop.visible = true

func _refresh_ore_shop_modal() -> void:
	if not game_manager: return
	ore_shop_coins.text = "🪙 Koin: " + str(game_manager.money)
	ore_shop_feedback.text = ""
	
	# Untuk menghapus list itemnya
	for child in ore_shop_list.get_children():
		child.queue_free()
		
	var ores = ["stone", "coal", "tin", "iron", "silver", "gold", "amethyst", "diamond"]
	var total_available = 0
	
	for ore in ores:
		var count = game_manager.get_ore_count(ore)
		total_available += count
		var price = game_manager.get_ore_price(ore)
		if game_manager.has_special_item("Golden Merchant Ring") or game_manager.has_special_item("Cincin Emas Pedagang"):
			price = int(price * 1.25)
			
		var row = HBoxContainer.new()
		row.custom_minimum_size = Vector2(240, 16)
		row.add_theme_constant_override("separation", 4)
		
		var lbl_info = Label.new()
		lbl_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_info.add_theme_font_size_override("font_size", 6)
		lbl_info.add_theme_color_override("font_color", Color("#261c14"))
		lbl_info.text = "⛏️ %s: Dimiliki %d (%d 🪙/biji)" % [_translate_ore_name(ore), count, price]
		row.add_child(lbl_info)
		
		var btn_sell_1 = Button.new()
		btn_sell_1.custom_minimum_size = Vector2(40, 14)
		btn_sell_1.add_theme_font_size_override("font_size", 6)
		btn_sell_1.text = "Jual 1"
		btn_sell_1.disabled = count <= 0
		btn_sell_1.pressed.connect(_on_sell_single_pressed.bind(ore, 1))
		row.add_child(btn_sell_1)
		
		var btn_sell_all_ore = Button.new()
		btn_sell_all_ore.custom_minimum_size = Vector2(50, 14)
		btn_sell_all_ore.add_theme_font_size_override("font_size", 6)
		btn_sell_all_ore.text = "Jual Semua"
		btn_sell_all_ore.disabled = count <= 0
		btn_sell_all_ore.pressed.connect(_on_sell_all_ore_pressed.bind(ore))
		row.add_child(btn_sell_all_ore)
		
		ore_shop_list.add_child(row)
		
	if total_available == 0:
		ore_shop_feedback.text = "Kamu belum memiliki bijih apapun untuk dijual."
		ore_shop_feedback.modulate = Color("#991b1b")

func _on_sell_single_pressed(ore: String, count: int) -> void:
	if not game_manager: return
	var res = game_manager.sell_single_ore(ore, count)
	if res.get("success", false):
		_play_sfx(audio_coin)
		ore_shop_feedback.text = "🎉 Berhasil menjual %dx %s (+%d Koin)!" % [count, _translate_ore_name(ore), res["earned"]]
		ore_shop_feedback.modulate = Color("#15803d")
		_refresh_ore_shop_modal()

func _on_sell_all_ore_pressed(ore: String) -> void:
	if not game_manager: return
	var res = game_manager.sell_all_of_type(ore)
	if res.get("success", false):
		_play_sfx(audio_coin)
		ore_shop_feedback.text = "🎉 Berhasil menjual semua %s (+%d Koin)!" % [_translate_ore_name(ore), res["earned"]]
		ore_shop_feedback.modulate = Color("#15803d")
		_refresh_ore_shop_modal()

# Bagian yang mengatur pembicaraan dan Craft Anvil modal (Blacksmith Ivan)
func _open_craft() -> void:
	quest_modal.visible = false
	_refresh_craft_modal()
	_set_game_hud_visible(false)
	if craft_modal: craft_modal.visible = true
	if modal_backdrop: modal_backdrop.visible = true

func _refresh_craft_modal() -> void:
	if not game_manager: return
	craft_coins.text = "🪙 Koin: " + str(game_manager.money)
	craft_feedback.text = ""
	
	var tier = game_manager.pickaxe_tier
	if tier >= 5:
		target_title.text = "★ Beliung Berlian Maksimal ★"
		target_power.text = "⛏️ Kekuatan Gali: 5 (Maksimal)"
		target_desc.text = "Beliungmu telah mencapai puncak kesempurnaan seorang penambang sejati!"
		target_status.text = "★ SEMPURNA & MAKSIMAL ★"
		target_status.modulate = Color("#38bdf8")
		mat_ore_label.text = "⛏️ Bijih: Selesai"
		mat_coin_label.text = "🪙 Koin: Selesai"
		btn_craft.disabled = true
		btn_craft.text = "SUDAH MAKSIMAL"
		return
		
	var next_tier = tier + 1
	var next_info = game_manager.PICKAXE_TIERS[next_tier]
	
	target_title.text = next_info["name"] + " (Tingkat " + str(next_tier) + "/5)"
	target_power.text = "⛏️ Kekuatan Gali: " + str(next_info["power"])
	
	var ore_req = next_info["cost_ore"]
	var ore_count_req = next_info["cost_ore_count"]
	var coin_req = next_info["cost_coins"]
	
	var ore_cur = game_manager.get_ore_count(ore_req) if ore_req != "" else 0
	mat_ore_label.text = "⛏️ Bijih: %d / %d %s" % [ore_cur, ore_count_req, _translate_ore_name(ore_req)] if ore_req != "" else "⛏️ Bijih: Bebas"
	mat_coin_label.text = "🪙 Koin: %d / %d 🪙" % [game_manager.money, coin_req]
	
	if ResourceLoader.exists(next_info["icon"]):
		next_pickaxe_preview.texture = load(next_info["icon"])
		
	var can_up = game_manager.can_upgrade_pickaxe()
	if can_up:
		target_status.text = "✅ Bahan Lengkap! Siap Ditempa"
		target_status.modulate = Color("#15803d")
		btn_craft.disabled = false
		btn_craft.text = "🔨 TEMPA SEKARANG"
	else:
		target_status.text = "❌ Bahan atau koin belum mencukupi"
		target_status.modulate = Color("#dc2626")
		btn_craft.disabled = true
		btn_craft.text = "TERKUNCI"

func _on_craft_pickaxe_pressed() -> void:
	if not game_manager: return
	if game_manager.upgrade_pickaxe():
		_play_sfx(audio_fanfare)
		var new_name = game_manager.PICKAXE_TIERS[game_manager.pickaxe_tier]["name"]
		craft_feedback.text = "✨ Beliung berhasil ditempa menjadi %s!" % new_name
		craft_feedback.modulate = Color("#15803d")
		game_manager.message_shown.emit("⚒️ Sukses menempa " + new_name + "!", 3.0)
		_refresh_craft_modal()

func _on_sell_all_pressed() -> void:
	pass
