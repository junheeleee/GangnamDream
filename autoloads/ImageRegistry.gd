extends Node
## ImageRegistry — 인물 초상화 / 배경 / CG 이미지 중앙 관리
##
## 이벤트 JSON은 ID만 참조한다 ("portrait": "jiyeon_normal").
## 실제 파일이 없으면 빈 문자열을 반환 → UI에서 플레이스홀더(색상 박스 + 이름)로 대체.
## 이렇게 하면 이미지가 한 장도 없어도 게임이 정상 동작한다.

const CAST_VISUAL_YEARS_PATH := "res://content/meta/cast_visual_years.json"

var _cast_visual_years: Dictionary = {}
var _portrait_time_overrides: Dictionary = {}
var _fixed_time_portraits: Dictionary = {}

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
	# 본편은 33~38세다. 배경이 구워진 50대 에필로그 원화 대신 같은 신원의 투명 피로 초상을 쓴다.
	"player_hollow":      "res://assets/characters/main_character_tired.png",
	"player_romance_casual": "res://assets/characters/main_character_unemployed.png",
	# 비직업 일상/산책 장면. 현재 직업 정장으로 동적 교체하지 않는 검은 크루넥 중립 얼굴.
	"player_offduty_neutral": "res://assets/characters/main_character_neutral_goshiwon.png",
	"player_heatwave":    "res://assets/characters/main_character_heatwave.png",
	"player_monsoon":     "res://assets/characters/main_character_monsoon.png",
	"player_cold_snap":   "res://assets/characters/main_character_cold_snap.png",
	# 밴드 경계 자각 장면 전용. 같은 검은 크루넥/동일 얼굴에서 표정만 단계적으로 변한다.
	"player_moral_gray":  "res://assets/characters/main_character_neutral_goshiwon.png",
	"player_moral_black": "res://assets/characters/main_character_determined.png",
	"player_moral_white": "res://assets/characters/main_character_happy.png",
	# 직업/생활 맥락을 보존하는 1·3·5년 시간 앵커. y1은 기존 원화다.
	"player_unemployed":     "res://assets/characters/main_character_unemployed.png",
	"player_unemployed_y3":  "res://assets/characters/main_character_unemployed_y3.png",
	"player_unemployed_y5":  "res://assets/characters/main_character_unemployed_y5.png",
	"player_part_time":      "res://assets/characters/main_character_part_time.png",
	"player_part_time_y3":   "res://assets/characters/main_character_part_time_y3.png",
	"player_part_time_y5":   "res://assets/characters/main_character_part_time_y5.png",
	"player_office":         "res://assets/characters/main_character_office.png",
	"player_office_y3":      "res://assets/characters/main_character_office_y3.png",
	"player_office_y5":      "res://assets/characters/main_character_office_y5.png",
	"player_corporate":      "res://assets/characters/main_character_corporate.png",
	"player_corporate_y3":   "res://assets/characters/main_character_corporate_y3.png",
	"player_corporate_y5":   "res://assets/characters/main_character_corporate_y5.png",

	# 김다은 (연인)
	"daeun_normal":       "res://assets/characters/npc_romantic_interest.png",
	"daeun_normal_y3":    "res://assets/characters/npc_daeun_normal_y3.png",
	"daeun_normal_y5":    "res://assets/characters/npc_daeun_normal_y5.png",
	"daeun_smile":        "res://assets/characters/npc_daeun_smile.png",
	"daeun_smile_y3":     "res://assets/characters/npc_daeun_smile_y3.png",
	"daeun_smile_y5":     "res://assets/characters/npc_daeun_smile_y5.png",
	"daeun_proposal":     "res://assets/characters/npc_daeun_proposal.png",
	"daeun_sad":          "res://assets/characters/npc_daeun_sad.png",
	"daeun_sad_y3":       "res://assets/characters/npc_daeun_sad_y3.png",
	"daeun_sad_y5":       "res://assets/characters/npc_daeun_sad_y5.png",
	"daeun_sea":          "res://assets/characters/npc_daeun_sea_v2.png",
	"daeun_fireworks":    "res://assets/characters/npc_daeun_fireworks.png",
	"daeun_cherry":       "res://assets/characters/npc_daeun_cherry.png",
	"daeun_namsan":       "res://assets/characters/npc_daeun_namsan.png",
	"daeun_amusement":    "res://assets/characters/npc_daeun_amusement.png",
	"daeun_hometown_worried": "res://assets/characters/npc_daeun_hometown_worried.png",
	"daeun_hometown_warm": "res://assets/characters/npc_daeun_hometown_warm.png",
	"daeun_wedding_night": "res://assets/characters/npc_daeun_wedding_night.png",
	"daeun_first_snow":  "res://assets/characters/npc_daeun_first_snow.png",

	# 임상철 (인맥 브로커)
	"sangchul_normal":    "res://assets/characters/npc_boss.png",
	"sangchul_normal_y3": "res://assets/characters/npc_sangchul_normal_y3.png",
	"sangchul_normal_y5": "res://assets/characters/npc_sangchul_normal_y5.png",
	"sangchul_serious":   "res://assets/characters/npc_sangchul_serious.png",
	"sangchul_serious_y3": "res://assets/characters/npc_sangchul_serious_y3.png",
	"sangchul_serious_y5": "res://assets/characters/npc_sangchul_serious_y5.png",

	# 강남 카페 시나리오 — 폴더 주인과 폴더 속 김 부장은 별개 인물
	"cafe_investor":      "res://assets/characters/npc_cafe_investor.png",
	"cafe_broker_kim":    "res://assets/characters/npc_cafe_broker_kim.png",

	# 강현수 (고시원 옆방 공시생 후배)
	"hyunsu":             "res://assets/characters/npc_close_friend.png",
	"hyunsu_normal":      "res://assets/characters/npc_close_friend.png",
	"hyunsu_normal_y3":   "res://assets/characters/npc_hyunsu_normal_y3.png",
	"hyunsu_normal_y5":   "res://assets/characters/npc_hyunsu_normal_y5.png",
	"hyunsu_accounting":  "res://assets/characters/npc_hyunsu_accounting.png",
	"hyunsu_civil_service": "res://assets/characters/npc_hyunsu_civil_service.png",

	# 한지연 (투자·로맨스) — legacy file names, regenerate as transparent portraits
	"jiyeon_normal":      "res://assets/characters/npc_mentor.png",
	"jiyeon_normal_y3":   "res://assets/characters/npc_jiyeon_normal_y3.png",
	"jiyeon_normal_y5":   "res://assets/characters/npc_jiyeon_normal_y5.png",
	"jiyeon_warm":        "res://assets/characters/npc_jiyeon_warm.png",
	"jiyeon_warm_y3":     "res://assets/characters/npc_jiyeon_warm_y3.png",
	"jiyeon_warm_y5":     "res://assets/characters/npc_jiyeon_warm_y5.png",
	"jiyeon_cold":        "res://assets/characters/npc_jiyeon_cold.png",
	"jiyeon_cold_y3":     "res://assets/characters/npc_jiyeon_cold_y3.png",
	"jiyeon_cold_y5":     "res://assets/characters/npc_jiyeon_cold_y5.png",
	"jiyeon_sea":         "res://assets/characters/npc_jiyeon_sea_v2.png",
	"jiyeon_fireworks":   "res://assets/characters/npc_jiyeon_fireworks.png",
	"jiyeon_cherry":      "res://assets/characters/npc_jiyeon_cherry.png",
	"jiyeon_namsan":      "res://assets/characters/npc_jiyeon_namsan.png",
	"jiyeon_amusement":   "res://assets/characters/npc_jiyeon_amusement.png",
	"jiyeon_narrow_door": "res://assets/characters/npc_jiyeon_narrow_door.png",
	"jiyeon_narrow_room": "res://assets/characters/npc_jiyeon_narrow_room.png",
	"jiyeon_wedding_night": "res://assets/characters/npc_jiyeon_wedding_night.png",
	"jiyeon_first_snow": "res://assets/characters/npc_jiyeon_first_snow.png",

	# 조연
	"boss":               "res://assets/characters/npc_team_lead.png",
	"goshiwon_owner":     "res://assets/characters/npc_goshiwon_owner.png",
	"mother":             "res://assets/characters/npc_mother.png",
	"father_normal":      "res://assets/characters/npc_father.png",
	"father_proud":       "res://assets/characters/npc_father.png",
	"father_past":        "res://assets/characters/npc_father_past.png",
	"father_weak":        "res://assets/characters/npc_father_weak.png",
	"father_home":        "res://assets/characters/npc_father_home.png",
	"father_home_y3":     "res://assets/characters/npc_father_home_y3.png",
	"father_home_y5":     "res://assets/characters/npc_father_home_y5.png",
	"father_home_weak":   "res://assets/characters/npc_father_home_weak.png",
	"father_hospitalized": "res://assets/characters/npc_father_hospitalized.png",
	"jaehyuk_charisma":   "res://assets/characters/npc_jaehyuk.png",
	"jaehyuk_friendly":   "res://assets/characters/npc_jaehyuk.png",
	"jaehyuk_normal_y3":  "res://assets/characters/npc_jaehyuk_normal_y3.png",
	"jaehyuk_normal_y5":  "res://assets/characters/npc_jaehyuk_normal_y5.png",
	"jaehyuk_shadow":     "res://assets/characters/npc_jaehyuk_shadow.png",
	"jaehyuk_shadow_y3":  "res://assets/characters/npc_jaehyuk_shadow_y3.png",
	"jaehyuk_shadow_y5":  "res://assets/characters/npc_jaehyuk_shadow_y5.png",
	"jaehyuk_cornered":   "res://assets/characters/npc_jaehyuk.png",
	"seongjun":           "res://assets/characters/npc_seongjun.png",

	# 경마장 정보상
	"tip_seller":         "res://assets/characters/npc_tip_seller.png",

	# 신규 인물 (Year 3-5)
	"minseo":             "res://assets/characters/npc_minseo.png",
	"minseo_normal":      "res://assets/characters/npc_minseo.png",
}

