extends Node
## L2 only: exercise the real StoryMode node for exact authored
## location moves. This is deterministic regression evidence, never a
## substitute for the required normal-speed human M49-M60 replays.

const QA_PREFIX := "GangnamDream_StoryNameplateQA_"
const CHAPTER5_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const FULL_STORY_FLOW := preload("res://systems/FullStoryFlow.gd")
const BURNOUT_PRIOR_CHOICES := [2, 1, 0, 1]
const W202_EVENT := "callback_daeun_committed_gangnam_eve"
const W4_EVENT := "arc_temptation_01"
const W4_ROOM := "goshiwon_room"
const M07_HYUNSU_RESULT := "hyunsu_result_fail"
const M07_HALL := "goshiwon_hallway"
const M07_BASIN := "goshiwon_shared_washbasin"
const M07_EXAM_ROOM := "hyunsu_exam_room"
const M07_BASIN_WORDS := {
	"ko": "공용 세면대", "en": "the shared sink", "ja": "共用の洗面台",
	"zh-CN": "公共洗手台", "zh-TW": "公共洗手台",
}
const M07_RETURN_WORDS := {
	"ko": "물소리가 멎은 뒤", "en": "When the water stopped", "ja": "水音が止んだあと",
	"zh-CN": "水声停了", "zh-TW": "水聲停下後",
}
const W48_YEAR_CLOSE := "arc_year1_close"
const W48_YEAR_CLOSE_PASSED := "arc_year1_close_father_passed"
const W48_GOSHIWON := "goshiwon_room"
const W45_DECEMBER := "story_one_year"
const W53_NETWORK := "arc_sangchul_03_network"
const W53_DINING := "sangchul_private_dining"
const W57_MEDICATION := "arc_father_medication"
const W72_DINNER := "arc_sangchul_human"
const W69_STORE := "arc_year_one_half"
const W69_INSIDE := "convenience_night_dry"
const W69_STEPS := "convenience_night_steps"
const W82_BUS := "arc_y2_hyunsu_night_bus"
const W82_TERMINAL := "seoul_bus_terminal_night"
const W82_DEPARTURE := "seoul_bus_terminal_departure"
const W82_CUT_SENTENCES := [
	["터미널 불빛 아래서", "Under the terminal lights", "ターミナルの明かりの下で", "车站灯光下", "轉運站的燈光下"],
	["전화를 끊고", "He hung up", "電話を切って", "挂掉电话", "掛掉電話"],
]
const W57_VIBRATION := "arc_father_medication::description:0:0:phone_vibrate"
const W57_PASSAGE := "seoul_subway_transfer_passage"
const W57_CAR := "seoul_subway_commuters_w57"
const W57_GATE := "changwon_station_arrival_gate"
const W57_TABLE := "changwon_home_medication_table"
const W57_GATE_START := {
	"ko": "주말에 도착했을 때", "en": "When {name} arrives that weekend,",
	"ja": "週末、到着すると、", "zh-CN": "周末到了，", "zh-TW": "週末抵達時，",
}
const W57_CAR_START := {
	"ko": "두 정거장을 지나는 동안", "en": "Two stops later,",
	"ja": "二駅過ぎる間に", "zh-CN": "经过两站，", "zh-TW": "經過兩站的時間裡，",
}
const HYUNSU_CALL := "arc_hyunsu_new_path"
const HYUNSU_KEYBOARD := "keyboard_phone"
const HYUNSU_INTRO_CUE := "arc_hyunsu_new_path::description:2:0:keyboard_phone"
const HYUNSU_RESULT_CUE := "arc_hyunsu_new_path::result:1:1:0:keyboard_phone"
const W37_FIRST_BILL := "arc_y1_new_room_first_month"
const DAEUN_AFTERNOON := "arc_daeun_02_regular"
const DAEUN_EMPTY_STORE := "arc_daeun_02b_dream"
const DAEUN_RESULT_CGS := ["cg_daeun_regular_bunsik", "cg_daeun_regular_walk", "cg_daeun_regular_night_wait"]
const DAEUN_NIGHT_WAIT_ASSET := "res://assets/cg/romance/daeun_regular_night_wait_v2.png"
const FULL_CHAPTER_WEEKS := {"chapter_card_33": 1, "chapter_card_34": 49, "chapter_card_35": 97,
	"chapter_card_36": 145, "chapter_card_37": 193}
const M03_EVENT := "arc_jiyeon_01_crash"
const M03_APPROACH := "sinchon_crash_approach_rain_dusk"
const M03_IMPACT := "sinchon_crash_impact_rain_dusk"
const M03_EXIT := "sinchon_crash_exit_rain_dusk"
const REUNION := "arc_jiyeon_02_store"
const REUNION_STOP := "sinchon_bus_stop_after_rain_night"
const REUNION_SEDAN := "sinchon_bus_stop_sedan_night"
const REUNION_HEADLIGHTS := "sinchon_bus_stop_distant_bus_night"
const OFFER := "arc_jiyeon_03_offer"
const OFFER_STOP := "sinchon_main_road_bus_stop_rain_overcast"
const OFFER_SEDAN := "sinchon_offer_sedan_rain"
const OFFER_STATION := "sinchon_offer_station_approach_rain"
const OFFER_CAFE := "sinchon_offer_cafe_two_coffees"
const OFFER_UMBRELLA := "jiyeon_offer_umbrella"
const OFFER_FOLLOW_UP := "callback_jiyeon_honest_referral"
const OFFER_BRANCH_FLAGS := ["jiyeon_refused_coffee", "jiyeon_had_coffee", "jiyeon_honest"]
const M23_PARENTS := "arc_34_parents_visit"
const M23_CALL := "arc_father_03_hospital"
const W96_VISIT := "arc_father_04_visit"
const W96_HOSPITAL := "hospital"
const W96_STICKER := "seoul_station_visitor_sticker"
const W96_YEAR_CLOSE := "arc_year2_close"
const W100_DOCUMENT := "arc_y3_father_avoidance_document"
const W100_CONTACT_FLAGS := ["y3_father_avoidance_voicemail", "y3_father_avoidance_source_message", "y3_father_avoidance_scheduled_call"]
const W112_PHONE := "arc_y3_father_deferred_call"
const W112_ANSWER := {"ko": "세 번째 신호에 아버지가 받았다.", "en": "Father answered on the third ring.",
	"ja": "三度目の呼び出し音で父が出た。", "zh-CN": "第三声铃，父亲接了。", "zh-TW": "第三聲鈴響，父親接了。"}
const M27_PITCH := "arc_jaehyuk_03_pitch"
const M27_FLAGS := ["jaehyuk_trusted_fully", "jaehyuk_partial", "jaehyuk_refused"]
const M27_HOME := {"ko": "그리고 집에 와서 검색을 시작했다.", "en": "Back home, he starts searching.",
	"ja": "そして家に帰り、検索を始めた。", "zh-CN": "回家后，开始搜索。", "zh-TW": "接著，回到家開始搜尋。"}
const W108_WARNING := "arc_jaehyuk_hyunsu_warning"
const W116_GHOST := "arc_jaehyuk_04a_ghost"
const W116_CHILDREN := ["arc_jaehyuk_ghost_read", "arc_jaehyuk_ghost_message"]
const W116_DECISION := "arc_jaehyuk_ghost_decision"
const W116_PHOTO := "arc_jaehyuk_photo_in_dark"
const W116_ARTIFACT := "artifact_jaehyuk_photo"
const W116_AFTERMATH := "arc_jaehyuk_aftermath"
const W117_COUNTER := "arc_jaehyuk_04b_counter"
const W117_POLICE := "police_evidence_reception"
const W117_ARREST := {"ko": "재혁은 구속됐다.", "en": "Jaehyuk was arrested.",
	"ja": "ジェヒョクは身柄を拘束された。", "zh-CN": "Jaehyuk 被羁押了。", "zh-TW": "Jaehyuk 遭到羈押。"}
const W108_CONTACT := {
	"ko": ["메시지", "통화 중"], "en": ["MESSAGE", "VOICE CALL"], "ja": ["メッセージ", "通話中"],
	"zh-CN": ["消息", "通话中"], "zh-TW": ["訊息", "通話中"],
}
const W96_ARRIVAL := {
	"ko": "서울역에 내려", "en": "At Seoul Station,", "ja": "ソウル駅で降り",
	"zh-CN": "到了首尔站", "zh-TW": "在首爾站下車",
}
# Baseline from 6f1a763, before the isolated closing-sentence revision. The
# hashes authenticate the whole old raw source, not just the replaced suffix.
const W96_PRE_REVISION := {
	"ko": ["열지 않은 문은 {name}이 고른 채로 남았다.", "병실 문 앞에서 돌아선 사람은 {name}이었다.",
		"2eedebc512bf29ca530d8c3e5601992cfef0e9d45c1e6eca54258b57e913e6a2"],
	"en": ["The unopened door remained his choice.", "He had chosen not to go into the room.",
		"d2cbc00e8b9a6f61d26ece29f02296e0c05128c2d1033a4f5fb0d7a672cbea55"],
	"ja": ["開けなかったドアは、{name}が選んだまま残った。", "病室のドアの前で引き返したのは、{name}だった。",
		"305c4a037eef2f95385790dde1118cee1821ca46c26a08f23452c353488eb020"],
	"zh-CN": ["那扇没开的门，留下来，是{name}自己选的。", "是{name}自己在那间病房的门口转身离开的。",
		"111754333e420ff9a64e54610f590a0289339e36d3ab3480404a25a1947bcf9b"],
	"zh-TW": ["那扇沒開的門，留下了{name}自己的選擇。", "是{name}自己從那間病房門口轉身離開的。",
		"ae2e862275aa13e60e9751cd9130ad07670c7ecba5be5416b21b7a41add41f75"],
}
const M23_KTX_STATION := "seoul_station_first_ktx_predawn"
const M23_KTX_COACH := "ktx_changwon_first_train_predawn"
const M23_KTX_ANCHORS := {
	"ko": ["새벽 다섯 시 서울역.", "기차 안에서"],
	"en": ["5 a.m. from Seoul Station.", "On the train"],
	"ja": ["明け方五時、ソウル駅。", "列車の中で"],
	"zh-CN": ["凌晨五点，首尔站。", "在列车上"],
	"zh-TW": ["凌晨五點，首爾站。", "在列車上"],
}
const M23_CONCOURSE := "seoul_station_parents_concourse"
const M23_GATE := "seoul_station_parents_ticket_gate"
const M23_BAG := "parents_visit_food_bag_in_transit"
const M23_RESTAURANT := "restaurant"
const M23_HOME := "current_housing"
const M23_HOUSING := ["gosiwon", "oneroom", "apartment"]
const M23_CUT_ANCHORS := {
	"ko": ["{name}은 방에 널린 빨래를", "이동하는 동안"],
	"en": ["{name} pushes the laundry", "Mother keeps the side-dish bag"],
	"ja": ["{name}は部屋に散らばった洗濯物を", "移動の間"],
	"zh-CN": ["{name}把房里散着的衣服", "路上，母亲"],
	"zh-TW": ["{name}把散在房裡的衣物", "路上，母親"],
}
const W4_DEMO := preload("res://playtests/order124/StoryChoiceM1M6Playtest.gd")
const W4_TERMS := {
	"ko": ["한 시간 뒤 같은 보관함", "방으로 돌아온"],
	"en": ["He opened the locker again an hour later", "Back in the room,"],
	"ja": ["一時間後、同じロッカーには", "部屋に戻った"],
	"zh-CN": ["一小时后，同一个储物柜里", "回到房间，"],
	"zh-TW": ["一小時後，同一個置物櫃裡", "回到房間，"],
}
const W8_EVENT := "arc_temptation_fallout"
const W8_QA_SLOT := 9
const W8_BANK := "bank_service_counter_rainy_day"
const W8_BANK_EXIT := "bank_exterior_wet_day"
const W8_LOCKERS := "subway_station_coin_lockers"
const M14_BANK := "arc_y2_bank_limit_review"
const M14_COUNTER := "bank_loan_counter_day"
const M14_EXIT := "bank_loan_exit_day"
const W234_SUMMIT := "arc_y5_general_pre_ending_summit_exact"
const W234_OFFICE := "realestate_office"
const W234_BOULEVARD := "gangnam_boulevard_winter_dusk"
const W234_DOOR := {
	"ko": "유리문이 등 뒤에서", "en": "The glass door eased shut", "ja": "背後でガラス戸が",
	"zh-CN": "玻璃门在背后", "zh-TW": "玻璃門在背後",
}
const M14_EXIT_LINE := {
	"ko": "문을 나설 때", "en": "He left with a document", "ja": "外へ出るとき",
	"zh-CN": "走出门时", "zh-TW": "走出銀行時",
}
const W8_ARRIVAL_TEXT := {
	"ko": ["은행을 나서자", "사흘 뒤"],
	"en": ["Outside the bank,", "Three days later,"],
	"ja": ["銀行を出ると、", "三日後、"],
	"zh-CN": ["走出银行时，", "三天后，"],
	"zh-TW": ["走出銀行時，", "三天後，"],
}
const CASES := [
	{
		"id": "arc_y5_burnout_check_reference",
		"root": "hospital_clinic_day",
		"root_ambience": "hospital",
		"results": ["hospital_clinic_day", "hospital_clinic_day", "hospital_clinic_day"],
		"result_ambience": ["hospital", "hospital", "hospital"],
	},
	{
		"id": "rare_wallet_executive",
		"root": "subway_station_stairs",
		"root_ambience": "subway",
		"results": ["subway_station_lost_found", "subway_station_stairs"],
		"result_ambience": ["subway", "subway"],
	},
	{
		"id": "chain_exec_meal_arrival",
		"root": "hanjeongsik_restaurant_day",
		"root_ambience": "cafe",
		"results": ["hanjeongsik_restaurant_day", "hanjeongsik_restaurant_day"],
		"result_ambience": ["cafe", "cafe"],
	},
	{
		"id": "arc_jiyeon_year5_news",
		"root": "hanjeongsik_restaurant_day",
		"root_ambience": "cafe",
		"results": ["hanjeongsik_restaurant_day", "street"],
		"result_ambience": ["cafe", "street"],
	},
	{
		"id": "yolo_spend_moment",
		"root": "convenience_store",
		"root_ambience": "convenience",
		"results": ["concert_hall_night", "convenience_store", "concert_hall_night"],
		"result_ambience": ["amusement", "convenience", "amusement"],
	},
	{
		"id": "chain_envelope_owner_return",
		"root": "convenience_night",
		"root_ambience": "convenience",
		"results": ["villa_renovation_day", "convenience_night"],
		"result_ambience": ["street", "convenience"],
	},
	{
		"id": "hidden_gangnam_open_house",
		"root": "gangnam_apartment",
		"root_ambience": "apartment",
		"results": ["current_housing", "subway"],
		"result_ambience": ["apartment", "subway"],
	},
	{
		"id": W202_EVENT, "turn": 202,
		"root": "current_housing",
		"root_ambience": "oneroom",
		"results": ["gukbap_restaurant_night", "current_housing"],
		"result_ambience": ["", "oneroom"],
	},
	{
		"id": "cafe_00", "turn": 6,
		"root": "cafe", "root_ambience": "cafe",
		"results": ["cafe", "cafe", "street_rainy"],
		"result_ambience": ["cafe", "cafe", "rain"],
	},
	{
		"id": "cafe_bluff_caught", "turn": 6,
		"auto_single_choice": true,
		"root": "cafe", "root_ambience": "cafe",
		"results": ["street_rainy"], "result_ambience": ["rain"],
	},
	{
		"id": "cafe_mind_01", "turn": 6,
		"root": "cafe", "root_ambience": "cafe",
		"results": ["cafe", "street_rainy"], "result_ambience": ["cafe", "rain"],
	},
]

const EXACT_PATHS := {
	W82_TERMINAL: "res://assets/backgrounds/seoul_bus_terminal_night.png",
	W82_DEPARTURE: "res://assets/backgrounds/seoul_bus_terminal_departure_v1.png",
	W69_INSIDE: "res://assets/backgrounds/convenience_store_night_dry_v1.png",
	W69_STEPS: "res://assets/backgrounds/convenience_store_night_steps_v1.png",
	W57_PASSAGE: "res://assets/backgrounds/seoul_subway_transfer_passage_v1.png",
	W57_CAR: "res://assets/backgrounds/seoul_subway_commuters_w57_v1.png",
	W57_GATE: "res://assets/backgrounds/changwon_station_arrival_gate_v1.png",
	W57_TABLE: "res://assets/backgrounds/changwon_home_medication_table_v1.png",
	W53_DINING: "res://assets/backgrounds/sangchul_private_dining.png",
	W234_OFFICE: "res://assets/backgrounds/realestate_office.png",
	W234_BOULEVARD: "res://assets/backgrounds/gangnam_boulevard_winter_dusk.png",
	W4_ROOM: "res://assets/backgrounds/goshiwon_room.png",
	M07_HALL: "res://assets/backgrounds/goshiwon_hallway.png",
	M07_BASIN: "res://assets/backgrounds/goshiwon_shared_washbasin_v1.png",
	M07_EXAM_ROOM: "res://assets/backgrounds/hyunsu_exam_room_v2.png",
	OFFER_STOP: "res://assets/backgrounds/sinchon_main_road_bus_stop_rain_overcast.png",
	OFFER_SEDAN: "res://assets/backgrounds/sinchon_offer_sedan_rain.png",
	OFFER_STATION: "res://assets/backgrounds/sinchon_offer_station_approach_rain.png",
	OFFER_CAFE: "res://assets/backgrounds/sinchon_offer_cafe_two_coffees.png",
	M23_CONCOURSE: "res://assets/backgrounds/seoul_station_parents_concourse.png",
	M23_GATE: "res://assets/backgrounds/seoul_station_parents_ticket_gate.png",
	M23_BAG: "res://assets/backgrounds/parents_visit_food_bag_in_transit.png",
	M23_RESTAURANT: "res://assets/backgrounds/restaurant_korean.png",
	M23_KTX_STATION: "res://assets/backgrounds/seoul_station_first_ktx_predawn.png",
	M23_KTX_COACH: "res://assets/backgrounds/ktx_changwon_first_train_predawn.png",
	W96_HOSPITAL: "res://assets/backgrounds/hospital_corridor.png",
	W96_STICKER: "res://assets/backgrounds/seoul_station_visitor_sticker.png",
	"hospital_clinic_day": "res://assets/backgrounds/hospital_clinic_day.png",
	"subway_station_stairs": "res://assets/backgrounds/subway_station_stairs.png",
	"subway_station_lost_found": "res://assets/backgrounds/subway_station_lost_found.png",
	"hanjeongsik_restaurant_day": "res://assets/backgrounds/hanjeongsik_restaurant_day.png",
	"concert_hall_night": "res://assets/backgrounds/concert_hall_night.png",
	"villa_renovation_day": "res://assets/backgrounds/villa_renovation_day.png",
	"convenience_store": "res://assets/backgrounds/convenience_store_night_v2.png",
	"convenience_night": "res://assets/backgrounds/convenience_store_night_v2.png",
	"street": "res://assets/backgrounds/street_seoul_day.png",
	"street_rainy": "res://assets/backgrounds/seoul_rainy_street.png",
	W8_BANK: "res://assets/backgrounds/bank_service_counter_rainy_day.png",
	W8_BANK_EXIT: "res://assets/backgrounds/bank_exterior_wet_day.png",
	W8_LOCKERS: "res://assets/backgrounds/subway_station_coin_lockers.png",
	M14_COUNTER: "res://assets/backgrounds/bank_loan_counter_day.png",
	M14_EXIT: "res://assets/backgrounds/bank_loan_exit_day.png",
	"cafe": "res://assets/backgrounds/cafe_seoul.png",
	"meeting": "res://assets/backgrounds/investment_meeting.png",
	W117_POLICE: "res://assets/backgrounds/police_evidence_reception.png",
	"gangnam_apartment": "res://assets/backgrounds/gangnam_apartment.png",
	"apartment": "res://assets/backgrounds/oneroom_apartment.png",
	"gukbap_restaurant_night": "res://assets/backgrounds/gukbap_restaurant_night.png",
	"subway": "res://assets/backgrounds/seoul_subway.png",
}

var _story: Control
var _failures := 0
var _cases := 0
var _intro_pages := 0
var _result_pages := 0
var _w8_cases := 0
var _w8_pages := 0
var _w4_cases := 0
var _w4_reloads := 0
var _w4_rebinds := 0
var _w4_capture_dir := ""
var _w234_cases := 0
var _w234_reloads := 0
var _w234_capture_dir := ""
var _m14_cases := 0
var _m14_capture_dir := ""
var _w8_reloads := 0
var _w8_language_switches := 0
var _w202_silent_results := 0
var _context := "bootstrap"
var _w8_capture_dir := ""
var _w8_capture_start_msec := 0
var _w8_capture_shots := 0
var _offer_capture_dir := ""
var _m23_capture_dir := ""
var _first_ktx_capture_dir := ""
var _w96_capture_dir := ""
var _w112_capture_dir := ""
var _w117_capture_dir := ""

