extends Node
## ImageRegistry — 인물 초상화 / 배경 / CG 이미지 중앙 관리
##
## 이벤트 JSON은 ID만 참조한다 ("portrait": "jiyeon_normal").
## 실제 파일이 없으면 빈 문자열을 반환 → UI에서 플레이스홀더(색상 박스 + 이름)로 대체.
## 이렇게 하면 이미지가 한 장도 없어도 게임이 정상 동작한다.

# ── 인물 초상화 ────────────────────────────────────────────────
# 경로 규칙: assets/characters/ 플랫 구조 (Codex 생성 파일과 일치)
const PORTRAITS = {
	# 주인공 (김민준, 33세) — player_* 일부는 get_portrait()에서 직업/상태 기반으로 동적 선택
	"player_normal":      "res://assets/characters/main_character_neutral_goshiwon.png",
	"player_tired":       "res://assets/characters/main_character_tired.png",
	"player_determined":  "res://assets/characters/main_character_determined.png",
	"player_happy":       "res://assets/characters/main_character_happy.png",
	"player_shocked":     "res://assets/characters/main_character_shocked.png",
	"player_sad":         "res://assets/characters/main_character_tired.png",
	"player_suit":        "res://assets/characters/main_character_corporate.png",
	"player_hollow":      "res://assets/characters/main_character_50s.png",

	# 김다은 (연인)
	"daeun_normal":       "res://assets/characters/npc_romantic_interest.png",
	"daeun_smile":        "res://assets/characters/npc_daeun_smile.png",
	"daeun_sad":          "res://assets/characters/npc_daeun_sad.png",

	# 임상철 (인맥 브로커)
	"sangchul_normal":    "res://assets/characters/npc_boss.png",
	"sangchul_serious":   "res://assets/characters/npc_sangchul_serious.png",

	# 강현수 (고시원 옆방 공시생 후배)
	"hyunsu":             "res://assets/characters/npc_close_friend.png",
	"hyunsu_normal":      "res://assets/characters/npc_close_friend.png",

	# 한지연 (투자·로맨스) — legacy file names, regenerate as transparent portraits
	"jiyeon_normal":      "res://assets/characters/npc_mentor.png",
	"jiyeon_warm":        "res://assets/characters/npc_jiyeon_warm.png",
	"jiyeon_cold":        "res://assets/characters/npc_jiyeon_cold.png",

	# 조연
	"boss":               "res://assets/characters/npc_team_lead.png",
	"goshiwon_owner":     "res://assets/characters/npc_goshiwon_owner.png",
	"mother":             "res://assets/characters/npc_mother.png",
	"father_normal":      "res://assets/characters/npc_father.png",
	"father_proud":       "res://assets/characters/npc_father.png",
	"father_weak":        "res://assets/characters/npc_father_weak.png",
	"jaehyuk_charisma":   "res://assets/characters/npc_jaehyuk.png",
	"jaehyuk_friendly":   "res://assets/characters/npc_jaehyuk.png",
	"jaehyuk_shadow":     "res://assets/characters/npc_jaehyuk_shadow.png",
	"jaehyuk_cornered":   "res://assets/characters/npc_jaehyuk.png",
	"seongjun":           "res://assets/characters/npc_seongjun.png",

	# 경마장 정보상
	"tip_seller":         "res://assets/characters/npc_tip_seller.png",
}

const PLAYER_UNEMPLOYED = "res://assets/characters/main_character_unemployed.png"
const PLAYER_PART_TIME = "res://assets/characters/main_character_part_time.png"
const PLAYER_OFFICE = "res://assets/characters/main_character_office.png"
const PLAYER_CORPORATE = "res://assets/characters/main_character_corporate.png"
const PLAYER_TIRED = "res://assets/characters/main_character_tired.png"
const PLAYER_HAPPY = "res://assets/characters/main_character_happy.png"
const PLAYER_SHOCKED = "res://assets/characters/main_character_shocked.png"
const PLAYER_HOLLOW = "res://assets/characters/main_character_50s.png"

# ── 인물 표시 정보 (플레이스홀더용 — 이름 + 테마색) ──────────────
const PERSON_INFO = {
	"player":   {"name": "{name}",       "color": "#5b9cf6"},
	"jiyeon":   {"name": "한지연",        "color": "#e8a0c0"},
	"daeun":    {"name": "김다은",        "color": "#7ec8a0"},
	"jaehyuk":  {"name": "최재혁",        "color": "#d08a4a"},
	"father":   {"name": "아버지",        "color": "#9a8a6a"},
	"sangchul": {"name": "임상철",        "color": "#8a8aa0"},
	"goshiwon_owner": {"name": "고시원 원장", "color": "#a0907a"},
	"hyunsu":   {"name": "현수",          "color": "#7a8a9a"},
	"seongjun": {"name": "박성준",        "color": "#6a9ab0"},
	"mother":   {"name": "어머니",        "color": "#b09a9a"},
	"boss":     {"name": "팀장",          "color": "#9a6a6a"},
}