const PLAYER_UNEMPLOYED = "res://assets/characters/main_character_unemployed.png"
const PLAYER_PART_TIME = "res://assets/characters/main_character_part_time.png"
const PLAYER_OFFICE = "res://assets/characters/main_character_office.png"
const PLAYER_CORPORATE = "res://assets/characters/main_character_corporate.png"
const PLAYER_TIRED = "res://assets/characters/main_character_tired.png"
const PLAYER_HAPPY = "res://assets/characters/main_character_happy.png"
const PLAYER_SHOCKED = "res://assets/characters/main_character_shocked.png"
const PLAYER_HOLLOW = "res://assets/characters/main_character_tired.png"
const PLAYER_MORAL_GRAY = "res://assets/characters/main_character_neutral_goshiwon.png"
const PLAYER_MORAL_BLACK = "res://assets/characters/main_character_determined.png"
const PLAYER_MORAL_WHITE = "res://assets/characters/main_character_happy.png"

# ── 인물 표시 정보 (플레이스홀더용 — 이름 + 테마색) ──────────────
const PERSON_INFO = {
	"player":   {"name": "{name}",       "color": "#c9a227"},
	"jiyeon":   {"name": "한지연",        "color": "#e8a0c0"},
	"daeun":    {"name": "김다은",        "color": "#7ec8a0"},
	"jaehyuk":  {"name": "최재혁",        "color": "#d08a4a"},
	"father":   {"name": "아버지",        "color": "#9a8a6a"},
	"sangchul": {"name": "임상철",        "color": "#8a8aa0"},
	"cafe_investor": {"name": "카페의 남자", "color": "#78929a"},
	"cafe_broker_kim": {"name": "김 부장",   "color": "#9a7a72"},
	"goshiwon_owner": {"name": "고시원 원장", "color": "#a0907a"},
	"hyunsu":   {"name": "현수",          "color": "#7a8a9a"},
	"seongjun": {"name": "박성준",        "color": "#6a9ab0"},
	"mother":   {"name": "어머니",        "color": "#b09a9a"},
	"boss":     {"name": "팀장",          "color": "#9a6a6a"},
	"jaewon":   {"name": "박재원",        "color": "#7a9a8a"},
	"minseo":   {"name": "이민서",        "color": "#9a8a7a"},
}