func _ready() -> void:
	Engine.max_fps = 60
	var bootstrap_script := get_tree().get_script() as Script
	if bootstrap_script == null \
			or bootstrap_script.resource_path != "res://tools/StoryNameplateBootstrap.gd":
		_fail("exact pre-autoload isolation bootstrap required")
		get_tree().quit(1)
		return
	var qa_namespace := str(ProjectSettings.get_setting(
		"application/config/custom_user_dir_name", ""))
	if not bool(ProjectSettings.get_setting(
			"application/config/use_custom_user_dir", false)) \
			or not qa_namespace.begins_with(QA_PREFIX) \
			or not OS.get_user_data_dir().ends_with(qa_namespace):
		_fail("isolated QA user directory was not selected before autoloads")
		get_tree().quit(1)
		return
	print("STORY_NAMEPLATE_QA_USER_DIR=%s" % OS.get_user_data_dir())
	print("STORY_BACKGROUND_CONTEXT_SOURCE=%s" % ProjectSettings.globalize_path("res://"))
	await get_tree().process_frame
	SaveManager.set_setting("story_text_size", "standard")
	if OS.has_environment("GANGNAM_W82_BUS_CHECK"):
		var bus_ok := await _check_w82_bus()
		await _remove_story()
		await _stop_audio()
		if bus_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w82_bus")
		get_tree().quit(0 if bus_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W69_STEPS_CHECK"):
		var steps_ok := await _check_w69_steps()
		await _remove_story()
		await _stop_audio()
		if steps_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w69_steps")
		get_tree().quit(0 if steps_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W72_DINNER_CHECK"):
		var dinner_ok := await _check_w72_dinner_audio()
		await _remove_story()
		await _stop_audio()
		if dinner_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w72_dinner_audio")
		get_tree().quit(0 if dinner_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W57_MESSAGE_CHECK"):
		var message_ok := await _check_w57_message_audio()
		await _remove_story()
		await _stop_audio()
		if message_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w57_message_audio")
		get_tree().quit(0 if message_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W53_DINING_CHECK"):
		var dining_ok := await _check_w53_dining_audio()
		await _remove_story()
		await _stop_audio()
		if dining_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w53_dining_audio")
		get_tree().quit(0 if dining_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W45_HOME_CHECK"):
		var december_ok := await _check_w45_december_home()
		await _remove_story()
		await _stop_audio()
		if december_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w45_home")
		get_tree().quit(0 if december_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W48_LIGHTS_OUT_CHECK"):
		var lights_ok := await _check_w48_lights_out()
		await _remove_story()
		await _stop_audio()
		if lights_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w48_lights_out locales=5 roots=2 choices=3")
		get_tree().quit(0 if lights_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_M07_WASHBASIN_CHECK"):
		var basin_ok := await _check_m07_washbasin()
		await _remove_story()
		await _stop_audio()
		if basin_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=m07_washbasin locales=5 choices=2")
		get_tree().quit(0 if basin_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W41_CALL_CHECK"):
		var call_ok := await _check_hyunsu_call()
		if call_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w40_w41_hyunsu_call")
		get_tree().quit(0 if call_ok else 1)
		return
	if OS.has_environment("GANGNAM_W19_REUNION_CHECK"):
		var w19_ok := await _check_w19_reunion()
		if w19_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w19_reunion")
		get_tree().quit(0 if w19_ok else 1)
		return
	if OS.has_environment("GANGNAM_FULL_CHAPTER_CARD_CHECK"):
		var cards_ok := await _check_full_chapter_card_ambience()
		if cards_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=full_chapter_cards")
		get_tree().quit(0 if cards_ok else 1)
		return
	if OS.has_environment("GANGNAM_W37_ROOM_CHECK"):
		var w37_ok := await _check_w37_first_bill()
		if w37_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w37_first_bill")
		get_tree().quit(0 if w37_ok else 1)
		return
	if OS.has_environment("GANGNAM_DAEUN_STORE_AUDIO_CHECK"):
		var dry_capture_dir := OS.get_environment("GANGNAM_DAEUN_DRY_CAPTURE_DIR")
		var daeun_ok := await _check_daeun_store_audio(not dry_capture_dir.is_empty(), dry_capture_dir)
		if daeun_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=daeun_store")
		get_tree().quit(0 if daeun_ok else 1)
		return
	if OS.has_environment("GANGNAM_W117_COUNTER_CHECK"):
		var w117_ok := await _check_w117_counter()
		if w117_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w117_counter")
		get_tree().quit(0 if w117_ok else 1)
		return
	if OS.has_environment("GANGNAM_W116_GHOST_CHECK"):
		var w116_ok := await _check_w116_ghost()
		if w116_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w116_ghost")
		get_tree().quit(0 if w116_ok else 1)
		return
	if OS.has_environment("GANGNAM_W108_WARNING_CHECK"):
		var w108_ok := await _check_w108_warning()
		if w108_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w108_warning")
		get_tree().quit(0 if w108_ok else 1)
		return
	if OS.has_environment("GANGNAM_M27_PITCH_CHECK"):
		var m27_ok := await _check_m27_pitch()
		if m27_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=m27_pitch")
		get_tree().quit(0 if m27_ok else 1)
		return
	if OS.has_environment("GANGNAM_W112_PHONE_CHECK"):
		var w112_ok := await _check_w112_phone()
		if w112_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w112_phone")
		get_tree().quit(0 if w112_ok else 1)
		return
	if OS.has_environment("GANGNAM_W100_DOCUMENT_CHECK"):
		var w100_ok := await _check_w100_document()
		if w100_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w100_document")
		get_tree().quit(0 if w100_ok else 1)
		return
	if OS.has_environment("GANGNAM_W96_RETURN_CHECK"):
		var w96_ok := await _check_w96_return()
		if w96_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w96_return")
		get_tree().quit(0 if w96_ok else 1)
		return
	if OS.has_environment("GANGNAM_FIRST_KTX_CHECK"):
		var ktx_ok := await _check_first_ktx()
		if ktx_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=first_ktx")
		get_tree().quit(0 if ktx_ok else 1)
		return
	if OS.has_environment("GANGNAM_M23_PARENTS_CHECK"):
		var m23_ok := await _check_m23_parents()
		if m23_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=m23_parents")
		get_tree().quit(0 if m23_ok else 1)
		return
	if OS.has_environment("GANGNAM_SINCHON_OFFER_CHECK"):
		var offer_ok := await _check_sinchon_offer()
		if offer_ok:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=sinchon_offer")
		get_tree().quit(0 if offer_ok else 1)
		return
	if OS.has_environment("GANGNAM_SINCHON_REUNION_CHECK"):
		await _check_sinchon_reunion()
		return
	if OS.has_environment("GANGNAM_M03_CHECK"):
		await _check_m03_crash()
		return
	if OS.has_environment("GANGNAM_W234_CAPTURE_DIR"):
		await _capture_w234()
		return
	if OS.has_environment("GANGNAM_W4_CAPTURE_DIR"):
		await _capture_w4()
		return
	if OS.has_environment("GANGNAM_W8_CAPTURE_DIR"):
		await _capture_w8()
		return
	if OS.has_environment("GANGNAM_M14_BANK_CAPTURE_DIR"):
		await _capture_m14_bank()
		return
	for language in ["ko", "en"]:
		LocaleManager.set_language(language)
		for fixture_variant in CASES:
			var fixture: Dictionary = fixture_variant
			var results: Array = fixture["results"]
			for choice_index in range(results.size()):
				await _play_case(language, fixture, choice_index)
	for language in W8_ARRIVAL_TEXT:
		LocaleManager.set_language(language)
		for choice_index in range(2):
			await _play_w8_case(language, choice_index)
		for choice_index in range(3):
			await _play_m14_bank_case(language, choice_index)
	for language in W4_TERMS:
		LocaleManager.set_language(language)
		for choice_index in range(2):
			await _play_w4_case(language, choice_index, false)
		for choice_index in range(2):
			await _play_w4_case(language, choice_index, true)
		for choice_index in range(2):
			await _play_w234_case(language, choice_index)
	if not await _check_first_ktx(true):
		_fail("first KTX default full-owner smoke failed")
	if not await _check_w96_return(true):
		_fail("W96 default full-owner smoke failed")
	if not await _check_daeun_store_audio(true):
		_fail("Daeun store default full-owner smoke failed")
	if not await _check_hyunsu_call(true):
		_fail("Hyunsu call default full-owner smoke failed")
	if not await _check_m07_washbasin(true):
		_fail("M07 washbasin regression smoke failed")
	if not await _check_w48_lights_out(true):
		_fail("W48 lights-out regression smoke failed")
	if not await _check_w45_december_home(true):
		_fail("W45 quiet home regression smoke failed")
	if not await _check_w53_dining_audio(true):
		_fail("W53 dining audio regression smoke failed")
	if not await _check_w57_message_audio(true):
		_fail("W57 medication message audio regression smoke failed")
	if not await _check_w72_dinner_audio(true):
		_fail("W72 dinner audio regression smoke failed")
	if not await _check_w69_steps(true):
		_fail("W69 steps regression smoke failed")
	if not await _check_w82_bus(true):
		_fail("W82 bus regression smoke failed")
	await _remove_story()
	await _stop_audio()
	if _cases != 48 or _intro_pages < 48 or _result_pages < 48:
		_fail("fixture inventory incomplete cases=%d intro_pages=%d result_pages=%d" % [
			_cases, _intro_pages, _result_pages])
	if _w8_cases != 10 or _w8_pages < 30 or _w8_reloads != 10 \
			or _w8_language_switches != 8:
		_fail("W8 fixture inventory incomplete cases=%d pages=%d reloads=%d language_switches=%d" % [
			_w8_cases, _w8_pages, _w8_reloads, _w8_language_switches])
	if _w202_silent_results != 2:
		_fail("W202 quiet result inventory incomplete: %d" % _w202_silent_results)
	if _m14_cases != 15:
		_fail("M14 bank branch inventory incomplete: %d" % _m14_cases)
	if _w4_cases != 20 or _w4_reloads != 15 or _w4_rebinds != 4:
		_fail("W4 inventory incomplete paths=%d restores=%d rebinds=%d" % [
			_w4_cases, _w4_reloads, _w4_rebinds])
	if _w234_cases != 10 or _w234_reloads != 2:
		_fail("W234 required five locales with both exits and two cold checks, got %d/%d" % [
			_w234_cases, _w234_reloads])
	if _failures > 0:
		print("STORY_BACKGROUND_CONTEXT_CHECK_FAIL failures=%d cases=%d intro_pages=%d result_pages=%d" % [
			_failures, _cases, _intro_pages, _result_pages])
		get_tree().quit(1)
		return
	print("STORY_BACKGROUND_CONTEXT_W8_OK cases=%d pages=%d cold_cut_reloads=%d language_switches=%d" % [
		_w8_cases, _w8_pages, _w8_reloads, _w8_language_switches])
	print("STORY_BACKGROUND_CONTEXT_W202_OK silent_results=%d shared_profile_unchanged=1" % _w202_silent_results)
	print("STORY_BACKGROUND_CONTEXT_M14_OK cases=%d exact_exit=1 clean_beds=1" % _m14_cases)
	print("STORY_BACKGROUND_CONTEXT_W4_OK paths=%d restores=%d rebinds=%d" % [
		_w4_cases, _w4_reloads, _w4_rebinds])
	print("STORY_BACKGROUND_CONTEXT_W234_OK paths=%d cold_exits=%d" % [_w234_cases, _w234_reloads])
	print("STORY_BACKGROUND_CONTEXT_CHECK_OK cases=%d intro_pages=%d result_pages=%d ko_en=1 choices=all live_storymode=1 settled_texture=1 ambience=1 human_gate=OPEN" % [
		_cases, _intro_pages, _result_pages])
	get_tree().quit(0)

func _capture_w8() -> void:
	_w8_capture_dir = OS.get_environment("GANGNAM_W8_CAPTURE_DIR")
	var language := OS.get_environment("GANGNAM_W8_CAPTURE_LANGUAGE")
	var output := DirAccess.open(_w8_capture_dir) if _w8_capture_dir.is_absolute_path() else null
	if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
			or language not in ["ko", "en"] or DisplayServer.get_name() == "headless":
		_fail("W8 capture requires a fresh absolute output, KO/EN and a real display")
		get_tree().quit(1)
		return
	OS.low_processor_usage_mode = false
	LocaleManager.set_language(language)
	var master_bus := AudioServer.get_bus_index("Master")
	# Godot 4.6.2's recorder exposes only its last effect instance. On a
	# surround bus this may be a silent rear pair, not the game's stereo mix.
	if master_bus < 0 or AudioServer.get_speaker_mode() != AudioServer.SPEAKER_MODE_STEREO:
		_fail("W8 recorder requires a stereo engine bus, got %s/%s" % [
			AudioServer.get_driver_name(), AudioServer.get_speaker_mode()])
		get_tree().quit(1)
		return
	for choice_index in range(2):
		await _remove_story()
		await _stop_audio()
		var record := AudioEffectRecord.new()
		var effect_index := AudioServer.get_bus_effect_count(master_bus)
		AudioServer.add_bus_effect(master_bus, record)
		_w8_capture_start_msec = Time.get_ticks_msec()
		record.set_recording_active(true)
		var previous_shots := _w8_capture_shots
		await _play_w8_case(language, choice_index)
		record.set_recording_active(false)
		var wav := record.get_recording()
		AudioServer.remove_bus_effect(master_bus, effect_index)
		var prefix := "%s_c%d" % [language, choice_index]
		if wav == null or wav.get_length() < 5.0 or not _w8_has_nonzero_pcm(wav.get_data()) \
				or wav.save_to_wav(_w8_capture_dir.path_join(prefix + "_master.wav")) != OK:
			_fail("W8 Master bus recording empty, short or unwritable: " + prefix)
		if _w8_capture_shots - previous_shots < 4:
			_fail("W8 capture missed a rendered boundary: " + prefix)
		for label in ["01_rain_call", "02_choices", "04_before_move", "05_after_move"]:
			if not FileAccess.file_exists(_w8_capture_dir.path_join("%s_%s.png" % [prefix, label])):
				_fail("W8 capture missed %s: %s" % [label, prefix])
		if _failures > 0:
			break
	await _remove_story()
	await _stop_audio()
	if _w8_cases != 2 or _w8_reloads != 0 or _w8_language_switches != 0:
		_fail("W8 capture must render two uninterrupted choices")
	if _failures == 0:
		print("W8_VIEWPORT_CAPTURE_OK language=%s paths=%d frames=%d audio=Master driver=%s" % [
			language, _w8_cases, _w8_capture_shots, AudioServer.get_driver_name()])
	get_tree().quit(0 if _failures == 0 else 1)

func _w8_has_nonzero_pcm(bytes: PackedByteArray) -> bool:
	for value in bytes:
		if value != 0:
			return true
	return false

func _mark_w8_capture(label: String) -> void:
	print("W8_CAPTURE %s t=%.3f %s" % [
		_context, float(Time.get_ticks_msec() - _w8_capture_start_msec) / 1000.0, label])

func _save_w8_capture(language: String, choice_index: int, label: String) -> void:
	var path := _w8_capture_dir.path_join("%s_c%d_%s.png" % [language, choice_index, label])
	if not await _save_viewport_frame(path):
		return
	_w8_capture_shots += 1
	_mark_w8_capture(label)

func _save_viewport_frame(path: String) -> bool:
	# Wait for the real post-draw buffer and discard the first OpenGL readback.
	for _draw in range(4):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var texture := get_viewport().get_texture()
	if texture == null:
		_fail("viewport has no render texture")
		return false
	var _prime_readback := texture.get_image()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var frame := texture.get_image()
	if frame == null or frame.is_empty() or frame.save_png(path) != OK:
		_fail("viewport capture failed: " + path)
		return false
	return true

func _capture_m14_bank() -> void:
	_m14_capture_dir = OS.get_environment("GANGNAM_M14_BANK_CAPTURE_DIR")
	var output := DirAccess.open(_m14_capture_dir) if _m14_capture_dir.is_absolute_path() else null
	var language := OS.get_environment("GANGNAM_M14_BANK_CAPTURE_LANGUAGE")
	if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
			or not M14_EXIT_LINE.has(language) or DisplayServer.get_name() == "headless":
		_fail("M14 capture requires a fresh absolute output, an authored locale and a real display")
		get_tree().quit(1)
		return
	if OS.get_environment("GANGNAM_M14_BANK_CAPTURE_COMPACT") == "1":
		DisplayServer.window_set_size(Vector2i(960, 600))
		await get_tree().process_frame
		if DisplayServer.window_get_size() != Vector2i(960, 600):
			_fail("M14 compact capture did not get a 960x600 window")
			get_tree().quit(1)
			return
	OS.low_processor_usage_mode = false
	LocaleManager.set_language(language)
	for choice_index in range(3):
		await _play_m14_bank_case(language, choice_index)
	await _remove_story()
	await _stop_audio()
	if _m14_cases != 3:
		_fail("one or more M14 branches were not captured")
	if _failures == 0:
		print("M14_BANK_VIEWPORT_OK language=%s paths=%d" % [language, _m14_cases])
	get_tree().quit(0 if _failures == 0 else 1)

func _capture_w4() -> void:
	_w4_capture_dir = OS.get_environment("GANGNAM_W4_CAPTURE_DIR")
	var output := DirAccess.open(_w4_capture_dir) if _w4_capture_dir.is_absolute_path() else null
	var language := OS.get_environment("GANGNAM_W4_CAPTURE_LANGUAGE")
	if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
			or not W4_TERMS.has(language) or DisplayServer.get_name() == "headless":
		_fail("W4 capture requires a fresh absolute output, authored locale and a real display")
		get_tree().quit(1)
		return
	OS.low_processor_usage_mode = false
	# The receipt-bearing M01 source drives the same renderer as the full game.
	LocaleManager.set_language(language)
	await _play_w4_case(language, 1, true)
	await _remove_story()
	await _stop_audio()
	for name in ["01_room.png", "02_locker.png", "03_home.png"]:
		if not FileAccess.file_exists(_w4_capture_dir.path_join(name)):
			_fail("W4 viewport missing " + name)
	if _failures == 0 and _w4_cases == 1:
		print("W4_LOCKER_VIEWPORT_OK language=%s frames=3" % language)
	get_tree().quit(0 if _failures == 0 and _w4_cases == 1 else 1)

func _capture_w234() -> void:
	_w234_capture_dir = OS.get_environment("GANGNAM_W234_CAPTURE_DIR")
	var language := OS.get_environment("GANGNAM_W234_CAPTURE_LANGUAGE")
	var output := DirAccess.open(_w234_capture_dir) if _w234_capture_dir.is_absolute_path() else null
	if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
			or not W234_DOOR.has(language) or DisplayServer.get_name() == "headless":
		_fail("W234 capture requires a fresh output, authored locale and a real display")
		get_tree().quit(1)
		return
	OS.low_processor_usage_mode = false
	LocaleManager.set_language(language)
	for choice_index in range(2):
		await _play_w234_case(language, choice_index)
	await _remove_story()
	await _stop_audio()
	if _failures == 0 and _w234_cases == 2:
		print("W234_VIEWPORT_OK language=%s paths=2" % language)
	get_tree().quit(0 if _failures == 0 and _w234_cases == 2 else 1)

func _play_case(language: String, fixture: Dictionary, choice_index: int) -> void:
	await _remove_story()
	var event_id := str(fixture["id"])
	var w202_quiet_choice := event_id == W202_EVENT and choice_index == 0
	_context = "%s/%s/choice%d" % [language, event_id, choice_index]
	if not _seed_story(event_id, int(fixture.get("turn", 220))):
		return
	GameState.pending_story_queue = [event_id]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await _wait_stable()
	_story.call("_set_auto_mode", false, false, false)
	if str((_story.get("_current") as Dictionary).get("id", "")) != event_id \
			or bool(_story.get("_read_only_replay")):
		_fail("real StoryMode did not load the requested live root")
		return
	if not await _read_phase(str(fixture["root"]), str(fixture["root_ambience"]), false):
		return
	_story.call("_on_advance")
	await _wait_stable()
	if bool(fixture.get("auto_single_choice", false)):
		if choice_index != 0 or bool(_story.get("_showing_choices")):
			_fail("linear cafe exit did not advance without a redundant choice menu")
			return
	else:
		if not bool(_story.get("_showing_choices")):
			_fail("authored choices were not exposed after sequential intro")
			return
		if not _expect_surface(str(fixture["root"]), str(fixture["root_ambience"]), "choices"):
			return
		var visible: Array = _story.call("_visible_choice_indices", _story.get("_current"))
		if not visible.has(choice_index):
			_fail("target authored choice is not visible")
			return
		var music_key := str(BGMPlayer.get("_current_key"))
		if w202_quiet_choice and not _w202_prime_ambience_layers():
			return
		_story.call("_on_choice", choice_index)
		if w202_quiet_choice:
			if not _expect_no_ambience("W202 accepted result on the choice frame"):
				return
			if str(BGMPlayer.get("_current_key")) != music_key:
				_fail("W202 location silence changed the score")
				return
		await _wait_stable()
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index:
		_fail("actual choice did not enter its exact result phase")
		return
	var expected_results: Array = fixture["results"]
	var expected_ambiences: Array = fixture["result_ambience"]
	if not await _read_phase(
			str(expected_results[choice_index]),
			str(expected_ambiences[choice_index]), true):
		return
	if w202_quiet_choice:
		if not _expect_no_ambience("W202 accepted result after its final page"):
			return
		_w202_silent_results += 1
	if int(fixture.get("turn", 0)) == 6 and str(expected_results[choice_index]) == "street_rainy":
		var portrait_id := str(_story.call("_resolved_story_surface_portrait_id"))
		var human_layer := str(BGMPlayer.get("_current_human_ambience_key"))
		if portrait_id != "player_tired" or human_layer != "street":
			_fail("cafe exit retained the investor or cafe human layer")
			return
	_cases += 1

func _w202_prime_ambience_layers() -> bool:
	# Exercise the shared profile without changing the real root/defer evidence.
	# All three layers must be live before checking immediate—not faded—silence.
	BGMPlayer.update_event_ambience({}, "", "gukbap_restaurant_night")
	BGMPlayer.set_season_ambience("winter")
	if str(BGMPlayer.get("_current_ambience_key")) != "hoesik" \
			or str(BGMPlayer.get("_current_human_ambience_key")) != "cafe" \
			or str(BGMPlayer.get("_current_season_key")) != "winter":
		_fail("W202 shared restaurant profile or ambience fixture changed")
		return false
	for player_property in ["_ambience_player", "_human_ambience_player", "_season_player"]:
		var player := BGMPlayer.get(player_property) as AudioStreamPlayer
		if not is_instance_valid(player) or not player.playing:
			_fail("W202 did not start %s before the silence test" % player_property)
			return false
	return true

func _play_m14_bank_case(language: String, choice_index: int) -> void:
	await _remove_story()
	_context = "%s/%s/choice%d" % [language, M14_BANK, choice_index]
	_seed_story(M14_BANK, 53)
	GameState.age = 34
	GameState.year = 2027
	GameState.month = 2
	GameState.money = 750_000.0
	GameState.flags["arc_34_money_attracts_seen"] = true
	if not _w202_prime_ambience_layers():
		return
	GameState.pending_story_queue = [M14_BANK]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	if not _expect_no_ambience("M14 entry on the first frame"):
		return
	await _wait_stable()
	_story.call("_set_auto_mode", false, false, false)
	var current: Dictionary = _story.get("_current")
	if current.get("id") != M14_BANK or current.get("choices", []).size() != 3:
		_fail("M14 exact live bank root and three choices were not exposed")
		return
	for _page in range((_story.get("_paragraphs") as Array).size()):
		await _finish_page()
		if not _m14_expect_surface(false) or not _m14_expect_cues(choice_index, -1):
			return
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")) \
			or not _expect_surface(M14_COUNTER, "", "bank choice dock"):
		_fail("M14 choice dock did not remain at the counter")
		return
	if not _m14_capture_dir.is_empty():
		# The choice group's entrance tween is separate from the ink tween.
		await get_tree().create_timer(0.40).timeout
		if not await _save_viewport_frame(_m14_capture_dir.path_join("c%d_choices.png" % choice_index)):
			return
	var initial_money := float(GameState.money)
	var initial_receipts := GameState.event_log.size()
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	if not bool(_story.get("_pending_after_result")) \
			or not GameState.flags.get("arc_y2_bank_limit_review_seen", false) \
			or not is_equal_approx(GameState.money, initial_money) \
			or GameState.event_log.size() != initial_receipts + 1:
		_fail("M14 choice must create one receipt, no money and retain the outcome flag")
		return
	var pages: Array = _story.get("_paragraphs")
	var saw_exit_line := false
	for page_index in range(pages.size()):
		var source_index := int(_story.call("_story_source_paragraph_index", page_index))
		var exterior := choice_index == 2 and source_index == 1
		if str(pages[page_index]).contains(str(M14_EXIT_LINE[language])):
			if not exterior:
				_fail("M14 departure narration did not own the exit cut")
				return
			saw_exit_line = true
		if not _m14_expect_surface(exterior) or not _m14_expect_cues(choice_index, source_index):
			return
		await _finish_page()
		if not _m14_capture_dir.is_empty() and not await _save_viewport_frame(
				_m14_capture_dir.path_join("c%d_result_%d_%s.png" % [
					choice_index, page_index, "exit" if exterior else "counter"])):
			return
		if page_index < pages.size() - 1:
			_story.call("_on_advance")
			await _wait_stable()
	if saw_exit_line != (choice_index == 2):
		_fail("M14 translated departure line missing or appeared on another choice")
		return
	_m14_cases += 1

func _m14_expect_surface(exterior: bool) -> bool:
	if str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not str(BGMPlayer.get("_current_key")).is_empty():
		_fail("M14 bank scene acquired precipitation or an unrelated score")
		return false
	return _expect_surface(M14_EXIT if exterior else M14_COUNTER, "", "bank surface") \
		and _expect_no_ambience("M14 must not inherit people or weather")

func _m14_expect_cues(choice: int, source: int) -> bool:
	var expected: Array[String] = []
	if choice == 0 and source >= 0:
		expected.append(M14_BANK + "::result:0:0:0:paper_handle")
	elif choice == 1 and source >= 1:
		expected.append(M14_BANK + "::result:1:1:0:paper_handle")
	elif choice == 2 and source >= 0:
		expected.append(M14_BANK + "::result:2:0:0:pen_write")
		if source >= 1:
			expected.append(M14_BANK + "::result:2:1:0:traffic_pass")
	var observed: Array[String] = []
	for raw in AudioManager._story_audio_seen:
		if str(raw).begins_with(M14_BANK + ":"):
			observed.append(str(raw))
	if observed != expected:
		_fail("M14 authored cue order expected=%s actual=%s" % [expected, observed])
		return false
	return true

func _check_m03_crash() -> void:
	var cases := 0
	var reloads := 0
	var demo := OS.has_environment("GANGNAM_M03_DEMO")
	var capture_dir := OS.get_environment("GANGNAM_M03_CAPTURE_DIR")
	var capture_language := OS.get_environment("GANGNAM_M03_CAPTURE_LANGUAGE")
	var languages := W4_TERMS.keys()
	if not capture_dir.is_empty():
		var output := DirAccess.open(capture_dir) if capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or not W4_TERMS.has(capture_language) or DisplayServer.get_name() == "headless":
			_fail("M03 capture requires a fresh absolute output, supported language and real display")
			get_tree().quit(1)
			return
		languages = [capture_language]
		OS.low_processor_usage_mode = false
	for language in languages:
		LocaleManager.set_language(language)
		for choice in range(3):
			await _remove_story()
			_context = "%s/M03/choice%d" % [language, choice]
			_seed_story(M03_EVENT, 9)
			GameState.age = 33
			GameState.month = 3
			GameState.money = 500_000.0
			# Exercise the default, shorter orthodox and unorthodox layouts.
			if choice == 1:
				GameState.route_orthodox = 40
			elif choice == 2:
				GameState.route_unorthodox = 40
			if demo:
				GameState.story_return_scene = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
				W4_DEMO.install_story_demo_runtime_events()
			GameState.pending_story_queue = [M03_EVENT]
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			await _wait_stable()
			var intro: Array = _story.get("_paragraphs")
			if int(_story.call("_story_source_paragraph_count")) != (4 if choice == 1 else 5):
				_fail("M03 fixture did not select the authored route variant")
				continue
			for page in range(intro.size()):
				var source := int(_story.call("_story_source_paragraph_index", page))
				if not _expect_m03_surface(M03_APPROACH if source == 0 else M03_IMPACT if source == 1 else ""):
					break
				await _finish_page()
				if not capture_dir.is_empty() and choice == 0 and page == int(_story.call(
						"_first_story_page_for_source", source)) and source in [0, 1, 2]:
					await _save_viewport_frame(capture_dir.path_join("intro_p%d.png" % source))
				_story.call("_on_advance")
				await _wait_stable()
			var original: Dictionary = _story.get("_current")
			if not bool(_story.get("_showing_choices")) or original.get("id") != M03_EVENT \
					or (original.get("choices", []) as Array).size() != 3:
				_fail("M03 must retain all three original choices")
				continue
			var receipts := GameState.event_log.size()
			_story.call("_on_choice", choice)
			await _wait_stable()
			var pages: Array = _story.get("_paragraphs")
			var cut := int(_story.get("_result_location_cut_page"))
			var raw: String = original.choices[choice].result_text
			var whitespace := RegEx.new()
			whitespace.compile("\\s+")
			if (cut >= 0) != (choice != 1) or cut >= pages.size() \
					or not bool(_story.get("_pending_after_result")) \
					or (demo and not bool(GameState.flags.get(
						"order124_choice__%s__%d" % [M03_EVENT, choice], false))) \
					or whitespace.sub("".join(PackedStringArray(pages)), "", true) != whitespace.sub(
						str(_story.call("_fmt", raw)), "", true) \
					or GameState.event_log.size() != receipts + 1 \
					or not is_equal_approx(GameState.money, 580_000.0 if choice == 1 else 500_000.0):
				_fail("M03 result text or original choice effects changed")
				continue
			for page in range(pages.size()):
				var expected := M03_EXIT if cut >= 0 and page >= cut else ""
				if not _expect_m03_surface(expected):
					break
				await _finish_page()
				if not capture_dir.is_empty() and (page == 0 or page == cut):
					await _save_viewport_frame(capture_dir.path_join("c%d_p%d.png" % [choice, page]))
				if not demo and capture_dir.is_empty() and language == "ko" \
						and ((cut < 0 and page == 0) or page in [cut - 1, cut]):
					if not await _reload_cut_result(choice, page, false):
						break
					await _wait_stable()
					if not _expect_m03_surface(expected):
						break
					reloads += 1
				if page + 1 < pages.size():
					_story.call("_on_advance")
					await _wait_stable()
			cases += 1
	await _remove_story()
	await _stop_audio()
	var expected_reloads := 0 if demo or not capture_dir.is_empty() else 5
	if _failures == 0 and cases == languages.size() * 3 and reloads == expected_reloads:
		print("M03_CRASH_OK routes=%d cold_reloads=%d demo=%s" % [cases, reloads, demo])
		get_tree().quit(0)
	else:
		get_tree().quit(1)

func _expect_m03_surface(background: String) -> bool:
	var cg := background.is_empty()
	var path := ImageRegistry.get_cg("cg_jiyeon_crash") if cg else ImageRegistry.get_background(background)
	var image := _story.get("_bg_img") as TextureRect
	var portrait := _story.get("_portrait_frame") as Control
	var hud := _story.get("_hud_panel") as Control
	if path.is_empty() or image.texture == null or image.texture.resource_path != path \
			or bool(_story.get("_current_uses_cg")) != cg or portrait.visible \
			or hud.visible == cg or not BGMPlayer._ambience_player.playing \
			or BGMPlayer._current_ambience_key != "rain" \
			or BGMPlayer._human_ambience_player.playing:
		_fail("M03 wrong surface, portrait or ambient layer: %s" % background)
		return false
	return true

func _check_sinchon_reunion() -> void:
	var routes := 0
	var loads := 0
	var capture_dir := OS.get_environment("GANGNAM_SINCHON_CAPTURE_DIR")
	var capture_language := OS.get_environment("GANGNAM_SINCHON_CAPTURE_LANGUAGE")
	var languages := W4_TERMS.keys()
	if not capture_dir.is_empty():
		var output := DirAccess.open(capture_dir) if capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or not W4_TERMS.has(capture_language) or DisplayServer.get_name() == "headless":
			_fail("Sinchon capture requires fresh absolute output, known locale and display")
			get_tree().quit(1)
			return
		languages = [capture_language]
		OS.low_processor_usage_mode = false
	for language in languages:
		LocaleManager.set_language(language)
		for choice in range(2):
			await _remove_story()
			_context = "%s/Sinchon/choice%d" % [language, choice]
			_seed_story(REUNION, 34)
			GameState.age = 33
			GameState.month = 9
			GameState.week_of_month = 2
			GameState.flags["arc_jiyeon_crash_seen"] = true
			if choice == 0:
				GameState.flags["bicycle_wheel_bent"] = true
			BGMPlayer.enter_ambient_bed(0.0)
			BGMPlayer.set_ambience("rain")
			BGMPlayer.set_season_ambience("winter")
			GameState.pending_story_queue = [REUNION]
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			await _wait_stable()
			if int(_story.call("_story_source_paragraph_count")) != (6 if choice == 0 else 5):
				_fail("Sinchon memory must append without moving the arrival or theme")
				continue
			var intro: Array = _story.get("_paragraphs")
			for page in range(intro.size()):
				var source := int(_story.call("_story_source_paragraph_index", page))
				if not _expect_reunion_surface(REUNION_STOP if source == 0 else REUNION_SEDAN,
						source >= 1, source >= 2, source >= 1):
					break
				await _finish_page()
				if not capture_dir.is_empty() and choice == 0 and source in [0, 1, 2, 5] \
						and page == int(_story.call("_first_story_page_for_source", source)):
					await _save_reunion_frame(capture_dir.path_join("intro_p%d.png" % source))
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) or not _expect_reunion_surface(
					REUNION_SEDAN, true, true, true):
				_fail("Sinchon choices unavailable or on the wrong surface")
				continue
			var cash := float(GameState.money)
			var mental := float(GameState.mental)
			var social := float(GameState.social_skill)
			var receipts := GameState.event_log.size()
			_story.call("_on_choice", choice)
			await _wait_stable()
			if GameState.event_log.size() != receipts + 1 \
					or not is_equal_approx(GameState.money, cash) \
					or GameState.mental != mental - (2.0 if choice == 0 else 0.0) \
					or GameState.social_skill != social + (2.0 if choice == 1 else 0.0):
				_fail("Sinchon choice changed an effect or did not commit exactly once")
				continue
			var results: Array = _story.get("_paragraphs")
			var resumed := false
			var headlights_loaded := false
			for page in range(results.size()):
				var source := int(_story.call("_story_source_paragraph_index", page))
				var headlights := choice == 0 and source == 3
				var expected := REUNION_HEADLIGHTS if headlights else REUNION_SEDAN
				if not _expect_reunion_surface(expected, not headlights, true, not resumed):
					break
				await _finish_page()
				if not capture_dir.is_empty() and (page == 0 or (headlights \
						and page == int(_story.call("_first_story_page_for_source", source)))):
					await _save_reunion_frame(capture_dir.path_join("c%d_p%d.png" % [choice, source]))
				if capture_dir.is_empty() and language == "ko" and (page == 0 or (headlights and not headlights_loaded)):
					if not await _reload_cut_result(choice, page, false):
						break
					await _wait_stable()
					if not _expect_reunion_surface(expected, not headlights, true, false):
						break
					resumed = true
					headlights_loaded = headlights
					loads += 1
				if page + 1 < results.size():
					_story.call("_on_advance")
					await _wait_stable()
			routes += 1
	await _remove_story()
	await _stop_audio()
	if _failures == 0 and routes == languages.size() * 2 and loads == (3 if capture_dir.is_empty() else 0):
		print("SINCHON_REUNION_OK routes=%d cold_results=%d" % [routes, loads])
		get_tree().quit(0)
	else:
		get_tree().quit(1)

func _save_reunion_frame(path: String) -> void:
	var portrait := _story.get("_portrait_frame") as Control
	for _frame in range(120):
		if not portrait.visible or portrait.modulate.a >= 0.99:
			await _save_viewport_frame(path)
			return
		await get_tree().process_frame
	_fail("Sinchon capture portrait did not finish fading in")

func _expect_reunion_surface(background: String, portrait_visible: bool, score: bool, car_cue: bool) -> bool:
	var image := _story.get("_bg_img") as TextureRect
	var portrait := _story.get("_portrait_frame") as Control
	var face := _story.get("_portrait") as TextureRect
	var nameplate := _story.get("_name_panel") as Control
	var warm := bool(_story.get("_pending_after_result")) and int(_story.get("_pending_result_choice_index")) == 1
	var expected_face := ImageRegistry.get_portrait("jiyeon_warm" if warm else "jiyeon_normal")
	var observed: Array[String] = []
	for key in AudioManager._story_audio_seen:
		if str(key).begins_with(REUNION + ":"):
			observed.append(str(key))
	var expected_cues: Array = [REUNION + "::description:1:0:traffic_pass"] if car_cue else []
	if image.texture == null or image.texture.resource_path != ImageRegistry.get_background(background) \
			or str(_story.get_meta("living_scene_effect", "")) != "none" \
			or portrait.visible != portrait_visible or nameplate.visible \
			or (portrait_visible and (face.texture == null or face.texture.resource_path != expected_face)) \
			or BGMPlayer._current_key != ("jiyeon" if score else "") \
			or observed != expected_cues or not _expect_no_ambience("Sinchon"):
		_fail("Sinchon wrong surface, portrait, weather, score or cue: %s cues=%s" % [background, observed])
		return false
	return true

func _check_m23_parents() -> bool:
	_m23_capture_dir = OS.get_environment("GANGNAM_M23_PARENTS_CAPTURE_DIR")
	var capture := not _m23_capture_dir.is_empty()
	var languages := W4_TERMS.keys()
	if capture:
		var language := OS.get_environment("GANGNAM_M23_PARENTS_CAPTURE_LANGUAGE")
		var output := DirAccess.open(_m23_capture_dir) if _m23_capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or not W4_TERMS.has(language) or DisplayServer.get_name() == "headless":
			_fail("M23 capture requires a fresh absolute output, known locale and real display")
			return false
		languages = [language]
		OS.low_processor_usage_mode = false
	await _remove_story()
	await _stop_audio()
	_context = "M23/prepare"
	if not _prepare_full_owner_history(89, [[14, "arc_father_01_call"], [21, "arc_father_02_signal"],
			[49, "chapter_card_34"], [57, "arc_father_medication"]]) or not _m23_selector():
		return false
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	var paths := 0
	var housing_count: Dictionary = {}
	for lang_index in range(languages.size()):
		var language: String = languages[lang_index]
		LocaleManager.set_language(language)
		for low in [false, true]:
			for choice in [0, 1]:
				await _remove_story()
				GameState.call("_restore_serialized_snapshot_exact", prepared)
				GameState.mental = 19 if low else 60
				GameState.money = 600_000.0
				var housing: String = M23_HOUSING[(lang_index + int(low)) % M23_HOUSING.size()]
				GameState.housing = housing
				_context = "%s/M23/%s/c%d/%s" % [language, "low" if low else "normal", choice, housing]
				if await _play_m23_parents(low, choice, housing):
					paths += 1
					if choice == 1:
						housing_count[housing] = true
	await _remove_story()
	await _stop_audio()
	if paths != languages.size() * 4 or (not capture and housing_count.size() != M23_HOUSING.size()):
		_fail("M23 path or housing inventory incomplete paths=%d housing=%s" % [paths, housing_count.keys()])
	if capture:
		var shots := 0
		for file in DirAccess.get_files_at(_m23_capture_dir):
			if file.ends_with(".png"):
				shots += 1
		if shots != 24:
			_fail("M23 expected 24 renders for %s, got %d" % [languages[0], shots])
	if _failures != 0:
		return false
	print("M23_PARENTS_OK paths=%d cold_results=%d cold_prose=%d cold_choices=%d locale_rebinds=%d call_handoffs=%d housing=%s full_owner=1 prepared_history=1 capture=%s" % [
		paths, 5 * languages.size() if not capture else 0, 2 * languages.size() if not capture else 0,
		paths if not capture else 0, 8 if not capture else 0, paths, housing_count.keys(), capture])
	return true

func _m23_selector() -> bool:
	var probe := load("res://scenes/MainGame.tscn").instantiate() as Control
	var eligible := bool(GameState.flags.get("arc_father_02_done", false)) \
		and bool(GameState.flags.get("arc_father_medication_seen", false))
	for turn in [88, 89, 90, 91, 92, 93]:
		eligible = eligible and (probe.call("_next_arc_id", turn, true) == M23_PARENTS) == (turn >= 89 and turn <= 92)
	var flags: Dictionary = GameState.flags.duplicate()
	eligible = eligible and probe.call("_story_graph_contract_event_id", 89, flags, true) != M23_PARENTS
	for forbidden in ["arc_34_parents_visit_seen", "arc_father_03_seen"]:
		var invalid := flags.duplicate()
		invalid[forbidden] = true
		eligible = eligible and probe.call("_story_graph_contract_event_id", 89, invalid, false) != M23_PARENTS
	for required in ["arc_father_02_done", "arc_father_medication_seen"]:
		var invalid := flags.duplicate()
		invalid.erase(required)
		eligible = eligible and probe.call("_story_graph_contract_event_id", 89, invalid, false) != M23_PARENTS
	probe.free()
	if not eligible:
		_fail("M23 W89-92 route or its actual predecessor/death boundary failed")
	return eligible

func _play_m23_parents(low: bool, choice: int, housing: String, verify_resume: bool = true) -> bool:
	if not await _open_full_fixture_event(M23_PARENTS):
		return false
	var event: Dictionary = _story.get("_current")
	var intro: Array = (_story.get("_paragraphs") as Array).duplicate()
	var intro_count := 3 if low else 4
	var intro_cut := _m23_expected_cut(intro, 0, low)
	if int(_story.call("_story_source_paragraph_count")) != intro_count \
			or (intro_cut >= 0) != low \
			or not _m23_same_prose(intro, str(_story.call("_fmt", event["description_low_mental" if low else "description"]))):
		_fail("M23 intro selector or preserved original prose changed")
		return false
	var tag := "low" if low else "normal"
	for page in range(intro.size()):
		var source := int(_story.call("_story_source_paragraph_index", page))
		var laundry := low and source == 0 and page >= intro_cut
		var expected := M23_RESTAURANT if source == intro_count - 1 else (M23_HOME if laundry else M23_CONCOURSE)
		if not _m23_surface(expected, housing, false):
			return false
		await _finish_page()
		if choice == 0 and not _m23_capture_dir.is_empty() and (page == intro_cut \
				or page == int(_story.call("_first_story_page_for_source", source))):
			var shot := "%s_intro_p%d%s" % [tag, source, "_laundry" if page == intro_cut else ""]
			if not await _save_m23_frame(shot):
				return false
		if low and choice == 1 and _m23_capture_dir.is_empty() and page in [intro_cut - 1, intro_cut]:
			if not await _reload_prechoice("prose", M23_PARENTS) or int(_story.get("_para_index")) != page \
					or not _m23_surface(expected, housing, false):
				_fail("M23 low intro cold resume shifted at the laundry cut")
				return false
			if LocaleManager.language == "ko" and not await _m23_rebind(false, page >= intro_cut, expected, housing):
				return false
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")) or (_story.get("_choice_box") as Control).get_child_count() != 2 \
			or not _m23_surface(M23_RESTAURANT, housing):
		_fail("M23 expected both choices in the restaurant")
		return false
	if verify_resume and _m23_capture_dir.is_empty() \
			and (not await _reload_prechoice("choices", M23_PARENTS) or not _m23_surface(M23_RESTAURANT, housing)):
		return false
	if not _m23_capture_dir.is_empty() and choice == 0 and not await _save_m23_frame("%s_choices" % tag):
		return false
	var expected_state := [float(GameState.money) - (80_000.0 if choice == 0 else 0.0),
		GameState.mental + (4 if choice == 0 else 2), GameState.social_skill + (1 if choice == 0 else 0),
		GameState.reputation + (2 if choice == 1 else 0), GameState.event_log.size() + 1]
	_story.call("_on_choice", choice)
	await _wait_stable()
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var result_cut := _m23_expected_cut(pages, 1, choice == 1)
	if int(_story.call("_story_source_paragraph_count")) != 3 \
			or (result_cut >= 0) != (choice == 1) \
			or not _m23_same_prose(pages, str(_story.call("_fmt", event["choices"][choice]["result_text"]))) \
			or not _m23_choice_receipt(choice, expected_state, false):
		_fail("M23 result changed original content or once-only effects")
		return false
	for page in range(pages.size()):
		var source := int(_story.call("_story_source_paragraph_index", page))
		var ride := choice == 1 and source == 0 and page >= result_cut
		var expected := (M23_BAG if ride else M23_RESTAURANT) if source == 0 \
			else (M23_GATE if choice == 0 else M23_HOME)
		if not _m23_surface(expected, housing):
			return false
		await _finish_page()
		var first_for_source := page == int(_story.call("_first_story_page_for_source", source))
		if _m23_capture_dir.is_empty() and low and (page == result_cut or (first_for_source and source in [0, 1])):
			if not await _reload_cut_result(choice, page, false):
				return false
			await _wait_stable()
			if not _m23_surface(expected, housing) or not _m23_choice_receipt(choice, expected_state, false):
				return false
			if LocaleManager.language == "ko" and choice == 1 and page in [result_cut - 1, result_cut] \
					and not await _m23_rebind(true, ride, expected, housing):
				return false
		elif not _m23_capture_dir.is_empty() and (page == result_cut or first_for_source):
			if not await _save_m23_frame("%s_c%d_p%d%s" % [tag, choice, source, "_ride" if page == result_cut else ""]):
				return false
		_story.call("_on_advance")
		await _wait_stable()
	var call: Dictionary = _story.get("_current")
	if call.get("id") != M23_CALL or not _m23_choice_receipt(choice, expected_state, true) \
			or str(_story.get_meta("story_transition_mode", "")) != "time_cut" \
			or str(_story.get("_event_background_id")) != _m23_home_background(housing):
		_fail("M23 did not close exactly once into mother's home phone call time cut")
		return false
	return true

func _m23_same_prose(pages: Array, authored: String) -> bool:
	var whitespace := RegEx.new()
	whitespace.compile("\\s+")
	return whitespace.sub("".join(PackedStringArray(pages)), "", true) == whitespace.sub(authored, "", true)

func _m23_expected_cut(pages: Array, anchor_index: int, required: bool) -> int:
	if not required:
		if int(_story.get("_result_location_cut_page")) != -1:
			_fail("M23 unrelated prose or choice gained a mid-paragraph cut")
		return -1
	var anchor: String = _story.call("_fmt", M23_CUT_ANCHORS[LocaleManager.language][anchor_index])
	var cut := int(_story.get("_result_location_cut_page"))
	if cut < 1 or cut >= pages.size() or not str(pages[cut]).begins_with(anchor) \
			or int(_story.call("_story_source_paragraph_index", cut - 1)) != 0 \
			or int(_story.call("_story_source_paragraph_index", cut)) != 0:
		_fail("M23 exact same-source boundary did not start at %s" % anchor)
		return -1
	return cut

func _m23_rebind(result: bool, after_cut: bool, background: String, housing: String) -> bool:
	# Different translations have different character ratios on each side;
	# changing the language must never move to the other picture mid-sentence.
	for language in ["en", "ko"]:
		_story.call("_set_story_language", language)
		await _wait_stable()
		var cut := _m23_expected_cut(_story.get("_paragraphs"), int(result), true)
		if cut < 0 or LocaleManager.language != language \
				or (int(_story.get("_para_index")) >= cut) != after_cut \
				or not _m23_surface(background, housing, result):
			_fail("M23 locale rebind crossed the laundry or bag boundary")
			return false
	return true

func _m23_home_background(housing: String) -> String:
	return {"gosiwon": W4_ROOM, "oneroom": "apartment", "apartment": "gangnam_apartment"}[housing]

func _m23_surface(expected: String, housing: String, room_tone: bool = true) -> bool:
	var home := expected == M23_HOME
	var actual := _m23_home_background(housing) if home else expected
	var sound_here := home and room_tone
	var audio := "apartment" if sound_here else ""
	if not _expect_surface(actual, audio, "M23 parents"):
		return false
	var cues: Array = AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(M23_PARENTS + ":"))
	var portrait := _story.get("_portrait_frame") as Control
	var nameplate := _story.get("_name_panel") as Control
	var bag := expected == M23_BAG
	if str(_story.get_meta("living_scene_effect", "")) != "none" or not cues.is_empty() \
			or portrait.visible == bag or (bag and nameplate.visible) \
			or not BGMPlayer._current_key.is_empty() or BGMPlayer._ambience_player.playing != sound_here \
			or not BGMPlayer._current_human_ambience_key.is_empty() or BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() or BGMPlayer._season_player.playing:
		_fail("M23 unexpected cue, score, weather or wrong live ambience: %s cues=%s" % [actual, cues])
		return false
	return true

func _m23_choice_receipt(choice: int, expected: Array, call_open: bool) -> bool:
	var records: Array = GameState.event_log
	var receipt: Dictionary = records.back() if not records.is_empty() else {}
	var valid: bool = FULL_STORY_FLOW.valid_session() and records.size() == expected[4] \
		and receipt.get("event_id") == M23_PARENTS and int(receipt.get("choice_index", -1)) == choice \
		and is_equal_approx(GameState.money, expected[0]) and GameState.mental == expected[1] \
		and GameState.social_skill == expected[2] and GameState.reputation == expected[3] \
		and bool(GameState.flags.get("arc_34_parents_visit_seen", false)) \
		and bool(GameState.flags.get("arc_34_parents_visited", false)) \
		and bool(GameState.flags.get("hid_room_from_parents", false)) == (choice == 0) \
		and bool(GameState.flags.get("showed_room_to_parents", false)) == (choice == 1) \
		and not bool(GameState.flags.get("arc_father_03_seen", false)) \
		and bool(_story.get("_pending_after_result")) != call_open
	if not call_open:
		valid = valid and str(_story.get("_pending_follow_up")) == M23_CALL
	return valid

func _save_m23_frame(label: String) -> bool:
	if bool(_story.get("_showing_choices")):
		var box := _story.get("_choice_box") as Control
		for _frame in range(150):
			var settled := box.modulate.a >= 0.99 and box.get_child_count() == 2
			for child in box.get_children():
				var group := child as Control
				settled = settled and group.modulate.a >= 0.99 and group.scale.is_equal_approx(Vector2.ONE)
			if settled:
				break
			if _frame == 149:
				_fail("M23 did not settle choice boxes for capture")
				return false
			await get_tree().process_frame
	var portrait := _story.get("_portrait_frame") as Control
	var threshold := 0.93 if bool(_story.get("_showing_choices")) else 0.99
	for _frame in range(150):
		if not portrait.visible or portrait.modulate.a >= threshold:
			return await _save_viewport_frame(_m23_capture_dir.path_join(label + ".png"))
		await get_tree().process_frame
	_fail("M23 did not settle portrait for capture")
	return false

func _check_w100_document() -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "W100/prepare"
	if not _prepare_full_owner_history(100, _father_contact_history()):
		return false
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	if not _w100_router(false):
		return false
	var paths := 0
	var known := W4_TERMS.keys()
	for lang_index in range(known.size()):
		var language: String = known[lang_index]
		for choice in range(W100_CONTACT_FLAGS.size()):
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			GameState.call("_restore_serialized_snapshot_exact", prepared)
			var housing: String = M23_HOUSING[(lang_index + choice) % M23_HOUSING.size()]
			GameState.housing = housing
			_context = "%s/W100/c%d/%s" % [language, choice, housing]
			if not await _open_full_fixture_event(W100_DOCUMENT) or not await _play_w100_document(choice, housing):
				_fail("W100 live contact or isolated result restore failed")
				await _remove_story()
				await _stop_audio()
				return false
			paths += 1
	await _remove_story()
	await _stop_audio()
	if _failures != 0:
		return false
	print("W100_DOCUMENT_OK paths=%d contact_frames=%d result_v4=%d actual_choice_receipts=%d full_owner=1 w112_owner_unchanged=1" % [paths, paths * 2, paths * 2, paths])
	return true

func _father_contact_history() -> Array:
	return [[14, "arc_father_01_call"], [21, "arc_father_02_signal"], [49, "chapter_card_34"],
		[57, "arc_father_medication"], [85, "arc_y2_relationship_fork_unattached"], [89, M23_PARENTS],
		[89, M23_CALL], [96, W96_VISIT, 3], [96, W96_YEAR_CLOSE], [97, "chapter_card_35"]]

func _play_w100_document(choice: int, housing: String) -> bool:
	var expected_background := _m23_home_background(housing)
	var event: Dictionary = _story.get("_current")
	var original := [GameState.money, GameState.health, GameState.mental, GameState.moral_tint,
		GameState.get_cast_affinity("father"), GameState.get_cast_stage("father"), GameState.event_log.size()]
	var deferred := GameState.deferred_events.duplicate(true)
	for page in range((_story.get("_paragraphs") as Array).size()):
		await _finish_page()
		if int(_story.get("_para_index")) != page or not _w100_surface(expected_background, false):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")) or (_story.get("_choice_box") as Control).get_child_count() != 3 \
			or not _w100_surface(expected_background, false) or GameState.event_log.size() != original[6]:
		return false
	_story.call("_on_choice", choice)
	await _wait_stable()
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", event["choices"][choice]["result_text"]))
	if int(_story.call("_story_source_paragraph_count")) != 2 or not _m23_same_prose(pages, authored):
		_fail("W100 result text or authored paragraphs changed")
		return false
	for page in range(pages.size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		var messaging := choice == 2 or (choice == 1 and source == 1)
		if int(_story.get("_para_index")) != page or not _w100_surface(expected_background, messaging) \
				or not _w100_receipt(choice, original, deferred, false):
			return false
		if page == int(_story.call("_first_story_page_for_source", source)):
			if not await _reload_cut_result(choice, page, false):
				return false
			await _wait_stable()
			if not _w100_surface(expected_background, messaging) or not _w100_receipt(choice, original, deferred, false):
				return false
		if page == pages.size() - 1:
			_story.set_meta("_screenshot_qa_static_surface", true)
		_story.call("_on_advance")
		await _wait_stable()
	return _w100_receipt(choice, original, deferred, true) and _w100_router(true)

func _w100_surface(background: String, messaging: bool) -> bool:
	var labels := {"ko": "메시지", "en": "Message", "ja": "メッセージ", "zh-CN": "消息", "zh-TW": "訊息"}
	return _expect_father_contact_surface(W100_DOCUMENT, background, "message" if messaging else "internal",
		str(labels[LocaleManager.language]) if messaging else "")

func _expect_father_contact_surface(event_id: String, background: String, channel: String, badge_text: String) -> bool:
	var presentation: Dictionary = _story.get("_current_presentation")
	var badge := _story.get("_communication_badge") as Control
	var label := _story.get("_communication_label") as Label
	var portrait := _story.get("_portrait") as TextureRect
	var sound_cues := AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(event_id + ":"))
	if not _expect_surface(background, "apartment", event_id + " home") \
			or presentation.get("channel") != channel or presentation.get("portrait_role") != "local" \
			or badge.visible != (not badge_text.is_empty()) or label.text.nocasecmp_to(badge_text) != 0 \
			or bool(_story.get("_portrait_remote_inset")) or not (_story.get("_portrait_frame") as Control).visible \
			or portrait.texture == null or portrait.texture.resource_path != ImageRegistry.get_portrait("player_tired") \
			or str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not BGMPlayer._ambience_player.playing or not BGMPlayer._current_human_ambience_key.is_empty() \
			or BGMPlayer._human_ambience_player.playing or not BGMPlayer._current_season_key.is_empty() \
			or BGMPlayer._season_player.playing or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing or not sound_cues.is_empty():
		_fail("%s contradictory contact, actor or ambience: channel=%s badge=%s/%s score=%s cues=%s" % [
			event_id, presentation.get("channel"), badge.visible, label.text, BGMPlayer._current_key, sound_cues])
		return false
	return true

func _w100_receipt(choice: int, original: Array, deferred: Array, closed: bool) -> bool:
	var latest: Dictionary = GameState.event_log.back()
	var snapshot := FULL_STORY_FLOW.snapshot()
	var reads: Array = snapshot.get("read_receipts", {}).get("100", [])
	var chain: Dictionary = snapshot.get("chain", {})
	var valid: bool = FULL_STORY_FLOW.valid_session() and GameState.turn == 100 \
		and GameState.event_log.size() == original[6] + 1 and latest.get("event_id") == W100_DOCUMENT \
		and int(latest.get("choice_index", -1)) == choice and int(latest.get("turn", -1)) == 100 \
		and is_equal_approx(GameState.money, original[0]) and GameState.health == original[1] \
		and GameState.mental == original[2] and is_equal_approx(GameState.moral_tint, original[3]) \
		and GameState.get_cast_affinity("father") == original[4] and GameState.get_cast_stage("father") == original[5] \
		and _w96_deferred_equal(deferred) and bool(GameState.flags.get("arc_y3_father_avoidance_document_seen", false)) \
		and bool(GameState.flags.get("father_visit_deferred", false)) and not bool(GameState.flags.get("visited_father", false)) \
		and reads.size() == int(closed) and bool(chain.get("closed", false)) == closed \
		and chain.get("pending_event_ids") == ([] if closed else [W100_DOCUMENT])
	for index in range(W100_CONTACT_FLAGS.size()):
		valid = valid and bool(GameState.flags.get(W100_CONTACT_FLAGS[index], false)) == (index == choice)
	if closed and valid:
		valid = reads[0].get("event_id") == W100_DOCUMENT and int(reads[0].get("choice_index", -1)) == choice
	if not valid:
		_fail("W100 altered original choice flags, effects, or owner receipt")
	return valid

func _w100_router(closed: bool) -> bool:
	var probe := load("res://scenes/MainGame.tscn").instantiate() as Control
	var flags := GameState.flags.duplicate()
	var w112 := "arc_y3_father_deferred_call"
	var valid: bool = (probe.call("_story_graph_contract_event_id", 100, flags, false) == W100_DOCUMENT) != closed \
		and probe.call("_story_graph_contract_event_id", 99, flags, false) != W100_DOCUMENT \
		and probe.call("_story_graph_contract_event_id", 101, flags, false) != W100_DOCUMENT \
		and probe.call("_story_graph_contract_event_id", 100, flags, true) != W100_DOCUMENT \
		and (probe.call("_story_graph_contract_event_id", 112, flags, false) == w112) == closed \
		and probe.call("_story_graph_contract_event_id", 111, flags, false) != w112 \
		and probe.call("_story_graph_contract_event_id", 113, flags, false) != w112
	probe.free()
	if not valid:
		_fail("W100 presentation changed the existing W100/W112 gate")
	return valid

func _check_w112_phone() -> bool:
	_w112_capture_dir = OS.get_environment("GANGNAM_W112_PHONE_CAPTURE_DIR")
	var capture := not _w112_capture_dir.is_empty()
	var languages := ["ko"] if capture else W112_ANSWER.keys()
	if capture:
		var output := DirAccess.open(_w112_capture_dir) if _w112_capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or DisplayServer.get_name() == "headless":
			_fail("W112 KO capture requires a fresh absolute output and real display")
			return false
		OS.low_processor_usage_mode = false
	await _remove_story()
	await _stop_audio()
	var paths := 0
	var memories := [2] if capture else [0, 1, 2]
	var prepared_memories: Dictionary = {}
	# Build unopened snapshots before any real W112 closure sets the return
	# marker that the isolated MainGame boundary intentionally does not consume.
	for memory in memories:
		_context = "W112/prepare/memory%d" % memory
		if not _prepare_full_owner_history(112, _father_contact_history() + [[100, W100_DOCUMENT, memory]]) \
				or not _w112_routes(memory):
			return false
		prepared_memories[memory] = GameState.serialize().duplicate(true)
	for language in languages:
		LocaleManager.set_language(language)
		for memory in memories:
			for choice in ([2] if capture else [0, 1, 2]):
				await _remove_story()
				await _stop_audio()
				GameState.call("_restore_serialized_snapshot_exact", prepared_memories[memory])
				var housing: String = M23_HOUSING[(W112_ANSWER.keys().find(language) + memory + choice) % M23_HOUSING.size()]
				GameState.housing = housing
				_context = "%s/W112/memory%d/c%d/%s" % [language, memory, choice, housing]
				if not await _open_full_fixture_event(W112_PHONE) or not await _play_w112_phone(memory, choice, housing, capture):
					_fail("W112 live call or isolated restore failed")
					await _remove_story()
					await _stop_audio()
					return false
				paths += 1
	await _remove_story()
	await _stop_audio()
	if capture and DirAccess.get_files_at(_w112_capture_dir).size() != 4:
		_fail("W112 expected exactly four settled captures")
	if _failures != 0:
		return false
	print("W112_PHONE_OK paths=%d memory_variants=%d prose_v4=%d result_v4=%d actual_choice_receipts=%d full_owner=1 captures=%d" % [paths,
		1 if capture else languages.size() * 3, 0 if capture else languages.size() * 6,
		0 if capture else languages.size() * 9, paths, 4 if capture else 0])
	return true

func _play_w112_phone(memory: int, choice: int, housing: String, capture: bool) -> bool:
	var background := _m23_home_background(housing)
	var event: Dictionary = _story.get("_current")
	var known: Dictionary = event.get("description_if_known", {})
	var authored := str(_story.call("_fmt", known.get(W100_CONTACT_FLAGS[memory], "")))
	var prose: Array = (_story.get("_paragraphs") as Array).duplicate()
	if int(_story.call("_story_source_paragraph_count")) != 3 or not _m23_same_prose(prose, authored):
		_fail("W112 did not render the actual W100 contact memory")
		return false
	var snapshot_before: Dictionary = GameState.serialize().duplicate(true)
	for page in range(prose.size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		var first := page == int(_story.call("_first_story_page_for_source", source))
		if int(_story.get("_para_index")) != page or not _w112_surface(background, source > 0):
			return false
		if first and source == 1 and not str(prose[page]).begins_with(W112_ANSWER[LocaleManager.language]):
			_fail("W112 connected state not anchored to the localized third-ring answer")
			return false
		if first and source in [0, 1]:
			if capture:
				if not await _save_w112_frame("%02d_%s" % [source + 1, "before_answer" if source == 0 else "father_answers"]):
					return false
			elif choice == memory:
				if not await _reload_prechoice("prose", W112_PHONE) or not _w112_surface(background, source > 0) \
						or int(_story.get("_para_index")) != page:
					return false
		_story.call("_on_advance")
		await _wait_stable()
	_story.call("_refresh_story_speaker_language")
	if not bool(_story.get("_showing_choices")) or (_story.get("_choice_box") as Control).get_child_count() != 3 \
			or (_story.get("_name_panel") as Control).visible \
			or not _w112_surface(background, true) or GameState.event_log.size() != snapshot_before["event_log"].size():
		return false
	_story.call("_on_choice", choice)
	await _wait_stable()
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var result := str(_story.call("_fmt", event["choices"][choice]["result_text"]))
	if int(_story.call("_story_source_paragraph_count")) != 3 or not _m23_same_prose(pages, result):
		_fail("W112 result changed the original conversation or authored paragraphs")
		return false
	for page in range(pages.size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		var connected := choice != 2 or source < 2
		if int(_story.get("_para_index")) != page or not _w112_surface(background, connected) \
				or not _w112_receipt(memory, choice, snapshot_before, false):
			return false
		if page == int(_story.call("_first_story_page_for_source", source)):
			if capture and source in [1, 2]:
				if not await _save_w112_frame("%02d_%s" % [source + 2, "agreed_time" if connected else "call_ended"]):
					return false
			elif not capture and choice == memory:
				if not await _reload_cut_result(choice, page, false):
					return false
				await _wait_stable()
				if not _w112_surface(background, connected) or not _w112_receipt(memory, choice, snapshot_before, false):
					return false
		if page == pages.size() - 1:
			_story.set_meta("_screenshot_qa_static_surface", true)
		_story.call("_on_advance")
		await _wait_stable()
	return _w112_receipt(memory, choice, snapshot_before, true)

func _w112_surface(background: String, connected: bool) -> bool:
	var labels := {"ko": "통화 중", "en": "VOICE CALL", "ja": "通話中", "zh-CN": "通话中", "zh-TW": "通話中"}
	var presentation: Dictionary = _story.get("_current_presentation")
	if connected and presentation.get("state") != "connected":
		_fail("W112 active call did not declare a connection")
		return false
	if not connected and str(presentation.get("state", "")) == "connected":
		_fail("W112 inactive call retained the connected state")
		return false
	return _expect_father_contact_surface(W112_PHONE, background, "phone" if connected else "internal",
		str(labels[LocaleManager.language]) if connected else "")

func _w112_routes(memory: int) -> bool:
	var probe := load("res://scenes/MainGame.tscn").instantiate() as Control
	var flags := GameState.flags.duplicate()
	var wrong := flags.duplicate()
	wrong[W100_CONTACT_FLAGS[(memory + 1) % 3]] = true
	var valid: bool = probe.call("_story_graph_contract_event_id", 112, flags, false) == W112_PHONE \
		and probe.call("_story_graph_contract_event_id", 111, flags, false) != W112_PHONE \
		and probe.call("_story_graph_contract_event_id", 113, flags, false) != W112_PHONE \
		and probe.call("_story_graph_contract_event_id", 112, flags, true) != W112_PHONE \
		and probe.call("_story_graph_contract_event_id", 112, wrong, false) != W112_PHONE
	probe.free()
	if not valid:
		_fail("W112 eligibility changed for the exact W100 memory/death gate")
	return valid

func _w112_receipt(memory: int, choice: int, before: Dictionary, closed: bool) -> bool:
	var latest: Dictionary = GameState.event_log.back()
	var owner := FULL_STORY_FLOW.snapshot()
	var read_100: Array = owner.get("read_receipts", {}).get("100", [])
	var read_112: Array = owner.get("read_receipts", {}).get("112", [])
	var chain: Dictionary = owner.get("chain", {})
	var valid: bool = FULL_STORY_FLOW.valid_session() and GameState.turn == 112 \
		and GameState.event_log.size() == before["event_log"].size() + 1 and latest.get("event_id") == W112_PHONE \
		and int(latest.get("choice_index", -1)) == choice and int(latest.get("turn", -1)) == 112 \
		and bool(GameState.flags.get("arc_y3_father_deferred_call_seen", false)) and read_100.size() == 1 \
		and read_100[0].get("event_id") == W100_DOCUMENT and int(read_100[0].get("choice_index", -1)) == memory \
		and _w96_deferred_equal(before["deferred_events"]) and read_112.size() == int(closed) \
		and bool(chain.get("closed", false)) == closed and chain.get("pending_event_ids") == ([] if closed else [W112_PHONE])
	for index in range(W100_CONTACT_FLAGS.size()):
		valid = valid and bool(GameState.flags.get(W100_CONTACT_FLAGS[index], false)) == (index == memory)
	for key in ["money", "health", "mental", "moral_tint"]:
		valid = valid and is_equal_approx(float(GameState.get(key)), float(before[key]))
	if closed and valid:
		valid = read_112[0].get("event_id") == W112_PHONE and int(read_112[0].get("choice_index", -1)) == choice
	if not valid:
		_fail("W112 replay altered the original W100 memory, effects, or closure receipt")
	return valid

func _save_w112_frame(label: String) -> bool:
	var portrait := _story.get("_portrait_frame") as Control
	for _frame in range(150):
		if portrait.modulate.a >= 0.99:
			return await _save_viewport_frame(_w112_capture_dir.path_join("ko_%s.png" % label))
		await get_tree().process_frame
	_fail("W112 local portrait never settled for capture")
	return false

func _jaehyuk_pitch_history() -> Array:
	return [[19, "arc_jaehyuk_01_reunion"], [49, "chapter_card_34"],
		[56, "arc_jaehyuk_01b_real_face"], [68, "arc_jaehyuk_02_bond"], [80, "arc_jaehyuk_02b_favor"],
		[96, W96_YEAR_CLOSE], [97, "chapter_card_35"]]

func _jaehyuk_calendar_fixture_history(photo: bool, late_choices: Array) -> Array:
	var history := _jaehyuk_pitch_history()
	history[0].append(0 if photo else 1)
	# Resolve old foreground gates through authored choices rather than flags.
	history += [[5, "arc_intro_03_sns"], [6, "cafe_00", 2], [8, "arc_job_first_rejection"],
		[9, "arc_money_check_low"], [10, "arc_sangchul_01_answer"], [11, "arc_gosiwon_wall"],
		[12, "arc_invest_guidance", 1], [13, "arc_rescue_job"], [14, "arc_father_01_call"],
		[14, "arc_first_job_week_convenience"],
		[15, "arc_daeun_01_meet", 1], [17, M03_EVENT], [20, "arc_hyunsu_night_talk"],
		[21, "arc_father_02_signal", 1], [31, "arc_sangchul_02_coffee", 1], [32, "arc_first_real_win"],
		[35, "arc_daeun_02_regular", 1], [36, REUNION], [76, "arc_sangchul_casino_decision", 1],
		[115, "arc_why_gangnam_real"]] + late_choices
	history.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]))
	return history

func _check_w19_reunion() -> bool:
	const REUNION_ID := "arc_jaehyuk_01_reunion"
	var capture_dir := OS.get_environment("GANGNAM_W19_REUNION_CAPTURE_DIR")
	var languages := W4_TERMS.keys() if capture_dir.is_empty() else ["ko"]
	if not capture_dir.is_empty() and (DisplayServer.get_name() == "headless"
			or not DirAccess.dir_exists_absolute(capture_dir)):
		_fail("W19 capture requires a renderer and an existing output directory")
		return false
	var paths := 0
	var restored := 0
	var rebinds := 0
	var reflows := 0
	for language in languages:
		for variant in range(3):
			for choice in range(2):
				await _remove_story()
				await _stop_audio()
				LocaleManager.set_language(language)
				_context = "%s/W19/variant%d/c%d" % [language, variant, choice]
				if not _prepare_full_owner_history(19, [[5, "arc_intro_03_sns"], [6, "cafe_00", 2],
						[8, "arc_job_first_rejection"], [9, "arc_money_check_low"],
						[10, "arc_rescue_job"], [11, "arc_sangchul_01_answer"], [11, "arc_gosiwon_wall"],
						[14, "arc_father_01_call"], [14, "arc_first_job_week_convenience"],
						[12, "arc_daeun_01_meet"], [14, "arc_invest_guidance"], [16, "arc_night_routine"],
						[17, M03_EVENT], [18, "arc_father_quiet_call"]]):
					return false
				GameState.route_orthodox = 30 if variant == 1 else 0
				GameState.route_unorthodox = 30 if variant == 2 else 0
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var selected: String = ingress.call("_next_arc_id", -1, true)
				ingress.free()
				if selected != REUNION_ID:
					_fail("W19 prepared predecessors selected " + selected)
					return false
				if not await _open_full_fixture_event(REUNION_ID) or not _w19_surface(false):
					return false
				var cut: int = _story.get("_result_location_cut_page")
				var pages: Array = _story.get("_paragraphs")
				if cut <= 0 or cut >= pages.size() or int(_story.call("_story_source_paragraph_index", cut)) != (1 if variant == 2 else 2):
					_fail("first real reunion paragraph was not identified")
					return false
				var raw := str(_story.call("_resolved_story_description", _story.get("_current")))
				if "".join(pages).replace(" ", "").replace("\n", "") != raw.replace(" ", "").replace("\n", ""):
					_fail("presentation cut changed the authored prose")
					return false
				var prefix := "v%d_c%d" % [variant, choice]
				var cues: Array = AudioManager._story_audio_seen.keys()
				if cues.size() != 1 or not str(cues[0]).ends_with(":phone_notification"):
					_fail("first contact did not play exactly one existing notification: %s" % [cues])
					return false
				for page in range(pages.size()):
					await _finish_page()
					var expected_score := "ambition" if int(_story.call("_story_source_paragraph_index", page)) >= 1 else ""
					if not _w19_surface(page >= cut) or BGMPlayer._current_key != expected_score:
						_fail("W19 did not keep its authored music entrance")
						return false
					if not capture_dir.is_empty() and (page == cut - 1 or page == cut):
						await get_tree().create_timer(0.45).timeout
						if not await _save_viewport_frame(capture_dir.path_join(prefix + ("_arrival.png" if page == cut else "_before.png"))):
							return false
					if capture_dir.is_empty() and choice == 0 and (page == cut - 1 or page == cut):
						if not await _reload_prechoice("prose", REUNION_ID) \
								or int(_story.get("_para_index")) != page or not _w19_surface(page >= cut) \
								or not AudioManager._story_audio_seen.is_empty() or BGMPlayer._current_key != expected_score:
							_fail("cold prose crossed the cut or replayed the message")
							return false
						restored += 1
						if language == "ko" and variant != 0:
							for target in ["en", "ko"]:
								_story.call("_set_story_language", target)
								await _wait_stable()
								if LocaleManager.language != target or not _w19_surface(page >= cut) \
										or not AudioManager._story_audio_seen.is_empty() or BGMPlayer._current_key != expected_score:
									_fail("language rebind crossed the arrival or replayed its audio")
									return false
								rebinds += 1
							if int(_story.get("_para_index")) != page:
								_fail("language round trip did not restore the Korean page")
								return false
							for level in ["large", "standard"]:
								_story.call("_set_story_text_size", level)
								await _wait_stable()
								if str(_story.get("_story_text_size")) != level or not _w19_surface(page >= cut) \
										or int(_story.get("_result_location_cut_page")) <= 0 or BGMPlayer._current_key != expected_score:
									_fail("text-size change dropped the arrival boundary")
									return false
								reflows += 1
							if int(_story.get("_para_index")) != page:
								_fail("text-size round trip did not restore the Korean page")
								return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")) or not _w19_surface(true):
					return false
				if capture_dir.is_empty() and choice == 0:
					if not await _reload_prechoice("choices", REUNION_ID) or not _w19_surface(true) \
							or not AudioManager._story_audio_seen.is_empty():
						_fail("cold choice did not return to the real meeting")
						return false
					restored += 1
				var receipts := GameState.event_log.size()
				var cash := float(GameState.money)
				_story.call("_on_choice", choice)
				await _finish_page()
				if not _w19_surface(true) or GameState.event_log.size() != receipts + 1 \
						or GameState.money != cash or GameState.has_item("artifact_jaehyuk_photo") != (choice == 0):
					_fail("reunion choice changed its existing money, photo or receipt")
					return false
				if capture_dir.is_empty():
					if not await _reload_cut_result(choice, 0, false) or not _w19_surface(true) \
							or not AudioManager._story_audio_seen.is_empty():
						_fail("cold result did not return to the meeting quietly")
						return false
					restored += 1
				paths += 1
	await _remove_story()
	await _stop_audio()
	if _failures != 0 or paths != languages.size() * 6 \
			or restored != (75 if capture_dir.is_empty() else 0) \
			or rebinds != (8 if capture_dir.is_empty() else 0) or reflows != rebinds:
		return false
	print("W19_REUNION_OK paths=%d cold_v4=%d rebinds=%d reflows=%d cut_variants=3 existing_photo_receipt=1" % [paths, restored, rebinds, reflows])
	return true

func _w19_surface(arrived: bool) -> bool:
	var bg := (_story.get("_bg_img") as TextureRect).texture
	var portrait := _story.get("_portrait_frame") as Control
	var expected_art: bool = bg != null and bg.resource_path == ImageRegistry.get_background("pojangmacha") if arrived else bg == null
	if not bool(_story.get("_full_w19_reunion")) or not expected_art or portrait.visible != arrived \
			or (not arrived and (_story.get("_name_panel") as Control).visible) \
			or str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not BGMPlayer._current_ambience_key.is_empty() or BGMPlayer._ambience_player.playing \
			or not BGMPlayer._current_human_ambience_key.is_empty() or BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() or BGMPlayer._season_player.playing:
		_fail("W19 physical location, cast or ambience did not match arrival=%s" % arrived)
		return false
	return true

func _check_full_chapter_card_ambience() -> bool:
	var cases := 0
	var cold := 0
	var next_room := 0
	for language: String in W4_TERMS:
		for event_id: String in FULL_CHAPTER_WEEKS:
			_context = "%s/full-chapter-card/%s" % [language, event_id]
			await _remove_story()
			await _stop_audio()
			# The static test owns the room instead of invoking MainGame's usual
			# post-story clearing. Do not let that prior case leak into a new run.
			GameState.returning_from_story = false
			LocaleManager.set_language(language)
			var turn: int = FULL_CHAPTER_WEEKS[event_id]
			if turn == 1:
				GameState.start_new_game()
				if not FULL_STORY_FLOW.initialize_fresh_run():
					return false
				GameState.flags["prologue_done"] = true
			else:
				var history: Array = [[192, "arc_year4_close"]] if turn == 193 else []
				if not _prepare_full_owner_history(turn, history):
					return false
				GameState.flags["prologue_done"] = true
				for earlier_age in range(34, GameState.age):
					GameState.flags["chapter_%d_seen" % earlier_age] = true
			var selector := load("res://scenes/MainGame.tscn").instantiate() as Control
			var actual_card: String = selector.call("_next_arc_id", -1, false, true)
			selector.free()
			if actual_card != event_id:
				_fail("full chapter selector chose %s instead of %s" % [actual_card, event_id])
				return false
			BGMPlayer.play_punctuation("grief")
			var score_token: int = BGMPlayer._punctuation_token
			var next: Array = ["arc_37_reckoning"] if turn == 193 else []
			if not await _open_full_fixture_event(event_id, next, true) or not _full_card_surface(event_id) \
					or BGMPlayer._current_key != "grief" or BGMPlayer._punctuation_token != score_token:
				_fail("location cleanup changed the previous score or card")
				return false
			cases += 1
			if language != "ko":
				continue
			var saved: Dictionary = _story.call("build_save_resume_context")
			var seen_before: int = GameState.events_seen
			if saved.get("event_id") != event_id or saved.get("phase") != "chapter" \
					or not SaveManager.save_game(W8_QA_SLOT, saved, {"qa_fixture": true}):
				_fail("could not save the actual chapter phase")
				return false
			await _remove_story()
			GameState.start_new_game()
			if not SaveManager.load_game(W8_QA_SLOT) or not FULL_STORY_FLOW.is_full_run():
				_fail("cold chapter could not restore its production owner")
				return false
			BGMPlayer.set_ambience("street")
			BGMPlayer.set_season_ambience("winter")
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			await _wait_stable()
			if not _full_card_surface(event_id) or GameState.events_seen != seen_before:
				_fail("cold title did not restore silence or replayed the card receipt")
				return false
			var old_title := (_story.get("_chapter_overlay") as Control).find_child("ChapterTitle", true, false) as Label
			var old_value := old_title.text
			_story.call("_set_story_language", "en")
			await get_tree().process_frame
			if LocaleManager.language != "en" or old_title.text == old_value \
					or old_title.text != str(DataRegistry.find_event(event_id).get("title", "")) \
					or not _full_card_surface(event_id):
				_fail("live language setting did not rebind the chapter title without bringing back the street")
				return false
			_story.set_meta("_screenshot_qa_static_surface", true)
			_story.call("_on_advance")
			await _wait_stable()
			if GameState.events_seen != seen_before + 1 or not bool(GameState.flags.get(
					"chapter_%s_seen" % event_id.right(2), false)) or not FULL_STORY_FLOW.valid_session():
				_fail("advancing changed or duplicated the exact chapter receipt")
				return false
			if turn == 193:
				if str((_story.get("_current") as Dictionary).get("id")) != "arc_37_reckoning" \
						or GameState.has_deferred_event("arc_37_reckoning") \
						or not _expect_surface(W4_ROOM, "room", "W193 physical room after title"):
					_fail("W193 title did not hand back the physical ambience to its actual deferred scene")
					return false
				next_room += 1
			cold += 1
	await _remove_story()
	await _stop_audio()
	# Existing non-full card presentation (including legacy 24 weeks) is not owned here.
	GameState.start_new_game()
	GameState.month = 1
	GameState.pending_story_queue = ["chapter_card_33"]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await _wait_stable()
	if FULL_STORY_FLOW.is_full_run() or BGMPlayer._current_ambience_key != "street" \
			or not bool(_story.get("_is_chapter_card")):
		_fail("non-full Chapter 1 compatibility surface changed")
		return false
	await _remove_story()
	await _stop_audio()
	if cases != 25 or cold != 5 or next_room != 1 or _failures != 0:
		return false
	print("FULL_CHAPTER_CARD_AMBIENCE_OK cards=%d cold=%d locale_rebind=%d score_kept=%d legacy_control=1 w193_handoff=%d" % [
		cases, cold, cold, cases, next_room])
	return true

func _full_card_surface(event_id: String) -> bool:
	var background := _story.get("_bg_img") as TextureRect
	var canvas := _story.get("_chapter_overlay") as Control
	var valid := bool(_story.get("_is_chapter_card")) and is_instance_valid(canvas) \
		and is_instance_valid(background) and background.texture == null \
		and str((_story.get("_current") as Dictionary).get("id")) == event_id \
		and BGMPlayer._current_ambience_key.is_empty() and not BGMPlayer._ambience_player.playing \
		and BGMPlayer._current_human_ambience_key.is_empty() and not BGMPlayer._human_ambience_player.playing \
		and BGMPlayer._current_season_key.is_empty() and not BGMPlayer._season_player.playing
	if not valid:
		_fail("locationless full card showed a place or kept a physical layer")
	return valid

func _check_daeun_store_audio(smoke: bool = false, capture_dir: String = "") -> bool:
	if not capture_dir.is_empty() and (DisplayServer.get_name() == "headless"
			or not DirAccess.dir_exists_absolute(capture_dir)):
		_fail("Daeun dry capture requires a real renderer and an existing output directory")
		return false
	if OS.get_environment("GANGNAM_DAEUN_DRY_COMPACT") == "1":
		# The project stretch otherwise retains a 1280×800 logical canvas.
		var root := get_tree().root
		root.content_scale_size = Vector2i(960, 600)
		root.size = Vector2i(960, 600)
		await get_tree().process_frame
		if get_viewport().get_visible_rect().size != Vector2(960, 600):
			_fail("Daeun compact check did not obtain a 960×600 logical viewport")
			return false
	if not _prepare_full_owner_history(35, [[5, "arc_intro_03_sns"], [6, "cafe_00", 2],
			[8, "arc_job_first_rejection"], [9, "arc_money_check_low"],
			[10, "arc_rescue_job", 1], [11, "arc_sangchul_01_meet"],
			[11, "arc_sangchul_01_measure"], [11, "arc_sangchul_01_answer"], [12, "arc_daeun_01_meet"],
			[14, "arc_invest_guidance"],
			[34, "arc_goshiwon_goodbye"], [34, "arc_housing_new_life"]]):
		return false
	GameState.housing = "oneroom"
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	var paths := 0
	var cold := 0
	var nights := 0
	var languages: Array = ["ko"] if smoke else W4_TERMS.keys()
	var choices: Array = [2] if smoke else range(DAEUN_RESULT_CGS.size())
	for language in languages:
		for choice in choices:
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			GameState.call("_restore_serialized_snapshot_exact", prepared)
			_context = "%s/Daeun conversation/c%d" % [language, choice]
			var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
			var selected: String = ingress.call("_next_arc_id", -1, true)
			ingress.free()
			if selected != DAEUN_AFTERNOON:
				_fail("Daeun W35 prepared calendar selected " + selected)
				return false
			if not await _open_full_fixture_event(DAEUN_AFTERNOON):
				return false
			for page in range((_story.get("_paragraphs") as Array).size()):
				var source: int = _story.call("_story_source_paragraph_index", page)
				var background := "convenience_afternoon" if source < 2 else "convenience_afternoon_exterior"
				if not _daeun_store_surface(background, "", source < 2, source < 2):
					return false
				await _finish_page()
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) \
					or not _daeun_store_surface("convenience_afternoon_exterior", "", false, false):
				_fail("Daeun choice dock must be outside and quiet")
				return false
			if choice == 2 and (not await _reload_prechoice("choices", DAEUN_AFTERNOON)
					or not _daeun_store_surface("convenience_afternoon_exterior", "", false, false)):
				return false
			var before := GameState.event_log.size()
			_story.call("_on_choice", choice)
			await _wait_stable()
			var seen_cut := [false, false]
			for page in range((_story.get("_paragraphs") as Array).size()):
				var source: int = _story.call("_story_source_paragraph_index", page)
				var revealed := source >= (2 if choice == 2 else 1)
				var art: String = DAEUN_RESULT_CGS[choice] if revealed else ""
				if not _daeun_store_surface("convenience_afternoon_exterior", art, false, false):
					return false
				await _finish_page()
				if not capture_dir.is_empty() and not seen_cut[int(revealed)]:
					var frame := "night_waiting_ko.png" if revealed else "afternoon_before_cut_ko.png"
					if not await _save_viewport_frame(capture_dir.path_join(frame)):
						return false
				if not seen_cut[int(revealed)]:
					# An inherited bed must not leak on either side of result restore.
					BGMPlayer.set_ambience("street")
					BGMPlayer.set_season_ambience("winter")
					if not await _reload_cut_result(choice, page, false):
						return false
					await _wait_stable()
					if not _daeun_store_surface("convenience_afternoon_exterior", art, false, false):
						return false
					if not capture_dir.is_empty() and revealed:
						await _finish_page()
						if not await _save_viewport_frame(capture_dir.path_join("night_waiting_loaded_ko.png")):
							return false
					cold += 1
					seen_cut[int(revealed)] = true
				if choice != 2 and page == (_story.get("_paragraphs") as Array).size() - 1:
					break
				_story.call("_on_advance")
				await _wait_stable()
			if not seen_cut[0] or not seen_cut[1] or GameState.event_log.size() != before + 1:
				_fail("Daeun result cut or exact receipt missing")
				return false
			if choice == 2:
				var night: Dictionary = _story.get("_current")
				if night.get("id") != DAEUN_EMPTY_STORE \
						or str(_story.get_meta("living_scene_effect", "")) != "none" \
						or not _daeun_store_surface("convenience_night_dry", "", true, false):
					_fail("Daeun quiet night follow-up did not resolve")
					return false
				if not capture_dir.is_empty():
					await _finish_page()
					if not await _capture_daeun_night(capture_dir.path_join("night_followup_ko.png")):
						return false
				nights += 1
			paths += 1
	await _remove_story()
	await _stop_audio()
	if paths != (1 if smoke else 15) or cold != (2 if smoke else 30) \
			or nights != (1 if smoke else 5) or _failures:
		return false
	print("DAEUN_STORE_AUDIO_OK paths=%d cold_result_v4=%d night_followup=%d full_owner=1" % [paths, cold, nights])
	return true

func _capture_daeun_night(path: String) -> bool:
	var portrait := _story.get("_portrait_frame") as Control
	var target_alpha: float = _story.get("_portrait_target_alpha")
	for _frame in range(150):
		if portrait.visible and portrait.modulate.a >= target_alpha - 0.01:
			return await _save_viewport_frame(path)
		await get_tree().process_frame
	_fail("Daeun's night portrait did not finish fading in")
	return false

func _daeun_store_surface(background: String, cg: String, fridge: bool, shoppers: bool) -> bool:
	var art := (_story.get("_bg_img") as TextureRect).texture
	var expected := ImageRegistry.get_background(background) if cg.is_empty() else ImageRegistry.get_cg(cg)
	var bed := "convenience" if fridge else ""
	var human := "convenience" if shoppers else ""
	if art == null or art.resource_path != expected \
			or BGMPlayer._current_ambience_key != bed or BGMPlayer._ambience_player.playing != fridge \
			or BGMPlayer._current_human_ambience_key != human or BGMPlayer._human_ambience_player.playing != shoppers:
		_fail("Daeun expected %s art and %s/%s bed and people; saw %s/%s" % [
			cg if not cg.is_empty() else background, bed, human,
			BGMPlayer._current_ambience_key, BGMPlayer._current_human_ambience_key])
		return false
	if cg == DAEUN_RESULT_CGS[2] and (art.resource_path != DAEUN_NIGHT_WAIT_ASSET \
			or (_story.get("_portrait_frame") as Control).visible):
		_fail("Daeun night result did not keep both figures solely in the exterior-to-interior CG")
		return false
	if not shoppers and (not BGMPlayer._current_season_key.is_empty() or BGMPlayer._season_player.playing):
		_fail("Daeun quiet cut kept an unrelated season bed")
		return false
	return true

func _check_w45_december_home(smoke: bool = false) -> bool:
	var homes := {"gosiwon": W4_ROOM, "oneroom": "apartment", "villa": "apartment",
		"apartment": "gangnam_apartment", "gangnam": "gangnam_apartment"}
	var languages: Array = ["ko"] if smoke else LocaleManager.SUPPORTED_LANGUAGES
	var houses: Array = ["gosiwon"] if smoke else homes.keys()
	var cases := 0
	var cold := 0
	for language: String in languages:
		for house: String in houses:
			for choice: int in ([0] if smoke else [0, 1]):
				await _remove_story()
				await _stop_audio()
				LocaleManager.set_language(language)
				_context = "%s/W45/%s/c%d" % [language, house, choice]
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 45
				GameState.age = 33
				GameState.month = 12
				GameState.week_of_month = 1
				GameState.housing = house
				GameState.mental = 60
				GameState.intelligence = 10
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var event_id := str(ingress.call("_next_milestone_id"))
				ingress.free()
				if event_id != W45_DECEMBER:
					_fail("W45 not selected by the December milestone producer")
					return false
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [event_id]
				BGMPlayer.set_ambience("room")
				BGMPlayer.set_season_ambience("winter")
				BGMPlayer.play_punctuation("reckoning")
				if not BGMPlayer._human_ambience_player.playing \
						or not BGMPlayer._season_player.playing or BGMPlayer._current_key != "reckoning":
					_fail("W45 fixture did not start with leaking layers")
					return false
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				for _frame in range(12):
					await get_tree().create_timer(0.055).timeout
					if not BGMPlayer._player_a.playing and not BGMPlayer._player_b.playing:
						break
				var background := str(homes[house])
				if not await _read_quiet_room_phase(W45_DECEMBER, background, false, 4):
					return false
				await _finish_page()
				_story.call("_on_advance")
				await _wait_stable()
				if not bool(_story.get("_showing_choices")) or not _expect_quiet_room(W45_DECEMBER, background, "choices"):
					_fail("W45 lost the local quiet choice surface")
					return false
				var events_seen := GameState.events_seen
				var cash: float = GameState.money
				_story.call("_on_choice", choice)
				await _wait_stable()
				if not await _read_quiet_room_phase(W45_DECEMBER, background, true, 1):
					return false
				if not smoke:
					var context: Dictionary = _story.call("build_save_resume_context")
					await _stop_audio()
					if not await _reload_authored_result_context(context, language, 1, 0) \
							or str((_story.get("_current") as Dictionary).get("id", "")) != W45_DECEMBER \
							or not bool(_story.get("_pending_after_result")) \
							or int(_story.get("_pending_result_choice_index")) != choice \
							or int(_story.call("_story_source_paragraph_count")) != 1 \
							or int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) != 0 \
							or not _expect_quiet_room(W45_DECEMBER, background, "cold result"):
						return false
					cold += 1
				if GameState.events_seen != events_seen + 1 or GameState.money != cash \
						or GameState.mental != (78 if choice == 0 else 57) \
						or GameState.intelligence != (10 if choice == 0 else 15) \
						or not GameState.flags.get("story_one_year_seen", false):
					_fail("W45 no longer applied the original choice exactly once")
					return false
				cases += 1
	if not smoke:
		print("W45_QUIET_HOME_OK paths=%d result_v4=%d languages=5 houses=5 choices=2" % [cases, cold])
	return cases == (1 if smoke else 50) and cold == (0 if smoke else 50)

func _check_w57_message_audio(smoke: bool = false) -> bool:
	var paths := 0
	var restores := 0
	var boundary_restores := 0
	var reflows := 0
	var render_dir := OS.get_environment("GANGNAM_W57_CAPTURE_DIR")
	if not render_dir.is_empty():
		var output := DirAccess.open(render_dir) if render_dir.is_absolute_path() else null
		if DisplayServer.get_name() == "headless" or output == null or not output.get_files().is_empty() \
				or not output.get_directories().is_empty():
			_fail("W57 capture requires a display and a fresh absolute output directory")
			return false
	var languages: Array = ["ko"] if smoke else LocaleManager.SUPPORTED_LANGUAGES
	for language: String in languages:
		for known: bool in ([false] if smoke else [false, true]):
			for choice: int in [0, 1, 2]:
				await _remove_story()
				await _stop_audio()
				_context = "%s/W57/known=%s/c%d" % [language, known, choice]
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 57
				GameState.month = 3
				GameState.age = 34
				GameState.mental = 60
				GameState.flags["arc_father_02_done"] = true
				GameState.flags["arc_daeun_fork_seen"] = known
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var selected := str(ingress.call("_story_graph_contract_event_id", 57, GameState.flags, false))
				ingress.free()
				if selected != W57_MEDICATION:
					_fail("W57 prepared calendar state did not select the medication event")
					return false
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [selected]
				AudioManager._last_sfx_ms.erase("phone_vibrate")
				BGMPlayer.set_ambience("subway")
				BGMPlayer.set_season_ambience("winter")
				if not BGMPlayer._ambience_player.playing or not BGMPlayer._human_ambience_player.playing \
						or not BGMPlayer._season_player.playing:
					_fail("W57 fixture did not start with the inaccurate transit layers")
					return false
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				var expect_vibration := true
				if not _expect_w57_audio(true, "opening") or not _expect_w57_art(-1, 0) \
						or int(_story.call("_story_source_paragraph_count")) != 4:
					return false
				var vibration: AudioStream = AudioManager._sounds.get("phone_vibrate")
				var played_at := int(AudioManager._last_sfx_ms.get("phone_vibrate", -1))
				var playing := AudioManager._pool.filter(func(player: AudioStreamPlayer) -> bool:
					return player.playing and player.stream == vibration)
				if vibration == null or played_at < 0 or playing.size() != 1:
					_fail("W57 opening did not actually start one authored vibration recording")
					return false
				if not smoke and choice == 0:
					await _finish_page()
					if not render_dir.is_empty() and not known:
						await get_tree().create_timer(0.42).timeout
						if not await _save_viewport_frame(render_dir.path_join(language + "_transfer.png")):
							return false
					if not await _reload_prechoice("prose", W57_MEDICATION, false) \
							or not _expect_w57_audio(false, "restored opening") or not _expect_w57_art(-1, 0):
						return false
					expect_vibration = false
					restores += 1
				for page in range((_story.get("_paragraphs") as Array).size()):
					await _finish_page()
					if int(_story.get("_para_index")) != page or not _expect_w57_audio(expect_vibration, "prose") \
							or not _expect_w57_art(-1, 0):
						return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")) or not _expect_w57_audio(expect_vibration, "choices") \
						or not _expect_w57_art(-1, 0):
					return false
				var cash: float = GameState.money
				var events := GameState.events_seen
				_story.call("_on_choice", choice)
				await _wait_stable()
				if not bool(_story.get("_pending_after_result")) or int(_story.call("_story_source_paragraph_count")) != 3:
					return false
				var pages: Array = _story.get("_paragraphs")
				var cut := int(_story.get("_result_location_cut_page"))
				var cut_anchors := W57_CAR_START if choice == 1 else W57_GATE_START
				if choice > 0 and (cut <= 0 or cut >= pages.size() \
						or not str(pages[cut]).begins_with(str(_story.call("_fmt", cut_anchors[language])))):
					_fail("W57 travel did not start at its authored sentence")
					return false
				var arrival_context: Dictionary = {}
				for page in range(pages.size()):
					if not smoke and choice > 0 and page == cut:
						if not await _reload_authored_result_context(arrival_context, language, 3, 1, true) \
								or not _expect_w57_saved_boundary(arrival_context, page, true) \
								or not _expect_w57_art(choice, 1, true) \
								or not _expect_w57_audio(false, "restored arrival", choice == 1):
							return false
						expect_vibration = false
						boundary_restores += 1
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					var after_cut := choice > 0 and source == 1 and page >= cut
					var onboard := choice == 1 and after_cut
					if int(_story.get("_para_index")) != page \
							or not _expect_w57_audio(expect_vibration, "result", onboard) \
							or not _expect_w57_art(choice, source, after_cut):
						return false
					if not smoke and choice > 0 and page == cut - 1:
						var reply_context: Dictionary = _story.call("build_save_resume_context")
						if not await _reload_authored_result_context(reply_context, language, 3, 1, true) \
								or not _expect_w57_saved_boundary(reply_context, page, false) \
								or not _expect_w57_art(choice, 1, false) \
								or not _expect_w57_audio(false, "restored before travel"):
							return false
						expect_vibration = false
						boundary_restores += 1
					if not smoke and language == "ko" and not known and choice > 0 and page in [cut - 1, cut]:
						for target in ["en", "ko"]:
							var cursor: float = BGMPlayer._ambience_player.get_playback_position()
							_story.call("_set_story_language", target)
							await _wait_stable()
							if LocaleManager.language != target or not _expect_w57_art(choice, 1, after_cut) \
									or not _expect_w57_audio(false, "language switch", onboard) \
									or (onboard and BGMPlayer._ambience_player.get_playback_position() + 0.03 < cursor):
								return false
							reflows += 1
						await _finish_page()
					if not render_dir.is_empty() and not known and source > 0 \
							and page == int(_story.call("_first_story_page_for_source", source)):
						if not await _save_viewport_frame(render_dir.path_join("%s_c%d_p%d.png" % [language, choice, source])):
							return false
					if after_cut and page == cut and not render_dir.is_empty() and not known:
						await get_tree().create_timer(0.45).timeout
						var prefix := "_subway_onboard.png" if onboard else "_changwon_gate.png"
						if not await _save_viewport_frame(render_dir.path_join(language + prefix)):
							return false
					if page < pages.size() - 1:
						_story.call("_on_advance")
						if choice == 1 and source == 1 \
								and int(_story.call("_story_source_paragraph_index", page + 1)) == 2 \
								and not _expect_w57_audio(expect_vibration, "immediate exit"):
							return false
						if not smoke and choice > 0 and page + 1 == cut:
							# Snapshot the new display page before a frame types a single character.
							_story.call("_finish_story_scene_transition")
							arrival_context = _story.call("build_save_resume_context")
						await _wait_stable()
				if not smoke:
					var context: Dictionary = _story.call("build_save_resume_context")
					if not await _reload_authored_result_context(context, language, 3, 2) \
							or int(_story.get("_pending_result_choice_index")) != choice \
							or not _expect_w57_audio(false, "restored result") or not _expect_w57_art(choice, 2):
						return false
					restores += 1
				var branch_flags := ["called_about_medication", "ignored_medication_signal", "visited_for_medication"]
				if GameState.events_seen != events + 1 or not GameState.flags.get(branch_flags[choice], false) \
						or GameState.money != cash - (50_000.0 if choice == 2 else 0.0) \
						or GameState.mental != (65 if choice == 2 else 55):
					_fail("W57 changed original choice semantics on playback or restore")
					return false
				if int(AudioManager._last_sfx_ms.get("phone_vibrate", -1)) != played_at:
					_fail("W57 vibration played a second time after the received message")
					return false
				paths += 1
	if not smoke:
		print("W57_MEDICATION_AUDIO_OK paths=%d v4_restores=%d languages=5 variants=2 choices=3" % [paths, restores])
		print("W57_TRAVEL_CUTS_OK boundary_v4=%d reflows=%d" % [boundary_restores, reflows])
	return paths == (3 if smoke else 30) and restores == (0 if smoke else 40) \
		and boundary_restores == (0 if smoke else 40) and reflows == (0 if smoke else 8)

func _expect_w57_saved_boundary(context: Dictionary, page: int, at_start: bool) -> bool:
	var type_pos := 0 if at_start else str(_story.get("_type_full")).length()
	if int(context.get("paragraph_index", -1)) != page \
			or bool(context.get("paragraph_was_typing", false)) != at_start \
			or not is_equal_approx(float(context.get("paragraph_type_ratio", -1.0)), 0.0 if at_start else 1.0) \
			or int(_story.get("_para_index")) != page or int(_story.get("_type_pos")) != type_pos \
			or bool(_story.get("_typing")) != at_start:
		_fail("W57 did not preserve exact reply/arrival cursor for page %d start=%s" % [page, at_start])
		return false
	return true

func _expect_w57_art(choice: int, source: int, after_cut: bool = false) -> bool:
	var expected_background := W57_PASSAGE
	if source > 0 and choice == 1:
		expected_background = (W57_CAR if after_cut else "") if source == 1 \
			else ImageRegistry.resolve_contextual_background_id("current_housing")
	elif source > 0 and choice == 2:
		expected_background = W57_TABLE if source == 2 else W57_GATE if after_cut else ""
	var expected_channel := "message"
	if choice >= 0 and not (choice != 0 and source == 0):
		expected_channel = "phone" if choice == 0 and source < 2 else "narration"
	if choice == 2 and source == 1:
		expected_channel = "in_person" if after_cut else "message"
	var badge := _story.get("_communication_badge") as Control
	var presentation := _story.get("_current_presentation") as Dictionary
	var art := (_story.get("_bg_img") as TextureRect).texture
	var portrait := _story.get("_portrait") as TextureRect
	var frame := _story.get("_portrait_frame") as Control
	var ambience := "seoul_subway_onboard" if expected_background == W57_CAR else ""
	var background_ok: bool = _expect_surface(expected_background, ambience, "W57") if not expected_background.is_empty() else (
		art == null and str(_story.get("_event_background_id")).is_empty() and (_story.get("_bg_dim") as ColorRect).color == Color("#111216"))
	if not background_ok or str(presentation.get("channel", "")) != expected_channel \
			or badge.visible != (expected_channel in ["message", "phone"]) \
			or str(_story.get_meta("living_scene_effect", "")) != "none":
		_fail("W57 wrong background/channel for c%d source %d; expected %s/%s" % [choice, source, expected_background, expected_channel])
		return false
	if choice == 2 and source > 0:
		var expected_portrait := "father_normal" if after_cut else "" if source == 2 else "player_tired"
		if str(_story.call("_resolved_story_surface_portrait_id")) != expected_portrait \
				or frame.visible != (not expected_portrait.is_empty()) \
				or (not expected_portrait.is_empty() and (portrait.texture == null \
					or portrait.texture.resource_path != ImageRegistry.get_portrait(expected_portrait))) \
				or presentation.has("remote_location") \
				or str(presentation.get("remote_actor", "")) != ("father" if source == 1 and not after_cut else ""):
			_fail("W57 father appeared before arrival, was missing at the gates, or remained at the table")
			return false
	return true

func _expect_w57_audio(expect_vibration: bool, label: String, onboard: bool = false) -> bool:
	var heard := AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(W57_MEDICATION + ":"))
	var rail := BGMPlayer._ambience_player
	var rail_ok := BGMPlayer._current_ambience_key.is_empty() and not rail.playing
	if onboard:
		var expected := load("res://assets/audio/amb_seoul_subway_onboard.wav") as AudioStreamWAV
		var actual := rail.stream as AudioStreamWAV
		rail_ok = BGMPlayer._current_ambience_key == "seoul_subway_onboard" and rail.playing \
			and expected != null and actual != null and actual.loop_mode == AudioStreamWAV.LOOP_FORWARD \
			and actual.data == expected.data and actual.mix_rate == expected.mix_rate and actual.stereo
	var valid := heard == ([W57_VIBRATION] if expect_vibration else []) \
		and rail_ok \
		and BGMPlayer._current_human_ambience_key.is_empty() and not BGMPlayer._human_ambience_player.playing \
		and BGMPlayer._current_season_key.is_empty() and not BGMPlayer._season_player.playing
	if not valid:
		_fail("W57 wrong audio at %s: cues=%s, bed=%s, human=%s, season=%s" % [label, heard,
			BGMPlayer._current_ambience_key, BGMPlayer._current_human_ambience_key, BGMPlayer._current_season_key])
	return valid

func _check_w82_bus(smoke: bool = false) -> bool:
	var paths := 0
	var restores := 0
	var capture := OS.get_environment("GANGNAM_W82_CAPTURE_DIR")
	if not capture.is_empty():
		var out := DirAccess.open(capture) if capture.is_absolute_path() else null
		if DisplayServer.get_name() == "headless" or out == null or not out.get_files().is_empty():
			_fail("W82 captures require a native display and a fresh directory")
			return false
	var languages: Array = ["ko"] if smoke else LocaleManager.SUPPORTED_LANGUAGES
	for language: String in languages:
		for choice: int in [0, 1]:
			await _remove_story()
			await _stop_audio()
			_context = "%s/W82/c%d" % [language, choice]
			LocaleManager.set_language(language)
			SaveManager.clear_loaded_resume_context()
			GameState.start_new_game()
			GameState.turn = 82
			GameState.age = 34
			GameState.month = 9
			GameState.housing = "oneroom"
			GameState.mental = 60
			GameState.flags["arc_intro_hyunsu_seen"] = true
			GameState.story_return_scene = "res://scenes/MainGame.tscn"
			GameState.pending_story_queue = [W82_BUS]
			BGMPlayer.set_ambience("highway")
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			var home := ImageRegistry.resolve_contextual_background_id("current_housing")
			for page in range((_story.get("_paragraphs") as Array).size()):
				await _finish_page()
				if int(_story.get("_para_index")) != page or not _expect_w82_surface(home, "phone"):
					return false
				if page == 0 and choice == 0 and not capture.is_empty() \
						and not await _save_viewport_frame(capture.path_join(language + "_phone.png")):
					return false
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) or not _expect_w82_surface(home, "phone"):
				return false
			var cash := float(GameState.money)
			var count: int = GameState.events_seen
			_story.call("_on_choice", choice)
			await _wait_stable()
			var pages: Array = _story.get("_paragraphs")
			var cut := int(_story.get("_result_location_cut_page"))
			var locale_index := LocaleManager.SUPPORTED_LANGUAGES.find(language)
			if not bool(_story.get("_pending_after_result")) or int(_story.call("_story_source_paragraph_count")) != 3 \
					or cut <= 0 or cut >= pages.size() or locale_index < 0 \
					or not str(pages[cut]).begins_with(str(W82_CUT_SENTENCES[choice][locale_index])):
				_fail("W82 missing the exact localized arrival or hangup cut")
				return false
			for page in range(pages.size()):
				await _finish_page()
				var source := int(_story.call("_story_source_paragraph_index", page))
				var arrived := choice == 0 and source == 0 and page >= cut
				var location := home if choice == 1 else (
					W82_TERMINAL if arrived else W82_DEPARTURE if source == 1 else "")
				var channel := "in_person" if arrived else "phone" if choice == 1 and page < cut else "narration"
				if int(_story.get("_para_index")) != page or not _expect_w82_surface(location, channel):
					return false
				if page in [cut - 1, cut] or page == pages.size() - 1:
					if not smoke:
						var context: Dictionary = _story.call("build_save_resume_context")
						if not await _reload_authored_result_context(context, language, 3, source) \
								or int(_story.get("_para_index")) != page or not _expect_w82_surface(location, channel):
							return false
						restores += 1
				if not capture.is_empty():
					await get_tree().create_timer(0.5).timeout
					if not await _save_viewport_frame(capture.path_join("%s_c%d_p%d.png" % [language, choice, page])):
						return false
				if page + 1 < pages.size():
					_story.call("_on_advance")
					await _wait_stable()
			if GameState.events_seen != count + 1 or not GameState.flags.get("arc_y2_hyunsu_night_bus_seen", false) \
					or GameState.money != cash + (30000.0 if choice == 1 else 0.0) \
					or GameState.mental != (66 if choice == 0 else 60):
				_fail("W82 changed a saved choice result")
				return false
			paths += 1
	if not smoke:
		print("W82_BUS_OK paths=%d v4=%d" % [paths, restores])
	return paths == (2 if smoke else 10) and restores == (0 if smoke else 30)

func _expect_w82_surface(background: String, channel: String) -> bool:
	var portrait := _story.get("_portrait_frame") as Control
	var badge := _story.get("_communication_badge") as Control
	var presentation: Dictionary = _story.get("_current_presentation")
	var texture := (_story.get("_bg_img") as TextureRect).texture
	var location_ok := (texture == null and str(_story.get("_event_background_id")).is_empty() \
		and (_story.get("_bg_dim") as ColorRect).color == Color("#111216") \
		and str(_story.get_meta("living_scene_effect", "")) == "none") if background.is_empty() \
		else _expect_surface(background, "", "W82 bus")
	if not location_ok or str(presentation.get("channel", "")) != channel \
			or badge.visible != (channel == "phone") or bool(_story.get("_portrait_remote_inset")) != (channel == "phone") \
			or portrait.visible != (channel != "narration") or BGMPlayer._ambience_player.playing \
			or BGMPlayer._human_ambience_player.playing or BGMPlayer._season_player.playing:
		_fail("W82 carried a location, actor or audio layer across the wrong beat")
		return false
	return true

func _check_w69_steps(smoke: bool = false) -> bool:
	var paths := 0
	var restores := 0
	var capture := OS.get_environment("GANGNAM_W69_CAPTURE_DIR")
	if not capture.is_empty():
		var output := DirAccess.open(capture) if capture.is_absolute_path() else null
		if DisplayServer.get_name() == "headless" or output == null \
				or not output.get_files().is_empty() or not output.get_directories().is_empty():
			_fail("W69 captures need a native display and a fresh directory")
			return false
	var languages: Array = ["ko"] if smoke else LocaleManager.SUPPORTED_LANGUAGES
	for language: String in languages:
		for choice: int in ([0] if smoke else [0, 1, 2]):
			await _remove_story()
			await _stop_audio()
			_context = "%s/W69/c%d" % [language, choice]
			LocaleManager.set_language(language)
			SaveManager.clear_loaded_resume_context()
			GameState.start_new_game()
			GameState.turn = 69
			GameState.age = 34
			GameState.month = 6
			GameState.mental = 60
			GameState.story_return_scene = "res://scenes/MainGame.tscn"
			GameState.pending_story_queue = [W69_STORE]
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			if not _expect_w69_surface(false) or int(_story.call("_story_source_paragraph_count")) != 3:
				return false
			for page in range((_story.get("_paragraphs") as Array).size()):
				await _finish_page()
				if int(_story.get("_para_index")) != page or not _expect_w69_surface(false):
					return false
				if page == 0 and choice == 0 and not capture.is_empty():
					await get_tree().create_timer(0.5).timeout
					if not await _save_viewport_frame(capture.path_join(language + "_inside.png")):
						return false
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) or not _expect_w69_surface(false):
				return false
			var count: int = GameState.events_seen
			var cash: float = GameState.money
			_story.call("_on_choice", choice)
			var outside := choice == 0
			if outside and not _expect_w69_surface(true):
				return false
			await _wait_stable()
			var pages: Array = _story.get("_paragraphs")
			if not bool(_story.get("_pending_after_result")) or int(_story.call("_story_source_paragraph_count")) != 2:
				return false
			for page in range(pages.size()):
				await _finish_page()
				if int(_story.get("_para_index")) != page or not _expect_w69_surface(outside):
					return false
				if outside and not capture.is_empty() and page == int(_story.call(
						"_first_story_page_for_source", _story.call("_story_source_paragraph_index", page))):
					await get_tree().create_timer(0.5).timeout
					if not await _save_viewport_frame(capture.path_join("%s_steps_%d.png" % [language, page])):
						return false
				if page + 1 < pages.size():
					_story.call("_on_advance")
					await _wait_stable()
			if not smoke:
				var context: Dictionary = _story.call("build_save_resume_context")
				if not await _reload_authored_result_context(context, language, 2, 1) or not _expect_w69_surface(outside):
					return false
				restores += 1
			var next := GameState.deferred_events.filter(func(item: Dictionary) -> bool:
				return item.get("event_id") == "arc_34_two_years_in")
			if GameState.events_seen != count + 1 or GameState.money != cash \
					or GameState.mental != [65, 55, 62][choice] \
					or not GameState.flags.get("arc_year_one_half_seen", false) \
					or next.size() != 1 or int(next[0].get("trigger_turn", -1)) != 87:
				_fail("W69 changed a choice or its 18-week follow-up")
				return false
			paths += 1
	if not smoke:
		print("W69_STEPS_OK paths=%d v4=%d" % [paths, restores])
	return paths == (1 if smoke else 15) and restores == (0 if smoke else 15)

