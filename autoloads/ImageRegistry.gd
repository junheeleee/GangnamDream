extends Node
## ImageRegistry — 인물 초상화 / 배경 / CG 이미지 중앙 관리
##
## 이벤트 JSON은 ID만 참조한다 ("portrait": "jiyeon_normal").
## 실제 파일이 없으면 빈 문자열을 반환 → UI에서 플레이스홀더(색상 박스 + 이름)로 대체.
## 이렇게 하면 이미지가 한 장도 없어도 게임이 정상 동작한다.

# ── 인물 초상화 ────────────────────────────────────────────────
const PORTRAITS = {
	# 주인공 ({name}, 33세)
	"player_normal":      "res://assets/characters/player/normal.png",
	"player_tired":       "res://assets/characters/player/tired.png",
	"player_determined":  "res://assets/characters/player/determined.png",
	"player_happy":       "res://assets/characters/player/happy.png",
	"player_shocked":     "res://assets/characters/player/shocked.png",
	"player_suit":        "res://assets/characters/player/suit.png",        # 성공 후
	"player_hollow":      "res://assets/characters/player/hollow.png",      # 공허 엔딩

	# 한지연 (31세, 금수저)
	"jiyeon_normal":      "res://assets/characters/jiyeon/normal.png",
	"jiyeon_warm":        "res://assets/characters/jiyeon/warm.png",
	"jiyeon_cold":        "res://assets/characters/jiyeon/cold.png",
	"jiyeon_conflict":    "res://assets/characters/jiyeon/conflict.png",

	# 김다은 (33세, 평범)
	"daeun_normal":       "res://assets/characters/daeun/normal.png",
	"daeun_smile":        "res://assets/characters/daeun/smile.png",
	"daeun_sad":          "res://assets/characters/daeun/sad.png",

	# 최재혁 (34세, 군대 동기·사기꾼)
	"jaehyuk_charisma":   "res://assets/characters/jaehyuk/charisma.png",
	"jaehyuk_friendly":   "res://assets/characters/jaehyuk/friendly.png",
	"jaehyuk_shadow":     "res://assets/characters/jaehyuk/shadow.png",
	"jaehyuk_cornered":   "res://assets/characters/jaehyuk/cornered.png",

	# 아버지 (63세)
	"father_normal":      "res://assets/characters/father/normal.png",
	"father_proud":       "res://assets/characters/father/proud.png",
	"father_weak":        "res://assets/characters/father/weak.png",

	# 임상철 (52세, 멘토)
	"sangchul_normal":    "res://assets/characters/sangchul/normal.png",
	"sangchul_serious":   "res://assets/characters/sangchul/serious.png",

	# 조연
	"goshiwon_owner":     "res://assets/characters/extra/goshiwon_owner.png",
	"hyunsu":             "res://assets/characters/extra/hyunsu.png",
	"seongjun":           "res://assets/characters/extra/seongjun.png",
	"mother":             "res://assets/characters/extra/mother.png",
	"boss":               "res://assets/characters/extra/boss.png",
}

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
	"dad_house":         "res://assets/backgrounds/dad_house.png",
	"ktx_window":        "res://assets/backgrounds/ktx_window.png",
}

const FALLBACK_BG = "res://assets/backgrounds/goshiwon_room.png"

# ── CG (감정적 클라이맥스 전체화면) ────────────────────────────
const CG = {
	"cg_start":          "res://assets/cg/start.png",
	"cg_father_phone":   "res://assets/cg/father_phone.png",
	"cg_jiyeon_crash":   "res://assets/cg/jiyeon_crash.png",
	"cg_jaehyuk_reveal": "res://assets/cg/jaehyuk_reveal.png",
	"cg_crisis":         "res://assets/cg/crisis.png",
	"cg_gangnam_door":   "res://assets/cg/gangnam_door.png",
	"cg_ending_father":  "res://assets/cg/ending_father.png",
}

# ── 조회 API ──────────────────────────────────────────────────

## 초상화 경로 반환. 파일 없으면 "" (UI가 플레이스홀더 처리)
func get_portrait(id: String) -> String:
	var path = str(PORTRAITS.get(id, ""))
	if path != "" and ResourceLoader.exists(path):
		return path
	return ""

## 배경 경로 반환. 파일 없으면 기본 배경으로 폴백
func get_background(id: String) -> String:
	var path = str(BACKGROUNDS.get(id, ""))
	if path != "" and ResourceLoader.exists(path):
		return path
	if ResourceLoader.exists(FALLBACK_BG):
		return FALLBACK_BG
	return ""

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