const PERSON_NAMES_EN = {
	"player": "{name}",
	"jiyeon": "Han Jiyeon",
	"daeun": "Kim Daeun",
	"jaehyuk": "Choi Jaehyuk",
	"father": "Father",
	"sangchul": "Lim Sangchul",
	"cafe_investor": "Man at the Cafe",
	"cafe_broker_kim": "Manager Kim",
	"goshiwon_owner": "Goshiwon Manager",
	"hyunsu": "Kang Hyunsu",
	"seongjun": "Park Seongjun",
	"mother": "Mother",
	"boss": "Team Lead",
	"jaewon": "Park Jaewon",
	"minseo": "Lee Minseo",
}

# ── 배경 이미지 ────────────────────────────────────────────────
const BACKGROUNDS = {
	# 고시원/생활권
	# Runtime sentinels. get_background() resolves these from the live run state.
	"current_housing":   "res://assets/backgrounds/goshiwon_room.png",
	"current_workplace": "res://assets/backgrounds/office_desk.png",
	"goshiwon":          "res://assets/backgrounds/goshiwon_room.png",
	"goshiwon_room":     "res://assets/backgrounds/goshiwon_room.png",
	"goshiwon_hallway":  "res://assets/backgrounds/goshiwon_hallway.png",
	"goshiwon_shared_kitchen": "res://assets/backgrounds/goshiwon_shared_kitchen.png",
	# 서울 일상
	"convenience_night": "res://assets/backgrounds/convenience_store_night_v2.png",
	"convenience_first_snow_exterior": "res://assets/backgrounds/convenience_store_exterior_first_snow.png",
	"cafe":              "res://assets/backgrounds/cafe_seoul.png",
	"gukbap_restaurant_night": "res://assets/backgrounds/gukbap_restaurant_night.png",
	"street_day":        "res://assets/backgrounds/street_seoul_day.png",
	"subway":            "res://assets/backgrounds/seoul_subway.png",
	"seoul_bus_terminal_night": "res://assets/backgrounds/seoul_bus_terminal_night.png",
	"street_rainy":      "res://assets/backgrounds/seoul_rainy_street.png",
	"street_rainy_bus_stop_wallet": "res://assets/backgrounds/seoul_bus_stop_wallet.png",
	"cold_snap_street":  "res://assets/backgrounds/seoul_cold_snap_street.png",
	"winter_street_bungeoppang": "res://assets/backgrounds/winter_bungeoppang_stall.png",
	"year2_winter_street_night": "res://assets/backgrounds/year2_winter_last_night.png",
	"pojangmacha":       "res://assets/backgrounds/pojangmacha.png",
	"hangang_riverside": "res://assets/backgrounds/hangang_riverside_walk.png",
	"year3_hangang_winter_night": "res://assets/backgrounds/year3_hangang_winter_night.png",
	"namsan_tower":      "res://assets/backgrounds/namsan_tower_view.png",
	"namsan_cable_car":  "res://assets/backgrounds/namsan_cable_car_night.png",
	"namsan_tonkatsu_restaurant": "res://assets/backgrounds/namsan_tonkatsu_restaurant_night.png",
	"namsan_observation_deck": "res://assets/backgrounds/namsan_observation_deck_night.png",
	"amusement_park_parade": "res://assets/backgrounds/amusement_park_parade_day.png",
	"amusement_roller_coaster": "res://assets/backgrounds/amusement_roller_coaster_day.png",
	"amusement_photo_booth": "res://assets/backgrounds/amusement_photo_booth_evening.png",
	"rooftop_day":       "res://assets/backgrounds/rooftop_daytime.png",
	"rooftop_night":     "res://assets/backgrounds/rooftop_night.png",
	"year4_winter_rooftop": "res://assets/backgrounds/year4_winter_rooftop.png",
	"hagwon_street":     "res://assets/backgrounds/hagwon_street.png",
	"suneung_test_hall": "res://assets/backgrounds/suneung_test_hall.png",
	"community_center":  "res://assets/backgrounds/community_center.png",
	"jjimjilbang":       "res://assets/backgrounds/jjimjilbang.png",
	"cherry_blossom_path": "res://assets/backgrounds/cherry_blossom_path.png",
	"saju_cafe":         "res://assets/backgrounds/saju_cafe.png",
	"company_dinner_restaurant": "res://assets/backgrounds/company_dinner_restaurant.png",
	"heatwave_city":     "res://assets/backgrounds/heatwave_city.png",
	"fine_dust_sky":     "res://assets/backgrounds/fine_dust_sky.png",
	"chuseok_highway":   "res://assets/backgrounds/chuseok_highway.png",
	"open_chat_screen":  "res://assets/backgrounds/open_chat_screen.png",
	# 직장/사업
	"office":            "res://assets/backgrounds/office_desk.png",
	"office_interview_day": "res://assets/backgrounds/office_interview_day.png",
	"warehouse_inventory_night": "res://assets/backgrounds/warehouse_inventory_night.png",
	"moving_truck_loading_dusk": "res://assets/backgrounds/moving_truck_loading_dusk.png",
	"realestate_office": "res://assets/backgrounds/realestate_office.png",
	"meeting":           "res://assets/backgrounds/investment_meeting.png",
	"sangchul_private_dining": "res://assets/backgrounds/sangchul_private_dining.png",
	# 강남
	"gangnam_day":       "res://assets/backgrounds/gangnam_day.png",
	"gangnam_night":     "res://assets/backgrounds/gangnam_night_street.png",
	"gangnam_apartment": "res://assets/backgrounds/gangnam_apartment.png",
	# 특수
	"hospital":          "res://assets/backgrounds/hospital_corridor.png",
	"hospital_clinic":   "res://assets/backgrounds/hospital_clinic.png",
	"changwon_hospital_room_empty": "res://assets/backgrounds/changwon_hospital_room_empty.png",
	"gym":               "res://assets/backgrounds/gym_interior.png",
	"exercise":          "res://assets/backgrounds/gym_interior.png",
	"military":          "res://assets/backgrounds/military_training_ground.png",
	"military_base_gate": "res://assets/backgrounds/military_base_gate.png",
	# Canon-safe Changwon father-home background regenerated on 2026-06-12.
	"dad_house":         "res://assets/backgrounds/family_living_room.png",
	"hometown_train_station": "res://assets/backgrounds/hometown_train_station.png",
	"seoul_station_ktx_platform_winter": "res://assets/backgrounds/seoul_station_ktx_platform_winter.png",
	"ktx_window":        "res://assets/backgrounds/regional_train_window_summer.png",
	"regional_train_window": "res://assets/backgrounds/regional_train_window_summer.png",
	"daeun_mother_home_dining": "res://assets/backgrounds/daeun_mother_home_dining_summer.png",
	"daeun_newlywed_home": "res://assets/backgrounds/daeun_newlywed_home_night.png",
	"jiyeon_newlywed_home": "res://assets/backgrounds/jiyeon_newlywed_home_night.png",
	"jiyeon_sedan_night": "res://assets/backgrounds/jiyeon_sedan_night_interior.png",
	"jiyeon_sedan_first_snow": "res://assets/backgrounds/jiyeon_sedan_first_snow_interior.png",
	"burnout":           "res://assets/backgrounds/burnout_hospital_room.png",
	"penthouse":         "res://assets/backgrounds/penthouse_view.png",
	"gangnam_penthouse": "res://assets/backgrounds/penthouse_view.png",
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
	"apartment_balcony": "res://assets/backgrounds/oneroom_apartment.png",
	"convenience_store": "res://assets/backgrounds/convenience_store_night_v2.png",
	# 미니게임 전용
	"racetrack_betting": "res://assets/backgrounds/racetrack_betting_hall.png",
	"racetrack_track":   "res://assets/backgrounds/racetrack_track_view.png",
	"holdem_club":       "res://assets/backgrounds/holdem_club_interior.png",
	"casino":            "res://assets/backgrounds/casino_interior.png",
	"jeongseon_casino_exterior": "res://assets/backgrounds/jeongseon_casino_exterior.png",
	"jeongseon_casino_entrance": "res://assets/backgrounds/jeongseon_casino_entrance.png",
	"scalping_room":     "res://assets/backgrounds/scalping_trading_room.png",
	"aruba_delivery":    "res://assets/backgrounds/aruba_delivery_street.png",
	"gangnam_station":   "res://assets/backgrounds/gangnam_station_exit.png",
}