func _expect_w69_surface(outside: bool) -> bool:
	if not _expect_surface(W69_STEPS if outside else W69_INSIDE,
			"" if outside else "convenience", "W69 store") \
			or str(_story.get_meta("living_scene_effect", "")) != "none" \
			or (outside and (BGMPlayer._ambience_player.playing \
				or BGMPlayer._human_ambience_player.playing or BGMPlayer._season_player.playing)):
		_fail("W69 wrong store surface, weather or surviving indoor audio")
		return false
	return true

func _check_w72_dinner_audio(smoke: bool = false) -> bool:
	var paths := 0
	var restores := 0
	var languages: Array = ["ko"] if smoke else LocaleManager.SUPPORTED_LANGUAGES
	for language: String in languages:
		for known: bool in ([false] if smoke else [false, true]):
			for choice: int in ([1] if smoke else [0, 1, 2]):
				await _remove_story()
				await _stop_audio()
				_context = "%s/W72/known=%s/c%d" % [language, known, choice]
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 72
				GameState.age = 34
				GameState.month = 6
				GameState.flags["arc_sangchul_offguard_seen"] = true
				GameState.flags["sangchul_truth_known"] = known
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				# Both preserved W72 runs already demonstrate foreground ingress.
				# Isolate the actual StoryMode scene without fabricating 71 earlier weeks.
				GameState.pending_story_queue = [W72_DINNER]
				BGMPlayer.set_ambience("hoesik")
				BGMPlayer.set_season_ambience("summer")
				if not BGMPlayer._ambience_player.playing or not BGMPlayer._human_ambience_player.playing \
						or not BGMPlayer._season_player.playing:
					_fail("W72 test did not enter from the inappropriate sound layers")
					return false
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				if not _expect_w72_dinner() or int(_story.call("_story_source_paragraph_count")) != (3 if known else 4):
					return false
				for page in range((_story.get("_paragraphs") as Array).size()):
					await _finish_page()
					if int(_story.get("_para_index")) != page or not _expect_w72_dinner():
						return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")) or not _expect_w72_dinner():
					return false
				var event_count: int = GameState.events_seen
				var cash: float = GameState.money
				_story.call("_on_choice", choice)
				await _wait_stable()
				var pages: Array = _story.get("_paragraphs")
				if not bool(_story.get("_pending_after_result")) or int(_story.call("_story_source_paragraph_count")) != 2:
					return false
				for page in range(pages.size()):
					await _finish_page()
					if int(_story.get("_para_index")) != page or not _expect_w72_dinner():
						return false
					if page + 1 < pages.size():
						_story.call("_on_advance")
						await _wait_stable()
				if not smoke:
					var context: Dictionary = _story.call("build_save_resume_context")
					BGMPlayer.set_ambience("hoesik")
					BGMPlayer.set_season_ambience("summer")
					if not await _reload_authored_result_context(context, language, 2, 1, true) \
							or not _expect_w72_dinner():
						return false
					restores += 1
				if GameState.events_seen != event_count + 1 or GameState.money != cash \
						or not bool(GameState.flags.get("arc_sangchul_human_seen", false)) \
						or bool(GameState.flags.get("shared_with_sangchul", false)) != (choice == 0) \
						or bool(GameState.flags.get("sangchul_deflected", false)) != (choice == 2):
					_fail("W72 changed a choice result")
					return false
				paths += 1
	if not smoke:
		print("W72_DINNER_AUDIO_OK paths=%d v4=%d" % [paths, restores])
	return paths == (1 if smoke else 30) and restores == (0 if smoke else 30)