# ── 배경 이미지 ────────────────────────────────────────────────
const BACKGROUNDS = {
	# 고시원/생활권
	"goshiwon":          "res://assets/backgrounds/goshiwon_room.png",
	"goshiwon_room":     "res://assets/backgrounds/goshiwon_room.png",
	"goshiwon_hallway":  "res://assets/backgrounds/goshiwon_hallway.png",
	# 서울 일상
	"convenience_night": "res://assets/backgrounds/convenience_store_night.png",
	"cafe":              "res://assets/backgrounds/cafe_seoul.png",
	"subway":            "res://assets/backgrounds/seoul_subway.png",
	"street_rainy":      "res://assets/backgrounds/seoul_rainy_street.png",
	"pojangmacha":       "res://assets/backgrounds/pojangmacha.png",
	"rooftop_night":     "res://assets/backgrounds/rooftop_night.png",
	# 직장/사업
	"office":            "res://assets/backgrounds/office_desk.png",
	"realestate_office": "res://assets/backgrounds/realestate_office.png",
	"meeting":           "res://assets/backgrounds/investment_meeting.png",
	# 강남
	"gangnam_day":       "res://assets/backgrounds/gangnam_day.png",
	"gangnam_night":     "res://assets/backgrounds/gangnam_night_street.png",
	"gangnam_apartment": "res://assets/backgrounds/gangnam_apartment.png",
	# 특수
	"hospital":          "res://assets/backgrounds/hospital_corridor.png",
	"hospital_clinic":   "res://assets/backgrounds/hospital_clinic.png",
	# Canon-safe Changwon father-home background regenerated on 2026-06-12.
	"dad_house":         "res://assets/backgrounds/family_living_room.png",
	"ktx_window":        "res://assets/backgrounds/hometown_train_station.png",
	"burnout":           "res://assets/backgrounds/burnout_hospital_room.png",
	"penthouse":         "res://assets/backgrounds/penthouse_view.png",
	"investment":        "res://assets/backgrounds/investment_phone.png",
	"investment_phone":  "res://assets/backgrounds/investment_phone.png",
	# Legacy key kept for old event JSON. General investing must stay phone/desk-scale;
	# multi-monitor rooms are reserved for scalping/pro-level scenes.
	"trading":           "res://assets/backgrounds/investment_phone.png",
	"trading_room":      "res://assets/backgrounds/trading_screen_night.png",
	"pc_bang":           "res://assets/backgrounds/pc_bang_interior.png",
	# Canonical 4am variant generated from goshiwon_room.png; same room layout.
	"late_night":        "res://assets/backgrounds/late_night_room.png",
	# 신규 (2026-06-12)
	"library":           "res://assets/backgrounds/library.png",
	"restaurant":        "res://assets/backgrounds/restaurant_korean.png",
	"street":            "res://assets/backgrounds/street_seoul_day.png",
	"apartment":         "res://assets/backgrounds/oneroom_apartment.png",
	"convenience_store": "res://assets/backgrounds/convenience_store_night.png",
	# 미니게임 전용
	"racetrack_betting": "res://assets/backgrounds/racetrack_betting_hall.png",
	"racetrack_track":   "res://assets/backgrounds/racetrack_track_view.png",
	"holdem_club":       "res://assets/backgrounds/holdem_club_interior.png",
	"scalping_room":     "res://assets/backgrounds/scalping_trading_room.png",
	"aruba_delivery":    "res://assets/backgrounds/aruba_delivery_street.png",
	"gangnam_station":   "res://assets/backgrounds/gangnam_station_exit.png",
}

const FALLBACK_BG = "res://assets/backgrounds/goshiwon_room.png"

# ── CG (감정적 클라이맥스 전체화면) ────────────────────────────
const CG = {
	"cg_start":          "res://assets/cg/start.png",
	"cg_jiyeon_crash":   "res://assets/cg/jiyeon_crash.png",
	"cg_jaehyuk_reveal": "res://assets/cg/jaehyuk_reveal.png",
	"cg_ending_father":  "res://assets/cg/ending_father.png",
}

# ── 조회 API ──────────────────────────────────────────────────

## 초상화 경로 반환. 파일 없으면 "" (UI가 플레이스홀더 처리)
func get_portrait(id: String) -> String:
	var dynamic_path = _get_dynamic_player_portrait(id)
	if dynamic_path != "":
		if ResourceLoader.exists(dynamic_path):
			return dynamic_path
		return ""
	var path = str(PORTRAITS.get(id, ""))
	if path != "" and ResourceLoader.exists(path):
		return path
	return ""