const FALLBACK_BG = "res://assets/backgrounds/goshiwon_room.png"

# ── CG (감정적 클라이맥스 전체화면) ────────────────────────────
const CG = {
	"cg_start":          "res://assets/cg/start.png",
	"cg_demo_first_interview": "res://assets/cg/demo/first_interview_v1.png",
	"cg_jiyeon_crash":   "res://assets/cg/jiyeon_crash_day_v3.png",
	"cg_demo_daeun_first_kindness": "res://assets/cg/demo/daeun_first_kindness_v2.png",
	"cg_demo_father_first_call": "res://assets/cg/demo/father_first_call_v1.png",
	"cg_seollal_sebae_family": "res://assets/cg/seollal_sebae_family_v1.png",
	"cg_jaehyuk_reveal": "res://assets/cg/jaehyuk_reveal.png",
	"cg_ending_father":  "res://assets/cg/ending_father.png",
	"cg_ending_gangnam_dream": "res://assets/cg/ending_gangnam_dream.png",
	"cg_ending_empty_house":   "res://assets/cg/ending_empty_house.png",
	"cg_ending_crypto_ghost":  "res://assets/cg/ending_crypto_ghost.png",
	"cg_ending_full_circle": "res://assets/cg/ending_full_circle_v1.png",
	"cg_ending_gangnam_dream_white": "res://assets/cg/ending_gangnam_dream_white_v2.png",
	"cg_ending_with_daeun": "res://assets/cg/ending_with_daeun_v1.png",
	"cg_ending_second_love": "res://assets/cg/ending_second_love_v1.png",
	"cg_ending_jiyeon_man": "res://assets/cg/ending_jiyeon_man_v2.png",
	"cg_ending_guardian": "res://assets/cg/ending_guardian_v1.png",
	"cg_ending_jaehyuk_way": "res://assets/cg/ending_jaehyuk_way_v1.png",
	"cg_ending_sangchul_reckoning": "res://assets/cg/ending_sangchul_reckoning_v1.png",
	"cg_ending_late_call": "res://assets/cg/ending_late_call_v1.png",
	"cg_ending_lonely_rich": "res://assets/cg/ending_lonely_rich_v1.png",
	"cg_ending_gambling_recovery": "res://assets/cg/ending_gambling_recovery_v2.png",
	"cg_ending_bankruptcy": "res://assets/cg/ending_bankruptcy_v2.png",
	"cg_ending_debt_spiral": "res://assets/cg/ending_debt_spiral_v2.png",
	"cg_ending_startup_exit": "res://assets/cg/ending_startup_exit_v1.png",
	"cg_ending_instant_legend": "res://assets/cg/ending_instant_legend_v1.png",
	"cg_ending_orthodox_pinnacle": "res://assets/cg/ending_orthodox_pinnacle_v1.png",
	"cg_ending_burnout": "res://assets/cg/ending_burnout_v1.png",
	"cg_ending_stable_success": "res://assets/cg/ending_stable_success_v1.png",
	"cg_ending_ordinary_life": "res://assets/cg/ending_ordinary_life_v1.png",
	"cg_ending_mental_break": "res://assets/cg/ending_mental_break_v1.png",
	"cg_ending_political_fix": "res://assets/cg/ending_political_fix_v1.png",
	"cg_ending_investment_master": "res://assets/cg/ending_investment_master_v1.png",
	"cg_ending_reputation_legend": "res://assets/cg/ending_reputation_legend_v1.png",
	"cg_ending_healthy_retirement": "res://assets/cg/ending_healthy_retirement_v1.png",
	"cg_ending_orthodox_hollow": "res://assets/cg/ending_orthodox_hollow_v2.png",
	"cg_ending_balanced_life": "res://assets/cg/ending_balanced_life_v1.png",
	"cg_ending_unorthodox_legend": "res://assets/cg/ending_unorthodox_legend_v1.png",
	"cg_ending_early_retirement": "res://assets/cg/ending_early_retirement_v1.png",
	"cg_ending_creator_success": "res://assets/cg/ending_creator_success_v1.png",
	"cg_ending_career_climber": "res://assets/cg/ending_career_climber_v1.png",
	"cg_ending_career_burnout": "res://assets/cg/ending_career_burnout_v1.png",
	"cg_ending_writer": "res://assets/cg/ending_writer_v1.png",
	"cg_romance_sea_daeun":    "res://assets/cg/romance/sea_daeun_v3.png",
	"cg_romance_sea_jiyeon":   "res://assets/cg/romance/sea_jiyeon_v2.png",
	"cg_romance_fireworks_daeun": "res://assets/cg/romance/fireworks_daeun.png",
	"cg_romance_fireworks_jiyeon": "res://assets/cg/romance/fireworks_jiyeon.png",
	"cg_romance_cherry_daeun": "res://assets/cg/romance/cherry_daeun.png",
	"cg_romance_cherry_jiyeon": "res://assets/cg/romance/cherry_jiyeon.png",
	"cg_romance_first_kiss_daeun": "res://assets/cg/romance/first_kiss_daeun.png",
	"cg_romance_first_kiss_jiyeon": "res://assets/cg/romance/first_kiss_jiyeon.png",
	"cg_romance_namsan_lock_daeun": "res://assets/cg/romance/namsan_lock_daeun_v1.png",
	"cg_romance_namsan_lock_jiyeon": "res://assets/cg/romance/namsan_lock_jiyeon_v1.png",
	"cg_romance_amusement_lost_child_daeun": "res://assets/cg/romance/amusement_lost_child_daeun_v1.png",
	"cg_romance_amusement_photo_strip_jiyeon": "res://assets/cg/romance/amusement_photo_strip_jiyeon_v1.png",
	"cg_romance_narrow_room_jiyeon": "res://assets/cg/romance/narrow_room_jiyeon_v1.png",
	"cg_romance_hometown_night_bus_daeun": "res://assets/cg/romance/hometown_night_bus_daeun_v1.png",
	"cg_romance_proposal_daeun": "res://assets/cg/romance/proposal_daeun_v1.png",
	"cg_romance_wedding_daeun_mother_reaction": "res://assets/cg/romance/wedding_daeun_mother_reaction_v1.png",
	"cg_romance_wedding_daeun_father_reaction": "res://assets/cg/romance/wedding_daeun_father_reaction_v1.png",
	"cg_romance_wedding_daeun_father_reaction_hyunsu": "res://assets/cg/romance/wedding_daeun_father_reaction_hyunsu_v1.png",
	"cg_romance_wedding_daeun_father_reaction_passed": "res://assets/cg/romance/wedding_daeun_father_reaction_passed_v1.png",
	"cg_romance_wedding_daeun_father_reaction_passed_hyunsu": "res://assets/cg/romance/wedding_daeun_father_reaction_passed_hyunsu_v1.png",
	"cg_romance_wedding_daeun_small": "res://assets/cg/romance/wedding_daeun_small_v1.png",
	"cg_romance_wedding_daeun_full": "res://assets/cg/romance/wedding_daeun_full_v1.png",
	"cg_romance_wedding_daeun_small_close": "res://assets/cg/romance/wedding_daeun_small_close_v1.png",
	"cg_romance_wedding_daeun_full_close": "res://assets/cg/romance/wedding_daeun_full_close_v1.png",
	"cg_romance_wedding_gap_jiyeon": "res://assets/cg/romance/wedding_gap_jiyeon_v1.png",
	"cg_romance_wedding_morning_daeun": "res://assets/cg/romance/wedding_morning_daeun_v1.png",
	"cg_romance_wedding_morning_jiyeon": "res://assets/cg/romance/wedding_morning_jiyeon_v1.png",
	"cg_romance_first_snow_daeun": "res://assets/cg/romance/first_snow_daeun_v1.png",
	"cg_romance_first_snow_jiyeon": "res://assets/cg/romance/first_snow_jiyeon_v1.png",
	"cg_romance_breakup_daeun": "res://assets/cg/romance/breakup_daeun_v1.png",
	"cg_romance_breakup_jiyeon": "res://assets/cg/romance/breakup_jiyeon_v1.png",
}