func _expect_w72_dinner() -> bool:
	var texture := (_story.get("_portrait") as TextureRect).texture
	if not _expect_surface("restaurant", "", "W72 dinner") \
			or texture == null or texture.resource_path != ImageRegistry.get_portrait("sangchul_normal") \
			or BGMPlayer._ambience_player.playing or BGMPlayer._human_ambience_player.playing \
			or BGMPlayer._season_player.playing or not BGMPlayer._current_human_ambience_key.is_empty() \
			or not BGMPlayer._current_season_key.is_empty():
		_fail("W72 brought the bar, pub or outdoor seasonal bed to dinner")
		return false
	return true

func _check_w53_dining_audio(smoke: bool = false) -> bool:
	var languages: Array = ["ko"] if smoke else LocaleManager.SUPPORTED_LANGUAGES
	var capture_dir := OS.get_environment("GANGNAM_W53_CAPTURE_DIR")
	if not capture_dir.is_empty():
		var output := DirAccess.open(capture_dir) if capture_dir.is_absolute_path() else null
		if DisplayServer.get_name() == "headless" or output == null \
				or not output.get_files().is_empty() or not output.get_directories().is_empty():
			_fail("W53 capture requires a display and a fresh absolute output directory")
			return false
	var cases := 0
	var cold := 0
	var prose_restores := 0
	var rebinds := 0
	for language: String in languages:
		for known: bool in ([false] if smoke else [false, true]):
			for choice: int in ([0] if smoke else [0, 1]):
				await _remove_story()
				await _stop_audio()
				LocaleManager.set_language(language)
				_context = "%s/W53/known=%s/c%d" % [language, known, choice]
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 53
				GameState.age = 34
				GameState.month = 2
				GameState.week_of_month = 1
				GameState.mental = 60
				GameState.flags["sangchul_truth_known"] = known
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [W53_NETWORK]
				BGMPlayer.set_ambience("cafe")
				BGMPlayer.set_season_ambience("winter")
				BGMPlayer.play_punctuation("reckoning")
				if not BGMPlayer._ambience_player.playing or not BGMPlayer._human_ambience_player.playing \
						or not BGMPlayer._season_player.playing or BGMPlayer._current_key != "reckoning":
					_fail("W53 fixture did not start with both café recordings and unrelated sound layers")
					return false
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				for _frame in range(12):
					await get_tree().create_timer(0.055).timeout
					if not BGMPlayer._player_a.playing and not BGMPlayer._player_b.playing:
						break
				if int(_story.call("_story_source_paragraph_count")) != (4 if known else 5):
					_fail("W53 original prose boundaries changed")
					return false
				var paragraphs: Array = _story.get("_paragraphs")
				for page in range(paragraphs.size()):
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					var invitation := not known and source == 0
					if not _expect_w53_surface(not invitation, not invitation, "prose/%d" % page):
						return false
					if not smoke and not known and choice == 1 and source < 2 \
							and page == int(_story.call("_first_story_page_for_source", source)):
						if not capture_dir.is_empty() and not await _capture_w53_frame(capture_dir, language,
								"invitation" if invitation else "arrival"):
							return false
						BGMPlayer.set_ambience("cafe")
						if not await _reload_prechoice("prose", W53_NETWORK, false) \
								or not _expect_w53_surface(not invitation, not invitation, "restored prose"):
							return false
						prose_restores += 1
						if language == "ko":
							if not await _rebind_w53_surface(not invitation, not invitation, source):
								return false
							rebinds += 2
					if page + 1 < paragraphs.size():
						_story.call("_on_advance")
						await _wait_stable()
				_story.call("_on_advance")
				await _wait_stable()
				if not bool(_story.get("_showing_choices")) or not _expect_w53_surface(true, true, "choices"):
					_fail("W53 lost its original choice surface")
					return false
				var events_seen := GameState.events_seen
				var cash: float = GameState.money
				_story.call("_on_choice", choice)
				await _wait_stable()
				var sources := 1 if choice == 0 else 2
				if not bool(_story.get("_pending_after_result")) or int(_story.call("_story_source_paragraph_count")) != sources:
					_fail("W53 original result boundaries changed")
					return false
				paragraphs = _story.get("_paragraphs")
				for page in range(paragraphs.size()):
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					if not _expect_w53_surface(source == 0, true, "result/%d" % page):
						return false
					if not known and choice == 1 and page == int(_story.call("_first_story_page_for_source", source)):
						if not capture_dir.is_empty() and not await _capture_w53_frame(capture_dir, language,
								"results_inside" if source == 0 else "departure"):
							return false
						if language == "ko":
							if not await _rebind_w53_surface(source == 0, true, source):
								return false
							rebinds += 2
					if page + 1 < paragraphs.size():
						_story.call("_on_advance")
						await _wait_stable()
				if not smoke:
					var context: Dictionary = _story.call("build_save_resume_context")
					await _stop_audio()
					if not await _reload_authored_result_context(context, language, sources, sources - 1) \
							or str((_story.get("_current") as Dictionary).get("id", "")) != W53_NETWORK \
							or not bool(_story.get("_pending_after_result")) \
							or int(_story.get("_pending_result_choice_index")) != choice \
							or int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) != sources - 1 \
							or not _expect_w53_surface(choice == 0, true, "cold result"):
						return false
					cold += 1
				var promises := GameState.deferred_events.filter(func(event: Dictionary) -> bool:
					return event.get("event_id") == "callback_shadow_investors_proposal")
				if GameState.events_seen != events_seen + 1 or GameState.money != cash \
						or GameState.mental != (58 if choice == 0 else 56) \
						or not GameState.flags.get("arc_sangchul_03_seen", false) \
						or GameState.flags.get("entered_network", false) != (choice == 0) \
						or GameState.flags.get("approached_shadow_investors", false) != (choice == 1) \
						or promises.size() != choice \
						or (choice == 1 and int(promises[0].get("trigger_turn", -1)) != 65):
					_fail("W53 changed the original result or the 12-week investor follow-up")
					return false
				cases += 1
	if not smoke:
		print("W53_DINING_CUT_OK paths=%d result_v4=%d prose_restores=%d rebinds=%d languages=5 branches=2 choices=2" % [
			cases, cold, prose_restores, rebinds])
	return cases == (1 if smoke else 20) and cold == (0 if smoke else 20) \
		and prose_restores == (0 if smoke else 10) and rebinds == (0 if smoke else 8)

func _expect_w53_surface(dining: bool, with_sangchul: bool, label: String) -> bool:
	var art := (_story.get("_bg_img") as TextureRect).texture
	var portrait := _story.get("_portrait") as TextureRect
	var frame := _story.get("_portrait_frame") as Control
	var nameplate := _story.get("_name_panel") as Control
	var badge := _story.get("_communication_badge") as Control
	var place_ok: bool = _expect_quiet_room(W53_NETWORK, W53_DINING, label) if dining else (
		art == null and str(_story.get("_event_background_id")).is_empty()
		and (_story.get("_bg_dim") as ColorRect).color == Color("#111216")
		and BGMPlayer._current_ambience_key.is_empty() and not BGMPlayer._ambience_player.playing
		and BGMPlayer._current_human_ambience_key.is_empty() and not BGMPlayer._human_ambience_player.playing
		and BGMPlayer._current_season_key.is_empty() and not BGMPlayer._season_player.playing
		and BGMPlayer._current_key.is_empty() and not BGMPlayer._player_a.playing and not BGMPlayer._player_b.playing
		and str(_story.get_meta("living_scene_effect", "")) == "none"
		and not AudioManager._story_audio_seen.keys().any(func(key: String) -> bool: return key.begins_with(W53_NETWORK + ":")))
	if not place_ok or frame.visible != with_sangchul or (portrait.texture != null) != with_sangchul \
			or (with_sangchul and portrait.texture.resource_path != ImageRegistry.get_portrait("sangchul_normal")) \
			or (not with_sangchul and nameplate.visible) or badge.visible:
		_fail("W53 incorrect place or person at %s: dining=%s Sangchul=%s" % [label, dining, with_sangchul])
		return false
	return true

