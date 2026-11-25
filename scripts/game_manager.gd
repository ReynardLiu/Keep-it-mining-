extends Node
class_name GameManagerClass

signal stats_changed
signal inventory_changed
signal player_fainted(penalty: int)
signal message_shown(text: String, duration: float)
signal quests_updated
signal special_item_unlocked(npc_name: String, item_name: String, desc: String)
signal player_jailed(fine: int, duration: float)
signal player_released_from_jail

# Stat untuk Player
var max_hearts: int = 5
var current_hearts: int = 5
var money: int = 150 # Koin awal-awal
var streak: int = 0
var current_depth: int = 0 # 0 = Town, 1-5 = Mine levels
var pickaxe_tier: int = 1 # 1: Wood, 2: Stone, 3: Iron, 4: Gold, 5: Diamond
var regen_buff_timer: float = 0.0 # 3 min buff elexir
var regen_tick: float = 0.0

# Sistem level dan progresinya
var player_level: int = 1
var player_xp: int = 0

# Membuka item spesialnya (Ketika mencapai hati ke-7)
var unlocked_special_items: Array = []

var inventory_ores: Dictionary = {
	"stone": 0,
	"coal": 0,
	"tin": 0,
	"iron": 0,
	"silver": 0,
	"gold": 0,
	"amethyst": 0,
	"diamond": 0
}

const BASE_ORE_PRICES = {
	"stone": 5,
	"coal": 15,
	"tin": 25,
	"iron": 45,
	"silver": 85,
	"gold": 160,
	"amethyst": 300,
	"diamond": 650
}

const PICKAXE_TIERS = {
	1: {
		"name": "Beliung Kayu",
		"power": 1,
		"cost_coins": 0,
		"cost_ore": "",
		"cost_ore_count": 0,
		"icon": "res://assets/images/hud/pickaxe_wood.png",
		"desc": "Beliung kayu pemula standar. Kekuatan Tambang: 1."
	},
	2: {
		"name": "Beliung Batu",
		"power": 2,
		"cost_coins": 50,
		"cost_ore": "stone",
		"cost_ore_count": 8,
		"icon": "res://assets/images/hud/pickaxe_stone.png",
		"desc": "Mata batu yang diasah tajam. Kekuatan Tambang: 2."
	},
	3: {
		"name": "Beliung Besi",
		"power": 3,
		"cost_coins": 150,
		"cost_ore": "iron",
		"cost_ore_count": 6,
		"icon": "res://assets/images/hud/pickaxe_iron.png",
		"desc": "Besi tempa kokoh dan tangguh. Kekuatan Tambang: 3."
	},
	4: {
		"name": "Beliung Emas",
		"power": 4,
		"cost_coins": 350,
		"cost_ore": "gold",
		"cost_ore_count": 5,
		"icon": "res://assets/images/hud/pickaxe_gold.png",
		"desc": "Beliung berlapis emas berkilau. Kekuatan Tambang: 4."
	},
	5: {
		"name": "Beliung Berlian",
		"power": 5,
		"cost_coins": 800,
		"cost_ore": "diamond",
		"cost_ore_count": 3,
		"icon": "res://assets/images/hud/pickaxe_diamond.png",
		"desc": "Beliung Berlian Legendaris! Kekuatan maksimal (Kekuatan Tambang: 5)!"
	}
}

func get_ore_display_name(ore: String) -> String:
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

# Timer untuk quest yang tidak diterima
const UNACCEPTED_ROTATION_TIME: float = 300.0 # 5 menit