# ── 유물 오브젝트 스틸 ────────────────────────────────────────
const ITEM_ART = {
	"artifact_sangchul_card": "res://assets/items/artifacts/artifact_sangchul_card.svg",
	"artifact_daeun_note":   "res://assets/items/artifacts/artifact_daeun_note.svg",
	"artifact_father_call":  "res://assets/items/artifacts/artifact_father_call.svg",
	"artifact_jiyeon_text":  "res://assets/items/artifacts/artifact_jiyeon_text.svg",
	"artifact_jaehyuk_photo": "res://assets/items/artifacts/artifact_jaehyuk_photo.svg",
	"artifact_hyunsu_card":  "res://assets/items/artifacts/artifact_hyunsu_card.svg",
}

# ── 조회 API ──────────────────────────────────────────────────

## 초상화 경로 반환. 파일 없으면 "" (UI가 플레이스홀더 처리)
func get_portrait(id: String) -> String:
	return get_portrait_for_turn(id, GameState.turn)

## 저장 데이터에 별도 연차 상태를 넣지 않는다. 같은 저장이라도 현재 turn에서
## 1·3·5년 앵커를 결정하므로 구버전 저장과 언어별 경로가 같은 초상을 본다.
func get_portrait_for_turn(id: String, turn_override: int) -> String:
	var canonical_id := _get_dynamic_player_portrait_id(id)
	var resolved_id := resolve_temporal_portrait_id(canonical_id, turn_override)
	for candidate_id in [resolved_id, canonical_id, id]:
		var path := str(PORTRAITS.get(str(candidate_id), ""))
		if path != "" and has_texture(path):
			return path
	return ""

func get_player_portrait_for_state(state: String = "normal") -> String:
	var portrait_id := "player_normal"
	match state:
		"shocked":
			portrait_id = "player_shocked"
		"happy":
			portrait_id = "player_happy"
		"tired", "sad":
			portrait_id = "player_tired"
		"hollow":
			portrait_id = "player_hollow"
		"normal", "determined", "suit":
			portrait_id = "player_normal"
		_:
			portrait_id = "player_normal"
	return get_portrait(portrait_id)

func get_player_context_portrait() -> String:
	return get_portrait_for_turn(get_player_context_portrait_id(), GameState.turn)