func _rebind_w53_surface(dining: bool, with_sangchul: bool, source: int) -> bool:
	for target in ["en", "ko"]:
		_story.call("_set_story_language", target)
		await _wait_stable()
		if LocaleManager.language != target \
				or int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) != source \
				or not _expect_w53_surface(dining, with_sangchul, "language change"):
			_fail("W53 language change crossed a location boundary")
			return false
	return true

func _capture_w53_frame(capture_dir: String, language: String, label: String) -> bool:
	var frame := _story.get("_portrait_frame") as Control
	for _frame in range(150):
		if not frame.visible or frame.modulate.a >= 0.99:
			return await _save_viewport_frame(capture_dir.path_join(language + "_" + label + ".png"))
		await get_tree().process_frame
	_fail("W53 portrait never settled for capture")
	return false

func _read_quiet_room_phase(event_id: String, background: String, result: bool, expected_count: int) -> bool:
	var count := int(_story.call("_story_source_paragraph_count"))
	if count != expected_count or bool(_story.get("_pending_after_result")) != result:
		_fail("%s original prose/result boundaries changed" % event_id)
		return false
	var pages: Array = _story.get("_paragraphs")
	for page in range(pages.size()):
		await _finish_page()
		if int(_story.get("_para_index")) != page or not _expect_quiet_room(
				event_id, background, "result=%s/page%d" % [result, page]):
			return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	return not pages.is_empty()

func _check_w48_lights_out(smoke: bool = false) -> bool:
	var languages: Array = ["ko"] if smoke else LocaleManager.SUPPORTED_LANGUAGES
	for language: String in languages:
		for passed: bool in ([false] if smoke else [false, true]):
			var root := W48_YEAR_CLOSE_PASSED if passed else W48_YEAR_CLOSE
			for choice: int in ([2] if smoke else [0, 1, 2]):
				_context = "%s/W48/%s/c%d" % [language, root, choice]
				await _remove_story()
				await _stop_audio()
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 48
				GameState.month = 12
				GameState.week_of_month = 4
				GameState.housing = "gosiwon"
				GameState.flags = {"prologue_done": true, "father_passed": passed}
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [W48_YEAR_CLOSE]
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				await _wait_stable()
				if str((_story.get("_current") as Dictionary).get("id", "")) != root:
					_fail("W48 fixture missed the correct live family variant")
					return false
				for _page in range(20):
					if bool(_story.get("_showing_choices")):
						break
					await _finish_page()
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")) or not _expect_surface(W48_GOSHIWON, "room", "choices"):
					_fail("W48 changed the lit choice surface")
					return false
				_story.call("_on_choice", choice)
				await _wait_stable()
				var pages: Array = _story.get("_paragraphs")
				if pages.is_empty():
					_fail("W48 lost an authored result")
					return false
				var saw_dark := false
				for page in range(pages.size()):
					var dark := choice == 2 and int(_story.call("_story_source_paragraph_index", page)) == 1
					saw_dark = saw_dark or dark
					var overlay := _story.get("_wedding_lights_out") as ColorRect
					if int(_story.get("_para_index")) != page or overlay.visible != dark \
							or not _expect_surface(W48_GOSHIWON, "" if dark else "room", "result/%d" % page) \
							or (not dark and (not BGMPlayer._ambience_player.playing \
								or not BGMPlayer._human_ambience_player.playing \
								or BGMPlayer._current_human_ambience_key != "thin_wall")) \
							or (dark and (not _expect_no_ambience("W48 blackout") \
								or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing)):
						_fail("W48 blackout or ambient stop escaped its authored page")
						return false
					await _finish_page()
					if page + 1 < pages.size():
						_story.call("_on_advance")
						await _wait_stable()
				if saw_dark != (choice == 2):
					_fail("W48 lost the lights-out branch")
					return false
	return true

func _check_m07_washbasin(smoke: bool = false) -> bool:
	var languages: Array = ["ko"] if smoke else M07_BASIN_WORDS.keys()
	for language: String in languages:
		for choice in range(2):
			_context = "%s/M07/c%d" % [language, choice]
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			SaveManager.clear_loaded_resume_context()
			GameState.start_new_game()
			GameState.turn = 26
			GameState.month = 7
			GameState.week_of_month = 2
			GameState.housing = "gosiwon"
			GameState.flags = {"prologue_done": true, "hyunsu_exam_day_seen": true}
			GameState.story_return_scene = "res://scenes/MainGame.tscn"
			GameState.pending_story_queue = [M07_HYUNSU_RESULT]
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			await _wait_stable()
			for _page in range(16):
				if bool(_story.get("_showing_choices")):
					break
				await _finish_page()
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) \
					or not _expect_surface(M07_HALL, "apartment", "choices"):
				_fail("M07 choices must remain in the hall")
				return false
			_story.call("_on_choice", choice)
			await _wait_stable()
			var places := [M07_HALL, M07_EXAM_ROOM, M07_EXAM_ROOM, M07_EXAM_ROOM] if choice == 0 \
				else [M07_HALL, M07_BASIN, M07_HALL, M07_HALL]
			var sources := [0, 1, 2, 3] if choice == 0 else [0, 1, 1, 2]
			var pages: Array = _story.get("_paragraphs")
			if pages.size() != places.size() or int(_story.get("_result_location_cut_page")) != (-1 if choice == 0 else 2):
				_fail("M07 changed the authored result boundaries")
				return false
			if choice == 1 and (not str(pages[1]).contains(M07_BASIN_WORDS[language]) \
					or str(pages[1]).contains(M07_RETURN_WORDS[language]) \
					or not str(pages[2]).begins_with(M07_RETURN_WORDS[language])):
				_fail("M07 must cut at the sentence after the water stops")
				return false
			for page in range(places.size()):
				await _finish_page()
				if int(_story.get("_para_index")) != page \
						or int(_story.call("_story_source_paragraph_index", page)) != sources[page] \
						or not _expect_surface(places[page], "apartment", "result/%d" % page) \
						or str(_story.get_meta("living_scene_effect", "")) != "none" \
						or BGMPlayer._human_ambience_player.playing or BGMPlayer._season_player.playing \
						or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
					_fail("M07 moved off the exact place, neutral bed, or source paragraph")
					return false
				if page + 1 < places.size():
					_story.call("_on_advance")
					await _wait_stable()
	return true

func _check_hyunsu_call(smoke: bool = false) -> bool:
	var expected_bed := load("res://assets/audio/amb_apartment_room.wav") as AudioStreamWAV
	var homes: Array = ["gosiwon"] if smoke else ["gosiwon", "oneroom"]
	var locales: Array = ["ko"] if smoke else W4_TERMS.keys()
	var cases := 0
	var cold_prose := 0
	var live_cues := 0
	var live_result_exits := 0
	var recording := AudioManager._sounds.get(HYUNSU_KEYBOARD) as AudioStreamWAV
	if expected_bed == null or recording == null or recording.loop_mode != AudioStreamWAV.LOOP_DISABLED:
		_fail("Hyunsu call needs the recorded apartment master and a non-looping telephone sound")
		return false
	for house: String in homes:
		var turn := 41 if house == "gosiwon" else 40
		for language: String in locales:
			for choice: int in ([0] if smoke else [0, 1, 2]):
				await _remove_story()
				await _stop_audio()
				LocaleManager.set_language(language)
				_context = "%s/W%d/%s/c%d" % [language, turn, house, choice]
				if not _prepare_full_owner_history(turn, [
						[25, "hyunsu_exam_day"], [26, "hyunsu_result_fail"], [30, "arc_hyunsu_exam_fail"],
						[turn - 6, "arc_hyunsu_drift"],
					]):
					return false
				GameState.housing = house
				# Keep unrelated restoration/first-move scenes out of this isolated
				# phone fixture; the genuine delayed entry must still be consumed.
				GameState.flags["arc_goshiwon_goodbye_seen"] = house == "oneroom"
				GameState.flags["arc_housing_new_life_seen"] = house == "oneroom"
				var before_money: float = GameState.money
				var before_seen: int = GameState.events_seen
				var reserved := GameState.deferred_events.filter(func(entry: Dictionary) -> bool:
					return entry.get("event_id") == HYUNSU_CALL)
				if reserved.size() != 1 or int(reserved[0].get("trigger_turn", -1)) != turn \
						or not EventManager.deferred_event_is_eligible(HYUNSU_CALL):
					_fail("Hyunsu call did not retain the original W+6 receipt")
					return false
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var selected: String = ingress.call("_next_arc_id", -1, false, true)
				ingress.free()
				if selected != HYUNSU_CALL or GameState.has_deferred_event(HYUNSU_CALL):
					_fail("Hyunsu call was not selected and claimed by the real router: " + selected)
					return false
				BGMPlayer.set_ambience("room")
				BGMPlayer.set_season_ambience("winter")
				if not BGMPlayer._human_ambience_player.playing or not BGMPlayer._season_player.playing:
					_fail("Hyunsu call test could not seed the old human and weather layers")
					return false
				if not await _open_full_fixture_event(selected, [], true):
					return false
				var home := _m23_home_background(house)
				var authored: Dictionary = DataRegistry.find_event(HYUNSU_CALL)
				if not await _hyunsu_call_pages(home, expected_bed, -1, str(authored["description"]), 5):
					return false
				_story.call("_on_advance")
				await _wait_stable()
				if not bool(_story.get("_showing_choices")) or not _hyunsu_call_surface(home, expected_bed, true) \
						or not _hyunsu_expect_cues([HYUNSU_INTRO_CUE], 0):
					return false
				_story.call("_on_choice", choice)
				await _wait_stable()
				var result_count := 2 if choice == 1 else 3
				if not await _hyunsu_call_pages(home, expected_bed, choice,
						str(authored["choices"][choice]["result_text"]), result_count):
					return false
				live_cues += 1 + int(choice == 1)
				var resume: Dictionary = _story.call("build_save_resume_context")
				if choice == 1:
					var pre_exit: Dictionary = GameState.serialize().duplicate(true)
					_story.set_meta("_screenshot_qa_static_surface", true)
					_story.call("_on_advance")
					if not _hyunsu_expect_playing(0):
						return false
					GameState.call("_restore_serialized_snapshot_exact", pre_exit)
					live_result_exits += 1
				await _stop_audio()
				if not await _reload_authored_result_context(resume, language, result_count, result_count - 1) \
						or int(_story.get("_pending_result_choice_index")) != choice \
						or not _hyunsu_call_surface(home, expected_bed, choice != 0) \
						or not _hyunsu_expect_cues([], 0) \
						or GameState.housing != house or GameState.money != before_money \
						or GameState.events_seen != before_seen + 1 \
						or not GameState.flags.get("hyunsu_pivoted", false) \
						or bool(GameState.flags.get("asked_hyunsu_plan", false)) != (choice == 1) \
						or GameState.has_deferred_event(HYUNSU_CALL):
					_fail("Hyunsu isolated re-entry changed room, call state, or choice receipt")
					return false
				cases += 1
	# Prose has a separate cold-load consumer. Starting before the cue must
	# still allow the first live crossing; starting on the cue must stay quiet.
	for language: String in locales:
		for source_index in [1, 2]:
			if not await _check_hyunsu_cold_prose(language, source_index, expected_bed):
				return false
			cold_prose += 1
	await _remove_story()
	await _stop_audio()
	if cases != (1 if smoke else 30) or live_cues != (1 if smoke else 40) \
			or live_result_exits != (0 if smoke else 10) \
			or cold_prose != locales.size() * 2 or _failures != 0:
		return false
	print("HYUNSU_CALL_QUIET_ROOM_OK paths=%d cold_results=%d cold_prose=%d live_keyboards=%d live_result_exits=%d real_deferred_ingress=1 neutral_recording=1" % [
		cases, cases, cold_prose, live_cues, live_result_exits])
	return true

func _hyunsu_call_pages(home: String, expected_bed: AudioStreamWAV, choice: int,
		source: String, count: int) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	if int(_story.call("_story_source_paragraph_count")) != count \
			or not _m23_same_prose(pages, str(_story.call("_fmt", source))):
		_fail("Hyunsu call lost authored paragraphs")
		return false
	for page in range(pages.size()):
		var source_index := int(_story.call("_story_source_paragraph_index", page))
		var first_page := int(_story.call("_first_story_page_for_source", source_index)) == page
		var owns_sound := (choice < 0 and source_index == 2) or (choice == 1 and source_index == 1)
		var cues: Array = [HYUNSU_INTRO_CUE] if choice >= 0 or source_index >= 2 else []
		if choice == 1 and source_index >= 1:
			cues.append(HYUNSU_RESULT_CUE)
		if not _hyunsu_expect_cues(cues, (1 if owns_sound else 0) if first_page else -1):
			return false
		await _finish_page()
		var connected := not (choice == 0 and source_index >= 2)
		if int(_story.get("_para_index")) != page or not _hyunsu_call_surface(home, expected_bed, connected):
			return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	return true

func _check_hyunsu_cold_prose(language: String, source_index: int, bed: AudioStreamWAV) -> bool:
	await _remove_story()
	await _stop_audio()
	LocaleManager.set_language(language)
	_context = "%s/W41/cold-prose%d" % [language, source_index]
	if not _prepare_full_owner_history(41, [
			[25, "hyunsu_exam_day"], [26, "hyunsu_result_fail"],
			[30, "arc_hyunsu_exam_fail"], [35, "arc_hyunsu_drift"],
		]):
		return false
	GameState.housing = "gosiwon"
	if not await _open_full_fixture_event(HYUNSU_CALL, [], true):
		return false
	for step in range(12):
		await _finish_page()
		if int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) == source_index:
			break
		_story.call("_on_advance")
		await _wait_stable()
	var resume: Dictionary = _story.call("build_save_resume_context")
	if resume.get("phase") != "prose" or int(resume.get("source_paragraph_index", -1)) != source_index \
			or not SaveManager.save_game(W8_QA_SLOT, resume, {"qa_fixture": true}):
		_fail("Hyunsu intro cold fixture did not save at its exact source position")
		return false
	await _remove_story()
	await _stop_audio()
	GameState.start_new_game()
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("Hyunsu cold intro save could not be loaded")
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if not _hyunsu_call_surface(W4_ROOM, bed, true) or not _hyunsu_expect_cues([], 0) \
			or int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) != source_index:
		return false
	if source_index == 2:
		return true
	for step in range(12):
		await _finish_page()
		_story.call("_on_advance")
		var current := int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index"))))
		if current == 2:
			if not _hyunsu_expect_cues([HYUNSU_INTRO_CUE], 1):
				return false
			if language not in ["ko", "en"]:
				# All five built-ins are exercised in the fixture. The public
				# retail switch itself currently exposes only KO and EN.
				return true
			# Model the recording having already finished, while leaving its
			# once-only token intact. A locale redraw must not restart it.
			AudioManager.stop_sound(HYUNSU_KEYBOARD)
			var alternate := "en" if language == "ko" else "ko"
			_story.call("_set_story_language", alternate)
			await _wait_stable()
			if LocaleManager.language != alternate or not _hyunsu_expect_cues([HYUNSU_INTRO_CUE], 0):
				return false
			_story.call("_set_story_language", language)
			await _wait_stable()
			return LocaleManager.language == language and _hyunsu_expect_cues([HYUNSU_INTRO_CUE], 0)
		await _wait_stable()
	_fail("Hyunsu intro cold start before the cue did not reach its live entrance")
	return false

func _hyunsu_expect_cues(expected: Array, active: int) -> bool:
	var seen := AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(HYUNSU_CALL + ":"))
	if seen != expected:
		_fail("Hyunsu unexpected or missed exact cue: tags=%s / %s" % [seen, expected])
		return false
	return active == -1 or _hyunsu_expect_playing(active)

func _hyunsu_expect_playing(active: int) -> bool:
	var stream: AudioStream = AudioManager._sounds.get(HYUNSU_KEYBOARD)
	var playing := AudioManager._pool.filter(func(player: AudioStreamPlayer) -> bool:
		return player.playing and player.stream == stream)
	if playing.size() != active:
		_fail("Hyunsu foreground telephone keyboard copies=%d / %d" % [playing.size(), active])
		return false
	return true

func _hyunsu_call_surface(home: String, expected_bed: AudioStreamWAV, connected: bool) -> bool:
	var presentation: Dictionary = _story.get("_current_presentation")
	var badge := _story.get("_communication_badge") as Control
	var portrait := _story.get("_portrait") as TextureRect
	var bed := BGMPlayer._ambience_player.stream as AudioStreamWAV
	var valid: bool = _expect_surface(home, "apartment", "Hyunsu call") \
		and BGMPlayer._ambience_player.playing and bed != null and bed.data == expected_bed.data \
		and bed.mix_rate == expected_bed.mix_rate and bed.format == expected_bed.format \
		and bed.stereo == expected_bed.stereo and bed.loop_mode == AudioStreamWAV.LOOP_FORWARD \
		and not BGMPlayer._human_ambience_player.playing and BGMPlayer._current_human_ambience_key.is_empty() \
		and not BGMPlayer._season_player.playing and BGMPlayer._current_season_key.is_empty() \
		and BGMPlayer._current_key.is_empty() and not BGMPlayer._player_a.playing and not BGMPlayer._player_b.playing \
		and badge.visible == connected and bool(_story.get("_portrait_remote_inset")) == connected \
		and (presentation.get("channel") == "phone") == connected
	if connected:
		valid = valid and presentation.get("state") == "connected" and presentation.get("remote_actor") == "hyunsu" \
			and portrait.visible and portrait.texture != null \
			and portrait.texture.resource_path == ImageRegistry.get_portrait("hyunsu")
	if not valid:
		_fail("Hyunsu call changed the sound, actual house or call boundary: %s" % presentation)
	return valid

func _check_w37_first_bill() -> bool:
	var houses := {"oneroom": "apartment", "villa": "apartment", "apartment": "gangnam_apartment"}
	var prepared: Dictionary = {}
	if not _prepare_full_owner_history(37, [[34, "arc_goshiwon_goodbye"], [35, "arc_housing_new_life"]]):
		return false
	prepared = GameState.serialize().duplicate(true)
	var cases := 0
	var locales := W4_TERMS.keys()
	for locale_index in range(locales.size()):
		var language: String = locales[locale_index]
		for choice in range(3):
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			GameState.call("_restore_serialized_snapshot_exact", prepared)
			var housing: String = houses.keys()[(locale_index + choice) % houses.size()]
			var background: String = houses[housing]
			GameState.housing = housing
			_context = "%s/W37/choice%d/%s" % [language, choice, housing]
			var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
			var selected: String = ingress.call("_next_arc_id", -1, false, true)
			var before_move: Dictionary = GameState.flags.duplicate(true)
			before_move.erase("arc_housing_new_life_seen")
			var when_unmoved: String = ingress.call("_story_graph_contract_event_id", 37, before_move, false)
			ingress.free()
			if selected != W37_FIRST_BILL or when_unmoved == W37_FIRST_BILL:
				_fail("W37 wrong actual owner: %s (no move: %s)" % [selected, when_unmoved])
				return false
			if not await _open_full_fixture_event(selected, [], true) \
					or not await _w37_read_quiet_phase(background, false):
				return false
			_story.call("_on_advance")
			await _wait_stable()
			if not bool(_story.get("_showing_choices")) or not _w37_quiet_home(background, "choices"):
				_fail("W37 did not reach the three choices in the same quiet room")
				return false
			var seen_before: int = GameState.events_seen
			var money_before: float = GameState.money
			var deferred_before := GameState.deferred_events.duplicate(true)
			_story.call("_on_choice", choice)
			await _wait_stable()
			if not await _w37_read_quiet_phase(background, true):
				return false
			var context: Dictionary = _story.call("build_save_resume_context")
			await _stop_audio()
			if not await _reload_authored_result_context(context, language, 2, 1) \
					or int(_story.get("_pending_result_choice_index")) != choice \
					or not _w37_quiet_home(background, "cold result") \
					or GameState.events_seen != seen_before + 1 or GameState.money != money_before \
					or GameState.deferred_events != deferred_before \
					or not GameState.flags.get("arc_y1_new_room_first_month_seen", false):
				_fail("W37 cold result lost its room or re-applied the original choice")
				return false
			cases += 1
	await _remove_story()
	await _stop_audio()
	if cases != 15 or _failures != 0:
		return false
	print("W37_QUIET_ROOM_OK paths=%d localizations=5 housing=3 result_v4=%d motion_none=1 no_manufactured_foley=1" % [cases, cases])
	return true

func _w37_read_quiet_phase(background: String, result: bool) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	if pages.is_empty() or int(_story.call("_story_source_paragraph_count")) != 2:
		_fail("W37 expected the same two authored paragraphs, result=%s" % result)
		return false
	for page in range(pages.size()):
		await _finish_page()
		if int(_story.get("_para_index")) != page or bool(_story.get("_pending_after_result")) != result \
				or not _w37_quiet_home(background, "result=%s/page%d" % [result, page]):
			return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	return true

func _w37_quiet_home(background: String, label: String) -> bool:
	return _expect_quiet_room(W37_FIRST_BILL, background, label)

func _expect_quiet_room(event_id: String, background: String, label: String) -> bool:
	var cues: Array = AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(event_id + ":"))
	var valid := _expect_surface(background, "apartment", label) \
		and BGMPlayer._ambience_player.playing and BGMPlayer._ambience_player.stream == BGMPlayer._load_ambience("apartment") \
		and BGMPlayer._current_human_ambience_key.is_empty() and not BGMPlayer._human_ambience_player.playing \
		and BGMPlayer._current_season_key.is_empty() and not BGMPlayer._season_player.playing \
		and BGMPlayer._current_key.is_empty() and not BGMPlayer._player_a.playing and not BGMPlayer._player_b.playing \
		and str(_story.get_meta("living_scene_effect", "")) == "none" and cues.is_empty()
	if not valid:
		_fail("%s tracks, cue or effects drifted at %s" % [event_id, label])
	return valid

func _check_w116_ghost() -> bool:
	await _remove_story()
	await _stop_audio()
	var prepared: Array[Dictionary] = []
	for photo in [false, true]:
		_context = "W116/prepare/photo=%s" % photo
		var history := _jaehyuk_calendar_fixture_history(photo, [[104, M27_PITCH],
			[106, "arc_jaehyuk_wait"], [108, W108_WARNING, 1]])
		if not _prepare_full_owner_history(116, history):
			return false
		var due := GameState.deferred_events.filter(func(e: Dictionary) -> bool:
			return e.get("event_id") == W116_GHOST)
		if due.size() != 1 or int(due[0].get("trigger_turn", -1)) != 116 \
				or EventManager.deferred_event_is_eligible(W116_GHOST) \
				or not GameState.cast_has_flag("jaehyuk", "invested") or GameState.has_item(W116_ARTIFACT) != photo:
			_fail("W116 preparation lost the original photo, investment or single warning reservation")
			return false
		prepared.append(GameState.serialize().duplicate(true))
	var paths := 0
	var languages := W4_TERMS.keys()
	for lang_index in range(languages.size()):
		var language: String = languages[lang_index]
		for terminal in range(3):
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			var branch := (lang_index + terminal) % 2
			var photo := terminal == 2
			GameState.call("_restore_serialized_snapshot_exact", prepared[int(photo)])
			# Cross-test the resolved location without making a historical move
			# scene compete with this week's prepared natural foreground admission.
			var housing: String = M23_HOUSING[(lang_index + terminal) % M23_HOUSING.size()]
			if housing != "gosiwon":
				GameState.turn = 30
				for event_id in ["arc_goshiwon_goodbye", "arc_housing_new_life"]:
					var witness: Dictionary = DataRegistry.find_event(event_id)
					if not GameState.apply_choice(witness, witness["choices"][0]):
						_fail("W116 moved-housing fixture could not seal the original move consequences")
						return false
				GameState.turn = 116
			GameState.housing = housing
			GameState.mental = 70
			GameState.health = 70
			GameState.intelligence = 60
			GameState.moral_tint = 50
			_context = "%s/W116/root%d/terminal%d/%s" % [language, branch, terminal, housing]
			var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
			var selected: String = ingress.call("_next_arc_id", -1, false, true)
			ingress.free()
			if selected != W116_GHOST or GameState.has_deferred_event(W116_GHOST):
				_fail("W116 prepared production selector chose %s instead of the invested root" % selected)
				return false
			if not await _open_full_fixture_event(selected, [], true) or not await _play_w116_ghost(branch, terminal, housing):
				return false
			paths += 1
	await _remove_story()
	await _stop_audio()
	if _failures != 0:
		return false
	print("W116_GHOST_OK paths=%d actual_selector=%d audio_cold_v4=%d photo_paths=%d aftermath_w117_reserved=%d full_owner=1 prepared_history=1" % [
		paths, paths, paths, languages.size(), paths])
	return true

func _play_w116_ghost(branch: int, terminal: int, housing: String) -> bool:
	var background := _m23_home_background(housing)
	var ids: Array = [W116_GHOST, W116_CHILDREN[branch], W116_DECISION]
	var indices: Array = [branch, 0, terminal]
	if terminal == 2:
		ids.append(W116_PHOTO)
		indices.append(branch)
	var base := [GameState.money, GameState.health, GameState.mental, GameState.intelligence, GameState.moral_tint,
		GameState.event_log.size(), GameState.deferred_events.duplicate(true)]
	var score_mark: int = BGMPlayer.get("_punctuation_token")
	var last_score := -1.0
	for link in range(ids.size()):
		var event_id: String = ids[link]
		var choice: int = indices[link]
		var event: Dictionary = _story.get("_current")
		var edge: Dictionary = _story.get_meta("story_transition_contract", {})
		var start: int = [3, 1, 0, 0][link]
		var intro: Array = (_story.get("_paragraphs") as Array).duplicate()
		var source_count := int(_story.call("_story_source_paragraph_count"))
		if event.get("id") != event_id or source_count != [4, 4, 3, 5][link] \
				or (link > 0 and (edge.get("mode") != "same_location" or edge.get("audio_policy") != "continue" \
					or edge.get("from_surface") != "current_housing" or edge.get("to_surface") != "current_housing")):
			_fail("W116 wrong same-home link %s or intro layout %d; transition=%s" % [event_id, source_count, edge])
			return false
		for page in range(intro.size()):
			await _finish_page()
			var source := int(_story.call("_story_source_paragraph_index", page))
			var score := int(BGMPlayer.get("_punctuation_token"))
			var expected_score := score_mark + link + int(source >= start)
			if int(_story.get("_para_index")) != page or score != expected_score \
					or not _w116_surface(event_id, background, link > 0 or source >= start, last_score):
				_fail("W116 wrong intro %s/%d original score marks=%d expected=%d" % [event_id, source, score, expected_score])
				return false
			last_score = _score_playback_position("reckoning")
			if link == 1 and page == intro.size() - 1 and int(_story.call("_direct_continue_choice_index")) != 0:
				_fail("W116 single child no longer directly continues into its original result")
				return false
			_story.call("_on_advance")
			await _wait_stable()
		if link != 1:
			var visible: Array = [[0, 1], [0], ([0, 1, 2] if terminal == 2 else [0, 1]), [0, 1]][link]
			if not bool(_story.get("_showing_choices")) or (_story.get("_choice_box") as Control).get_child_count() != visible.size() \
					or _story.call("_visible_choice_indices", event) != visible \
					or not _w116_surface(event_id, background, true, last_score):
				_fail("W116 wrong original visible choices for %s" % event_id)
				return false
			if link == 2 and terminal != 2:
				_story.call("_on_choice", 2)
				if not bool(_story.get("_showing_choices")) or bool(_story.get("_pending_after_result")) \
						or GameState.event_log.size() != base[5] + link:
					_fail("W116 photo choice bypassed the missing-item gate")
					return false
			_story.call("_on_choice", choice)
			await _wait_stable()
		var result: Array = (_story.get("_paragraphs") as Array).duplicate()
		var expected_next: String = ids[link + 1] if link + 1 < ids.size() else ""
		var result_sources := int(_story.call("_story_source_paragraph_count"))
		var formatted := str(_story.call("_fmt", event["choices"][choice]["result_text"]))
		if not bool(_story.get("_pending_after_result")) or int(_story.get("_pending_result_choice_index")) != choice \
				or str(_story.get("_pending_follow_up")) != expected_next or not _m23_same_prose(result, formatted):
			_fail("W116 lost its original result/next link at %s" % event_id)
			return false
		for page in range(result.size()):
			await _finish_page()
			if int(_story.get("_para_index")) != page or BGMPlayer.get("_punctuation_token") != score_mark + link + 1 \
					or not _w116_surface(event_id, background, true, last_score):
				return false
			last_score = _score_playback_position("reckoning")
			if page != result.size() - 1:
				_story.call("_on_advance")
				await _wait_stable()
		if link == ids.size() - 1:
			var context: Dictionary = _story.call("build_save_resume_context")
			if not _w116_final_receipts(ids, indices, base, false):
				return false
			await _stop_audio()
			if not await _reload_authored_result_context(context, LocaleManager.language, result_sources, result_sources - 1) \
					or int(_story.get("_pending_result_choice_index")) != choice \
					or int(_story.get("_para_index")) != int(context.get("paragraph_index", -1)) \
					or not _w116_surface(event_id, background, false, -1.0, true) \
					or not _w116_final_receipts(ids, indices, base, false):
				_fail("W116 audio-cleared v4 result moved or re-applied %s" % event_id)
				return false
			_story.set_meta("_screenshot_qa_static_surface", true)
		_story.call("_on_advance")
		await _wait_stable()
	return _w116_final_receipts(ids, indices, base, true)

func _w116_surface(event_id: String, background: String, scored: bool, prior_score: float, cold := false) -> bool:
	var score := _score_playback_position("reckoning")
	var visible_portrait := (_story.get("_portrait_frame") as Control).visible
	var direction: Dictionary = _story.get("_direction")
	var valid: bool = _expect_surface(background, "apartment", "W116 home") \
		and str(_story.get_meta("living_scene_effect", "")) == "none" and BGMPlayer._ambience_player.playing \
		and BGMPlayer._current_human_ambience_key.is_empty() and not BGMPlayer._human_ambience_player.playing \
		and BGMPlayer._current_season_key.is_empty() and not BGMPlayer._season_player.playing \
		and visible_portrait == (event_id != W116_PHOTO) \
		and (event_id != W116_DECISION or direction.get("sting") == "loss") \
		and (cold or (scored == (score >= 0.0) and (not scored or score + 0.060 >= prior_score)))
	if not valid:
		_fail("W116 room/score drift %s: score=%s prior=%s cold=%s portrait=%s direction=%s" % [
			event_id, score, prior_score, cold, visible_portrait, direction])
	return valid

func _w116_final_receipts(ids: Array, indices: Array, base: Array, closed: bool) -> bool:
	var terminal: int = indices[2]
	var photo: bool = ids.back() == W116_PHOTO
	var ending: int = indices.back()
	var owner := FULL_STORY_FLOW.snapshot()
	var chain: Dictionary = owner.get("chain", {})
	var reads: Array = owner.get("read_receipts", {}).get("116", [])
	var expected_deferred: Array = base[6].duplicate(true)
	expected_deferred.append({"event_id": W116_AFTERMATH, "trigger_turn": 117})
	var mental: int = int(base[2]) + [-35, -20, -18][terminal] + ((8 if ending == 0 else -5) if photo else 0)
	var tint: float = float(base[4]) + [0, 5, 3][terminal] + ((4 if ending == 0 else -2) if photo else 0)
	var valid: bool = FULL_STORY_FLOW.valid_session() and GameState.turn == 116 \
		and is_equal_approx(GameState.money, base[0]) and GameState.health == int(base[1]) - (8 if terminal == 0 else 0) \
		and GameState.mental == mental and GameState.intelligence == int(base[3]) + (4 if terminal == 1 else 0) \
		and is_equal_approx(GameState.moral_tint, tint) and GameState.get_cast_stage("jaehyuk") == "betrayed" \
		and GameState.flags.get("arc_jaehyuk_ghost_seen", false) and GameState.flags.get("jaehyuk_scammed", false) \
		and GameState.flags.get("hit_rock_bottom", false) == (terminal == 0) \
		and GameState.flags.get("joined_victims", false) == (terminal == 1) \
		and GameState.flags.get("presented_artifact_correct", false) == photo \
		and GameState.flags.get("arc_jaehyuk_photo_in_dark_seen", false) == photo \
		and GameState.flags.get("jaehyuk_night_was_real", false) == (photo and ending == 0) \
		and GameState.flags.get("deleted_jaehyuk_photo", false) == (photo and ending == 1) \
		and GameState.flags.get("arc_jaehyuk_aftermath_seen", false) == false \
		and _w96_deferred_equal(expected_deferred) and GameState.event_log.size() == base[5] + ids.size() \
		and bool(chain.get("closed", false)) == closed and chain.get("pending_event_ids") == ([] if closed else [ids.back()]) \
		and reads.size() == ids.size() - int(not closed)
	for i in range(reads.size()):
		valid = valid and reads[i].get("event_id") == ids[i] and int(reads[i].get("choice_index", -1)) == indices[i]
	if not valid:
		_fail("W116 changed choice/read receipt, branch outcome or W117 reservation: closed=%s events=%d reads=%s" % [
			closed, GameState.event_log.size() - int(base[5]), reads])
	return valid

func _check_w117_counter() -> bool:
	_w117_capture_dir = OS.get_environment("GANGNAM_W117_COUNTER_CAPTURE_DIR")
	var capture := not _w117_capture_dir.is_empty()
	if capture:
		var output := DirAccess.open(_w117_capture_dir) if _w117_capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or DisplayServer.get_name() == "headless":
			_fail("W117 KO capture requires a fresh absolute output and real display")
			return false
		OS.low_processor_usage_mode = false
	if OS.get_environment("GANGNAM_W117_COUNTER_COMPACT") == "1":
		# --resolution sets the OS window; the project stretch would keep its
		# 1280 logical width. Change both in this isolated fixture only.
		var root := get_tree().root
		root.content_scale_size = Vector2i(960, 600)
		root.size = Vector2i(960, 600)
		await get_tree().process_frame
		if get_viewport().get_visible_rect().size != Vector2(960, 600):
			_fail("W117 compact verification did not obtain a real 960×600 logical viewport")
			return false
	await _remove_story()
	await _stop_audio()
	_context = "W117/prepare"
	if not _prepare_full_owner_history(117, _jaehyuk_calendar_fixture_history(false, [[105, M27_PITCH, 2]])):
		return false
	var due := GameState.deferred_events.filter(func(e: Dictionary) -> bool:
		return e.get("event_id") == W117_COUNTER)
	var early := load("res://scenes/MainGame.tscn").instantiate() as Control
	var early_id: String = early.call("_next_arc_id", 116, true)
	early.free()
	if due.size() != 1 or int(due[0].get("trigger_turn", -1)) != 117 or early_id == W117_COUNTER \
			or not GameState.has_deferred_event(W117_COUNTER) or EventManager.deferred_event_is_eligible(W117_COUNTER) \
			or not GameState.cast_has_flag("jaehyuk", "suspected") or GameState.cast_has_flag("jaehyuk", "invested") \
			or GameState.has_deferred_event(W116_GHOST) or not GameState.flags.get("jaehyuk_refused", false):
		_fail("W117 did not originate from the exact +12 refusal reservation")
		return false
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	var languages := ["ko"] if capture else W117_ARREST.keys()
	var only := OS.get_environment("GANGNAM_W117_COUNTER_LANGUAGE")
	if not only.is_empty():
		if not W117_ARREST.has(only) or (capture and only != "ko"):
			_fail("W117 unknown exact fixture language: %s" % only)
			return false
		languages = [only]
	var paths := 0
	for language: String in languages:
		for choice in ([0] if capture else [0, 1, 2]):
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			GameState.call("_restore_serialized_snapshot_exact", prepared)
			GameState.health = 75
			GameState.mental = 70
			GameState.moral_tint = 0
			_context = "%s/W117/c%d" % [language, choice]
			var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
			var selected: String = ingress.call("_next_arc_id", -1, false, true)
			ingress.free()
			if selected != W117_COUNTER or GameState.has_deferred_event(W117_COUNTER):
				_fail("W117 refused path selected %s instead of the counter root" % selected)
				return false
			if not await _open_full_fixture_event(W117_COUNTER, [], true) or not await _play_w117_counter(choice):
				await _remove_story()
				await _stop_audio()
				return false
			paths += 1
	await _remove_story()
	await _stop_audio()
	if capture:
		if _failures != 0 or paths != 1 or DirAccess.get_files_at(_w117_capture_dir).size() != 4:
			_fail("W117 expected four exact KO live viewport frames")
			return false
		print("W117_COUNTER_CAPTURE_OK language=ko live_calendar=1 frames=4 aftermath=1")
		return true
	if _failures != 0 or paths != languages.size() * 3:
		return false
	print("W117_COUNTER_OK paths=%d live_calendar=%d result_v4=%d old_v4=%d cross_locale_v4=%d prose_v4=%d rebinds=%d aftermath=%d viewport=%s" % [
		paths, paths, languages.size() * 6, languages.size() * 3, languages.size(), 2 if languages.has("ko") else 0,
		4 if languages.has("ko") else 0, paths,
		str(get_viewport().get_visible_rect().size)])
	return true