func get_player_portrait_for_state(state: String = "normal") -> String:
	match state:
		"shocked":
			return PLAYER_SHOCKED
		"happy":
			return PLAYER_HAPPY
		"tired", "sad":
			return PLAYER_TIRED
		"hollow":
			return PLAYER_HOLLOW
		"normal", "determined", "suit":
			return get_player_context_portrait()
		_:
			return get_player_context_portrait()

func get_player_context_portrait() -> String:
	if GameState.age >= 50:
		return PLAYER_HOLLOW

	var job: Dictionary = GameState.current_job
	var total_asset := float(GameState.get_total_asset_value())
	if job.is_empty():
		if GameState.housing in ["apartment", "gangnam"] or total_asset >= 100_000_000.0:
			return PLAYER_CORPORATE
		return PLAYER_UNEMPLOYED

	var job_id := str(job.get("id", ""))
	var category := str(job.get("category", ""))
	var tier := int(job.get("tier", 1))

	if category == "survival" or job_id in ["job_01", "job_02"]:
		return PLAYER_PART_TIME
	if job_id == "job_08" or category in ["finance", "sales"] or tier >= 3:
		return PLAYER_CORPORATE
	return PLAYER_OFFICE

func _get_dynamic_player_portrait(id: String) -> String:
	match id:
		"player_normal":
			return get_player_portrait_for_state("normal")
		"player_determined":
			return get_player_portrait_for_state("determined")
		"player_suit":
			return get_player_portrait_for_state("suit")
		"player_tired", "player_sad":
			return get_player_portrait_for_state("tired")
		"player_happy":
			return get_player_portrait_for_state("happy")
		"player_shocked":
			return get_player_portrait_for_state("shocked")
		"player_hollow":
			return get_player_portrait_for_state("hollow")
		_:
			return ""

## 배경 경로 반환. 파일 없으면 기본 배경으로 폴백
func get_background(id: String) -> String:
	var path = str(BACKGROUNDS.get(id, ""))
	if path != "" and ResourceLoader.exists(path):
		return path
	if ResourceLoader.exists(FALLBACK_BG):
		return FALLBACK_BG
	return ""

## 명시 background가 없는 이벤트의 배경을 태그/카테고리로 추론.
## (MainGame._get_bg_for_event와 같은 규칙 — StoryMode에서 빈 배경 방지)
func infer_background_id(ev: Dictionary, housing: String = "gosiwon") -> String:
	var tags: Array = ev.get("tags", [])
	var category := str(ev.get("category", ""))
	if "hospital" in tags or category == "health":
		return "hospital"
	if "gym" in tags or "exercise" in tags:
		return "rooftop_day"
	if "convenience" in tags:
		return "convenience_night"
	if "scalping" in tags:
		return "scalping_room"
	if "investment" in tags or category == "investment" or "finance" in tags:
		return "investment_phone"
	if "job" in tags or "work" in tags or "office" in tags or category == "jobs":
		return "office"
	if "commute" in tags or "subway" in tags:
		return "subway"
	if "social" in tags or "date" in tags or "cafe" in tags \
			or "relationship" in tags or category == "romance":
		return "cafe"
	if "family" in tags or category == "family":
		return "restaurant"
	if "hometown" in tags:
		return "ktx_window"
	if "rooftop" in tags:
		return "rooftop_night"
	if category == "politics":
		return "gangnam_night"
	if category == "gambling" or "gambling" in tags or "crypto" in tags:
		return "investment_phone"
	if "pc_bang" in tags or "gaming" in tags:
		return "pc_bang"
	if "night" in tags or "stress" in tags:
		return "late_night"
	if "gosiwon" in tags:
		return "goshiwon_room"
	# 주거 기반 폴백
	match housing:
		"gangnam":   return "gangnam_apartment"
		"apartment": return "late_night"
		_:           return "goshiwon_room"

## CG 경로 반환. 파일 없으면 "" (UI가 검은 화면 + 텍스트 처리)
func get_cg(id: String) -> String:
	var path = str(CG.get(id, ""))
	if path != "" and ResourceLoader.exists(path):
		return path
	return ""

## 초상화 ID에서 인물 정보(이름/색상) 추출 — 플레이스홀더 렌더용
## "jiyeon_warm" → {"name":"한지연", "color":"#e8a0c0"}
func get_person_info(portrait_id: String) -> Dictionary:
	if portrait_id == "":
		return {}
	# 마지막 _ 기준으로 prefix 추출 (예: "goshiwon_owner" 같은 복합 키 우선 매칭)
	for key in PERSON_INFO:
		if portrait_id == key or portrait_id.begins_with(key + "_"):
			var info = PERSON_INFO[key].duplicate()
			# {name} 치환
			if info.get("name", "") == "{name}":
				info["name"] = GameState.player_name
			return info
	return {}