func get_player_context_portrait_id() -> String:
	if GameState.age >= 50:
		return "player_hollow"

	var job: Dictionary = GameState.current_job
	var total_asset := float(GameState.get_total_asset_value())
	if job.is_empty():
		if GameState.housing in ["apartment", "gangnam"] or total_asset >= 100_000_000.0:
			return "player_corporate"
		return "player_unemployed"

	var job_id := str(job.get("id", ""))
	var category := str(job.get("category", ""))
	var tier := int(job.get("tier", 1))

	if category == "survival" or job_id in ["job_01", "job_02"]:
		return "player_part_time"
	if job_id == "job_08" or category in ["finance", "sales"] or tier >= 3:
		return "player_corporate"
	return "player_office"

## 밴드 경계 비네트는 직업 복장이 아니라 시작 당시의 검은 크루넥으로 돌아간다.
## 같은 기억 프레임에서 표정과 시선만 바뀌어야 전후 비교가 성립한다.
func get_player_moral_portrait(stage: int) -> String:
	match clampi(stage, -2, 2):
		-2:
			return PLAYER_MORAL_BLACK
		-1:
			return PLAYER_TIRED
		0:
			return PLAYER_MORAL_GRAY
		1, 2:
			return PLAYER_MORAL_WHITE
		_:
			return PLAYER_MORAL_GRAY

func _get_dynamic_player_portrait_id(id: String) -> String:
	match id:
		"player_normal":
			return get_player_context_portrait_id()
		"player_determined":
			return get_player_context_portrait_id()
		"player_suit":
			return get_player_context_portrait_id()
		"player_tired", "player_sad":
			return "player_tired"
		"player_happy":
			return "player_happy"
		"player_shocked":
			return "player_shocked"
		"player_hollow":
			return "player_hollow"
		_:
			return id

func reload_cast_visual_years() -> void:
	_cast_visual_years.clear()
	_portrait_time_overrides.clear()
	_fixed_time_portraits.clear()
	_ensure_cast_visual_years()

func get_visual_time_stage(turn_override: int = -1) -> String:
	_ensure_cast_visual_years()
	var current_turn := maxi(turn_override if turn_override >= 0 else GameState.turn, 1)
	var windows: Array = _cast_visual_years.get("stage_windows", [])
	for row_variant in windows:
		if not row_variant is Dictionary:
			continue
		var row: Dictionary = row_variant
		if current_turn >= int(row.get("min_turn", 1)) and current_turn <= int(row.get("max_turn", 240)):
			return str(row.get("id", "y1"))
	return "y5" if current_turn > 192 else "y1"

func resolve_temporal_portrait_id(id: String, turn_override: int = -1) -> String:
	_ensure_cast_visual_years()
	if bool(_fixed_time_portraits.get(id, false)):
		return id
	var stage := get_visual_time_stage(turn_override)
	if stage == "y1":
		return id
	var variants: Dictionary = _portrait_time_overrides.get(id, {})
	return str(variants.get(stage, id))

func is_portrait_time_locked(id: String) -> bool:
	_ensure_cast_visual_years()
	return bool(_fixed_time_portraits.get(id, false))

func get_cast_visual_years_contract() -> Dictionary:
	_ensure_cast_visual_years()
	return _cast_visual_years.duplicate(true)

func _ensure_cast_visual_years() -> void:
	if not _cast_visual_years.is_empty():
		return
	if not FileAccess.file_exists(CAST_VISUAL_YEARS_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CAST_VISUAL_YEARS_PATH))
	if not parsed is Dictionary:
		push_error("CAST_VISUAL_TIME_LOAD_FAIL invalid JSON root")
		return
	_cast_visual_years = parsed
	var characters: Dictionary = _cast_visual_years.get("characters", {})
	for character_variant in characters.values():
		if not character_variant is Dictionary:
			continue
		var character: Dictionary = character_variant
		var overrides: Dictionary = character.get("portrait_overrides", {})
		for portrait_id_variant in overrides:
			var portrait_id := str(portrait_id_variant)
			var variants_variant: Variant = overrides.get(portrait_id_variant, {})
			if variants_variant is Dictionary:
				_portrait_time_overrides[portrait_id] = variants_variant
		var fixed_portraits: Array = character.get("fixed_portraits", [])
		for portrait_id_variant in fixed_portraits:
			_fixed_time_portraits[str(portrait_id_variant)] = true

## 배경 경로 반환. 파일 없으면 기본 배경으로 폴백
func get_background(id: String) -> String:
	var resolved_id := resolve_contextual_background_id(id)
	var path = str(BACKGROUNDS.get(resolved_id, ""))
	if path != "" and has_texture(path):
		return path
	if has_texture(FALLBACK_BG):
		return FALLBACK_BG
	return ""

func resolve_contextual_background_id(id: String) -> String:
	match id:
		"current_housing":
			return _housing_background_id(str(GameState.housing))
		"current_workplace":
			match str(GameState.current_job.get("id", "")):
				"job_01": return "convenience_night"
				"job_02": return "aruba_delivery"
				_: return "office"
	return id

func get_item_art(id: String) -> String:
	var path: String = str(ITEM_ART.get(id, ""))
	if path != "" and has_texture(path):
		return path
	return ""