func _play_w117_counter(choice: int) -> bool:
	var event: Dictionary = _story.get("_current")
	if event.get("id") != W117_COUNTER or int(_story.call("_story_source_paragraph_count")) != 4:
		_fail("W117 lost its original four-paragraph counter root")
		return false
	var music_token: int = BGMPlayer.get("_punctuation_token")
	var capture := not _w117_capture_dir.is_empty()
	var prose_v4 := not capture and choice == 0 and LocaleManager.language == "ko"
	for page in range((_story.get("_paragraphs") as Array).size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		var meeting := source >= 2
		if int(_story.get("_para_index")) != page or BGMPlayer.get("_punctuation_token") != music_token + int(meeting) \
				or not _w117_surface("meeting" if meeting else "", meeting):
			_fail("W117 investigation/reunion prose does not match source %d" % source)
			return false
		if prose_v4 and source in [0, 3] and page == int(_story.call("_first_story_page_for_source", source)):
			if not await _w117_prose_restore(source, page, meeting):
				return false
			music_token = int(BGMPlayer.get("_punctuation_token")) - int(meeting)
		if capture and source in [0, 2] and page == int(_story.call("_first_story_page_for_source", source)) \
				and not await _w117_save_frame("01_recap" if source == 0 else "02_meeting"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")) or _story.call("_visible_choice_indices", event) != [0, 1, 2] \
			or (_story.get("_choice_box") as Control).get_child_count() != 3 or not _w117_surface("meeting", true):
		_fail("W117 encounter choices no longer share the real meeting")
		return false
	var before: Dictionary = GameState.serialize().duplicate(true)
	var last_score := _score_playback_position("reckoning")
	_story.call("_on_choice", choice)
	await _wait_stable()
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", event["choices"][choice]["result_text"]))
	var cut_page := int(_story.get("_result_location_cut_page"))
	if not bool(_story.get("_pending_after_result")) or not _m23_same_prose(pages, authored) \
			or int(_story.call("_story_source_paragraph_count")) != 2 \
			or (choice != 0 and cut_page != -1) \
			or (choice == 0 and (cut_page < 1 or cut_page >= pages.size() \
				or not str(pages[cut_page]).begins_with(W117_ARREST[LocaleManager.language]) \
				or int(_story.call("_story_source_paragraph_index", cut_page - 1)) != 0 \
				or int(_story.call("_story_source_paragraph_index", cut_page)) != 0)):
		_fail("W117 lost original result/source counts or exact localized arrest boundary")
		return false
	var before_cut: Dictionary = {}
	var after_cut: Dictionary = {}
	var c1_meeting: Dictionary = {}
	for page in range(pages.size()):
		var source := int(_story.call("_story_source_paragraph_index", page))
		if page == cut_page:
			after_cut = _story.call("build_save_resume_context")
		await _finish_page()
		var background := _w117_result_background(choice, source, page, cut_page)
		var score := _score_playback_position("reckoning")
		if int(_story.get("_para_index")) != page or BGMPlayer.get("_punctuation_token") != music_token + 1 \
				or score + 0.060 < last_score or not _w117_surface(background, true) \
				or not _w117_receipt(choice, before, false):
			_fail("W117 pending result disturbed its geometry, effects or continuous score")
			return false
		last_score = score
		if capture and page in [0, cut_page] and not await _w117_save_frame("03_police" if page == 0 else "04_arrest"):
			return false
		if choice == 1 and source == 0:
			c1_meeting = _story.call("build_save_resume_context")
		if choice == 0 and page == cut_page - 1:
			before_cut = _story.call("build_save_resume_context")
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	var ending: Dictionary = _story.call("build_save_resume_context")
	var language := LocaleManager.language
	if capture:
		_story.set_meta("_screenshot_qa_static_surface", true)
		_story.call("_on_advance")
		await _wait_stable()
		return _w117_receipt(choice, before, true) and await _w117_next_aftermath(choice)
	if choice == 0:
		# Capture a true zero-cursor current v4 boundary. The frame that settles
		# the fade may have started typing; these fields describe the exact tie.
		after_cut["paragraph_was_typing"] = true
		after_cut["paragraph_type_ratio"] = 0.0
		after_cut["type_pos"] = 0
		after_cut["source_text_progress"] = _story.call("_story_source_page_progress", cut_page, 0.0)
		if before_cut.is_empty() or int(after_cut.get("paragraph_index", -1)) != cut_page \
				or not is_equal_approx(float(before_cut.get("source_text_progress", -1.0)), float(after_cut["source_text_progress"])) \
				or not await _w117_restore(before_cut, language, W117_POLICE, choice, before, true) \
				or not await _w117_rebind(W117_POLICE, choice, before) \
				or not await _w117_restore(after_cut, language, "", choice, before, true) \
				or not await _w117_rebind("", choice, before) \
				or not await _w117_old_unsplit(authored, before_cut, choice, before):
			_fail("W117 same-language cut tie or pre-cut v4 compatibility failed")
			return false
		var other := "en" if language == "ko" else "ko"
		if not await _w117_restore(after_cut, other, W117_POLICE, choice, before) \
				or int(_story.get("_para_index")) != 0:
			_fail("W117 cross-language cold result jumped over the police handoff")
			return false
	if choice == 1 and not await _w117_restore(c1_meeting, language, "meeting", choice, before, true):
		return false
	# All choices restore their final result, including counter c2 still at
	# the meeting (cold initializes the intro on the locationless P0).
	if not await _w117_restore(ending, language, "meeting" if choice == 2 else "", choice, before, true):
		return false
	_story.set_meta("_screenshot_qa_static_surface", true)
	_story.call("_on_advance")
	await _wait_stable()
	if not _w117_receipt(choice, before, true):
		return false
	return await _w117_next_aftermath(choice)

func _w117_save_frame(label: String) -> bool:
	var frame := _story.get("_portrait_frame") as Control
	for _attempt in range(150):
		if not frame.visible or frame.modulate.a >= 0.99:
			return await _save_viewport_frame(_w117_capture_dir.path_join("ko_%s.png" % label))
		await get_tree().process_frame
	_fail("W117 local portrait did not settle for capture")
	return false

func _w117_result_background(choice: int, source: int, page: int, cut_page: int) -> String:
	if choice == 0:
		return W117_POLICE if page < cut_page else ""
	return "meeting" if choice == 2 or source == 0 else ""

func _w117_surface(background: String, scored: bool) -> bool:
	var meeting := background == "meeting"
	var plate := _story.get("_bg_img") as TextureRect
	var portrait := _story.get("_portrait") as TextureRect
	var frame := _story.get("_portrait_frame") as Control
	var dim := _story.get("_bg_dim") as ColorRect
	var score := _score_playback_position("reckoning")
	var texture_ok := (plate.texture == null and str(_story.get("_event_background_id")).is_empty() \
		and dim.visible and dim.color.a >= 0.99) if background.is_empty() \
		else _expect_surface(background, "apartment" if meeting else "", "W117 surface")
	var cues := AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(W117_COUNTER + ":"))
	if not texture_ok or frame.visible != meeting or not cues.is_empty() \
			or (_story.get("_communication_badge") as Control).visible \
			or bool(_story.get("_portrait_remote_inset")) or bool(_story.get("_current_uses_cg")) \
			or str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not BGMPlayer._current_human_ambience_key.is_empty() or BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() or BGMPlayer._season_player.playing \
			or (score >= 0.0) != scored or BGMPlayer._current_key != ("reckoning" if scored else "") \
			or (not meeting and (portrait.texture != null or (_story.get("_name_panel") as Control).visible)) \
			or (meeting and (portrait.texture == null or portrait.texture.resource_path != ImageRegistry.get_portrait("jaehyuk_cornered") \
				or not BGMPlayer._ambience_player.playing)):
		_fail("W117 plate/actor/layers do not match %s (neutral alpha=%s score=%s expected_scored=%s cues=%s)" % [
			background, dim.color.a, score, scored, cues])
		return false
	return meeting or _expect_no_ambience("W117 no invented room tone")

func _w117_prose_restore(source: int, page: int, meeting: bool) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	var event_count := GameState.event_log.size()
	await _stop_audio()
	if context.get("phase") != "prose" or int(context.get("source_paragraph_index", -1)) != source \
			or not await _reload_w117_story_context(context, LocaleManager.language):
		_fail("W117 could not cold-load its original source-%d prose" % source)
		return false
	await _wait_stable()
	if int(_story.get("_para_index")) != page or int(_story.get("_type_pos")) != int(context.get("type_pos", -1)) \
			or GameState.event_log.size() != event_count or not _w117_surface("meeting" if meeting else "", meeting):
		_fail("W117 cold source %d crossed the sustained-score entrance or reapplied a choice" % source)
		return false
	return true

func _reload_w117_story_context(context: Dictionary, language: String) -> bool:
	if not ["prose", "result"].has(context.get("phase")) or context.get("event_id") != W117_COUNTER \
			or not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		return false
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not (disk is Dictionary) or int(disk.get("version", -1)) != 4:
		return false
	await _remove_story()
	GameState.start_new_game()
	LocaleManager.set_language(language)
	if not SaveManager.load_game(W8_QA_SLOT):
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	return LocaleManager.language == language

func _w117_restore(context: Dictionary, language: String, background: String, choice: int, before: Dictionary,
		exact_current := false) -> bool:
	await _stop_audio()
	if context.get("phase") != "result" or int(context.get("source_paragraph_count", -1)) != 2 \
			or not [0, 1].has(int(context.get("source_paragraph_index", -1))) \
			or not await _reload_w117_story_context(context, language):
		return false
	if exact_current and (int(_story.get("_para_index")) != int(context.get("paragraph_index", -1)) \
			or int(_story.get("_type_pos")) != int(context.get("type_pos", -1)) \
			or bool(_story.get("_typing")) != bool(context.get("paragraph_was_typing", false))):
		_fail("W117 exact current v4 page/type cursor moved during load")
		return false
	await _wait_stable()
	return int(_story.get("_pending_result_choice_index")) == choice and _w117_surface(background, true) \
		and _w117_receipt(choice, before, false)

func _w117_rebind(background: String, choice: int, before: Dictionary) -> bool:
	if LocaleManager.language != "ko":
		return true
	var token: int = BGMPlayer.get("_punctuation_token")
	for language in ["en", "ko"]:
		_story.call("_set_story_language", language)
		await _wait_stable()
		if LocaleManager.language != language or not _w117_surface(background, true) \
				or BGMPlayer.get("_punctuation_token") != token \
				or not _w117_receipt(choice, before, false):
			_fail("W117 in-place language change crossed the same-source police cut")
			return false
	return true

func _w117_old_unsplit(authored: String, basis: Dictionary, choice: int, before: Dictionary) -> bool:
	# Rebuild old real pagination from the unchanged authored text, without
	# the new same-source cut. Use positions well away from newline rounding.
	var old: Dictionary = _story.call("_story_page_data", authored)
	var old_pages: Array = old["pages"]
	var old_indices: Array = old["source_indices"]
	var anchor: String = W117_ARREST[LocaleManager.language]
	var old_source := ""
	var number := 0
	for i in range(old_pages.size()):
		if int(old_indices[i]) != 0:
			break
		old_source += str(old_pages[i])
		number += 1
	var split := old_source.find(anchor)
	if number < 1 or split < 4 or old_source.count(anchor) != 1 or old_source.length() <= split + anchor.length() + 3:
		_fail("W117 old unsplit fixture lost its unambiguous localized arrest")
		return false
	for target: int in [int(split / 2.0), split + anchor.length() + 3, old_source.length()]:
		var remaining := target
		var context := basis.duplicate(true)
		for page in range(number):
			var line_length := str(old_pages[page]).length()
			if remaining <= line_length:
				context["paragraph_index"] = page
				context["type_pos"] = remaining
				context["paragraph_type_ratio"] = float(remaining) / float(line_length)
				context["paragraph_was_typing"] = remaining < line_length
				context["source_text_progress"] = float(target) / float(old_source.length())
				break
			remaining -= line_length
		if not await _w117_restore(context, LocaleManager.language, W117_POLICE if target < split else "", choice, before):
			_fail("W117 old unsplit progress chose wrong side at %d/%d" % [target, old_source.length()])
			return false
	return true

func _w117_receipt(choice: int, before: Dictionary, closed: bool) -> bool:
	var outcome := ["jaehyuk_reported", "jaehyuk_exploited", "jaehyuk_partnered"]
	var owner := FULL_STORY_FLOW.snapshot()
	var chain: Dictionary = owner.get("chain", {})
	var reads: Array = owner.get("read_receipts", {}).get("117", [])
	var latest: Dictionary = GameState.event_log.back()
	var deferred: Array = before["deferred_events"].duplicate(true)
	deferred.append({"event_id": W116_AFTERMATH, "trigger_turn": 118})
	if choice > 0:
		deferred.append({"event_id": ["", "callback_jaehyuk_exploited_retaliate", "callback_jaehyuk_partnered_reckoning"][choice],
			"trigger_turn": 117 + (12 if choice == 1 else 14)})
	var valid: bool = FULL_STORY_FLOW.valid_session() and GameState.turn == 117 \
		and GameState.event_log.size() == before["event_log"].size() + 1 and latest.get("event_id") == W117_COUNTER \
		and int(latest.get("turn", -1)) == 117 and int(latest.get("choice_index", -1)) == choice \
		and GameState.flags.get("arc_jaehyuk_counter_seen", false) and not GameState.flags.get("arc_jaehyuk_ghost_seen", false) \
		and not GameState.flags.get("arc_jaehyuk_aftermath_seen", false) \
		and is_equal_approx(GameState.money, float(before["money"]) + [0, 8_000_000, 5_000_000][choice]) \
		and GameState.health == int(before["health"]) and GameState.mental == int(before["mental"]) + [15, -16, -26][choice] \
		and GameState.investment_skill == int(before["investment_skill"]) + (6 if choice == 2 else 0) \
		and GameState.reputation == int(before["reputation"]) + (8 if choice == 0 else 0) \
	and is_equal_approx(GameState.moral_tint, minf(float(before["moral_tint"]) + [6, -5, -8][choice], -20.0 if choice == 1 else 100.0)) \
		and GameState.get_cast_stage("jaehyuk") == ["reported", "blackmailed", "partner_in_crime"][choice] \
		and GameState.route_orthodox == int(before["route_orthodox"]) + int(choice == 0) \
		and GameState.route_unorthodox == int(before["route_unorthodox"]) + int(choice != 0) \
		and _w96_deferred_equal(deferred) and bool(chain.get("closed", false)) == closed \
		and chain.get("pending_event_ids") == ([] if closed else [W117_COUNTER]) and reads.size() == int(closed)
	for index in range(outcome.size()):
		valid = valid and bool(GameState.flags.get(outcome[index], false)) == (choice == index)
	if valid and closed:
		valid = reads[0].get("event_id") == W117_COUNTER and int(reads[0].get("choice_index", -1)) == choice
	if not valid:
		_fail("W117 counter c%d closed=%s changed choice outcome or links: stats=%s stage=%s deferred=%s/%s chain=%s" % [
			choice, closed, [GameState.money, GameState.mental, GameState.investment_skill, GameState.reputation,
				GameState.moral_tint, GameState.route_orthodox, GameState.route_unorthodox, GameState.event_log.size()],
			GameState.get_cast_stage("jaehyuk"), GameState.deferred_events, deferred, chain])
	return valid

func _w117_next_aftermath(choice: int) -> bool:
	if not FULL_STORY_FLOW.apply_background_for_turn(117) or GameState.advance_calendar() \
			or GameState.turn != 118 or not FULL_STORY_FLOW.complete_turn(117):
		_fail("W117 could not close the actual owner into the next calendar week")
		return false
	await _remove_story()
	var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
	var selected: String = ingress.call("_next_arc_id", -1, false, true)
	ingress.free()
	var aftermath: Dictionary = DataRegistry.find_event(W116_AFTERMATH)
	var visible: Array = []
	for index in range(aftermath.get("choices", []).size()):
		if GameState.choice_available(aftermath, aftermath["choices"][index]):
			visible.append(index)
	if selected != W116_AFTERMATH or visible != [0 if choice == 0 else 1] \
			or GameState.has_deferred_event(W116_AFTERMATH) or not FULL_STORY_FLOW.valid_session():
		_fail("W118 did not consume the original aftermath with factual c%d, selected=%s visible=%s" % [choice, selected, visible])
		return false
	return true

func _check_w108_warning() -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "W108/prepare"
	if not _prepare_full_owner_history(108, _jaehyuk_pitch_history() + [[104, M27_PITCH], [106, "arc_jaehyuk_wait"]]):
		return false
	# Both authored roots exclude ordinary deferred draws via min_turn=9999.
	# MainGame drops their due reservations before the dedicated arc fallback.
	var wait_reservation: Dictionary = GameState.claim_deferred_event("arc_jaehyuk_wait", 106)
	var due: Dictionary = GameState.claim_deferred_event(W108_WARNING, 108)
	if int(wait_reservation.get("trigger_turn", -1)) != 106 or int(due.get("trigger_turn", -1)) != 108 \
			or EventManager.deferred_event_is_eligible(W108_WARNING) \
			or GameState.has_deferred_event(W108_WARNING) or not GameState.flags.get("arc_jaehyuk_wait_seen", false) \
			or not GameState.flags.get("jaehyuk_trusted_fully", false):
		_fail("W108 lost eligibility or the single W106 reservation")
		return false
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	var paths := 0
	var languages := W108_CONTACT.keys()
	for lang_index in range(languages.size()):
		var language: String = languages[lang_index]
		for choice in [0, 1, 2]:
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			GameState.call("_restore_serialized_snapshot_exact", prepared)
			var housing: String = M23_HOUSING[(lang_index + choice) % M23_HOUSING.size()]
			GameState.housing = housing
			GameState.mental = 60
			GameState.intelligence = 60
			_context = "%s/W108/c%d/%s" % [language, choice, housing]
			if not await _open_full_fixture_event(W108_WARNING, [], true) or not await _play_w108_warning(choice, housing):
				_fail("W108 message/call ownership or isolated result restore failed")
				await _remove_story()
				await _stop_audio()
				return false
			paths += 1
	await _remove_story()
	await _stop_audio()
	if _failures != 0:
		return false
	print("W108_WARNING_OK paths=%d result_v4=%d actual_choice_receipts=%d claimed_w108_from_w106=1 scheduled_w116_once=1 full_owner=1" % [paths, 7 * languages.size(), paths])
	return true

func _play_w108_warning(choice: int, housing: String) -> bool:
	var background := _m23_home_background(housing)
	var event: Dictionary = _story.get("_current")
	var original := [GameState.money, GameState.mental, GameState.intelligence, GameState.get_cast_affinity("hyunsu"),
		GameState.get_cast_stage("jaehyuk"), GameState.event_log.size()]
	var deferred := GameState.deferred_events.duplicate(true)
	if int(_story.call("_story_source_paragraph_count")) != 5:
		return false
	for page in range((_story.get("_paragraphs") as Array).size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		if not _w108_surface(background, "message", source >= 3):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	_story.call("_refresh_story_speaker_language")
	if not bool(_story.get("_showing_choices")) or (_story.get("_choice_box") as Control).get_child_count() != 3 \
			or not _w108_surface(background, "message", true) or GameState.event_log.size() != original[5]:
		return false
	var score_token: int = BGMPlayer.get("_punctuation_token")
	_story.call("_on_choice", choice)
	await _wait_stable()
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", event["choices"][choice]["result_text"]))
	var source_count := 3 if choice == 0 else 2
	if int(_story.call("_story_source_paragraph_count")) != source_count or not _m23_same_prose(pages, authored):
		_fail("W108 altered an original result paragraph")
		return false
	var saved: Dictionary = {}
	for page in range(pages.size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		var channel := _w108_channel(choice, source)
		if int(_story.get("_para_index")) != page or not _w108_surface(background, channel, true) \
				or BGMPlayer.get("_punctuation_token") != score_token or not _w108_receipt(choice, original, deferred, false):
			return false
		saved[source] = _story.call("build_save_resume_context")
		if page < pages.size() - 1:
			_story.call("_on_advance")
			await _wait_stable()
	for source in range(source_count):
		var context: Dictionary = saved.get(source, {})
		# Emulate opening the result in a fresh audio session, not inheriting a
		# same-process copy of the P3 score that already played above.
		await _stop_audio()
		if not await _reload_authored_result_context(context, LocaleManager.language, source_count, source) \
				or int(_story.get("_pending_result_choice_index")) != choice \
				or int(_story.get("_para_index")) != int(context.get("paragraph_index", -1)) \
				or not _w108_surface(background, _w108_channel(choice, source), false) \
				or not _w108_receipt(choice, original, deferred, false):
			return false
	_story.set_meta("_screenshot_qa_static_surface", true)
	_story.call("_on_advance")
	await _wait_stable()
	return _w108_receipt(choice, original, deferred, true)

func _w108_channel(choice: int, source: int) -> String:
	return "narration" if source > 0 else ("phone" if choice == 0 else "message")

func _w108_surface(background: String, channel: String, scored: bool) -> bool:
	var presentation: Dictionary = _story.get("_current_presentation")
	var badge := _story.get("_communication_badge") as Control
	var label := _story.get("_communication_label") as Label
	var name_panel := _story.get("_name_panel") as Control
	var portrait := _story.get("_portrait") as TextureRect
	var remote := channel != "narration"
	var actor := "hyunsu" if channel == "message" else ("jaehyuk" if channel == "phone" else "")
	var asset := "hyunsu" if actor == "hyunsu" else "jaehyuk_charisma"
	var labels: Array = W108_CONTACT[LocaleManager.language]
	var expected_label := str(labels[0] if channel == "message" else (labels[1] if channel == "phone" else ""))
	var sound_cues := AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(W108_WARNING + ":"))
	if not _expect_surface(background, "apartment", "W108 home") or presentation.get("channel") != channel \
			or str(presentation.get("remote_actor", "")) != actor or badge.visible != remote \
			or label.text.nocasecmp_to(expected_label) != 0 or bool(_story.get("_portrait_remote_inset")) != remote \
			or (_story.get("_portrait_frame") as Control).visible != remote \
			or (channel == "phone" and presentation.get("state") != "connected") \
			or (not remote and (name_panel.visible or portrait.texture != null)) \
			or (remote and (portrait.texture == null or portrait.texture.resource_path != ImageRegistry.get_portrait(asset))) \
			or str(_story.get_meta("living_scene_effect", "")) != "none" or not BGMPlayer._ambience_player.playing \
			or not BGMPlayer._current_human_ambience_key.is_empty() or BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() or BGMPlayer._season_player.playing \
			or BGMPlayer._current_key != ("reckoning" if scored else "") \
			or (_score_playback_position("reckoning") >= 0.0) != scored or not sound_cues.is_empty():
		_fail("W108 wrong channel/portrait/room sound: expected=%s actual=%s badge=%s score=%s cues=%s" % [
			channel, presentation, label.text, BGMPlayer._current_key, sound_cues])
		return false
	return true

func _w108_receipt(choice: int, original: Array, deferred: Array, closed: bool) -> bool:
	var owner := FULL_STORY_FLOW.snapshot()
	var reads: Array = owner.get("read_receipts", {}).get("108", [])
	var chain: Dictionary = owner.get("chain", {})
	var last: Dictionary = GameState.event_log.back()
	var expected := deferred.duplicate(true)
	expected.append({"event_id": "arc_jaehyuk_04a_ghost", "trigger_turn": 116})
	var valid: bool = FULL_STORY_FLOW.valid_session() and GameState.turn == 108 \
		and last.get("event_id") == W108_WARNING and int(last.get("choice_index", -1)) == choice \
		and GameState.event_log.size() == original[5] + 1 and bool(GameState.flags.get("arc_jaehyuk_hyunsu_warning_seen", false)) \
		and is_equal_approx(GameState.money, original[0] + (500_000.0 if choice == 0 else 0.0)) \
		and GameState.mental == original[1] + [-20, -13, -8][choice] and GameState.intelligence == original[2] + (5 if choice == 2 else 0) \
		and GameState.get_cast_affinity("hyunsu") == original[3] + [10, 3, 12][choice] \
		and GameState.get_cast_stage("jaehyuk") == ["retreating", original[4], "suspect"][choice] \
		and bool(GameState.flags.get("tried_to_withdraw", false)) == (choice == 0) \
		and bool(GameState.flags.get("ignored_hyunsu_warning", false)) == (choice == 1) \
		and bool(GameState.flags.get("started_investigating", false)) == (choice == 2) \
		and bool(GameState.flags.get("hyunsu_warned", false)) == (choice != 1) \
		and _w96_deferred_equal(expected) and bool(chain.get("closed", false)) == closed and reads.size() == int(closed)
	if closed and valid:
		valid = reads[0].get("event_id") == W108_WARNING and int(reads[0].get("choice_index", -1)) == choice
	if not valid:
		_fail("W108 changed choice effects, the W116 reservation or the owner receipt")
	return valid

func _check_m27_pitch() -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "M27/prepare"
	# This fixture owns the W104 result under the real chain and display, not
	# the upstream whole-calendar scheduler (covered by arc_flow_sim).
	if not _prepare_full_owner_history(104, _jaehyuk_pitch_history()):
		return false
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	var cases := 0
	var languages := M27_HOME.keys()
	for lang_index in range(languages.size()):
		var language: String = languages[lang_index]
		for choice in range(M27_FLAGS.size()):
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			GameState.call("_restore_serialized_snapshot_exact", prepared)
			var housing: String = M23_HOUSING[(lang_index + choice) % M23_HOUSING.size()]
			GameState.housing = housing
			GameState.money = 5_000_000.0
			GameState.mental = 60
			GameState.intelligence = 60
			GameState.moral_tint = 0.0
			_context = "%s/M27/c%d/%s" % [language, choice, housing]
			if not await _open_full_fixture_event(M27_PITCH, [], true) or not await _play_m27_pitch(choice, housing):
				_fail("M27 pitch location, score, save or choice receipt failed")
				await _remove_story()
				await _stop_audio()
				return false
			cases += 1
	await _remove_story()
	await _stop_audio()
	if _failures != 0:
		return false
	print("M27_PITCH_OK paths=%d home_exits=%d v4_result=%d v4_exact_refusal=%d actual_choice_receipts=%d full_owner=1 prepared_ingress=1" % [
		cases, 2 * languages.size(), cases, languages.size(), cases])
	return true

func _play_m27_pitch(choice: int, housing: String) -> bool:
	var event: Dictionary = _story.get("_current")
	var witness_turn: int = GameState.turn
	var stats := [float(GameState.money), GameState.mental, GameState.intelligence, GameState.moral_tint,
		GameState.get_cast_affinity("jaehyuk"), GameState.route_orthodox, GameState.route_unorthodox, GameState.event_log.size()]
	var deferred := GameState.deferred_events.duplicate(true)
	for page in range((_story.get("_paragraphs") as Array).size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		if not _m27_surface(false, housing, source >= 3):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")) or (_story.get("_choice_box") as Control).get_child_count() != 3 \
			or not _m27_surface(false, housing, true):
		return false
	var music_token := int(BGMPlayer.get("_punctuation_token"))
	_story.call("_on_choice", choice)
	await _wait_stable()
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var source_count := 1 if choice == 1 else 2
	var authored := str(_story.call("_fmt", event["choices"][choice]["result_text"]))
	if int(_story.call("_story_source_paragraph_count")) != source_count or not _m23_same_prose(pages, authored):
		_fail("M27 changed original result prose or source paragraphs")
		return false
	var home_page := -1
	if choice == 0:
		home_page = int(_story.call("_first_story_page_for_source", 1))
	elif choice == 2:
		home_page = int(_story.get("_result_location_cut_page"))
		if home_page < 1 or home_page >= pages.size() or not str(pages[home_page]).begins_with(M27_HOME[LocaleManager.language]) \
				or int(_story.call("_story_source_paragraph_index", home_page)) != 0:
			_fail("M27 return home did not start at the exact second sentence of the refusal")
			return false
	if choice != 1 and (home_page < 1 or home_page >= pages.size()):
		return false
	for page in range(pages.size()):
		await _finish_page()
		var at_home := choice != 1 and page >= home_page
		if int(_story.get("_para_index")) != page or not _m27_surface(at_home, housing, true) \
				or int(BGMPlayer.get("_punctuation_token")) != music_token \
				or not _m27_receipt(choice, stats, deferred, witness_turn, false):
			return false
		if page < pages.size() - 1:
			_story.call("_on_advance")
			if choice == 2 and page + 1 == home_page:
				if not await _reload_cut_result(choice, home_page, true):
					return false
			await _wait_stable()
	# Revisit the changed home phase (or the unchanged hotel) from real v4.
	# Old result resume did not start the live P3 score; this patch must not either.
	var final_context: Dictionary = _story.call("build_save_resume_context")
	await _stop_audio()
	if not await _reload_authored_result_context(final_context, LocaleManager.language, source_count, source_count - 1) \
			or int(_story.get("_para_index")) != pages.size() - 1 \
			or int(_story.get("_pending_result_choice_index")) != choice:
		return false
	await _wait_stable()
	if not _m27_surface(choice != 1, housing, false) or not _m27_receipt(choice, stats, deferred, witness_turn, false):
		return false
	_story.set_meta("_screenshot_qa_static_surface", true)
	_story.call("_on_advance")
	await _wait_stable()
	return _m27_receipt(choice, stats, deferred, witness_turn, true)

func _m27_surface(at_home: bool, housing: String, scored: bool) -> bool:
	var plate := _story.get("_bg_img") as TextureRect
	var ambience := "apartment" if at_home else "cafe"
	var texture_ok := _expect_surface(_m23_home_background(housing), ambience, "M27 home") if at_home \
		else (plate.texture != null and plate.texture.resource_path == "res://assets/cg/jaehyuk_reveal.png")
	var observed: Array = AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(M27_PITCH + ":"))
	if not texture_ok or bool(_story.get("_current_uses_cg")) == at_home \
			or BGMPlayer._current_ambience_key != ambience or not BGMPlayer._ambience_player.playing \
			or BGMPlayer._current_human_ambience_key != ("" if at_home else "cafe") \
			or BGMPlayer._human_ambience_player.playing == at_home or not BGMPlayer._current_season_key.is_empty() \
			or (at_home and (BGMPlayer._season_player.playing or (_story.get("_name_panel") as Control).visible \
				or (_story.get("_portrait_frame") as Control).visible or str(_story.get_meta("living_scene_effect", "")) != "none")) \
			or BGMPlayer._current_key != ("reckoning" if scored else "") \
			or (_score_playback_position("reckoning") >= 0.0) != scored or not observed.is_empty():
		_fail("M27 wrong surface home=%s texture_ok=%s cg=%s name=%s portrait=%s weather=%s ambience=%s/%s human=%s/%s season=%s/%s score=%s/%.3f expected=%s cues=%s" % [
			at_home, texture_ok, _story.get("_current_uses_cg"), (_story.get("_name_panel") as Control).visible,
			(_story.get("_portrait_frame") as Control).visible, _story.get_meta("living_scene_effect", ""), BGMPlayer._current_ambience_key, BGMPlayer._ambience_player.playing,
			BGMPlayer._current_human_ambience_key, BGMPlayer._human_ambience_player.playing,
			BGMPlayer._current_season_key, BGMPlayer._season_player.playing, BGMPlayer._current_key,
			_score_playback_position("reckoning"), scored, observed])
		return false
	return true

func _m27_receipt(choice: int, stats: Array, deferred: Array, turn: int, closed: bool) -> bool:
	var owner := FULL_STORY_FLOW.snapshot()
	var reads: Array = owner.get("read_receipts", {}).get(str(turn), [])
	var chain: Dictionary = owner.get("chain", {})
	var last: Dictionary = GameState.event_log.back()
	var expected := deferred.duplicate(true)
	expected.append({"event_id": "arc_jaehyuk_04b_counter" if choice == 2 else "arc_jaehyuk_wait",
		"trigger_turn": turn + (12 if choice == 2 else 2)})
	var valid: bool = FULL_STORY_FLOW.valid_session() and GameState.turn == turn \
		and last.get("event_id") == M27_PITCH and int(last.get("choice_index", -1)) == choice \
		and GameState.event_log.size() == stats[7] + 1 and bool(GameState.flags.get("arc_jaehyuk_pitch_seen", false)) \
		and is_equal_approx(GameState.money, stats[0] - [3_000_000.0, 1_000_000.0, 0.0][choice]) \
		and GameState.mental == stats[1] + [-8, -5, -6][choice] and GameState.intelligence == stats[2] + [0, 2, 6][choice] \
		and is_equal_approx(GameState.moral_tint, stats[3] + [-5.0, 2.0, 0.0][choice]) \
		and GameState.get_cast_affinity("jaehyuk") == stats[4] + [5, 3, -5][choice] \
		and GameState.get_cast_stage("jaehyuk") == ["all_in", "partial", "suspect"][choice] \
		and GameState.cast_has_flag("jaehyuk", "invested") == (choice != 2) \
		and GameState.cast_has_flag("jaehyuk", "suspected") == (choice == 2) \
		and GameState.route_orthodox == stats[5] + int(choice == 2) and GameState.route_unorthodox == stats[6] + int(choice == 0) \
		and _w96_deferred_equal(expected) and bool(chain.get("closed", false)) == closed and reads.size() == int(closed)
	for index in range(M27_FLAGS.size()):
		valid = valid and bool(GameState.flags.get(M27_FLAGS[index], false)) == (index == choice)
	if closed and valid:
		valid = reads[0].get("event_id") == M27_PITCH and int(reads[0].get("choice_index", -1)) == choice
	if not valid:
		_fail("M27 changed the cost, flags, scheduled callback or exact owner receipt")
	return valid

func _check_w96_return(smoke: bool = false) -> bool:
	_w96_capture_dir = "" if smoke else OS.get_environment("GANGNAM_W96_RETURN_CAPTURE_DIR")
	var capture := not _w96_capture_dir.is_empty()
	var languages := ["ko"] if smoke else W96_ARRIVAL.keys()
	if capture:
		var language := OS.get_environment("GANGNAM_W96_RETURN_CAPTURE_LANGUAGE")
		var output := DirAccess.open(_w96_capture_dir) if _w96_capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or not W96_ARRIVAL.has(language) or DisplayServer.get_name() == "headless":
			_fail("W96 capture requires a fresh absolute output, known locale and real display")
			return false
		languages = [language]
		OS.low_processor_usage_mode = false
	await _remove_story()
	await _stop_audio()
	if not _prepare_full_owner_history(96, [[14, "arc_father_01_call"], [21, "arc_father_02_signal"],
			[49, "chapter_card_34"], [57, "arc_father_medication"], [89, M23_PARENTS], [89, M23_CALL]]):
		return false
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	var probe := load("res://scenes/MainGame.tscn").instantiate() as Control
	var opens_exact_week: bool = probe.call("_next_arc_id", 96, true) == W96_VISIT \
		and probe.call("_next_arc_id", 95, true) != W96_VISIT and probe.call("_next_arc_id", 97, true) != W96_VISIT
	probe.free()
	if not opens_exact_week:
		_fail("W96 hospital door did not follow the genuine call at its exact week")
		return false
	for language in languages:
		var choices := [3] if capture or smoke or language != "ko" else [0, 1, 2, 3]
		for choice in choices:
			await _remove_story()
			await _stop_audio()
			LocaleManager.set_language(language)
			GameState.call("_restore_serialized_snapshot_exact", prepared)
			GameState.mental = 60
			GameState.moral_tint = 0.0
			if OS.has_environment("GANGNAM_W96_REVISION_CHECK"):
				var custom_name := OS.get_environment("GANGNAM_W96_REVISION_CUSTOM_NAME")
				if not custom_name.is_empty():
					GameState.player_name = custom_name
			_context = "%s/W96/c%d" % [language, choice]
			if not await _open_full_fixture_event(W96_VISIT, [W96_YEAR_CLOSE]) \
					or not await _read_w96_return(choice, smoke, capture):
				_fail("W96 full owner fixture failed")
				await _remove_story()
				await _stop_audio()
				return false
	await _remove_story()
	await _stop_audio()
	if capture and DirAccess.get_files_at(_w96_capture_dir).size() != 3:
		_fail("W96 expected three actual settled frames per locale")
	if _failures != 0:
		return false
	var revision_checks := 2 * languages.size() if OS.has_environment("GANGNAM_W96_REVISION_CHECK") and not (capture or smoke) else 0
	print("W96_RETURN_OK paths=%d bedside_regressions=%d boundary_v4=%d legacy_unsplit_v4=%d different_locale_v4=%d previous_prose_v4=%d rebinds=%d same_week_close=1 w100_exact_gate=1 captures=%d" % [languages.size(),
		0 if smoke or capture else 3, 0 if capture else (1 if smoke else languages.size() * 2),
		0 if smoke or capture else languages.size(), 0 if smoke or capture else languages.size(), revision_checks,
		0 if smoke or capture else 8, 3 if capture else 0])
	return true

func _read_w96_return(choice: int, smoke: bool, capture: bool) -> bool:
	var language := LocaleManager.language
	var event: Dictionary = _story.get("_current")
	if int(_story.call("_story_source_paragraph_count")) != 3 \
			or not await _read_phase_surface_only(W96_HOSPITAL, "hospital"):
		return false
	_story.call("_on_advance")
	await _wait_stable()
	if not bool(_story.get("_showing_choices")) or (_story.get("_choice_box") as Control).get_child_count() != 4:
		return false
	var expected := [float(GameState.money), GameState.mental + [23, 15, 3, -18][choice],
		GameState.get_cast_affinity("father") + [25, 18, 12, -15][choice],
		GameState.moral_tint + [9.0, 2.0, 4.0, -12.0][choice], GameState.event_log.size() + 1]
	var original_deferred := GameState.deferred_events.duplicate(true)
	_story.call("_on_choice", choice)
	await _wait_stable()
	var authored := str(_story.call("_fmt", event["choices"][choice]["result_text"]))
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var cut := _w96_cut(pages)
	if not _m23_same_prose(pages, authored) or (cut >= 0) != (choice == 3):
		_fail("W96 changed original prose or location boundary")
		return false
	var score_token: int = BGMPlayer.get("_punctuation_token")
	var score_position := _w96_score_position()
	for page in range(pages.size()):
		var at_station := choice == 3 and page >= cut
		await _finish_page()
		if int(_story.get("_para_index")) != page or not _w96_surface(choice, at_station) \
				or not _w96_receipt(choice, expected, original_deferred, false):
			return false
		if capture and page in [0, cut - 1, cut]:
			var label := "result_p0" if page == 0 else ("before_arrival" if page < cut else "seoul_station")
			if not await _save_w96_frame(label):
				return false
		if choice == 3 and not capture and not smoke and page == cut - 1:
			if not await _reload_cut_result(choice, page, false):
				return false
			await _wait_stable()
			if not _w96_surface(choice, false) or not await _w96_rebind(language, false):
				return false
			# The following live arrival must keep the actual score opened by the load.
			score_token = BGMPlayer.get("_punctuation_token")
			score_position = _w96_score_position()
		if page + 1 < pages.size():
			_story.call("_on_advance")
			if choice == 3 and page + 1 == cut:
				if BGMPlayer.get("_punctuation_token") != score_token \
						or _w96_score_position() + 0.05 < score_position:
					_fail("W96 live location cut restarted or stopped the existing grief score")
					return false
				if not capture and not await _reload_cut_result(choice, page + 1, true):
					return false
			await _wait_stable()
			if choice == 3 and page + 1 == cut and not capture and not smoke:
				if not _w96_surface(choice, true) or not await _w96_rebind(language, true):
					return false
	if choice == 3 and not capture and not smoke:
		var final_context: Dictionary = _story.call("build_save_resume_context")
		if OS.has_environment("GANGNAM_W96_REVISION_CHECK") \
				and not await _w96_previous_prose_resume(event["choices"][choice]["result_text"], final_context,
					cut, expected, original_deferred):
			return false
		if not await _w96_legacy_unsplit(authored, final_context) or not _w96_surface(3, true):
			return false
		var other := "en" if language == "ko" else "ko"
		if not await _reload_authored_result_context(final_context, other, 2, 1) \
				or int(_story.get("_para_index")) != int(_story.call("_first_story_page_for_source", 1)) \
				or not _w96_surface(3, false):
			_fail("W96 cold language change did not rewind to the start of source paragraph 1")
			return false
		if not await _reload_authored_result_context(final_context, language, 2, 1) or not _w96_surface(3, true):
			return false
		await _finish_page()
	_story.call("_on_advance")
	await _wait_stable()
	return _w96_receipt(choice, expected, original_deferred, true)

func _w96_cut(pages: Array) -> int:
	var cut := int(_story.get("_result_location_cut_page"))
	if cut < 0:
		return -1
	if cut < 2 or cut >= pages.size() or not str(pages[cut]).begins_with(W96_ARRIVAL[LocaleManager.language]) \
			or int(_story.call("_story_source_paragraph_count")) != 2 \
			or int(_story.call("_story_source_paragraph_index", cut - 1)) != 1 \
			or int(_story.call("_story_source_paragraph_index", cut)) != 1:
		_fail("W96 screen cut not at the exact Seoul arrival inside source 1")
		return -1
	return cut

func _w96_surface(choice: int, at_station: bool) -> bool:
	if choice != 3:
		var plate := _story.get("_bg_img") as TextureRect
		return str(_story.get("_event_cg_id")) == "cg_ending_father" and plate.texture != null \
			and plate.texture.resource_path == "res://assets/cg/ending_father.png" \
			and str(BGMPlayer.get("_current_ambience_key")) == "hospital"
	var cues: Array = AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(W96_VISIT + ":"))
	var expected_bg := W96_STICKER if at_station else W96_HOSPITAL
	if not _expect_surface(expected_bg, "" if at_station else "hospital", "W96 result") \
			or not str(_story.get("_event_cg_id")).is_empty() or not cues.is_empty() \
			or str(BGMPlayer.get("_current_key")) != "grief" or _w96_score_position() < 0.0 \
			or str(_story.get_meta("living_scene_effect", "")) != "none":
		_fail("W96 altered score=%s/%.3f cues=%s weather=%s cg=%s" % [BGMPlayer.get("_current_key"),
			_w96_score_position(), cues, _story.get_meta("living_scene_effect", ""), _story.get("_event_cg_id")])
		return false
	if at_station:
		return _expect_no_ambience("W96 arrival") and not (_story.get("_portrait_frame") as Control).visible \
			and not (_story.get("_name_panel") as Control).visible and not (_story.get("_communication_badge") as Control).visible
	return (_story.get("_portrait_frame") as Control).visible and BGMPlayer._ambience_player.playing \
		and BGMPlayer._current_human_ambience_key == "public_interior" and BGMPlayer._human_ambience_player.playing

func _w96_score_position() -> float:
	return _score_playback_position("grief")

func _score_playback_position(key: String) -> float:
	# ModLoader duplicates the imported stream to set looping, so its
	# resource_path may be empty; the cached stream identity remains exact.
	var score := ModLoader.load_audio(str(BGMPlayer.TRACKS[key]), true)
	for player in [BGMPlayer._player_a, BGMPlayer._player_b]:
		if player.playing and player.stream != null and player.stream == score:
			return player.get_playback_position()
	return -1.0

func _w96_receipt(choice: int, expected: Array, original_deferred: Array, closed: bool) -> bool:
	var receipt: Dictionary = GameState.event_log.back() if not GameState.event_log.is_empty() else {}
	var snapshot := FULL_STORY_FLOW.snapshot()
	var reads: Array = snapshot.get("read_receipts", {}).get("96", [])
	var pending: Array = snapshot.get("chain", {}).get("pending_event_ids", [])
	var next := W96_YEAR_CLOSE if closed else W96_VISIT
	var valid: bool = FULL_STORY_FLOW.valid_session() and GameState.turn == 96 \
		and str((_story.get("_current") as Dictionary).get("id")) == next and bool(_story.get("_pending_after_result")) != closed \
		and receipt.get("event_id") == W96_VISIT and int(receipt.get("choice_index", -1)) == choice \
		and GameState.event_log.size() == expected[4] and is_equal_approx(GameState.money, expected[0]) \
		and GameState.mental == expected[1] and GameState.get_cast_affinity("father") == expected[2] \
		and is_equal_approx(GameState.moral_tint, expected[3]) \
		and GameState.get_cast_stage("father") == ["reconciled", "hopeful", "quiet", "distant"][choice] \
		and bool(GameState.flags.get("visited_father", false)) == (choice != 3) \
		and bool(GameState.flags.get("father_visit_deferred", false)) == (choice == 3) \
		and _w96_deferred_equal(original_deferred) and not pending.is_empty() and pending.front() == next \
		and reads.size() == int(closed)
	if closed and valid:
		valid = reads[0].get("event_id") == W96_VISIT and int(reads[0].get("choice_index", -1)) == choice \
			and _w96_w100_gate(choice == 3)
	if not valid:
		_fail("W96 altered effects/receipts: actual=%s expect=%s logged=%s pending=%s read_count=%d deferred_match=%s closed=%s" % [
			[GameState.money, GameState.mental, GameState.get_cast_affinity("father"), GameState.moral_tint, GameState.event_log.size(),
			GameState.get_cast_stage("father"), GameState.flags.get("visited_father"), GameState.flags.get("father_visit_deferred")],
			expected, receipt.get("event_id"), pending, reads.size(), _w96_deferred_equal(original_deferred), closed])
	return valid

func _w96_deferred_equal(original: Array) -> bool:
	if original.size() != GameState.deferred_events.size():
		return false
	for index in range(original.size()):
		var current: Dictionary = GameState.deferred_events[index]
		if str(current.get("event_id", "")) != str(original[index].get("event_id", "")) \
				or int(current.get("trigger_turn", -1)) != int(original[index].get("trigger_turn", -1)):
			return false
	return true

func _w96_w100_gate(defers: bool) -> bool:
	var probe := load("res://scenes/MainGame.tscn").instantiate() as Control
	var flags := GameState.flags.duplicate()
	var target := "arc_y3_father_avoidance_document"
	var valid: bool = (probe.call("_story_graph_contract_event_id", 100, flags, false) == target) == defers
	for off_week in [99, 101]:
		valid = valid and probe.call("_story_graph_contract_event_id", off_week, flags, false) != target
	valid = valid and probe.call("_story_graph_contract_event_id", 100, flags, true) != target
	flags["arc_y3_father_avoidance_document_seen"] = true
	valid = valid and probe.call("_story_graph_contract_event_id", 100, flags, false) != target
	probe.free()
	return valid

func _w96_rebind(language: String, at_station: bool) -> bool:
	if language not in ["ko", "en"]:
		return true
	for other in ["en" if language == "ko" else "ko", language]:
		_story.call("_set_story_language", other)
		await _wait_stable()
		var cut := _w96_cut(_story.get("_paragraphs"))
		if LocaleManager.language != other or cut < 0 \
				or (int(_story.get("_para_index")) >= cut) != at_station or not _w96_surface(3, at_station):
			_fail("W96 language change crossed the source-1 arrival sentence")
			return false
	return true

func _w96_previous_prose_resume(current_raw: String, current_context: Dictionary, current_cut: int,
		expected: Array, deferred: Array) -> bool:
	var language := LocaleManager.language
	var baseline: Array = W96_PRE_REVISION[language]
	var old_suffix: String = baseline[0]
	var replacement: String = baseline[1]
	if not current_raw.ends_with(replacement) or current_raw.ends_with(old_suffix):
		_fail("W96 prior-prose compatibility requires the corrected live sentence")
		return false
	var old_raw := current_raw.substr(0, current_raw.length() - replacement.length()) + old_suffix
	if old_raw.sha256_text() != baseline[2]:
		_fail("W96 reconstructed previous source did not match the independently extracted Git blob text")
		return false
	var old_display: String = _story.call("_fmt", old_raw)
	var old_data: Dictionary = _story.call("_split_formatted_story_page", old_display, 1, W96_ARRIVAL[language])
	var old_pages: Array = old_data.get("pages", [])
	var indices: Array = old_data.get("source_indices", [])
	var old_cut := int(old_data.get("result_location_cut_page", -1))
	if old_cut < 2 or old_cut >= old_pages.size() or int(indices[old_cut - 1]) != 1 or int(indices[old_cut]) != 1:
		_fail("W96 previous prose did not have an exact old physical source-1 boundary")
		return false
	var old_consumed := 0
	var old_total := 0
	for page in range(old_pages.size()):
		if int(indices[page]) != 1:
			continue
		var length := str(old_pages[page]).length()
		old_total += length
		if page < old_cut:
			old_consumed += length
	if old_consumed <= 0 or old_consumed >= old_total:
		return false
	for at_station in [false, true]:
		var old_page := old_cut if at_station else old_cut - 1
		var context := current_context.duplicate(true)
		context["paragraph_index"] = old_page
		context["paragraph_was_typing"] = at_station
		context["type_pos"] = 0 if at_station else str(old_pages[old_page]).length()
		context["paragraph_type_ratio"] = 0.0 if at_station else 1.0
		context["source_text_progress"] = float(old_consumed) / float(old_total)
		if not await _reload_authored_result_context(context, language, 2, 1, true):
			return false
		var current_page := current_cut if at_station else current_cut - 1
		var type_pos := 0 if at_station else str(_story.get("_type_full")).length()
		if int(_story.get("_para_index")) != current_page or int(_story.get("_type_pos")) != type_pos \
				or bool(_story.get("_typing")) != at_station:
			_fail("W96 actual prior-text save crossed the arrival boundary (expected station=%s cursor=%d)" % [at_station, type_pos])
			return false
		await _wait_stable()
		if not _w96_surface(3, at_station) or not _w96_receipt(3, expected, deferred, false):
			return false
	return true

func _w96_legacy_unsplit(authored: String, final_context: Dictionary) -> bool:
	# Pre-cut v4 displayed source 1 as a single screen here. Its old source
	# progress already meant the reader reached the arrival; do not reapply c3.
	var old_data: Dictionary = _story.call("_story_page_data", authored)
	var old_pages: Array = old_data.get("pages", [])
	var old_sources: Array = old_data.get("source_indices", [])
	if old_sources != [0, 1] or not str(old_pages[1]).contains(W96_ARRIVAL[LocaleManager.language]):
		_fail("W96 expected a single old v4 screen for unsplit source 1")
		return false
	var legacy := final_context.duplicate(true)
	legacy["paragraph_index"] = 1
	legacy["type_pos"] = str(old_pages[1]).length()
	return await _reload_authored_result_context(legacy, LocaleManager.language, 2, 1)

func _save_w96_frame(label: String) -> bool:
	var portrait := _story.get("_portrait_frame") as Control
	for _frame in range(150):
		if not portrait.visible or portrait.modulate.a >= 0.99:
			return await _save_viewport_frame(_w96_capture_dir.path_join("%s_c3_%s.png" % [LocaleManager.language, label]))
		await get_tree().process_frame
	_fail("W96 portrait never settled for capture")
	return false

func _check_first_ktx(smoke: bool = false) -> bool:
	_first_ktx_capture_dir = "" if smoke else OS.get_environment("GANGNAM_FIRST_KTX_CAPTURE_DIR")
	var capture := not _first_ktx_capture_dir.is_empty()
	var languages := ["ko"] if smoke else M23_KTX_ANCHORS.keys()
	if capture:
		var language := OS.get_environment("GANGNAM_FIRST_KTX_CAPTURE_LANGUAGE")
		var output := DirAccess.open(_first_ktx_capture_dir) if _first_ktx_capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or not M23_KTX_ANCHORS.has(language) or DisplayServer.get_name() == "headless":
			_fail("first KTX capture requires fresh absolute output, known locale and real display")
			return false
		languages = [language]
		OS.low_processor_usage_mode = false
	await _remove_story()
	await _stop_audio()
	_context = "first_ktx/prepare"
	if not _prepare_full_owner_history(89, [[14, "arc_father_01_call"], [21, "arc_father_02_signal"],
			[49, "chapter_card_34"], [57, "arc_father_medication"]]) or not _m23_selector():
		_fail("first KTX could not prepare the actual parents-to-call owner")
		return false
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	var paths := 0
	for language in languages:
		await _remove_story()
		LocaleManager.set_language(language)
		GameState.call("_restore_serialized_snapshot_exact", prepared)
		GameState.mental = 60
		GameState.money = 600_000.0
		GameState.moral_tint = 0.0
		var housing: String = M23_HOUSING[M23_KTX_ANCHORS.keys().find(language) % M23_HOUSING.size()]
		GameState.housing = housing
		_context = "%s/first_ktx/%s" % [language, housing]
		if not await _play_m23_parents(false, int(language in ["ja", "zh-TW"]), housing, false) \
				or not await _read_first_ktx(housing, capture, smoke):
			_fail("first KTX focused chain incomplete")
			await _remove_story()
			await _stop_audio()
			return false
		paths += 1
	await _remove_story()
	await _stop_audio()
	if capture and DirAccess.get_files_at(_first_ktx_capture_dir).size() != 3:
		_fail("first KTX expected exactly three settled viewport renders")
	if _failures != 0:
		return false
	if smoke:
		print("FIRST_KTX_SMOKE_OK paths=1 same_layout_v4=1 phases=3 full_owner=1 prepared_history=1")
		return true
	print("FIRST_KTX_OK paths=%d same_layout_v4=%d legacy_unsplit_v4=%d different_locale_v4=%d locale_rebinds=%d text_size_reflows=%d full_owner=1 prepared_history=1 captures=%d" % [paths,
		0 if capture else paths * 5, 0 if capture else paths * 3, 0 if capture else paths,
		0 if capture else 12, 0 if capture else paths * 6, 3 if capture else 0])
	return true

func _read_first_ktx(housing: String, capture: bool, smoke: bool) -> bool:
	var language := LocaleManager.language
	var event: Dictionary = _story.get("_current")
	var home := _m23_home_background(housing)
	if not (_story.get("_communication_badge") as Control).visible \
			or not await _read_phase_surface_only(home, "apartment"):
		_fail("mother's call first needs the connected phone and actual home")
		return false
	_story.call("_on_advance")
	await _wait_stable()
	if not bool(_story.get("_showing_choices")) or (_story.get("_choice_box") as Control).get_child_count() != 4 \
			or not (_story.get("_communication_badge") as Control).visible:
		_fail("mother's call did not offer the existing four choices")
		return false
	var expected := [float(GameState.money) - 80_000.0, GameState.mental - 15,
		GameState.get_cast_affinity("father") + 15, GameState.moral_tint + 8.0, GameState.event_log.size() + 1]
	_story.call("_on_choice", 0)
	await _wait_stable()
	var authored := str(_story.call("_fmt", event["choices"][0]["result_text"]))
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var cuts := _first_ktx_expected_cuts(pages)
	if cuts.is_empty() or not _m23_same_prose(pages, authored):
		_fail("first KTX changed/lost author text or its exact location anchors")
		return false
	for page in range(pages.size()):
		var stage := int(page >= cuts[0]) + int(page >= cuts[1])
		if int(_story.get("_para_index")) != page or not _first_ktx_surface(stage, housing, expected):
			_fail("first KTX did not advance within the expected original prose")
			return false
		await _finish_page()
		if page == 0 or page in cuts:
			if capture:
				if not await _first_ktx_capture(language, stage):
					return false
			elif not smoke:
				if not await _reload_cut_result(0, page, false):
					return false
				await _wait_stable()
				if not _first_ktx_surface(stage, housing, expected) \
						or not await _reflow_first_ktx(stage, housing, expected, language):
					_fail("first KTX same-layout cold/locale/text reflow failed at stage %d" % stage)
					return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			if not capture and (page + 1 == cuts[0] or (not smoke and page + 1 == cuts[1])):
				if not await _reload_cut_result(0, page + 1, true):
					return false
			await _wait_stable()
	if not capture and not smoke:
		for stage in range(3):
			if not await _reload_legacy_first_ktx(authored, stage, housing, expected):
				return false
		var different_language := "en" if language == "ko" else "ko"
		var last_context: Dictionary = _story.call("build_save_resume_context")
		if not await _reload_first_ktx_context(last_context, different_language) \
				or int(_story.get("_para_index")) != 0 \
				or not _first_ktx_surface(0, housing, expected):
			_fail("first KTX different-locale cold resume did not conservatively rewind booking")
			return false
	return true

func _read_phase_surface_only(background: String, ambience: String) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	for page in range(pages.size()):
		await _finish_page()
		if int(_story.get("_para_index")) != page or not _expect_surface(background, ambience, "mother's call"):
			return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	return not pages.is_empty()

func _first_ktx_expected_cuts(pages: Array) -> Array:
	var anchors: Array = M23_KTX_ANCHORS[LocaleManager.language]
	var cuts: Array = _story.get("_first_ktx_cut_pages")
	if cuts.size() != 2 or int(cuts[0]) < 1 or int(cuts[0]) >= int(cuts[1]) or int(cuts[1]) >= pages.size() \
			or not str(pages[cuts[0]]).begins_with(anchors[0]) or not str(pages[cuts[1]]).begins_with(anchors[1]):
		return []
	for page in range(pages.size()):
		if int(_story.call("_story_source_paragraph_index", page)) != 0:
			return []
	return cuts.duplicate()

func _first_ktx_surface(stage: int, housing: String, expected: Array) -> bool:
	var booking := stage == 0
	var actual := _m23_home_background(housing) if booking else str(["", M23_KTX_STATION, M23_KTX_COACH][stage])
	if not _expect_surface(actual, "apartment" if booking else "", "first KTX"):
		return false
	var cuts := _first_ktx_expected_cuts(_story.get("_paragraphs"))
	var page := int(_story.get("_para_index"))
	var receipt: Dictionary = GameState.event_log.back() if not GameState.event_log.is_empty() else {}
	var followups: Array = GameState.deferred_events.filter(func(entry: Dictionary) -> bool:
		return entry.get("event_id") in ["callback_rushed_to_father_echo", "callback_sent_money_instead_echo"])
	var cues: Array = AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(M23_CALL + ":"))
	if cuts.is_empty() or int(page >= cuts[0]) + int(page >= cuts[1]) != stage \
			or (_story.get("_communication_badge") as Control).visible \
			or (_story.get("_portrait_frame") as Control).visible != booking \
			or (not booking and (_story.get("_name_panel") as Control).visible) \
			or str(_story.get_meta("living_scene_effect", "")) != "none" or not cues.is_empty() \
			or not BGMPlayer._current_key.is_empty() or BGMPlayer._ambience_player.playing != booking \
			or not BGMPlayer._current_human_ambience_key.is_empty() or BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() or BGMPlayer._season_player.playing:
		_fail("first KTX wrong cut, weather, actor, phone, score or cue at stage %d: %s" % [stage, cues])
		return false
	if not FULL_STORY_FLOW.valid_session() or GameState.turn != 89 \
			or int(_story.get("_pending_result_choice_index")) != 0 or not bool(_story.get("_pending_after_result")) \
			or str((_story.get("_current") as Dictionary).get("id")) != M23_CALL \
			or receipt.get("event_id") != M23_CALL or int(receipt.get("choice_index", -1)) != 0 \
			or GameState.event_log.size() != expected[4] or not is_equal_approx(GameState.money, expected[0]) \
			or GameState.mental != expected[1] or GameState.get_cast_affinity("father") != expected[2] \
			or not is_equal_approx(GameState.moral_tint, expected[3]) or GameState.get_cast_stage("father") != "health_crisis" \
			or not bool(GameState.flags.get("arc_father_03_seen", false)) or not bool(GameState.flags.get("rushed_to_father", false)) \
			or bool(GameState.flags.get("sent_money_instead", false)) or bool(GameState.flags.get("sangchul_helped_with_father", false)) \
			or followups.size() != 1 or followups[0].get("event_id") != "callback_rushed_to_father_echo" \
			or int(followups[0].get("trigger_turn", -1)) != 103:
		_fail("first KTX cost, flags, father stage or delayed receipt changed/repeated")
		return false
	return true