# Registri NPC dari tingkat kesukaan (0.0 to 7.0 hati) and item spesialnya
var npcs: Dictionary = {
	"mayor": {
		"id": "mayor",
		"name": "Walikota Archibald",
		"title": "Walikota Kota",
		"role": "Gubernur Kota & Pemimpin Wilayah",
		"is_mayor": true,
		"is_citizen": false,
		"allow_gift": true,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Segel Kehormatan Kerajaan",
		"special_item_desc": "Mendapatkan bonus tunjangan walikota (+1000 Koin) & perlindungan istimewa!",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniNobleMan.png",
		"unaccepted_timer": 300.0,
		"current_quest": null
	},
	"blacksmith": {
		"id": "blacksmith",
		"name": "Blacksmith Ivan",
		"title": "Pandai Besi Desa",
		"role": "Ahli Tempa Beliung & Peleburan Bijih",
		"is_mayor": false,
		"is_citizen": false,
		"allow_gift": false,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Batu Asah Titanium",
		"special_item_desc": "Mempertajam beliung untuk menambah +1 ekstra kekuatan!",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniWorker.png",
		"unaccepted_timer": 300.0,
		"current_quest": null
	},
	"elder": {
		"id": "elder",
		"name": "Elder Pete",
		"title": "Cendekiawan Goa",
		"role": "Arkeolog & Peneliti Sejarah Goa",
		"is_mayor": false,
		"is_citizen": false,
		"allow_gift": true,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Kompas Kuno Goa",
		"special_item_desc": "Menggandakan peluang kemunculan permata langka di goa!",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniOldMan.png",
		"unaccepted_timer": 300.0,
		"current_quest": null
	},
	"herbalist": {
		"id": "herbalist",
		"name": "Nenek Martha",
		"title": "Tabib Herbal Desa",
		"role": "Ahli Ramuan & Penyembuh",
		"is_mayor": false,
		"is_citizen": false,
		"allow_gift": true,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Jimat Hati Abadi",
		"special_item_desc": "Meningkatkan Darah Maksimal secara permanen dari 5 menjadi 6 Hati!",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniOldWoman.png",
		"unaccepted_timer": 300.0,
		"current_quest": null
	},
	"farmer": {
		"id": "farmer",
		"name": "Farmer Tom",
		"title": "Petani Desa",
		"role": "Pengelola Peternakan & Kebun",
		"is_mayor": false,
		"is_citizen": false,
		"allow_gift": true,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Semanggi Keberuntungan",
		"special_item_desc": "Melindungi streak dari 1 kali jawaban salah dalam kuis matematika!",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniPeasant.png",
		"unaccepted_timer": 300.0,
		"current_quest": null
	},
	"miner_bob": {
		"id": "miner_bob",
		"name": "Miner Bob",
		"title": "Penambang Veteran",
		"role": "Pemandu Goa & Penjelajah Abyss",
		"is_mayor": false,
		"is_citizen": false,
		"allow_gift": true,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Lentera Tambang Bob",
		"special_item_desc": "Menambah +3 detik waktu berpikir ekstra pada kuis matematika!",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniWorker.png",
		"unaccepted_timer": 300.0,
		"current_quest": null
	},
	"villager_lily": {
		"id": "villager_lily",
		"name": "Lily",
		"title": "Gadis Bunga Desa",
		"role": "Penduduk Ramah Desa Penambang",
		"is_mayor": false,
		"is_citizen": true,
		"allow_gift": true,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Karangan Bunga Segar",
		"special_item_desc": "Bunga harum yang membuat warga desa tersenyum ramah.",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniVillagerWoman.png",
		"unaccepted_timer": 0.0,
		"current_quest": null
	},
	"villager_lucas": {
		"id": "villager_lucas",
		"name": "Lucas",
		"title": "Warga Desa",
		"role": "Penduduk Muda Desa Penambang",
		"is_mayor": false,
		"is_citizen": true,
		"allow_gift": true,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Koin Keberuntungan",
		"special_item_desc": "Koin tua penambah semangat penambang muda.",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniVillagerMan.png",
		"unaccepted_timer": 0.0,
		"current_quest": null
	},
	"villager_evelyn": {
		"id": "villager_evelyn",
		"name": "Nyonya Evelyn",
		"title": "Bangsawan Tamu",
		"role": "Pengagum Lanskap Pegunungan",
		"is_mayor": false,
		"is_citizen": true,
		"allow_gift": true,
		"favorability": 0.0,
		"special_item_claimed": false,
		"special_item_name": "Bros Berlian Halus",
		"special_item_desc": "Hiasan indah lambang persahabatan.",
		"sprite": "res://assets/images/minifolks/MinifolksVillagers/Outline/MiniNobleWoman.png",
		"unaccepted_timer": 0.0,
		"current_quest": null
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initialize_all_quests()

func _process(delta: float) -> void:
	# Regenerasi buff elixir selama 3 menit
	if regen_buff_timer > 0.0:
		regen_buff_timer = max(0.0, regen_buff_timer - delta)
		regen_tick += delta
		if regen_tick >= 4.0:
			regen_tick = 0.0
			if current_hearts < max_hearts:
				current_hearts = min(max_hearts, current_hearts + 1)
				stats_changed.emit()
	
	var need_emit = false
	for npc_id in npcs.keys():
		var npc_data = npcs[npc_id]
		if npc_data.get("is_citizen", false):
			continue
		var quest = npc_data.get("current_quest")
		if quest == null:
			_generate_quest_for_npc(npc_id)
			need_emit = true
		elif not quest["is_accepted"]:
			# Tidak diterima: perputaran selama 5 menit
			npc_data["unaccepted_timer"] -= delta
			if npc_data["unaccepted_timer"] <= 0.0:
				npc_data["unaccepted_timer"] = UNACCEPTED_ROTATION_TIME
				_generate_quest_for_npc(npc_id)
				need_emit = true
		else:
			# Ketika diterima: limit waktunya baru dihitung mundur
			if quest["time_remaining"] > 0.0:
				quest["time_remaining"] = max(0.0, quest["time_remaining"] - delta)
				
	if need_emit:
		quests_updated.emit()

func _initialize_all_quests() -> void:
	for npc_id in npcs.keys():
		_generate_quest_for_npc(npc_id)

# Bagian progressi dan leveling
func get_xp_required_for_level(lvl: int) -> int:
	return max(40, lvl * 50)

func add_xp(amount: int) -> void:
	player_xp += amount
	var req = get_xp_required_for_level(player_level)
	while player_xp >= req and player_level < 100:
		player_xp -= req
		player_level += 1
		req = get_xp_required_for_level(player_level)
		message_shown.emit("🌟 LEVEL MENINGKAT! Kamu mencapai level " + str(player_level) + "!", 3.0)
	stats_changed.emit()

func set_player_level(lvl: int) -> void:
	player_level = max(1, lvl)
	player_xp = 0
	stats_changed.emit()
	message_shown.emit("⭐ Level player diatur ke " + str(player_level), 2.5)

# Bagian inventori dan ore
func add_ore(ore_name: String, amount: int = 1) -> void:
	var clean_name = ore_name.to_lower().replace("_ore", "").replace(".tres", "").strip_edges()
	if inventory_ores.has(clean_name):
		inventory_ores[clean_name] += amount
	else:
		inventory_ores[clean_name] = amount
	inventory_changed.emit()
	add_xp(5 * amount)

func remove_ore(ore_name: String, amount: int = 1) -> bool:
	var clean_name = ore_name.to_lower().replace("_ore", "").replace(".tres", "").strip_edges()
	if inventory_ores.has(clean_name) and inventory_ores[clean_name] >= amount:
		inventory_ores[clean_name] -= amount
		inventory_changed.emit()
		return true
	return false

func get_ore_count(ore_name: String) -> int:
	var clean_name = ore_name.to_lower().replace("_ore", "").replace(".tres", "").strip_edges()
	return inventory_ores.get(clean_name, 0)

func get_ore_price(ore_name: String) -> int:
	var clean_name = ore_name.to_lower().replace("_ore", "").replace(".tres", "").strip_edges()
	var base = BASE_ORE_PRICES.get(clean_name, 5)
	# Ketika memiliki item spesial: "Golden Merchant Ring" memberikan harga jual ore sebanyak +25%
	if has_special_item("Golden Merchant Ring"):
		base = int(base * 1.25)
	return base

func sell_ore(ore_name: String, count: int = 1) -> int:
	var clean_name = ore_name.to_lower().replace("_ore", "").replace(".tres", "").strip_edges()
	var owned = get_ore_count(clean_name)
	var to_sell = min(owned, count)
	if to_sell > 0:
		var price = get_ore_price(clean_name)
		var earnings = to_sell * price
		inventory_ores[clean_name] -= to_sell
		money += earnings
		inventory_changed.emit()
		stats_changed.emit()
		return earnings
	return 0

func sell_all_ores() -> int:
	var total_earned = 0
	for ore in inventory_ores.keys():
		var count = inventory_ores[ore]
		if count > 0:
			var price = get_ore_price(ore)
			total_earned += count * price
			inventory_ores[ore] = 0
	if total_earned > 0:
		money += total_earned
		inventory_changed.emit()
		stats_changed.emit()
	return total_earned

# Bagian peningkatan beliungnya serta kekuatannya
func get_pickaxe_power() -> int:
	var info = PICKAXE_TIERS.get(pickaxe_tier, PICKAXE_TIERS[1])
	var pwr = info.get("power", 1)
	# Ketika memiliki item spesial: "Titanium Whetstone" menambahkan kekuatan beliung sebanyak +1 kekuatan
	if has_special_item("Titanium Whetstone"):
		pwr += 1
	return pwr

func can_upgrade_pickaxe() -> bool:
	if pickaxe_tier >= 5:
		return false
	var next_tier = pickaxe_tier + 1
	var info = PICKAXE_TIERS[next_tier]
	var coin_ok = money >= info["cost_coins"]
	var ore_ok = true
	if info["cost_ore"] != "":
		ore_ok = get_ore_count(info["cost_ore"]) >= info["cost_ore_count"]
	return coin_ok and ore_ok

func upgrade_pickaxe() -> bool:
	if not can_upgrade_pickaxe():
		return false
	var next_tier = pickaxe_tier + 1
	var info = PICKAXE_TIERS[next_tier]
	money -= info["cost_coins"]
	if info["cost_ore"] != "":
		remove_ore(info["cost_ore"], info["cost_ore_count"])
	pickaxe_tier = next_tier
	add_xp(50 * pickaxe_tier)
	stats_changed.emit()
	inventory_changed.emit()
	return true

# Bagian darahnya dan ketika pingsan (Darahnya <= 0)
func take_damage(amount: int = 1) -> bool:
	current_hearts = max(0, current_hearts - amount)
	streak = 0
	stats_changed.emit()
	
	if current_hearts <= 0:
		var penalty = max(15, int(money * 0.20))
		money = max(0, money - penalty)
		current_hearts = max_hearts
		stats_changed.emit()
		player_fainted.emit(penalty)
		return true # Mengembalikan state pingsan
	return false

func heal_hearts(amount: int) -> void:
	current_hearts = min(max_hearts, current_hearts + amount)
	stats_changed.emit()

func heal_full() -> void:
	current_hearts = max_hearts
	stats_changed.emit()

func apply_elixir() -> void:
	current_hearts = max_hearts
	regen_buff_timer = 180.0 # Durasi selama 3 menit (Elixirnya)
	regen_tick = 0.0
	stats_changed.emit()

# Menangani ketika menjual ore 1 per 1
func sell_single_ore(ore: String, count: int = 1) -> Dictionary:
	var cur = get_ore_count(ore)
	if cur < count or count <= 0:
		return {"success": false, "earned": 0, "message": "Bijih tidak mencukupi."}
	var base_price = get_ore_price(ore)
	var bonus = 1.0
	if has_special_item("Golden Merchant Ring") or has_special_item("Cincin Emas Pedagang"):
		bonus = 1.25
	var earned = int(base_price * count * bonus)
	remove_ore(ore, count)
	money += earned
	stats_changed.emit()
	inventory_changed.emit()
	return {"success": true, "earned": earned, "remaining": get_ore_count(ore)}

# Menangani ketika menjual seluruh ore langsung
func sell_all_of_type(ore: String) -> Dictionary:
	var cur = get_ore_count(ore)
	if cur <= 0:
		return {"success": false, "earned": 0, "message": "Kamu tidak memiliki bijih ini."}
	return sell_single_ore(ore, cur)

# Menangani ketika memiliki item spesial
func has_special_item(item_name: String) -> bool:
	if unlocked_special_items.has(item_name):
		return true
	var aliases = {
		"Golden Merchant Ring": "Cincin Emas Pedagang",
		"Heart Amulet": "Jimat Hati Abadi",
		"Royal Seal of Honor": "Segel Kehormatan Kerajaan",
		"Titanium Whetstone": "Batu Asah Titanium",
		"Ancient Cave Compass": "Kompas Kuno Goa",
		"Lucky Four-Leaf Clover": "Semanggi Keberuntungan",
		"Bob's Mining Lantern": "Lentera Tambang Bob"
	}
	if aliases.has(item_name) and unlocked_special_items.has(aliases[item_name]):
		return true
	for k in aliases.keys():
		if aliases[k] == item_name and unlocked_special_items.has(k):
			return true
	return false

# Tingkat kesukaan dan engine untuk pemberian questnya
func _generate_quest_for_npc(npc_id: String) -> void:
	if not npcs.has(npc_id): return
	var npc = npcs[npc_id]
	if npc.get("is_citizen", false): return
	var is_mayor = npc["is_mayor"]
	
	var quest_dict = {}
	if is_mayor:
		# Randomisasi quest dari mayor untuk quest tingkat epic dan legendary!
		var roll = randf()
		if roll < 0.6:
			# Epic Questnya
			quest_dict = {
				"id": "quest_mayor_epic_" + str(randi() % 10000),
				"title": "👑 Kas Kota: Batangan Emas",
				"npc_id": "mayor",
				"difficulty": "Epic",
				"desc": "Kas kota membutuhkan emas murni untuk renovasi kota! Kumpulkan 3 Bijih Emas.",
				"target_ore": "gold",
				"target_count": 3,
				"reward_coins": 550,
				"reward_xp": 200,
				"time_limit": 3600.0, # 1 jam
				"time_remaining": 3600.0,
				"is_accepted": false,
				"is_completed": false
			}
		else:
			# Legendary Questnya
			quest_dict = {
				"id": "quest_mayor_leg_" + str(randi() % 10000),
				"title": "💎 Permata Abadi Abyss",
				"npc_id": "mayor",
				"difficulty": "Legendary",
				"desc": "Temukan Berlian langka dari goa terdalam, kedalaman Level 5 (Bioma Abyss) untuk item spesial tongkat kehormatan Walikota!",
				"target_ore": "diamond",
				"target_count": 1,
				"reward_coins": 1500,
				"reward_xp": 600,
				"time_limit": 4500.0, # 1 jam 15 menit
				"time_remaining": 4500.0,
				"is_accepted": false,
				"is_completed": false
			}
	else:
		# Quest untuk npc normalnya: dari quest umum (Common) sampai langkah (Rare) 
		var diff_roll = randi_range(1, 3)
		match diff_roll:
			1: # Umum
				var targets = [
					{"ore": "stone", "count": 4, "title": "Batu Pondasi", "desc": "Warga membutuhkan 4 batu kokoh untuk perbaikan jalan desa.", "coins": 45, "xp": 25, "time": 3600.0},
					{"ore": "coal", "count": 3, "title": "Batu Bara Penghangat", "desc": "Bawa 3 bongkah batu bara untuk menyalakan tungku perapian warga.", "coins": 60, "xp": 30, "time": 3600.0}
				]
				var t = targets[randi() % targets.size()]
				quest_dict = {
					"id": "quest_" + npc_id + "_" + str(randi() % 10000),
					"title": "⛏️ " + t["title"],
					"npc_id": npc_id,
					"difficulty": "Common",
					"desc": t["desc"],
					"target_ore": t["ore"],
					"target_count": t["count"],
					"reward_coins": t["coins"],
					"reward_xp": t["xp"],
					"time_limit": t["time"],
					"time_remaining": t["time"],
					"is_accepted": false,
					"is_completed": false
				}
			2: # Tidak umum
				var targets = [
					{"ore": "tin", "count": 3, "title": "Peralatan Masak Timah", "desc": "Kumpulkan 3 bijih timah untuk membuat peralatan dapur desa.", "coins": 100, "xp": 50, "time": 3000.0},
					{"ore": "iron", "count": 2, "title": "Batangan Besi Kokoh", "desc": "Kumpulkan 2 bijih besi dari kedalaman Level 2 untuk ditempa.", "coins": 120, "xp": 60, "time": 3000.0}
				]
				var t = targets[randi() % targets.size()]
				quest_dict = {
					"id": "quest_" + npc_id + "_" + str(randi() % 10000),
					"title": "⚒️ " + t["title"],
					"npc_id": npc_id,
					"difficulty": "Uncommon",
					"desc": t["desc"],
					"target_ore": t["ore"],
					"target_count": t["count"],
					"reward_coins": t["coins"],
					"reward_xp": t["xp"],
					"time_limit": t["time"],
					"time_remaining": t["time"],
					"is_accepted": false,
					"is_completed": false
				}
			3: # Langka
				var targets = [
					{"ore": "silver", "count": 2, "title": "Relik Perak Berkilau", "desc": "Bawa 2 bijih perak berkilau dari goa kedalaman Level 3.", "coins": 220, "xp": 100, "time": 2400.0},
					{"ore": "gold", "count": 1, "title": "Koin Emas Murni", "desc": "Hadiah dari goa dalam! Kumpulkan 1 bijih emas berharga.", "coins": 260, "xp": 120, "time": 2400.0}
				]
				var t = targets[randi() % targets.size()]
				quest_dict = {
					"id": "quest_" + npc_id + "_" + str(randi() % 10000),
					"title": "✨ " + t["title"],
					"npc_id": npc_id,
					"difficulty": "Rare",
					"desc": t["desc"],
					"target_ore": t["ore"],
					"target_count": t["count"],
					"reward_coins": t["coins"],
					"reward_xp": t["xp"],
					"time_limit": t["time"],
					"time_remaining": t["time"],
					"is_accepted": false,
					"is_completed": false
				}
				
	npc["current_quest"] = quest_dict
	npc["unaccepted_timer"] = UNACCEPTED_ROTATION_TIME

func get_npc_quest(npc_id: String) -> Dictionary:
	if npcs.has(npc_id) and npcs[npc_id].get("current_quest") != null:
		return npcs[npc_id]["current_quest"]
	return {}

func accept_quest(npc_id: String) -> bool:
	if not npcs.has(npc_id): return false
	if npc_id == "mayor" and player_level < 50:
		message_shown.emit("👑 Walikota: Capai Penambang Level 50 untuk membuka Misi Kerajaan!", 2.5)
		return false
	var npc = npcs[npc_id]
	var quest = npc.get("current_quest")
	if quest and not quest["is_accepted"]:
		quest["is_accepted"] = true
		quests_updated.emit()
		message_shown.emit("📋 Menerima Quest: " + quest["title"] + "!", 2.5)
		return true
	return false

func can_complete_quest(npc_id: String) -> bool:
	if not npcs.has(npc_id): return false
	var npc = npcs[npc_id]
	var quest = npc.get("current_quest")
	if quest and quest["is_accepted"] and not quest["is_completed"]:
		var req_ore = quest.get("target_ore", "")
		var req_count = quest.get("target_count", 0)
		if req_ore != "" and get_ore_count(req_ore) >= req_count:
			return true
	return false

# Menangani quest yang sudah selesai dan menghitung tinkat kesukaannya (+1.0 hati jika tepat waktu, dan +0.5 hati jika telat)
func complete_quest(npc_id: String) -> Dictionary:
	if not can_complete_quest(npc_id):
		return {"success": false, "reason": "Requirements not met"}
		
	var npc = npcs[npc_id]
	var quest = npc["current_quest"]
	
	# Mengurangi item berdasarkan yang diminta
	remove_ore(quest["target_ore"], quest["target_count"])
	
	# Menangani tingkat kesukaannya: 1.0 kalau tepat waktu, 0.5 kalau terlambat
	var was_on_time = quest["time_remaining"] > 0.0
	var heart_award = 1.0 if was_on_time else 0.5
	
	# Memberikan hadiahnya sesuai perjanjian dari questnya
	money += quest["reward_coins"]
	add_xp(quest["reward_xp"])
	npc["favorability"] = clampf(npc["favorability"] + heart_award, 0.0, 7.0)
	
	var special_unlocked = false
	if npc["favorability"] >= 7.0 and not npc["special_item_claimed"]:
		npc["special_item_claimed"] = true
		unlocked_special_items.append(npc["special_item_name"])
		special_unlocked = true
		
		# Menerapkan pasif unik dan buff langsung
		if npc["special_item_name"] in ["Heart Amulet", "Jimat Hati Abadi"]:
			max_hearts = 6
			current_hearts = 6
		elif npc["special_item_name"] in ["Royal Seal of Honor", "Segel Kehormatan Kerajaan"]:
			money += 1000
			
		special_item_unlocked.emit(npc["name"], npc["special_item_name"], npc["special_item_desc"])
	
	var result = {
		"success": true,
		"title": quest["title"],
		"coins": quest["reward_coins"],
		"xp": quest["reward_xp"],
		"heart_award": heart_award,
		"new_favorability": npc["favorability"],
		"special_unlocked": special_unlocked,
		"special_name": npc["special_item_name"] if special_unlocked else ""
	}
	
	# Merotasikan quest untuk quest baru lagi
	_generate_quest_for_npc(npc_id)
	quests_updated.emit()
	stats_changed.emit()
	return result

# ----------------- MAYOR INTERACTION -----------------
func attempt_mayor_quest_claim() -> Dictionary:
	return {
		"jailed": false,
		"level": player_level,
		"allowed": player_level >= 50
	}

# Sistem yang menangani tingkat kesukaan dan pemberian hadiah
const NPC_GIFT_PREFERENCES = {
	"mayor": {
		"loved": ["gold", "diamond", "coins"],
		"liked": ["silver", "amethyst"],
		"disliked": ["stone", "coal"]
	},
	"villager_lily": {
		"loved": ["amethyst", "diamond", "coins"],
		"liked": ["tin", "silver"],
		"disliked": ["stone", "coal"]
	},
	"villager_lucas": {
		"loved": ["silver", "gold"],
		"liked": ["tin", "iron", "coal"],
		"disliked": ["stone"]
	},
	"villager_evelyn": {
		"loved": ["diamond", "gold", "coins"],
		"liked": ["silver", "amethyst"],
		"disliked": ["stone", "coal", "tin"]
	},
	"blacksmith": {
		"loved": ["iron", "coal", "gold"],
		"liked": ["tin", "silver", "stone"],
		"disliked": ["coins", "amethyst"]
	},
	"elder": {
		"loved": ["silver", "tin", "stone"],
		"liked": ["coal", "iron", "amethyst"],
		"disliked": ["diamond"]
	},
	"herbalist": {
		"loved": ["amethyst", "coins"],
		"liked": ["tin", "silver", "gold"],
		"disliked": ["coal", "iron"]
	},
	"farmer": {
		"loved": ["tin", "coal", "coins"],
		"liked": ["stone", "iron"],
		"disliked": ["diamond", "silver"]
	},
	"miner_bob": {
		"loved": ["coal", "iron", "diamond"],
		"liked": ["tin", "silver", "gold", "stone"],
		"disliked": ["coins"]
	}
}

func give_gift_to_npc(npc_id: String, gift_type: String, amount: int = 1) -> Dictionary:
	if not npcs.has(npc_id):
		return {"success": false, "message": "NPC tidak ditemukan."}
		
	var npc = npcs[npc_id]
	if npc.get("allow_gift") == false:
		return {"success": false, "message": "%s tidak menerima hadiah karena fokus menambang & melebur bijih!" % npc["name"]}
	var npc_name = npc["name"]
	
	# Berfungsi untuk mengecek harga dan pengurangan uangnya
	if gift_type == "coins":
		if money < amount:
			return {"success": false, "message": "Koinmu tidak mencukupi (%d Koin dibutuhkan)." % amount}
		money -= amount
	else:
		if get_ore_count(gift_type) < amount:
			return {"success": false, "message": "Kamu tidak memiliki bijih tersebut."}
		remove_ore(gift_type, amount)
		
	var prefs = NPC_GIFT_PREFERENCES.get(npc_id, {"loved": [], "liked": [], "disliked": []})
	var mood_roll = randf()
	var reaction = "neutral"
	var heart_delta = 0.2
	var msg = ""
	
	var is_loved = gift_type in prefs.get("loved", [])
	var is_liked = gift_type in prefs.get("liked", [])
	var is_disliked = gift_type in prefs.get("disliked", [])
	
	if is_loved:
		reaction = "neutral" if mood_roll < 0.10 else "loved"
	elif is_disliked:
		reaction = "neutral" if mood_roll < 0.10 else "disliked"
	elif is_liked:
		if mood_roll < 0.20:
			reaction = "loved"
		elif mood_roll < 0.35:
			reaction = "neutral"
		else:
			reaction = "liked"
	else:
		if mood_roll < 0.30:
			reaction = "liked"
		elif mood_roll < 0.65:
			reaction = "neutral"
		else:
			reaction = "disliked"
		
	var gift_display_name = ("%d Koin" % amount) if gift_type == "coins" else _translate_ore_gift(gift_type)
	
	match reaction:
		"loved":
			heart_delta = randf_range(0.6, 1.0)
			var loved_msgs = [
				"Wah! Luar biasa! %s sangat menyukai %s yang kamu berikan! (+%.1f Hati ❤️)" % [npc_name, gift_display_name, heart_delta],
				"'Ini benar-benar yang kucari! Terima kasih banyak, kawan!' (+%.1f Hati ❤️)" % heart_delta,
				"'Kamu sangat mengerti apa yang kubutuhkan! Senang berteman denganmu!' (+%.1f Hati ❤️)" % heart_delta
			]
			msg = loved_msgs[randi() % loved_msgs.size()]
		"liked":
			heart_delta = randf_range(0.3, 0.5)
			var liked_msgs = [
				"%s tersenyum menerima %s. 'Terima kasih, ini sangat berguna!' (+%.1f Hati ❤️)" % [npc_name, gift_display_name, heart_delta],
				"'Makasi, hadiah yang bagus! Aku pasti menyimpannya dengan baik.' (+%.1f Hati ❤️)" % heart_delta
			]
			msg = liked_msgs[randi() % liked_msgs.size()]
		"neutral":
			heart_delta = 0.1
			msg = "%s menerima %s. 'Terima kasih atas pemberianmu.' (+0.1 Hati)" % [npc_name, gift_display_name]
		"disliked":
			heart_delta = -0.1 if npc["favorability"] > 0.5 else 0.0
			var dis_msgs = [
				"%s tampak ragu... 'Hmm, sebenarnya ini bukan yang kucari...' (Tidak suka)" % npc_name,
				"'Waduh, bukan ini yang ku cari. Tapi makasi atas bantuanmu.' (Tidak cocok)",
				"'Kurasa ini kurang berguna untukku saat ini...' (Bukan yang diinginkan)"
			]
			msg = dis_msgs[randi() % dis_msgs.size()]
			
	npc["favorability"] = clampf(npc["favorability"] + heart_delta, 0.0, 7.0)
	
	var special_unlocked = false
	if npc["favorability"] >= 7.0 and not npc["special_item_claimed"]:
		npc["special_item_claimed"] = true
		unlocked_special_items.append(npc["special_item_name"])
		special_unlocked = true
		if npc["special_item_name"] in ["Heart Amulet", "Jimat Hati Abadi"]:
			max_hearts = 6
			current_hearts = 6
		elif npc["special_item_name"] in ["Royal Seal of Honor", "Segel Kehormatan Kerajaan"]:
			money += 1000
		special_item_unlocked.emit(npc["name"], npc["special_item_name"], npc["special_item_desc"])
		
	stats_changed.emit()
	quests_updated.emit()
	
	return {
		"success": true,
		"reaction": reaction,
		"heart_delta": heart_delta,
		"new_favorability": npc["favorability"],
		"message": msg,
		"special_unlocked": special_unlocked,
		"special_name": npc["special_item_name"] if special_unlocked else ""
	}

func _translate_ore_gift(ore: String) -> String:
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

# Menangani perpindahan scenenya
var spawn_at_ladder: bool = false

func go_to_town(from_mine: bool = false) -> void:
	if from_mine:
		spawn_at_ladder = true
	current_depth = 0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/town/town.tscn")

func go_to_mine_lobby(_from_mine: bool = false) -> void:
	# Akan dilewati sesuai keinginan player: langsung menuju tambang lantai 1
	go_to_mine_level(1)

func go_to_mine_level(depth: int) -> void:
	current_depth = clamp(depth, 1, 5)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			var mode = DisplayServer.window_get_mode()
			if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