## 명시 background가 없는 이벤트의 배경을 태그/카테고리로 추론.
## (MainGame._get_bg_for_event와 같은 규칙 — StoryMode에서 빈 배경 방지)
func infer_background_id(ev: Dictionary, housing: String = "gosiwon") -> String:
	var tags: Array = ev.get("tags", [])
	var event_id := str(ev.get("id", ""))
	var category := str(ev.get("category", ""))
	var search := _event_search_text(ev)

	# 구체적인 장소 의미가 broad category보다 항상 먼저다.
	# 예: "집들이"는 social이어도 카페가 아니라 현재 방, "헬스장"은 health가 아니라 운동 배경.
	if "jeongseon" in tags or "jeongseon_casino" in tags or _has_any(search, [
		"정선 카지노", "정선카지노", "jeongseon casino", "casino resort"
	]):
		if _has_any(search, [
			"카지노 입구", "입구", "로비", "서비스 데스크", "출입", "입장",
			"다시 들어", "발이 안 떨어", "나오면서", "entrance", "lobby", "check-in"
		]):
			return "jeongseon_casino_entrance"
		return "jeongseon_casino_exterior"
	if "hangang" in tags or _has_any(search, [
		"한강", "한강공원", "한강변", "강변", "여의도공원", "반포대교",
		"han river", "hangang", "riverside promenade", "river walk"
	]):
		return "hangang_riverside"
	if "namsan" in tags or _has_any(search, [
		"남산", "남산타워", "n서울타워", "서울타워", "n seoul tower",
		"namsan", "seoul tower"
	]):
		return "namsan_tower"
	if event_id == "arc_minseo_01_meet":
		return "meeting"
	if event_id in ["arc_minseo_02_real", "arc_minseo_03_arrival", "arc_minseo_03b_not_arrived"]:
		return "cafe"
	if event_id in ["arc_jaehyuk_sangchul_echo", "arc_jiyeon_father_records"]:
		return "cafe"
	if event_id == "arc_pre_ending_summit":
		return "realestate_office"
	if event_id == "arc_gangnam_real_estate":
		return "investment_phone"
	if event_id == "hyunsu_study_together":
		return "goshiwon_shared_kitchen"
	if event_id == "arc_36_body_signal":
		return "goshiwon_hallway"
	if event_id == "callback_hoesik_payoff":
		return "office"
	if event_id == "casino_chip_exchange":
		return "jeongseon_casino_entrance"
	if event_id == "amb_jeonse_00":
		return "apartment"
	if event_id in ["amb_coin_00", "amb_coin_warn"]:
		return "investment_phone"
	if event_id == "amb_hoesik_drink":
		return "goshiwon_room"
	if event_id == "amb_jobswitch_in":
		return "office"
	if event_id == "amb_quit_impulse":
		return "subway"
	if event_id in ["arc_daeun_03b_date", "arc_daeun_05_breaking"]:
		return "pojangmacha"
	if "cherry_blossom" in tags or "spring_cherry" in tags or _has_any(search, [
		"벚꽃", "여의도 둑방", "석촌호수", "꽃잎", "cherry blossom", "cherry blossoms",
		"yeouido embankment", "seokchon lake", "petals"
	]):
		return "cherry_blossom_path"
	if "saju" in tags or _has_any(search, [
		"사주카페", "사주", "생년월일시", "fortune-reading", "fortune reading",
		"fortune cafe", "saju"
	]):
		return "saju_cafe"
	if "pojangmacha" in tags or _has_any(search, [
		"포장마차", "street stall", "pojangmacha"
	]):
		return "pojangmacha"
	if "hoesik" in tags or _has_any(search, [
		"회식", "삼겹살집", "삼겹살", "소주", "노래방", "포장마차",
		"company dinner", "hoesik", "samgyeopsal", "soju", "noraebang", "karaoke"
	]):
		return "company_dinner_restaurant"
	if "heatwave" in tags or _has_any(search, [
		"폭염", "체감온도 40도", "아스팔트 열기", "냉방 쉼터", "heatwave",
		"heat wave", "feels like 40", "asphalt heat", "cooling shelter"
	]):
		return "heatwave_city"
	if event_id == "kx_fine_dust" or "fine_dust" in tags or _has_any(search, [
		"미세먼지", "황사", "kf94", "초미세먼지", "air pollution", "fine dust",
		"yellow dust", "smog", "kf94 mask"
	]):
		return "fine_dust_sky"
	if event_id == "kx_chuseok_traffic" or _has_any(search, [
		"추석 귀성길", "귀성길", "추석 연휴", "고속도로", "시외버스", "ktx는",
		"chuseok traffic", "holiday traffic", "homecoming traffic", "intercity bus"
	]):
		return "chuseok_highway"
	if event_id == "kx_open_chat" or _has_any(search, [
		"오픈채팅", "오픈 채팅", "open chat", "open chatroom", "anonymous chat",
		"online investing chat", "chat room"
	]):
		return "open_chat_screen"
	if event_id == "kx_monsoon" or _has_any(search, [
		"장마", "며칠 째 비", "젖은 우산", "monsoon", "raining for days", "wet umbrellas"
	]):
		return "street_rainy"
	if event_id == "kx_civil_defense_siren" or _has_any(search, [
		"민방위", "사이렌", "civil defense siren", "civil defense drill"
	]):
		return "street"
	if "hagwon" in tags or _has_any(search, [
		"학원가", "학원", "대치동", "입시학원", "보습학원", "private academy",
		"academy street", "hagwon", "daechi"
	]):
		return "hagwon_street"
	if "suneung" in tags or _has_any(search, [
		"수능", "시험장", "고사장", "수험표", "감독관", "college scholastic ability test",
		"csat", "exam hall", "test hall"
	]):
		return "suneung_test_hall"
	if "community_center" in tags or _has_any(search, [
		"주민센터", "동사무소", "행정복지센터", "번호표", "확정일자", "민원 창구",
		"community center", "district office", "public service office", "queue ticket"
	]):
		return "community_center"
	if "jjimjilbang" in tags or _has_any(search, [
		"찜질방", "황토방", "사우나", "목욕탕", "찜질복", "나무 베개",
		"jjimjilbang", "korean sauna", "sauna room"
	]):
		return "jjimjilbang"
	if "reserve_duty" in tags or _has_any(search, [
		"예비군", "입소 통지서", "훈련 통지", "불참 시 과태료", "reserve forces",
		"reserve duty", "reserve-force", "reserve training", "no-show fine"
	]):
		return "military_base_gate"
	if event_id == "kx_convenience_store_job" or _has_any(search, [
		"편의점 알바 면접", "편의점 점장", "convenience store interview",
		"convenience-store interview"
	]):
		return "convenience_night"
	if event_id == "kx_claw_machine" or _has_any(search, [
		"인형뽑기", "뽑기의 함정", "지하철역 출구 인형뽑기", "claw machine"
	]):
		return "gangnam_station"
	if event_id == "kx_room_escape" or _has_any(search, [
		"방탈출", "방탈출 카페", "escape room"
	]):
		return "cafe"
	if event_id == "kx_health_insurance" or _has_any(search, [
		"건강보험료 고지서", "지역가입자", "health insurance bill"
	]):
		return "goshiwon_room"
	if event_id == "kx_holiday_alone" or _has_any(search, [
		"혼자 보내는 명절", "명절 연휴, 서울은 텅 비었다", "holidays alone"
	]):
		return "goshiwon_room"
	if event_id == "kx_naver_cafe" or _has_any(search, [
		"네이버 카페", "naver café", "naver cafe"
	]):
		return "goshiwon_room"
	if _has_any(search, [
		"신촌 이면도로", "back-alley in sinchon"
	]):
		return "street"
	if event_id in ["friend_housewarming", "housewarming_alone"] or _has_any(search, [
		"집들이", "방 안", "방안을", "창문 밖", "옆 건물", "my room", "inside the room",
		"housewarming"
	]):
		return _housing_background_id(housing)
	if "holdem" in tags or _has_any(search, [
		"홀덤", "포커", "텍사스 홀덤", "poker", "holdem", "texas hold'em",
		"green felt", "felt table"
	]):
		return "holdem_club"
	if "racetrack" in tags or "race" in tags or _has_any(search, [
		"경마", "경마장", "경마공원", "과천", "마권", "기수", "말들이", "최종 직선",
		"horse race", "racetrack", "racecourse", "betting hall"
	]):
		if _has_any(search, ["결과", "스타트", "제1코너", "최종 직선", "관람대", "track view", "finish"]):
			return "racetrack_track"
		return "racetrack_betting"
	if "lotto" in tags or _has_any(search, ["복권", "로또", "스크래치", "lottery", "scratch"]):
		return "convenience_night"
	if "gym" in tags or "exercise" in tags or _has_any(search, [
		"헬스장", "운동", "달리기", "달렸다", "러닝", "pt ", "gym", "exercise",
		"workout", "fitness", "trainer"
	]):
		return "gym"
	if "hospital" in tags or _has_any(search, [
		"병원", "의사", "검진", "응급실", "진료", "입원", "퇴원", "hospital",
		"doctor", "checkup", "clinic", "emergency room", "medical"
	]):
		return "hospital"
	if "convenience" in tags or _has_any(search, ["편의점", "convenience store"]):
		return "convenience_night"
	if "scalping" in tags:
		return "scalping_room"
	if "realestate" in tags or _has_any(search, [
		"부동산", "중개소", "청약", "전세", "경매", "보증금", "재개발", "빌라", "real estate",
		"redevelopment", "deposit", "auction"
	]):
		return "realestate_office"
	if category == "housing" or "housing" in tags:
		if "gangnam" in tags or "gangnam_station" in tags:
			return "gangnam_apartment"
		return _housing_background_id(housing)
	if "study" in tags or _has_any(search, [
		"도서관", "열람실", "스터디카페", "독서", "책을", "library", "reading room", "study cafe"
	]):
		return "library"
	if "interview" in tags or _has_any(search, ["면접", "면접관", "interview", "interviewer"]):
		return "office_interview_day"
	if "job" in tags or "work" in tags or "office" in tags or category == "jobs" \
			or _has_any(search, ["사무실", "회사", "직장", "office"]):
		return "office"
	if "commute" in tags or "subway" in tags or _has_any(search, ["지하철", "subway"]):
		return "subway"
	if "social" in tags or "date" in tags or "cafe" in tags \
			or "relationship" in tags or category == "romance" \
			or _has_any(search, ["카페", "커피", "cafe", "coffee"]):
		return "cafe"
	if "investment" in tags or category == "investment" or "finance" in tags:
		return "investment_phone"
	if "family" in tags or category == "family":
		return "dad_house"
	if "hometown" in tags:
		return "ktx_window"
	if "rooftop" in tags:
		return "rooftop_day"
	if category == "health":
		if "stress" in tags or "burnout" in tags or "mental" in tags:
			return "late_night"
		return "hospital"
	if category == "military" or "military" in tags:
		return "military"
	if category == "politics":
		return "gangnam_night"
	if category == "gambling" or "gambling" in tags or "crypto" in tags:
		return "investment_phone"
	if "pc_bang" in tags or "gaming" in tags or _has_any(search, [
		"pc방", "피시방", "pc bang", "pc cafe", "internet cafe"
	]):
		return "pc_bang"
	if "gangnam_station" in tags:
		return "gangnam_station"
	if "night" in tags or "stress" in tags:
		return "late_night"
	if "gosiwon" in tags:
		return "goshiwon_room"
	# 주거 기반 폴백
	return _housing_background_id(housing)