func _reflow_first_ktx(stage: int, housing: String, expected: Array, language: String) -> bool:
	for level in ["large", "standard"]:
		_story.call("_set_story_text_size", level)
		await _wait_stable()
		if not _first_ktx_surface(stage, housing, expected):
			return false
	# Exercise the real full-build language control without widening its
	# release allowlist. Root cold/visual coverage also loads prepared locales.
	if language in ["ko", "en"]:
		for other in ["en" if language == "ko" else "ko", language]:
			_story.call("_set_story_language", other)
			await _wait_stable()
			if LocaleManager.language != other or not _first_ktx_surface(stage, housing, expected):
				_fail("first KTX locale rebind expected %s and stage %d" % [other, stage])
				return false
	await _finish_page()
	return true

func _reload_legacy_first_ktx(authored: String, stage: int, housing: String, expected: Array) -> bool:
	# Model the actual pre-cut v4 payload using the same unsplit paginator it used.
	# Save/load still traverses the regular disk serializer; the real slot is never opened.
	var legacy: Dictionary = _story.call("build_save_resume_context")
	var old_data: Dictionary = _story.call("_story_page_data", authored)
	var old_pages: Array = old_data["pages"]
	var anchors: Array = M23_KTX_ANCHORS[LocaleManager.language]
	var total := 0
	for old_page in old_pages:
		total += str(old_page).length()
	var anchor_offsets := [0, -1, -1, total]
	var seen := 0
	for old_page in old_pages:
		for index in range(anchors.size()):
			var at := str(old_page).find(anchors[index])
			if at >= 0:
				anchor_offsets[index + 1] = seen + at
		seen += str(old_page).length()
	if int(anchor_offsets[1]) <= 0 or int(anchor_offsets[2]) <= int(anchor_offsets[1]):
		_fail("could not reconstruct actual prior unsplit result progress")
		return false
	var target := roundi(lerpf(anchor_offsets[stage], anchor_offsets[stage + 1], 0.45))
	seen = 0
	for index in range(old_pages.size()):
		var length := str(old_pages[index]).length()
		if target <= seen + length:
			legacy["paragraph_index"] = index
			legacy["type_pos"] = target - seen
			legacy["paragraph_type_ratio"] = float(target - seen) / float(length)
			legacy["paragraph_was_typing"] = true
			legacy["source_text_progress"] = float(target) / float(total)
			break
		seen += length
	if not await _reload_first_ktx_context(legacy, LocaleManager.language) \
			or not _first_ktx_surface(stage, housing, expected) \
			or not bool(_story.get("_typing")) or int(_story.get("_type_pos")) < 1:
		_fail("first KTX prior unsplit v4 position moved outside semantic stage %d" % stage)
		return false
	return true

func _reload_first_ktx_context(context: Dictionary, target_locale: String) -> bool:
	return await _reload_authored_result_context(context, target_locale, 1, 0)

func _reload_authored_result_context(context: Dictionary, target_locale: String, source_count: int, source_index: int,
		immediate: bool = false) -> bool:
	if context.get("phase") != "result" or int(context.get("source_paragraph_count", 0)) != source_count \
			or int(context.get("source_paragraph_index", -1)) != source_index \
			or not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("isolated save did not preserve the expected original source paragraph")
		return false
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int(disk.get("version", -1)) != 4:
		_fail("authored result altered disk schema v4")
		return false
	await _remove_story()
	GameState.start_new_game()
	LocaleManager.set_language(target_locale)
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("isolated authored result v4 cold load failed")
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	if immediate:
		return LocaleManager.language == target_locale
	await _wait_stable()
	_story.call("_finish_story_scene_transition")
	return LocaleManager.language == target_locale

func _first_ktx_capture(language: String, stage: int) -> bool:
	var portrait := _story.get("_portrait_frame") as Control
	for _frame in range(150):
		if not portrait.visible or portrait.modulate.a >= 0.99:
			var key: String = ["booking", "station", "coach"][stage]
			return await _save_viewport_frame(_first_ktx_capture_dir.path_join("%s_c0_%s.png" % [language, key]))
		await get_tree().process_frame
	_fail("first KTX player portrait did not finish fading in")
	return false

func _check_sinchon_offer() -> bool:
	_offer_capture_dir = OS.get_environment("GANGNAM_SINCHON_OFFER_CAPTURE_DIR")
	var language_arg := OS.get_environment("GANGNAM_SINCHON_OFFER_CAPTURE_LANGUAGE")
	var languages := W4_TERMS.keys()
	if not _offer_capture_dir.is_empty():
		var output := DirAccess.open(_offer_capture_dir) if _offer_capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or not W4_TERMS.has(language_arg) or DisplayServer.get_name() == "headless":
			_fail("Sinchon offer capture requires a fresh absolute output, known locale and real display")
			return false
		if OS.get_environment("GANGNAM_SINCHON_OFFER_CAPTURE_COMPACT") == "1":
			DisplayServer.window_set_size(Vector2i(960, 600))
			await get_tree().process_frame
			if DisplayServer.window_get_size() != Vector2i(960, 600):
				_fail("Sinchon offer compact capture did not get a 960x600 window")
				return false
		languages = [language_arg]
		OS.low_processor_usage_mode = false
	await _remove_story()
	await _stop_audio()
	_context = "Sinchon-offer/prepare"
	if not _prepare_sinchon_offer():
		return false
	var prepared: Dictionary = GameState.serialize().duplicate(true)
	var paths := 0
	for language in languages:
		LocaleManager.set_language(language)
		for choice in range(3):
			await _remove_story()
			GameState.call("_restore_serialized_snapshot_exact", prepared)
			_context = "%s/Sinchon-offer/c%d" % [language, choice]
			if await _play_sinchon_offer(choice):
				paths += 1
	if _offer_capture_dir.is_empty():
		await _remove_story()
		LocaleManager.set_language("ko")
		GameState.call("_restore_serialized_snapshot_exact", prepared)
		_context = "ko/Sinchon-offer/prechoice-restore"
		if not await _check_offer_prechoice_resume():
			return false
	await _remove_story()
	await _stop_audio()
	if paths != languages.size() * 3:
		_fail("Sinchon offer path inventory incomplete: %d" % paths)
	if not _offer_capture_dir.is_empty():
		var expected := ["intro_p0", "intro_p1", "choices", "c0_p0", "c0_p1", "c1_p0", "c2_p0"]
		for shot in expected:
			if not FileAccess.file_exists(_offer_capture_dir.path_join(shot + ".png")):
				_fail("Sinchon offer capture missing %s" % shot)
	if _failures != 0:
		return false
	print("SINCHON_OFFER_OK paths=%d cold_results=%d cold_prechoice=%d full_owner=1 prepared_history=1 capture=%s" % [
		paths, paths if _offer_capture_dir.is_empty() else 0,
		2 if _offer_capture_dir.is_empty() else 0, not _offer_capture_dir.is_empty()])
	return true

func _prepare_sinchon_offer() -> bool:
	if not _prepare_full_owner_history(85, [[17, M03_EVENT], [34, REUNION], [49, "chapter_card_34"]]):
		return false
	GameState.mental = 60
	GameState.social_skill = 40
	var probe := load("res://scenes/MainGame.tscn").instantiate() as Control
	var eligible := bool(GameState.flags.get("arc_jiyeon_store_seen", false))
	for turn in [84, 85, 86, 87, 88, 89]:
		eligible = eligible and (probe.call("_next_arc_id", turn, true) == OFFER) == (turn in [85, 86, 87, 88])
	var competing: Dictionary = GameState.flags.duplicate()
	competing["arc_daeun_regular_seen"] = true
	var saved_cast: Dictionary = GameState.cast.duplicate(true)
	GameState.apply_cast_effect("daeun", {"affinity": 12})
	eligible = eligible and probe.call("_story_graph_contract_event_id", 85, competing, false) == "arc_daeun_03_fork"
	GameState.cast = saved_cast
	probe.free()
	if not eligible:
		_fail("Sinchon offer routing did not match full calendar, reunion witness or competing Daeun route")
	return eligible

func _prepare_full_owner_history(at_turn: int, extra_prior: Array) -> bool:
	# Prepared elapsed weeks, not played weeks; bind scene witnesses to actual
	# choice application. The scoped test exercises real routing at at_turn.
	GameState.start_new_game()
	if not FULL_STORY_FLOW.initialize_fresh_run():
		_fail("could not initialize a pristine full owner")
		return false
	var owner := FULL_STORY_FLOW.snapshot()
	for prior in [[1, "story_flashforward"], [1, "chapter_card_33"],
			[4, W4_EVENT], [8, "arc_temptation_clean"], [9, "arc_intro_04_hyunsu"],
			[9, "arc_chapter1_close"]] + extra_prior:
		GameState.turn = int(prior[0])
		var event: Dictionary = DataRegistry.find_event(str(prior[1]))
		var choice_index := int(prior[2]) if prior.size() > 2 else 0
		if event.is_empty() or not GameState.apply_choice(event, event["choices"][choice_index]):
			_fail("full owner preparation lost authored predecessor %s" % prior[1])
			return false
		var turn_key := str(GameState.turn)
		if not owner["read_receipts"].has(turn_key):
			owner["read_receipts"][turn_key] = []
		var tuple := {"turn": GameState.turn, "event_id": prior[1], "choice_index": choice_index}
		var record: Dictionary = tuple.duplicate()
		record.merge({"expression": false, "applied_sequence": GameState.events_seen, "applied_tuple": tuple})
		owner["read_receipts"][turn_key].append(record)
	for prior_turn in range(1, at_turn):
		owner["completed_turns"][str(prior_turn)] = {"turn": prior_turn, "next_turn": prior_turn + 1}
		owner["routine_receipts"][str(prior_turn)] = {
			"turn": prior_turn, "source": FULL_STORY_FLOW.ROUTINE_SOURCE, "job_id": "", "status": "applied",
			"effects": {"money": 70_000, "health": 0, "mental": 4},
			"units": [
				{"kind": "livelihood", "requested_effects": FULL_STORY_FLOW.APPROVED_UNEMPLOYED.duplicate(),
					"effects": {"money": 70_000, "health": -1, "mental": 1},
					"before": {"money": 500_000, "health": 65, "mental": 60, "work_performance": 0},
					"after": {"money": 570_000, "health": 64, "mental": 61, "work_performance": 0}},
				{"kind": "recovery", "requested_effects": FULL_STORY_FLOW.APPROVED_RECOVERY.duplicate(),
					"effects": {"health": 1, "mental": 3},
					"before": {"money": 570_000, "health": 64, "mental": 61, "work_performance": 0},
					"after": {"money": 570_000, "health": 65, "mental": 64, "work_performance": 0}},
			],
		}
	owner["last_completed_turn"] = at_turn - 1
	GameState.flags[FULL_STORY_FLOW.STATE_KEY] = owner
	GameState.turn = at_turn
	GameState.week_of_month = (at_turn - 1) % 4 + 1
	GameState.month = int((at_turn - 1) / 4.0) % 12 + 1
	GameState.year = 2026 + int((at_turn - 1) / 48.0)
	GameState.age = 33 + int((at_turn - 1) / 48.0)
	SaveManager.clear_loaded_resume_context()
	if not FULL_STORY_FLOW.valid_session():
		_fail("prepared full owner failed its calendar or authentic read rules")
		return false
	return true

func _open_sinchon_offer() -> bool:
	return await _open_full_fixture_event(OFFER)

func _open_full_fixture_event(expected_id: String, expected_continuation: Array = [], presentation_only: bool = false) -> bool:
	var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
	ingress.set_meta("_screenshot_qa_static_surface", true)
	var event_id: String = expected_id if presentation_only else ingress.call("_next_arc_id", -1, true)
	ingress.call("_go_story_mode", [event_id])
	ingress.free()
	var queue: Array = GameState.pending_story_queue
	if event_id != expected_id or queue.slice(0, expected_continuation.size() + 1) != [expected_id] + expected_continuation \
			or (queue.size() > expected_continuation.size() + 1 and (expected_id != W96_VISIT \
				or queue.size() != 3 or str(queue[2]) != "arc_year2_scene")) or not FULL_STORY_FLOW.valid_session():
		_fail("%s did not reserve its normal FullStoryFlow handoff" % expected_id)
		return false
	# Enter from a rain/street crowd and a stale seasonal bed to check the actual
	# scene contract clears both, including after the outdoor choice moves.
	BGMPlayer.set_ambience("rain")
	BGMPlayer.set_season_ambience("winter")
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	return true

func _play_sinchon_offer(choice: int) -> bool:
	if not await _open_sinchon_offer():
		return false
	var intro: Array = (_story.get("_paragraphs") as Array).duplicate()
	if int(_story.call("_story_source_paragraph_count")) != 5:
		_fail("Sinchon offer lost a source paragraph")
		return false
	for page in range(intro.size()):
		var source := int(_story.call("_story_source_paragraph_index", page))
		if source == 0:
			_story.call("_refresh_story_speaker_language")
		if not _expect_offer_surface(OFFER_STOP if source == 0 else OFFER_SEDAN,
				"" if source == 0 else OFFER_UMBRELLA, source >= 1):
			return false
		await _finish_page()
		if choice == 0 and not _offer_capture_dir.is_empty() and source in [0, 1] \
				and page == int(_story.call("_first_story_page_for_source", source)):
			await _save_offer_frame("intro_p%d" % source)
		_story.call("_on_advance")
		await _wait_stable()
	var current: Dictionary = _story.get("_current")
	if not bool(_story.get("_showing_choices")) or current.get("id") != OFFER \
			or (current.get("choices", []) as Array).size() != 3 \
			or not _expect_offer_surface(OFFER_SEDAN, OFFER_UMBRELLA, true):
		_fail("Sinchon offer did not retain all choices at the rainy sedan")
		return false
	if choice == 0 and not _offer_capture_dir.is_empty():
		await _save_offer_frame("choices")
	var expected := [float(GameState.money), GameState.mental + [5, 2, 8][choice],
		GameState.social_skill + (3 if choice == 1 else 0),
		GameState.get_cast_affinity("jiyeon") + [6, 15, 20][choice],
		["intrigued", "interest", "drawn"][choice], GameState.event_log.size() + 1]
	_story.call("_on_choice", choice)
	await _wait_stable()
	var results: Array = (_story.get("_paragraphs") as Array).duplicate()
	var whitespace := RegEx.new()
	whitespace.compile("\\s+")
	var authored: String = _story.call("_fmt", str(current["choices"][choice].get("result_text", "")))
	if int(_story.call("_story_source_paragraph_count")) != [3, 3, 2][choice] \
			or whitespace.sub("".join(PackedStringArray(results)), "", true) != whitespace.sub(authored, "", true) \
			or not _expect_offer_choice(choice, expected):
		_fail("Sinchon offer choice lost original result prose or effects")
		return false
	var background: String = [OFFER_STATION, OFFER_CAFE, OFFER_SEDAN][choice]
	var portrait_id: String = ["", "jiyeon_warm", OFFER_UMBRELLA][choice]
	var cold := false
	for page in range(results.size()):
		var source := int(_story.call("_story_source_paragraph_index", page))
		if page == 0 and choice in [0, 1]:
			_story.call("_refresh_story_speaker_language")
		if not _expect_offer_surface(background, portrait_id, not cold):
			return false
		await _finish_page()
		if not _offer_capture_dir.is_empty() and (page == 0 or (choice == 0 and source == 1 \
				and page == int(_story.call("_first_story_page_for_source", source)))):
			await _save_offer_frame("c%d_p%d" % [choice, source])
		if page == 0 and _offer_capture_dir.is_empty():
			if not await _reload_cut_result(choice, 0, false):
				return false
			await _wait_stable()
			if not _expect_offer_surface(background, portrait_id, false) or not _expect_offer_choice(choice, expected):
				return false
			cold = true
		if page + 1 < results.size():
			_story.call("_on_advance")
			await _wait_stable()
	return true

func _check_offer_prechoice_resume() -> bool:
	if not await _open_sinchon_offer():
		return false
	await _finish_page()
	_story.call("_on_advance")
	await _wait_stable()
	if int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) != 1 \
			or not _expect_offer_surface(OFFER_SEDAN, OFFER_UMBRELLA, true):
		return false
	await _finish_page()
	if not await _reload_offer_prechoice("prose"):
		return false
	for _advance in range((_story.get("_paragraphs") as Array).size()):
		if bool(_story.get("_showing_choices")):
			break
		await _finish_page()
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")):
		_fail("Sinchon offer choices were not reached after cold arrival")
		return false
	return await _reload_offer_prechoice("choices")

func _reload_offer_prechoice(phase: String) -> bool:
	if not await _reload_prechoice(phase, OFFER):
		return false
	return _expect_offer_surface(OFFER_SEDAN, OFFER_UMBRELLA, false)

func _reload_prechoice(phase: String, event_id: String, require_full_owner: bool = true) -> bool:
	var saved_context: Dictionary = _story.call("build_save_resume_context")
	var count := GameState.event_log.size()
	if saved_context.get("phase") != phase or not SaveManager.save_game(W8_QA_SLOT, saved_context, {"qa_fixture": true}):
		_fail("%s could not save %s" % [event_id, phase])
		return false
	await _remove_story()
	GameState.start_new_game()
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("%s could not cold load %s" % [event_id, phase])
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	var restored_context: Dictionary = _story.call("build_save_resume_context")
	if restored_context.get("event_id") != event_id or restored_context.get("phase") != phase \
			or int(restored_context.get("source_paragraph_index", -1)) != int(saved_context.get("source_paragraph_index", -2)) \
			or GameState.event_log.size() != count \
			or (require_full_owner and not FULL_STORY_FLOW.valid_session()):
		_fail("%s %s resume changed its source page, handoff or choice state" % [event_id, phase])
		return false
	return true

func _save_offer_frame(label: String) -> void:
	var portrait := _story.get("_portrait_frame") as Control
	var showing_choices := bool(_story.get("_showing_choices"))
	var target_alpha := 0.94 if showing_choices else 1.0
	var choice_box := _story.get("_choice_box") as Control
	for _frame in range(120):
		var choices_settled := not showing_choices
		if showing_choices and choice_box.modulate.a >= 0.99 and choice_box.get_child_count() == 3:
			choices_settled = true
			for child in choice_box.get_children():
				var group := child as Control
				choices_settled = choices_settled and group.modulate.a >= 0.99 \
					and group.scale.is_equal_approx(Vector2.ONE)
		if choices_settled and (not portrait.visible or portrait.modulate.a >= target_alpha - 0.01):
			await _save_viewport_frame(_offer_capture_dir.path_join(label + ".png"))
			return
		await get_tree().process_frame
	_fail("Sinchon offer portrait or choices did not finish fading in at %s" % label)

func _expect_offer_choice(choice: int, expected: Array) -> bool:
	var records: Array = GameState.event_log
	var receipt: Dictionary = records.back() if not records.is_empty() else {}
	var followups: Array = GameState.deferred_events.filter(func(entry: Dictionary) -> bool:
		return entry.get("event_id") == OFFER_FOLLOW_UP)
	var expected_followups := 1 if choice == 2 else 0
	var valid: bool = FULL_STORY_FLOW.valid_session() and bool(_story.get("_pending_after_result")) \
		and int(_story.get("_pending_result_choice_index")) == choice and records.size() == expected[5] \
		and receipt.get("event_id") == OFFER and receipt.get("choice_index") == choice \
		and is_equal_approx(GameState.money, expected[0]) and GameState.mental == expected[1] \
		and GameState.social_skill == expected[2] and GameState.get_cast_affinity("jiyeon") == expected[3] \
		and GameState.get_cast_stage("jiyeon") == expected[4] and GameState.flags.get("arc_jiyeon_offer_seen", false) \
		and followups.size() == expected_followups \
		and (choice != 2 or int(followups[0].get("trigger_turn", -1)) == 101)
	for index in range(OFFER_BRANCH_FLAGS.size()):
		valid = valid and bool(GameState.flags.get(OFFER_BRANCH_FLAGS[index], false)) == (index == choice)
	if not valid:
		_fail("Sinchon offer receipt/effects expected=%s actual=%s followups=%s valid_owner=%s" % [
			expected, [GameState.money, GameState.mental, GameState.social_skill,
				GameState.get_cast_affinity("jiyeon"), GameState.get_cast_stage("jiyeon"), records.size()],
			followups, FULL_STORY_FLOW.valid_session()])
	return valid

func _expect_offer_surface(background: String, portrait_id: String, car_cue: bool) -> bool:
	var rain := background != OFFER_CAFE
	if not _expect_surface(background, "rain" if rain else "", "Sinchon offer"):
		return false
	var portrait := _story.get("_portrait_frame") as Control
	var face := _story.get("_portrait") as TextureRect
	var nameplate := _story.get("_name_panel") as Control
	var observed: Array[String] = []
	for key in AudioManager._story_audio_seen:
		if str(key).begins_with(OFFER + ":"):
			observed.append(str(key))
	var expected_cues: Array = [OFFER + "::description:1:0:traffic_pass"] if car_cue else []
	var weather: Dictionary = _story.get_meta("living_scene_profile", {})
	var expect_name := not portrait_id.is_empty() and not bool(_story.get("_showing_choices"))
	var expected_stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED if portrait_id == OFFER_UMBRELLA \
		else TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if str(_story.get_meta("living_scene_effect", "")) != ("rain" if rain else "none") \
			or not is_equal_approx(float(weather.get("base_intensity", -1.0)), 0.12 if rain else 0.0) \
			or portrait.visible != (not portrait_id.is_empty()) or nameplate.visible != expect_name \
			or (face.texture != null if portrait_id.is_empty() else (
				face.texture == null or face.texture.resource_path != ImageRegistry.get_portrait(portrait_id) \
				or face.stretch_mode != expected_stretch)) \
			or not BGMPlayer._current_key.is_empty() or observed != expected_cues \
			or BGMPlayer._ambience_player.playing != rain \
			or not BGMPlayer._current_human_ambience_key.is_empty() or BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() or BGMPlayer._season_player.playing:
		_fail("Sinchon offer surface weather=%s portrait=%s/%s expected=%s label=%s score=%s audible=%s/%s/%s cues=%s" % [
			_story.get_meta("living_scene_effect", ""), portrait.visible,
			"" if face.texture == null else face.texture.resource_path,
			portrait_id, nameplate.visible, BGMPlayer._current_key, BGMPlayer._ambience_player.playing,
			BGMPlayer._current_human_ambience_key, BGMPlayer._current_season_key, observed])
		return false
	return true

func _play_w234_case(language: String, choice_index: int) -> void:
	await _remove_story()
	_context = "%s/W234/choice%d" % [language, choice_index]
	_seed_story(W234_SUMMIT, 224)
	GameState.money = 2_500_000_000.0
	GameState.flags.merge({"father_passed": true, "chapter5_general_minseo_arrival_1": true,
		"arc_y5_general_name_boundary_exact_seen": true, "chapter5_general_name_boundary_0": true,
		"arc_y5_general_debt_memory_reconnect_seen": true, "chapter5_general_debt_memory_reconnect_0": true,
		"arc_endgame_sixmonths_seen": true})
	GameState.event_log = [
		{"event_id": "arc_minseo_03_arrival", "choice_index": 1, "turn": 203},
		{"event_id": "arc_y5_general_name_boundary_exact", "choice_index": 0, "turn": 211},
		{"event_id": "arc_y5_general_debt_memory_reconnect", "choice_index": 0, "turn": 220},
	]
	GameState.prepare_chapter5_finale_route_entry()
	GameState.record_chapter5_finale_choice("arc_y5_general_father_legacy_voice_exact", 1)
	GameState.turn = 229
	GameState.record_chapter5_finale_choice("arc_y5_general_debt_memory_voice_exact", 0)
	GameState.turn = 234
	GameState.year = 2030
	GameState.month = 11
	GameState.week_of_month = 2
	if GameState.chapter5_finale_next_event_for_turn() != W234_SUMMIT:
		_fail("W234 exact general-route eligibility could not reach the summit")
		return
	BGMPlayer.stop()
	BGMPlayer.set_ambience("office")
	BGMPlayer.set_season_ambience("winter")
	if not BGMPlayer._ambience_player.playing or not BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._season_player.playing:
		_fail("W234 test did not seed the three unrelated ambience layers")
		return
	GameState.pending_story_queue = [W234_SUMMIT]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if str((_story.get("_current") as Dictionary).get("id", "")) != W234_SUMMIT:
		_fail("W234 genuine choice surface was unavailable")
		return
	for _page in range((_story.get("_paragraphs") as Array).size()):
		await _finish_page()
		if not _expect_surface(W234_OFFICE, "", "W234 introductory office") \
				or not _expect_no_ambience("W234 quiet solo office"):
			return
		_story.call("_on_advance")
		await _wait_stable()
	var score_token := int(BGMPlayer.get("_punctuation_token"))
	var cash := float(GameState.money)
	var initial_receipts := GameState.event_log.size()
	AudioManager._last_sfx_ms.erase("traffic_pass")
	if not bool(_story.get("_showing_choices")) or BGMPlayer.get("_current_key") != "reckoning":
		_fail("W234 choice or original cue missing")
		return
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	var pages: Array = _story.get("_paragraphs")
	var cut := int(_story.get("_result_location_cut_page"))
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.call("_story_source_paragraph_count")) != 3 \
			or not is_equal_approx(GameState.money, cash) \
			or GameState.event_log.size() != initial_receipts + 1 \
			or not GameState.chapter5_finale_receipt_matches(W234_SUMMIT, choice_index):
		_fail("W234 expected three source paragraphs and unchanged cash")
		return
	if choice_index == 0 and (cut < 3 or cut >= pages.size()
			or not str(pages[cut]).begins_with(str(W234_DOOR[language]))
			or int(_story.call("_story_source_paragraph_index", cut - 1)) != 2):
		_fail("W234 no-call branch did not split the same last source paragraph")
		return
	for index in range(pages.size()):
		var outside := choice_index == 1 or index >= cut
		if int(_story.get("_para_index")) != index \
				or str(_story.get_meta("living_scene_effect", "")) != "none" \
				or BGMPlayer.get("_current_key") != "reckoning" \
				or int(BGMPlayer.get("_punctuation_token")) != score_token \
				or not _expect_surface(W234_BOULEVARD if outside else W234_OFFICE,
					"", "W234 exact result") \
				or not _expect_no_ambience("W234 boulevard" if outside else "W234 quiet solo office"):
			_fail("W234 route, score or room-tone timing drifted")
			return
		if AudioManager._last_sfx_ms.has("traffic_pass") != outside \
				or not AudioManager._story_audio_seen.has(W234_SUMMIT + "::description:0:0:paper_handle") \
				or AudioManager._story_audio_seen.has(W234_SUMMIT + "::result:1:0:0:paper_handle") != (choice_index == 1):
			_fail("W234 traffic played on the wrong side of the door")
			return
		await _finish_page()
		if not _w234_capture_dir.is_empty() and not await _save_viewport_frame(
				_w234_capture_dir.path_join("c%d_p%d_%s.png" % [
					choice_index, index, "street" if outside else "office"])):
			return
		if _w234_capture_dir.is_empty() and language == "ko" and index + 1 == pages.size():
			AudioManager._last_sfx_ms.erase("traffic_pass")
			if not await _reload_cut_result(choice_index, index, false):
				return
			if not _expect_surface(W234_BOULEVARD, "", "W234 saved outside") \
					or not _expect_no_ambience("W234 saved outside") \
					or not GameState.chapter5_finale_receipt_matches(W234_SUMMIT, choice_index) \
					or AudioManager._last_sfx_ms.has("traffic_pass"):
				_fail("W234 load replayed an exit cue or changed the saved result")
				return
			_w234_reloads += 1
		if index + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	_w234_cases += 1

func _play_w4_case(language: String, choice_index: int, demo: bool) -> void:
	await _remove_story()
	_context = "%s/W4/choice%d/demo=%s" % [language, choice_index, demo]
	_seed_story(W4_EVENT, 4)
	GameState.age = 33
	GameState.month = 1
	GameState.week_of_month = 4
	GameState.housing = "goshiwon"
	GameState.money = 500_000.0
	BGMPlayer.stop()
	if demo:
		GameState.story_return_scene = "res://playtests/order124/StoryChoiceM1M6Playtest.tscn"
		W4_DEMO.install_story_demo_runtime_events()
	GameState.pending_story_queue = [W4_EVENT]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	var current: Dictionary = _story.get("_current")
	var choice: Dictionary = current.get("choices", [{}, {}])[choice_index]
	if current.get("id") != W4_EVENT or (demo and not (choice.get("flags", []) as Array).any(
			func(flag): return str(flag).begins_with("order124_choice__arc_temptation_01__"))):
		_fail("W4 actual root or demo receipt-bearing overlay missing")
		return
	for _page in range((_story.get("_paragraphs") as Array).size()):
		await _finish_page()
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")):
		_fail("W4 original choices are missing")
		return
	var initial_cash := float(GameState.money)
	var records := GameState.event_log.size()
	var score_token := int(BGMPlayer.get("_punctuation_token"))
	if str(BGMPlayer.get("_current_key")) != "crisis":
		_fail("W4 intro did not retain its existing crisis score")
		return
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	if not bool(_story.get("_pending_after_result")) \
			or not is_equal_approx(GameState.money, initial_cash + (2_000_000.0 if choice_index == 1 else 0.0)) \
			or GameState.event_log.size() != records + 1 \
			or bool(GameState.flags.get("lent_account", false)) != (choice_index == 1):
		_fail("W4 original choice effect was not applied exactly once")
		return
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var cut := int(_story.get("_result_location_cut_page"))
	var terms: Array = W4_TERMS[language]
	if choice_index == 1:
		var raw := str(_story.call("_fmt", str(choice["result_text"])))
		var whitespace := RegEx.new()
		whitespace.compile("\\s+")
		if cut < 2 or cut >= pages.size() or not str(pages[cut]).begins_with(terms[1]) \
				or not str("".join(PackedStringArray(pages.slice(0, cut)))).contains(terms[0]) \
				or int(_story.call("_story_source_paragraph_count")) != 2 \
				or whitespace.sub("".join(PackedStringArray(pages)), "", true) != whitespace.sub(raw, "", true):
			_fail("W4 exact localized content or paragraph boundaries changed")
			return
	elif cut != -1:
		_fail("W4 refusal incorrectly received a location cut")
		return
	var restored := false
	for page_index in range(pages.size()):
		if int(_story.get("_para_index")) != page_index:
			_fail("W4 result skipped or repeated a physical page")
			return
		var source := int(_story.call("_story_source_paragraph_index", page_index))
		var locker := choice_index == 1 and source == 1 and page_index < cut
		if not _w4_surface(locker) or (not restored and (
				int(BGMPlayer.get("_punctuation_token")) != score_token or BGMPlayer.get("_current_key") != "crisis")):
			_fail("W4 location or live score changed outside the authored cut")
			return
		if language == "ko" and not demo and choice_index == 1 \
				and (page_index == cut - 1 or page_index == cut):
			for other in ["en", "ko"]:
				_story.call("_set_story_language", other)
				await _wait_stable()
				if LocaleManager.language != other or not _w4_surface(locker):
					_fail("W4 locale reflow changed the current place")
					return
				_w4_rebinds += 1
		await _finish_page()
		if not _w4_capture_dir.is_empty():
			var sample := ""
			if page_index == 0:
				sample = "01_room.png"
			elif locker and int(_story.call("_story_source_paragraph_index", page_index - 1)) == 0:
				sample = "02_locker.png"
			elif page_index == cut:
				sample = "03_home.png"
			if not sample.is_empty() and not await _save_viewport_frame(_w4_capture_dir.path_join(sample)):
				return
		if not demo and choice_index == 1 and page_index == cut - 1:
			if not await _reload_cut_result(choice_index, page_index, false):
				return
			await _wait_stable()
			if not _w4_surface(true):
				return
			_w4_reloads += 1
			restored = true
		if page_index + 1 < pages.size():
			_story.call("_on_advance")
			if not demo and choice_index == 1 and (
					page_index + 1 == cut or (source == 0 and int(_story.call(
						"_story_source_paragraph_index", page_index + 1)) == 1)):
				if not await _reload_cut_result(choice_index, page_index + 1, true):
					return
				_w4_reloads += 1
				restored = true
			await _wait_stable()
	_w4_cases += 1

func _w4_surface(locker: bool) -> bool:
	var seasonal := BGMPlayer.get("_season_player") as AudioStreamPlayer
	if str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not is_instance_valid(seasonal) or seasonal.playing:
		_fail("W4 interior received precipitation or a seasonal loop")
		return false
	var bed := BGMPlayer.get("_ambience_player") as AudioStreamPlayer
	if not is_instance_valid(bed) or bed.playing == locker:
		_fail("W4 expected a playing bed only in the room")
		return false
	return _expect_surface(W8_LOCKERS if locker else W4_ROOM, "" if locker else "room", "W4 result") \
		and (not locker or _expect_no_ambience("W4 locker"))

func _play_w8_case(language: String, choice_index: int) -> void:
	await _remove_story()
	_context = "%s/%s/choice%d" % [language, W8_EVENT, choice_index]
	var capture := not _w8_capture_dir.is_empty()
	_seed_story(W8_EVENT, 8)
	GameState.age = 33
	GameState.month = 2
	GameState.week_of_month = 4
	GameState.housing = "goshiwon"
	GameState.money = 2_500_000.0
	GameState.pending_story_queue = [W8_EVENT]
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	await _wait_stable()
	_story.call("_set_auto_mode", false, false, false)
	var current: Dictionary = _story.get("_current")
	var authored_choices: Array = current.get("choices", [])
	if current.get("id") != W8_EVENT or authored_choices.size() != 2:
		_fail("expected the real W8 event and its two original choices")
		return
	var intro: Array = (_story.get("_paragraphs") as Array).duplicate()
	for page_index in range(intro.size()):
		await _finish_page()
		if not _w8_expect_surface("street_rainy", "rain", "rain", "intro-%d" % page_index):
			return
		if capture and page_index == 0:
			await get_tree().create_timer(1.5).timeout
			await _save_w8_capture(language, choice_index, "01_rain_call")
		_story.call("_on_advance")
		await _wait_stable()
	if not bool(_story.get("_showing_choices")) \
			or not _w8_expect_surface("street_rainy", "rain", "rain", "choice-dock"):
		_fail("a result location appeared before the original choices")
		return
	var before_money := float(GameState.money)
	var before_count := GameState.event_log.size()
	if capture:
		await _save_w8_capture(language, choice_index, "02_choices")
		_mark_w8_capture("choice_commit")
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index \
			or GameState.event_log.size() != before_count + 1 \
			or not is_equal_approx(GameState.money, before_money + (
				-1_500_000.0 if choice_index == 0 else 3_000_000.0)):
		_fail("W8 original choice and cash effect were not applied exactly once")
		return
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var cut: int = _w8_expect_cut(language, choice_index, pages)
	if cut < 0:
		return
	for page_index in range(pages.size()):
		if int(_story.get("_para_index")) != page_index:
			_fail("W8 advance skipped a page")
			return
		var after_cut := page_index >= cut
		var result_background := (W8_BANK_EXIT if after_cut else W8_BANK) \
			if choice_index == 0 else (W8_LOCKERS if after_cut else "street_rainy")
		var result_ambience := ("street" if after_cut else "") \
			if choice_index == 0 else ("" if after_cut else "rain")
		var result_weather := "rain" if result_ambience == "rain" else "none"
		if not _w8_expect_surface(result_background, result_ambience, result_weather,
				"result-%d" % page_index):
			return
		if not capture and page_index + 1 == cut and language == "ko" \
				and not await _w8_switch_languages(choice_index, false):
			return
		await _finish_page()
		if capture:
			var shot_label := ""
			if page_index + 1 == cut:
				shot_label = "04_before_move"
			elif page_index == cut:
				shot_label = "05_after_move"
			elif page_index == 0:
				shot_label = "03_first_result"
			elif page_index + 1 == pages.size():
				shot_label = "06_last_result"
			if not shot_label.is_empty():
				await _save_w8_capture(language, choice_index, shot_label)
				await get_tree().create_timer(1.5).timeout
		_w8_pages += 1
		if page_index + 1 < pages.size():
			if capture and page_index + 1 == cut:
				_mark_w8_capture("location_cut")
			_story.call("_on_advance")
			if not capture and page_index + 1 == cut:
				if not await _w8_cold_reload(choice_index, cut):
					return
			await _wait_stable()
			if not capture and page_index + 1 == cut and language == "ko" \
					and not await _w8_switch_languages(choice_index, true):
				return
	_w8_cases += 1

func _w8_expect_cut(language: String, choice_index: int, pages: Array) -> int:
	var prefix: String = W8_ARRIVAL_TEXT[language][choice_index]
	var cut := -1
	for index in range(pages.size()):
		if str(pages[index]).begins_with(prefix):
			if cut >= 0:
				_fail("W8 duplicated the localized cut sentence")
				return -1
			cut = index
	var current: Dictionary = _story.get("_current")
	var choices: Array = current["choices"]
	var authored: String = _story.call("_fmt", str(choices[choice_index].get("result_text", "")))
	var whitespace := RegEx.new()
	whitespace.compile("\\s+")
	var combined := "".join(PackedStringArray(pages))
	if cut < 1 or int(_story.get("_result_location_cut_page")) != cut \
			or int(_story.call("_story_source_paragraph_count")) != 2 \
			or int(_story.call("_story_source_paragraph_index", cut)) != (1 if choice_index == 0 else 0) \
			or int(_story.call("_story_source_paragraph_index", cut - 1)) != (1 if choice_index == 0 else 0) \
			or whitespace.sub(combined, "", true) != whitespace.sub(authored, "", true):
		_fail("W8 cut did not start at the exact localized sentence with two preserved source paragraphs")
		return -1
	return cut

func _w8_cold_reload(choice_index: int, cut: int) -> bool:
	if not await _reload_cut_result(choice_index, cut, true):
		return false
	_w8_reloads += 1
	return true

func _reload_cut_result(choice_index: int, cut: int, at_start: bool) -> bool:
	# Settle the already-entered location without processing a typing frame.
	# Manual save correctly stays unavailable while the ink transition runs.
	_story.call("_finish_story_scene_transition")
	var context: Dictionary = _story.call("build_save_resume_context")
	if context.get("phase") != "result" \
			or int(context.get("paragraph_index", -1)) != cut \
			or bool(context.get("paragraph_was_typing", false)) != at_start \
			or not is_equal_approx(float(context.get("paragraph_type_ratio", -1.0)), 0.0 if at_start else 1.0):
		_fail("expected page %d start=%s, saw phase=%s page=%s typing=%s ratio=%s" % [
			cut, at_start, context.get("phase"), context.get("paragraph_index"),
			context.get("paragraph_was_typing"), context.get("paragraph_type_ratio")])
		return false
	var cash := float(GameState.money)
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	var health := float(GameState.health)
	var mental := float(GameState.mental)
	var luck := float(GameState.luck)
	var count := GameState.event_log.size()
	if not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("isolated result disk save failed")
		return false
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int(disk.get("version", -1)) != 4:
		_fail("saved result did not use the unchanged v4 schema")
		return false
	await _remove_story()
	GameState.start_new_game()
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("isolated result cold load failed")
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	var expected_type_pos := 0 if at_start else str(_story.get("_type_full")).length()
	if int(_story.get("_para_index")) != cut or int(_story.get("_type_pos")) != expected_type_pos \
			or str((_story.get("_current") as Dictionary).get("id", "")) != event_id \
			or not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index \
			or GameState.event_log.size() != count \
			or not is_equal_approx(GameState.money, cash) or GameState.health != health \
			or GameState.mental != mental or GameState.luck != luck:
		_fail("cold result moved off the exact cut or reapplied the choice")
		return false
	return true

func _w8_switch_languages(choice_index: int, after_cut: bool) -> bool:
	var expected_background := (W8_BANK_EXIT if after_cut else W8_BANK) \
		if choice_index == 0 else (W8_LOCKERS if after_cut else "street_rainy")
	var expected_ambience := ("street" if after_cut else "") \
		if choice_index == 0 else ("" if after_cut else "rain")
	var expected_weather := "rain" if expected_ambience == "rain" else "none"
	for language in ["en", "ko"]:
		_story.call("_set_story_language", language)
		await _wait_stable()
		var pages: Array = _story.get("_paragraphs")
		var cut := _w8_expect_cut(language, choice_index, pages)
		if LocaleManager.language != language or cut < 0 \
				or (int(_story.get("_para_index")) >= cut) != after_cut \
				or not _w8_expect_surface(expected_background, expected_ambience,
					expected_weather, "switch-%s" % language):
			_fail("W8 language change did not preserve the current place")
			return false
		_w8_language_switches += 1
	return true

func _w8_expect_surface(background: String, ambience: String, weather: String, label: String) -> bool:
	if not _expect_surface(background, ambience, label):
		return false
	if str(_story.get_meta("living_scene_effect", "")) != weather:
		_fail("%s wrong W8 weather: expected %s" % [label, weather])
		return false
	return not ambience.is_empty() or _expect_no_ambience("W8 " + label)

func _expect_no_ambience(label: String) -> bool:
	for layer in [
		["_current_ambience_key", "_ambience_player"],
		["_current_human_ambience_key", "_human_ambience_player"],
		["_current_season_key", "_season_player"],
	]:
		var player := BGMPlayer.get(layer[1]) as AudioStreamPlayer
		if not str(BGMPlayer.get(layer[0])).is_empty() \
				or not is_instance_valid(player) or player.playing:
			_fail("%s retained ambience %s" % [label, layer[1]])
			return false
	return true

func _seed_story(event_id: String, turn: int) -> bool:
	GameState.start_new_game()
	GameState.turn = turn
	GameState.age = 33 if turn == 6 else 37
	GameState.month = 2 if turn == 6 else 7
	GameState.week_of_month = 2 if turn == 6 else 1
	GameState.housing = "oneroom"
	GameState.money = 2_800_000_000.0
	GameState.health = 80
	GameState.mental = 80
	GameState.current_job = {"id": "job_01"}
	GameState.flags = {"prologue_done": true}
	if event_id == W202_EVENT:
		GameState.flags["daeun_romance_started"] = true
	GameState.story_replay_mode = false
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	EventManager.current_event = {}
	if event_id != "arc_y5_burnout_check_reference":
		return true
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true,
		2_800_000_000.0)
	if not bool(locked.get("ok", false)):
		_fail("burnout prerequisite could not lock the causal route")
		return false
	var state: Dictionary = locked["state"]
	var target_index: int = CHAPTER5_ROUTE.OWNED_EVENT_IDS.find(event_id)
	for index in range(target_index):
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(
			state, CHAPTER5_ROUTE.OWNED_EVENT_IDS[index],
			BURNOUT_PRIOR_CHOICES[index], CHAPTER5_ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("burnout prerequisite failed at %s" % CHAPTER5_ROUTE.OWNED_EVENT_IDS[index])
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	GameState.turn = CHAPTER5_ROUTE.OWNED_TURNS[target_index]
	if GameState.chapter5_causal_next_event_for_turn() != event_id:
		_fail("burnout causal route did not admit the exact live root")
		return false
	return true

func _read_phase(expected_background: String, expected_ambience: String, result: bool) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	if pages.is_empty() or int(_story.get("_para_index")) != 0:
		_fail("phase did not start at decoded page zero")
		return false
	for page_index in range(pages.size()):
		if int(_story.get("_para_index")) != page_index \
				or bool(_story.get("_pending_after_result")) != result:
			_fail("normal advance skipped a page or crossed the phase boundary")
			return false
		await _finish_page()
		if not _expect_surface(expected_background, expected_ambience,
				("result" if result else "intro") + "-page%d" % page_index):
			return false
		if result:
			_result_pages += 1
		else:
			_intro_pages += 1
		if page_index + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	return true

func _expect_surface(raw_background: String, expected_ambience: String, label: String) -> bool:
	var resolved_background := ImageRegistry.resolve_contextual_background_id(raw_background)
	var expected_path := str(EXACT_PATHS.get(resolved_background, ""))
	var background := _story.get("_bg_img") as TextureRect
	var actual_path := "" if not is_instance_valid(background) \
			or background.texture == null else background.texture.resource_path
	var actual_id := str(_story.get("_event_background_id"))
	var actual_ambience := str(BGMPlayer.get("_current_ambience_key"))
	if expected_path.is_empty() or not FileAccess.file_exists(expected_path):
		_fail("%s expected authored asset is missing: %s" % [label, expected_path])
		return false
	if ImageRegistry.get_background(resolved_background) != expected_path:
		_fail("%s registry does not own exact path %s" % [label, expected_path])
		return false
	if actual_id != resolved_background or actual_path != expected_path:
		_fail("%s wrong settled background expected=%s/%s actual=%s/%s" % [
			label, resolved_background, expected_path, actual_id, actual_path])
		return false
	if actual_ambience != expected_ambience:
		_fail("%s wrong settled ambience expected=%s actual=%s" % [
			label, expected_ambience, actual_ambience])
		return false
	return true

func _finish_page() -> void:
	if bool(_story.get("_direction_beat_waiting")):
		_story.call("_on_advance")
	_story.call("_complete_typing")
	await _wait_stable()

func _wait_stable() -> void:
	for _frame in range(240):
		await get_tree().process_frame
		if not is_instance_valid(_story):
			return
		var raw_ink_tween: Variant = _story.get("_story_ink_transition_tween")
		var raw_text_tween: Variant = _story.get("_story_text_panel_tween")
		var ink_layer := _story.get("_story_ink_transition_layer") as Control
		var transition_busy := bool(_story.get("_story_scene_transition_active")) \
				or bool(_story.get("_direction_hold_active")) \
				or (raw_ink_tween is Tween and (raw_ink_tween as Tween).is_running()) \
				or (raw_text_tween is Tween and (raw_text_tween as Tween).is_running()) \
				or (is_instance_valid(ink_layer) and ink_layer.visible)
		if not transition_busy:
			await get_tree().process_frame
			return
		if not _w4_capture_dir.is_empty() or not _w8_capture_dir.is_empty() \
				or not _m14_capture_dir.is_empty() or not _w234_capture_dir.is_empty() \
				or not _offer_capture_dir.is_empty() or not _m23_capture_dir.is_empty() \
				or not _first_ktx_capture_dir.is_empty() or not _w96_capture_dir.is_empty() \
				or not _w112_capture_dir.is_empty() or not _w117_capture_dir.is_empty():
			continue
		if raw_ink_tween is Tween and (raw_ink_tween as Tween).is_running():
			(raw_ink_tween as Tween).custom_step(10.0)
		if raw_text_tween is Tween and (raw_text_tween as Tween).is_running():
			(raw_text_tween as Tween).custom_step(10.0)
	_fail("StoryMode surface never settled")

func _diagnostic() -> Dictionary:
	var data := {"context": _context, "language": LocaleManager.language}
	if not is_instance_valid(_story):
		return data
	var background := _story.get("_bg_img") as TextureRect
	data.merge({
		"event": str((_story.get("_current") as Dictionary).get("id", "")),
		"phase": _story.call("_story_resume_phase"),
		"page": int(_story.get("_para_index")),
		"background_id": str(_story.get("_event_background_id")),
		"background_path": "" if not is_instance_valid(background) \
				or background.texture == null else background.texture.resource_path,
		"ambience": str(BGMPlayer.get("_current_ambience_key")),
	})
	return data

func _fail(message: String) -> void:
	_failures += 1
	print("STORY_BACKGROUND_CONTEXT_CHECK_FAIL %s %s" % [
		message, JSON.stringify(_diagnostic())])

func _remove_story() -> void:
	if is_instance_valid(_story):
		_story.queue_free()
		await get_tree().process_frame
		await get_tree().process_frame
	_story = null
	GameState.pending_story_queue.clear()
	EventManager.current_event = {}

func _stop_audio() -> void:
	await AudioManager.drain_pending_timers_for_exit()
	BGMPlayer.stop()
	for owner in [AudioManager, BGMPlayer]:
		for child in owner.get_children():
			if child is AudioStreamPlayer:
				(child as AudioStreamPlayer).stop()
				(child as AudioStreamPlayer).stream = null
	for _frame in range(4):
		await get_tree().process_frame