func _housing_background_id(housing: String) -> String:
	match housing:
		"gangnam":   return "gangnam_apartment"
		"apartment": return "gangnam_apartment"
		"villa":     return "apartment"
		"oneroom":   return "apartment"
		_:           return "goshiwon_room"

func _event_search_text(ev: Dictionary) -> String:
	var parts := PackedStringArray()
	parts.append(str(ev.get("id", "")))
	parts.append(str(ev.get("title", "")))
	parts.append(str(ev.get("description", "")))
	parts.append(str(ev.get("category", "")))
	for tag in ev.get("tags", []):
		parts.append(str(tag))
	return " ".join(parts).to_lower()

func _has_any(text: String, needles: Array) -> bool:
	for needle in needles:
		if text.find(str(needle).to_lower()) >= 0:
			return true
	return false

## CG 경로 반환. 파일 없으면 "" (UI가 검은 화면 + 텍스트 처리)
func get_cg(id: String) -> String:
	var path = str(CG.get(id, ""))
	if path != "" and has_texture(path):
		return path
	return ""

func has_texture(canonical_path: String) -> bool:
	return ModLoader.image_exists(canonical_path)

func load_texture(canonical_path: String) -> Texture2D:
	return ModLoader.load_texture(canonical_path)

## 초상화 ID에서 인물 정보(이름/색상) 추출 — 플레이스홀더 렌더용
## "jiyeon_warm" → {"name":"한지연", "color":"#e8a0c0"}
func get_person_info(portrait_id: String) -> Dictionary:
	if portrait_id == "":
		return {}
	# 마지막 _ 기준으로 prefix 추출 (예: "goshiwon_owner" 같은 복합 키 우선 매칭)
	for key in PERSON_INFO:
		if portrait_id == key or portrait_id.begins_with(key + "_"):
			var info = PERSON_INFO[key].duplicate()
			if LocaleManager.is_english() and PERSON_NAMES_EN.has(key):
				info["name"] = PERSON_NAMES_EN[key]
			# {name} 치환
			if info.get("name", "") == "{name}":
				var pname := str(GameState.player_name)
				if LocaleManager.is_english() and pname == LocaleManager.DEFAULT_NAME_KO:
					pname = LocaleManager.DEFAULT_NAME_EN
				info["name"] = pname
			return info
	return {}
