extends Node
## L2 only: exercise the real StoryMode node for exact authored
## location moves. This is deterministic regression evidence, never a
## substitute for the required normal-speed human M49-M60 replays.

const QA_PREFIX := "GangnamDream_StoryNameplateQA_"
const CHAPTER5_ROUTE := preload("res://systems/Chapter5CausalRoute.gd")
const CHAPTER5_FINALE_ROUTE := preload("res://systems/Chapter5FinaleRoute.gd")
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
const W126_RIVER := "arc_goal_vertigo"
const W205_PHONE := "arc_minseo_03b_not_arrived"
const W161_BODY := "arc_36_body_signal"
const W161_STOPPED := "seoul_subway_stopped_w161"
const W161_PLATFORM := "seoul_subway_platform_bench_w161"
const W161_CASHIER := "hospital_outpatient_cashier_w161"
const W161_BAEKBAN_MEAL := "baekban_closing_meal_w161"
const W161_BAEKBAN_EMPTY := "baekban_closing_empty_w161"
const W161_STATION_SHOP := "seoul_station_convenience_w161"
const W164_DAEUN := "arc_y4_body_witness"
const W164_UNATTACHED := "arc_y4_body_witness_hyunsu"
const W164_INTAKE := "hospital_night_intake_w164"
const W164_START := {"ko": "접수대에서", "en": "At intake,", "ja": "受付で",
	"zh-CN": "在挂号台，", "zh-TW": "在掛號櫃檯，"}
const W167_DAEUN := "arc_y4_family_partner_collision"
const W167_UNATTACHED := "arc_y4_family_commitment_none"
const W167_LATE := "arc_y4_family_table_missed"
const W167_RESTAURANT := "family_soup_restaurant_w167"
const W167_CUT_STARTS := {
	"daeun": {
		"ko": "여섯 시 이 분,", "en": "At 6:02,", "ja": "六時二分、",
		"zh-CN": "六点零二分，", "zh-TW": "六點兩分，",
	},
	"late": {
		"ko": "일곱 시 오십칠 분,", "en": "At 7:57,", "ja": "七時五十七分、",
		"zh-CN": "七点五十七分，", "zh-TW": "七點五十七分，",
	},
	"rebook": {
		"ko": "가족이 그 시각을 받아들인 답을 확인한 뒤 다섯 시 현장으로 이동했다.",
		"en": "After the family member confirmed the time, he traveled to the five o'clock site.",
		"ja": "家族がその時刻を受け入れた返事を確かめてから、五時の現場へ向かった。",
		"zh-CN": "确认家人回复接受那个时间后，前往五点开始的现场工作。",
		"zh-TW": "確認家人回覆接受那個時間後，前往五點的現場工作。",
	},
	"cancel": {
		"ko": "다섯 시 정각, 현장 출입기에", "en": "At five, his name entered the site log.",
		"ja": "五時ちょうど、現場の入退場端末に", "zh-CN": "五点整，在现场门禁机上",
		"zh-TW": "五點整，在現場出入機上",
	},
}
const W169_MIDPOINT := "arc_year_three_half"
const W169_VARIANT_MARKERS := {
	"default": {
		"ko": "방의 불을 하나만 남기고", "en": "left a single light on",
		"ja": "部屋の明かりを一つだけ残し", "zh-CN": "只留一盏灯", "zh-TW": "只留一盞燈",
	},
	"degraded": {
		"ko": "세 기록의 제목만 겨우 알아봤다", "en": "could barely make out the headings",
		"ja": "三つの記録の見出しだけを、やっと読み取れた",
		"zh-CN": "只勉强认出了三份记录的标题", "zh-TW": "只勉強認出了三份紀錄的標題",
	},
	"complete": {
		"ko": "네 시 아버지 통화를 지켰다",
		"en": "kept the four o'clock call with his father",
		"ja": "四時の父との通話を守った", "zh-CN": "守住了四点与父亲通话的约定",
		"zh-TW": "守住了四點和父親通話的約定",
	},
}
const W174_ROOT := "arc_father_call_on_ktx"
const W174_MEMORY := "arc_father_call_on_ktx_memory"
const W174_NUMBER := "arc_father_call_on_ktx_number"
const W174_ANSWERED := "arc_y4_father_call_answered_on_ktx"
const W174_MISSED := "arc_y4_father_call_missed_on_ktx"
const W174_KTX := "ktx_window"
const W174_KTX_PATH := "res://assets/backgrounds/regional_train_window_summer.png"
const W174_PANE_PATH := "res://assets/backgrounds/ktx_tunnel_window_overlay_w174.svg"
const W174_SOURCE_COUNTS := {
	W174_ROOT: 4,
	W174_MEMORY: 5,
	W174_NUMBER: 3,
	W174_ANSWERED: 4,
	W174_MISSED: 3,
}
const W174_RESULT_COUNTS := {
	W174_ROOT: [2, 2],
	W174_MEMORY: [2],
	W174_NUMBER: [4, 2],
	W174_ANSWERED: [3, 3, 3],
	W174_MISSED: [2, 2, 2],
}
const W177_DAEUN := "arc_y4_borrowed_name"
const W177_SELF := "arc_y4_borrowed_name_self"
const W177_DOCUMENT_GAP := "arc_y4_borrowed_name_document_gap"
const W177_CORRIDOR := "withdrawal_corridor_w177"
const W177_CORRIDOR_PATH := "res://assets/backgrounds/withdrawal_corridor_w177_v1.png"
const W177_CORRIDOR_START := {
	"ko": "복도 불빛 아래에는", "en": "Beneath the corridor light,",
	"ja": "廊下の明かりの下には", "zh-CN": "走廊灯下，", "zh-TW": "走廊燈光下，",
}
const W181_DAEUN := "arc_y4_bill_night"
const W181_UNATTACHED := "arc_y4_bill_night_unattached"
const W181_INTAKE := "hospital_night_intake_w164"
const W181_INTAKE_PATH := "res://assets/backgrounds/hospital_night_intake_w164_v1.png"
const W181_CUT_STARTS := {
	W181_DAEUN: {
		"ko": "11시 59분, 접수대에서", "en": "At 11:59, he told them himself",
		"ja": "11時59分、受付で", "zh-CN": "11点59分，在挂号台",
		"zh-TW": "11點59分，在掛號櫃檯",
	},
	W181_UNATTACHED: {
		"ko": "신분증을 내고", "en": "He presented identification",
		"ja": "身分証を出し、", "zh-CN": "递出身份证件，",
		"zh-TW": "遞出身分證件，",
	},
}
const W181_MEMORY_FLAGS := [
	"arc_y4_borrowed_name_reduced_to_self",
	"arc_y4_borrowed_name_partner_review_only",
	"arc_y4_borrowed_name_withdrew_request",
	"arc_y4_borrowed_name_own_name_counteroffer",
	"arc_y4_borrowed_name_requested_complete_terms",
]
const W185_CONTACT := "arc_y4_father_crisis_contact"
const W185_DEPARTURE_CUT := preload("res://assets/w185_father_departure_cut.tres")
const W185_BILL_FLAGS := [
	"arc_y4_bill_chose_payment",
	"arc_y4_bill_chose_body_care",
	"arc_y4_bill_chose_father_care",
]
const W185_CALL_FLAGS := ["called_father_on_ktx", "did_not_call_father_on_ktx"]
const W185_OUTCOME_FLAGS := [
	"father_crisis_contact_present",
	"father_crisis_contact_called",
	"father_crisis_contact_missed",
]
const W185_FOLLOW_UPS := [
	"arc_y4_father_final_contact_present",
	"arc_y4_father_final_contact_called",
	"arc_y4_father_final_contact_missed",
]
const W188_ROOT := "arc_father_passing"
const W188_PLATFORM := "arc_father_passing_platform"
const W188_DEAL := "arc_father_passing_deal_room"
const W188_PLATFORM_BG := "seoul_station_ktx_platform_winter"
const W188_ONBOARD_BG := "ktx_changwon_winter_night_w188"
const W188_FOLLOW_UPS := [
	"arc_father_passing_hospital_room",
	"arc_father_passing_deal_morning",
]
const W192_ROOT := "arc_year4_close"
const W192_DEAD := "arc_year4_close_father_passed"
const W192_BG := "year4_winter_rooftop"
const W192_INSIDE := "year4_rooftop_door_inside_w192"
const W192_WIND_CUT := preload("res://assets/w192_year4_close_wind_cut.tres")
const W196_DELIVERY := "arc_y5_contract_reviewer_delivery_sangchul"
const W196_VIBRATE_CUT := preload("res://assets/w196_friday_notice_cut.tres")
const W196_TRACKED_SFX := ["phone_vibrate", "phone_notification", "paper_handle", "page_turn"]
const W197_PUSH := "arc_y5_final_push_deadline_investment"
const W197_FOLDER_STARTS := {
	"ko": "{name}은 R3 원문이 든 투명 폴더를 키보드 옆에 놓고",
	"en": "{name} set the clear folder holding R3 beside the keyboard",
	"ja": "{name}はR3の原文が入った透明フォルダーをキーボードの横に置き、",
	"zh-CN": "{name}把装有R3原文的透明文件夹放在键盘旁，",
	"zh-TW": "{name}把裝有 R3 原文的透明資料夾放在鍵盤旁，",
}
const W200_BOUNDARY := "arc_y5_protection_boundary_daeun"
const W200_PENCIL_CUT := preload("res://assets/w200_daeun_pencil_cut.tres")
const W200_TRACKED_SFX := ["pen_write", "cup_set", "paper_handle", "page_turn"]
const W207_OFFER := "arc_y5_final_offer"
const W207_PAGE_TURN := preload("res://assets/w207_daeun_page_turn.tres")
const W207_TRACKED_SFX := ["page_turn", "cup_set", "paper_handle"]
const W208_DELIVERY := "arc_y5_final_offer_reference_delivery"
const W208_DOCUMENT_SCAN := preload("res://assets/w208_document_scan.tres")
const W208_TRACKED_SFX := ["document_scan", "register_scan", "page_turn", "paper_handle"]
const W215_OLD_OFFICE := "arc_sangchul_final_door"
const W216_REVIEW := "arc_y5_sangchul_review_receipt"
const W216_LANDING := "sangchul_old_office_landing_w216"
const W219_MEETING_DECISION := "arc_y5_three_in_room_decision"
const W220_CONSENT_RECEIPT := "arc_y5_room_consent_receipt"
const W227_FILING := "arc_y5_name_on_line_daeun_routed"
const W227_BACKGROUND := "finale_intake_blue_pen"
const W227_BALLPOINT_WRITE := preload("res://assets/w227_ballpoint_write.tres")
const W227_TRACKED_SFX := [
	"pen_ballpoint", "paper_handle", "pen_write", "document_scan", "register_scan",
]
const W230_CAFE := "arc_y5_people_verdict_daeun_exact"
const W230_BACKGROUND := "finale_cafe_rear_papers"
const W235_NOTICE := "arc_y5_property_not_executed_notice"
const W235_NOTICE_DESK := "finale_notice_desk"
const W235_NOTICE_RETURN := preload("res://assets/w235_notice_return.tres")
const W237_RECORD := "arc_y5_general_final_record_seal"
const W237_RECORD_PAGE_TURN := preload("res://assets/w237_record_page_turn.tres")
const W237_TRACKED_SFX := [
	"phone_vibrate", "page_turn", "paper_handle", "pen_ballpoint", "pen_write",
	"document_scan", "register_scan",
]
const W238_REMAINING := "arc_y5_remaining_jaehyuk_or_self"
const W238_TRACKED_SFX := [
	"phone_notification", "phone_vibrate", "page_turn", "paper_handle",
	"pen_ballpoint", "pen_write", "document_scan", "register_scan",
	"cup_set", "traffic_pass", "door_latch",
]
const W239_FATHER_ALIVE := "arc_y5_final_father_answer_alive"
const W239_ALIVE_NAME_WRITE := preload("res://assets/w239_alive_name_write.tres")
const W239_FATHER_PASSED := "arc_y5_final_father_answer_passed"
const W239_PASSED_PAPER_ACTIONS := preload("res://assets/w239_passed_paper_actions.tres")
const W240_GENERAL_SACRIFICE := "arc_final_countdown_general_near_goal_passed"
const W240_GENERAL_SACRIFICE_WRITE := preload(
	"res://assets/w240_general_sacrifice_write.tres")
const W239_TRACKED_SFX := [
	"phone_notification", "phone_vibrate", "page_turn", "paper_handle",
	"pen_ballpoint", "pen_write", "document_scan", "register_scan",
	"cup_set", "traffic_pass", "door_latch",
]
const W235_HOME_CASES: Array[Dictionary] = [
	{"id": "gosiwon", "housing": "gosiwon", "background": "goshiwon_room"},
	{"id": "oneroom", "housing": "oneroom", "background": "apartment"},
	{"id": "villa", "housing": "villa", "background": "apartment"},
	{"id": "apartment", "housing": "apartment", "background": "gangnam_apartment"},
	{"id": "gangnam", "housing": "gangnam", "background": "gangnam_apartment"},
	{"id": "daeun_shared", "housing": "gosiwon", "background": "daeun_newlywed_home",
		"flags": {"arc_daeun_wedding_day_seen": true}},
	{"id": "divorced_villa", "housing": "villa", "background": "apartment",
		"flags": {"arc_daeun_wedding_day_seen": true, "daeun_divorced": true}},
]
const W132_REPORT := "arc_sangchul_reckoning"
const W132_CAFE_ROOT := "arc_sangchul_stairwell"
const W132_STAIRS := "sangchul_cafe_stairs"
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
	W216_LANDING: "res://assets/backgrounds/sangchul_old_office_landing_w216_v1.png",
	W227_BACKGROUND: "res://assets/backgrounds/finale_intake_blue_pen_v1.png",
	W230_BACKGROUND: "res://assets/backgrounds/finale_cafe_rear_papers_v1.png",
	W235_NOTICE_DESK: "res://assets/backgrounds/finale_notice_desk_v1.png",
	"daeun_newlywed_home": "res://assets/backgrounds/daeun_newlywed_home_night.png",
	"office": "res://assets/backgrounds/office_desk.png",
	W132_STAIRS: "res://assets/backgrounds/sangchul_cafe_stairs_v2.png",
	"hangang_riverside": "res://assets/backgrounds/hangang_riverside_walk.png",
	W82_TERMINAL: "res://assets/backgrounds/seoul_bus_terminal_night.png",
	W82_DEPARTURE: "res://assets/backgrounds/seoul_bus_terminal_departure_v1.png",
	W69_INSIDE: "res://assets/backgrounds/convenience_store_night_dry_v1.png",
	W69_STEPS: "res://assets/backgrounds/convenience_store_night_steps_v1.png",
	W57_PASSAGE: "res://assets/backgrounds/seoul_subway_transfer_passage_v1.png",
	W57_CAR: "res://assets/backgrounds/seoul_subway_commuters_w57_v1.png",
	W161_STOPPED: "res://assets/backgrounds/seoul_subway_stopped_w161_v1.png",
	W161_PLATFORM: "res://assets/backgrounds/seoul_subway_platform_bench_w161_v1.png",
	W161_CASHIER: "res://assets/backgrounds/hospital_outpatient_cashier_w161_v1.png",
	W161_BAEKBAN_MEAL: "res://assets/backgrounds/baekban_closing_meal_w161_v1.png",
	W161_BAEKBAN_EMPTY: "res://assets/backgrounds/baekban_closing_empty_w161_v1.png",
	W161_STATION_SHOP: "res://assets/backgrounds/seoul_station_convenience_w161_v1.png",
	W164_INTAKE: "res://assets/backgrounds/hospital_night_intake_w164_v1.png",
	W167_RESTAURANT: "res://assets/backgrounds/family_soup_restaurant_w167_v1.png",
	W177_CORRIDOR: W177_CORRIDOR_PATH,
	W188_PLATFORM_BG: "res://assets/backgrounds/seoul_station_ktx_platform_winter.png",
	W188_ONBOARD_BG: "res://assets/backgrounds/ktx_changwon_winter_night_w188_v1.png",
	W192_BG: "res://assets/backgrounds/year4_winter_rooftop.png",
	W192_INSIDE: "res://assets/backgrounds/year4_rooftop_door_inside_w192_v1.png",
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
var _w216_cold_restored := false
var _w216_cold_count := 0
var _w220_receipt_cold_count := 0
var _w220_receipt_paper_expected := false
var _w230_cold_ink := 0
var _w230_cross_future_ink := 0
var _w230_reflow_ink := 0
var _w235_cold_paper := 0
var _w235_future_paper := 0
var _w235_reflow_paper := 0
var _w237_cold_pages := 0
var _w237_future_pages := 0
var _w237_reflow_pages := 0
var _w239_cold_ink := 0
var _w239_reflow_ink := 0
var _w239_passed_cold_paper := 0
var _w239_passed_reflow_paper := 0
var _w240_cold_ink := 0
var _w240_reflow_ink := 0

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
	if OS.has_environment("GANGNAM_W240_GENERAL_SIGNATURE_CHECK"):
		var w240_ok: bool = await _check_w240_general_signature()
		await _remove_story()
		await _stop_audio()
		if w240_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w240_general_signature")
		get_tree().quit(0 if w240_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W239_FATHER_PASSED_CHECK"):
		var w239_passed_ok: bool = await _check_w239_father_passed()
		await _remove_story()
		await _stop_audio()
		if w239_passed_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w239_father_passed")
		get_tree().quit(0 if w239_passed_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W239_FATHER_ALIVE_CHECK"):
		var w239_ok: bool = await _check_w239_father_alive()
		await _remove_story()
		await _stop_audio()
		if w239_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w239_father_alive")
		get_tree().quit(0 if w239_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W238_REMAINING_CHECK"):
		var w238_ok: bool = await _check_w238_remaining()
		await _remove_story()
		await _stop_audio()
		if w238_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w238_remaining")
		get_tree().quit(0 if w238_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W237_PAGE_TURN_CHECK"):
		var w237_ok: bool = await _check_w237_record_page_turn()
		await _remove_story()
		await _stop_audio()
		if w237_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w237_page_turn")
		get_tree().quit(0 if w237_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W235_PAPER_RETURN_CHECK"):
		var w235_ok: bool = await _check_w235_notice_return()
		await _remove_story()
		await _stop_audio()
		if w235_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w235_paper_return")
		get_tree().quit(0 if w235_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W230_BALLPOINT_CHECK"):
		var w230_ok: bool = await _check_w230_cafe_write()
		await _remove_story()
		await _stop_audio()
		if w230_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w230_ballpoint")
		get_tree().quit(0 if w230_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W227_BALLPOINT_CHECK"):
		var ballpoint_ok: bool = await _check_w227_ballpoint()
		await _remove_story()
		await _stop_audio()
		if ballpoint_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w227_ballpoint")
		get_tree().quit(0 if ballpoint_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W220_RECEIPT_CHECK"):
		var receipt_ok: bool = await _check_w220_receipt()
		await _remove_story()
		await _stop_audio()
		if receipt_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w220_receipt")
		get_tree().quit(0 if receipt_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W216_LANDING_CHECK"):
		var landing_ok := await _check_w216_landing()
		await _remove_story()
		await _stop_audio()
		if landing_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w216_landing")
		get_tree().quit(0 if landing_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W208_SCAN_CHECK"):
		var scan_ok := await _check_w208_document_scan()
		await _remove_story()
		await _stop_audio()
		if scan_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w208_document_scan")
		get_tree().quit(0 if scan_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W207_PAGE_TURN_CHECK"):
		var offer_ok := await _check_w207_page_turn()
		await _remove_story()
		await _stop_audio()
		if offer_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w207_page_turn")
		get_tree().quit(0 if offer_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W200_PENCIL_CHECK"):
		var pencil_ok := await _check_w200_pencil_audio()
		await _remove_story()
		await _stop_audio()
		if pencil_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w200_pencil_audio")
		get_tree().quit(0 if pencil_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W196_CHECK"):
		var friday_ok := await _check_w196_friday_vibration()
		await _remove_story()
		await _stop_audio()
		if friday_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w196_friday_vibration")
		get_tree().quit(0 if friday_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W197_CHECK"):
		var folder_ok := await _check_w197_folder_audio()
		await _remove_story()
		await _stop_audio()
		if folder_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w197_folder_audio")
		get_tree().quit(0 if folder_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W192_CHECK"):
		var year_close_ok := await _check_w192_year_close_wind()
		await _remove_story()
		await _stop_audio()
		if year_close_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w192_year_close_wind")
		get_tree().quit(0 if year_close_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W188_CHECK"):
		var platform_ok := await _check_w188_platform_silence()
		var deal_ok := false
		if platform_ok:
			deal_ok = await _check_w188_deal_boarding()
		await _remove_story()
		await _stop_audio()
		if platform_ok and deal_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w188_father_passing_boarding")
		get_tree().quit(0 if platform_ok and deal_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W185_CHECK"):
		var departure_ok := await _check_w185_father_departure()
		await _remove_story()
		await _stop_audio()
		if departure_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w185_father_departure")
		get_tree().quit(0 if departure_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W181_CHECK"):
		var bill_ok := await _check_w181_bill_night()
		await _remove_story()
		await _stop_audio()
		if bill_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w181_bill_night")
		get_tree().quit(0 if bill_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W177_CHECK"):
		var withdrawal_ok := await _check_w177_withdrawal()
		await _remove_story()
		await _stop_audio()
		if withdrawal_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w177_withdrawal")
		get_tree().quit(0 if withdrawal_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W174_CHECK"):
		var father_call_ok := await _check_w174_father_call()
		await _remove_story()
		await _stop_audio()
		if father_call_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w174_father_call")
		get_tree().quit(0 if father_call_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W169_CHECK"):
		var midpoint_ok := await _check_w169_midpoint()
		await _remove_story()
		await _stop_audio()
		if midpoint_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w169_midpoint")
		get_tree().quit(0 if midpoint_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W167_CHECK"):
		var table_ok := await _check_w167_family_table()
		await _remove_story()
		await _stop_audio()
		if table_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w167_family_table")
		get_tree().quit(0 if table_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W164_CHECK"):
		var intake_ok := await _check_w164_intake()
		await _remove_story()
		await _stop_audio()
		if intake_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w164_intake")
		get_tree().quit(0 if intake_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W161_CHECK"):
		var body_ok := await _check_w161_body()
		await _remove_story()
		await _stop_audio()
		if body_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w161_body")
		get_tree().quit(0 if body_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W132_CHECK"):
		var stairs_ok := await _check_w132_stairs()
		await _remove_story()
		await _stop_audio()
		if stairs_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w132_stairs")
		get_tree().quit(0 if stairs_ok and _failures == 0 else 1)
		return
	if OS.has_environment("GANGNAM_W126_W205_CHECK"):
		var later_ok := await _check_w126_w205()
		await _remove_story()
		await _stop_audio()
		if later_ok and _failures == 0:
			print("STORY_BACKGROUND_CONTEXT_CHECK_OK scope=w126_w205")
		get_tree().quit(0 if later_ok and _failures == 0 else 1)
		return
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
	if not await _check_w126_w205(true):
		_fail("W126/W205 location regression smoke failed")
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

func _check_w126_w205(smoke: bool = false) -> bool:
	var paths := 0
	var restores := 0
	var cafe_handoffs := 0
	var capture := OS.get_environment("GANGNAM_W126_W205_CAPTURE_DIR")
	if not capture.is_empty():
		var out := DirAccess.open(capture) if capture.is_absolute_path() else null
		if DisplayServer.get_name() == "headless" or out == null or not out.get_files().is_empty():
			_fail("W126/W205 captures require a native display and a fresh directory")
			return false
	var languages: Array = ["ko"] if smoke else LocaleManager.SUPPORTED_LANGUAGES
	for language: String in languages:
		for event: String in [W126_RIVER, W205_PHONE]:
			var river := event == W126_RIVER
			var variants: Array = [[]] if smoke or river else [[], ["contacted_minseo"], ["minseo_real_talk"],
				["contacted_minseo", "minseo_real_talk"], ["thought_about_after"]]
			for flags: Array in variants:
				var choices: Array = ([2] if smoke else [0, 1, 2]) if river else ([0] if smoke else [0, 1])
				for choice: int in choices:
					await _remove_story()
					await _stop_audio()
					_context = "%s/%s/%s/c%d" % [language, event, flags, choice]
					LocaleManager.set_language(language)
					SaveManager.clear_loaded_resume_context()
					GameState.start_new_game()
					GameState.turn = 126 if river else 205
					GameState.age = 35 if river else 37
					GameState.month = 8 if river else 4
					GameState.housing = "oneroom"
					GameState.mental = 60
					GameState.health = 60
					for flag: String in flags:
						GameState.flags[flag] = true
					GameState.story_return_scene = "res://scenes/MainGame.tscn"
					var cafe_handoff := not river and flags.is_empty() and choice == 0
					GameState.pending_story_queue = ["arc_minseo_02_real", event] if cafe_handoff else [event]
					BGMPlayer.set_ambience("cafe")
					_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
					add_child(_story)
					_story.call("_set_auto_mode", false, false, false)
					var home := ImageRegistry.resolve_contextual_background_id("current_housing")
					if cafe_handoff:
						if str((_story.get("_current") as Dictionary).get("id", "")) != "arc_minseo_02_real" \
								or str(_story.get("_event_background_id")) != "cafe" \
								or (_story.get("_bg_img") as TextureRect).texture == null:
							_fail("W205 handoff fixture did not start in the café")
							return false
						_story.call("_load_next_event")
						if str((_story.get("_current") as Dictionary).get("id", "")) != event \
								or not _expect_w126_w205_surface(false, home, false, false):
							return false
						cafe_handoffs += 1
					var cases: Array = _story.get("_paragraphs")
					for page in range(cases.size()):
						await _finish_page()
						if not _expect_w126_w205_surface(river, home, false, false):
							return false
						if page == 1 and flags.is_empty() and choice == (2 if river else 0) and not capture.is_empty():
							await get_tree().create_timer(0.5).timeout
							if not await _save_viewport_frame(capture.path_join("%s_%s_intro.png" % [language, event])):
								return false
						_story.call("_on_advance")
						await _wait_stable()
					if not bool(_story.get("_showing_choices")) or not _expect_w126_w205_surface(river, home, false, false):
						return false
					var count: int = GameState.events_seen
					var money: float = GameState.money
					_story.call("_on_choice", choice)
					await _wait_stable()
					var pages: Array = _story.get("_paragraphs")
					var source_count := 3 if river else 2
					if not bool(_story.get("_pending_after_result")) or int(_story.call("_story_source_paragraph_count")) != source_count:
						return false
					for page in range(pages.size()):
						await _finish_page()
						var source := int(_story.call("_story_source_paragraph_index", page))
						var outside := river and choice == 2
						var ended := not river and choice == 0 and source == 1
						if not _expect_w126_w205_surface(river, home, outside, ended):
							return false
						if not capture.is_empty() and flags.is_empty() and choice == (2 if river else 0) \
								and (page == 0 or source == source_count - 1):
							await get_tree().create_timer(0.5).timeout
							if not await _save_viewport_frame(capture.path_join("%s_%s_result_%d.png" % [language, event, page])):
								return false
						if page + 1 < pages.size():
							_story.call("_on_advance")
							await _wait_stable()
					if not smoke:
						var result: Dictionary = _story.call("build_save_resume_context")
						if not await _reload_authored_result_context(result, language, source_count, source_count - 1) \
								or not _expect_w126_w205_surface(river, home, river and choice == 2, not river and choice == 0):
							return false
						restores += 1
					var mental: int = [55, 68, 69][choice] if river else [64, 57][choice]
					if GameState.events_seen != count + 1 or GameState.money != money or GameState.mental != mental \
							or not GameState.flags.get("arc_goal_vertigo_seen" if river else "arc_minseo_03_seen", false):
						_fail("W126/W205 changed the authored result")
						return false
					if river:
						var queued := GameState.deferred_events.filter(func(row: Dictionary) -> bool:
							return row.get("event_id") == "arc_35_path_cost" and int(row.get("trigger_turn", -1)) == 148)
						if queued.size() != 1:
							_fail("W126 did not preserve its 22-week follow-up")
							return false
					paths += 1
	if not smoke:
		print("W126_W205_OK paths=%d v4=%d cafe_handoffs=%d" % [paths, restores, cafe_handoffs])
	return paths == (2 if smoke else 65) and restores == (0 if smoke else 65) \
		and cafe_handoffs == (1 if smoke else 5)

func _check_w164_intake() -> bool:
	var paths := 0
	var restores := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for is_daeun: bool in [false, true]:
			for choice: int in range(3):
				await _remove_story()
				await _stop_audio()
				_context = "%s/W164/daeun=%s/c%d" % [language, str(is_daeun), choice]
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 164
				GameState.month = 5
				GameState.age = 36
				GameState.housing = "oneroom"
				GameState.flags["arc_36_body_signal_seen"] = true
				if is_daeun:
					GameState.flags["daeun_romance_started"] = true
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var selected := str(ingress.call("_chapter_four_causal_arc_id", 164, GameState.flags, false))
				ingress.free()
				if selected != (W164_DAEUN if is_daeun else W164_UNATTACHED):
					_fail("W164 release ingress resolved the wrong witness")
					return false
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [selected]
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				var home := ImageRegistry.resolve_contextual_background_id("current_housing")
				for _page in range((_story.get("_paragraphs") as Array).size()):
					await _finish_page()
					if not _expect_surface(home, "oneroom", "W164 before choice"):
						return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")):
					return false
				var cash: float = GameState.money
				var events := GameState.events_seen
				_story.call("_on_choice", choice)
				await _wait_stable()
				var pages: Array = _story.get("_paragraphs")
				var cut := int(_story.get("_result_location_cut_page"))
				var care := is_daeun and choice == 0
				if int(_story.call("_story_source_paragraph_count")) != 2 or (cut > 0) != care \
						or (care and (cut >= pages.size() or not str(pages[cut]).begins_with(W164_START[language]))):
					_fail("W164 did not cut at the night intake words in the original source")
					return false
				for page in range(pages.size()):
					await _finish_page()
					var at_intake := care and page >= cut
					if not _expect_w164_intake(home, at_intake):
						return false
					if care and page in [cut - 1, cut, pages.size() - 1]:
						var source := int(_story.call("_story_source_paragraph_index", page))
						var context: Dictionary = _story.call("build_save_resume_context")
						if not await _reload_authored_result_context(context, language, 2, source, true) \
								or not _expect_w164_intake(home, at_intake) or int(_story.get("_para_index")) != page:
							_fail("W164 cold slot did not immediately recover the side of the cut")
							return false
						await _finish_page()
						restores += 1
					if page + 1 < pages.size():
						_story.call("_on_advance")
						await _wait_stable()
				var expected_flag: String = ["arc_y4_body_chose_care", "arc_y4_body_chose_deadline", "arc_y4_body_chose_alone"][choice]
				if GameState.money != cash or GameState.events_seen != events + 1 \
						or not GameState.flags.get("arc_y4_body_witness_seen", false) \
						or not GameState.flags.get(expected_flag, false):
					_fail("W164 cut altered or replayed the chosen result")
					return false
				paths += 1
	print("W164_INTAKE_OK paths=%d same_locale_v4=%d" % [paths, restores])
	return paths == 30 and restores == 15

func _expect_w164_intake(home: String, at_intake: bool) -> bool:
	if not _expect_surface(W164_INTAKE if at_intake else home, "hospital" if at_intake else "oneroom", "W164"):
		return false
	if at_intake and (not BGMPlayer._ambience_player.playing or BGMPlayer._human_ambience_player.playing \
			or BGMPlayer._season_player.playing):
		_fail("W164 night intake inherited people, weather or lost the hospital room tone")
		return false
	return true

func _check_w167_family_table() -> bool:
	var paths := 0
	var restores := 0
	var cut_restores := 0
	var variants := [
		{"id": W167_DAEUN, "intro": "neutral", "intro_sources": 2,
			"flags": ["daeun_romance_started"]},
		{"id": W167_UNATTACHED, "intro": "home", "intro_sources": 2,
			"flags": []},
		{"id": W167_LATE, "intro": "home", "intro_sources": 3,
			"flags": ["arc_y4_three_promises_missed_father"]},
	]
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for raw_variant: Dictionary in variants:
			for choice: int in range(3):
				await _remove_story()
				await _stop_audio()
				var event_id: String = str(raw_variant["id"])
				_context = "%s/W167/%s/c%d" % [language, event_id, choice]
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 167
				GameState.month = 6
				GameState.age = 36
				GameState.housing = "oneroom"
				GameState.flags["arc_y4_body_witness_seen"] = true
				for flag: String in raw_variant["flags"]:
					GameState.flags[flag] = true
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var selected: String = str(ingress.call("_chapter_four_causal_arc_id", 167, GameState.flags, false))
				ingress.free()
				if selected != event_id:
					_fail("W167 release ingress resolved the wrong family-table variant")
					return false
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [event_id]
				# Begin with a busy public bed plus weather. Every W167 surface must
				# replace it with its authored apartment bed or intentional silence.
				BGMPlayer.set_ambience("cafe")
				BGMPlayer.set_season_ambience("rain")
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				if str((_story.get("_current") as Dictionary).get("id", "")) != event_id \
						or int(_story.call("_story_source_paragraph_count")) != int(raw_variant["intro_sources"]):
					_fail("W167 did not open the selected localized family-table source")
					return false
				var home: String = ImageRegistry.resolve_contextual_background_id("current_housing")
				var intro_pages: Array = _story.get("_paragraphs")
				for page in range(intro_pages.size()):
					await _finish_page()
					if not _expect_w167_surface(str(raw_variant["intro"]), home, "W167 intro"):
						return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")):
					_fail("W167 did not reach its three authored choices")
					return false
				var money: float = GameState.money
				var health: float = float(GameState.health)
				var mental: float = float(GameState.mental)
				var events: int = GameState.events_seen
				_story.call("_on_choice", choice)
				await _wait_stable()
				var pages: Array = _story.get("_paragraphs")
				var cut: int = int(_story.get("_result_location_cut_page"))
				var cut_key: String = _w167_cut_key(event_id, choice)
				if int(_story.call("_story_source_paragraph_count")) != 2 \
						or (cut >= 0) != not cut_key.is_empty():
					_fail("W167 result lost its exact two-source cut contract")
					return false
				if not cut_key.is_empty():
					var starts: Dictionary = W167_CUT_STARTS[cut_key]
					if cut <= 0 or cut >= pages.size() \
							or not str(pages[cut]).begins_with(str(starts[language])):
						_fail("W167 localized move did not start at its exact authored sentence")
						return false
				var restore_page: int = _w167_restore_page(event_id, choice, pages, cut)
				if restore_page < 0 or restore_page >= pages.size():
					_fail("W167 did not expose a deterministic v4 restore page")
					return false
				for page in range(pages.size()):
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					var surface: String = _w167_result_surface(event_id, choice, page, source, cut)
					if not _expect_w167_surface(surface, home, "W167 result"):
						return false
					if page == restore_page:
						var context: Dictionary = _story.call("build_save_resume_context")
						if not await _reload_authored_result_context(context, language, 2, source, true) \
								or int(_story.get("_para_index")) != page \
								or int(_story.get("_result_location_cut_page")) != cut \
								or not _expect_w167_surface(surface, home, "W167 restored result"):
							_fail("W167 same-locale v4 load did not recover its exact surface")
							return false
						await _finish_page()
						restores += 1
						if cut >= 0:
							cut_restores += 1
					if page + 1 < pages.size():
						_story.call("_on_advance")
						await _wait_stable()
				if GameState.money != money or GameState.health != health or GameState.mental != mental \
						or GameState.events_seen != events + 1 \
						or not _w167_outcome_flags_match(event_id, choice):
					_fail("W167 surface cut changed or replayed the authored outcome")
					return false
				paths += 1
	print("W167_FAMILY_TABLE_OK paths=%d v4=%d cut_v4=%d" % [paths, restores, cut_restores])
	return paths == 45 and restores == 45 and cut_restores == 20

func _w167_cut_key(event_id: String, choice: int) -> String:
	if event_id == W167_DAEUN and choice == 0:
		return "daeun"
	if event_id == W167_LATE and choice == 0:
		return "late"
	if event_id == W167_UNATTACHED and choice == 1:
		return "rebook"
	if event_id == W167_UNATTACHED and choice == 2:
		return "cancel"
	return ""

func _w167_restore_page(event_id: String, choice: int, pages: Array, cut: int) -> int:
	if cut >= 0:
		return cut
	if event_id == W167_DAEUN and choice == 1:
		for page in range(pages.size()):
			if int(_story.call("_story_source_paragraph_index", page)) == 1:
				return page
	if event_id == W167_UNATTACHED and choice == 0:
		return 0
	return pages.size() - 1

func _w167_result_surface(event_id: String, choice: int, page: int, source: int, cut: int) -> String:
	if event_id == W167_DAEUN:
		if (choice == 0 and page >= cut) or (choice == 1 and source == 1):
			return "restaurant"
		return "neutral"
	if event_id == W167_UNATTACHED:
		if choice == 0:
			return "restaurant"
		return "home" if cut >= 0 and page < cut else "neutral"
	if event_id == W167_LATE and choice == 0:
		return "restaurant" if page >= cut else "neutral"
	return "home"

func _w167_outcome_flags_match(event_id: String, choice: int) -> bool:
	var common := [
		"arc_y4_family_table_seen", "arc_y4_family_partner_daeun",
		"arc_y4_family_no_partner", "arc_y4_family_attended_together",
		"arc_y4_family_attended_alone", "arc_y4_family_missed",
	]
	var expected := ["arc_y4_family_table_seen"]
	if event_id == W167_DAEUN:
		expected.append("arc_y4_family_partner_daeun")
	else:
		expected.append("arc_y4_family_no_partner")
	if event_id == W167_DAEUN and choice == 0:
		expected.append("arc_y4_family_attended_together")
	elif choice == 0 or (event_id == W167_DAEUN and choice == 1):
		expected.append("arc_y4_family_attended_alone")
	else:
		expected.append("arc_y4_family_missed")
	for flag: String in common:
		if bool(GameState.flags.get(flag, false)) != (flag in expected):
			return false
	return true

func _expect_w167_surface(kind: String, home: String, label: String) -> bool:
	if kind == "home":
		if not _expect_surface(home, "apartment", label):
			return false
	elif kind == "restaurant":
		if not _expect_surface(W167_RESTAURANT, "", label):
			return false
	elif kind == "neutral":
		var background := _story.get("_bg_img") as TextureRect
		if str(_story.get("_event_background_id")) != "" \
				or not is_instance_valid(background) or background.texture != null \
				or not str(BGMPlayer.get("_current_ambience_key")).is_empty():
			_fail("%s did not settle on the authored neutral surface" % label)
			return false
	else:
		_fail("%s requested an unknown W167 surface: %s" % [label, kind])
		return false
	var home_bed := kind == "home"
	if BGMPlayer._ambience_player.playing != home_bed \
			or not BGMPlayer._current_human_ambience_key.is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() \
			or BGMPlayer._season_player.playing:
		_fail("%s inherited a crowd/weather bed or lost its sole apartment bed" % label)
		return false
	return true

func _check_w169_midpoint() -> bool:
	var paths := 0
	var score_entries := 0
	var cue_entries := 0
	var variants := [
		{"name": "default", "flags": ["arc_y4_family_table_seen"]},
		{"name": "degraded", "flags": [
			"arc_y4_three_promises_seen", "arc_y4_body_witness_seen", "arc_y4_family_table_seen",
		]},
		{"name": "complete", "flags": [
			"arc_y4_three_promises_seen", "arc_y4_body_witness_seen", "arc_y4_family_table_seen",
			"arc_y4_three_promises_protected_father", "arc_y4_three_promises_missed_person",
			"arc_y4_three_promises_missed_deal", "arc_y4_body_chose_care",
			"arc_y4_family_attended_together",
		]},
	]
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for raw_variant: Dictionary in variants:
			await _remove_story()
			await _stop_audio()
			var variant: String = str(raw_variant["name"])
			_context = "%s/W169/%s" % [language, variant]
			LocaleManager.set_language(language)
			SaveManager.clear_loaded_resume_context()
			GameState.start_new_game()
			GameState.turn = 169
			GameState.month = 7
			GameState.age = 36
			GameState.housing = "oneroom"
			for flag: String in raw_variant["flags"]:
				GameState.flags[flag] = true
			var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
			var selected: String = str(ingress.call(
				"_chapter_four_causal_arc_id", 169, GameState.flags, false))
			ingress.free()
			if selected != W169_MIDPOINT:
				_fail("W169 release ingress did not select the midpoint receipt")
				return false
			GameState.story_return_scene = "res://scenes/MainGame.tscn"
			GameState.pending_story_queue = [W169_MIDPOINT]
			BGMPlayer.set_ambience("cafe")
			BGMPlayer.set_season_ambience("rain")
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			var event: Dictionary = _story.get("_current")
			var resolved := str(_story.call("_resolved_story_description", event))
			var markers: Dictionary = W169_VARIANT_MARKERS[variant]
			if str(event.get("id", "")) != W169_MIDPOINT \
					or int(_story.call("_story_source_paragraph_count")) != 3 \
					or not resolved.contains(str(markers[language])):
				_fail("W169 did not resolve the exact default/degraded/complete source")
				return false
			var home: String = ImageRegistry.resolve_contextual_background_id("current_housing")
			var before_flags: Dictionary = GameState.flags.duplicate(true)
			var before_metrics := [float(GameState.money), float(GameState.health), float(GameState.mental),
				float(GameState.luck), float(GameState.moral_tint),
				int(GameState.route_orthodox), int(GameState.route_unorthodox)]
			var before_events: int = GameState.events_seen
			var before_log: int = GameState.event_log.size()
			var intro_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
			var score_started := false
			var last_score := -1.0
			for page in range(intro_pages.size()):
				await _finish_page()
				var source := int(_story.call("_story_source_paragraph_index", page))
				var scored := source >= 1
				var score := _score_playback_position("reckoning")
				if int(_story.get("_para_index")) != page \
						or not _expect_w169_home(home) or BGMPlayer._current_key != ("reckoning" if scored else "") \
						or (score >= 0.0) != scored or not _w169_cues().is_empty() \
						or (scored and last_score >= 0.0 and score + 0.060 < last_score):
					_fail("W169 score, room or pre-result cue drifted at source %d" % source)
					return false
				if scored and not score_started:
					score_started = true
					score_entries += 1
				last_score = score
				_story.call("_on_advance")
				await _wait_stable()
			if not score_started or not bool(_story.get("_pending_after_result")) \
					or int(_story.get("_pending_result_choice_index")) != 0 \
					or int(_story.call("_story_source_paragraph_count")) != 3:
				_fail("W169 direct continuation did not enter its original three-source result")
				return false
			var result_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
			var heard_paper := false
			for page in range(result_pages.size()):
				await _finish_page()
				var source := int(_story.call("_story_source_paragraph_index", page))
				var cues := _w169_cues()
				var expect_paper := source >= 2
				if int(_story.get("_para_index")) != page or not _expect_w169_home(home) \
						or BGMPlayer._current_key != "reckoning" \
						or (_score_playback_position("reckoning") < 0.0) \
						or cues != ([] if not expect_paper else [
							W169_MIDPOINT + "::result:0:2:0:paper_handle"]):
					_fail("W169 result cue did not stay exclusive to source paragraph two")
					return false
				if expect_paper and not heard_paper:
					heard_paper = true
					cue_entries += 1
				if page + 1 < result_pages.size():
					_story.call("_on_advance")
					await _wait_stable()
			var after_metrics := [float(GameState.money), float(GameState.health), float(GameState.mental),
				float(GameState.luck), float(GameState.moral_tint),
				int(GameState.route_orthodox), int(GameState.route_unorthodox)]
			var receipt: Dictionary = GameState.event_log.back() if not GameState.event_log.is_empty() else {}
			if not heard_paper or after_metrics != before_metrics \
					or GameState.events_seen != before_events + 1 or GameState.event_log.size() != before_log + 1 \
					or str(receipt.get("event_id", "")) != W169_MIDPOINT \
					or int(receipt.get("choice_index", -1)) != 0 \
					or not _w169_flags_match(before_flags):
				_fail("W169 altered state beyond its two authored receipt flags")
				return false
			paths += 1
	print("W169_MIDPOINT_OK paths=%d score_entries=%d cue_entries=%d" % [
		paths, score_entries, cue_entries])
	return paths == 15 and score_entries == 15 and cue_entries == 15

func _w169_cues() -> Array:
	var cues: Array = AudioManager._story_audio_seen.keys().filter(func(key: String) -> bool:
		return key.begins_with(W169_MIDPOINT + ":"))
	cues.sort()
	return cues

func _w169_flags_match(before: Dictionary) -> bool:
	var expected := ["arc_year_three_half_seen", "arc_y4_midpoint_receipt_seen"]
	for flag: String in expected:
		if not bool(GameState.flags.get(flag, false)) or bool(before.get(flag, false)):
			return false
	for raw_flag in GameState.flags.keys():
		var flag := str(raw_flag)
		if bool(GameState.flags.get(flag, false)) != bool(before.get(flag, false)) \
				and flag not in expected:
			return false
	return true

func _expect_w169_home(home: String) -> bool:
	if not _expect_surface(home, "apartment", "W169 oneroom"):
		return false
	if not BGMPlayer._ambience_player.playing \
			or not BGMPlayer._current_human_ambience_key.is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() \
			or BGMPlayer._season_player.playing:
		_fail("W169 lost its sole apartment bed or inherited people/weather")
		return false
	return true

func _check_w181_bill_night() -> bool:
	if ImageRegistry.get_background(W181_INTAKE) != W181_INTAKE_PATH \
			or not FileAccess.file_exists(W181_INTAKE_PATH):
		_fail("W181 intake asset identity changed")
		return false
	var paths := 0
	var restores := 0
	var legacy_restores := 0
	var no_memory_paths := 0
	var memory_hits := {}
	for flag: String in W181_MEMORY_FLAGS:
		memory_hits[flag] = 0
	var variants: Array[Dictionary] = [
		{"id": W181_DAEUN, "daeun": true},
		{"id": W181_UNATTACHED, "daeun": false},
	]
	for language_index in range(LocaleManager.SUPPORTED_LANGUAGES.size()):
		var language: String = str(LocaleManager.SUPPORTED_LANGUAGES[language_index])
		for variant_index in range(variants.size()):
			var variant: Dictionary = variants[variant_index]
			for choice in range(3):
				await _remove_story()
				await _stop_audio()
				var event_id: String = str(variant["id"])
				_context = "%s/W181/%s/c%d" % [language, event_id, choice]
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 181
				GameState.month = 10
				GameState.age = 36
				GameState.housing = "oneroom"
				GameState.money = 2_000_000.0
				if bool(variant["daeun"]):
					GameState.flags["daeun_romance_started"] = true
				# Five prior W177 receipts and the no-memory case each appear once per
				# six paths. The result cut must not depend on the optional intro.
				var path_index := language_index * variants.size() * 3 + variant_index * 3 + choice
				var memory_slot := path_index % (W181_MEMORY_FLAGS.size() + 1)
				var memory_flag := ""
				if memory_slot == 0:
					no_memory_paths += 1
				else:
					memory_flag = str(W181_MEMORY_FLAGS[memory_slot - 1])
					GameState.flags[memory_flag] = true
					memory_hits[memory_flag] = int(memory_hits[memory_flag]) + 1
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var selected := str(ingress.call(
					"_chapter_four_causal_arc_id", 181, GameState.flags, false))
				ingress.free()
				if selected != event_id:
					_fail("W181 release ingress resolved the wrong bill-night variant")
					return false
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [event_id]
				# A stale public room and weather layer make every authored reset
				# observable without changing any product save.
				BGMPlayer.set_ambience("cafe")
				BGMPlayer.set_season_ambience("rain")
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				var current: Dictionary = _story.get("_current")
				var resolved_intro := str(_story.call("_resolved_story_description", current))
				var intro_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
				var expected_intro_sources := 4 + (0 if memory_flag.is_empty() else 1)
				if str(current.get("id", "")) != event_id \
						or int(_story.call("_story_source_paragraph_count")) != expected_intro_sources \
						or not _m23_same_prose(intro_pages, resolved_intro):
					_fail("W181 did not open the exact localized root and optional memory")
					return false
				if not memory_flag.is_empty():
					var memory_map: Dictionary = current.get("description_memory_if_known", {})
					var expected_memory := str(_story.call(
						"_fmt", str(memory_map.get(memory_flag, ""))))
					if expected_memory.is_empty() or not resolved_intro.contains(expected_memory):
						_fail("W181 did not resolve the selected W177 memory receipt")
						return false
				var home := ImageRegistry.resolve_contextual_background_id("current_housing")
				for page in range(intro_pages.size()):
					await _finish_page()
					if not _expect_w181_surface(home, "home", "W181 intro"):
						return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")):
					_fail("W181 did not reach its three authored choices")
					return false
				var before_phenotype := _w177_phenotype_state()
				var expected_phenotype: Dictionary = before_phenotype.duplicate(true)
				if choice == 0:
					expected_phenotype["money"] = float(before_phenotype["money"]) - 487_300.0
				var before_flags: Dictionary = GameState.flags.duplicate(true)
				var before_events := int(GameState.events_seen)
				var before_log: Array = GameState.event_log.duplicate(true)
				var before_action_points := int(GameState.action_points)
				var before_commitments: Array = GameState.weekly_commitments.duplicate(true)
				var before_meta: Dictionary = MetaProgression.data.duplicate(true)
				_story.call("_on_choice", choice)
				await _wait_stable()
				var applied_state := _w177_applied_state()
				var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
				var cut := int(_story.get("_result_location_cut_page"))
				var authored := str(_story.call(
					"_fmt", str((current.get("choices", []) as Array)[choice].get("result_text", ""))))
				if int(_story.call("_story_source_paragraph_count")) != 2 \
						or pages.is_empty() or not _m23_same_prose(pages, authored) \
						or int(_story.call("_story_source_paragraph_index", pages.size() - 1)) != 1 \
						or (cut >= 0) != (choice == 1):
					_fail("W181 result lost its two-source choice-one cut contract")
					return false
				if choice == 1:
					var cut_starts: Dictionary = W181_CUT_STARTS[event_id]
					if cut <= 0 or cut >= pages.size() \
							or int(_story.call("_story_source_paragraph_index", cut - 1)) != 0 \
							or int(_story.call("_story_source_paragraph_index", cut)) != 0 \
							or not str(pages[cut]).begins_with(str(cut_starts[language])):
						_fail("W181 localized hospital move did not begin at the exact action sentence")
						return false
				var phenotype_ok := _w177_phenotype_state() == expected_phenotype
				var flags_ok := _w181_outcome_flags_match(before_flags, choice)
				var receipt_ok := _w181_receipt_matches(before_log, event_id, choice)
				var commitment_ok := _w181_commitment_matches(
					before_commitments, event_id, choice, home)
				if not phenotype_ok or not flags_ok or not receipt_ok \
						or before_action_points <= 0 or not commitment_ok:
					_fail("W181 choice lost its exact money, flags or human commitment receipt phenotype=%s flags=%s receipt=%s commitment=%s ap=%d weekly=%s" % [
						phenotype_ok, flags_ok, receipt_ok, commitment_ok,
						GameState.action_points, JSON.stringify(GameState.weekly_commitments)])
					return false
				var saw_source_one := false
				for page in range(pages.size()):
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					if source == 1:
						saw_source_one = true
					var kind := "home"
					if choice == 1:
						kind = "intake" if page >= cut else "neutral"
					if not _w177_applied_state_matches(applied_state, "W181 live result") \
							or not _expect_w181_surface(home, kind, "W181 result"):
						return false
					if choice == 1 and page in [cut - 1, cut]:
						var context: Dictionary = _story.call("build_save_resume_context")
						if not await _reload_authored_result_context(context, language, 2, 0, true) \
								or int(_story.get("_para_index")) != page \
								or int(_story.get("_result_location_cut_page")) != cut \
								or (int(_story.get("_para_index")) >= cut) != (kind == "intake") \
								or not _w177_applied_state_matches(applied_state, "W181 cold result") \
								or not _expect_w181_surface(home, kind, "W181 cold result"):
							_fail("W181 v4 load crossed the same-source hospital boundary")
							return false
						await _finish_page()
						restores += 1
					if page + 1 < pages.size():
						_story.call("_on_advance")
						await _wait_stable()
				if not saw_source_one or GameState.events_seen != before_events + 1 \
						or not _w177_applied_state_matches(applied_state, "W181 final result") \
						or MetaProgression.data != before_meta:
					_fail("W181 cut skipped the aftermath or changed applied state/gallery data")
					return false
				if choice == 1 and language in ["ko", "en"]:
					if not await _w181_legacy_unsplit_v4(authored, language, home, applied_state):
						return false
					legacy_restores += 2
				paths += 1
	for flag: String in W181_MEMORY_FLAGS:
		if int(memory_hits[flag]) != 5:
			_fail("W181 optional memory coverage drifted for %s" % flag)
			return false
	print("W181_BILL_NIGHT_OK paths=%d v4=%d legacy_v4=%d memory=%d no_memory=%d" % [
		paths, restores, legacy_restores, 25, no_memory_paths])
	return paths == 30 and restores == 20 and legacy_restores == 8 and no_memory_paths == 5

func _w181_legacy_unsplit_v4(authored: String, language: String, home: String,
		applied_state: Dictionary) -> bool:
	# Before this cut, source 0 was paginated as one unsplit prose block.
	# A result saved before it was read must not jump to the intake; a result
	# saved after the whole block must not return to the taxi or replay choice.
	var old_data: Dictionary = _story.call("_story_page_data", authored)
	var old_pages: Array = old_data.get("pages", [])
	var old_source_indices: Array = old_data.get("source_indices", [])
	var final_context: Dictionary = _story.call("build_save_resume_context")
	for at_intake: bool in [false, true]:
		var page: int = old_source_indices.rfind(0) if at_intake else old_source_indices.find(0)
		if page < 0 or page >= old_pages.size():
			_fail("W181 legacy fixture could not paginate unsplit source 0")
			return false
		var context := final_context.duplicate(true)
		var progress := 1.0 if at_intake else 0.0
		context["paragraph_index"] = page
		context["paragraph_was_typing"] = not at_intake
		context["type_pos"] = str(old_pages[page]).length() if at_intake else 0
		context["paragraph_type_ratio"] = progress
		context["source_paragraph_index"] = 0
		context["source_text_progress"] = progress
		if not await _reload_authored_result_context(context, language, 2, 0, true) \
				or int(_story.call("_story_source_paragraph_index", _story.get("_para_index"))) != 0 \
				or not _w177_applied_state_matches(applied_state, "W181 legacy v4") \
				or not _expect_w181_surface(home, "intake" if at_intake else "neutral", "W181 legacy v4"):
			_fail("W181 original unsplit v4 cursor crossed the intake boundary")
			return false
	return true

func _expect_w181_surface(home: String, kind: String, label: String) -> bool:
	var portrait := _story.get("_portrait_frame") as Control
	var portrait_visible := kind != "intake"
	if not is_instance_valid(portrait) or portrait.visible != portrait_visible \
			or bool(_story.get("_current_uses_cg")) \
			or not str(_story.get("_event_cg_id")).is_empty():
		_fail("%s did not keep Minjun exclusive to the non-clinic surface" % label)
		return false
	if kind == "home":
		return _expect_surface(home, "oneroom", label)
	if kind == "neutral":
		var background := _story.get("_bg_img") as TextureRect
		if str(_story.get("_event_background_id")) != "" \
				or not is_instance_valid(background) or background.texture != null \
				or not _expect_no_ambience(label):
			_fail("%s did not keep the pre-intake result visually and aurally neutral" % label)
			return false
		return true
	if kind == "intake":
		if not _expect_surface(W181_INTAKE, "hospital", label) \
				or not BGMPlayer._ambience_player.playing \
				or not BGMPlayer._current_human_ambience_key.is_empty() \
				or BGMPlayer._human_ambience_player.playing \
				or not BGMPlayer._current_season_key.is_empty() \
				or BGMPlayer._season_player.playing:
			_fail("%s lost the sole hospital room bed or inherited people/weather" % label)
			return false
		return true
	_fail("%s requested an unknown W181 surface: %s" % [label, kind])
	return false

func _w181_outcome_flags_match(before: Dictionary, choice: int) -> bool:
	var expected: Dictionary = before.duplicate(true)
	expected["arc_y4_bill_night_seen"] = true
	expected[[
		"arc_y4_bill_chose_payment",
		"arc_y4_bill_chose_body_care",
		"arc_y4_bill_chose_father_care",
	][choice]] = true
	expected["father_care_coordinated" if choice == 2 else "father_care_left_open"] = true
	return GameState.flags == expected

func _w181_receipt_matches(before: Array, event_id: String, choice: int) -> bool:
	var after: Array = GameState.event_log
	var receipt: Dictionary = after.back() if not after.is_empty() else {}
	return after.size() == before.size() + 1 \
		and after.slice(0, before.size()) == before \
		and str(receipt.get("event_id", "")) == event_id \
		and int(receipt.get("choice_index", -1)) == choice \
		and int(receipt.get("turn", -1)) == 181

func _w181_commitment_matches(before: Array, event_id: String, choice: int,
		home: String) -> bool:
	var after: Array = GameState.weekly_commitments
	if GameState.action_points != 0 or after.size() != before.size() + 1 \
			or after.slice(0, before.size()) != before:
		return false
	var receipt: Dictionary = after.back() if not after.is_empty() else {}
	# The receipt records alternatives that remain visible after the choice
	# effects apply. In particular, any W181 result closes the one-shot payment
	# option. Derive that exact product contract instead of assuming all other
	# numeric indexes remain eligible.
	var event: Dictionary = DataRegistry.find_event(event_id)
	var choices: Array = event.get("choices", [])
	var forgone: Array[int] = []
	for candidate in range(choices.size()):
		if candidate != choice and GameState.choice_available(event, choices[candidate]):
			forgone.append(candidate)
	var actual_forgone: Variant = receipt.get("forgone_choice_indexes", [])
	if not actual_forgone is Array:
		return false
	var seen_forgone := {}
	for raw_index in actual_forgone as Array:
		if typeof(raw_index) != TYPE_INT or int(raw_index) == choice \
				or int(raw_index) < 0 or int(raw_index) >= choices.size() \
				or seen_forgone.has(int(raw_index)):
			return false
		seen_forgone[int(raw_index)] = true
	var outcome := {"money": -487_300.0, "total_assets": -487_300.0} \
		if choice == 0 else {}
	return int(receipt.get("turn", -1)) == 181 \
		and str(receipt.get("source", "")) == "story_event" \
		and str(receipt.get("story_event_id", "")) == event_id \
		and int(receipt.get("story_choice_index", -1)) == choice \
		and str(receipt.get("choice_id", "")) == "story:%s:%d" % [event_id, choice] \
		and str(receipt.get("actual_action_id", "")) == "story_choice" \
		and str(receipt.get("axis", "")) == "human" \
		and str(receipt.get("week_kind", "")) == "decision" \
		and str(receipt.get("scene_background_id", "")) == home \
		and actual_forgone == forgone \
		and receipt.get("outcome", {}) == outcome

func _check_w207_page_turn() -> bool:
	var contract: Dictionary = BGMPlayer.scene_audio_contract(W207_OFFER)
	if str(contract.get("ambience", "")) != "office" \
			or contract.get("music", {}) != {"key": "reckoning", "start_paragraph": 2.0} \
			or contract.has("paragraph_cues") or contract.has("result_paragraph_cues"):
		_fail("W207 changed its office/reckoning contract or retained an opening cue")
		return false
	var anchors: Dictionary = W207_PAGE_TURN.get_meta("page_anchors", {})
	if anchors.size() != LocaleManager.SUPPORTED_LANGUAGES.size():
		_fail("W207 lost its five-locale page anchors")
		return false
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		if str(anchors.get(language, "")).strip_edges().is_empty():
			_fail("W207 lost its %s page anchor" % language)
			return false

	var paths := 0
	var guards := 0
	var restores := 0
	var live_cues := 0
	var locale_reflows := 0
	var text_size_reflows := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for producer_choice in range(3):
			if not await _w207_open(language, producer_choice) \
					or not await _w207_read_intro(producer_choice):
				return false
			_story.call("_on_choice", 2)
			await _wait_stable()
			var applied := _w196_applied_state()
			if not _w207_result_layout() \
					or not _w207_surface("W207 result entry", true) \
					or not _w207_audio_matches(false, "W207 result entry") \
					or not await _w207_seek_before_source_one(applied):
				return false
			await _finish_page()
			if not _w207_audio_matches(false, "W207 before Daeun opens her page"):
				return false

			var representative := language == "ko" and producer_choice == 0
			if representative:
				if not await _w207_reflow_boundary(0, applied) \
						or not await _w207_cold_boundary(0, applied):
					return false
				restores += 1
				locale_reflows += 2
				text_size_reflows += 2
				# A cold result restores prose but not an already-entered score. Re-open
				# the real route before measuring the live page-turn edge.
				if not await _w207_open(language, producer_choice) \
						or not await _w207_read_intro(producer_choice):
					return false
				_story.call("_on_choice", 2)
				await _wait_stable()
				applied = _w196_applied_state()
				if not await _w207_seek_before_source_one(applied):
					return false
				await _finish_page()

			_w207_clear_tracked()
			_story.call("_on_advance")
			var played_at := int(AudioManager._last_sfx_ms.get("page_turn", -1))
			if played_at < 0 or not _w207_at_source(1, true) \
					or not _w196_state_matches(applied, "W207 live page turn") \
					or not _w207_surface("W207 live page turn", true) \
					or not _w207_audio_matches(true, "W207 live page turn"):
				_fail("W207 Daeun page did not emit exactly one live page_turn")
				return false
			await _wait_stable()
			await _finish_page()
			if int(AudioManager._last_sfx_ms.get("page_turn", -1)) != played_at:
				_fail("W207 repeated its page turn while completing the same page")
				return false
			live_cues += 1
			_w207_clear_tracked()

			if representative:
				if not await _w207_reflow_boundary(1, applied) \
						or not await _w207_cold_boundary(1, applied):
					return false
				restores += 1
				locale_reflows += 2
				text_size_reflows += 2
			paths += 1

	# The two other responses keep the offer-room surface and never turn a page.
	for producer_choice in range(3):
		for choice in [0, 1]:
			if not await _w207_open("ko", producer_choice) \
					or not await _w207_read_intro(producer_choice):
				return false
			_story.call("_on_choice", choice)
			await _wait_stable()
			var applied := _w196_applied_state()
			if int(_story.get("_result_location_cut_page")) >= 0:
				_fail("W207 quiet c%d unexpectedly gained a result cut" % choice)
				return false
			while true:
				await _finish_page()
				if not _w207_surface("W207 quiet c%d" % choice, false) \
						or not _w196_state_matches(applied, "W207 quiet result") \
						or not _w207_audio_matches(false, "W207 quiet c%d" % choice):
					return false
				if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
					break
				_story.call("_on_advance")
				await _wait_stable()
			guards += 1

	print("W207_PAGE_TURN_OK paths=%d guards=%d v4=%d live_cues=%d locale_reflows=%d text_size_reflows=%d" % [
		paths, guards, restores, live_cues, locale_reflows, text_size_reflows])
	return paths == 15 and guards == 6 and restores == 2 and live_cues == 15 \
		and locale_reflows == 4 and text_size_reflows == 4

func _w207_open(language: String, producer_choice: int) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W207/producer%d" % [language, producer_choice]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	SaveManager.set_setting("story_text_size", "standard")
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 207
	GameState.age = 37
	GameState.month = 4
	GameState.week_of_month = 3
	GameState.housing = "oneroom"
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.flags["route_invest"] = true
	for flag in [
		"arc_sangchul_met_seen", "arc_daeun_met", "daeun_romance_started",
		"arc_minseo_02_seen", "arc_jaehyuk_reunion_seen", "arc_jaehyuk_aftermath_seen",
	]:
		GameState.flags[flag] = true
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true,
		GameState.get_total_asset_value())
	if not bool(locked.get("ok", false)):
		_fail("W207 fixture could not lock the actual Chapter 5 route")
		return false
	var state: Dictionary = locked["state"]
	for step in [[0, 2], [1, 1], [2, 0], [3, 2], [4, 1], [5, 0], [6, producer_choice]]:
		var index := int(step[0])
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(
			state, CHAPTER5_ROUTE.OWNED_EVENT_IDS[index], int(step[1]),
			CHAPTER5_ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("W207 fixture could not commit predecessor %d/%d" % [index, step[1]])
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	if GameState.chapter5_causal_next_event_for_turn() != W207_OFFER:
		_fail("W207 exact predecessor receipts did not admit the final offer")
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.pending_story_queue = [W207_OFFER]
	_w207_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if str((_story.get("_current") as Dictionary).get("id", "")) != W207_OFFER \
			or int(GameState.chapter5_causal_selected_choice(
				CHAPTER5_ROUTE.OWNED_EVENT_IDS[6])) != producer_choice \
			or not _w207_surface("W207 opening", false, false) \
			or not _w207_audio_matches(false, "W207 opening"):
		_fail("W207 StoryMode did not open its exact localized receipt path")
		return false
	return true

func _w207_read_intro(producer_choice: int) -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	var reads: Dictionary = current.get("chapter5_causal_reads", {})
	var text_rows: Array = reads.get("texts", [])
	var expected_prefix := ""
	if text_rows.size() == 1 and text_rows[0] is Array \
			and producer_choice < (text_rows[0] as Array).size():
		expected_prefix = str(_story.call("_fmt", (text_rows[0] as Array)[producer_choice])).strip_edges()
	var sources := authored.split("\n\n")
	var untouched := _w196_applied_state()
	if int(_story.call("_story_source_paragraph_count")) != 6 \
			or sources.size() != 6 or str(sources[0]).strip_edges() != expected_prefix \
			or not _m23_same_prose(pages, authored):
		_fail("W207 lost its selected W204 receipt plus five authored sources")
		return false
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call("_story_source_paragraph_index",
			int(_story.get("_para_index"))))
		await _finish_page()
		if not _w207_surface("W207 intro", false, source >= 2) \
				or not _w196_state_matches(untouched, "W207 intro") \
				or not _w207_audio_matches(false, "W207 intro"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 3 \
		and _w196_state_matches(untouched, "W207 choices") \
		and _w207_surface("W207 choices", false) \
		and _w207_audio_matches(false, "W207 choices")

func _w207_result_layout() -> bool:
	var pages: Array = _story.get("_paragraphs")
	var current: Dictionary = _story.get("_current")
	var choices: Array = current.get("choices", [])
	if choices.size() != 3:
		return false
	var authored := str(_story.call("_fmt", (choices[2] as Dictionary).get("result_text", "")))
	var cut := _w207_source_one_page()
	var anchor := str(_story.call("_fmt", (W207_PAGE_TURN.get_meta(
		"page_anchors", {}) as Dictionary).get(LocaleManager.language, "")))
	return int(_story.call("_story_source_paragraph_count")) == 2 \
		and int(_story.get("_result_location_cut_page")) < 0 \
		and not pages.is_empty() and _m23_same_prose(pages, authored) \
		and cut > 0 and cut < pages.size() and not anchor.is_empty() \
		and int(_story.call("_story_source_paragraph_index", cut - 1)) == 0 \
		and int(_story.call("_story_source_paragraph_index", cut)) == 1 \
		and str(pages[cut]).begins_with(anchor)

func _w207_source_one_page() -> int:
	var pages: Array = _story.get("_paragraphs")
	for page in range(pages.size()):
		if int(_story.call("_story_source_paragraph_index", page)) == 1:
			return page
	return -1

func _w207_at_source(source: int, require_first_page: bool = false) -> bool:
	var page := int(_story.get("_para_index"))
	var pages: Array = _story.get("_paragraphs")
	if not _w207_result_layout() or page < 0 or page >= pages.size() \
			or int(_story.call("_story_source_paragraph_index", page)) != source:
		return false
	if not require_first_page:
		return true
	return source == 1 and page == _w207_source_one_page()

func _w207_seek_before_source_one(applied: Dictionary) -> bool:
	var cut := _w207_source_one_page()
	while int(_story.get("_para_index")) < cut - 1:
		await _finish_page()
		if not _w207_surface("W207 approach to Daeun page", true) \
				or not _w196_state_matches(applied, "W207 approach to Daeun page") \
				or not _w207_audio_matches(false, "W207 approach to Daeun page"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		cut = _w207_source_one_page()
	if int(_story.get("_para_index")) != cut - 1 or not _w207_at_source(0):
		_fail("W207 did not settle on the last source0 page before Daeun opens hers")
		return false
	return true

func _w207_cold_boundary(source: int, applied: Dictionary) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	_w207_clear_tracked()
	if int(context.get("source_paragraph_index", -1)) != source \
			or not await _reload_authored_result_context(
				context, LocaleManager.language, 2, source) \
			or not _w207_at_source(source, source == 1) \
			or not _w207_surface("W207 cold boundary", true, false) \
			or not _w196_state_matches(applied, "W207 cold boundary") \
			or not _w207_audio_matches(false, "W207 cold boundary"):
		_fail("W207 cold result crossed or replayed Daeun's page turn")
		return false
	return true

func _w207_reflow_boundary(source: int, applied: Dictionary) -> bool:
	for level in ["large", "standard"]:
		_w207_clear_tracked()
		_story.call("_set_story_text_size", level)
		await _wait_stable()
		if not _w207_at_source(source, source == 1) \
				or not _w207_surface("W207 text-size reflow", true) \
				or not _w196_state_matches(applied, "W207 text-size reflow") \
				or not _w207_audio_matches(false, "W207 text-size reflow"):
			return false
	for language in ["en", "ko"]:
		_w207_clear_tracked()
		_story.call("_set_story_language", language)
		await _wait_stable()
		if LocaleManager.language != language \
				or not _w207_at_source(source, source == 1) \
				or not _w207_surface("W207 locale reflow", true) \
				or not _w196_state_matches(applied, "W207 locale reflow") \
				or not _w207_audio_matches(false, "W207 locale reflow"):
			return false
	return true

func _w207_surface(label: String, daeun_result: bool, verify_score: bool = true) -> bool:
	var portrait := _story.get("_portrait") as TextureRect
	var expected_portrait := "daeun_normal" if daeun_result else "sangchul_serious"
	var expected_background := "cafe" if daeun_result else "meeting"
	var expected_ambience := "cafe" if daeun_result else "office"
	if str((_story.get("_current") as Dictionary).get("id", "")) != W207_OFFER \
			or str(_story.get("_event_background_id")) != expected_background \
			or str(BGMPlayer.get("_current_ambience_key")) != expected_ambience \
			or (verify_score and str(BGMPlayer.get("_current_key")) != "reckoning") \
			or str(_story.call("_resolved_story_surface_portrait_id")) != expected_portrait \
			or not (_story.get("_portrait_frame") as Control).visible \
			or portrait.texture == null \
			or portrait.texture.resource_path != ImageRegistry.get_portrait(expected_portrait):
		_fail("%s changed W207 %s/%s/%s/reckoning surface" % [
			label, expected_background, expected_ambience, expected_portrait])
		return false
	return true

func _w207_clear_tracked() -> void:
	for sound_id in W207_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)

func _w207_audio_matches(expect_turn: bool, label: String) -> bool:
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		if not str(key).begins_with(W207_OFFER + ":"):
			return false
		for sound_id in W207_TRACKED_SFX:
			if str(key).ends_with(":" + sound_id):
				return true
		return false)
	var invalid: Array[String] = []
	for sound_id in W207_TRACKED_SFX:
		var expected: bool = expect_turn and sound_id == "page_turn"
		if AudioManager._last_sfx_ms.has(sound_id) != expected \
				or _w197_sfx_stream_count(sound_id) != (1 if expected else 0):
			invalid.append(sound_id)
	if not invalid.is_empty() or not cue_keys.is_empty():
		_fail("%s W207 cue mismatch invalid=%s authored=%s" % [label, invalid, cue_keys])
		return false
	return true

func _check_w208_document_scan() -> bool:
	var contract: Dictionary = BGMPlayer.scene_audio_contract(W208_DELIVERY)
	if contract != {"ambience": "office", "suppress_music": true}:
		_fail("W208 changed its office/silent-score contract or retained an opening cue")
		return false
	var anchors: Dictionary = W208_DOCUMENT_SCAN.get_meta("reveal_anchors", {})
	if anchors.size() != LocaleManager.SUPPORTED_LANGUAGES.size():
		_fail("W208 lost its five-locale scan anchors")
		return false
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		if str(anchors.get(language, "")).strip_edges().is_empty():
			_fail("W208 lost its %s scan anchor" % language)
			return false

	var paths := 0
	var natural_cues := 0
	var skip_cues := 0
	var cold_restores := 0
	var text_reflows := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for producer_choice in range(3):
			if not await _w208_open(language, producer_choice):
				return false
			if not _w208_layout(producer_choice):
				_fail("W208 %s producer%d lost its exact receipt, prose, or scan endpoint" % [
					language, producer_choice])
				return false
			var applied := _w196_applied_state()
			if not await _w208_seek_before_scan(applied):
				return false
			await _finish_page()
			var representative := language == "ko" and producer_choice == 0
			_w208_clear_tracked()
			_story.call("_on_advance")
			_story.set_process(false)
			await _wait_stable()
			if not _w208_at_scan_page(true) \
					or not _w208_surface("W208 live scan page") \
					or not _w196_state_matches(applied, "W208 live scan page") \
					or not _w208_audio_matches(false, "W208 scan page entry"):
				_fail("W208 did not arm its authored scan page on live advance")
				return false
			if representative:
				if not await _w208_reflow_pending(applied):
					return false
				text_reflows += 2
			var reveal := int(_story.get("_w208_scan_reveal_at"))
			if reveal <= 0 or not _w208_type_to(reveal - 1) \
					or not _w208_audio_matches(false, "W208 before scan clause end"):
				_fail("W208 scan played before the complete localized clause")
				return false
			if representative:
				if not await _w208_reload_typing_boundary(true, applied):
					return false
				cold_restores += 1
				reveal = int(_story.get("_w208_scan_reveal_at"))
			if not _w208_type_to(reveal) \
					or not _w208_audio_matches(true, "W208 natural scan reveal"):
				_fail("W208 natural type progression did not play one document_scan")
				return false
			var played_at := int(AudioManager._last_sfx_ms.get("document_scan", -1))
			natural_cues += 1

			if representative:
				if not await _w208_reload_typing_boundary(false, applied):
					return false
				cold_restores += 1
				_story.call("_complete_typing")
				if not _w208_audio_matches(false, "W208 completion after cold consumed scan"):
					_fail("W208 completion replayed its cold-restored consumed scan")
					return false
				if not await _w208_reflow_consumed(applied):
					return false
				text_reflows += 2
				played_at = -1
			else:
				_story.call("_complete_typing")
				if int(AudioManager._last_sfx_ms.get("document_scan", -1)) != played_at:
					_fail("W208 completion replayed the live document scan")
					return false
			if not await _w208_finish_intro_without_duplicate(applied, played_at):
				return false
			paths += 1

	# One separate path proves that manually completing the still-typing scan page
	# crosses the same boundary exactly once; it is not a second pagination mode.
	if not await _w208_open("ko", 0) or not await _w208_seek_before_scan(_w196_applied_state()):
		return false
	await _finish_page()
	_w208_clear_tracked()
	_story.call("_on_advance")
	_story.set_process(false)
	await _wait_stable()
	_story.call("_complete_typing")
	var skipped_at := int(AudioManager._last_sfx_ms.get("document_scan", -1))
	if skipped_at < 0 or not _w208_audio_matches(true, "W208 skip scan reveal"):
		_fail("W208 skip-to-complete lost its document scan")
		return false
	_story.call("_complete_typing")
	if int(AudioManager._last_sfx_ms.get("document_scan", -1)) != skipped_at:
		_fail("W208 repeated document_scan after an already-complete skip")
		return false
	skip_cues += 1

	print("W208_DOCUMENT_SCAN_OK paths=%d natural=%d skip=%d v4=%d text_reflows=%d" % [
		paths, natural_cues, skip_cues, cold_restores, text_reflows])
	var counts_ok := paths == 15 and natural_cues == 15 and skip_cues == 1 \
		and cold_restores == 2 and text_reflows == 4
	if not counts_ok:
		_fail("W208 fixture population drifted paths=%d natural=%d skip=%d v4=%d reflow=%d" % [
			paths, natural_cues, skip_cues, cold_restores, text_reflows])
	return counts_ok

func _check_w227_ballpoint() -> bool:
	var contract: Dictionary = BGMPlayer.scene_audio_contract(W227_FILING)
	if contract != {
			"ambience": "intentional_silence",
			"music": {"key": "reckoning", "start_paragraph": 1.0},
			"result_paragraph_cues": {
				"0": {"0": [{"sfx": "paper_handle", "volume_db": -6.0}]},
			},
		}:
		_fail("W227 changed its quiet-room, held-score, or c0 paper-only contract")
		return false
	var anchor_rows: Dictionary = W227_BALLPOINT_WRITE.get_meta("write_anchors", {})
	if anchor_rows.keys().map(func(key: Variant) -> String: return str(key)) != ["1", "3"]:
		_fail("W227 ballpoint metadata lost its exact c1/c3 rows")
		return false
	for choice_key in ["1", "3"]:
		var anchors: Dictionary = anchor_rows.get(choice_key, {})
		if anchors.size() != LocaleManager.SUPPORTED_LANGUAGES.size():
			_fail("W227 c%s lost its five-locale writing anchors" % choice_key)
			return false
		for language: String in LocaleManager.SUPPORTED_LANGUAGES:
			if str(anchors.get(language, "")).strip_edges().is_empty():
				_fail("W227 c%s lost its %s writing anchor" % [choice_key, language])
				return false

	var paths := 0
	var live_ink := 0
	var paper_guards := 0
	var silent_guards := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice: int in range(4):
			if not await _w227_open(language) or not await _w227_read_intro():
				return false
			_w227_clear_tracked()
			_story.call("_on_choice", choice)
			_story.set_process(false)
			await _wait_stable()
			var applied := _w227_state_bytes()
			if not _w227_result_layout(choice) \
					or not GameState.chapter5_finale_receipt_matches(W227_FILING, choice, 227) \
					or not _w227_surface("W227 result entry", true) \
					or not _w227_state_matches(applied, "W227 result entry"):
				_fail("W227 %s c%d did not enter its exact live result" % [language, choice])
				return false
			if choice == 0:
				if not _w227_audio_matches("paper", "W227 c0 source0", true) \
						or not await _w227_finish_result(applied, "paper", -1):
					return false
				paper_guards += 1
			elif choice == 2:
				if not _w227_audio_matches("none", "W227 c2 source0") \
						or not await _w227_finish_result(applied, "none", -1):
					return false
				silent_guards += 1
			else:
				if not await _w227_seek_pen_page(applied):
					return false
				var reveal := int(_story.get("_w227_pen_reveal_at"))
				if reveal <= 0 or not _w227_type_to(reveal - 1) \
						or not _w227_boundary_side(true) \
						or not _w227_audio_matches("none", "W227 before writing clause"):
					_fail("W227 %s c%d sounded before its localized writing clause" % [language, choice])
					return false
				if not _w227_type_to(reveal) \
						or not _w227_audio_matches("pen", "W227 exact writing clause", true):
					_fail("W227 %s c%d lost its exact live ballpoint crossing" % [language, choice])
					return false
				var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
				_story.call("_complete_typing")
				_story.call("_complete_typing")
				if int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != played_at \
						or not await _w227_finish_result(applied, "pen", played_at):
					_fail("W227 %s c%d replayed its completed writing action" % [language, choice])
					return false
				live_ink += 1
			paths += 1

	var skip_ink := 0
	for choice: int in [1, 3]:
		if not await _w227_prepare_result("ko", choice):
			return false
		var mapping := _w227_pen_mapping()
		_w227_clear_tracked()
		if int(mapping.get("page", -1)) != 0:
			_fail("W227 c%d writing clause left initial result page0" % choice)
			return false
		_story.call("_complete_typing")
		var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
		_story.call("_complete_typing")
		if played_at < 0 or int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != played_at \
				or not _w227_audio_matches("pen", "W227 page0 skip", true):
			_fail("W227 c%d page0 completion did not emit one ballpoint action" % choice)
			return false
		skip_ink += 1

	var cold_boundaries := 0
	var cold_live_ink := 0
	for choice: int in [1, 3]:
		for before_pen: bool in [true, false]:
			if not await _w227_prepare_result("ko", choice):
				return false
			var applied := _w227_state_bytes()
			if not await _w227_seek_pen_page(applied):
				return false
			var reveal := int(_story.get("_w227_pen_reveal_at"))
			if not _w227_type_to(reveal - 1 if before_pen else reveal):
				return false
			if not before_pen and not _w227_audio_matches("pen", "W227 pre-save consumed pen", true):
				return false
			_w227_clear_tracked()
			if not await _w227_cold_boundary(choice, before_pen, applied, "ko"):
				return false
			cold_boundaries += 1
			if before_pen:
				cold_live_ink += 1

	var reflow_boundaries := 0
	var reflow_live_ink := 0
	for choice: int in [1, 3]:
		for before_pen: bool in [true, false]:
			if not await _w227_prepare_result("ko", choice):
				return false
			var applied := _w227_state_bytes()
			if not await _w227_seek_pen_page(applied):
				return false
			var reveal := int(_story.get("_w227_pen_reveal_at"))
			if not _w227_type_to(reveal - 1 if before_pen else reveal):
				return false
			_w227_clear_tracked()
			if not await _w227_reflow_boundary(choice, before_pen, applied):
				return false
			reflow_boundaries += 2
			if before_pen:
				reflow_live_ink += 1

	var cross_locale_cold := 0
	for choice: int in [1, 3]:
		if not await _w227_prepare_result("ko", choice):
			return false
		var applied := _w227_state_bytes()
		if not await _w227_seek_pen_page(applied):
			return false
		var reveal := int(_story.get("_w227_pen_reveal_at"))
		if not _w227_type_to(reveal - 1):
			return false
		_w227_clear_tracked()
		if not await _w227_cold_boundary(choice, false, applied, "en", true):
			return false
		cross_locale_cold += 1

	if not await _w227_source1_cold_guard():
		return false
	print("W227_BALLPOINT_OK paths=%d live_ink=%d skip_ink=%d paper=%d silent=%d v4=%d cross_locale_v4=%d source1_v4=1 reflows=%d reflow_ink=%d cold_ink=%d" % [
		paths, live_ink, skip_ink, paper_guards, silent_guards,
		cold_boundaries, cross_locale_cold, reflow_boundaries,
		reflow_live_ink, cold_live_ink])
	var counts_ok := paths == 20 and live_ink == 10 and skip_ink == 2 \
		and paper_guards == 5 and silent_guards == 5 and cold_boundaries == 4 \
		and cross_locale_cold == 2 and reflow_boundaries == 8 \
		and reflow_live_ink == 2 and cold_live_ink == 2
	if not counts_ok:
		_fail("W227 dynamic fixture population drifted")
	return counts_ok

func _w227_open(language: String) -> bool:
	return await _open_finale_ink_event(language, W227_FILING, 227)

func _w230_open(language: String) -> bool:
	return await _open_finale_ink_event(language, W230_CAFE, 230)

func _w235_open(language: String, home_case: Dictionary,
		prime_same_key: bool = false) -> bool:
	return await _open_finale_ink_event(
		language, W235_NOTICE, 235, home_case, prime_same_key)

func _w238_open(language: String, home_case: Dictionary,
		guarantee_choice: int = 0, life: String = "alive",
		prime_same_key: bool = false) -> bool:
	return await _open_finale_ink_event(
		language, W238_REMAINING, 238, home_case, prime_same_key,
		guarantee_choice, life)

func _w239_open(language: String, home_case: Dictionary,
		father_trace_choice: int = 0, remaining_choice: int = 0,
		prime_same_key: bool = false) -> bool:
	return await _open_finale_ink_event(
		language, W239_FATHER_ALIVE, 239, home_case, prime_same_key,
		0, "alive", father_trace_choice, remaining_choice)

func _w239_passed_open(language: String, home_case: Dictionary,
		father_trace_choice: int = 0, remaining_choice: int = 0,
		prime_same_key: bool = false) -> bool:
	return await _open_finale_ink_event(
		language, W239_FATHER_PASSED, 239, home_case, prime_same_key,
		0, "passed", father_trace_choice, remaining_choice)

func _open_finale_ink_event(language: String, target_event_id: String, turn: int,
		home_case: Dictionary = {}, prime_same_key: bool = false,
		guarantee_choice: int = 0, father_life: String = "alive",
		father_trace_choice: int = 0, remaining_choice: int = 0) -> bool:
	await _remove_story()
	await _stop_audio()
	var label := "W239P" if target_event_id == W239_FATHER_PASSED else (
		"W239" if target_event_id == W239_FATHER_ALIVE else (
		"W227" if target_event_id == W227_FILING else (
		"W230" if target_event_id == W230_CAFE else (
			"W235" if target_event_id == W235_NOTICE else "W238"))))
	_context = "%s/%s" % [language, label]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	SaveManager.set_setting("story_text_size", "standard")
	if not _prepare_full_owner_history(turn, []):
		return false
	GameState.money = 2_100_000_000.0
	GameState.housing = str(home_case.get("housing", "oneroom")) \
		if target_event_id in [W235_NOTICE, W238_REMAINING,
			W239_FATHER_ALIVE, W239_FATHER_PASSED] \
		else "oneroom"
	if target_event_id in [W235_NOTICE, W238_REMAINING,
			W239_FATHER_ALIVE, W239_FATHER_PASSED]:
		GameState.flags.erase("arc_daeun_wedding_day_seen")
		GameState.flags.erase("daeun_divorced")
		var home_flags: Dictionary = home_case.get("flags", {})
		for flag: String in home_flags:
			GameState.flags[flag] = bool(home_flags[flag])
	if father_life == "passed":
		GameState.flags["father_passed"] = true
	else:
		GameState.flags.erase("father_passed")
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true,
		GameState.get_total_asset_value())
	if not bool(locked.get("ok", false)):
		_fail("%s could not lock the actual Chapter 5 causal route" % label)
		return false
	var state: Dictionary = locked["state"]
	for index: int in range(CHAPTER5_ROUTE.OWNED_EVENT_IDS.size()):
		var event_id: String = CHAPTER5_ROUTE.OWNED_EVENT_IDS[index]
		var choice_index := 1 if event_id == W219_MEETING_DECISION else (
			guarantee_choice if event_id \
				== "arc_y5_jaehyuk_guarantee_decision_reference" else 0)
		var at_turn: int = CHAPTER5_ROUTE.OWNED_TURNS[index]
		if not CHAPTER5_ROUTE.choice_commit_available(state, event_id, choice_index, at_turn):
			continue
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(
			state, event_id, choice_index, at_turn)
		if not bool(committed.get("ok", false)):
			_fail("%s could not commit causal predecessor %s/c%d" % [
				label, event_id, choice_index])
			return false
		state = committed["state"]
	if not CHAPTER5_ROUTE.route_complete(state) \
			or CHAPTER5_ROUTE.selected_choice(state, W219_MEETING_DECISION) != 1 \
			or CHAPTER5_ROUTE.selected_choice(
				state, "arc_y5_jaehyuk_guarantee_decision_reference") != guarantee_choice:
		_fail("%s causal paper trail did not close on W212 c%d/W219 c1" % [
			label, guarantee_choice])
		return false
	GameState.chapter5_causal_state = state
	var final_calendar := [GameState.turn, GameState.age, GameState.year,
		GameState.month, GameState.week_of_month]
	GameState.turn = 221
	if not GameState.prepare_chapter5_finale_route_entry():
		_fail("%s could not lock its real finale entry" % label)
		return false
	var father_event := GameState.chapter5_finale_next_event_for_turn()
	var father_result: Dictionary = GameState.record_chapter5_finale_choice(
		father_event, father_trace_choice)
	GameState.turn = 224
	var custody_event := GameState.chapter5_finale_next_event_for_turn()
	var custody_result: Dictionary = GameState.record_chapter5_finale_choice(custody_event, 0)
	var filing_event := ""
	var filing_result: Dictionary = {}
	if target_event_id in [W230_CAFE, W235_NOTICE, W238_REMAINING,
			W239_FATHER_ALIVE, W239_FATHER_PASSED]:
		GameState.turn = 227
		filing_event = GameState.chapter5_finale_next_event_for_turn()
		filing_result = GameState.record_chapter5_finale_choice(filing_event, 0)
	var verdict_event := ""
	var verdict_result: Dictionary = {}
	if target_event_id in [W235_NOTICE, W238_REMAINING,
			W239_FATHER_ALIVE, W239_FATHER_PASSED]:
		GameState.turn = 230
		verdict_event = GameState.chapter5_finale_next_event_for_turn()
		verdict_result = GameState.record_chapter5_finale_choice(verdict_event, 0)
	var notice_event := ""
	var notice_result: Dictionary = {}
	if target_event_id in [W238_REMAINING, W239_FATHER_ALIVE, W239_FATHER_PASSED]:
		GameState.turn = 235
		notice_event = GameState.chapter5_finale_next_event_for_turn()
		notice_result = GameState.record_chapter5_finale_choice(notice_event, 0)
	var remaining_event := ""
	var remaining_result: Dictionary = {}
	if target_event_id in [W239_FATHER_ALIVE, W239_FATHER_PASSED]:
		GameState.turn = 238
		remaining_event = GameState.chapter5_finale_next_event_for_turn()
		remaining_result = GameState.record_chapter5_finale_choice(
			remaining_event, remaining_choice)
	GameState.turn = int(final_calendar[0])
	GameState.age = int(final_calendar[1])
	GameState.year = int(final_calendar[2])
	GameState.month = int(final_calendar[3])
	GameState.week_of_month = int(final_calendar[4])
	if father_event not in CHAPTER5_FINALE_ROUTE.OWNED_EVENT_IDS.slice(0, 2) \
			or not bool(father_result.get("ok", false)) \
			or custody_event != CHAPTER5_FINALE_ROUTE.OWNED_EVENT_IDS[2] \
			or not bool(custody_result.get("ok", false)) \
			or (target_event_id in [W230_CAFE, W235_NOTICE, W238_REMAINING, W239_FATHER_ALIVE, W239_FATHER_PASSED] and (filing_event != W227_FILING \
				or not bool(filing_result.get("ok", false)))) \
			or (target_event_id in [W235_NOTICE, W238_REMAINING, W239_FATHER_ALIVE, W239_FATHER_PASSED] and (verdict_event != W230_CAFE \
				or not bool(verdict_result.get("ok", false)))) \
			or (target_event_id in [W238_REMAINING, W239_FATHER_ALIVE, W239_FATHER_PASSED] and (notice_event != W235_NOTICE \
				or not bool(notice_result.get("ok", false)))) \
			or (target_event_id in [W239_FATHER_ALIVE, W239_FATHER_PASSED] and (remaining_event != W238_REMAINING \
				or not bool(remaining_result.get("ok", false)))) \
			or GameState.chapter5_finale_next_event_for_turn() != target_event_id:
		_fail("%s finale predecessors did not admit its exact root" % label)
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
	ingress.set_meta("_screenshot_qa_static_surface", true)
	var routed := bool(ingress.call("_route_chapter5_finale_week"))
	ingress.free()
	if not routed or GameState.pending_story_queue != [target_event_id] \
			or not FULL_STORY_FLOW.valid_session():
		_fail("%s did not route through MainGame and FullStoryFlow" % label)
		return false
	if target_event_id in [W235_NOTICE, W238_REMAINING,
			W239_FATHER_ALIVE, W239_FATHER_PASSED]:
		BGMPlayer.set_ambience("room")
		BGMPlayer.set_season_ambience("winter")
		BGMPlayer.play_punctuation("reckoning")
		if prime_same_key:
			BGMPlayer.set_ambience("apartment")
			BGMPlayer.duck_ambience(-12.0, 1.4)
			if str(BGMPlayer.get("_current_ambience_key")) != "apartment" \
					or not BGMPlayer._ambience_player.playing \
					or BGMPlayer._ambience_tween == null \
					or not BGMPlayer._ambience_tween.is_running():
				_fail("%s same-key fixture did not seed its inherited apartment fade" % label)
				return false
		elif str(BGMPlayer.get("_current_ambience_key")) != "room" \
				or str(BGMPlayer.get("_current_human_ambience_key")) != "thin_wall" \
				or str(BGMPlayer.get("_current_season_key")) != "winter" \
				or not BGMPlayer._ambience_player.playing \
				or not BGMPlayer._human_ambience_player.playing \
				or not BGMPlayer._season_player.playing \
				or not _w216_score_playing():
			_fail("%s fixture did not seed old room/thin-wall/winter/reckoning layers" % label)
			return false
	else:
		BGMPlayer.set_ambience("rain")
		BGMPlayer.set_season_ambience("winter")
	if target_event_id == W238_REMAINING:
		_w238_clear_tracked()
	elif target_event_id == W239_FATHER_ALIVE:
		_w239_clear_tracked()
	elif target_event_id == W239_FATHER_PASSED:
		_w239_passed_clear_tracked()
	else:
		_w227_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if str((_story.get("_current") as Dictionary).get("id", "")) != target_event_id:
		return false
	if target_event_id == W227_FILING:
		return _w227_surface("W227 live opening", false) \
			and _w227_audio_matches("none", "W227 live opening")
	if target_event_id == W230_CAFE:
		return _w230_surface("W230 live opening", false) \
			and _w230_audio_matches("paper", "W230 live opening", true, true)
	if target_event_id == W235_NOTICE:
		return _w235_surface("W235 live opening", str(home_case.get("background", ""))) \
			and _w235_audio_matches("none", "W235 live opening")
	if target_event_id == W239_FATHER_ALIVE:
		return _w239_surface(
			"W239 live opening", str(home_case.get("background", "")), false) \
			and (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
			and (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
			and _w239_audio_matches(false, "W239 live opening")
	if target_event_id == W239_FATHER_PASSED:
		return _w239_passed_surface(
			"W239 passed live opening", str(home_case.get("background", ""))) \
			and (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
			and (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
			and _w239_passed_audio_matches(false, "W239 passed live opening")
	return _w238_surface(
		"W238 live opening", str(home_case.get("background", "")), false) \
		and _w238_audio_matches("W238 live opening")

func _w227_read_intro() -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	if int(_story.call("_story_source_paragraph_count")) != 4 \
			or pages.is_empty() or not _m23_same_prose(pages, authored):
		_fail("W227 lost its two receipt rows plus two authored prose sources")
		return false
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index"))))
		await _finish_page()
		if not _w227_surface("W227 opening", source >= 1) \
				or not _w227_audio_matches("none", "W227 opening"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 4 \
		and _w227_surface("W227 choices", true) \
		and _w227_audio_matches("none", "W227 choices")

func _w227_prepare_result(language: String, choice: int) -> bool:
	if not await _w227_open(language) or not await _w227_read_intro():
		return false
	_w227_clear_tracked()
	_story.call("_on_choice", choice)
	_story.set_process(false)
	await _wait_stable()
	return _w227_result_layout(choice) \
		and GameState.chapter5_finale_receipt_matches(W227_FILING, choice, 227) \
		and _w227_surface("W227 prepared result", true)

func _w227_result_layout(choice: int) -> bool:
	var pages: Array = _story.get("_paragraphs")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choice < 0 or choice >= choices.size() or pages.is_empty():
		return false
	var authored := str(_story.call("_fmt", (choices[choice] as Dictionary).get("result_text", "")))
	var expected_sources: Array = [2, 1, 2, 2]
	if int(_story.call("_story_source_paragraph_count")) != int(expected_sources[choice]) \
			or not _m23_same_prose(pages, authored) \
			or int(_story.get("_result_location_cut_page")) >= 0:
		return false
	var mapping := _w227_pen_mapping()
	return not mapping.is_empty() if choice in [1, 3] else mapping.is_empty()

func _w227_pen_mapping() -> Dictionary:
	var found: Array[Dictionary] = []
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		var page := str((_story.get("_paragraphs") as Array)[page_index])
		var reveal := int(_story.call("_w227_pen_reveal_position", page, page_index))
		if reveal > 0:
			found.append({"page": page_index, "reveal": reveal})
	return found[0] if found.size() == 1 else {}

func _w227_seek_pen_page(applied: String) -> bool:
	var mapping := _w227_pen_mapping()
	var target := int(mapping.get("page", -1))
	while int(_story.get("_para_index")) < target:
		await _finish_page()
		if not _w227_audio_matches("none", "W227 before writing page") \
				or not _w227_state_matches(applied, "W227 before writing page"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		mapping = _w227_pen_mapping()
		target = int(mapping.get("page", -1))
	if target < 0 or int(_story.get("_para_index")) != target \
			or int(_story.get("_w227_pen_reveal_at")) != int(mapping.get("reveal", -2)):
		_fail("W227 did not settle on its exact writing-clause page")
		return false
	return true

func _w227_type_to(target: int, owner: String = "W227") -> bool:
	var guard := 0
	while int(_story.get("_type_pos")) < target and guard < 4096:
		var before := int(_story.get("_type_pos"))
		_story.call("_process", float(_story.call("_direction_type_interval")))
		if int(_story.get("_type_pos")) == before:
			_story.call("_process", 0.001)
		guard += 1
	if int(_story.get("_type_pos")) != target:
		_fail("%s typewriter skipped target=%d actual=%d" % [
			owner, target, int(_story.get("_type_pos"))])
		return false
	return true

func _w227_finish_result(applied: String, audio_mode: String, played_at: int) -> bool:
	while true:
		await _finish_page()
		if not _w227_surface("W227 result", true) \
				or not _w227_state_matches(applied, "W227 result") \
				or not _w227_audio_matches(audio_mode, "W227 result"):
			return false
		if played_at >= 0 and int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != played_at:
			_fail("W227 later result page replayed pen_ballpoint")
			return false
		if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
			return true
		_story.call("_on_advance")
		await _wait_stable()
	return false

func _w227_boundary_side(before_pen: bool) -> bool:
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) not in [1, 3] \
			or int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) != 0:
		return false
	var pen_range: Vector2 = _story.call("_w227_pen_progress_range")
	var context: Dictionary = _story.call("build_save_resume_context")
	var progress := float(context.get("source_text_progress", -1.0))
	if pen_range.x < 0.0 or pen_range.y < pen_range.x:
		return false
	if before_pen:
		return not bool(_story.get("_w227_pen_consumed")) \
			and int(_story.get("_w227_pen_reveal_at")) > int(_story.get("_type_pos")) \
			and progress <= pen_range.x + 0.00001
	return bool(_story.get("_w227_pen_consumed")) \
		and int(_story.get("_w227_pen_reveal_at")) < 0 \
		and progress >= pen_range.y - 0.00001

func _w227_cold_boundary(choice: int, before_pen: bool, applied: String,
		target_locale: String, cross_locale: bool = false) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	var saved_progress := float(context.get("source_text_progress", -1.0))
	if context.get("event_id") != W227_FILING or context.get("phase") != "result" \
			or int(context.get("pending_result_choice_index", -1)) != choice \
			or int(context.get("source_paragraph_index", -1)) != 0 \
			or not bool(context.get("paragraph_was_typing", false)) \
			or not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("W227 could not save its exact typing boundary")
		return false
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int((disk as Dictionary).get("version", -1)) != 4:
		_fail("W227 cold boundary lost disk schema v4")
		return false
	await _remove_story()
	GameState.start_new_game()
	LocaleManager.set_language(target_locale)
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("W227 could not cold-load its typing boundary")
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	await get_tree().create_timer(0.85).timeout
	var restored: Dictionary = _story.call("build_save_resume_context")
	var expected_before := before_pen and not cross_locale
	var restored_progress := float(restored.get("source_text_progress", -2.0))
	var side_ok := _w227_boundary_side(expected_before)
	if cross_locale:
		var pen_range: Vector2 = _story.call("_w227_pen_progress_range")
		var source_characters := 0
		for page_index: int in range((_story.get("_paragraphs") as Array).size()):
			if int(_story.call("_story_source_paragraph_index", page_index)) == 0:
				source_characters += str((_story.get("_paragraphs") as Array)[page_index]).length()
		var quantization_bound := 0.5 / float(source_characters) + 0.000001 \
			if source_characters > 0 else -1.0
		side_ok = bool(_story.get("_w227_pen_consumed")) \
			and int(_story.get("_w227_pen_reveal_at")) < 0 \
			and quantization_bound > 0.0 \
			and absf(restored_progress - saved_progress) <= quantization_bound \
			and (saved_progress >= pen_range.x or restored_progress < pen_range.y)
	if LocaleManager.language != target_locale or restored.get("event_id") != W227_FILING \
			or restored.get("phase") != "result" \
			or int(restored.get("pending_result_choice_index", -1)) != choice \
			or int(restored.get("source_paragraph_index", -1)) != 0 \
			or (not cross_locale and not is_equal_approx(restored_progress, saved_progress)) \
			or not side_ok \
			or not _w227_state_matches(applied, "W227 cold result", cross_locale) \
			or not _w227_surface("W227 cold result", true) \
			or not _w227_audio_matches("none", "W227 cold result"):
		_fail("W227 cold boundary crossed, replayed, changed state, or lost held score")
		return false
	if expected_before:
		var reveal := int(_story.get("_w227_pen_reveal_at"))
		if not _w227_type_to(reveal) \
				or not _w227_audio_matches("pen", "W227 cold pending crossing", true):
			_fail("W227 same-locale cold restore did not retain its future pen action")
			return false
		var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
		_story.call("_complete_typing")
		if int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != played_at:
			_fail("W227 cold pending crossing replayed at completion")
			return false
	else:
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if not _w227_audio_matches("none", "W227 cold consumed completion"):
			_fail("W227 cold consumed boundary replayed a past writing action")
			return false
	return _w216_score_playing() \
		and _w227_state_matches(applied, "W227 cold final", cross_locale)

func _w227_reflow_boundary(choice: int, before_pen: bool, applied: String) -> bool:
	_story.call("_set_story_text_size", "large")
	await _wait_stable()
	if not _w227_boundary_side(before_pen) \
			or not _w227_state_matches(applied, "W227 font reflow") \
			or not _w227_surface("W227 font reflow", true) \
			or not _w227_audio_matches("none", "W227 font reflow"):
		_fail("W227 c%d font reflow crossed or replayed its pen boundary" % choice)
		return false
	_story.call("_set_story_language", "en")
	await _wait_stable()
	if LocaleManager.language != "en" or not _w227_boundary_side(before_pen) \
			or not _w227_state_matches(applied, "W227 locale reflow", true) \
			or not _w227_surface("W227 locale reflow", true) \
			or not _w227_audio_matches("none", "W227 locale reflow"):
		_fail("W227 c%d locale reflow crossed or replayed its pen boundary" % choice)
		return false
	if before_pen:
		var reveal := int(_story.get("_w227_pen_reveal_at"))
		if not _w227_type_to(reveal) \
				or not _w227_audio_matches("pen", "W227 reflow pending crossing", true):
			_fail("W227 c%d reflow lost its one remaining pen action" % choice)
			return false
		var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
		_story.call("_complete_typing")
		return int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) == played_at
	_story.call("_complete_typing")
	_story.call("_complete_typing")
	return _w227_audio_matches("none", "W227 reflow consumed completion")

func _w227_source1_cold_guard() -> bool:
	if not await _w227_prepare_result("ko", 3):
		return false
	var applied := _w227_state_bytes()
	if not await _w227_seek_pen_page(applied):
		return false
	var reveal := int(_story.get("_w227_pen_reveal_at"))
	if not _w227_type_to(reveal):
		return false
	while int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) == 0:
		await _finish_page()
		if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
			_fail("W227 c3 lost its second result source")
			return false
		_story.call("_on_advance")
		await _wait_stable()
	_w227_clear_tracked()
	var context: Dictionary = _story.call("build_save_resume_context")
	if int(context.get("source_paragraph_index", -1)) != 1 \
			or not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("W227 c3 could not save its later source1")
		return false
	await _remove_story()
	GameState.start_new_game()
	LocaleManager.set_language("ko")
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("W227 c3 could not restore its later source1")
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	await get_tree().create_timer(0.85).timeout
	var restored: Dictionary = _story.call("build_save_resume_context")
	_story.call("_complete_typing")
	return int(restored.get("source_paragraph_index", -1)) == 1 \
		and bool(_story.get("_w227_pen_consumed")) \
		and _w227_state_matches(applied, "W227 source1 cold") \
		and _w227_surface("W227 source1 cold", true) \
		and _w227_audio_matches("none", "W227 source1 cold")

func _w227_surface(label: String, expect_score: bool) -> bool:
	return _finale_ink_surface(
		W227_FILING, W227_BACKGROUND, "W227", label, expect_score)

func _finale_ink_surface(event_id: String, background_id: String,
		owner: String, label: String, expect_score: bool) -> bool:
	var portrait := _story.get("_portrait") as TextureRect
	var portrait_frame := _story.get("_portrait_frame") as Control
	if str((_story.get("_current") as Dictionary).get("id", "")) != event_id \
			or not _expect_surface(background_id, "", label) \
			or portrait.texture != null or portrait_frame.visible \
			or not _expect_no_ambience(label):
		_fail("%s changed %s quiet surface or empty portrait" % [label, owner])
		return false
	if expect_score:
		if not _w216_score_playing():
			_fail("%s lost %s held reckoning score" % [label, owner])
			return false
	elif not str(BGMPlayer.get("_current_key")).is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("%s opened %s score before source1" % [label, owner])
		return false
	return true

func _w227_clear_tracked() -> void:
	for sound_id: String in W227_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)

func _w227_audio_matches(mode: String, label: String, require_stream: bool = false) -> bool:
	return _finale_ink_audio_matches(
		W227_FILING, "W227", mode, label, require_stream, false)

func _finale_ink_audio_matches(event_id: String, owner: String, mode: String,
		label: String, require_stream: bool, expect_intro_token: bool) -> bool:
	var expected_sound := "paper_handle" if mode == "paper" else (
		"pen_ballpoint" if mode == "pen" else "")
	var cue_keys: Array = AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		if not str(key).begins_with(event_id + ":"):
			return false
		for sound_id: String in W227_TRACKED_SFX:
			if str(key).ends_with(":" + sound_id):
				return true
		return false)
	cue_keys.sort()
	var expected_cues: Array = []
	if event_id == W227_FILING and mode == "paper":
		expected_cues.append(W227_FILING + "::result:0:0:0:paper_handle")
	elif event_id == W230_CAFE and expect_intro_token:
		expected_cues.append(W230_CAFE + "::description:0:0:paper_handle")
	var invalid: Array[String] = []
	for sound_id: String in W227_TRACKED_SFX:
		var expected := sound_id == expected_sound
		var streams := _w197_sfx_stream_count(sound_id)
		if AudioManager._last_sfx_ms.has(sound_id) != expected \
				or (not expected and streams != 0) \
				or (expected and require_stream and streams != 1):
			invalid.append(sound_id)
	if cue_keys != expected_cues or not invalid.is_empty():
		_fail("%s %s audio mismatch mode=%s invalid=%s cues=%s" % [
			label, owner, mode, invalid, cue_keys])
		return false
	if require_stream and not expected_sound.is_empty():
		var choice := int(_story.get("_pending_result_choice_index"))
		var gain := -8.0 if event_id == W235_NOTICE else (
			(-6.0 if mode == "paper" else -5.0) if event_id == W227_FILING \
			else (-7.0 if mode == "paper" or choice != 1 else -6.0))
		var expected_db := float(AudioManager.call("_vol_db")) \
			+ AudioManager.sfx_mix_trim_db(expected_sound) + gain
		for player: AudioStreamPlayer in AudioManager._pool:
			if player.playing and player.stream == AudioManager._sounds.get(expected_sound):
				if not is_equal_approx(player.volume_db, expected_db):
					_fail("%s %s %s volume expected=%s actual=%s" % [
						label, owner, expected_sound, expected_db, player.volume_db])
					return false
				return true
		_fail("%s %s %s stream was not active" % [label, owner, expected_sound])
		return false
	return true

func _w227_state_bytes() -> String:
	# Compare every serialized field and meta value across the v4 JSON boundary.
	# Numeric Variant widths normalize legitimately; no semantic field is omitted.
	return JSON.stringify({
		"game": _w177_json_state(GameState.serialize()),
		"meta": _w177_json_state(MetaProgression.data),
	}, "", true)

func _w227_state_matches(expected: String, label: String,
		allow_default_name_projection: bool = false, owner: String = "W227") -> bool:
	var actual_bytes := _w227_state_bytes()
	if actual_bytes == expected:
		return true
	var expected_state: Variant = JSON.parse_string(expected)
	var actual_state: Variant = JSON.parse_string(actual_bytes)
	if allow_default_name_projection and expected_state is Dictionary \
			and actual_state is Dictionary:
		var expected_game: Dictionary = (expected_state as Dictionary).get("game", {})
		var actual_game: Dictionary = (actual_state as Dictionary).get("game", {})
		var projected_name := LocaleManager.localize_player_name(
			str(expected_game.get("player_name", "")))
		if str(actual_game.get("player_name", "")) == projected_name:
			expected_game["player_name"] = projected_name
			(expected_state as Dictionary)["game"] = expected_game
			if expected_state == actual_state:
				return true
	var changed: Array[String] = []
	var changed_flags: Array[String] = []
	var changed_game: Array[String] = []
	if expected_state is Dictionary and actual_state is Dictionary:
		for key: String in expected_state:
			if expected_state[key] != (actual_state as Dictionary).get(key):
				changed.append(key)
		var expected_flags: Dictionary = (expected_state as Dictionary).get("flags", {})
		var actual_flags: Dictionary = (actual_state as Dictionary).get("flags", {})
		var flag_keys: Array = expected_flags.keys()
		for key: Variant in actual_flags:
			if not flag_keys.has(key):
				flag_keys.append(key)
		flag_keys.sort()
		for key: Variant in flag_keys:
			if expected_flags.get(key, null) != actual_flags.get(key, null):
				changed_flags.append("%s:%s->%s" % [key,
					JSON.stringify(expected_flags.get(key, null)),
					JSON.stringify(actual_flags.get(key, null))])
		var expected_game: Dictionary = (expected_state as Dictionary).get("game", {})
		var actual_game: Dictionary = (actual_state as Dictionary).get("game", {})
		for key: Variant in expected_game:
			if expected_game[key] != actual_game.get(key, null):
				changed_game.append(str(key))
	_fail("%s changed %s route/economy/flags/receipts/gallery state keys=%s game=%s flags=%s expected=%s actual=%s" % [
		label, owner, changed, changed_game, changed_flags,
		expected.sha256_text(), actual_bytes.sha256_text()])
	return false


func _check_w230_cafe_write() -> bool:
	_w230_cold_ink = 0
	_w230_cross_future_ink = 0
	_w230_reflow_ink = 0
	var paths := 0
	var live_ink := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice: int in range(3):
			if not await _w230_prepare_result(language, choice):
				return false
			var applied := _w227_state_bytes()
			if not GameState.chapter5_finale_receipt_matches(W230_CAFE, choice, 230) \
					or not _w230_surface("W230 result entry", true) \
					or not _w230_state_matches(applied, "W230 result entry") \
					or not _w230_audio_matches(
						"none", "W230 result entry", false, true):
				_fail("W230 %s c%d did not enter its exact live result" % [language, choice])
				return false
			var last_pen_ms := -1
			var action_sources := _w230_action_sources(choice)
			for action_index in range(action_sources.size()):
				var source_index: int = action_sources[action_index]
				if not await _w230_seek_pen_page(source_index, applied, last_pen_ms):
					return false
				var reveal := int(_story.get("_w230_pen_reveal_at"))
				if reveal <= 0 or not _w227_type_to(reveal - 1, "W230") \
						or not _w230_boundary_side(source_index, true) \
						or int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != last_pen_ms:
					_fail("W230 %s c%d/s%d sounded before its localized writing clause" % [
						language, choice, source_index])
					return false
				if not _w227_type_to(reveal, "W230"):
					return false
				var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
				if played_at <= last_pen_ms \
						or not _w230_boundary_side(source_index, false) \
						or not _w230_audio_matches(
							"pen", "W230 exact writing clause", true, true):
					_fail("W230 %s c%d/s%d lost its exact live ballpoint crossing" % [
						language, choice, source_index])
					return false
				_story.call("_complete_typing")
				_story.call("_complete_typing")
				if int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != played_at:
					_fail("W230 %s c%d/s%d replayed its completed writing action" % [
						language, choice, source_index])
					return false
				last_pen_ms = played_at
				live_ink += 1
				if action_index + 1 < action_sources.size() \
						and not await _w230_wait_ballpoint_completion(played_at):
					return false
			if not await _w230_finish_result(applied, last_pen_ms):
				return false
			paths += 1
	if paths != 15 or live_ink != 25:
		_fail("W230 live fixture population drifted paths=%d live_ink=%d" % [
			paths, live_ink])
		return false
	var rapid: Dictionary = await _w230_rapid_skip_guard()
	if not bool(rapid.get("ok", false)):
		return false
	var cold_boundaries := 0
	for choice: int in range(3):
		for source_index: int in _w230_action_sources(choice):
			for before_pen: bool in [true, false]:
				if not await _w230_prepare_result("ko", choice):
					return false
				var applied := _w227_state_bytes()
				if not await _w230_position_at_action(source_index, applied):
					return false
				var reveal := int(_story.get("_w230_pen_reveal_at"))
				if not _w227_type_to(reveal - 1 if before_pen else reveal, "W230"):
					return false
				if not before_pen:
					var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
					if played_at < 0 or not await _w230_wait_ballpoint_completion(played_at):
						return false
				_w227_clear_tracked()
				if not await _w230_cold_boundary(
						choice, source_index, before_pen, applied, "ko", false):
					return false
				cold_boundaries += 1
	var cross_locale_cold := 0
	for choice: int in range(3):
		for source_index: int in _w230_action_sources(choice):
			if not await _w230_prepare_result("ko", choice):
				return false
			var applied := _w227_state_bytes()
			if not await _w230_position_at_action(source_index, applied):
				return false
			var reveal := int(_story.get("_w230_pen_reveal_at"))
			if not _w227_type_to(reveal - 1, "W230"):
				return false
			_w227_clear_tracked()
			if not await _w230_cold_boundary(
					choice, source_index, false, applied, "en", true):
				return false
			cross_locale_cold += 1
	var reflow_boundaries := 0
	for choice: int in range(3):
		for source_index: int in _w230_action_sources(choice):
			for before_pen: bool in [true, false]:
				if not await _w230_prepare_result("ko", choice):
					return false
				var applied := _w227_state_bytes()
				if not await _w230_position_at_action(source_index, applied):
					return false
				var reveal := int(_story.get("_w230_pen_reveal_at"))
				if not _w227_type_to(reveal - 1 if before_pen else reveal, "W230"):
					return false
				if not before_pen:
					var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
					if played_at < 0 or not await _w230_wait_ballpoint_completion(played_at):
						return false
				if not await _w230_reflow_boundary(
						choice, source_index, before_pen, applied):
					return false
				reflow_boundaries += 2
	print("W230_BALLPOINT_OK paths=%d live_ink=%d rapid_beats=%d rapid_dispatch=%d v4=%d cold_ink=%d cross_locale_v4=%d cross_future_ink=%d reflows=%d reflow_ink=%d" % [
		paths, live_ink, int(rapid.get("beats", 0)), int(rapid.get("dispatch", 0)),
		cold_boundaries, _w230_cold_ink, cross_locale_cold,
		_w230_cross_future_ink, reflow_boundaries, _w230_reflow_ink])
	var counts_ok := cold_boundaries == 10 and _w230_cold_ink == 9 \
		and cross_locale_cold == 5 and _w230_cross_future_ink == 2 \
		and reflow_boundaries == 20 and _w230_reflow_ink == 5 \
		and int(rapid.get("beats", 0)) == 5 and int(rapid.get("dispatch", 0)) == 3
	if not counts_ok:
		_fail("W230 dynamic fixture population drifted")
	return counts_ok


func _w230_action_sources(choice: int) -> Array[int]:
	var sources: Array[int] = []
	if choice in [0, 1]:
		sources.assign([0, 1])
	elif choice == 2:
		sources.append(0)
	return sources


func _w230_read_intro() -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	var paper_at := int(AudioManager._last_sfx_ms.get("paper_handle", -1))
	if int(_story.call("_story_source_paragraph_count")) != 4 \
			or pages.is_empty() or not _m23_same_prose(pages, authored) or paper_at < 0:
		_fail("W230 lost its two receipt rows, two authored prose sources, or intro paper")
		return false
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		await _finish_page()
		if not _w230_surface("W230 opening", source >= 1) \
				or not _w230_audio_matches("paper", "W230 opening", false, true) \
				or int(AudioManager._last_sfx_ms.get("paper_handle", -1)) != paper_at:
			_fail("W230 replayed its intro paper while reading")
			return false
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 3 \
		and _w230_surface("W230 choices", true) \
		and _w230_audio_matches("paper", "W230 choices", false, true)


func _w230_prepare_result(language: String, choice: int) -> bool:
	if not await _w230_open(language) or not await _w230_read_intro():
		return false
	_w227_clear_tracked()
	_story.call("_on_choice", choice)
	_story.set_process(false)
	await _wait_stable()
	return _w230_result_layout(choice) \
		and GameState.chapter5_finale_receipt_matches(W230_CAFE, choice, 230) \
		and _w230_surface("W230 prepared result", true) \
		and _w230_audio_matches("none", "W230 prepared result", false, true)


func _w230_result_layout(choice: int) -> bool:
	var pages: Array = _story.get("_paragraphs")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choice < 0 or choice >= choices.size() or pages.is_empty():
		return false
	var authored := str(_story.call(
		"_fmt", (choices[choice] as Dictionary).get("result_text", "")))
	if int(_story.call("_story_source_paragraph_count")) != 2 \
			or not _m23_same_prose(pages, authored) \
			or int(_story.get("_result_location_cut_page")) >= 0:
		_fail("W230 c%d lost its exact two-source result" % choice)
		return false
	var expected_sources := _w230_action_sources(choice)
	for source_index in range(2):
		var mapping := _w230_pen_mapping(source_index)
		if (source_index in expected_sources) != (not mapping.is_empty()):
			_fail("W230 c%d/s%d changed its exact write-action inventory" % [
				choice, source_index])
			return false
	return true


func _w230_pen_mapping(source_index: int) -> Dictionary:
	var found: Array[Dictionary] = []
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		if int(_story.call("_story_source_paragraph_index", page_index)) != source_index:
			continue
		var page := str((_story.get("_paragraphs") as Array)[page_index])
		var reveal := int(_story.call("_w230_pen_reveal_position", page, page_index))
		if reveal > 0:
			found.append({"page": page_index, "reveal": reveal})
	return found[0] if found.size() == 1 else {}


func _w230_seek_pen_page(source_index: int, applied: String, last_pen_ms: int,
		allow_default_name_projection: bool = false) -> bool:
	var mapping := _w230_pen_mapping(source_index)
	var target := int(mapping.get("page", -1))
	while int(_story.get("_para_index")) < target:
		await _finish_page()
		if not _w230_state_matches(
				applied, "W230 before writing page", allow_default_name_projection) \
				or int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != last_pen_ms:
			_fail("W230 changed state or replayed ink before its writing page")
			return false
		_story.call("_on_advance")
		await _wait_stable()
		mapping = _w230_pen_mapping(source_index)
		target = int(mapping.get("page", -1))
	if target < 0 or int(_story.get("_para_index")) != target \
			or int(_story.get("_w230_pen_reveal_at")) != int(mapping.get("reveal", -2)):
		_fail("W230 did not settle on c%d/source%d writing-clause page" % [
			int(_story.get("_pending_result_choice_index")), source_index])
		return false
	return true


func _w230_finish_result(applied: String, last_pen_ms: int) -> bool:
	while true:
		await _finish_page()
		if not _w230_surface("W230 result", true) \
				or not _w230_state_matches(applied, "W230 result") \
				or not _w230_audio_matches("pen", "W230 result", false, true) \
				or int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != last_pen_ms:
			_fail("W230 later result page replayed or lost pen_ballpoint")
			return false
		if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
			return true
		_story.call("_on_advance")
		await _wait_stable()
	return false


func _w230_boundary_side(source_index: int, before_pen: bool) -> bool:
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) not in [0, 1, 2] \
			or int(_story.call(
				"_story_source_paragraph_index", int(_story.get("_para_index")))) != source_index:
		return false
	var pen_range: Vector2 = _story.call("_w230_pen_progress_range", source_index)
	var context: Dictionary = _story.call("build_save_resume_context")
	var progress := float(context.get("source_text_progress", -1.0))
	var consumed: Dictionary = _story.get("_w230_pen_consumed")
	if pen_range.x < 0.0 or pen_range.y < pen_range.x:
		return false
	if before_pen:
		return not bool(consumed.get(str(source_index), false)) \
			and int(_story.get("_w230_pen_reveal_at")) > int(_story.get("_type_pos")) \
			and progress <= pen_range.x + 0.00001
	return bool(consumed.get(str(source_index), false)) \
		and int(_story.get("_w230_pen_reveal_at")) < 0 \
		and progress >= pen_range.y - 0.00001


func _w230_surface(label: String, expect_score: bool) -> bool:
	return _finale_ink_surface(
		W230_CAFE, W230_BACKGROUND, "W230", label, expect_score)


func _w230_audio_matches(mode: String, label: String,
		require_stream: bool = false, expect_intro_token: bool = true) -> bool:
	return _finale_ink_audio_matches(
		W230_CAFE, "W230", mode, label, require_stream, expect_intro_token)


func _w230_state_matches(expected: String, label: String,
		allow_default_name_projection: bool = false) -> bool:
	return _w227_state_matches(
		expected, label, allow_default_name_projection, "W230")


func _w230_wait_ballpoint_completion(played_at: int) -> bool:
	var stream: AudioStream = AudioManager._sounds.get("pen_ballpoint")
	if stream == null or played_at < 0:
		_fail("W230 cannot derive the recorded ballpoint completion boundary")
		return false
	var duration_msec := int(ceil(stream.get_length() * 1000.0))
	var deadline := Time.get_ticks_msec() + maxi(250, duration_msec + 250)
	while _w197_sfx_stream_count("pen_ballpoint") > 0 \
			and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	if _w197_sfx_stream_count("pen_ballpoint") != 0 \
			or int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != played_at:
		_fail("W230 ballpoint did not finish naturally without replay")
		return false
	return true


func _w230_rapid_skip_guard() -> Dictionary:
	var beats := 0
	var dispatch := 0
	for choice: int in range(3):
		if not await _w230_prepare_result("ko", choice):
			return {"ok": false}
		var applied := _w227_state_bytes()
		var last_pen_ms := -1
		var actions := _w230_action_sources(choice)
		for action_index in range(actions.size()):
			var source_index: int = actions[action_index]
			if not await _w230_seek_pen_page(source_index, applied, last_pen_ms):
				return {"ok": false}
			var consumed: Dictionary = _story.get("_w230_pen_consumed")
			if bool(consumed.get(str(source_index), false)):
				_fail("W230 rapid c%d/s%d was consumed before its own clause" % [
					choice, source_index])
				return {"ok": false}
			var reveal := int(_story.get("_w230_pen_reveal_at"))
			if reveal <= 0:
				return {"ok": false}
			var pending_timers: Dictionary = AudioManager._pending_audio_timers.duplicate()
			_story.call("_complete_typing")
			var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
			consumed = _story.get("_w230_pen_consumed")
			if not bool(consumed.get(str(source_index), false)) \
					or _w197_sfx_stream_count("pen_ballpoint") != 1 \
					or not _w230_state_matches(applied, "W230 rapid completion"):
				_fail("W230 rapid c%d/s%d lost its consumed beat or live stroke" % [
					choice, source_index])
				return {"ok": false}
			beats += 1
			if action_index == 0:
				if played_at <= last_pen_ms:
					_fail("W230 rapid c%d did not dispatch its first physical stroke" % choice)
					return {"ok": false}
				dispatch += 1
			else:
				if played_at != last_pen_ms \
						or AudioManager._pending_audio_timers != pending_timers:
					_fail("W230 rapid c%d stacked or queued a late second stroke" % choice)
					return {"ok": false}
			last_pen_ms = played_at
			if action_index + 1 < actions.size():
				var future_source: int = actions[action_index + 1]
				consumed = _story.get("_w230_pen_consumed")
				if bool(consumed.get(str(future_source), false)):
					_fail("W230 rapid c%d consumed future source%d with source%d" % [
						choice, future_source, source_index])
					return {"ok": false}
		if not await _w230_wait_ballpoint_completion(last_pen_ms):
			return {"ok": false}
		for _frame in range(4):
			await get_tree().process_frame
		if int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != last_pen_ms \
				or _w197_sfx_stream_count("pen_ballpoint") != 0:
			_fail("W230 rapid completion emitted a late pen after the stroke ended")
			return {"ok": false}
	return {"ok": true, "beats": beats, "dispatch": dispatch}


func _w230_position_at_action(source_index: int, applied: String) -> bool:
	var choice := int(_story.get("_pending_result_choice_index"))
	var last_pen_ms := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
	for prior_source: int in _w230_action_sources(choice):
		if prior_source >= source_index:
			break
		if not await _w230_seek_pen_page(prior_source, applied, last_pen_ms):
			return false
		var reveal := int(_story.get("_w230_pen_reveal_at"))
		if not _w227_type_to(reveal, "W230"):
			return false
		var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
		if played_at <= last_pen_ms \
				or not _w230_audio_matches(
					"pen", "W230 prior source action", true, true) \
				or not await _w230_wait_ballpoint_completion(played_at):
			_fail("W230 could not complete prior source%d before source%d" % [
				prior_source, source_index])
			return false
		last_pen_ms = played_at
	return await _w230_seek_pen_page(source_index, applied, last_pen_ms)


func _w230_cold_boundary(
		choice: int, source_index: int, before_pen: bool, applied: String,
		target_locale: String, cross_locale: bool) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	var saved_progress := float(context.get("source_text_progress", -1.0))
	if context.get("event_id") != W230_CAFE or context.get("phase") != "result" \
			or int(context.get("pending_result_choice_index", -1)) != choice \
			or int(context.get("source_paragraph_index", -1)) != source_index \
			or not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("W230 could not save c%d/source%d exact typing boundary" % [
			choice, source_index])
		return false
	var disk: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int((disk as Dictionary).get("version", -1)) != 4:
		_fail("W230 cold boundary lost disk schema v4")
		return false
	await _remove_story()
	GameState.start_new_game()
	LocaleManager.set_language(target_locale)
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("W230 could not cold-load its typing boundary")
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	await get_tree().create_timer(0.85).timeout
	var restored: Dictionary = _story.call("build_save_resume_context")
	var expected_before := before_pen and not cross_locale
	var restored_progress := float(restored.get("source_text_progress", -2.0))
	var side_ok := _w230_boundary_side(source_index, expected_before)
	if cross_locale:
		var pen_range: Vector2 = _story.call("_w230_pen_progress_range", source_index)
		var source_characters := 0
		for page_index: int in range((_story.get("_paragraphs") as Array).size()):
			if int(_story.call("_story_source_paragraph_index", page_index)) == source_index:
				source_characters += str((_story.get("_paragraphs") as Array)[page_index]).length()
		var quantization_bound := 0.5 / float(source_characters) + 0.000001 \
			if source_characters > 0 else -1.0
		var consumed: Dictionary = _story.get("_w230_pen_consumed")
		side_ok = bool(consumed.get(str(source_index), false)) \
			and int(_story.get("_w230_pen_reveal_at")) < 0 \
			and quantization_bound > 0.0 \
			and absf(restored_progress - saved_progress) <= quantization_bound \
			and (saved_progress >= pen_range.x or restored_progress < pen_range.y)
	var consumed: Dictionary = _story.get("_w230_pen_consumed")
	var source_states_ok := true
	for action_source: int in _w230_action_sources(choice):
		var expected_consumed := action_source < source_index \
			or (action_source == source_index and not expected_before)
		if bool(consumed.get(str(action_source), false)) != expected_consumed:
			source_states_ok = false
	if LocaleManager.language != target_locale or restored.get("event_id") != W230_CAFE \
			or restored.get("phase") != "result" \
			or int(restored.get("pending_result_choice_index", -1)) != choice \
			or int(restored.get("source_paragraph_index", -1)) != source_index \
			or (not cross_locale and not is_equal_approx(restored_progress, saved_progress)) \
			or not side_ok or not source_states_ok \
			or not _w230_state_matches(applied, "W230 cold result", cross_locale) \
			or not _w230_surface("W230 cold result", true) \
			or not _w230_audio_matches("none", "W230 cold result", false, false):
		_fail("W230 cold boundary crossed, replayed, changed state, or lost source identity")
		return false
	var last_pen_ms := -1
	if expected_before:
		var reveal := int(_story.get("_w230_pen_reveal_at"))
		if not _w227_type_to(reveal, "W230") \
				or not _w230_audio_matches(
					"pen", "W230 cold pending crossing", true, false):
			_fail("W230 same-locale cold restore lost its pending pen action")
			return false
		last_pen_ms = int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
		_w230_cold_ink += 1
	else:
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if not _w230_audio_matches("none", "W230 cold consumed completion", false, false):
			_fail("W230 cold consumed boundary replayed a past writing action")
			return false
	if source_index == 0 and choice in [0, 1]:
		consumed = _story.get("_w230_pen_consumed")
		if bool(consumed.get("1", false)):
			_fail("W230 cold source0 consumed the definitely future source1 writer")
			return false
		if last_pen_ms >= 0 and not await _w230_wait_ballpoint_completion(last_pen_ms):
			return false
		if not await _w230_seek_pen_page(1, applied, last_pen_ms, cross_locale):
			return false
		var future_reveal := int(_story.get("_w230_pen_reveal_at"))
		if future_reveal <= 0 or not _w227_type_to(future_reveal - 1, "W230") \
				or bool((_story.get("_w230_pen_consumed") as Dictionary).get("1", false)):
			_fail("W230 cold restore lost source1 before its own writing clause")
			return false
		if not _w227_type_to(future_reveal, "W230"):
			return false
		var future_played := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
		if future_played <= last_pen_ms \
				or not _w230_audio_matches(
					"pen", "W230 cold future source1", true, false):
			_fail("W230 cold restore did not retain source1's independent pen action")
			return false
		last_pen_ms = future_played
		if cross_locale:
			_w230_cross_future_ink += 1
		else:
			_w230_cold_ink += 1
	if last_pen_ms >= 0:
		if not await _w230_wait_ballpoint_completion(last_pen_ms):
			return false
	return _w216_score_playing() \
		and _w230_state_matches(applied, "W230 cold final", cross_locale)


func _w230_reflow_boundary(
		choice: int, source_index: int, before_pen: bool, applied: String) -> bool:
	var last_pen_ms := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
	_story.call("_set_story_text_size", "large")
	await _wait_stable()
	if not _w230_boundary_side(source_index, before_pen) \
			or not _w230_state_matches(applied, "W230 font reflow") \
			or not _w230_surface("W230 font reflow", true) \
			or int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != last_pen_ms:
		_fail("W230 c%d/s%d font reflow crossed or replayed its pen boundary" % [
			choice, source_index])
		return false
	_story.call("_set_story_language", "en")
	await _wait_stable()
	if LocaleManager.language != "en" \
			or not _w230_boundary_side(source_index, before_pen) \
			or not _w230_state_matches(applied, "W230 locale reflow", true) \
			or not _w230_surface("W230 locale reflow", true) \
			or int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) != last_pen_ms:
		_fail("W230 c%d/s%d locale reflow crossed or replayed its pen boundary" % [
			choice, source_index])
		return false
	var consumed: Dictionary = _story.get("_w230_pen_consumed")
	if source_index == 0 and choice in [0, 1] and bool(consumed.get("1", false)):
		_fail("W230 c%d reflow consumed its future source1 writer" % choice)
		return false
	if before_pen:
		var reveal := int(_story.get("_w230_pen_reveal_at"))
		if not _w227_type_to(reveal, "W230"):
			return false
		var played_at := int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1))
		if played_at <= last_pen_ms \
				or not _w230_audio_matches(
					"pen", "W230 reflow pending crossing", true, true):
			_fail("W230 c%d/s%d reflow lost its remaining pen action" % [
				choice, source_index])
			return false
		_w230_reflow_ink += 1
		return true
	_story.call("_complete_typing")
	_story.call("_complete_typing")
	return int(AudioManager._last_sfx_ms.get("pen_ballpoint", -1)) == last_pen_ms


func _check_w238_remaining() -> bool:
	var default_home: Dictionary = W235_HOME_CASES[1]
	var settings_before := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	var paths := 0
	var silent_results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice in range(2):
			if not await _w238_prepare_result(language, choice, default_home):
				return false
			var applied := _w227_state_bytes()
			if not await _w238_finish_result(applied):
				return false
			paths += 1
			silent_results += 1

	var ingress_contexts := 0
	for life: String in ["alive", "passed"]:
		for guarantee_choice in range(3):
			if not await _w238_open(
					"ko", default_home, guarantee_choice, life) \
					or not _w238_context_matches(guarantee_choice, life):
				return false
			ingress_contexts += 1

	var housing_contexts := 0
	for home_case: Dictionary in W235_HOME_CASES:
		if not await _w238_open("ko", home_case) \
				or not _w238_surface(
					"W238 housing " + str(home_case.get("id", "")),
					str(home_case.get("background", "")), false):
			return false
		housing_contexts += 1

	var apartment_case: Dictionary = W235_HOME_CASES[3]
	if not await _w238_open("ko", apartment_case, 0, "alive", true):
		return false
	await get_tree().create_timer(1.5).timeout
	if not _w238_surface("W238 same-key settled bed", "gangnam_apartment", false) \
			or BGMPlayer._ambience_tween != null \
			and BGMPlayer._ambience_tween.is_running() \
			or not is_equal_approx(
				BGMPlayer._ambience_player.volume_db,
				float(BGMPlayer.call("_ambience_target_db"))):
		_fail("W238 inherited same-key fade stopped or kept ducking its fresh bed")
		return false

	var cold_restores := await _w238_cold_matrix(default_home)
	if cold_restores < 0:
		return false
	var reflows := await _w238_reflow_matrix(default_home)
	if reflows < 0:
		return false
	var settings_after := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	print("W238_REMAINING_OK paths=%d silent=%d ingress=%d homes=%d same_key=1 v4=%d reflows=%d" % [
		paths, silent_results, ingress_contexts, housing_contexts,
		cold_restores, reflows])
	var counts_ok := paths == 10 and silent_results == 10 \
		and ingress_contexts == 6 and housing_contexts == 7 \
		and cold_restores == 5 and reflows == 6 \
		and settings_before == settings_after
	if not counts_ok:
		_fail("W238 dynamic fixture population or master-volume state drifted")
	return counts_ok


func _w238_context_matches(guarantee_choice: int, life: String) -> bool:
	var current: Dictionary = _story.get("_current")
	var raw_event: Dictionary = DataRegistry.find_event(W238_REMAINING)
	var rows: Array = (
		raw_event.get("chapter5_finale_reads", {}) as Dictionary).get("texts", [])
	var sources := str(_story.call("_fmt", current.get("description", ""))).split("\n\n")
	var entry: Dictionary = GameState.chapter5_finale_entry_snapshot()
	var source_choices: Dictionary = entry.get("source_choices", {})
	var father: Dictionary = entry.get("father", {})
	if rows.size() != 2 or not rows[0] is Array or not rows[1] is Array \
			or (rows[0] as Array).size() != 3 or (rows[1] as Array).size() != 1 \
			or sources.size() != 4 \
			or str(sources[0]).strip_edges() != str(_story.call(
				"_fmt", (rows[0] as Array)[guarantee_choice])).strip_edges() \
			or str(sources[1]).strip_edges() != str(_story.call(
				"_fmt", (rows[1] as Array)[0])).strip_edges() \
			or int(source_choices.get("w212_guarantee", -1)) != guarantee_choice \
			or str(father.get("life", "")) != life \
			or GameState.chapter5_finale_next_event_for_turn() != W238_REMAINING \
			or not GameState.chapter5_finale_ingress_available(W238_REMAINING) \
			or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
			or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
			or not _w238_surface(
				"W238 exact ingress", _w235_current_home_background(), false) \
			or not _w238_audio_matches("W238 exact ingress"):
		_fail("W238 lost its selected W212 channel row or real finale ingress")
		return false
	return true


func _w238_read_intro(home_background: String) -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	if int(_story.call("_story_source_paragraph_count")) != 4 \
			or pages.is_empty() or not _m23_same_prose(pages, authored):
		_fail("W238 lost its guarantee/nontransaction rows plus two authored sources")
		return false
	var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
	var bed_position := BGMPlayer._ambience_player.get_playback_position()
	var untouched := _w227_state_bytes()
	var score_player: AudioStreamPlayer = null
	var score_stream: AudioStream = null
	var score_position := -1.0
	var score_token := -1
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		await _finish_page()
		var expect_score := source >= 1
		var current_bed_position := BGMPlayer._ambience_player.get_playback_position()
		if not _w238_surface(
				"W238 opening source%d" % source, home_background, expect_score) \
				or not _w238_audio_matches("W238 opening source%d" % source) \
				or not _w227_state_matches(
					untouched, "W238 opening source%d" % source, false, "W238") \
				or BGMPlayer._ambience_player.stream != bed_stream \
				or current_bed_position + 0.05 < bed_position \
				or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
				or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty():
			_fail("W238 source%d restarted its bed or gained a physical action" % source)
			return false
		bed_position = current_bed_position
		if expect_score:
			var current_score := _w237_score_player()
			if not is_instance_valid(current_score):
				_fail("W238 source%d has no actual reckoning stream" % source)
				return false
			if score_player == null:
				score_player = current_score
				score_stream = current_score.stream
				score_position = current_score.get_playback_position()
				score_token = int(BGMPlayer.get("_punctuation_token"))
			elif not _w237_score_unchanged(
					score_player, score_stream, score_position, score_token,
					"W238 source%d" % source):
				return false
			else:
				score_position = current_score.get_playback_position()
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 2 \
		and _w238_surface("W238 choices", home_background, true) \
		and _w238_audio_matches("W238 choices") \
		and _w227_state_matches(untouched, "W238 choices", false, "W238")


func _w238_prepare_result(
		language: String, choice: int, home_case: Dictionary) -> bool:
	var home_background := str(home_case.get("background", ""))
	if not await _w238_open(language, home_case) \
			or not await _w238_read_intro(home_background):
		return false
	_w238_clear_tracked()
	_story.call("_on_choice", choice)
	_story.set_process(false)
	await _wait_stable()
	return _w238_result_layout(choice) \
		and GameState.chapter5_finale_receipt_matches(
			W238_REMAINING, choice, 238) \
		and _w238_surface("W238 prepared result", home_background, true) \
		and _w238_audio_matches("W238 prepared result")


func _w238_result_layout(choice: int) -> bool:
	var pages: Array = _story.get("_paragraphs")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choice < 0 or choice >= choices.size() or pages.is_empty():
		return false
	var authored := str(_story.call(
		"_fmt", (choices[choice] as Dictionary).get("result_text", "")))
	var expected_sources := 1 if choice == 0 else 2
	var action_free := true
	for page_index in range(pages.size()):
		action_free = action_free \
			and (_story.call("_physical_cue_contract", page_index) as Dictionary).is_empty() \
			and (_story.call("_ballpoint_write_contract", page_index) as Dictionary).is_empty()
	if choices.size() != 2 \
			or int(_story.call("_story_source_paragraph_count")) != expected_sources \
			or not _m23_same_prose(pages, authored) \
			or int(_story.get("_result_location_cut_page")) >= 0 \
			or not action_free:
		_fail("W238 choice%d lost its exact silent result contract" % choice)
		return false
	return true


func _w238_finish_result(applied: String) -> bool:
	var score_player := _w237_score_player()
	if not is_instance_valid(score_player):
		_fail("W238 result started without its held reckoning score")
		return false
	var score_stream: AudioStream = score_player.stream
	var score_position := score_player.get_playback_position()
	var score_token := int(BGMPlayer.get("_punctuation_token"))
	while true:
		await _finish_page()
		if not _w238_surface(
				"W238 result", _w235_current_home_background(), true) \
				or not _w227_state_matches(applied, "W238 result", false, "W238") \
				or not _w238_audio_matches("W238 result") \
				or not _w237_score_unchanged(
					score_player, score_stream, score_position, score_token,
					"W238 result"):
			_fail("W238 result replayed a physical cue or restarted its score")
			return false
		score_position = score_player.get_playback_position()
		if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
			return true
		_story.call("_on_advance")
		await _wait_stable()
	return false


func _w238_cold_matrix(home_case: Dictionary) -> int:
	var restores := 0
	for spec: Dictionary in [
		{"phase": "prose", "source": 0, "locale": "ko"},
		{"phase": "prose", "source": 1, "locale": "en"},
		{"phase": "choices", "source": 3, "locale": "ko"},
		{"phase": "result", "choice": 0, "source": 0, "locale": "ko"},
		{"phase": "result", "choice": 1, "source": 1, "locale": "en"},
	]:
		if not await _w238_prepare_saved_position(spec, home_case):
			return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		var applied := _w227_state_bytes()
		var target_locale := str(spec.get("locale", "ko"))
		var cross_locale := target_locale != LocaleManager.language
		if not await _w238_cold_load(
				context, target_locale, applied, cross_locale,
				"W238 cold " + str(spec.get("phase", ""))):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		var source_index := int(spec.get("source", -1))
		var phase := str(spec.get("phase", ""))
		var expect_score := phase != "prose" or source_index >= 1
		if str(restored.get("phase", "")) != phase \
				or (phase != "choices" and int(restored.get(
					"source_paragraph_index", -1)) != source_index) \
				or (phase != "choices" and not _w238_progress_matches(
					context, restored, source_index, cross_locale)) \
				or not _w238_surface(
					"W238 cold " + phase, _w235_current_home_background(), expect_score) \
				or not _w238_audio_matches("W238 cold " + phase):
			_fail("W238 cold %s changed source progress, score, or physical silence" % phase)
			return -1
		if phase == "prose" and source_index == 0:
			if not await _w238_advance_to_source(1) \
					or not _w238_surface(
						"W238 cold future score", _w235_current_home_background(), true) \
					or not _w238_audio_matches("W238 cold future score"):
				_fail("W238 cold source0 did not retain its future source1 score entrance")
				return -1
			if not _w227_state_matches(
					applied, "W238 cold future score", cross_locale, "W238"):
				return -1
		restores += 1
	return restores


func _w238_prepare_saved_position(spec: Dictionary, home_case: Dictionary) -> bool:
	var phase := str(spec.get("phase", ""))
	var source_index := int(spec.get("source", 0))
	if phase == "result":
		if not await _w238_prepare_result(
				"ko", int(spec.get("choice", 0)), home_case) \
				or not await _w238_advance_to_source(source_index, true):
			return false
	elif not await _w238_open("ko", home_case):
		return false
	elif phase == "choices":
		if not await _w238_read_intro(str(home_case.get("background", ""))):
			return false
	elif not await _w238_advance_to_source(source_index):
		return false
	if phase != "choices":
		var page_length := str(_story.get("_type_full")).length()
		if not _w227_type_to(
				maxi(1, floori(float(page_length) / 2.0)), "W238"):
			return false
	var context: Dictionary = _story.call("build_save_resume_context")
	return str(context.get("event_id", "")) == W238_REMAINING \
		and str(context.get("phase", "")) == phase \
		and (phase == "choices" or int(context.get(
			"source_paragraph_index", -1)) == source_index)


func _w238_cold_load(context: Dictionary, target_locale: String,
		applied: String, cross_locale: bool, label: String) -> bool:
	if not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail(label + " could not write isolated v4 save")
		return false
	var disk: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int((disk as Dictionary).get("version", -1)) != 4:
		_fail(label + " lost disk schema v4")
		return false
	await _remove_story()
	await _stop_audio()
	GameState.start_new_game()
	LocaleManager.set_language(target_locale)
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail(label + " could not cold-load its source position")
		return false
	BGMPlayer.set_ambience("room")
	BGMPlayer.set_season_ambience("winter")
	BGMPlayer.play_punctuation("reckoning")
	_w238_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	await get_tree().create_timer(0.9).timeout
	return _w227_state_matches(applied, label, cross_locale, "W238")


func _w238_progress_matches(
		before: Dictionary, after: Dictionary, source_index: int,
		cross_locale: bool) -> bool:
	var expected := float(before.get("source_text_progress", -1.0))
	var actual := float(after.get("source_text_progress", -2.0))
	if not cross_locale:
		return is_equal_approx(actual, expected)
	var source_characters := 0
	for page_index in range((_story.get("_paragraphs") as Array).size()):
		if int(_story.call("_story_source_paragraph_index", page_index)) == source_index:
			source_characters += str((_story.get("_paragraphs") as Array)[page_index]).length()
	return source_characters > 0 \
		and absf(actual - expected) <= 0.5 / float(source_characters) + 0.000001


func _w238_reflow_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for spec: Dictionary in [
		{"phase": "prose", "source": 0},
		{"phase": "prose", "source": 1},
		{"phase": "result", "choice": 1, "source": 1},
	]:
		if not await _w238_prepare_saved_position(spec, home_case):
			return -1
		var before: Dictionary = _story.call("build_save_resume_context")
		var applied := _w227_state_bytes()
		var source_index := int(spec.get("source", 0))
		var expect_score := source_index >= 1 or str(spec.get("phase", "")) == "result"
		var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
		var bed_position := BGMPlayer._ambience_player.get_playback_position()
		var score_player: AudioStreamPlayer = _w237_score_player() if expect_score else null
		var score_stream: AudioStream = score_player.stream if is_instance_valid(score_player) else null
		var score_position := score_player.get_playback_position() \
			if is_instance_valid(score_player) else -1.0
		var score_token := int(BGMPlayer.get("_punctuation_token"))
		_story.call("_set_story_text_size", "large")
		await _wait_stable()
		var font_context: Dictionary = _story.call("build_save_resume_context")
		if not _w238_reflow_matches(
				before, font_context, source_index, false, applied,
				expect_score, bed_stream, bed_position, score_player,
				score_stream, score_position, score_token, "font"):
			return -1
		bed_position = BGMPlayer._ambience_player.get_playback_position()
		if expect_score:
			score_position = score_player.get_playback_position()
		_story.call("_set_story_language", "en")
		await _wait_stable()
		var locale_context: Dictionary = _story.call("build_save_resume_context")
		if LocaleManager.language != "en" \
				or not _w238_reflow_matches(
					before, locale_context, source_index, true, applied,
					expect_score, bed_stream, bed_position, score_player,
					score_stream, score_position, score_token, "locale"):
			return -1
		if str(spec.get("phase", "")) == "prose" and source_index == 0:
			if not await _w238_advance_to_source(1) \
					or not _w238_surface(
						"W238 reflow future score",
						_w235_current_home_background(), true):
				return -1
		boundaries += 2
	return boundaries


func _w238_reflow_matches(
		before: Dictionary, after: Dictionary, source_index: int,
		cross_locale: bool, applied: String, expect_score: bool,
		bed_stream: AudioStream, bed_position: float,
		score_player: AudioStreamPlayer, score_stream: AudioStream,
		score_position: float, score_token: int, label: String) -> bool:
	if str(after.get("phase", "")) != str(before.get("phase", "")) \
			or int(after.get("source_paragraph_index", -1)) != source_index \
			or not _w238_progress_matches(before, after, source_index, cross_locale) \
			or BGMPlayer._ambience_player.stream != bed_stream \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < bed_position \
			or not _w227_state_matches(
				applied, "W238 " + label + " reflow", cross_locale, "W238") \
			or not _w238_surface(
				"W238 " + label + " reflow",
				_w235_current_home_background(), expect_score) \
			or not _w238_audio_matches("W238 " + label + " reflow"):
		_fail("W238 %s reflow changed source progress, bed, state, or silence" % label)
		return false
	if expect_score and not _w237_score_unchanged(
			score_player, score_stream, score_position, score_token,
			"W238 " + label + " reflow"):
		return false
	return true


func _w238_advance_to_source(
		target_source: int, result_phase: bool = false) -> bool:
	for _guard in range(64):
		if bool(_story.get("_showing_choices")) and not result_phase:
			break
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		if source == target_source:
			return true
		if source > target_source:
			break
		await _finish_page()
		if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
			break
		_story.call("_on_advance")
		await _wait_stable()
	_fail("W238 could not advance to %s source%d" % [
		"result" if result_phase else "prose", target_source])
	return false


func _w238_surface(label: String, background_id: String, expect_score: bool) -> bool:
	var expected_stream: AudioStream = BGMPlayer.call("_load_ambience", "apartment")
	if str((_story.get("_current") as Dictionary).get("id", "")) != W238_REMAINING \
			or background_id.is_empty() \
			or not _expect_surface(background_id, "apartment", label) \
			or str(_story.call("_resolved_story_surface_portrait_id")) != "player_tired" \
			or expected_stream == null \
			or BGMPlayer._ambience_player.stream != expected_stream \
			or not BGMPlayer._ambience_player.playing \
			or not str(BGMPlayer.get("_current_human_ambience_key")).is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or not str(BGMPlayer.get("_current_season_key")).is_empty() \
			or BGMPlayer._season_player.playing:
		_fail(label + " changed the W238 home, apartment bed, portrait, or lower-layer silence")
		return false
	if expect_score:
		if not _w216_score_playing():
			_fail(label + " lost the W238 held reckoning score")
			return false
	elif not str(BGMPlayer.get("_current_key")).is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail(label + " opened W238 score before source1")
		return false
	return true


func _w238_clear_tracked() -> void:
	for sound_id: String in W238_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)


func _w238_audio_matches(label: String) -> bool:
	var cue_keys: Array = AudioManager._story_audio_seen.keys().filter(
		func(key: Variant) -> bool:
			return str(key).begins_with(W238_REMAINING + ":"))
	var invalid: Array[String] = []
	for sound_id: String in W238_TRACKED_SFX:
		if AudioManager._last_sfx_ms.has(sound_id) \
				or _w197_sfx_stream_count(sound_id) != 0:
			invalid.append(sound_id)
	if not cue_keys.is_empty() or not invalid.is_empty():
		_fail("%s W238 physical silence mismatch invalid=%s cues=%s" % [
			label, invalid, cue_keys])
		return false
	return true


func _check_w239_father_alive() -> bool:
	_w239_cold_ink = 0
	_w239_reflow_ink = 0
	var default_home: Dictionary = W235_HOME_CASES[1]
	var settings_before := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	var paths := 0
	var live_ink := 0
	var silent_results := 0
	for language_index in range(LocaleManager.SUPPORTED_LANGUAGES.size()):
		var language: String = LocaleManager.SUPPORTED_LANGUAGES[language_index]
		for choice in range(3):
			if not await _w239_prepare_result(
					language, choice, default_home,
					language_index % 3, language_index % 2):
				return false
			var applied := _w227_state_bytes()
			if choice == 2:
				if not await _w239_seek_pen_page(applied):
					return false
				var reveal := int(_story.get("_w239_pen_reveal_at"))
				if reveal <= 0 or not _w227_type_to(reveal - 1, "W239") \
						or not _w239_boundary_side(true) \
						or not _w239_audio_matches(
							false, "W239 before name-write clause"):
					_fail("W239 %s sounded before its localized name-write clause" % language)
					return false
				if not _w227_type_to(reveal, "W239"):
					return false
				var played_at := int(AudioManager._last_sfx_ms.get(
					"pen_ballpoint", -1))
				if played_at < 0 or not _w239_boundary_side(false) \
						or not _w239_audio_matches(
							true, "W239 exact name-write clause", true) \
						or not await _w239_finish_result(applied, played_at) \
						or not await _w239_wait_ballpoint_completion(played_at):
					_fail("W239 %s lost its one exact ballpoint action" % language)
					return false
				live_ink += 1
			elif not await _w239_finish_result(applied, -1):
				return false
			else:
				silent_results += 1
			paths += 1

	var ingress_contexts := 0
	for trace_choice in range(3):
		for remaining_choice in range(2):
			if not await _w239_open(
					"ko", default_home, trace_choice, remaining_choice) \
					or not _w239_context_matches(trace_choice, remaining_choice):
				return false
			ingress_contexts += 1

	var housing_contexts := 0
	for home_case: Dictionary in W235_HOME_CASES:
		if not await _w239_open("ko", home_case) \
				or not _w239_surface(
					"W239 housing " + str(home_case.get("id", "")),
					str(home_case.get("background", "")), false):
			return false
		housing_contexts += 1

	var apartment_case: Dictionary = W235_HOME_CASES[3]
	if not await _w239_open("ko", apartment_case, 0, 0, true):
		return false
	await get_tree().create_timer(1.5).timeout
	if not _w239_surface("W239 same-key settled bed", "gangnam_apartment", false) \
			or BGMPlayer._ambience_tween != null \
			and BGMPlayer._ambience_tween.is_running() \
			or not is_equal_approx(
				BGMPlayer._ambience_player.volume_db,
				float(BGMPlayer.call("_ambience_target_db"))):
		_fail("W239 inherited same-key fade stopped or kept ducking its fresh bed")
		return false

	var intro_cold := await _w239_intro_cold_matrix(default_home)
	if intro_cold < 0:
		return false
	var cold_boundaries := await _w239_result_cold_matrix(default_home)
	if cold_boundaries < 0:
		return false
	var legacy_boundaries := await _w239_legacy_cold_matrix(default_home)
	if legacy_boundaries < 0:
		return false
	var reflow_boundaries := await _w239_reflow_matrix(default_home)
	if reflow_boundaries < 0:
		return false
	var settings_after := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	print("W239_FATHER_ALIVE_OK paths=%d ballpoint=%d silent=%d ingress=%d homes=%d same_key=1 intro_v4=%d result_v4=%d legacy_v4=%d cold_ink=%d reflows=%d reflow_ink=%d" % [
		paths, live_ink, silent_results, ingress_contexts, housing_contexts,
		intro_cold, cold_boundaries, legacy_boundaries, _w239_cold_ink,
		reflow_boundaries, _w239_reflow_ink])
	var counts_ok := paths == 15 and live_ink == 5 and silent_results == 10 \
		and ingress_contexts == 6 and housing_contexts == 7 \
		and intro_cold == 3 and cold_boundaries == 6 \
		and legacy_boundaries == 2 and _w239_cold_ink == 1 \
		and reflow_boundaries == 4 and _w239_reflow_ink == 1 \
		and settings_before == settings_after
	if not counts_ok:
		_fail("W239 dynamic fixture population or master-volume state drifted")
	return counts_ok


func _w239_context_matches(trace_choice: int, remaining_choice: int) -> bool:
	var current: Dictionary = _story.get("_current")
	var raw_event: Dictionary = DataRegistry.find_event(W239_FATHER_ALIVE)
	var rows: Array = (
		raw_event.get("chapter5_finale_reads", {}) as Dictionary).get("texts", [])
	var sources := str(_story.call("_fmt", current.get("description", ""))).split("\n\n")
	var entry: Dictionary = GameState.chapter5_finale_entry_snapshot()
	var father: Dictionary = entry.get("father", {})
	var trace_receipt: Dictionary = CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_event(
		GameState.chapter5_finale_state, "arc_y5_father_trace_alive_exact")
	var remaining_receipt: Dictionary = CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_event(
		GameState.chapter5_finale_state, W238_REMAINING)
	if rows.size() != 2 or not rows[0] is Array or not rows[1] is Array \
			or (rows[0] as Array).size() != 3 or (rows[1] as Array).size() != 1 \
			or sources.size() != 4 \
			or str(sources[0]).strip_edges() != str(_story.call(
				"_fmt", (rows[0] as Array)[trace_choice])).strip_edges() \
			or str(sources[1]).strip_edges() != str(_story.call(
				"_fmt", (rows[1] as Array)[0])).strip_edges() \
			or int(trace_receipt.get("choice_index", -1)) != trace_choice \
			or int(remaining_receipt.get("choice_index", -1)) != remaining_choice \
			or str(father.get("life", "")) != "alive" \
			or GameState.chapter5_finale_next_event_for_turn() != W239_FATHER_ALIVE \
			or not GameState.chapter5_finale_ingress_available(W239_FATHER_ALIVE) \
			or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
			or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
			or not _w239_surface(
				"W239 exact ingress", _w235_current_home_background(), false) \
			or not _w239_audio_matches(false, "W239 exact ingress"):
		_fail("W239 lost its selected father/W238 receipts or real finale ingress")
		return false
	return true


func _w239_read_intro(home_background: String) -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	if int(_story.call("_story_source_paragraph_count")) != 4 \
			or pages.is_empty() or not _m23_same_prose(pages, authored):
		_fail("W239 lost its father/nontransaction rows plus two authored sources")
		return false
	var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
	var bed_position := BGMPlayer._ambience_player.get_playback_position()
	var untouched := _w227_state_bytes()
	var score_player: AudioStreamPlayer = null
	var score_stream: AudioStream = null
	var score_position := -1.0
	var score_token := -1
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		await _finish_page()
		var expect_score := source >= 1
		var current_bed_position := BGMPlayer._ambience_player.get_playback_position()
		if not _w239_surface(
				"W239 opening source%d" % source, home_background, expect_score) \
				or not _w239_audio_matches(false, "W239 opening source%d" % source) \
				or not _w227_state_matches(
					untouched, "W239 opening source%d" % source, false, "W239") \
				or BGMPlayer._ambience_player.stream != bed_stream \
				or current_bed_position + 0.05 < bed_position \
				or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
				or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty():
			_fail("W239 source%d restarted its bed or gained an early physical action" % source)
			return false
		bed_position = current_bed_position
		if expect_score:
			var current_score := _w239_grief_player()
			if not is_instance_valid(current_score):
				_fail("W239 source%d has no actual grief stream" % source)
				return false
			if score_player == null:
				score_player = current_score
				score_stream = current_score.stream
				score_position = current_score.get_playback_position()
				score_token = int(BGMPlayer.get("_punctuation_token"))
			elif not _w239_score_unchanged(
					score_player, score_stream, score_position, score_token,
					"W239 source%d" % source):
				return false
			else:
				score_position = current_score.get_playback_position()
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 3 \
		and _w239_surface("W239 choices", home_background, true) \
		and _w239_audio_matches(false, "W239 choices") \
		and _w227_state_matches(untouched, "W239 choices", false, "W239")


func _w239_prepare_result(
		language: String, choice: int, home_case: Dictionary,
		trace_choice: int = 0, remaining_choice: int = 0) -> bool:
	var home_background := str(home_case.get("background", ""))
	if not await _w239_open(
			language, home_case, trace_choice, remaining_choice) \
			or not await _w239_read_intro(home_background):
		return false
	_w239_clear_tracked()
	_story.call("_on_choice", choice)
	_story.set_process(false)
	await _wait_stable()
	return _w239_result_layout(choice) \
		and GameState.chapter5_finale_receipt_matches(
			W239_FATHER_ALIVE, choice, 239) \
		and _w239_surface("W239 prepared result", home_background, true) \
		and _w239_audio_matches(false, "W239 prepared result")


func _w239_result_layout(choice: int) -> bool:
	var pages: Array = _story.get("_paragraphs")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choice < 0 or choice >= choices.size() or pages.is_empty():
		return false
	var authored := str(_story.call(
		"_fmt", (choices[choice] as Dictionary).get("result_text", "")))
	var expected_sources: Array[int] = [2, 1, 2]
	var mapping := _w239_pen_mapping()
	var action_ok := mapping.is_empty()
	if choice == 2 and not mapping.is_empty():
		var page_index := int(mapping.get("page", -1))
		var contract: Dictionary = _story.call(
			"_physical_cue_contract", page_index)
		var expected_anchor := str(_story.call("_fmt", str(
			W239_ALIVE_NAME_WRITE.get_meta(
				"write_anchors", {}).get(LocaleManager.language, ""))))
		action_ok = int(mapping.get("source", -1)) == 0 \
			and int(contract.get("source_index", -1)) == 0 \
			and str(contract.get("anchor", "")) == expected_anchor \
			and is_equal_approx(float(contract.get("volume_db", 0.0)), -7.0) \
			and str(contract.get("sfx", "")) == "pen_ballpoint"
	if choices.size() != 3 \
			or int(_story.call("_story_source_paragraph_count")) != expected_sources[choice] \
			or not _m23_same_prose(pages, authored) \
			or int(_story.get("_result_location_cut_page")) >= 0 \
			or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
			or not action_ok:
		_fail("W239 choice%d lost its exact c2/source0 physical contract" % choice)
		return false
	return true


func _w239_pen_mapping() -> Dictionary:
	var found: Array[Dictionary] = []
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		var source_index := int(_story.call(
			"_story_source_paragraph_index", page_index))
		var page := str((_story.get("_paragraphs") as Array)[page_index])
		var reveal := int(_story.call(
			"_w239_pen_reveal_position", page, page_index))
		if reveal > 0:
			found.append({
				"page": page_index, "reveal": reveal, "source": source_index})
	return found[0] if found.size() == 1 else {}


func _w239_seek_pen_page(
		applied: String, allow_default_name_projection: bool = false) -> bool:
	var mapping := _w239_pen_mapping()
	var target := int(mapping.get("page", -1))
	while int(_story.get("_para_index")) < target:
		await _finish_page()
		if not _w227_state_matches(
				applied, "W239 before name-write page",
				allow_default_name_projection, "W239") \
				or not _w239_audio_matches(false, "W239 before name-write page"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		mapping = _w239_pen_mapping()
		target = int(mapping.get("page", -1))
	if target < 0 or int(_story.get("_para_index")) != target \
			or int(_story.get("_w239_pen_reveal_at")) != int(
				mapping.get("reveal", -2)):
		_fail("W239 did not settle on its exact name-write clause page")
		return false
	return true


func _w239_boundary_side(before_pen: bool) -> bool:
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != 2 \
			or int(_story.call(
				"_story_source_paragraph_index", int(_story.get("_para_index")))) != 0:
		return false
	var pen_range: Vector2 = _story.call("_w239_pen_progress_range")
	var context: Dictionary = _story.call("build_save_resume_context")
	var progress := float(context.get("source_text_progress", -1.0))
	if pen_range.x < 0.0 or pen_range.y < pen_range.x:
		return false
	if before_pen:
		return not bool(_story.get("_w239_pen_consumed")) \
			and int(_story.get("_w239_pen_reveal_at")) > int(
				_story.get("_type_pos")) \
			and progress <= pen_range.x + 0.00001
	return bool(_story.get("_w239_pen_consumed")) \
		and int(_story.get("_w239_pen_reveal_at")) < 0 \
		and progress >= pen_range.y - 0.00001


func _w239_finish_result(applied: String, played_at: int) -> bool:
	var score_player := _w239_grief_player()
	if not is_instance_valid(score_player):
		_fail("W239 result started without its held grief score")
		return false
	var score_stream: AudioStream = score_player.stream
	var score_position := score_player.get_playback_position()
	var score_token := int(BGMPlayer.get("_punctuation_token"))
	while true:
		await _finish_page()
		if not _w239_surface(
				"W239 result", _w235_current_home_background(), true) \
				or not _w227_state_matches(
					applied, "W239 result", false, "W239") \
				or not _w239_audio_matches(
					played_at >= 0, "W239 result") \
				or int(AudioManager._last_sfx_ms.get(
					"pen_ballpoint", -1)) != played_at \
				or not _w239_score_unchanged(
					score_player, score_stream, score_position, score_token,
					"W239 result"):
			_fail("W239 result replayed an action or restarted its score")
			return false
		score_position = score_player.get_playback_position()
		if int(_story.get("_para_index")) >= (
				_story.get("_paragraphs") as Array).size() - 1:
			return true
		_story.call("_on_advance")
		await _wait_stable()
	return false


func _w239_surface(label: String, background_id: String, expect_score: bool) -> bool:
	var expected_stream: AudioStream = BGMPlayer.call("_load_ambience", "apartment")
	if str((_story.get("_current") as Dictionary).get("id", "")) != W239_FATHER_ALIVE \
			or background_id.is_empty() \
			or not _expect_surface(background_id, "apartment", label) \
			or str(_story.call("_resolved_story_surface_portrait_id")) != "player_tired" \
			or expected_stream == null \
			or BGMPlayer._ambience_player.stream != expected_stream \
			or not BGMPlayer._ambience_player.playing \
			or not str(BGMPlayer.get("_current_human_ambience_key")).is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or not str(BGMPlayer.get("_current_season_key")).is_empty() \
			or BGMPlayer._season_player.playing:
		_fail(label + " changed the W239 home, apartment bed, portrait, or lower-layer silence")
		return false
	if expect_score:
		if not is_instance_valid(_w239_grief_player()) \
				or str(BGMPlayer.get("_current_key")) != "grief":
			_fail(label + " lost the W239 held grief score")
			return false
	elif not str(BGMPlayer.get("_current_key")).is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail(label + " opened W239 grief before source1")
		return false
	return true


func _w239_grief_player() -> AudioStreamPlayer:
	var expected: AudioStream = BGMPlayer.call("_load_track", "grief")
	for player: AudioStreamPlayer in [BGMPlayer._player_a, BGMPlayer._player_b]:
		if expected != null and player.playing and player.stream == expected:
			return player
	return null


func _w239_score_unchanged(player: AudioStreamPlayer, stream: AudioStream,
		previous_position: float, token: int, label: String) -> bool:
	var current := _w239_grief_player()
	if current != player or not is_instance_valid(current) \
			or current.stream != stream \
			or int(BGMPlayer.get("_punctuation_token")) != token \
			or current.get_playback_position() + 0.05 < previous_position:
		_fail(label + " restarted or replaced the held grief stream")
		return false
	return true


func _w239_clear_tracked() -> void:
	for sound_id: String in W239_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)


func _w239_audio_matches(
		expect_pen: bool, label: String, require_stream: bool = false) -> bool:
	var cue_keys: Array = AudioManager._story_audio_seen.keys().filter(
		func(key: Variant) -> bool:
			return str(key).begins_with(W239_FATHER_ALIVE + ":"))
	var invalid: Array[String] = []
	for sound_id: String in W239_TRACKED_SFX:
		var expected := expect_pen and sound_id == "pen_ballpoint"
		var stream_count := _w197_sfx_stream_count(sound_id)
		if AudioManager._last_sfx_ms.has(sound_id) != expected \
				or (not expected and stream_count != 0) \
				or (expected and require_stream and stream_count != 1):
			invalid.append(sound_id)
	if not cue_keys.is_empty() or not invalid.is_empty():
		_fail("%s W239 audio mismatch pen=%s invalid=%s cues=%s" % [
			label, expect_pen, invalid, cue_keys])
		return false
	if require_stream and expect_pen:
		var expected_db := float(AudioManager.call("_vol_db")) \
			+ AudioManager.sfx_mix_trim_db("pen_ballpoint") - 7.0
		for player: AudioStreamPlayer in AudioManager._pool:
			if player.playing \
					and player.stream == AudioManager._sounds.get("pen_ballpoint"):
				if is_equal_approx(player.volume_db, expected_db):
					return true
				_fail("%s W239 ballpoint volume expected=%s actual=%s" % [
					label, expected_db, player.volume_db])
				return false
		_fail(label + " W239 ballpoint stream was not active")
		return false
	return true


func _w239_wait_ballpoint_completion(played_at: int) -> bool:
	var stream: AudioStream = AudioManager._sounds.get("pen_ballpoint")
	if stream == null or played_at < 0:
		_fail("W239 cannot derive the recorded ballpoint completion boundary")
		return false
	var duration_msec := int(ceil(stream.get_length() * 1000.0))
	var deadline := Time.get_ticks_msec() + maxi(250, duration_msec + 250)
	while _w197_sfx_stream_count("pen_ballpoint") > 0 \
			and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	if _w197_sfx_stream_count("pen_ballpoint") != 0 \
			or int(AudioManager._last_sfx_ms.get(
				"pen_ballpoint", -1)) != played_at:
		_fail("W239 ballpoint did not finish naturally without replay")
		return false
	return true


func _w239_intro_cold_matrix(home_case: Dictionary) -> int:
	var restored_cases := 0
	for spec: Dictionary in [
		{"phase": "prose", "source": 0, "locale": "ko"},
		{"phase": "prose", "source": 1, "locale": "en"},
		{"phase": "choices", "source": 3, "locale": "ko"},
	]:
		if not await _w239_open("ko", home_case):
			return -1
		var phase := str(spec.get("phase", ""))
		var source_index := int(spec.get("source", -1))
		if phase == "choices":
			if not await _w239_read_intro(str(home_case.get("background", ""))):
				return -1
		elif not await _w239_advance_to_source(source_index):
			return -1
		if phase == "prose":
			var page_length := str(_story.get("_type_full")).length()
			if not _w227_type_to(
					maxi(1, floori(float(page_length) / 2.0)), "W239"):
				return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		var applied := _w227_state_bytes()
		var target_locale := str(spec.get("locale", "ko"))
		var cross_locale := target_locale != LocaleManager.language
		_w239_clear_tracked()
		if not await _w239_cold_load(
				context, target_locale, applied, cross_locale,
				"W239 cold " + phase):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		var expect_score := phase != "prose" or source_index >= 1
		if str(restored.get("phase", "")) != phase \
				or (phase != "choices" and int(restored.get(
					"source_paragraph_index", -1)) != source_index) \
				or (phase != "choices" and not _w238_progress_matches(
					context, restored, source_index, cross_locale)) \
				or not _w239_surface(
					"W239 cold " + phase,
					_w235_current_home_background(), expect_score) \
				or not _w239_audio_matches(false, "W239 cold " + phase) \
				or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
				or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty():
			_fail("W239 cold %s changed source progress, score, or action silence" % phase)
			return -1
		if phase == "prose" and source_index == 0:
			if not await _w239_advance_to_source(1) \
					or not _w239_surface(
						"W239 cold future grief",
						_w235_current_home_background(), true) \
					or not _w239_audio_matches(
						false, "W239 cold future grief") \
					or not _w227_state_matches(
						applied, "W239 cold future grief",
						cross_locale, "W239"):
				_fail("W239 cold source0 did not retain its future source1 grief entrance")
				return -1
		restored_cases += 1
	return restored_cases


func _w239_result_cold_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for before_pen: bool in [true, false]:
		if not await _w239_prepare_result("ko", 2, home_case):
			return -1
		var applied := _w227_state_bytes()
		if not await _w239_seek_pen_page(applied):
			return -1
		var reveal := int(_story.get("_w239_pen_reveal_at"))
		if not _w227_type_to(reveal - 1 if before_pen else reveal, "W239"):
			return -1
		if not before_pen:
			var played_at := int(AudioManager._last_sfx_ms.get(
				"pen_ballpoint", -1))
			if played_at < 0 or not await _w239_wait_ballpoint_completion(played_at):
				return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		_w239_clear_tracked()
		if not await _w239_cold_load(
				context, "ko", applied, false, "W239 cold result"):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		if str(restored.get("phase", "")) != "result" \
				or int(restored.get("pending_result_choice_index", -1)) != 2 \
				or int(restored.get("source_paragraph_index", -1)) != 0 \
				or not _w238_progress_matches(context, restored, 0, false) \
				or not _w239_boundary_side(before_pen) \
				or not _w239_surface(
					"W239 cold result", _w235_current_home_background(), true) \
				or not _w239_audio_matches(false, "W239 cold result"):
			_fail("W239 same-locale cold result crossed or replayed its name boundary")
			return -1
		if before_pen:
			var restored_reveal := int(_story.get("_w239_pen_reveal_at"))
			if not _w227_type_to(restored_reveal, "W239") \
					or not _w239_audio_matches(
						true, "W239 cold remaining name-write", true):
				_fail("W239 cold unread same-locale clause lost its one ballpoint")
				return -1
			var cold_played_at := int(AudioManager._last_sfx_ms.get(
				"pen_ballpoint", -1))
			if not await _w239_wait_ballpoint_completion(cold_played_at):
				return -1
			_w239_cold_ink += 1
		else:
			_story.call("_complete_typing")
			_story.call("_complete_typing")
			if not _w239_audio_matches(false, "W239 cold consumed completion"):
				return -1
		boundaries += 1

	if not await _w239_prepare_result("ko", 2, home_case):
		return -1
	var cross_state := _w227_state_bytes()
	if not await _w239_seek_pen_page(cross_state):
		return -1
	var cross_reveal := int(_story.get("_w239_pen_reveal_at"))
	if not _w227_type_to(cross_reveal - 1, "W239"):
		return -1
	var cross_context: Dictionary = _story.call("build_save_resume_context")
	_w239_clear_tracked()
	if not await _w239_cold_load(
			cross_context, "en", cross_state, true, "W239 cross-locale result"):
		return -1
	var cross_restored: Dictionary = _story.call("build_save_resume_context")
	if int(cross_restored.get("source_paragraph_index", -1)) != 0 \
			or not _w238_progress_matches(
				cross_context, cross_restored, 0, true) \
			or not bool(_story.get("_w239_pen_consumed")) \
			or int(_story.get("_w239_pen_reveal_at")) >= 0 \
			or not _w239_audio_matches(false, "W239 cross-locale result"):
		_fail("W239 cross-locale current result replayed an unprovable name action")
		return -1
	_story.call("_complete_typing")
	_story.call("_complete_typing")
	if not _w239_audio_matches(false, "W239 cross-locale completion"):
		return -1
	boundaries += 1

	if not await _w239_prepare_result("ko", 2, home_case):
		return -1
	var source1_state := _w227_state_bytes()
	if not await _w239_advance_to_source(1, true):
		return -1
	var source1_played_at := int(AudioManager._last_sfx_ms.get(
		"pen_ballpoint", -1))
	if source1_played_at < 0 \
			or not await _w239_wait_ballpoint_completion(source1_played_at):
		return -1
	var source1_length := str(_story.get("_type_full")).length()
	if not _w227_type_to(
			maxi(1, floori(float(source1_length) / 2.0)), "W239"):
		return -1
	var source1_context: Dictionary = _story.call("build_save_resume_context")
	_w239_clear_tracked()
	if not await _w239_cold_load(
			source1_context, "ko", source1_state, false, "W239 cold source1 result"):
		return -1
	var source1_restored: Dictionary = _story.call("build_save_resume_context")
	if int(source1_restored.get("source_paragraph_index", -1)) != 1 \
			or not _w238_progress_matches(
				source1_context, source1_restored, 1, false) \
			or not bool(_story.get("_w239_pen_consumed")) \
			or int(_story.get("_w239_pen_reveal_at")) >= 0 \
			or not _w239_audio_matches(false, "W239 cold source1 result"):
		_fail("W239 cold source1 replayed its completed source0 name action")
		return -1
	boundaries += 1

	for silent_choice in [0, 1]:
		if not await _w239_prepare_result("ko", silent_choice, home_case):
			return -1
		var silent_state := _w227_state_bytes()
		var silent_length := str(_story.get("_type_full")).length()
		if not _w227_type_to(
				maxi(1, floori(float(silent_length) / 2.0)), "W239"):
			return -1
		var silent_context: Dictionary = _story.call("build_save_resume_context")
		_w239_clear_tracked()
		if not await _w239_cold_load(
				silent_context, "ko", silent_state, false,
				"W239 cold silent c%d" % silent_choice):
			return -1
		if int((_story.call("build_save_resume_context") as Dictionary).get(
				"pending_result_choice_index", -1)) != silent_choice \
				or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
				or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
				or not _w239_audio_matches(
					false, "W239 cold silent c%d" % silent_choice):
			_fail("W239 cold c%d invented a physical action" % silent_choice)
			return -1
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if not _w239_audio_matches(
				false, "W239 cold silent completion c%d" % silent_choice):
			return -1
		boundaries += 1
	return boundaries


func _w239_legacy_cold_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for before_pen: bool in [true, false]:
		if not await _w239_prepare_result("ko", 2, home_case):
			return -1
		var applied := _w227_state_bytes()
		if not await _w239_seek_pen_page(applied):
			return -1
		var reveal := int(_story.get("_w239_pen_reveal_at"))
		if not _w227_type_to(reveal - 1 if before_pen else reveal, "W239"):
			return -1
		if not before_pen:
			var played_at := int(AudioManager._last_sfx_ms.get(
				"pen_ballpoint", -1))
			if played_at < 0 or not await _w239_wait_ballpoint_completion(played_at):
				return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		if before_pen:
			context.erase("story_locale")
		else:
			context.erase("source_paragraph_index")
			context.erase("source_text_progress")
		_w239_clear_tracked()
		if not await _w239_cold_load(
				context, "ko", applied, false,
				"W239 legacy %s" % ("before" if before_pen else "after")):
			return -1
		if not bool(_story.get("_w239_pen_consumed")) \
				or int(_story.get("_w239_pen_reveal_at")) >= 0 \
				or not _w239_surface(
					"W239 legacy result", _w235_current_home_background(), true) \
				or not _w239_audio_matches(false, "W239 legacy result"):
			_fail("W239 legacy result replayed an action without source/locale proof")
			return -1
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if not _w239_audio_matches(false, "W239 legacy completion"):
			return -1
		boundaries += 1
	return boundaries


func _w239_reflow_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for before_pen: bool in [true, false]:
		if not await _w239_prepare_result("ko", 2, home_case):
			return -1
		var applied := _w227_state_bytes()
		if not await _w239_seek_pen_page(applied):
			return -1
		var reveal := int(_story.get("_w239_pen_reveal_at"))
		if not _w227_type_to(reveal - 1 if before_pen else reveal, "W239"):
			return -1
		if not before_pen:
			var played_at := int(AudioManager._last_sfx_ms.get(
				"pen_ballpoint", -1))
			if played_at < 0 or not await _w239_wait_ballpoint_completion(played_at):
				return -1
		_w239_clear_tracked()
		var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
		var bed_position := BGMPlayer._ambience_player.get_playback_position()
		var score_player := _w239_grief_player()
		if not is_instance_valid(score_player):
			return -1
		var score_stream: AudioStream = score_player.stream
		var score_position := score_player.get_playback_position()
		var score_token := int(BGMPlayer.get("_punctuation_token"))
		_story.call("_set_story_text_size", "large")
		await _wait_stable()
		if not _w239_reflow_state(
				before_pen, applied, false, bed_stream, bed_position,
				score_player, score_stream, score_position, score_token,
				"font"):
			return -1
		boundaries += 1
		bed_position = BGMPlayer._ambience_player.get_playback_position()
		score_position = score_player.get_playback_position()
		_story.call("_set_story_language", "en")
		await _wait_stable()
		if LocaleManager.language != "en" \
				or not _w239_reflow_state(
					before_pen, applied, true, bed_stream, bed_position,
					score_player, score_stream, score_position, score_token,
					"locale"):
			return -1
		boundaries += 1
		if before_pen:
			var localized_reveal := int(_story.get("_w239_pen_reveal_at"))
			if localized_reveal <= 0 \
					or not _w227_type_to(localized_reveal, "W239") \
					or not _w239_audio_matches(
						true, "W239 reflow remaining name-write", true):
				_fail("W239 hot reflow lost its remaining localized ballpoint")
				return -1
			var reflow_played_at := int(AudioManager._last_sfx_ms.get(
				"pen_ballpoint", -1))
			if not await _w239_wait_ballpoint_completion(reflow_played_at):
				return -1
			_w239_reflow_ink += 1
		else:
			_story.call("_complete_typing")
			_story.call("_complete_typing")
			if not _w239_audio_matches(false, "W239 reflow consumed completion"):
				return -1
	return boundaries


func _w239_reflow_state(
		before_pen: bool, applied: String, allow_default_name_projection: bool,
		bed_stream: AudioStream, bed_position: float,
		score_player: AudioStreamPlayer, score_stream: AudioStream,
		score_position: float, score_token: int, label: String) -> bool:
	if not _w239_boundary_side(before_pen) \
			or BGMPlayer._ambience_player.stream != bed_stream \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < bed_position \
			or not _w227_state_matches(
				applied, "W239 " + label + " reflow",
				allow_default_name_projection, "W239") \
			or not _w239_surface(
				"W239 " + label + " reflow",
				_w235_current_home_background(), true) \
			or not _w239_audio_matches(false, "W239 " + label + " reflow") \
			or not _w239_score_unchanged(
				score_player, score_stream, score_position, score_token,
				"W239 " + label + " reflow"):
		_fail("W239 %s reflow crossed its action or restarted bed/score" % label)
		return false
	return true


func _w239_advance_to_source(
		target_source: int, result_phase: bool = false) -> bool:
	for _guard in range(64):
		if bool(_story.get("_showing_choices")) and not result_phase:
			break
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		if source == target_source:
			return true
		if source > target_source:
			break
		await _finish_page()
		if int(_story.get("_para_index")) >= (
				_story.get("_paragraphs") as Array).size() - 1:
			break
		_story.call("_on_advance")
		await _wait_stable()
	_fail("W239 could not advance to %s source%d" % [
		"result" if result_phase else "prose", target_source])
	return false


func _w239_cold_load(context: Dictionary, target_locale: String,
		applied: String, allow_default_name_projection: bool,
		label: String, owner: String = "W239") -> bool:
	if not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail(label + " could not write isolated v4 save")
		return false
	var disk: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int((disk as Dictionary).get("version", -1)) != 4:
		_fail(label + " lost disk schema v4")
		return false
	await _remove_story()
	await _stop_audio()
	GameState.start_new_game()
	LocaleManager.set_language(target_locale)
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail(label + " could not cold-load its source position")
		return false
	BGMPlayer.set_ambience("room")
	BGMPlayer.set_season_ambience("winter")
	BGMPlayer.play_punctuation("reckoning")
	_w239_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	await get_tree().create_timer(0.9).timeout
	return _w227_state_matches(
		applied, label, allow_default_name_projection, owner)


func _check_w240_general_signature() -> bool:
	_w240_cold_ink = 0
	_w240_reflow_ink = 0
	var default_home: Dictionary = W235_HOME_CASES[1]
	var settings_before := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	var paths := 0
	var live_ink := 0
	var outbound_continuity := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice in range(2):
			if not await _w240_prepare_result(
					language, choice, default_home, choice):
				return false
			var applied := _w227_state_bytes()
			if not await _w240_seek_pen_page(applied):
				return false
			var reveal := int(_story.get("_w240_general_pen_reveal_at"))
			if reveal <= 0 or not _w227_type_to(reveal - 1, "W240") \
					or not _w240_boundary_side(true) \
					or not _w240_audio_matches(
						false, "W240 before exact write clause"):
				_fail("W240 %s/c%d sounded before its exact clause" % [
					language, choice])
				return false
			if not _w227_type_to(reveal, "W240"):
				return false
			var played_at := int(AudioManager._last_sfx_ms.get(
				"pen_ballpoint", -1))
			if played_at < 0 or not _w240_boundary_side(false) \
					or not _w240_audio_matches(
						true, "W240 exact write clause", true) \
					or not await _w240_finish_result(applied, played_at) \
					or not await _w237_wait_sfx_completion(
						"pen_ballpoint", played_at, "W240 live write"):
				_fail("W240 %s/c%d lost its one exact pen action" % [
					language, choice])
				return false
			if outbound_continuity == 0:
				if not await _w240_outbound_continuity():
					return false
				outbound_continuity += 1
			live_ink += 1
			paths += 1

	var ingress_receipts := 0
	for record_choice in range(2):
		if not await _w240_open("ko", default_home, record_choice) \
				or not _w240_context_matches(record_choice):
			return false
		ingress_receipts += 1

	var housing_contexts := 0
	for home_case: Dictionary in W235_HOME_CASES:
		if not await _w240_open("ko", home_case) \
				or not _w240_surface(
					"W240 housing " + str(home_case.get("id", "")),
					str(home_case.get("background", "")), false):
			return false
		housing_contexts += 1

	var apartment_case: Dictionary = W235_HOME_CASES[3]
	if not await _w240_open("ko", apartment_case, 0, true):
		return false
	await get_tree().create_timer(1.5).timeout
	if not _w240_surface(
			"W240 same-key settled bed", "gangnam_apartment", false) \
			or BGMPlayer._ambience_tween != null \
			and BGMPlayer._ambience_tween.is_running() \
			or not is_equal_approx(
				BGMPlayer._ambience_player.volume_db,
				float(BGMPlayer.call("_ambience_target_db"))):
		_fail("W240 inherited fade stopped or kept ducking its fresh bed")
		return false

	var intro_cold := await _w240_intro_cold_matrix(default_home)
	if intro_cold < 0:
		return false
	var cold_boundaries := await _w240_result_cold_matrix(default_home)
	if cold_boundaries < 0:
		return false
	var legacy_boundaries := await _w240_legacy_cold_matrix(default_home)
	if legacy_boundaries < 0:
		return false
	var reflow_boundaries := await _w240_reflow_matrix(default_home)
	if reflow_boundaries < 0:
		return false
	var settings_after := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	print("W240_GENERAL_SIGNATURE_OK paths=%d ink=%d ingress=%d homes=%d same_key=1 intro_v4=%d result_v4=%d legacy_v4=%d cold_ink=%d reflows=%d reflow_ink=%d outbound=%d" % [
		paths, live_ink, ingress_receipts, housing_contexts, intro_cold,
		cold_boundaries, legacy_boundaries, _w240_cold_ink,
		reflow_boundaries, _w240_reflow_ink, outbound_continuity])
	var counts_ok := paths == 10 and live_ink == 10 \
		and ingress_receipts == 2 and housing_contexts == 7 \
		and intro_cold == 3 and cold_boundaries == 8 \
		and legacy_boundaries == 4 and _w240_cold_ink == 2 \
		and reflow_boundaries == 8 and _w240_reflow_ink == 2 \
		and outbound_continuity == 1 and settings_before == settings_after
	if not counts_ok:
		_fail("W240 fixture population or master-volume state drifted")
	return counts_ok


func _w240_open(language: String, home_case: Dictionary,
		record_choice: int = 0, prime_same_key: bool = false) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W240/%s/r%d" % [
		language, str(home_case.get("id", "home")), record_choice]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	SaveManager.set_setting("story_text_size", "standard")
	if not _prepare_full_owner_history(240, [
			[203, "arc_minseo_03_arrival", 1],
			[211, "arc_y5_general_name_boundary_exact", 0],
			[220, "arc_y5_general_debt_memory_reconnect", 0],
		]):
		return false
	GameState.money = 2_500_000_000.0
	GameState.housing = str(home_case.get("housing", "oneroom"))
	for flag_id: String in ["arc_daeun_wedding_day_seen", "daeun_divorced"]:
		GameState.flags.erase(flag_id)
	var home_flags: Dictionary = home_case.get("flags", {})
	for flag_id: String in home_flags:
		GameState.flags[flag_id] = bool(home_flags[flag_id])
	GameState.flags["father_passed"] = true
	GameState.flags["arc_endgame_sixmonths_seen"] = true
	var final_calendar := [GameState.turn, GameState.age, GameState.year,
		GameState.month, GameState.week_of_month]
	GameState.turn = 224
	if not GameState.prepare_chapter5_finale_route_entry():
		_fail("W240 could not lock its real general finale entry")
		return false
	var predecessors: Array = [
		["arc_y5_general_father_legacy_voice_exact", 1, 224],
		["arc_y5_general_debt_memory_voice_exact", 0, 229],
		["arc_y5_general_pre_ending_summit_exact", 1, 234],
		[W237_RECORD, record_choice, 237],
	]
	for predecessor: Array in predecessors:
		GameState.turn = int(predecessor[2])
		if GameState.chapter5_finale_next_event_for_turn() != str(predecessor[0]):
			_fail("W240 lost predecessor ingress %s" % predecessor[0])
			return false
		var committed: Dictionary = GameState.record_chapter5_finale_choice(
			str(predecessor[0]), int(predecessor[1]))
		if not bool(committed.get("ok", false)):
			_fail("W240 could not commit predecessor %s/c%d" % [
				predecessor[0], predecessor[1]])
			return false
	GameState.turn = int(final_calendar[0])
	GameState.age = int(final_calendar[1])
	GameState.year = int(final_calendar[2])
	GameState.month = int(final_calendar[3])
	GameState.week_of_month = int(final_calendar[4])
	if GameState.chapter5_finale_next_event_for_turn() != W240_GENERAL_SACRIFICE \
			or not GameState.chapter5_finale_ingress_available(
				W240_GENERAL_SACRIFICE):
		_fail("W240 predecessor receipts did not admit the exact signature root")
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
	ingress.set_meta("_screenshot_qa_static_surface", true)
	var routed := bool(ingress.call("_route_chapter5_finale_week"))
	ingress.free()
	if not routed or GameState.pending_story_queue != [W240_GENERAL_SACRIFICE] \
			or not FULL_STORY_FLOW.valid_session():
		_fail("W240 did not route through MainGame and FullStoryFlow")
		return false
	BGMPlayer.set_ambience("room")
	BGMPlayer.set_season_ambience("winter")
	BGMPlayer.play_punctuation("reckoning")
	if prime_same_key:
		BGMPlayer.set_ambience("apartment")
		BGMPlayer.duck_ambience(-12.0, 1.4)
		if str(BGMPlayer.get("_current_ambience_key")) != "apartment" \
				or not BGMPlayer._ambience_player.playing \
				or BGMPlayer._ambience_tween == null \
				or not BGMPlayer._ambience_tween.is_running():
			_fail("W240 same-key fixture did not seed its apartment fade")
			return false
	elif str(BGMPlayer.get("_current_ambience_key")) != "room" \
			or str(BGMPlayer.get("_current_human_ambience_key")) != "thin_wall" \
			or str(BGMPlayer.get("_current_season_key")) != "winter" \
			or not BGMPlayer._ambience_player.playing \
			or not BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._season_player.playing \
			or not _w216_score_playing():
		_fail("W240 fixture did not seed old room/layers/reckoning")
		return false
	_w240_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	return _w240_context_matches(record_choice) \
		and _w240_surface(
			"W240 live opening", str(home_case.get("background", "")), false) \
		and (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
		and (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
		and _w240_audio_matches(false, "W240 live opening")


func _w240_context_matches(record_choice: int) -> bool:
	var current: Dictionary = _story.get("_current")
	var raw_event: Dictionary = DataRegistry.find_event(W240_GENERAL_SACRIFICE)
	var rows: Array = (raw_event.get(
		"chapter5_finale_reads", {}) as Dictionary).get("texts", [])
	var sources := str(_story.call(
		"_fmt", current.get("description", ""))).split("\n\n")
	var receipt: Dictionary = CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_event(
		GameState.chapter5_finale_state, W237_RECORD)
	if rows.size() != 1 or not rows[0] is Array \
			or (rows[0] as Array).size() != 2 or sources.size() != 4 \
			or str(sources[0]).strip_edges() != str(_story.call(
				"_fmt", (rows[0] as Array)[record_choice])).strip_edges() \
			or int(receipt.get("choice_index", -1)) != record_choice \
			or str(GameState.chapter5_finale_entry_snapshot().get(
				"profile_id", "")) \
				!= CHAPTER5_FINALE_ROUTE.GENERAL_PROFILE_ID \
			or GameState.chapter5_finale_next_event_for_turn() \
				!= W240_GENERAL_SACRIFICE \
			or not GameState.chapter5_finale_ingress_available(
				W240_GENERAL_SACRIFICE) \
			or not FULL_STORY_FLOW.valid_session():
		_fail("W240 lost its actual record receipt or general-profile ingress")
		return false
	return true


func _w240_read_intro(home_background: String) -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	if int(_story.call("_story_source_paragraph_count")) != 4 \
			or pages.is_empty() or not _m23_same_prose(pages, authored):
		_fail("W240 lost its record receipt plus three authored sources")
		return false
	var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
	var bed_position := BGMPlayer._ambience_player.get_playback_position()
	var untouched := _w227_state_bytes()
	var score_player: AudioStreamPlayer = null
	var score_stream: AudioStream = null
	var score_position := -1.0
	var score_token := -1
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		await _finish_page()
		var expect_score := source >= 1
		var current_bed_position := BGMPlayer._ambience_player.get_playback_position()
		if not _w240_surface(
				"W240 opening source%d" % source, home_background, expect_score) \
				or not _w240_audio_matches(
					false, "W240 opening source%d" % source) \
				or not _w227_state_matches(
					untouched, "W240 opening source%d" % source, false, "W240") \
				or BGMPlayer._ambience_player.stream != bed_stream \
				or current_bed_position + 0.05 < bed_position \
				or not (_story.call(
					"_physical_cue_contract") as Dictionary).is_empty() \
				or not (_story.call(
					"_ballpoint_write_contract") as Dictionary).is_empty():
			_fail("W240 source%d restarted bed or gained an early action" % source)
			return false
		bed_position = current_bed_position
		if expect_score:
			var current_score := _w237_score_player()
			if not is_instance_valid(current_score):
				_fail("W240 source%d has no actual reckoning stream" % source)
				return false
			if score_player == null:
				score_player = current_score
				score_stream = current_score.stream
				score_position = current_score.get_playback_position()
				score_token = int(BGMPlayer.get("_punctuation_token"))
			elif not _w237_score_unchanged(
					score_player, score_stream, score_position, score_token,
					"W240 source%d" % source):
				return false
			else:
				score_position = current_score.get_playback_position()
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 2 \
		and _w240_surface("W240 choices", home_background, true) \
		and _w240_audio_matches(false, "W240 choices") \
		and _w227_state_matches(untouched, "W240 choices", false, "W240")


func _w240_prepare_result(
		language: String, choice: int, home_case: Dictionary,
		record_choice: int = 0) -> bool:
	var home_background := str(home_case.get("background", ""))
	if not await _w240_open(language, home_case, record_choice) \
			or not await _w240_read_intro(home_background):
		return false
	_w240_clear_tracked()
	_story.call("_on_choice", choice)
	_story.set_process(false)
	await _wait_stable()
	return _w240_result_layout(choice) \
		and GameState.chapter5_finale_receipt_matches(
			W240_GENERAL_SACRIFICE, choice, 240) \
		and _w240_surface("W240 prepared result", home_background, true) \
		and _w240_audio_matches(false, "W240 prepared result")


func _w240_result_layout(choice: int) -> bool:
	var pages: Array = _story.get("_paragraphs")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choice < 0 or choice >= choices.size() or pages.is_empty():
		return false
	var authored := str(_story.call(
		"_fmt", (choices[choice] as Dictionary).get("result_text", "")))
	var mapping := _w240_pen_mapping()
	var page_index := int(mapping.get("page", -1))
	var contract: Dictionary = _story.call("_physical_cue_contract", page_index)
	var rows: Dictionary = W240_GENERAL_SACRIFICE_WRITE.get_meta(
		"write_anchors", {})
	var locales: Dictionary = rows.get(str(choice), {})
	var expected_anchor := str(_story.call(
		"_fmt", str(locales.get(LocaleManager.language, ""))))
	var expected_gain := -5.0 if choice == 0 else -6.0
	if choices.size() != 2 \
			or int(_story.call("_story_source_paragraph_count")) != 2 \
			or not _m23_same_prose(pages, authored) \
			or int(mapping.get("source", -1)) != 0 \
			or int(contract.get("source_index", -1)) != 0 \
			or str(contract.get("anchor", "")) != expected_anchor \
			or not is_equal_approx(
				float(contract.get("volume_db", 0.0)), expected_gain) \
			or str(contract.get("sfx", "")) != "pen_ballpoint" \
			or not (_story.call(
				"_ballpoint_write_contract") as Dictionary).is_empty():
		_fail("W240 choice%d lost its exact source0 write contract" % choice)
		return false
	return true


func _w240_pen_mapping() -> Dictionary:
	var found: Array[Dictionary] = []
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		var source_index := int(_story.call(
			"_story_source_paragraph_index", page_index))
		var page := str((_story.get("_paragraphs") as Array)[page_index])
		var reveal := int(_story.call(
			"_w240_general_pen_reveal_position", page, page_index))
		if reveal > 0:
			found.append({
				"page": page_index, "reveal": reveal, "source": source_index})
	return found[0] if found.size() == 1 else {}


func _w240_seek_pen_page(
		applied: String, allow_default_name_projection: bool = false) -> bool:
	var mapping := _w240_pen_mapping()
	var target := int(mapping.get("page", -1))
	while int(_story.get("_para_index")) < target:
		await _finish_page()
		if not _w227_state_matches(
				applied, "W240 before write page",
				allow_default_name_projection, "W240") \
				or not _w240_audio_matches(false, "W240 before write page"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		mapping = _w240_pen_mapping()
		target = int(mapping.get("page", -1))
	if target < 0 or int(_story.get("_para_index")) != target \
			or int(_story.get("_w240_general_pen_reveal_at")) != int(
				mapping.get("reveal", -2)):
		_fail("W240 did not settle on its exact write-clause page")
		return false
	return true


func _w240_boundary_side(before_pen: bool) -> bool:
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) not in [0, 1] \
			or int(_story.call(
				"_story_source_paragraph_index", int(_story.get("_para_index")))) != 0:
		return false
	var pen_range: Vector2 = _story.call("_w240_general_pen_progress_range")
	var context: Dictionary = _story.call("build_save_resume_context")
	var progress := float(context.get("source_text_progress", -1.0))
	if pen_range.x < 0.0 or pen_range.y < pen_range.x:
		return false
	if before_pen:
		return not bool(_story.get("_w240_general_pen_consumed")) \
			and int(_story.get("_w240_general_pen_reveal_at")) > int(
				_story.get("_type_pos")) \
			and progress <= pen_range.x + 0.00001
	return bool(_story.get("_w240_general_pen_consumed")) \
		and int(_story.get("_w240_general_pen_reveal_at")) < 0 \
		and progress >= pen_range.y - 0.00001


func _w240_finish_result(applied: String, played_at: int) -> bool:
	var score_player := _w237_score_player()
	if not is_instance_valid(score_player):
		_fail("W240 result started without held reckoning")
		return false
	var score_stream: AudioStream = score_player.stream
	var score_position := score_player.get_playback_position()
	var score_token := int(BGMPlayer.get("_punctuation_token"))
	while true:
		await _finish_page()
		if not _w240_surface(
				"W240 result", _w235_current_home_background(), true) \
				or not _w227_state_matches(
					applied, "W240 result", false, "W240") \
				or not _w240_audio_matches(true, "W240 result") \
				or int(AudioManager._last_sfx_ms.get(
					"pen_ballpoint", -1)) != played_at \
				or not _w237_score_unchanged(
					score_player, score_stream, score_position, score_token,
					"W240 result"):
			_fail("W240 result replayed pen or restarted reckoning")
			return false
		score_position = score_player.get_playback_position()
		if int(_story.get("_para_index")) >= (
				_story.get("_paragraphs") as Array).size() - 1:
			return true
		_story.call("_on_advance")
		await _wait_stable()
	return false


func _w240_outbound_continuity() -> bool:
	var score_player := _w237_score_player()
	if not is_instance_valid(score_player):
		return false
	var score_stream: AudioStream = score_player.stream
	var score_position := score_player.get_playback_position()
	if score_position <= 0.15:
		_fail("W240 outbound proof did not observe established reckoning playback")
		return false
	_story.call("_on_advance")
	await _wait_stable()
	var current: Dictionary = _story.get("_current")
	var current_score := _w237_score_player()
	var transition: Dictionary = _story.get_meta(
		"story_transition_contract", {}) as Dictionary
	if str(current.get("id", "")) != "arc_y5_final_week_general_people_outbound" \
			or str(_story.get_meta("story_transition_mode", "")) != "same_location" \
			or str(transition.get("audio_policy", "")) != "continue" \
			or current_score != score_player \
			or not is_instance_valid(current_score) \
			or current_score.stream != score_stream \
			or current_score.get_playback_position() + 0.05 < score_position:
		_fail("W240 signature-to-outbound edge restarted its held score")
		return false
	return true


func _w240_surface(
		label: String, background_id: String, expect_score: bool) -> bool:
	var expected_stream: AudioStream = BGMPlayer.call("_load_ambience", "apartment")
	if str((_story.get("_current") as Dictionary).get("id", "")) \
			!= W240_GENERAL_SACRIFICE \
			or background_id.is_empty() \
			or not _expect_surface(background_id, "apartment", label) \
			or str(_story.call("_resolved_story_surface_portrait_id")) \
				!= "player_tired" \
			or expected_stream == null \
			or BGMPlayer._ambience_player.stream != expected_stream \
			or not BGMPlayer._ambience_player.playing \
			or not str(BGMPlayer.get("_current_human_ambience_key")).is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or not str(BGMPlayer.get("_current_season_key")).is_empty() \
			or BGMPlayer._season_player.playing:
		_fail(label + " changed W240 home, bed, portrait, or lower layers")
		return false
	if expect_score:
		if not is_instance_valid(_w237_score_player()) \
				or str(BGMPlayer.get("_current_key")) != "reckoning":
			_fail(label + " lost W240 held reckoning")
			return false
	elif not str(BGMPlayer.get("_current_key")).is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail(label + " opened W240 reckoning before source1")
		return false
	return true


func _w240_clear_tracked() -> void:
	for sound_id: String in W239_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)


func _w240_audio_matches(
		expect_pen: bool, label: String, require_stream: bool = false) -> bool:
	var cue_keys: Array = AudioManager._story_audio_seen.keys().filter(
		func(key: Variant) -> bool:
			return str(key).begins_with(W240_GENERAL_SACRIFICE + ":"))
	var invalid: Array[String] = []
	for sound_id: String in W239_TRACKED_SFX:
		var expected := expect_pen and sound_id == "pen_ballpoint"
		var stream_count := _w197_sfx_stream_count(sound_id)
		if AudioManager._last_sfx_ms.has(sound_id) != expected \
				or (not expected and stream_count != 0) \
				or (expected and require_stream and stream_count != 1):
			invalid.append(sound_id)
	if not cue_keys.is_empty() or not invalid.is_empty():
		_fail("%s W240 audio mismatch pen=%s invalid=%s cues=%s" % [
			label, expect_pen, invalid, cue_keys])
		return false
	if require_stream and expect_pen:
		var gain := -5.0 if int(_story.get(
			"_pending_result_choice_index")) == 0 else -6.0
		var expected_db := float(AudioManager.call("_vol_db")) \
			+ AudioManager.sfx_mix_trim_db("pen_ballpoint") + gain
		for player: AudioStreamPlayer in AudioManager._pool:
			if player.playing \
					and player.stream == AudioManager._sounds.get("pen_ballpoint"):
				if is_equal_approx(player.volume_db, expected_db):
					return true
				_fail("%s W240 ballpoint volume expected=%s actual=%s" % [
					label, expected_db, player.volume_db])
				return false
		_fail(label + " W240 ballpoint stream was not active")
		return false
	return true


func _w240_intro_cold_matrix(home_case: Dictionary) -> int:
	var restored_cases := 0
	for spec: Dictionary in [
		{"phase": "prose", "source": 0, "locale": "ko"},
		{"phase": "prose", "source": 1, "locale": "en"},
		{"phase": "choices", "source": 3, "locale": "ko"},
	]:
		if not await _w240_open("ko", home_case):
			return -1
		var phase := str(spec.get("phase", ""))
		var source_index := int(spec.get("source", -1))
		if phase == "choices":
			if not await _w240_read_intro(str(home_case.get("background", ""))):
				return -1
		elif not await _w239_advance_to_source(source_index):
			return -1
		if phase == "prose":
			var page_length := str(_story.get("_type_full")).length()
			if not _w227_type_to(
					maxi(1, floori(float(page_length) / 2.0)), "W240"):
				return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		var applied := _w227_state_bytes()
		var target_locale := str(spec.get("locale", "ko"))
		var cross_locale := target_locale != LocaleManager.language
		_w240_clear_tracked()
		if not await _w239_cold_load(
				context, target_locale, applied, cross_locale,
				"W240 cold " + phase, "W240"):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		var expect_score := phase != "prose" or source_index >= 1
		if str(restored.get("phase", "")) != phase \
				or (phase != "choices" and int(restored.get(
					"source_paragraph_index", -1)) != source_index) \
				or (phase != "choices" and not _w238_progress_matches(
					context, restored, source_index, cross_locale)) \
				or not _w240_surface(
					"W240 cold " + phase,
					_w235_current_home_background(), expect_score) \
				or not _w240_audio_matches(false, "W240 cold " + phase) \
				or not (_story.call(
					"_physical_cue_contract") as Dictionary).is_empty() \
				or not (_story.call(
					"_ballpoint_write_contract") as Dictionary).is_empty():
			_fail("W240 cold %s changed source progress, score, or silence" % phase)
			return -1
		if phase == "prose" and source_index == 0:
			if not await _w239_advance_to_source(1) \
					or not _w240_surface(
						"W240 cold future reckoning",
						_w235_current_home_background(), true) \
					or not _w240_audio_matches(
						false, "W240 cold future reckoning") \
					or not _w227_state_matches(
						applied, "W240 cold future reckoning",
						cross_locale, "W240"):
				_fail("W240 cold source0 lost its future source1 score")
				return -1
		restored_cases += 1
	return restored_cases


func _w240_result_cold_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for choice: int in [0, 1]:
		for before_pen: bool in [true, false]:
			if not await _w240_prepare_result("ko", choice, home_case):
				return -1
			var applied := _w227_state_bytes()
			if not await _w240_seek_pen_page(applied):
				return -1
			var reveal := int(_story.get("_w240_general_pen_reveal_at"))
			if not _w227_type_to(
					reveal - 1 if before_pen else reveal, "W240"):
				return -1
			if not before_pen:
				var played_at := int(AudioManager._last_sfx_ms.get(
					"pen_ballpoint", -1))
				if played_at < 0 or not await _w237_wait_sfx_completion(
						"pen_ballpoint", played_at,
						"W240 before cold save"):
					return -1
			var context: Dictionary = _story.call("build_save_resume_context")
			_w240_clear_tracked()
			if not await _w239_cold_load(
					context, "ko", applied, false,
					"W240 cold c%d result" % choice, "W240"):
				return -1
			var restored: Dictionary = _story.call("build_save_resume_context")
			if str(restored.get("phase", "")) != "result" \
					or int(restored.get(
						"pending_result_choice_index", -1)) != choice \
					or int(restored.get(
						"source_paragraph_index", -1)) != 0 \
					or not _w238_progress_matches(context, restored, 0, false) \
					or not _w240_boundary_side(before_pen) \
					or not _w240_surface(
						"W240 cold result",
						_w235_current_home_background(), true) \
					or not _w240_audio_matches(false, "W240 cold result"):
				_fail("W240 same-locale cold c%d crossed its pen boundary" % choice)
				return -1
			if before_pen:
				var restored_reveal := int(_story.get(
					"_w240_general_pen_reveal_at"))
				if not _w227_type_to(restored_reveal, "W240") \
						or not _w240_audio_matches(
							true, "W240 cold remaining write", true):
					_fail("W240 cold c%d lost its unread write action" % choice)
					return -1
				var cold_played_at := int(AudioManager._last_sfx_ms.get(
					"pen_ballpoint", -1))
				if not await _w237_wait_sfx_completion(
						"pen_ballpoint", cold_played_at,
						"W240 cold remaining write"):
					return -1
				_w240_cold_ink += 1
			else:
				_story.call("_complete_typing")
				_story.call("_complete_typing")
				if not _w240_audio_matches(
						false, "W240 cold consumed completion"):
					return -1
			boundaries += 1

	for choice: int in [0, 1]:
		if not await _w240_prepare_result("ko", choice, home_case):
			return -1
		var applied := _w227_state_bytes()
		if not await _w240_seek_pen_page(applied):
			return -1
		var reveal := int(_story.get("_w240_general_pen_reveal_at"))
		if not _w227_type_to(reveal - 1, "W240"):
			return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		_w240_clear_tracked()
		if not await _w239_cold_load(
				context, "en", applied, true,
				"W240 cross-locale c%d" % choice, "W240"):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		if int(restored.get("pending_result_choice_index", -1)) != choice \
				or int(restored.get("source_paragraph_index", -1)) != 0 \
				or not _w238_progress_matches(context, restored, 0, true) \
				or not bool(_story.get("_w240_general_pen_consumed")) \
				or int(_story.get("_w240_general_pen_reveal_at")) >= 0 \
				or not _w240_surface(
					"W240 cross-locale result",
					_w235_current_home_background(), true) \
				or not _w240_audio_matches(
					false, "W240 cross-locale result"):
			_fail("W240 cross-locale c%d replayed an unprovable write" % choice)
			return -1
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if not _w240_audio_matches(false, "W240 cross-locale completion"):
			return -1
		boundaries += 1

	for choice: int in [0, 1]:
		if not await _w240_prepare_result("ko", choice, home_case):
			return -1
		var applied := _w227_state_bytes()
		if not await _w239_advance_to_source(1, true):
			return -1
		var played_at := int(AudioManager._last_sfx_ms.get(
			"pen_ballpoint", -1))
		if played_at < 0 or not await _w237_wait_sfx_completion(
				"pen_ballpoint", played_at, "W240 before source1 save"):
			return -1
		var source_length := str(_story.get("_type_full")).length()
		if not _w227_type_to(
				maxi(1, floori(float(source_length) / 2.0)), "W240"):
			return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		_w240_clear_tracked()
		if not await _w239_cold_load(
				context, "ko", applied, false,
				"W240 cold source1 c%d" % choice, "W240"):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		if int(restored.get("pending_result_choice_index", -1)) != choice \
				or int(restored.get("source_paragraph_index", -1)) != 1 \
				or not _w238_progress_matches(context, restored, 1, false) \
				or not bool(_story.get("_w240_general_pen_consumed")) \
				or int(_story.get("_w240_general_pen_reveal_at")) >= 0 \
				or not _w240_surface(
					"W240 cold source1",
					_w235_current_home_background(), true) \
				or not _w240_audio_matches(false, "W240 cold source1"):
			_fail("W240 cold source1 c%d replayed source0 write" % choice)
			return -1
		boundaries += 1
	return boundaries


func _w240_legacy_cold_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for choice: int in [0, 1]:
		for before_pen: bool in [true, false]:
			if not await _w240_prepare_result("ko", choice, home_case):
				return -1
			var applied := _w227_state_bytes()
			if not await _w240_seek_pen_page(applied):
				return -1
			var reveal := int(_story.get("_w240_general_pen_reveal_at"))
			if not _w227_type_to(
					reveal - 1 if before_pen else reveal, "W240"):
				return -1
			if not before_pen:
				var played_at := int(AudioManager._last_sfx_ms.get(
					"pen_ballpoint", -1))
				if played_at < 0 or not await _w237_wait_sfx_completion(
						"pen_ballpoint", played_at,
						"W240 before legacy save"):
					return -1
			var context: Dictionary = _story.call("build_save_resume_context")
			if before_pen:
				context.erase("story_locale")
			else:
				context.erase("source_paragraph_index")
				context.erase("source_text_progress")
			_w240_clear_tracked()
			if not await _w239_cold_load(
					context, "ko", applied, false,
					"W240 legacy c%d/%s" % [
						choice, "before" if before_pen else "after"], "W240"):
				return -1
			if not bool(_story.get("_w240_general_pen_consumed")) \
					or int(_story.get("_w240_general_pen_reveal_at")) >= 0 \
					or not _w240_surface(
						"W240 legacy result",
						_w235_current_home_background(), true) \
					or not _w240_audio_matches(false, "W240 legacy result"):
				_fail("W240 legacy c%d replayed without source/locale proof" % choice)
				return -1
			_story.call("_complete_typing")
			_story.call("_complete_typing")
			if not _w240_audio_matches(false, "W240 legacy completion"):
				return -1
			boundaries += 1
	return boundaries


func _w240_reflow_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for choice: int in [0, 1]:
		for before_pen: bool in [true, false]:
			if not await _w240_prepare_result("ko", choice, home_case):
				return -1
			var applied := _w227_state_bytes()
			if not await _w240_seek_pen_page(applied):
				return -1
			var reveal := int(_story.get("_w240_general_pen_reveal_at"))
			if not _w227_type_to(
					reveal - 1 if before_pen else reveal, "W240"):
				return -1
			if not before_pen:
				var played_at := int(AudioManager._last_sfx_ms.get(
					"pen_ballpoint", -1))
				if played_at < 0 or not await _w237_wait_sfx_completion(
						"pen_ballpoint", played_at, "W240 before reflow"):
					return -1
			_w240_clear_tracked()
			var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
			var bed_position := BGMPlayer._ambience_player.get_playback_position()
			var score_player := _w237_score_player()
			if not is_instance_valid(score_player):
				return -1
			var score_stream: AudioStream = score_player.stream
			var score_position := score_player.get_playback_position()
			var score_token := int(BGMPlayer.get("_punctuation_token"))
			_story.call("_set_story_text_size", "large")
			await _wait_stable()
			if not _w240_reflow_state(
					before_pen, applied, false, bed_stream, bed_position,
					score_player, score_stream, score_position, score_token,
					"font"):
				return -1
			boundaries += 1
			bed_position = BGMPlayer._ambience_player.get_playback_position()
			score_position = score_player.get_playback_position()
			_story.call("_set_story_language", "en")
			await _wait_stable()
			if LocaleManager.language != "en" \
					or not _w240_reflow_state(
						before_pen, applied, true, bed_stream, bed_position,
						score_player, score_stream, score_position, score_token,
						"locale"):
				return -1
			boundaries += 1
			if before_pen:
				var localized_reveal := int(_story.get(
					"_w240_general_pen_reveal_at"))
				if localized_reveal <= 0 \
						or not _w227_type_to(localized_reveal, "W240") \
						or not _w240_audio_matches(
							true, "W240 reflow remaining write", true):
					_fail("W240 hot reflow lost c%d remaining write" % choice)
					return -1
				var reflow_played_at := int(AudioManager._last_sfx_ms.get(
					"pen_ballpoint", -1))
				if not await _w237_wait_sfx_completion(
						"pen_ballpoint", reflow_played_at,
						"W240 reflow remaining write"):
					return -1
				_w240_reflow_ink += 1
			else:
				_story.call("_complete_typing")
				_story.call("_complete_typing")
				if not _w240_audio_matches(
						false, "W240 reflow consumed completion"):
					return -1
	return boundaries


func _w240_reflow_state(
		before_pen: bool, applied: String,
		allow_default_name_projection: bool,
		bed_stream: AudioStream, bed_position: float,
		score_player: AudioStreamPlayer, score_stream: AudioStream,
		score_position: float, score_token: int, label: String) -> bool:
	if not _w240_boundary_side(before_pen) \
			or BGMPlayer._ambience_player.stream != bed_stream \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < bed_position \
			or not _w227_state_matches(
				applied, "W240 " + label + " reflow",
				allow_default_name_projection, "W240") \
			or not _w240_surface(
				"W240 " + label + " reflow",
				_w235_current_home_background(), true) \
			or not _w240_audio_matches(false, "W240 " + label + " reflow") \
			or not _w237_score_unchanged(
				score_player, score_stream, score_position, score_token,
				"W240 " + label + " reflow"):
		_fail("W240 %s reflow crossed pen or restarted bed/score" % label)
		return false
	return true


func _check_w239_father_passed() -> bool:
	_w239_passed_cold_paper = 0
	_w239_passed_reflow_paper = 0
	var default_home: Dictionary = W235_HOME_CASES[1]
	var settings_before := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	var paths := 0
	var live_paper := 0
	var silent_results := 0
	for language_index in range(LocaleManager.SUPPORTED_LANGUAGES.size()):
		var language: String = LocaleManager.SUPPORTED_LANGUAGES[language_index]
		for choice in range(3):
			if not await _w239_passed_prepare_result(
					language, choice, default_home,
					language_index % 3, language_index % 2):
				return false
			var applied := _w227_state_bytes()
			if choice in [0, 2]:
				if not await _w239_passed_seek_paper_page(applied):
					return false
				var reveal := int(_story.get("_w239_paper_reveal_at"))
				if reveal <= 0 or not _w227_type_to(reveal - 1, "W239P") \
						or not _w239_passed_boundary_side(true) \
						or not _w239_passed_audio_matches(
							false, "W239 passed before paper clause"):
					_fail("W239 passed %s/c%d sounded before its paper clause" % [
						language, choice])
					return false
				if not _w227_type_to(reveal, "W239P"):
					return false
				var played_at := int(AudioManager._last_sfx_ms.get(
					"paper_handle", -1))
				if played_at < 0 or not _w239_passed_boundary_side(false) \
						or not _w239_passed_audio_matches(
							true, "W239 passed exact paper clause", true) \
						or not await _w239_passed_finish_result(applied, played_at) \
						or not await _w237_wait_sfx_completion(
							"paper_handle", played_at, "W239 passed live paper"):
					_fail("W239 passed %s/c%d lost its one exact paper action" % [
						language, choice])
					return false
				live_paper += 1
			elif not await _w239_passed_finish_result(applied, -1):
				return false
			else:
				silent_results += 1
			paths += 1

	var ingress_contexts := 0
	for trace_choice in range(3):
		for remaining_choice in range(2):
			if not await _w239_passed_open(
					"ko", default_home, trace_choice, remaining_choice) \
					or not _w239_passed_context_matches(
						trace_choice, remaining_choice):
				return false
			ingress_contexts += 1

	var housing_contexts := 0
	for home_case: Dictionary in W235_HOME_CASES:
		if not await _w239_passed_open("ko", home_case) \
				or not _w239_passed_surface(
					"W239 passed housing " + str(home_case.get("id", "")),
					str(home_case.get("background", ""))):
			return false
		housing_contexts += 1

	var apartment_case: Dictionary = W235_HOME_CASES[3]
	if not await _w239_passed_open("ko", apartment_case, 0, 0, true):
		return false
	await get_tree().create_timer(1.5).timeout
	if not _w239_passed_surface(
			"W239 passed same-key settled bed", "gangnam_apartment") \
			or BGMPlayer._ambience_tween != null \
			and BGMPlayer._ambience_tween.is_running() \
			or not is_equal_approx(
				BGMPlayer._ambience_player.volume_db,
				float(BGMPlayer.call("_ambience_target_db"))):
		_fail("W239 passed inherited fade stopped or kept ducking its fresh bed")
		return false

	var intro_cold := await _w239_passed_intro_cold_matrix(default_home)
	if intro_cold < 0:
		return false
	var cold_boundaries := await _w239_passed_result_cold_matrix(default_home)
	if cold_boundaries < 0:
		return false
	var legacy_boundaries := await _w239_passed_legacy_cold_matrix(default_home)
	if legacy_boundaries < 0:
		return false
	var reflow_boundaries := await _w239_passed_reflow_matrix(default_home)
	if reflow_boundaries < 0:
		return false
	var settings_after := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	print("W239_FATHER_PASSED_OK paths=%d paper=%d silent=%d ingress=%d homes=%d same_key=1 intro_v4=%d result_v4=%d legacy_v4=%d cold_paper=%d reflows=%d reflow_paper=%d" % [
		paths, live_paper, silent_results, ingress_contexts, housing_contexts,
		intro_cold, cold_boundaries, legacy_boundaries,
		_w239_passed_cold_paper, reflow_boundaries, _w239_passed_reflow_paper])
	var counts_ok := paths == 15 and live_paper == 10 and silent_results == 5 \
		and ingress_contexts == 6 and housing_contexts == 7 \
		and intro_cold == 2 and cold_boundaries == 7 \
		and legacy_boundaries == 4 and _w239_passed_cold_paper == 2 \
		and reflow_boundaries == 8 and _w239_passed_reflow_paper == 2 \
		and settings_before == settings_after
	if not counts_ok:
		_fail("W239 passed fixture population or master-volume state drifted")
	return counts_ok


func _w239_passed_context_matches(trace_choice: int, remaining_choice: int) -> bool:
	var current: Dictionary = _story.get("_current")
	var raw_event: Dictionary = DataRegistry.find_event(W239_FATHER_PASSED)
	var rows: Array = (
		raw_event.get("chapter5_finale_reads", {}) as Dictionary).get("texts", [])
	var sources := str(_story.call("_fmt", current.get("description", ""))).split("\n\n")
	var entry: Dictionary = GameState.chapter5_finale_entry_snapshot()
	var trace_receipt: Dictionary = CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_event(
		GameState.chapter5_finale_state, "arc_y5_father_trace_passed_exact")
	var remaining_receipt: Dictionary = CHAPTER5_FINALE_ROUTE.receipt_snapshot_for_event(
		GameState.chapter5_finale_state, W238_REMAINING)
	if rows.size() != 2 or not rows[0] is Array or not rows[1] is Array \
			or (rows[0] as Array).size() != 3 or (rows[1] as Array).size() != 1 \
			or sources.size() != 4 \
			or str(sources[0]).strip_edges() != str(_story.call(
				"_fmt", (rows[0] as Array)[trace_choice])).strip_edges() \
			or str(sources[1]).strip_edges() != str(_story.call(
				"_fmt", (rows[1] as Array)[0])).strip_edges() \
			or int(trace_receipt.get("choice_index", -1)) != trace_choice \
			or int(remaining_receipt.get("choice_index", -1)) != remaining_choice \
			or str(entry.get("father", {}).get("life", "")) != "passed" \
			or GameState.chapter5_finale_next_event_for_turn() != W239_FATHER_PASSED \
			or not GameState.chapter5_finale_ingress_available(W239_FATHER_PASSED) \
			or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
			or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
			or not _w239_passed_surface(
				"W239 passed exact ingress", _w235_current_home_background()) \
			or not _w239_passed_audio_matches(
				false, "W239 passed exact ingress"):
		_fail("W239 passed lost selected father/W238 receipts or real ingress")
		return false
	return true


func _w239_passed_read_intro(home_background: String) -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	if int(_story.call("_story_source_paragraph_count")) != 4 \
			or pages.is_empty() or not _m23_same_prose(pages, authored):
		_fail("W239 passed lost its receipt rows plus two authored sources")
		return false
	var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
	var bed_position := BGMPlayer._ambience_player.get_playback_position()
	var score_player := _w239_grief_player()
	if not is_instance_valid(score_player):
		_fail("W239 passed opening has no source0 grief stream")
		return false
	var score_stream: AudioStream = score_player.stream
	var score_position := score_player.get_playback_position()
	var score_token := int(BGMPlayer.get("_punctuation_token"))
	var untouched := _w227_state_bytes()
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		await _finish_page()
		var current_bed_position := BGMPlayer._ambience_player.get_playback_position()
		if not _w239_passed_surface(
				"W239 passed opening source%d" % source, home_background) \
				or not _w239_passed_audio_matches(
					false, "W239 passed opening source%d" % source) \
				or not _w227_state_matches(
					untouched, "W239 passed opening source%d" % source,
					false, "W239P") \
				or BGMPlayer._ambience_player.stream != bed_stream \
				or current_bed_position + 0.05 < bed_position \
				or not _w239_score_unchanged(
					score_player, score_stream, score_position, score_token,
					"W239 passed source%d" % source) \
				or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
				or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty():
			_fail("W239 passed source%d restarted or gained an early action" % source)
			return false
		bed_position = current_bed_position
		score_position = score_player.get_playback_position()
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 3 \
		and _w239_passed_surface("W239 passed choices", home_background) \
		and _w239_passed_audio_matches(false, "W239 passed choices") \
		and _w227_state_matches(
			untouched, "W239 passed choices", false, "W239P")


func _w239_passed_prepare_result(
		language: String, choice: int, home_case: Dictionary,
		trace_choice: int = 0, remaining_choice: int = 0) -> bool:
	var home_background := str(home_case.get("background", ""))
	if not await _w239_passed_open(
			language, home_case, trace_choice, remaining_choice) \
			or not await _w239_passed_read_intro(home_background):
		return false
	_w239_passed_clear_tracked()
	_story.call("_on_choice", choice)
	_story.set_process(false)
	await _wait_stable()
	return _w239_passed_result_layout(choice) \
		and GameState.chapter5_finale_receipt_matches(
			W239_FATHER_PASSED, choice, 239) \
		and _w239_passed_surface("W239 passed prepared result", home_background) \
		and _w239_passed_audio_matches(false, "W239 passed prepared result")


func _w239_passed_result_layout(choice: int) -> bool:
	var pages: Array = _story.get("_paragraphs")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choice < 0 or choice >= choices.size() or pages.is_empty():
		return false
	var authored := str(_story.call(
		"_fmt", (choices[choice] as Dictionary).get("result_text", "")))
	var expected_sources: Array[int] = [2, 3, 1]
	var mapping := _w239_passed_paper_mapping()
	var action_ok := mapping.is_empty()
	if choice in [0, 2] and not mapping.is_empty():
		var page_index := int(mapping.get("page", -1))
		var contract: Dictionary = _story.call(
			"_physical_cue_contract", page_index)
		var rows: Dictionary = W239_PASSED_PAPER_ACTIONS.get_meta(
			"paper_anchors", {})
		var locales: Dictionary = rows.get(str(choice), {})
		var expected_anchor := str(_story.call(
			"_fmt", str(locales.get(LocaleManager.language, ""))))
		action_ok = int(mapping.get("source", -1)) == 0 \
			and int(contract.get("source_index", -1)) == 0 \
			and str(contract.get("anchor", "")) == expected_anchor \
			and is_equal_approx(float(contract.get("volume_db", 0.0)), -8.0) \
			and str(contract.get("sfx", "")) == "paper_handle"
	if choices.size() != 3 \
			or int(_story.call("_story_source_paragraph_count")) != expected_sources[choice] \
			or not _m23_same_prose(pages, authored) \
			or int(_story.get("_result_location_cut_page")) >= 0 \
			or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
			or not action_ok:
		_fail("W239 passed choice%d lost its exact paper contract" % choice)
		return false
	return true


func _w239_passed_paper_mapping() -> Dictionary:
	var found: Array[Dictionary] = []
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		var source_index := int(_story.call(
			"_story_source_paragraph_index", page_index))
		var page := str((_story.get("_paragraphs") as Array)[page_index])
		var reveal := int(_story.call(
			"_w239_paper_reveal_position", page, page_index))
		if reveal > 0:
			found.append({
				"page": page_index, "reveal": reveal, "source": source_index})
	return found[0] if found.size() == 1 else {}


func _w239_passed_seek_paper_page(
		applied: String, allow_default_name_projection: bool = false) -> bool:
	var mapping := _w239_passed_paper_mapping()
	var target := int(mapping.get("page", -1))
	while int(_story.get("_para_index")) < target:
		await _finish_page()
		if not _w227_state_matches(
				applied, "W239 passed before paper page",
				allow_default_name_projection, "W239P") \
				or not _w239_passed_audio_matches(
					false, "W239 passed before paper page"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		mapping = _w239_passed_paper_mapping()
		target = int(mapping.get("page", -1))
	if target < 0 or int(_story.get("_para_index")) != target \
			or int(_story.get("_w239_paper_reveal_at")) != int(
				mapping.get("reveal", -2)):
		_fail("W239 passed did not settle on its exact paper-action page")
		return false
	return true


func _w239_passed_boundary_side(before_paper: bool) -> bool:
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) not in [0, 2] \
			or int(_story.call(
				"_story_source_paragraph_index", int(_story.get("_para_index")))) != 0:
		return false
	var paper_range: Vector2 = _story.call("_w239_paper_progress_range")
	var context: Dictionary = _story.call("build_save_resume_context")
	var progress := float(context.get("source_text_progress", -1.0))
	if paper_range.x < 0.0 or paper_range.y < paper_range.x:
		return false
	if before_paper:
		return not bool(_story.get("_w239_paper_consumed")) \
			and int(_story.get("_w239_paper_reveal_at")) > int(
				_story.get("_type_pos")) \
			and progress <= paper_range.x + 0.00001
	return bool(_story.get("_w239_paper_consumed")) \
		and int(_story.get("_w239_paper_reveal_at")) < 0 \
		and progress >= paper_range.y - 0.00001


func _w239_passed_finish_result(applied: String, played_at: int) -> bool:
	var score_player := _w239_grief_player()
	if not is_instance_valid(score_player):
		_fail("W239 passed result started without its held grief score")
		return false
	var score_stream: AudioStream = score_player.stream
	var score_position := score_player.get_playback_position()
	var score_token := int(BGMPlayer.get("_punctuation_token"))
	while true:
		await _finish_page()
		if not _w239_passed_surface(
				"W239 passed result", _w235_current_home_background()) \
				or not _w227_state_matches(
					applied, "W239 passed result", false, "W239P") \
				or not _w239_passed_audio_matches(
					played_at >= 0, "W239 passed result") \
				or int(AudioManager._last_sfx_ms.get(
					"paper_handle", -1)) != played_at \
				or not _w239_score_unchanged(
					score_player, score_stream, score_position, score_token,
					"W239 passed result"):
			_fail("W239 passed result replayed paper or restarted grief")
			return false
		score_position = score_player.get_playback_position()
		if int(_story.get("_para_index")) >= (
				_story.get("_paragraphs") as Array).size() - 1:
			return true
		_story.call("_on_advance")
		await _wait_stable()
	return false


func _w239_passed_surface(label: String, background_id: String) -> bool:
	var expected_stream: AudioStream = BGMPlayer.call("_load_ambience", "apartment")
	if str((_story.get("_current") as Dictionary).get("id", "")) != W239_FATHER_PASSED \
			or background_id.is_empty() \
			or not _expect_surface(background_id, "apartment", label) \
			or str(_story.call("_resolved_story_surface_portrait_id")) != "player_sad" \
			or expected_stream == null \
			or BGMPlayer._ambience_player.stream != expected_stream \
			or not BGMPlayer._ambience_player.playing \
			or not str(BGMPlayer.get("_current_human_ambience_key")).is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or not str(BGMPlayer.get("_current_season_key")).is_empty() \
			or BGMPlayer._season_player.playing \
			or not is_instance_valid(_w239_grief_player()) \
			or str(BGMPlayer.get("_current_key")) != "grief":
		_fail(label + " changed passed home, bed, portrait, layers, or grief")
		return false
	return true


func _w239_passed_clear_tracked() -> void:
	for sound_id: String in W239_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)


func _w239_passed_audio_matches(
		expect_paper: bool, label: String, require_stream: bool = false) -> bool:
	var cue_keys: Array = AudioManager._story_audio_seen.keys().filter(
		func(key: Variant) -> bool:
			return str(key).begins_with(W239_FATHER_PASSED + ":"))
	var invalid: Array[String] = []
	for sound_id: String in W239_TRACKED_SFX:
		var expected := expect_paper and sound_id == "paper_handle"
		var stream_count := _w197_sfx_stream_count(sound_id)
		if AudioManager._last_sfx_ms.has(sound_id) != expected \
				or (not expected and stream_count != 0) \
				or (expected and require_stream and stream_count != 1):
			invalid.append(sound_id)
	if not cue_keys.is_empty() or not invalid.is_empty():
		_fail("%s W239 passed audio mismatch paper=%s invalid=%s cues=%s" % [
			label, expect_paper, invalid, cue_keys])
		return false
	if require_stream and expect_paper:
		var expected_db := float(AudioManager.call("_vol_db")) \
			+ AudioManager.sfx_mix_trim_db("paper_handle") - 8.0
		for player: AudioStreamPlayer in AudioManager._pool:
			if player.playing \
					and player.stream == AudioManager._sounds.get("paper_handle"):
				if is_equal_approx(player.volume_db, expected_db):
					return true
				_fail("%s W239 passed paper volume expected=%s actual=%s" % [
					label, expected_db, player.volume_db])
				return false
		_fail(label + " W239 passed paper stream was not active")
		return false
	return true


func _w239_passed_intro_cold_matrix(home_case: Dictionary) -> int:
	var restored_cases := 0
	for spec: Dictionary in [
		{"phase": "prose", "source": 0, "locale": "ko"},
		{"phase": "choices", "source": 3, "locale": "en"},
	]:
		if not await _w239_passed_open("ko", home_case):
			return -1
		var phase := str(spec.get("phase", ""))
		var source_index := int(spec.get("source", -1))
		if phase == "choices":
			if not await _w239_passed_read_intro(
					str(home_case.get("background", ""))):
				return -1
		elif not await _w239_advance_to_source(source_index):
			return -1
		if phase == "prose":
			var page_length := str(_story.get("_type_full")).length()
			if not _w227_type_to(
					maxi(1, floori(float(page_length) / 2.0)), "W239P"):
				return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		var applied := _w227_state_bytes()
		var target_locale := str(spec.get("locale", "ko"))
		var cross_locale := target_locale != LocaleManager.language
		_w239_passed_clear_tracked()
		if not await _w239_cold_load(
				context, target_locale, applied, cross_locale,
				"W239 passed cold " + phase):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		if str(restored.get("phase", "")) != phase \
				or (phase != "choices" and int(restored.get(
					"source_paragraph_index", -1)) != source_index) \
				or (phase != "choices" and not _w238_progress_matches(
					context, restored, source_index, cross_locale)) \
				or not _w239_passed_surface(
					"W239 passed cold " + phase,
					_w235_current_home_background()) \
				or not _w239_passed_audio_matches(
					false, "W239 passed cold " + phase) \
				or not (_story.call(
					"_physical_cue_contract") as Dictionary).is_empty() \
				or not (_story.call(
					"_ballpoint_write_contract") as Dictionary).is_empty():
			_fail("W239 passed cold %s changed source progress, grief, or silence" % phase)
			return -1
		restored_cases += 1
	return restored_cases


func _w239_passed_result_cold_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for choice: int in [0, 2]:
		for before_paper: bool in [true, false]:
			if not await _w239_passed_prepare_result("ko", choice, home_case):
				return -1
			var applied := _w227_state_bytes()
			if not await _w239_passed_seek_paper_page(applied):
				return -1
			var reveal := int(_story.get("_w239_paper_reveal_at"))
			if not _w227_type_to(
					reveal - 1 if before_paper else reveal, "W239P"):
				return -1
			if not before_paper:
				var played_at := int(AudioManager._last_sfx_ms.get(
					"paper_handle", -1))
				if played_at < 0 or not await _w237_wait_sfx_completion(
						"paper_handle", played_at,
						"W239 passed before cold save"):
					return -1
			var context: Dictionary = _story.call("build_save_resume_context")
			_w239_passed_clear_tracked()
			if not await _w239_cold_load(
					context, "ko", applied, false,
					"W239 passed cold c%d result" % choice):
				return -1
			var restored: Dictionary = _story.call("build_save_resume_context")
			if str(restored.get("phase", "")) != "result" \
					or int(restored.get(
						"pending_result_choice_index", -1)) != choice \
					or int(restored.get(
						"source_paragraph_index", -1)) != 0 \
					or not _w238_progress_matches(context, restored, 0, false) \
					or not _w239_passed_boundary_side(before_paper) \
					or not _w239_passed_surface(
						"W239 passed cold result",
						_w235_current_home_background()) \
					or not _w239_passed_audio_matches(
						false, "W239 passed cold result"):
				_fail("W239 passed same-locale cold c%d crossed its paper boundary" % choice)
				return -1
			if before_paper:
				var restored_reveal := int(_story.get("_w239_paper_reveal_at"))
				if not _w227_type_to(restored_reveal, "W239P") \
						or not _w239_passed_audio_matches(
							true, "W239 passed cold remaining paper", true):
					_fail("W239 passed cold c%d lost its unread paper action" % choice)
					return -1
				var cold_played_at := int(AudioManager._last_sfx_ms.get(
					"paper_handle", -1))
				if not await _w237_wait_sfx_completion(
						"paper_handle", cold_played_at,
						"W239 passed cold remaining paper"):
					return -1
				_w239_passed_cold_paper += 1
			else:
				_story.call("_complete_typing")
				_story.call("_complete_typing")
				if not _w239_passed_audio_matches(
						false, "W239 passed cold consumed completion"):
					return -1
			boundaries += 1

	for choice: int in [0, 2]:
		if not await _w239_passed_prepare_result("ko", choice, home_case):
			return -1
		var applied := _w227_state_bytes()
		if not await _w239_passed_seek_paper_page(applied):
			return -1
		var reveal := int(_story.get("_w239_paper_reveal_at"))
		if not _w227_type_to(reveal - 1, "W239P"):
			return -1
		var context: Dictionary = _story.call("build_save_resume_context")
		_w239_passed_clear_tracked()
		if not await _w239_cold_load(
				context, "en", applied, true,
				"W239 passed cross-locale c%d" % choice):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		if str(restored.get("phase", "")) != "result" \
				or int(restored.get(
					"pending_result_choice_index", -1)) != choice \
				or int(restored.get("source_paragraph_index", -1)) != 0 \
				or not _w238_progress_matches(context, restored, 0, true) \
				or not bool(_story.get("_w239_paper_consumed")) \
				or int(_story.get("_w239_paper_reveal_at")) >= 0 \
				or not _w239_passed_surface(
					"W239 passed cross-locale result",
					_w235_current_home_background()) \
				or not _w239_passed_audio_matches(
					false, "W239 passed cross-locale result"):
			_fail("W239 passed cross-locale c%d replayed an unprovable paper action" % choice)
			return -1
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if not _w239_passed_audio_matches(
				false, "W239 passed cross-locale completion"):
			return -1
		boundaries += 1

	if not await _w239_passed_prepare_result("ko", 1, home_case):
		return -1
	var silent_state := _w227_state_bytes()
	var silent_length := str(_story.get("_type_full")).length()
	if not _w227_type_to(
			maxi(1, floori(float(silent_length) / 2.0)), "W239P"):
		return -1
	var silent_context: Dictionary = _story.call("build_save_resume_context")
	_w239_passed_clear_tracked()
	if not await _w239_cold_load(
			silent_context, "ko", silent_state, false,
			"W239 passed cold silent c1"):
		return -1
	var silent_restored: Dictionary = _story.call("build_save_resume_context")
	if str(silent_restored.get("phase", "")) != "result" \
			or int(silent_restored.get(
				"pending_result_choice_index", -1)) != 1 \
			or int(silent_restored.get("source_paragraph_index", -1)) != 0 \
			or not _w238_progress_matches(
				silent_context, silent_restored, 0, false) \
			or not (_story.call(
				"_physical_cue_contract") as Dictionary).is_empty() \
			or not (_story.call(
				"_ballpoint_write_contract") as Dictionary).is_empty() \
			or not _w239_passed_surface(
				"W239 passed cold silent c1",
				_w235_current_home_background()) \
			or not _w239_passed_audio_matches(
				false, "W239 passed cold silent c1"):
		_fail("W239 passed c1 cold result invented a physical action")
		return -1
	_story.call("_complete_typing")
	_story.call("_complete_typing")
	if not _w239_passed_audio_matches(
			false, "W239 passed cold silent c1 completion"):
		return -1
	boundaries += 1
	return boundaries


func _w239_passed_legacy_cold_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for choice: int in [0, 2]:
		for before_paper: bool in [true, false]:
			if not await _w239_passed_prepare_result("ko", choice, home_case):
				return -1
			var applied := _w227_state_bytes()
			if not await _w239_passed_seek_paper_page(applied):
				return -1
			var reveal := int(_story.get("_w239_paper_reveal_at"))
			if not _w227_type_to(
					reveal - 1 if before_paper else reveal, "W239P"):
				return -1
			if not before_paper:
				var played_at := int(AudioManager._last_sfx_ms.get(
					"paper_handle", -1))
				if played_at < 0 or not await _w237_wait_sfx_completion(
						"paper_handle", played_at,
						"W239 passed before legacy save"):
					return -1
			var context: Dictionary = _story.call("build_save_resume_context")
			if before_paper:
				context.erase("story_locale")
			else:
				context.erase("source_paragraph_index")
				context.erase("source_text_progress")
			_w239_passed_clear_tracked()
			if not await _w239_cold_load(
					context, "ko", applied, false,
					"W239 passed legacy c%d/%s" % [
						choice, "before" if before_paper else "after"]):
				return -1
			var restored: Dictionary = _story.call("build_save_resume_context")
			if str(restored.get("phase", "")) != "result" \
					or int(restored.get(
						"pending_result_choice_index", -1)) != choice \
					or not bool(_story.get("_w239_paper_consumed")) \
					or int(_story.get("_w239_paper_reveal_at")) >= 0 \
					or not _w239_passed_surface(
						"W239 passed legacy result",
						_w235_current_home_background()) \
					or not _w239_passed_audio_matches(
						false, "W239 passed legacy result"):
				_fail("W239 passed legacy c%d replayed without source/locale proof" % choice)
				return -1
			_story.call("_complete_typing")
			_story.call("_complete_typing")
			if not _w239_passed_audio_matches(
					false, "W239 passed legacy completion"):
				return -1
			boundaries += 1
	return boundaries


func _w239_passed_reflow_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for choice: int in [0, 2]:
		for before_paper: bool in [true, false]:
			if not await _w239_passed_prepare_result("ko", choice, home_case):
				return -1
			var applied := _w227_state_bytes()
			if not await _w239_passed_seek_paper_page(applied):
				return -1
			var reveal := int(_story.get("_w239_paper_reveal_at"))
			if not _w227_type_to(
					reveal - 1 if before_paper else reveal, "W239P"):
				return -1
			if not before_paper:
				var played_at := int(AudioManager._last_sfx_ms.get(
					"paper_handle", -1))
				if played_at < 0 or not await _w237_wait_sfx_completion(
						"paper_handle", played_at,
						"W239 passed before reflow"):
					return -1
			_w239_passed_clear_tracked()
			var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
			var bed_position := BGMPlayer._ambience_player.get_playback_position()
			var score_player := _w239_grief_player()
			if not is_instance_valid(score_player):
				return -1
			var score_stream: AudioStream = score_player.stream
			var score_position := score_player.get_playback_position()
			var score_token := int(BGMPlayer.get("_punctuation_token"))
			_story.call("_set_story_text_size", "large")
			await _wait_stable()
			if not _w239_passed_reflow_state(
					before_paper, applied, false, bed_stream, bed_position,
					score_player, score_stream, score_position, score_token,
					"font"):
				return -1
			boundaries += 1
			bed_position = BGMPlayer._ambience_player.get_playback_position()
			score_position = score_player.get_playback_position()
			_story.call("_set_story_language", "en")
			await _wait_stable()
			if LocaleManager.language != "en" \
					or not _w239_passed_reflow_state(
						before_paper, applied, true, bed_stream, bed_position,
						score_player, score_stream, score_position, score_token,
						"locale"):
				return -1
			boundaries += 1
			if before_paper:
				var localized_reveal := int(_story.get("_w239_paper_reveal_at"))
				if localized_reveal <= 0 \
						or not _w227_type_to(localized_reveal, "W239P") \
						or not _w239_passed_audio_matches(
							true, "W239 passed reflow remaining paper", true):
					_fail("W239 passed hot reflow lost c%d remaining paper" % choice)
					return -1
				var reflow_played_at := int(AudioManager._last_sfx_ms.get(
					"paper_handle", -1))
				if not await _w237_wait_sfx_completion(
						"paper_handle", reflow_played_at,
						"W239 passed reflow remaining paper"):
					return -1
				_w239_passed_reflow_paper += 1
			else:
				_story.call("_complete_typing")
				_story.call("_complete_typing")
				if not _w239_passed_audio_matches(
						false, "W239 passed reflow consumed completion"):
					return -1
	return boundaries


func _w239_passed_reflow_state(
		before_paper: bool, applied: String,
		allow_default_name_projection: bool,
		bed_stream: AudioStream, bed_position: float,
		score_player: AudioStreamPlayer, score_stream: AudioStream,
		score_position: float, score_token: int, label: String) -> bool:
	if not _w239_passed_boundary_side(before_paper) \
			or BGMPlayer._ambience_player.stream != bed_stream \
			or BGMPlayer._ambience_player.get_playback_position() + 0.05 < bed_position \
			or not _w227_state_matches(
				applied, "W239 passed " + label + " reflow",
				allow_default_name_projection, "W239P") \
			or not _w239_passed_surface(
				"W239 passed " + label + " reflow",
				_w235_current_home_background()) \
			or not _w239_passed_audio_matches(
				false, "W239 passed " + label + " reflow") \
			or not _w239_score_unchanged(
				score_player, score_stream, score_position, score_token,
				"W239 passed " + label + " reflow"):
		_fail("W239 passed %s reflow crossed paper or restarted bed/score" % label)
		return false
	return true


func _check_w237_record_page_turn() -> bool:
	_w237_cold_pages = 0
	_w237_future_pages = 0
	_w237_reflow_pages = 0
	var default_home: Dictionary = W235_HOME_CASES[1]
	var settings_before := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	var paths := 0
	var live_pages := 0
	var silent_results := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice in range(2):
			if not await _w237_prepare_result(
					language, choice, default_home, true):
				return false
			var applied := _w227_state_bytes()
			if choice == 0:
				if not await _w237_seek_page(applied):
					return false
				var reveal := int(_story.get("_w237_page_reveal_at"))
				if reveal <= 0 or not _w227_type_to(reveal - 1, "W237") \
						or not _w237_boundary_side(true) \
						or AudioManager._last_sfx_ms.has("page_turn"):
					_fail("W237 %s sounded before its localized final page clause" % language)
					return false
				if not _w227_type_to(reveal, "W237"):
					return false
				var played_at := int(AudioManager._last_sfx_ms.get("page_turn", -1))
				if played_at < 0 or not _w237_boundary_side(false) \
						or not _w237_audio_matches(
							[_w237_phone_token(0), _w237_phone_token(3)], true,
							"W237 exact page clause", true):
					_fail("W237 %s lost its exact page turn" % language)
					return false
				if not await _w237_finish_result(applied, played_at) \
						or not await _w237_wait_sfx_completion(
							"page_turn", played_at, "W237 live result"):
					return false
				live_pages += 1
			else:
				if not await _w237_finish_result(applied, -1):
					return false
				silent_results += 1
			paths += 1

	var housing_contexts := 0
	for home_case: Dictionary in W235_HOME_CASES:
		if not await _w237_open("ko", home_case) \
				or not _w237_surface(
					"W237 housing " + str(home_case.get("id", "")),
					str(home_case.get("background", "")), false):
			return false
		housing_contexts += 1

	var apartment_case: Dictionary = W235_HOME_CASES[3]
	if not await _w237_open("ko", apartment_case, true):
		return false
	await get_tree().create_timer(1.5).timeout
	if not _w237_surface("W237 same-key settled bed", "gangnam_apartment", false) \
			or BGMPlayer._ambience_tween != null and BGMPlayer._ambience_tween.is_running() \
			or not is_equal_approx(
				BGMPlayer._ambience_player.volume_db,
				float(BGMPlayer.call("_ambience_target_db"))):
		_fail("W237 inherited same-key fade stopped or kept ducking its fresh bed")
		return false

	var cold_boundaries := await _w237_result_cold_matrix(default_home)
	if cold_boundaries < 0:
		return false
	var intro_cold := await _w237_intro_cold_matrix(default_home)
	if intro_cold < 0:
		return false
	var reflow_boundaries := await _w237_reflow_matrix(default_home)
	if reflow_boundaries < 0:
		return false
	var settings_after := [
		AudioManager.master_volume, AudioManager.bgm_volume, BGMPlayer.volume]
	print("W237_PAGE_TURN_OK paths=%d phones=%d page_turns=%d silent=%d homes=%d same_key=1 v4=%d cold_pages=%d future_pages=%d intro_cold=%d reflows=%d reflow_pages=%d" % [
		paths, paths * 2, live_pages, silent_results, housing_contexts,
		cold_boundaries, _w237_cold_pages, _w237_future_pages,
		intro_cold, reflow_boundaries, _w237_reflow_pages])
	var counts_ok := paths == 10 and live_pages == 5 and silent_results == 5 \
		and housing_contexts == 7 and cold_boundaries == 6 \
		and _w237_cold_pages == 3 and _w237_future_pages == 2 \
		and intro_cold == 3 and reflow_boundaries == 6 \
		and _w237_reflow_pages == 2 and settings_before == settings_after
	if not counts_ok:
		_fail("W237 dynamic fixture population or master-volume state drifted")
	return counts_ok


func _w237_read_intro(home_background: String, prove_live_phones: bool) -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	if int(_story.call("_story_source_paragraph_count")) != 4 \
			or pages.is_empty() or not _m23_same_prose(pages, authored):
		_fail("W237 lost its three inline receipt reads plus authored prose sources")
		return false
	var first_phone := int(AudioManager._last_sfx_ms.get("phone_vibrate", -1))
	if first_phone < 0 or not _w237_audio_matches(
			[_w237_phone_token(0)], false, "W237 source0 phone",
			false, prove_live_phones):
		return false
	if prove_live_phones and not await _w237_wait_sfx_completion(
			"phone_vibrate", first_phone, "W237 source0 phone"):
		return false
	var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
	var bed_position := BGMPlayer._ambience_player.get_playback_position()
	var score_token := -1
	var score_player: AudioStreamPlayer = null
	var score_stream: AudioStream = null
	var score_position := -1.0
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		await _finish_page()
		var current_bed_position := BGMPlayer._ambience_player.get_playback_position()
		if not _w237_surface("W237 opening source%d" % source, home_background, source >= 1) \
				or BGMPlayer._ambience_player.stream != bed_stream \
				or current_bed_position + 0.05 < bed_position:
			_fail("W237 source%d restarted its apartment bed or score state" % source)
			return false
		bed_position = current_bed_position
		if source >= 1:
			var current_score := _w237_score_player()
			if not is_instance_valid(current_score):
				_fail("W237 source%d has no actual reckoning stream" % source)
				return false
			if score_player == null:
				score_player = current_score
				score_stream = current_score.stream
				score_token = int(BGMPlayer.get("_punctuation_token"))
				score_position = current_score.get_playback_position()
			elif current_score != score_player or current_score.stream != score_stream \
					or int(BGMPlayer.get("_punctuation_token")) != score_token \
					or current_score.get_playback_position() + 0.05 < score_position:
				_fail("W237 source%d restarted its held reckoning stream" % source)
				return false
			else:
				score_position = current_score.get_playback_position()
		if source == 3:
			var second_phone := int(AudioManager._last_sfx_ms.get("phone_vibrate", -1))
			if prove_live_phones and (second_phone <= first_phone \
					or not _w237_audio_matches(
						[_w237_phone_token(0), _w237_phone_token(3)], false,
						"W237 source3 phone", false, true) \
					or not await _w237_wait_sfx_completion(
						"phone_vibrate", second_phone, "W237 source3 phone")):
				_fail("W237 source3 did not dispatch a distinct second phone vibration")
				return false
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 2 \
		and _w237_surface("W237 choices", home_background, true) \
		and _w237_audio_matches(
			[_w237_phone_token(0), _w237_phone_token(3)], false,
			"W237 choices")


func _w237_prepare_result(language: String, choice: int,
		home_case: Dictionary, prove_live_phones: bool = false) -> bool:
	var home_background := str(home_case.get("background", ""))
	if not await _w237_open(language, home_case) \
			or not await _w237_read_intro(home_background, prove_live_phones):
		return false
	AudioManager.stop_sound("page_turn")
	AudioManager._last_sfx_ms.erase("page_turn")
	_story.call("_on_choice", choice)
	_story.set_process(false)
	await _wait_stable()
	return _w237_result_layout(choice) \
		and GameState.chapter5_finale_receipt_matches(W237_RECORD, choice, 237) \
		and _w237_surface("W237 prepared result", home_background, true) \
		and _w237_audio_matches(
			[_w237_phone_token(0), _w237_phone_token(3)], false,
			"W237 prepared result")


func _w237_result_layout(choice: int) -> bool:
	var pages: Array = _story.get("_paragraphs")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choice < 0 or choice >= choices.size() or pages.is_empty():
		return false
	var authored := str(_story.call(
		"_fmt", (choices[choice] as Dictionary).get("result_text", "")))
	var mapping := _w237_page_mapping()
	var contract: Dictionary = _story.call(
		"_physical_cue_contract", int(mapping.get("page", -1))) \
		if not mapping.is_empty() else {}
	var expected_anchor := str(W237_RECORD_PAGE_TURN.get_meta(
		"page_turn_anchors", {}).get(LocaleManager.language, ""))
	var action_ok: bool = mapping.is_empty() and contract.is_empty() if choice == 1 \
		else int(mapping.get("source", -1)) == 1 \
			and contract.get("source_index") == 1 \
			and str(contract.get("anchor", "")) == str(_story.call("_fmt", expected_anchor)) \
			and is_equal_approx(float(contract.get("volume_db", 0.0)), -7.0) \
			and str(contract.get("sfx", "")) == "page_turn"
	if choices.size() != 2 \
			or int(_story.call("_story_source_paragraph_count")) != 2 \
			or not _m23_same_prose(pages, authored) \
			or int(_story.get("_result_location_cut_page")) >= 0 \
			or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
			or not action_ok:
		_fail("W237 choice%d lost its exact two-source paper-only contract" % choice)
		return false
	return true


func _w237_page_mapping() -> Dictionary:
	var found: Array[Dictionary] = []
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		var source_index := int(_story.call("_story_source_paragraph_index", page_index))
		var page := str((_story.get("_paragraphs") as Array)[page_index])
		var reveal := int(_story.call("_w237_page_reveal_position", page, page_index))
		if reveal > 0:
			found.append({"page": page_index, "reveal": reveal, "source": source_index})
	return found[0] if found.size() == 1 else {}


func _w237_seek_page(applied: String,
		allow_default_name_projection: bool = false) -> bool:
	var mapping := _w237_page_mapping()
	var target := int(mapping.get("page", -1))
	while int(_story.get("_para_index")) < target:
		await _finish_page()
		if not _w227_state_matches(
				applied, "W237 before page-turn page",
				allow_default_name_projection, "W237") \
				or not _w237_surface(
					"W237 before page-turn page", _w235_current_home_background(), true):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		mapping = _w237_page_mapping()
		target = int(mapping.get("page", -1))
	if target < 0 or int(_story.get("_para_index")) != target \
			or int(_story.get("_w237_page_reveal_at")) != int(mapping.get("reveal", -2)):
		_fail("W237 did not settle on its exact final page-turn clause")
		return false
	return true


func _w237_boundary_side(before_page: bool) -> bool:
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != 0 \
			or int(_story.call(
				"_story_source_paragraph_index", int(_story.get("_para_index")))) != 1:
		return false
	var page_range: Vector2 = _story.call("_w237_page_progress_range")
	var context: Dictionary = _story.call("build_save_resume_context")
	var progress := float(context.get("source_text_progress", -1.0))
	if page_range.x < 0.0 or page_range.y < page_range.x:
		return false
	if before_page:
		return not bool(_story.get("_w237_page_consumed")) \
			and int(_story.get("_w237_page_reveal_at")) > int(_story.get("_type_pos")) \
			and progress <= page_range.x + 0.00001
	return bool(_story.get("_w237_page_consumed")) \
		and int(_story.get("_w237_page_reveal_at")) < 0 \
		and progress >= page_range.y - 0.00001


func _w237_finish_result(applied: String, played_at: int) -> bool:
	while true:
		await _finish_page()
		if not _w237_surface("W237 result", _w235_current_home_background(), true) \
				or not _w227_state_matches(applied, "W237 result", false, "W237") \
				or int(AudioManager._last_sfx_ms.get("page_turn", -1)) != played_at \
				or not _w237_audio_matches(
					[_w237_phone_token(0), _w237_phone_token(3)], played_at >= 0,
					"W237 result"):
			_fail("W237 later result page replayed or lost page_turn")
			return false
		if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
			return true
		_story.call("_on_advance")
		await _wait_stable()
	return false


func _w237_intro_cold_matrix(home_case: Dictionary) -> int:
	var restored_cases := 0
	for target in [0, 2, -1]:
		if not await _w237_open("ko", home_case):
			return -1
		if target < 0:
			if not await _w237_read_intro(
					str(home_case.get("background", "")), true):
				return -1
		else:
			var first_phone := int(AudioManager._last_sfx_ms.get("phone_vibrate", -1))
			if first_phone < 0 or not await _w237_wait_sfx_completion(
					"phone_vibrate", first_phone, "W237 intro cold source0") \
					or not await _w237_advance_to_prose_source(target):
				return -1
		if target >= 0:
			var page_length := str(_story.get("_type_full")).length()
			if not _w227_type_to(maxi(1, floori(float(page_length) / 2.0)), "W237"):
				return -1
		var applied := _w227_state_bytes()
		var context: Dictionary = _story.call("build_save_resume_context")
		var expected_phase := "choices" if target < 0 else "prose"
		var expected_source := int(context.get("source_paragraph_index", -1))
		var saved_progress := float(context.get("source_text_progress", -1.0))
		_w237_clear_tracked()
		if context.get("event_id") != W237_RECORD \
				or context.get("phase") != expected_phase \
				or not await _w237_cold_load(
					context, "ko", applied, false, "W237 cold " + expected_phase):
			return -1
		var restored: Dictionary = _story.call("build_save_resume_context")
		var expect_score: bool = target != 0
		if restored.get("event_id") != W237_RECORD \
				or restored.get("phase") != expected_phase \
				or int(restored.get("source_paragraph_index", -1)) != expected_source \
				or not is_equal_approx(
					float(restored.get("source_text_progress", -2.0)), saved_progress) \
				or not _w237_surface(
					"W237 cold " + expected_phase,
					_w235_current_home_background(), expect_score) \
				or not _w237_audio_matches([], false, "W237 cold " + expected_phase):
			_fail("W237 cold %s replayed a phone or changed its source/score" % expected_phase)
			return -1
		if target in [0, 2]:
			if target == 0:
				if not await _w237_advance_to_prose_source(1) \
						or not _w237_surface(
							"W237 cold source1 score admission",
							_w235_current_home_background(), true):
					_fail("W237 cold source0 did not admit score at live source1")
					return -1
			if not await _w237_advance_to_prose_source(3):
				return -1
			var future_phone := int(AudioManager._last_sfx_ms.get("phone_vibrate", -1))
			if future_phone < 0 or not _w237_audio_matches(
					[_w237_phone_token(3)], false,
					"W237 cold future source3 phone", false, true) \
					or not await _w237_wait_sfx_completion(
						"phone_vibrate", future_phone,
						"W237 cold future source3 phone"):
				_fail("W237 cold prose lost its definitely future source3 phone")
				return -1
		restored_cases += 1
	return restored_cases


func _w237_advance_to_prose_source(target_source: int) -> bool:
	for _guard in range(64):
		if bool(_story.get("_showing_choices")):
			break
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		if source == target_source:
			return true
		if source > target_source:
			break
		await _finish_page()
		_story.call("_on_advance")
		await _wait_stable()
	_fail("W237 could not advance to prose source%d" % target_source)
	return false


func _w237_reflow_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for before_page: bool in [true, false]:
		if not await _w237_prepare_result("ko", 0, home_case):
			return -1
		var applied := _w227_state_bytes()
		if not await _w237_seek_page(applied):
			return -1
		var reveal := int(_story.get("_w237_page_reveal_at"))
		if not _w227_type_to(reveal - 1 if before_page else reveal, "W237"):
			return -1
		if not before_page:
			var played_at := int(AudioManager._last_sfx_ms.get("page_turn", -1))
			if played_at < 0 or not await _w237_wait_sfx_completion(
					"page_turn", played_at, "W237 before reflow"):
				return -1
		AudioManager.stop_sound("page_turn")
		AudioManager._last_sfx_ms.erase("page_turn")
		if not await _w237_reflow_boundary(1, before_page, applied):
			return -1
		boundaries += 2
	if not await _w237_prepare_result("ko", 0, home_case):
		return -1
	var future_state := _w227_state_bytes()
	if not await _w237_reflow_boundary(0, true, future_state):
		return -1
	boundaries += 2
	return boundaries


func _w237_reflow_boundary(
		source_index: int, before_page: bool, applied: String) -> bool:
	var score_player := _w237_score_player()
	if not is_instance_valid(score_player):
		_fail("W237 reflow started without actual reckoning stream")
		return false
	var score_stream: AudioStream = score_player.stream
	var score_position := score_player.get_playback_position()
	var score_token := int(BGMPlayer.get("_punctuation_token"))
	_story.call("_set_story_text_size", "large")
	await _wait_stable()
	var font_ok := not bool(_story.get("_w237_page_consumed")) \
		and int(_story.get("_w237_page_reveal_at")) < 0 if source_index == 0 \
		else _w237_boundary_side(before_page)
	if not font_ok \
			or not _w237_score_unchanged(
				score_player, score_stream, score_position, score_token,
				"W237 font reflow") \
			or not _w227_state_matches(applied, "W237 font reflow", false, "W237") \
			or not _w237_surface(
				"W237 font reflow", _w235_current_home_background(), true) \
			or not _w237_audio_matches(
				[_w237_phone_token(0), _w237_phone_token(3)], false,
				"W237 font reflow"):
		_fail("W237 source%d font reflow crossed or replayed its page boundary" % source_index)
		return false
	score_position = score_player.get_playback_position()
	_story.call("_set_story_language", "en")
	await _wait_stable()
	var locale_ok := not bool(_story.get("_w237_page_consumed")) \
		and int(_story.get("_w237_page_reveal_at")) < 0 if source_index == 0 \
		else _w237_boundary_side(before_page)
	if LocaleManager.language != "en" or not locale_ok \
			or not _w237_score_unchanged(
				score_player, score_stream, score_position, score_token,
				"W237 locale reflow") \
			or not _w227_state_matches(applied, "W237 locale reflow", true, "W237") \
			or not _w237_surface(
				"W237 locale reflow", _w235_current_home_background(), true) \
			or not _w237_audio_matches(
				[_w237_phone_token(0), _w237_phone_token(3)], false,
				"W237 locale reflow"):
		_fail("W237 source%d locale reflow crossed or replayed its page boundary" % source_index)
		return false
	var played_at := -1
	if source_index == 0:
		if not await _w237_seek_page(applied, true):
			return false
		var reveal := int(_story.get("_w237_page_reveal_at"))
		if reveal <= 0 or not _w227_type_to(reveal, "W237"):
			_fail("W237 source0 reflow consumed or lost future source1 page turn")
			return false
		played_at = int(AudioManager._last_sfx_ms.get("page_turn", -1))
		_w237_reflow_pages += 1
	elif before_page:
		var reveal := int(_story.get("_w237_page_reveal_at"))
		if not _w227_type_to(reveal, "W237"):
			_fail("W237 source1 reflow lost its one remaining page turn")
			return false
		played_at = int(AudioManager._last_sfx_ms.get("page_turn", -1))
		_w237_reflow_pages += 1
	else:
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		return not AudioManager._last_sfx_ms.has("page_turn")
	return played_at >= 0 \
		and _w237_audio_matches(
			[_w237_phone_token(0), _w237_phone_token(3)], true,
			"W237 reflow page turn", true) \
		and await _w237_wait_sfx_completion(
			"page_turn", played_at, "W237 reflow page turn")


func _w237_score_unchanged(player: AudioStreamPlayer, stream: AudioStream,
		previous_position: float, token: int, label: String) -> bool:
	var current := _w237_score_player()
	if current != player or not is_instance_valid(current) \
			or current.stream != stream \
			or int(BGMPlayer.get("_punctuation_token")) != token \
			or current.get_playback_position() + 0.05 < previous_position:
		_fail(label + " restarted or replaced the held reckoning stream")
		return false
	return true


func _w237_result_cold_matrix(home_case: Dictionary) -> int:
	var boundaries := 0
	for before_page: bool in [true, false]:
		if not await _w237_prepare_result("ko", 0, home_case):
			return -1
		var applied := _w227_state_bytes()
		if not await _w237_seek_page(applied):
			return -1
		var reveal := int(_story.get("_w237_page_reveal_at"))
		if not _w227_type_to(reveal - 1 if before_page else reveal, "W237"):
			return -1
		if not before_page:
			var played_at := int(AudioManager._last_sfx_ms.get("page_turn", -1))
			if played_at < 0 or not await _w237_wait_sfx_completion(
					"page_turn", played_at, "W237 before cold save"):
				return -1
		_w237_clear_tracked()
		if not await _w237_cold_result_boundary(
				0, 1, before_page, applied, "ko", false):
			return -1
		boundaries += 1

	if not await _w237_prepare_result("ko", 0, home_case):
		return -1
	var cross_state := _w227_state_bytes()
	if not await _w237_seek_page(cross_state):
		return -1
	var cross_reveal := int(_story.get("_w237_page_reveal_at"))
	if not _w227_type_to(cross_reveal - 1, "W237"):
		return -1
	_w237_clear_tracked()
	if not await _w237_cold_result_boundary(
			0, 1, true, cross_state, "en", true):
		return -1
	boundaries += 1

	for target_locale: String in ["ko", "en"]:
		if not await _w237_prepare_result("ko", 0, home_case):
			return -1
		var future_state := _w227_state_bytes()
		var first_page_length := str(_story.get("_type_full")).length()
		if not _w227_type_to(maxi(1, floori(float(first_page_length) / 2.0)), "W237"):
			return -1
		_w237_clear_tracked()
		if not await _w237_cold_result_boundary(
				0, 0, true, future_state, target_locale, target_locale == "en"):
			return -1
		boundaries += 1

	if not await _w237_prepare_result("ko", 1, home_case):
		return -1
	var silent_state := _w227_state_bytes()
	var silent_length := str(_story.get("_type_full")).length()
	if not _w227_type_to(maxi(1, floori(float(silent_length) / 2.0)), "W237"):
		return -1
	var silent_context: Dictionary = _story.call("build_save_resume_context")
	_w237_clear_tracked()
	if not await _w237_cold_load(silent_context, "ko", silent_state, false,
			"W237 silent result"):
		return -1
	var restored: Dictionary = _story.call("build_save_resume_context")
	if restored.get("phase") != "result" \
			or int(restored.get("pending_result_choice_index", -1)) != 1 \
			or not _w237_surface(
				"W237 cold silent result", _w235_current_home_background(), true) \
			or not (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
			or not _w237_audio_matches([], false, "W237 cold silent result"):
		_fail("W237 c1 cold result invented or replayed a physical action")
		return -1
	_story.call("_complete_typing")
	_story.call("_complete_typing")
	if AudioManager._last_sfx_ms.has("page_turn"):
		_fail("W237 c1 cold result replayed page_turn")
		return -1
	boundaries += 1
	return boundaries


func _w237_cold_result_boundary(
		choice: int, source_index: int, before_page: bool, applied: String,
		target_locale: String, cross_locale: bool) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	var saved_progress := float(context.get("source_text_progress", -1.0))
	if context.get("event_id") != W237_RECORD or context.get("phase") != "result" \
			or int(context.get("pending_result_choice_index", -1)) != choice \
			or int(context.get("source_paragraph_index", -1)) != source_index:
		_fail("W237 could not capture source%d result boundary" % source_index)
		return false
	if not await _w237_cold_load(
			context, target_locale, applied, cross_locale, "W237 cold result"):
		return false
	var restored: Dictionary = _story.call("build_save_resume_context")
	var restored_progress := float(restored.get("source_text_progress", -2.0))
	var source_characters := 0
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		if int(_story.call("_story_source_paragraph_index", page_index)) == source_index:
			source_characters += str((_story.get("_paragraphs") as Array)[page_index]).length()
	var quantization_bound := 0.5 / float(source_characters) + 0.000001 \
		if source_characters > 0 else -1.0
	var progress_ok := is_equal_approx(restored_progress, saved_progress) \
		if not cross_locale else quantization_bound > 0.0 \
			and absf(restored_progress - saved_progress) <= quantization_bound
	var boundary_ok := not bool(_story.get("_w237_page_consumed")) \
		and int(_story.get("_w237_page_reveal_at")) < 0 if source_index == 0 \
		else _w237_boundary_side(before_page and not cross_locale)
	if source_index == 1 and cross_locale:
		boundary_ok = bool(_story.get("_w237_page_consumed")) \
			and int(_story.get("_w237_page_reveal_at")) < 0
	if LocaleManager.language != target_locale or restored.get("event_id") != W237_RECORD \
			or restored.get("phase") != "result" \
			or int(restored.get("pending_result_choice_index", -1)) != choice \
			or int(restored.get("source_paragraph_index", -1)) != source_index \
			or not progress_ok or not boundary_ok \
			or not _w237_surface(
				"W237 cold result", _w235_current_home_background(), true) \
			or not _w237_audio_matches([], false, "W237 cold result"):
		_fail("W237 cold result crossed, replayed, changed state, or lost source identity")
		return false
	var played_at := -1
	if source_index == 0:
		if not await _w237_seek_page(applied, cross_locale):
			return false
		var reveal := int(_story.get("_w237_page_reveal_at"))
		if reveal <= 0 or not _w227_type_to(reveal - 1, "W237") \
				or bool(_story.get("_w237_page_consumed")) \
				or not _w227_type_to(reveal, "W237"):
			_fail("W237 cold source0 lost its definitely future source1 page turn")
			return false
		played_at = int(AudioManager._last_sfx_ms.get("page_turn", -1))
		_w237_cold_pages += 1
		_w237_future_pages += 1
	elif before_page and not cross_locale:
		var reveal := int(_story.get("_w237_page_reveal_at"))
		if not _w227_type_to(reveal, "W237"):
			_fail("W237 same-locale cold restore lost its pending page turn")
			return false
		played_at = int(AudioManager._last_sfx_ms.get("page_turn", -1))
		_w237_cold_pages += 1
	else:
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if AudioManager._last_sfx_ms.has("page_turn"):
			_fail("W237 cold consumed boundary replayed a past page turn")
			return false
	if played_at >= 0:
		if not _w237_audio_matches([], true, "W237 cold page turn", true) \
				or not await _w237_wait_sfx_completion(
					"page_turn", played_at, "W237 cold page turn"):
			return false
	return _w227_state_matches(
		applied, "W237 cold final", cross_locale, "W237") \
		and _w237_surface(
			"W237 cold final", _w235_current_home_background(), true)


func _w237_cold_load(context: Dictionary, target_locale: String,
		applied: String, allow_default_name_projection: bool, label: String) -> bool:
	if not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail(label + " could not write isolated v4 save")
		return false
	var disk: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int((disk as Dictionary).get("version", -1)) != 4:
		_fail(label + " lost disk schema v4")
		return false
	await _remove_story()
	await _stop_audio()
	GameState.start_new_game()
	LocaleManager.set_language(target_locale)
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail(label + " could not cold-load its boundary")
		return false
	BGMPlayer.set_ambience("room")
	BGMPlayer.set_season_ambience("winter")
	BGMPlayer.play_punctuation("reckoning")
	_w237_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	await get_tree().create_timer(0.9).timeout
	return _w227_state_matches(
		applied, label, allow_default_name_projection, "W237")


func _w237_open(language: String, home_case: Dictionary,
		prime_same_key: bool = false) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W237/%s" % [language, str(home_case.get("id", "home"))]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	SaveManager.set_setting("story_text_size", "standard")
	if not _prepare_full_owner_history(237, [
			[203, "arc_minseo_03_arrival", 1],
			[211, "arc_y5_general_name_boundary_exact", 0],
			[220, "arc_y5_general_debt_memory_reconnect", 0],
		]):
		return false
	GameState.money = 2_500_000_000.0
	GameState.housing = str(home_case.get("housing", "oneroom"))
	for flag_id: String in ["arc_daeun_wedding_day_seen", "daeun_divorced"]:
		GameState.flags.erase(flag_id)
	var home_flags: Dictionary = home_case.get("flags", {})
	for flag_id: String in home_flags:
		GameState.flags[flag_id] = bool(home_flags[flag_id])
	GameState.flags["father_passed"] = true
	GameState.flags["arc_endgame_sixmonths_seen"] = true
	var final_calendar := [GameState.turn, GameState.age, GameState.year,
		GameState.month, GameState.week_of_month]
	GameState.turn = 224
	if not GameState.prepare_chapter5_finale_route_entry():
		_fail("W237 could not lock its real general finale entry")
		return false
	var predecessors: Array = [
		["arc_y5_general_father_legacy_voice_exact", 1, 224],
		["arc_y5_general_debt_memory_voice_exact", 0, 229],
		["arc_y5_general_pre_ending_summit_exact", 1, 234],
	]
	for predecessor: Array in predecessors:
		GameState.turn = int(predecessor[2])
		if GameState.chapter5_finale_next_event_for_turn() != str(predecessor[0]):
			_fail("W237 lost predecessor ingress %s" % predecessor[0])
			return false
		var committed: Dictionary = GameState.record_chapter5_finale_choice(
			str(predecessor[0]), int(predecessor[1]))
		if not bool(committed.get("ok", false)):
			_fail("W237 could not commit predecessor %s/c%d" % [
				predecessor[0], predecessor[1]])
			return false
	GameState.turn = int(final_calendar[0])
	GameState.age = int(final_calendar[1])
	GameState.year = int(final_calendar[2])
	GameState.month = int(final_calendar[3])
	GameState.week_of_month = int(final_calendar[4])
	if GameState.chapter5_finale_next_event_for_turn() != W237_RECORD \
			or not GameState.chapter5_finale_ingress_available(W237_RECORD):
		_fail("W237 predecessor receipts did not admit the exact record root")
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
	ingress.set_meta("_screenshot_qa_static_surface", true)
	var routed := bool(ingress.call("_route_chapter5_finale_week"))
	ingress.free()
	if not routed or GameState.pending_story_queue != [W237_RECORD] \
			or not FULL_STORY_FLOW.valid_session():
		var owner: Dictionary = FULL_STORY_FLOW.snapshot()
		_fail("W237 did not route through MainGame and FullStoryFlow turn=%d last=%s valid=%s chain=%s routine_current=%s queue=%s" % [
			GameState.turn, owner.get("last_completed_turn"),
			FULL_STORY_FLOW.valid_session(), owner.get("chain", {}),
			(owner.get("routine_receipts", {}) as Dictionary).has(str(GameState.turn)),
			GameState.pending_story_queue])
		return false
	BGMPlayer.set_ambience("room")
	BGMPlayer.set_season_ambience("winter")
	BGMPlayer.play_punctuation("reckoning")
	if prime_same_key:
		BGMPlayer.set_ambience("apartment")
		BGMPlayer.duck_ambience(-12.0, 1.4)
		if str(BGMPlayer.get("_current_ambience_key")) != "apartment" \
				or not BGMPlayer._ambience_player.playing \
				or BGMPlayer._ambience_tween == null \
				or not BGMPlayer._ambience_tween.is_running():
			_fail("W237 same-key fixture did not seed its inherited apartment fade")
			return false
	elif str(BGMPlayer.get("_current_ambience_key")) != "room" \
			or str(BGMPlayer.get("_current_human_ambience_key")) != "thin_wall" \
			or str(BGMPlayer.get("_current_season_key")) != "winter" \
			or not BGMPlayer._ambience_player.playing \
			or not BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._season_player.playing or not _w216_score_playing():
		_fail("W237 fixture did not seed old room/thin-wall/winter/reckoning layers")
		return false
	_w237_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	var background := str(home_case.get("background", ""))
	return _w237_surface("W237 live opening", background, false) \
		and (_story.call("_physical_cue_contract") as Dictionary).is_empty() \
		and (_story.call("_ballpoint_write_contract") as Dictionary).is_empty() \
		and _w237_audio_matches(
			[_w237_phone_token(0)], false, "W237 live opening", false, true)


func _w237_phone_token(source_index: int) -> String:
	return W237_RECORD + "::description:%d:0:phone_vibrate" % source_index


func _w237_clear_tracked() -> void:
	for sound_id: String in W237_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)


func _w237_audio_matches(expected_cues: Array, expect_page: bool,
		label: String, require_page_stream: bool = false,
		require_phone_stream: bool = false) -> bool:
	var cue_keys: Array = AudioManager._story_audio_seen.keys().filter(
		func(key: Variant) -> bool:
			return str(key).begins_with(W237_RECORD + ":") and (
				str(key).ends_with(":phone_vibrate") \
				or str(key).ends_with(":page_turn") \
				or str(key).ends_with(":paper_handle") \
				or str(key).ends_with(":pen_ballpoint")))
	cue_keys.sort()
	var sorted_expected: Array = expected_cues.duplicate()
	sorted_expected.sort()
	var invalid: Array[String] = []
	for sound_id: String in W237_TRACKED_SFX:
		var expected_timestamp := expect_page if sound_id == "page_turn" else (
			not expected_cues.is_empty() if sound_id == "phone_vibrate" else false)
		var stream_count := _w197_sfx_stream_count(sound_id)
		if AudioManager._last_sfx_ms.has(sound_id) != expected_timestamp \
				or (not expected_timestamp and stream_count != 0) \
				or (sound_id == "page_turn" and require_page_stream and stream_count != 1) \
				or (sound_id == "phone_vibrate" and require_phone_stream and stream_count != 1):
			invalid.append(sound_id)
	if cue_keys != sorted_expected or not invalid.is_empty():
		_fail("%s W237 audio mismatch page=%s invalid=%s cues=%s expected=%s" % [
			label, expect_page, invalid, cue_keys, sorted_expected])
		return false
	var required_sound := "page_turn" if require_page_stream else (
		"phone_vibrate" if require_phone_stream else "")
	if not required_sound.is_empty():
		var gain := -7.0 if required_sound == "page_turn" else -8.0
		var expected_db := float(AudioManager.call("_vol_db")) \
			+ AudioManager.sfx_mix_trim_db(required_sound) + gain
		for player: AudioStreamPlayer in AudioManager._pool:
			if player.playing and player.stream == AudioManager._sounds.get(required_sound):
				if is_equal_approx(player.volume_db, expected_db):
					return true
				_fail("%s W237 %s volume expected=%s actual=%s" % [
					label, required_sound, expected_db, player.volume_db])
				return false
		_fail("%s W237 %s stream was not active" % [label, required_sound])
		return false
	return true


func _w237_surface(label: String, background_id: String, expect_score: bool) -> bool:
	var expected_stream: AudioStream = BGMPlayer.call("_load_ambience", "apartment")
	if str((_story.get("_current") as Dictionary).get("id", "")) != W237_RECORD \
			or background_id.is_empty() \
			or not _expect_surface(background_id, "apartment", label) \
			or str(_story.call("_resolved_story_surface_portrait_id")) != "player_tired" \
			or expected_stream == null \
			or BGMPlayer._ambience_player.stream != expected_stream \
			or not BGMPlayer._ambience_player.playing \
			or not str(BGMPlayer.get("_current_human_ambience_key")).is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or not str(BGMPlayer.get("_current_season_key")).is_empty() \
			or BGMPlayer._season_player.playing:
		_fail(label + " changed the W237 home, apartment bed, portrait, or lower-layer silence")
		return false
	if expect_score:
		if not _w216_score_playing():
			_fail(label + " lost the W237 held reckoning score")
			return false
	elif not str(BGMPlayer.get("_current_key")).is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail(label + " opened W237 score before source1")
		return false
	return true


func _w237_score_player() -> AudioStreamPlayer:
	var expected: AudioStream = BGMPlayer.call("_load_track", "reckoning")
	for player: AudioStreamPlayer in [BGMPlayer._player_a, BGMPlayer._player_b]:
		if expected != null and player.playing and player.stream == expected:
			return player
	return null


func _w237_wait_sfx_completion(
		sound_id: String, played_at: int, label: String) -> bool:
	var stream: AudioStream = AudioManager._sounds.get(sound_id)
	if stream == null or played_at < 0:
		_fail("%s cannot derive recorded %s completion boundary" % [label, sound_id])
		return false
	var duration_msec := int(ceil(stream.get_length() * 1000.0))
	var deadline := Time.get_ticks_msec() + maxi(250, duration_msec + 250)
	while _w197_sfx_stream_count(sound_id) > 0 \
			and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	if _w197_sfx_stream_count(sound_id) != 0 \
			or int(AudioManager._last_sfx_ms.get(sound_id, -1)) != played_at:
		_fail("%s %s did not finish naturally without replay" % [label, sound_id])
		return false
	return true


func _check_w235_notice_return() -> bool:
	_w235_cold_paper = 0
	_w235_future_paper = 0
	_w235_reflow_paper = 0
	var default_home: Dictionary = W235_HOME_CASES[1]
	var paths := 0
	var live_paper := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		if not await _w235_prepare_result(language, default_home):
			return false
		var applied := _w227_state_bytes()
		if not _w235_state_matches(applied, "W235 result entry") \
				or not await _w235_seek_paper_page(applied):
			return false
		var reveal := int(_story.get("_w235_paper_reveal_at"))
		if reveal <= 0 or not _w227_type_to(reveal - 1, "W235") \
				or not _w235_boundary_side(true) \
				or not _w235_audio_matches("none", "W235 before return clause"):
			_fail("W235 %s sounded before its localized return clause" % language)
			return false
		if not _w227_type_to(reveal, "W235"):
			return false
		var played_at := int(AudioManager._last_sfx_ms.get("paper_handle", -1))
		if played_at < 0 or not _w235_boundary_side(false) \
				or not _w235_audio_matches(
					"paper", "W235 exact return clause", true):
			_fail("W235 %s lost its exact physical paper return" % language)
			return false
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if int(AudioManager._last_sfx_ms.get("paper_handle", -1)) != played_at \
				or not await _w235_finish_result(applied, played_at) \
				or not await _w235_wait_paper_completion(played_at):
			_fail("W235 %s replayed or lost its completed paper return" % language)
			return false
		paths += 1
		live_paper += 1

	var housing_contexts := 0
	for home_case: Dictionary in W235_HOME_CASES:
		if not await _w235_prepare_result("ko", home_case):
			return false
		await get_tree().create_timer(0.9).timeout
		if not _w235_surface(
				"W235 housing " + str(home_case.get("id", "")),
				str(home_case.get("background", ""))):
			return false
		housing_contexts += 1

	var apartment_case: Dictionary = W235_HOME_CASES[3]
	if not await _w235_open("ko", apartment_case, true):
		return false
	await get_tree().create_timer(1.5).timeout
	if not _w235_surface("W235 same-key settled bed", "gangnam_apartment") \
			or BGMPlayer._ambience_tween != null and BGMPlayer._ambience_tween.is_running() \
			or not is_equal_approx(
				BGMPlayer._ambience_player.volume_db,
				float(BGMPlayer.call("_ambience_target_db"))):
		_fail("W235 inherited same-key fade stopped or kept ducking the fresh apartment bed")
		return false
	if not await _w235_read_intro("gangnam_apartment"):
		return false

	if not await _w235_prepare_result("ko", default_home):
		return false
	var skip_state := _w227_state_bytes()
	if not await _w235_seek_paper_page(skip_state):
		return false
	_w227_clear_tracked()
	_story.call("_complete_typing")
	var skip_at := int(AudioManager._last_sfx_ms.get("paper_handle", -1))
	if skip_at < 0 or not _w235_boundary_side(false) \
			or not _w235_audio_matches("paper", "W235 page completion", true) \
			or not await _w235_wait_paper_completion(skip_at):
		_fail("W235 page completion did not emit exactly one return action")
		return false

	var cold_boundaries := 0
	for before_paper: bool in [true, false]:
		if not await _w235_prepare_result("ko", default_home):
			return false
		var applied := _w227_state_bytes()
		if not await _w235_seek_paper_page(applied):
			return false
		var reveal := int(_story.get("_w235_paper_reveal_at"))
		if not _w227_type_to(reveal - 1 if before_paper else reveal, "W235"):
			return false
		if not before_paper:
			var played_at := int(AudioManager._last_sfx_ms.get("paper_handle", -1))
			if played_at < 0 or not await _w235_wait_paper_completion(played_at):
				return false
		_w227_clear_tracked()
		if not await _w235_cold_boundary(1, before_paper, applied, "ko", false):
			return false
		cold_boundaries += 1
	if not await _w235_prepare_result("ko", default_home):
		return false
	var cross_state := _w227_state_bytes()
	if not await _w235_seek_paper_page(cross_state):
		return false
	var cross_reveal := int(_story.get("_w235_paper_reveal_at"))
	if not _w227_type_to(cross_reveal - 1, "W235"):
		return false
	_w227_clear_tracked()
	if not await _w235_cold_boundary(1, true, cross_state, "en", true):
		return false
	cold_boundaries += 1
	for target_locale: String in ["ko", "en"]:
		if not await _w235_prepare_result("ko", default_home):
			return false
		var future_state := _w227_state_bytes()
		var first_page_length := str(_story.get("_type_full")).length()
		if not _w227_type_to(maxi(1, floori(float(first_page_length) / 2.0)), "W235") \
				or not await _w235_cold_boundary(
					0, true, future_state, target_locale, target_locale == "en"):
			return false
		cold_boundaries += 1

	var reflow_boundaries := 0
	for before_paper: bool in [true, false]:
		if not await _w235_prepare_result("ko", default_home):
			return false
		var applied := _w227_state_bytes()
		if not await _w235_seek_paper_page(applied):
			return false
		var reveal := int(_story.get("_w235_paper_reveal_at"))
		if not _w227_type_to(reveal - 1 if before_paper else reveal, "W235"):
			return false
		if not before_paper:
			var played_at := int(AudioManager._last_sfx_ms.get("paper_handle", -1))
			if played_at < 0 or not await _w235_wait_paper_completion(played_at):
				return false
		_w227_clear_tracked()
		if not await _w235_reflow_boundary(1, before_paper, applied):
			return false
		reflow_boundaries += 2
	if not await _w235_prepare_result("ko", default_home):
		return false
	var future_reflow_state := _w227_state_bytes()
	if not await _w235_reflow_boundary(0, true, future_reflow_state):
		return false
	reflow_boundaries += 2

	print("W235_PAPER_RETURN_OK paths=%d live_paper=%d skip_paper=1 homes=%d same_key=1 v4=%d cold_paper=%d future_paper=%d reflows=%d reflow_paper=%d" % [
		paths, live_paper, housing_contexts, cold_boundaries, _w235_cold_paper,
		_w235_future_paper, reflow_boundaries, _w235_reflow_paper])
	var counts_ok := paths == 5 and live_paper == 5 and housing_contexts == 7 \
		and cold_boundaries == 5 and _w235_cold_paper == 3 \
		and _w235_future_paper == 2 and reflow_boundaries == 6 \
		and _w235_reflow_paper == 2
	if not counts_ok:
		_fail("W235 dynamic fixture population drifted")
	return counts_ok


func _w235_read_intro(home_background: String) -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	if int(_story.call("_story_source_paragraph_count")) != 4 \
			or pages.is_empty() or not _m23_same_prose(pages, authored):
		_fail("W235 lost its filing/verdict rows plus two authored prose sources")
		return false
	var bed_stream: AudioStream = BGMPlayer._ambience_player.stream
	var bed_position := BGMPlayer._ambience_player.get_playback_position()
	while not bool(_story.get("_showing_choices")) \
			and not bool(_story.get("_pending_after_result")):
		var source := int(_story.call(
			"_story_source_paragraph_index", int(_story.get("_para_index"))))
		var expected_background := W235_NOTICE_DESK if source == 2 else home_background
		await _finish_page()
		var current_position := BGMPlayer._ambience_player.get_playback_position()
		if not _w235_surface("W235 opening source%d" % source, expected_background) \
				or not _w235_audio_matches("none", "W235 opening") \
				or BGMPlayer._ambience_player.stream != bed_stream \
				or current_position + 0.05 < bed_position:
			_fail("W235 source%d restarted or changed its single apartment bed" % source)
			return false
		bed_position = current_position
		_story.call("_on_advance")
		await _wait_stable()
	var direct_result := bool(_story.get("_pending_after_result")) \
		and int(_story.get("_pending_result_choice_index")) == 0
	return (direct_result \
		or bool(_story.get("_showing_choices")) \
			and (_story.get("_choice_box") as Control).get_child_count() == 1) \
		and _w235_surface(
			"W235 direct result" if direct_result else "W235 choices", home_background) \
		and _w235_audio_matches(
			"none", "W235 direct result" if direct_result else "W235 choices")


func _w235_prepare_result(language: String, home_case: Dictionary) -> bool:
	var home_background := str(home_case.get("background", ""))
	if not await _w235_open(language, home_case) \
			or not await _w235_read_intro(home_background):
		return false
	_w227_clear_tracked()
	if not bool(_story.get("_pending_after_result")):
		_story.call("_on_choice", 0)
		_story.set_process(false)
		await _wait_stable()
	return _w235_result_layout() \
		and GameState.chapter5_finale_receipt_matches(W235_NOTICE, 0, 235) \
		and _w235_surface("W235 prepared result", home_background) \
		and _w235_audio_matches("none", "W235 prepared result")


func _w235_result_layout() -> bool:
	var pages: Array = _story.get("_paragraphs")
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	if choices.size() != 1 or pages.is_empty():
		return false
	var authored := str(_story.call(
		"_fmt", (choices[0] as Dictionary).get("result_text", "")))
	if int(_story.call("_story_source_paragraph_count")) != 2 \
			or not _m23_same_prose(pages, authored) \
			or int(_story.get("_result_location_cut_page")) >= 0 \
			or not (_story.call("_ballpoint_write_contract") as Dictionary).is_empty():
		_fail("W235 lost its exact two-source paper-only result")
		return false
	var mapping := _w235_paper_mapping()
	if mapping.is_empty() or int(mapping.get("source", -1)) != 1:
		_fail("W235 lost its one source1 physical-return action")
		return false
	return true


func _w235_paper_mapping() -> Dictionary:
	var found: Array[Dictionary] = []
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		var source_index := int(_story.call("_story_source_paragraph_index", page_index))
		var page := str((_story.get("_paragraphs") as Array)[page_index])
		var reveal := int(_story.call("_w235_paper_reveal_position", page, page_index))
		if reveal > 0:
			found.append({"page": page_index, "reveal": reveal, "source": source_index})
	return found[0] if found.size() == 1 else {}


func _w235_seek_paper_page(
		applied: String, allow_default_name_projection: bool = false) -> bool:
	var mapping := _w235_paper_mapping()
	var target := int(mapping.get("page", -1))
	while int(_story.get("_para_index")) < target:
		await _finish_page()
		if not _w235_state_matches(
				applied, "W235 before return page", allow_default_name_projection) \
				or not _w235_audio_matches("none", "W235 before return page"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		mapping = _w235_paper_mapping()
		target = int(mapping.get("page", -1))
	if target < 0 or int(_story.get("_para_index")) != target \
			or int(_story.get("_w235_paper_reveal_at")) != int(mapping.get("reveal", -2)):
		_fail("W235 did not settle on its exact return-clause page")
		return false
	return true


func _w235_finish_result(applied: String, played_at: int) -> bool:
	while true:
		await _finish_page()
		if not _w235_surface("W235 result", _w235_current_home_background()) \
				or not _w235_state_matches(applied, "W235 result") \
				or not _w235_audio_matches("paper", "W235 result") \
				or int(AudioManager._last_sfx_ms.get("paper_handle", -1)) != played_at:
			_fail("W235 later result page replayed or lost paper_handle")
			return false
		if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
			return true
		_story.call("_on_advance")
		await _wait_stable()
	return false


func _w235_boundary_side(before_paper: bool) -> bool:
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != 0 \
			or int(_story.call(
				"_story_source_paragraph_index", int(_story.get("_para_index")))) != 1:
		return false
	var paper_range: Vector2 = _story.call("_w235_paper_progress_range")
	var context: Dictionary = _story.call("build_save_resume_context")
	var progress := float(context.get("source_text_progress", -1.0))
	if paper_range.x < 0.0 or paper_range.y < paper_range.x:
		return false
	if before_paper:
		return not bool(_story.get("_w235_paper_consumed")) \
			and int(_story.get("_w235_paper_reveal_at")) > int(_story.get("_type_pos")) \
			and progress <= paper_range.x + 0.00001
	return bool(_story.get("_w235_paper_consumed")) \
		and int(_story.get("_w235_paper_reveal_at")) < 0 \
		and progress >= paper_range.y - 0.00001


func _w235_surface(label: String, background_id: String) -> bool:
	var expected_stream: AudioStream = BGMPlayer.call("_load_ambience", "apartment")
	if str((_story.get("_current") as Dictionary).get("id", "")) != W235_NOTICE \
			or background_id.is_empty() \
			or not _expect_surface(background_id, "apartment", label) \
			or str(_story.call("_resolved_story_surface_portrait_id")) != "player_tired" \
			or expected_stream == null \
			or BGMPlayer._ambience_player.stream != expected_stream \
			or not BGMPlayer._ambience_player.playing \
			or not str(BGMPlayer.get("_current_human_ambience_key")).is_empty() \
			or BGMPlayer._human_ambience_player.playing \
			or not str(BGMPlayer.get("_current_season_key")).is_empty() \
			or BGMPlayer._season_player.playing \
			or not str(BGMPlayer.get("_current_key")).is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail(label + " changed the W235 home/desk, apartment bed, portrait, or lower-layer silence")
		return false
	return true


func _w235_current_home_background() -> String:
	return ImageRegistry.resolve_contextual_background_id("current_housing")


func _w235_audio_matches(
		mode: String, label: String, require_stream: bool = false) -> bool:
	return _finale_ink_audio_matches(
		W235_NOTICE, "W235", mode, label, require_stream, false)


func _w235_state_matches(expected: String, label: String,
		allow_default_name_projection: bool = false) -> bool:
	return _w227_state_matches(
		expected, label, allow_default_name_projection, "W235")


func _w235_wait_paper_completion(played_at: int) -> bool:
	var stream: AudioStream = AudioManager._sounds.get("paper_handle")
	if stream == null or played_at < 0:
		_fail("W235 cannot derive the recorded paper completion boundary")
		return false
	var duration_msec := int(ceil(stream.get_length() * 1000.0))
	var deadline := Time.get_ticks_msec() + maxi(250, duration_msec + 250)
	while _w197_sfx_stream_count("paper_handle") > 0 \
			and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	if _w197_sfx_stream_count("paper_handle") != 0 \
			or int(AudioManager._last_sfx_ms.get("paper_handle", -1)) != played_at:
		_fail("W235 paper return did not finish naturally without replay")
		return false
	return true


func _w235_cold_boundary(
		source_index: int, before_paper: bool, applied: String,
		target_locale: String, cross_locale: bool) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	var saved_progress := float(context.get("source_text_progress", -1.0))
	if context.get("event_id") != W235_NOTICE or context.get("phase") != "result" \
			or int(context.get("pending_result_choice_index", -1)) != 0 \
			or int(context.get("source_paragraph_index", -1)) != source_index \
			or not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("W235 could not save source%d exact typing boundary" % source_index)
		return false
	var disk: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int((disk as Dictionary).get("version", -1)) != 4:
		_fail("W235 cold boundary lost disk schema v4")
		return false
	await _remove_story()
	GameState.start_new_game()
	LocaleManager.set_language(target_locale)
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("W235 could not cold-load its typing boundary")
		return false
	BGMPlayer.set_ambience("room")
	BGMPlayer.set_season_ambience("winter")
	BGMPlayer.play_punctuation("reckoning")
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	await get_tree().create_timer(0.85).timeout
	var restored: Dictionary = _story.call("build_save_resume_context")
	var restored_progress := float(restored.get("source_text_progress", -2.0))
	var source_characters := 0
	for page_index: int in range((_story.get("_paragraphs") as Array).size()):
		if int(_story.call("_story_source_paragraph_index", page_index)) == source_index:
			source_characters += str((_story.get("_paragraphs") as Array)[page_index]).length()
	var quantization_bound := 0.5 / float(source_characters) + 0.000001 \
		if source_characters > 0 else -1.0
	var progress_ok := is_equal_approx(restored_progress, saved_progress) \
		if not cross_locale else quantization_bound > 0.0 \
			and absf(restored_progress - saved_progress) <= quantization_bound
	var boundary_ok := false
	if source_index == 0:
		boundary_ok = not bool(_story.get("_w235_paper_consumed")) \
			and int(_story.get("_w235_paper_reveal_at")) < 0
	else:
		boundary_ok = _w235_boundary_side(before_paper and not cross_locale)
		if cross_locale:
			boundary_ok = bool(_story.get("_w235_paper_consumed")) \
				and int(_story.get("_w235_paper_reveal_at")) < 0
	if LocaleManager.language != target_locale or restored.get("event_id") != W235_NOTICE \
			or restored.get("phase") != "result" \
			or int(restored.get("pending_result_choice_index", -1)) != 0 \
			or int(restored.get("source_paragraph_index", -1)) != source_index \
			or not progress_ok or not boundary_ok \
			or not _w235_state_matches(applied, "W235 cold result", cross_locale) \
			or not _w235_surface("W235 cold result", _w235_current_home_background()) \
			or not _w235_audio_matches("none", "W235 cold result"):
		_fail("W235 cold boundary crossed, replayed, changed state, or lost source identity")
		return false
	var played_at := -1
	if source_index == 0:
		if not await _w235_seek_paper_page(applied, cross_locale):
			return false
		var reveal := int(_story.get("_w235_paper_reveal_at"))
		if reveal <= 0 or not _w227_type_to(reveal - 1, "W235") \
				or bool(_story.get("_w235_paper_consumed")) \
				or not _w227_type_to(reveal, "W235"):
			_fail("W235 cold source0 lost its definitely future source1 return")
			return false
		played_at = int(AudioManager._last_sfx_ms.get("paper_handle", -1))
		if played_at < 0 or not _w235_audio_matches(
				"paper", "W235 cold future return", true):
			return false
		_w235_cold_paper += 1
		_w235_future_paper += 1
	elif before_paper and not cross_locale:
		var reveal := int(_story.get("_w235_paper_reveal_at"))
		if not _w227_type_to(reveal, "W235") \
				or not _w235_audio_matches(
					"paper", "W235 cold pending return", true):
			_fail("W235 same-locale cold restore lost its pending paper action")
			return false
		played_at = int(AudioManager._last_sfx_ms.get("paper_handle", -1))
		_w235_cold_paper += 1
	else:
		_story.call("_complete_typing")
		_story.call("_complete_typing")
		if not _w235_audio_matches("none", "W235 cold consumed completion"):
			_fail("W235 cold consumed boundary replayed a past paper action")
			return false
	if played_at >= 0 and not await _w235_wait_paper_completion(played_at):
		return false
	return _w235_state_matches(applied, "W235 cold final", cross_locale) \
		and _w235_surface("W235 cold final", _w235_current_home_background())


func _w235_reflow_boundary(
		source_index: int, before_paper: bool, applied: String) -> bool:
	_story.call("_set_story_text_size", "large")
	await _wait_stable()
	var font_ok := not bool(_story.get("_w235_paper_consumed")) \
		and int(_story.get("_w235_paper_reveal_at")) < 0 if source_index == 0 \
		else _w235_boundary_side(before_paper)
	if not font_ok or not _w235_state_matches(applied, "W235 font reflow") \
			or not _w235_surface("W235 font reflow", _w235_current_home_background()) \
			or not _w235_audio_matches("none", "W235 font reflow"):
		_fail("W235 source%d font reflow crossed or replayed its paper boundary" % source_index)
		return false
	_story.call("_set_story_language", "en")
	await _wait_stable()
	var locale_ok := not bool(_story.get("_w235_paper_consumed")) \
		and int(_story.get("_w235_paper_reveal_at")) < 0 if source_index == 0 \
		else _w235_boundary_side(before_paper)
	if LocaleManager.language != "en" or not locale_ok \
			or not _w235_state_matches(applied, "W235 locale reflow", true) \
			or not _w235_surface("W235 locale reflow", _w235_current_home_background()) \
			or not _w235_audio_matches("none", "W235 locale reflow"):
		_fail("W235 source%d locale reflow crossed or replayed its paper boundary" % source_index)
		return false
	if source_index == 0:
		if not await _w235_seek_paper_page(applied, true):
			return false
		var reveal := int(_story.get("_w235_paper_reveal_at"))
		if reveal <= 0 or not _w227_type_to(reveal, "W235") \
				or not _w235_audio_matches(
					"paper", "W235 reflow future return", true):
			_fail("W235 source0 reflow consumed or lost future source1 paper")
			return false
		_w235_reflow_paper += 1
		return await _w235_wait_paper_completion(
			int(AudioManager._last_sfx_ms.get("paper_handle", -1)))
	if before_paper:
		var reveal := int(_story.get("_w235_paper_reveal_at"))
		if not _w227_type_to(reveal, "W235") \
				or not _w235_audio_matches(
					"paper", "W235 reflow pending return", true):
			_fail("W235 source1 reflow lost its one remaining paper action")
			return false
		_w235_reflow_paper += 1
		return await _w235_wait_paper_completion(
			int(AudioManager._last_sfx_ms.get("paper_handle", -1)))
	_story.call("_complete_typing")
	_story.call("_complete_typing")
	return _w235_audio_matches("none", "W235 reflow consumed completion")

func _check_w220_receipt() -> bool:
	var paths: int = 0
	var skips: int = 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice: int in ([0, 1, 2] if language == "ko" else [1]):
			if not await _w220_receipt_route(language, choice):
				return false
			if choice != 1:
				skips += 1
				continue
			var current: Dictionary = _story.get("_current")
			var choices: Array = current.get("choices", [])
			if choices.size() != 1 or current.has("chapter5_causal_reads") \
					or not await _w220_receipt_read(false, 3, str(current.get("description", ""))):
				_fail("W220 lost its three unprefixed description sources")
				return false
			_story.call("_on_advance")
			await _wait_stable()
			if bool(_story.get("_showing_choices")) or int(_story.get("_pending_result_choice_index")) != 0 \
					or not await _w220_receipt_read(true, 2, str((choices[0] as Dictionary).get("result_text", ""))) \
					or GameState.chapter5_causal_selected_choice(W220_CONSENT_RECEIPT) != 0:
				_fail("W220 lost its single direct-progress result or exact receipt")
				return false
			paths += 1
	if paths != 5 or skips != 2 or _w220_receipt_cold_count != 15:
		_fail("W220 fixture population drifted paths=%d skips=%d v4=%d" % [paths, skips, _w220_receipt_cold_count])
		return false
	if _failures != 0:
		return false
	print("W220_RECEIPT_OK paths=%d skips=%d paper=5 reentry=5 v4=%d" % [paths, skips, _w220_receipt_cold_count])
	return true

func _w220_receipt_route(language: String, choice: int) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W220/W219-c%d" % [language, choice]
	_w220_receipt_paper_expected = false
	GameState.returning_from_story = false
	LocaleManager.set_language(language)
	if not _prepare_full_owner_history(219, []):
		return false
	GameState.money = 2_100_000_000.0
	GameState.housing = "oneroom"
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(CHAPTER5_ROUTE.default_state(),
		195, "투자형", true, true, GameState.get_total_asset_value())
	if not bool(locked.get("ok", false)):
		_fail("W220 could not lock the actual Chapter 5 route")
		return false
	var state: Dictionary = locked["state"]
	for index: int in range(CHAPTER5_ROUTE.OWNED_EVENT_IDS.find(W219_MEETING_DECISION)):
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(state,
			CHAPTER5_ROUTE.OWNED_EVENT_IDS[index], 0, CHAPTER5_ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("W220 could not bind predecessor index%d" % index)
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	if not await _w216_open_owned_root(W219_MEETING_DECISION) \
			or not await _w220_receipt_finish_predecessor(false):
		return false
	_story.call("_on_advance")
	await _wait_stable()
	if not bool(_story.get("_showing_choices")):
		_fail("W220 predecessor lost its three choices")
		return false
	_story.call("_on_choice", choice)
	await _wait_stable()
	if GameState.chapter5_causal_selected_choice(W219_MEETING_DECISION) != choice \
			or not await _w220_receipt_finish_predecessor(true):
		return false
	_story.call("_on_advance")
	await _wait_stable()
	if not FULL_STORY_FLOW.ready_to_advance() or not FULL_STORY_FLOW.apply_background_for_turn(219):
		_fail("W220 predecessor did not close its actual FullStoryFlow result")
		return false
	GameState.advance_calendar()
	if GameState.turn != 220 or not FULL_STORY_FLOW.complete_turn(219):
		_fail("W220 exact calendar advance failed")
		return false
	await _remove_story()
	var expected_id: String = W220_CONSENT_RECEIPT if choice == 1 else ""
	if GameState.chapter5_causal_next_event_for_turn() != expected_id \
			or GameState.chapter5_causal_ingress_available(W220_CONSENT_RECEIPT) != (choice == 1):
		_fail("W220 admission did not read the actual W219 choice")
		return false
	if choice != 1:
		return true
	_w197_clear_paper()
	return await _w216_open_owned_root(W220_CONSENT_RECEIPT)

func _w220_receipt_finish_predecessor(result: bool) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	if pages.is_empty():
		_fail("W220 predecessor has no readable pages")
		return false
	for page: int in range(pages.size()):
		await _finish_page()
		var image: TextureRect = _story.get("_bg_img")
		if int(_story.get("_para_index")) != page or bool(_story.get("_pending_after_result")) != result \
				or str((_story.get("_current") as Dictionary).get("id", "")) != W219_MEETING_DECISION \
				or image.texture == null or image.texture.resource_path != ImageRegistry.get_cg("cg_y5_three_in_room") \
				or str(BGMPlayer.get("_current_ambience_key")) != "office":
			_fail("W220 predecessor changed its real pages, ensemble CG or office")
			return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	return true

func _w220_receipt_read(result: bool, source_count: int, prose: String) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var applied: Dictionary = _w196_applied_state()
	var label: String = "result" if result else "prose"
	if pages.is_empty() or int(_story.call("_story_source_paragraph_count")) != source_count \
			or not _m23_same_prose(pages, str(_story.call("_fmt", prose))):
		_fail("W220 changed its authored %s prose or source count" % label)
		return false
	var probed_before: bool = false
	var probed_after: bool = false
	for page: int in range(pages.size()):
		await _finish_page()
		var source: int = int(_story.call("_story_source_paragraph_index", page))
		if not result and source == 2 and not probed_after:
			_w220_receipt_paper_expected = true
			var last_paper: int = int(AudioManager._last_sfx_ms.get("paper_handle", -1))
			_story.call("_play_current_paragraph_audio", 2)
			_story.call("_play_current_paragraph_audio", 2)
			if last_paper < 0 or int(AudioManager._last_sfx_ms.get("paper_handle", -1)) != last_paper:
				_fail("W220 source2 repeated or failed to play its physical paper handling")
		if int(_story.get("_para_index")) != page or bool(_story.get("_pending_after_result")) != result \
				or not _w196_state_matches(applied, "W220 " + label) or not _w220_receipt_surface(label):
			return false
		var last_in_source: bool = page + 1 == pages.size() \
			or int(_story.call("_story_source_paragraph_index", page + 1)) != source
		if not result and source == 1 and last_in_source and not probed_before:
			if not await _w220_receipt_cold(false, "before_paper"):
				return false
			probed_before = true
		if not result and source == 2 and not probed_after:
			if not await _w220_receipt_cold(false, "after_paper"):
				return false
			probed_after = true
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	if result:
		return await _w220_receipt_cold(true, "result")
	return probed_before and probed_after

func _w220_receipt_surface(label: String) -> bool:
	var portrait: TextureRect = _story.get("_portrait")
	if not _expect_surface("meeting", "office", "W220 " + label) \
			or not str(_story.get("_event_cg_id")).is_empty() \
			or not str(_story.call("_resolved_story_surface_portrait_id")).is_empty() \
			or portrait.texture != null or (_story.get("_portrait_frame") as Control).visible:
		_fail("W220 lost its meeting room or added an ensemble image/portrait")
		return false
	var expected_tokens: Array = [W220_CONSENT_RECEIPT + "::description:2:0:paper_handle"] \
		if _w220_receipt_paper_expected else []
	if AudioManager._story_audio_seen.keys() != expected_tokens \
			or AudioManager._last_sfx_ms.has("paper_handle") != _w220_receipt_paper_expected:
		_fail("W220 %s changed its paper timing/count: %s" % [label, AudioManager._story_audio_seen.keys()])
	if not _w216_score_playing():
		_fail("W220 %s lost its actual reckoning playback" % label)
	return true

func _w220_receipt_cold(result: bool, boundary: String) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	var applied: Dictionary = _w196_applied_state()
	var phase: String = "result" if result else "prose"
	if context.get("event_id") != W220_CONSENT_RECEIPT or context.get("phase") != phase \
			or not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("W220 could not save its live " + boundary)
		return false
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int((disk as Dictionary).get("version", -1)) != 4:
		_fail("W220 lost its actual v4 disk format")
		return false
	await _remove_story()
	_w197_clear_paper()
	GameState.start_new_game()
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("W220 could not load its live " + boundary)
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	await get_tree().create_timer(0.85).timeout
	var restored: Dictionary = _story.call("build_save_resume_context")
	if restored.get("event_id") != W220_CONSENT_RECEIPT or restored.get("phase") != phase \
			or restored.get("source_paragraph_index") != context.get("source_paragraph_index") \
			or not is_equal_approx(float(restored.get("source_text_progress", -1.0)), float(context.get("source_text_progress", -2.0))) \
			or not _w196_state_matches(applied, "W220 cold " + boundary):
		_fail("W220 cold %s changed source progress, choice effects or its real receipt" % boundary)
		return false
	_w220_receipt_paper_expected = false
	if not _w220_receipt_surface("cold " + boundary):
		return false
	_w220_receipt_cold_count += 1
	print("W220_COLD_BOUNDARY_PROBED locale=%s boundary=%s source=%s" % [
		LocaleManager.language, boundary, restored.get("source_paragraph_index")])
	return true

func _check_w216_landing() -> bool:
	var capture_dir := OS.get_environment("GANGNAM_W216_CAPTURE_DIR")
	if not capture_dir.is_empty():
		var output := DirAccess.open(capture_dir) if capture_dir.is_absolute_path() else null
		if output == null or not output.get_files().is_empty() or not output.get_directories().is_empty() \
				or DisplayServer.get_name() == "headless":
			_fail("W216 capture requires a fresh absolute output and a rendering display")
			return false
		OS.low_processor_usage_mode = false
		if OS.get_environment("GANGNAM_W216_CAPTURE_COMPACT") == "1":
			DisplayServer.window_set_size(Vector2i(960, 600))
			await get_tree().process_frame
	var paths := 0
	var skips := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice in ([0, 1, 2] if language == "ko" else [0]):
			if not await _w216_route_from_w215(language, int(choice)):
				return false
			if choice != 0:
				skips += 1
				continue
			var current: Dictionary = _story.get("_current")
			var choices: Array = current.get("choices", [])
			if choices.size() != 1 or not await _w216_read_phase(false, 3, str(current.get("description", "")), capture_dir):
				return false
			_story.call("_on_advance")
			await _wait_stable()
			if bool(_story.get("_showing_choices")) or int(_story.get("_pending_result_choice_index")) != 0 \
					or not await _w216_read_phase(true, 2, str((choices[0] as Dictionary).get("result_text", "")), capture_dir) \
					or GameState.chapter5_causal_selected_choice(W216_REVIEW) != 0:
				_fail("W216 lost the authored single direct-progress result")
				return false
			paths += 1
	var expected_captures := 0 if capture_dir.is_empty() else paths * 2
	if paths != 5 or skips != 2 or (not capture_dir.is_empty() \
			and DirAccess.get_files_at(capture_dir).size() != expected_captures):
		_fail("W216 did not cover five locales, two branch skips and both capture phases")
		return false
	if _failures != 0:
		return false
	print("W216_LANDING_OK paths=%d skips=%d captures=%d v4=%d" % [paths, skips, expected_captures, _w216_cold_count])
	return true

func _w216_route_from_w215(language: String, choice: int) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W216/W215-c%d" % [language, choice]
	_w216_cold_restored = false
	# The static fixture observes the real return without mounting MainGame,
	# so clear its consumed handoff before preparing the next independent run.
	GameState.returning_from_story = false
	LocaleManager.set_language(language)
	if not _prepare_full_owner_history(215, []):
		return false
	GameState.money = 2_100_000_000.0
	GameState.housing = "oneroom"
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true, GameState.get_total_asset_value())
	if not bool(locked.get("ok", false)):
		_fail("W216 fixture could not lock the actual Chapter 5 route")
		return false
	var state: Dictionary = locked["state"]
	for index in range(CHAPTER5_ROUTE.OWNED_EVENT_IDS.find(W215_OLD_OFFICE)):
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(state,
			CHAPTER5_ROUTE.OWNED_EVENT_IDS[index], 0, CHAPTER5_ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("W216 fixture could not bind predecessor index %d" % index)
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	if not await _w216_open_owned_root(W215_OLD_OFFICE) or not await _read_phase("office", "office", false):
		return false
	_story.call("_on_advance")
	await _wait_stable()
	if not bool(_story.get("_showing_choices")):
		_fail("W216 predecessor did not offer its three live choices")
		return false
	_story.call("_on_choice", choice)
	await _wait_stable()
	if GameState.chapter5_causal_selected_choice(W215_OLD_OFFICE) != choice \
			or not await _read_phase("office", "office", true):
		return false
	_story.call("_on_advance")
	await _wait_stable()
	if not FULL_STORY_FLOW.ready_to_advance() or not FULL_STORY_FLOW.apply_background_for_turn(215):
		_fail("W216 predecessor did not close its real FullStoryFlow chain")
		return false
	GameState.advance_calendar()
	if GameState.turn != 216 or not FULL_STORY_FLOW.complete_turn(215):
		_fail("W216 exact calendar advance failed")
		return false
	await _remove_story()
	var expected_id := W216_REVIEW if choice == 0 else ""
	if GameState.chapter5_causal_next_event_for_turn() != expected_id \
			or GameState.chapter5_causal_ingress_available(W216_REVIEW) != (choice == 0):
		_fail("W216 ingress did not read the exact W215 choice")
		return false
	if choice != 0:
		return true
	_w197_clear_paper()
	AudioManager.stop_sound("door_latch")
	AudioManager._last_sfx_ms.erase("door_latch")
	BGMPlayer.set_ambience("office")
	BGMPlayer.set_season_ambience("winter")
	return await _w216_open_owned_root(W216_REVIEW)

func _w216_open_owned_root(event_id: String) -> bool:
	var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
	ingress.set_meta("_screenshot_qa_static_surface", true)
	var routed := bool(ingress.call("_route_chapter5_causal_week"))
	ingress.free()
	if not routed or GameState.pending_story_queue != [event_id] or not FULL_STORY_FLOW.valid_session():
		_fail("%s did not route through its normal Chapter 5 and FullStoryFlow owner" % event_id)
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	return str((_story.get("_current") as Dictionary).get("id", "")) == event_id

func _w216_read_phase(result: bool, source_count: int, prose: String, capture_dir: String) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var label := "result" if result else "opening"
	if int(_story.call("_story_source_paragraph_count")) != source_count \
			or not _m23_same_prose(pages, str(_story.call("_fmt", prose))) or pages.is_empty():
		_fail("W216 changed its authored %s prose, sources or pagination" % label)
		return false
	for page in range(pages.size()):
		await _finish_page()
		var portrait := _story.get("_portrait") as TextureRect
		var portrait_frame := _story.get("_portrait_frame") as Control
		var expected_cues := [] if _w216_cold_restored else [W216_REVIEW + "::description:0:0:paper_handle"]
		if int(_story.get("_para_index")) != page or bool(_story.get("_pending_after_result")) != result \
				or not _expect_surface(W216_LANDING, "", label) \
				or not str(_story.call("_resolved_story_surface_portrait_id")).is_empty() \
				or portrait.texture != null or portrait_frame.visible \
				or not _w216_score_playing() \
				or BGMPlayer._ambience_player.playing or BGMPlayer._human_ambience_player.playing \
				or BGMPlayer._season_player.playing \
				or AudioManager._story_audio_seen.keys() != expected_cues \
				or AudioManager._last_sfx_ms.has("paper_handle") == _w216_cold_restored \
				or AudioManager._last_sfx_ms.has("door_latch"):
			_fail("W216 %s lost its unoccupied landing, silent room, score or source0 paper-only audio %s" % [label, {
				"page_expected": page, "pending_result": _story.get("_pending_after_result"),
				"portrait": _story.call("_resolved_story_surface_portrait_id"), "portrait_visible": portrait_frame.visible,
				"score": BGMPlayer._current_key, "ambience": BGMPlayer._ambience_player.playing,
				"human": BGMPlayer._human_ambience_player.playing, "season": BGMPlayer._season_player.playing,
				"music_mode": BGMPlayer.get("_music_mode"), "active_score": BGMPlayer.get("_active_key"),
				"fade_running": BGMPlayer._fade_tween != null and BGMPlayer._fade_tween.is_running(),
				"cues": AudioManager._story_audio_seen.keys(), "paper": AudioManager._last_sfx_ms.get("paper_handle", -1),
				"door": AudioManager._last_sfx_ms.get("door_latch", -1),
			}])
			return false
		if not capture_dir.is_empty() and page == (pages.size() - 1 if result else 0) \
				and not await _save_viewport_frame(capture_dir.path_join("%s_%s.png" % [LocaleManager.language, label])):
			return false
		if LocaleManager.language == "ko" and not result and page == 0 \
				and OS.has_environment("GANGNAM_W216_COLD_SOURCE0_CHECK") \
				and not await _w216_probe_cold_restore(false):
			return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	if LocaleManager.language == "ko" and OS.has_environment("GANGNAM_W216_COLD_CHECK"):
		return await _w216_probe_cold_restore(result)
	return true

func _w216_probe_cold_restore(result: bool) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	var applied := _w196_applied_state()
	var label := "result" if result else "prose"
	if context.get("event_id") != W216_REVIEW or context.get("phase") != label \
			or not SaveManager.save_game(W8_QA_SLOT, context, {"qa_fixture": true}):
		_fail("W216 could not save the live %s boundary" % label)
		return false
	var disk: Variant = JSON.parse_string(FileAccess.get_file_as_string(SaveManager.slot_path(W8_QA_SLOT)))
	if not disk is Dictionary or int(disk.get("version", -1)) != 4:
		_fail("W216 cold boundary lost the existing v4 disk schema")
		return false
	await _remove_story()
	_w197_clear_paper()
	AudioManager.stop_sound("door_latch")
	AudioManager._last_sfx_ms.erase("door_latch")
	GameState.start_new_game()
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("W216 cold load failed for the live %s boundary" % label)
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	_story.set_meta("_screenshot_qa_static_surface", true)
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	# The old-screen fade completed after 0.75 seconds and silently stopped the
	# restored same-key score. Check beyond it, not only in the first good frame.
	await get_tree().create_timer(0.85).timeout
	var restored: Dictionary = _story.call("build_save_resume_context")
	var portrait := _story.get("_portrait") as TextureRect
	if restored.get("event_id") != W216_REVIEW or restored.get("phase") != label \
			or restored.get("source_paragraph_index") != context.get("source_paragraph_index") \
			or not is_equal_approx(float(restored.get("source_text_progress", -1.0)), float(context.get("source_text_progress", -2.0))) \
			or not _w196_state_matches(applied, "W216 cold " + label) \
			or not _expect_surface(W216_LANDING, "", "W216 cold " + label) \
			or portrait.texture != null or (_story.get("_portrait_frame") as Control).visible \
			or not _w216_score_playing() or BGMPlayer._ambience_player.playing \
			or BGMPlayer._human_ambience_player.playing or BGMPlayer._season_player.playing:
		_fail("W216 cold %s changed source progress, state or the empty quiet landing" % label)
		return false
	# Keep probing the other phase after an audio-only failure; the enclosing
	# scope still fails and emits no success marker if either replayed a cue.
	if AudioManager._last_sfx_ms.has("paper_handle") or AudioManager._last_sfx_ms.has("door_latch"):
		_fail("W216 cold %s replayed a past paper/door cue: %s" % [label, AudioManager._story_audio_seen.keys()])
	_w216_cold_restored = true
	_w216_cold_count += 1
	print("W216_COLD_BOUNDARY_PROBED phase=%s score=%s mode=%s fade_running=%s" % [label,
		BGMPlayer._current_key, BGMPlayer.get("_music_mode"),
		BGMPlayer._fade_tween != null and BGMPlayer._fade_tween.is_running()])
	return true

func _w216_score_playing() -> bool:
	if BGMPlayer._current_key != "reckoning":
		return false
	# Looping streams are cached duplicates with no resource_path; compare the
	# actual playing stream to the recorded track's configured instance.
	var expected: AudioStream = BGMPlayer.call("_load_track", "reckoning")
	for player: AudioStreamPlayer in [BGMPlayer._player_a, BGMPlayer._player_b]:
		if expected != null and player.playing and player.stream == expected:
			return true
	return false

func _w208_open(language: String, producer_choice: int) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W208/producer%d" % [language, producer_choice]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	SaveManager.set_setting("story_text_size", "standard")
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 208
	GameState.age = 37
	GameState.month = 4
	GameState.week_of_month = 4
	GameState.housing = "oneroom"
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.flags["route_invest"] = true
	for flag in [
		"arc_sangchul_met_seen", "arc_daeun_met", "daeun_romance_started",
		"arc_minseo_02_seen", "arc_jaehyuk_reunion_seen", "arc_jaehyuk_aftermath_seen",
	]:
		GameState.flags[flag] = true
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true,
		GameState.get_total_asset_value())
	if not bool(locked.get("ok", false)):
		_fail("W208 fixture could not lock the actual Chapter 5 route")
		return false
	var state: Dictionary = locked["state"]
	for step in [[0, 2], [1, 1], [2, 0], [3, 2], [4, 1], [5, 0], [6, 0], [7, producer_choice]]:
		var index := int(step[0])
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(
			state, CHAPTER5_ROUTE.OWNED_EVENT_IDS[index], int(step[1]),
			CHAPTER5_ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("W208 fixture could not commit predecessor %d/%d" % [index, step[1]])
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	if GameState.chapter5_causal_next_event_for_turn() != W208_DELIVERY \
			or int(GameState.chapter5_causal_selected_choice(W207_OFFER)) != producer_choice:
		_fail("W208 predecessor receipt did not admit the reference delivery")
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.pending_story_queue = [W208_DELIVERY]
	_w208_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if not _w208_surface("W208 opening") or not _w208_audio_matches(false, "W208 opening"):
		return false
	return true

func _w208_layout(producer_choice: int) -> bool:
	var current: Dictionary = _story.get("_current")
	var authored := str(_story.call("_fmt", current.get("description", "")))
	var pages: Array = _story.get("_paragraphs")
	var reads: Dictionary = current.get("chapter5_causal_reads", {})
	var rows: Array = reads.get("texts", [])
	var expected_prefix := ""
	if rows.size() == 1 and rows[0] is Array and producer_choice < (rows[0] as Array).size():
		expected_prefix = str(_story.call("_fmt", (rows[0] as Array)[producer_choice])).strip_edges()
	var sources := authored.split("\n\n")
	var anchor := str(_story.call("_fmt", (W208_DOCUMENT_SCAN.get_meta(
		"reveal_anchors", {}) as Dictionary).get(LocaleManager.language, "")))
	var scan: Dictionary = _w208_scan_mapping()
	return int(_story.call("_story_source_paragraph_count")) == 4 \
		and sources.size() == 4 and str(sources[0]).strip_edges() == expected_prefix \
		and not pages.is_empty() and _m23_same_prose(pages, authored) \
		and int(_story.get("_result_location_cut_page")) < 0 \
		and not anchor.is_empty() and sources[1].count(anchor) == 1 \
		and int(scan.get("page", -1)) > 0 and int(scan.get("reveal", -1)) > 0

func _w208_scan_page() -> int:
	return int(_w208_scan_mapping().get("page", -1))

func _w208_scan_mapping() -> Dictionary:
	var anchor := str(_story.call("_fmt", (W208_DOCUMENT_SCAN.get_meta(
		"reveal_anchors", {}) as Dictionary).get(LocaleManager.language, "")))
	var authored := str(_story.call("_fmt", (_story.get("_current") as Dictionary).get(
		"description", "")))
	var sources := authored.split("\n\n")
	if anchor.is_empty() or sources.size() != 4 or sources[1].count(anchor) != 1:
		return {}
	var source := str(sources[1])
	var anchor_end := source.find(anchor) + anchor.length()
	var pages: Array = _story.get("_paragraphs")
	var cursor := 0
	for page in range(pages.size()):
		if int(_story.call("_story_source_paragraph_index", page)) != 1:
			continue
		var page_text := str(pages[page])
		var page_start := source.find(page_text, cursor)
		if page_start < 0:
			return {}
		var page_end := page_start + page_text.length()
		if anchor_end > page_start and anchor_end <= page_end:
			return {"page": page, "reveal": anchor_end - page_start}
		cursor = page_end
	return {}

func _w208_before_scan_page() -> bool:
	return _w208_layout(int(GameState.chapter5_causal_selected_choice(W207_OFFER))) \
		and int(_story.get("_para_index")) == _w208_scan_page() - 1

func _w208_at_scan_page(require_pending: bool) -> bool:
	var page := int(_story.get("_para_index"))
	if not _w208_layout(int(GameState.chapter5_causal_selected_choice(W207_OFFER))) \
			or page != _w208_scan_page():
		return false
	var reveal := int(_story.get("_w208_scan_reveal_at"))
	return (reveal > int(_story.get("_type_pos"))) if require_pending else reveal < 0

func _w208_seek_before_scan(applied: Dictionary) -> bool:
	var target := _w208_scan_page() - 1
	while int(_story.get("_para_index")) < target:
		await _finish_page()
		if not _w208_surface("W208 approach to scan") \
				or not _w196_state_matches(applied, "W208 approach to scan") \
				or not _w208_audio_matches(false, "W208 approach to scan"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		target = _w208_scan_page() - 1
	if not _w208_before_scan_page():
		_fail("W208 did not settle on the physical page before its scan clause")
		return false
	return true

func _w208_type_to(target: int) -> bool:
	var guard := 0
	while int(_story.get("_type_pos")) < target and guard < 4096:
		var before := int(_story.get("_type_pos"))
		_story.call("_process", float(_story.call("_direction_type_interval")))
		if int(_story.get("_type_pos")) == before:
			_story.call("_process", 0.001)
		guard += 1
	if int(_story.get("_type_pos")) != target:
		_fail("W208 typewriter skipped its exact scan threshold target=%d actual=%d" % [
			target, int(_story.get("_type_pos"))])
		return false
	return true

func _w208_reload_typing_boundary(before_scan: bool, applied: Dictionary) -> bool:
	var saved_context: Dictionary = _story.call("build_save_resume_context")
	var event_count := GameState.event_log.size()
	var saved_progress := float(saved_context.get("source_text_progress", -1.0))
	_w208_clear_tracked()
	if saved_context.get("event_id") != W208_DELIVERY \
			or saved_context.get("phase") != "prose" \
			or int(saved_context.get("source_paragraph_index", -1)) != 1 \
			or not bool(saved_context.get("paragraph_was_typing", false)) \
			or not SaveManager.save_game(W8_QA_SLOT, saved_context, {"qa_fixture": true}):
		_fail("W208 could not save its %s-scan typing boundary" % (
			"before" if before_scan else "after"))
		return false
	await _remove_story()
	GameState.start_new_game()
	if not SaveManager.load_game(W8_QA_SLOT):
		_fail("W208 could not cold load its typing boundary")
		return false
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.set_process(false)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	var restored: Dictionary = _story.call("build_save_resume_context")
	var reveal := int(_story.get("_w208_scan_reveal_at"))
	var pending_matches := reveal > int(_story.get("_type_pos")) \
		if before_scan else reveal < 0 and bool(_story.get("_w208_scan_consumed"))
	if restored.get("event_id") != W208_DELIVERY or restored.get("phase") != "prose" \
			or int(restored.get("source_paragraph_index", -1)) != 1 \
			or not bool(restored.get("paragraph_was_typing", false)) \
			or not is_equal_approx(float(restored.get("source_text_progress", -2.0)), saved_progress) \
			or not pending_matches or GameState.event_log.size() != event_count \
			or not _w208_surface("W208 cold typing boundary") \
			or not _w196_state_matches(applied, "W208 cold typing boundary") \
			or not _w208_audio_matches(false, "W208 cold typing boundary"):
		_fail("W208 cold %s-scan boundary changed progress, sounded, or lost one-shot state" % (
			"before" if before_scan else "after"))
		return false
	return true

func _w208_reflow_pending(applied: Dictionary) -> bool:
	for level in ["large", "standard"]:
		_w208_clear_tracked()
		_story.call("_set_story_text_size", level)
		await _wait_stable()
		if not _w208_at_scan_page(true) \
				or not _w208_surface("W208 pending text reflow") \
				or not _w196_state_matches(applied, "W208 pending text reflow") \
				or not _w208_audio_matches(false, "W208 pending text reflow"):
			_fail("W208 text reflow crossed or lost its pending scan boundary")
			return false
	return true

func _w208_reflow_consumed(applied: Dictionary) -> bool:
	for level in ["large", "standard"]:
		_w208_clear_tracked()
		_story.call("_set_story_text_size", level)
		await _wait_stable()
		if not _w208_at_scan_page(false) \
				or not _w208_surface("W208 consumed text reflow") \
				or not _w196_state_matches(applied, "W208 consumed text reflow") \
				or not _w208_audio_matches(false, "W208 consumed text reflow"):
			_fail("W208 text reflow replayed its consumed scan boundary")
			return false
	return true

func _w208_finish_intro_without_duplicate(applied: Dictionary, played_at: int) -> bool:
	while not bool(_story.get("_showing_choices")):
		await _finish_page()
		if not _w208_surface("W208 after scan") \
				or not _w196_state_matches(applied, "W208 after scan"):
			return false
		if played_at >= 0 and int(AudioManager._last_sfx_ms.get("document_scan", -1)) != played_at:
			_fail("W208 later prose replayed its document scan")
			return false
		for sound_id in ["register_scan", "page_turn", "paper_handle"]:
			if AudioManager._last_sfx_ms.has(sound_id) or _w197_sfx_stream_count(sound_id) != 0:
				_fail("W208 later prose emitted stale %s" % sound_id)
				return false
		if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
			_story.call("_on_advance")
			await _wait_stable()
			break
		_story.call("_on_advance")
		await _wait_stable()
	var reached := (bool(_story.get("_showing_choices")) \
		and (_story.get("_choice_box") as Control).get_child_count() == 1) \
		or (bool(_story.get("_pending_after_result")) \
		and int(_story.get("_pending_result_choice_index")) == 0)
	if not reached:
		_fail("W208 scan continuation did not reach or directly apply its single authored choice")
	return reached

func _w208_surface(label: String) -> bool:
	var portrait := _story.get("_portrait") as TextureRect
	if str((_story.get("_current") as Dictionary).get("id", "")) != W208_DELIVERY \
			or str(_story.get("_event_background_id")) != "meeting" \
			or str(BGMPlayer.get("_current_ambience_key")) != "office" \
			or not str(BGMPlayer.get("_current_key")).is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing \
			or str(_story.call("_resolved_story_surface_portrait_id")) != "player_determined" \
			or not (_story.get("_portrait_frame") as Control).visible \
			or portrait.texture == null \
			or portrait.texture.resource_path != ImageRegistry.get_portrait("player_determined"):
		_fail("%s changed W208 meeting/office/player/silent-score surface" % label)
		return false
	return true

func _w208_clear_tracked() -> void:
	for sound_id in W208_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)

func _w208_audio_matches(expect_scan: bool, label: String) -> bool:
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		if not str(key).begins_with(W208_DELIVERY + ":"):
			return false
		for sound_id in W208_TRACKED_SFX:
			if str(key).ends_with(":" + sound_id):
				return true
		return false)
	var invalid: Array[String] = []
	for sound_id in W208_TRACKED_SFX:
		var expected: bool = expect_scan and sound_id == "document_scan"
		if AudioManager._last_sfx_ms.has(sound_id) != expected \
				or _w197_sfx_stream_count(sound_id) != (1 if expected else 0):
			invalid.append(sound_id)
	if not invalid.is_empty() or not cue_keys.is_empty():
		_fail("%s W208 cue mismatch invalid=%s authored=%s" % [label, invalid, cue_keys])
		return false
	return true

func _check_w200_pencil_audio() -> bool:
	var contract: Dictionary = BGMPlayer.scene_audio_contract(W200_BOUNDARY)
	if str(contract.get("ambience", "")) != "cafe" \
			or contract.get("music", {}) != {"key": "reckoning", "start_paragraph": 2.0} \
			or contract.has("paragraph_cues") or contract.has("result_paragraph_cues"):
		_fail("W200 changed its cafe/reckoning contract or retained an authored cup/paper cue")
		return false
	for key in ["underline_anchors", "vertical_anchors"]:
		var anchors: Dictionary = W200_PENCIL_CUT.get_meta(key, {})
		if anchors.size() != LocaleManager.SUPPORTED_LANGUAGES.size():
			_fail("W200 %s lost its five-locale pencil anchors" % key)
			return false
		for language: String in LocaleManager.SUPPORTED_LANGUAGES:
			if str(anchors.get(language, "")).strip_edges().is_empty():
				_fail("W200 %s lost its %s pencil anchor" % [key, language])
				return false

	var paths := 0
	var guards := 0
	var live_cues := 0
	var restores := 0
	var locale_reflows := 0
	var text_size_reflows := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for producer_choice in range(3):
			for choice in [0, 2]:
				if not await _w200_open(language, producer_choice) \
						or not await _w200_read_intro(producer_choice):
					return false
				_story.call("_on_choice", choice)
				await _wait_stable()
				var applied := _w196_applied_state()
				if not _w200_cut_layout(choice) \
						or not _w200_surface("W200 result entry", true) \
						or not _w200_audio_matches(false, "W200 result entry") \
						or not await _w200_seek_before_cut(choice, applied):
					return false
				await _finish_page()
				if not _w200_audio_matches(false, "W200 before pencil sentence"):
					return false

				var representative: bool = language == "ko" and producer_choice == choice
				if representative:
					if not await _w200_reflow_boundary(choice, false, applied) \
							or not await _w200_cold_boundary(choice, false, applied):
						return false
					restores += 1
					locale_reflows += 2
					text_size_reflows += 2
					# A cold result restores prose/state but does not restart an already-
					# entered score. Re-open the real path before measuring live continuity.
					if not await _w200_open(language, producer_choice) \
							or not await _w200_read_intro(producer_choice):
						return false
					_story.call("_on_choice", choice)
					await _wait_stable()
					applied = _w196_applied_state()
					if not await _w200_seek_before_cut(choice, applied):
						return false
					await _finish_page()

				_w200_clear_tracked()
				_story.call("_on_advance")
				var played_at := int(AudioManager._last_sfx_ms.get("pen_write", -1))
				if played_at < 0 or not _w200_cut_structure(choice, true) \
						or not _w196_state_matches(applied, "W200 live pencil cut") \
						or not _w200_surface("W200 live pencil cut", true) \
						or not _w200_audio_matches(true, "W200 live pencil cut"):
					_fail("W200 c%d pencil sentence did not emit exactly one live pen_write" % choice)
					return false
				await _wait_stable()
				await _finish_page()
				if int(AudioManager._last_sfx_ms.get("pen_write", -1)) != played_at:
					_fail("W200 pencil sentence replayed while completing the same page")
					return false
				live_cues += 1
				_w200_clear_tracked()

				if representative:
					if not await _w200_reflow_boundary(choice, true, applied) \
							or not await _w200_cold_boundary(choice, true, applied):
						return false
					restores += 1
					locale_reflows += 2
					text_size_reflows += 2
				var last_source := int(_story.call("_story_source_paragraph_index",
					int(_story.get("_para_index"))))
				while int(_story.get("_para_index")) < (_story.get("_paragraphs") as Array).size() - 1:
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index",
						int(_story.get("_para_index"))))
					if int(_story.get("_para_index")) < int(_story.get("_result_location_cut_page")) \
							or source < last_source \
							or not _w196_state_matches(applied, "W200 later result") \
							or not _w200_surface("W200 later result", true, not representative) \
							or not _w200_audio_matches(false, "W200 later result"):
						return false
					last_source = source
					_story.call("_on_advance")
					await _wait_stable()
				paths += 1

	# The timestamp comparison stays intentionally quiet for every W197 receipt.
	for producer_choice in range(3):
		if not await _w200_open("ko", producer_choice) \
				or not await _w200_read_intro(producer_choice):
			return false
		_story.call("_on_choice", 1)
		await _wait_stable()
		var applied := _w196_applied_state()
		if int(_story.get("_result_location_cut_page")) >= 0:
			_fail("W200 quiet c1 unexpectedly gained a pencil cut")
			return false
		while true:
			await _finish_page()
			if not _w200_surface("W200 quiet c1", true) \
					or not _w196_state_matches(applied, "W200 quiet c1") \
					or not _w200_audio_matches(false, "W200 quiet c1"):
				return false
			if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
				break
			_story.call("_on_advance")
			await _wait_stable()
		guards += 1

	print("W200_PENCIL_AUDIO_OK paths=%d guards=%d v4=%d live_cues=%d locale_reflows=%d text_size_reflows=%d" % [
		paths, guards, restores, live_cues, locale_reflows, text_size_reflows])
	return paths == 30 and guards == 3 and restores == 4 and live_cues == 30 \
		and locale_reflows == 8 and text_size_reflows == 8

func _w200_open(language: String, producer_choice: int) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W200/producer%d" % [language, producer_choice]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	SaveManager.set_setting("story_text_size", "standard")
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 200
	GameState.age = 37
	GameState.month = 2
	GameState.week_of_month = 4
	GameState.housing = "oneroom"
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.flags["route_invest"] = true
	for flag in [
		"arc_sangchul_met_seen", "arc_daeun_met", "daeun_romance_started",
		"arc_minseo_02_seen", "arc_jaehyuk_reunion_seen", "arc_jaehyuk_aftermath_seen",
	]:
		GameState.flags[flag] = true
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true,
		GameState.get_total_asset_value())
	if not bool(locked.get("ok", false)):
		_fail("W200 fixture could not lock the actual Chapter 5 route")
		return false
	var state: Dictionary = locked["state"]
	for step in [[0, 2], [1, 1], [2, producer_choice]]:
		var index := int(step[0])
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(
			state, CHAPTER5_ROUTE.OWNED_EVENT_IDS[index], int(step[1]),
			CHAPTER5_ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("W200 fixture could not commit predecessor %d/%d" % [index, step[1]])
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	if GameState.chapter5_causal_next_event_for_turn() != W200_BOUNDARY:
		_fail("W200 exact predecessor receipts did not admit the Daeun boundary")
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.pending_story_queue = [W200_BOUNDARY]
	_w200_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if str((_story.get("_current") as Dictionary).get("id", "")) != W200_BOUNDARY \
			or int(GameState.chapter5_causal_selected_choice(
				CHAPTER5_ROUTE.OWNED_EVENT_IDS[2])) != producer_choice \
			or not _w200_surface("W200 opening", false) \
			or not _w200_audio_matches(false, "W200 opening"):
		_fail("W200 StoryMode did not open its exact localized receipt path")
		return false
	return true

func _w200_read_intro(producer_choice: int) -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	var reads: Dictionary = current.get("chapter5_causal_reads", {})
	var text_rows: Array = reads.get("texts", [])
	var expected_prefix := ""
	if text_rows.size() == 1 and text_rows[0] is Array \
			and producer_choice < (text_rows[0] as Array).size():
		expected_prefix = str(_story.call("_fmt", (text_rows[0] as Array)[producer_choice])).strip_edges()
	var sources := authored.split("\n\n")
	var untouched := _w196_applied_state()
	if int(_story.call("_story_source_paragraph_count")) != 5 \
			or sources.size() != 5 or str(sources[0]).strip_edges() != expected_prefix \
			or not _m23_same_prose(pages, authored):
		_fail("W200 lost its selected W197 receipt plus four authored sources")
		return false
	while not bool(_story.get("_showing_choices")):
		var source := int(_story.call("_story_source_paragraph_index",
			int(_story.get("_para_index"))))
		await _finish_page()
		if not _w200_surface("W200 intro", source >= 2) \
				or not _w196_state_matches(untouched, "W200 intro") \
				or not _w200_audio_matches(false, "W200 intro"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	return (_story.get("_choice_box") as Control).get_child_count() == 3 \
		and _w196_state_matches(untouched, "W200 choices") \
		and _w200_surface("W200 choices", true) \
		and _w200_audio_matches(false, "W200 choices")

func _w200_cut_layout(choice: int) -> bool:
	var pages: Array = _story.get("_paragraphs")
	var cut := int(_story.get("_result_location_cut_page"))
	var anchors: Dictionary = W200_PENCIL_CUT.get_meta(
		"underline_anchors" if choice == 0 else "vertical_anchors", {})
	var anchor := str(_story.call("_fmt", anchors.get(LocaleManager.language, "")))
	var choices: Array = (_story.get("_current") as Dictionary).get("choices", [])
	var authored := str(_story.call("_fmt", (choices[choice] as Dictionary).get("result_text", "")))
	if int(_story.call("_story_source_paragraph_count")) != 3 \
			or pages.is_empty() or not _m23_same_prose(pages, authored) \
			or cut <= 0 or cut >= pages.size() or anchor.is_empty() \
			or not str(pages[cut]).begins_with(anchor):
		return false
	if choice == 0:
		return int(_story.call("_story_source_paragraph_index", cut - 1)) == 0 \
			and int(_story.call("_story_source_paragraph_index", cut)) == 0
	return int(_story.call("_story_source_paragraph_index", cut - 1)) == 1 \
		and int(_story.call("_story_source_paragraph_index", cut)) == 2

func _w200_cut_structure(choice: int, after_cut: bool) -> bool:
	var page := int(_story.get("_para_index"))
	var pages: Array = _story.get("_paragraphs")
	var cut := int(_story.get("_result_location_cut_page"))
	if not _w200_cut_layout(choice) or page < 0 or page >= pages.size() \
			or (page >= cut) != after_cut:
		return false
	var source := int(_story.call("_story_source_paragraph_index", page))
	return source == (0 if choice == 0 else (2 if after_cut else 1))

func _w200_seek_before_cut(choice: int, applied: Dictionary) -> bool:
	var cut := int(_story.get("_result_location_cut_page"))
	while int(_story.get("_para_index")) < cut - 1:
		await _finish_page()
		if not _w200_surface("W200 approach to pencil", true) \
				or not _w196_state_matches(applied, "W200 approach to pencil") \
				or not _w200_audio_matches(false, "W200 approach to pencil"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		cut = int(_story.get("_result_location_cut_page"))
	if int(_story.get("_para_index")) != cut - 1 \
			or not _w200_cut_structure(choice, false):
		_fail("W200 c%d did not settle before its pencil sentence" % choice)
		return false
	return true

func _w200_cold_boundary(choice: int, after_cut: bool, applied: Dictionary) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	var expected_source := 0 if choice == 0 else (2 if after_cut else 1)
	_w200_clear_tracked()
	if int(context.get("source_paragraph_index", -1)) != expected_source \
			or not await _reload_authored_result_context(
				context, LocaleManager.language, 3, expected_source) \
			or not _w200_cut_structure(choice, after_cut) \
			or not _w200_surface("W200 cold boundary", true, false) \
			or not _w196_state_matches(applied, "W200 cold boundary") \
			or not _w200_audio_matches(false, "W200 cold boundary"):
		_fail("W200 c%d cold result crossed or replayed its pencil sentence" % choice)
		return false
	return true

func _w200_reflow_boundary(choice: int, after_cut: bool, applied: Dictionary) -> bool:
	for level in ["large", "standard"]:
		_w200_clear_tracked()
		_story.call("_set_story_text_size", level)
		await _wait_stable()
		if not _w200_cut_structure(choice, after_cut) \
				or not _w200_surface("W200 text-size reflow", true) \
				or not _w196_state_matches(applied, "W200 text-size reflow") \
				or not _w200_audio_matches(false, "W200 text-size reflow"):
			return false
	for language in ["en", "ko"]:
		_w200_clear_tracked()
		_story.call("_set_story_language", language)
		await _wait_stable()
		if LocaleManager.language != language \
				or not _w200_cut_structure(choice, after_cut) \
				or not _w200_surface("W200 locale reflow", true) \
				or not _w196_state_matches(applied, "W200 locale reflow") \
				or not _w200_audio_matches(false, "W200 locale reflow"):
			return false
	return true

func _w200_surface(label: String, expect_score: bool, verify_score: bool = true) -> bool:
	var current_key := str(BGMPlayer.get("_current_key"))
	if str((_story.get("_current") as Dictionary).get("id", "")) != W200_BOUNDARY \
			or str(_story.get("_event_background_id")) != "cafe" \
			or str(BGMPlayer.get("_current_ambience_key")) != "cafe" \
			or (verify_score and current_key != ("reckoning" if expect_score else "")):
		_fail("%s changed W200 cafe or reckoning phase expected_score=%s actual=%s" % [
			label, expect_score, current_key])
		return false
	return true

func _w200_clear_tracked() -> void:
	for sound_id in W200_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)

func _w200_audio_matches(expect_pen: bool, label: String) -> bool:
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		if not str(key).begins_with(W200_BOUNDARY + ":"):
			return false
		for sound_id in W200_TRACKED_SFX:
			if str(key).ends_with(":" + sound_id):
				return true
		return false)
	var invalid: Array[String] = []
	for sound_id in W200_TRACKED_SFX:
		var expected: bool = expect_pen and sound_id == "pen_write"
		if AudioManager._last_sfx_ms.has(sound_id) != expected \
				or _w197_sfx_stream_count(sound_id) != (1 if expected else 0):
			invalid.append(sound_id)
	if not invalid.is_empty() or not cue_keys.is_empty():
		_fail("%s W200 cue mismatch invalid=%s authored=%s" % [label, invalid, cue_keys])
		return false
	return true

func _check_w196_friday_vibration() -> bool:
	var contract: Dictionary = BGMPlayer.scene_audio_contract(W196_DELIVERY)
	if contract.has("paragraph_cues") or contract.has("result_paragraph_cues") \
			or str(contract.get("ambience", "")) != "current_housing" \
			or not bool(contract.get("suppress_music", false)):
		_fail("W196 retained an opening cue or changed its quiet room contract")
		return false
	var paths := 0
	var live_cues := 0
	var restores := 0
	var locale_reflows := 0
	var text_size_reflows := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for cover_choice in range(3):
			if not await _w196_open(language, cover_choice) \
					or not await _w196_read_intro():
				return false
			_story.call("_on_choice", 2)
			await _wait_stable()
			var applied := _w196_applied_state()
			if not _w196_cut_layout() or not _w196_surface("W196 c2 result entry") \
					or not _w196_audio_matches(false, "W196 c2 result entry"):
				return false
			if not await _w196_seek_before_cut(applied):
				return false
			await _finish_page()
			if not _w196_audio_matches(false, "W196 before Friday alert"):
				return false
			var representative := language == "ko" and cover_choice == 0
			if representative:
				if not await _w196_cold_boundary(false, applied) \
						or not await _w196_reflow_boundary(false, applied):
					return false
				restores += 1
				locale_reflows += 2
				text_size_reflows += 2
				if not await _w196_seek_before_cut(applied):
					return false
				await _finish_page()

			_w196_clear_tracked()
			_story.call("_on_advance")
			if not _w196_cut_structure(true) or not _w196_surface("W196 Friday alert") \
					or not _w196_state_matches(applied, "W196 Friday alert") \
					or not _w196_audio_matches(true, "W196 Friday alert"):
				_fail("W196 Friday sentence did not emit exactly one live phone vibration")
				return false
			var played_at := int(AudioManager._last_sfx_ms.get("phone_vibrate", -1))
			await _wait_stable()
			await _finish_page()
			if int(AudioManager._last_sfx_ms.get("phone_vibrate", -1)) != played_at:
				_fail("W196 Friday sentence replayed its vibration while completing")
				return false
			live_cues += 1
			_w196_clear_tracked()
			if representative:
				if not await _w196_cold_boundary(true, applied) \
						or not await _w196_reflow_boundary(true, applied):
					return false
				restores += 1
				locale_reflows += 2
				text_size_reflows += 2
			while not bool(_story.get("_pending_after_result")) \
					or int(_story.get("_para_index")) < (_story.get("_paragraphs") as Array).size() - 1:
				await _finish_page()
				if not _w196_cut_structure(true) or not _w196_surface("W196 later result") \
						or not _w196_state_matches(applied, "W196 later result") \
						or not _w196_audio_matches(false, "W196 later result"):
					return false
				if int(_story.get("_para_index")) >= (_story.get("_paragraphs") as Array).size() - 1:
					break
				_story.call("_on_advance")
				await _wait_stable()
			paths += 1

	# The two non-Friday choices retain their existing quiet result surface.
	for choice in [0, 1]:
		if not await _w196_open("ko", choice) or not await _w196_read_intro():
			return false
		_story.call("_on_choice", choice)
		await _wait_stable()
		var applied := _w196_applied_state()
		if int(_story.get("_result_location_cut_page")) >= 0:
			_fail("W196 unchanged c%d unexpectedly gained a sentence cut" % choice)
			return false
		for page in range((_story.get("_paragraphs") as Array).size()):
			await _finish_page()
			if not _w196_surface("W196 unchanged c%d" % choice) \
					or not _w196_state_matches(applied, "W196 unchanged choice") \
					or not _w196_audio_matches(false, "W196 unchanged c%d" % choice):
				return false
			if page + 1 < (_story.get("_paragraphs") as Array).size():
				_story.call("_on_advance")
				await _wait_stable()
	print("W196_FRIDAY_VIBRATION_OK paths=%d guards=2 v4=%d live_cues=%d locale_reflows=%d text_size_reflows=%d" % [
		paths, restores, live_cues, locale_reflows, text_size_reflows])
	return paths == 15 and restores == 2 and live_cues == 15 \
		and locale_reflows == 4 and text_size_reflows == 4

func _w196_open(language: String, cover_choice: int) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W196/cover%d" % [language, cover_choice]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	SaveManager.set_setting("story_text_size", "standard")
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 196
	GameState.age = 37
	GameState.month = 1
	GameState.week_of_month = 4
	GameState.housing = "oneroom"
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.flags["route_invest"] = true
	for flag in [
		"arc_sangchul_met_seen", "arc_daeun_met", "daeun_romance_started",
		"arc_minseo_02_seen", "arc_jaehyuk_reunion_seen", "arc_jaehyuk_aftermath_seen",
	]:
		GameState.flags[flag] = true
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true,
		GameState.get_total_asset_value())
	if not bool(locked.get("ok", false)):
		_fail("W196 fixture could not lock the actual Chapter 5 route")
		return false
	var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(
		locked["state"], CHAPTER5_ROUTE.OWNED_EVENT_IDS[0], cover_choice,
		CHAPTER5_ROUTE.OWNED_TURNS[0])
	if not bool(committed.get("ok", false)):
		_fail("W196 fixture could not commit W195 receipt %d" % cover_choice)
		return false
	GameState.chapter5_causal_state = committed["state"]
	if GameState.chapter5_causal_next_event_for_turn() != W196_DELIVERY:
		_fail("W196 exact W195 receipt did not admit reviewer delivery")
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.pending_story_queue = [W196_DELIVERY]
	_w196_clear_tracked()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if str((_story.get("_current") as Dictionary).get("id", "")) != W196_DELIVERY \
			or int(GameState.chapter5_causal_selected_choice(
				CHAPTER5_ROUTE.OWNED_EVENT_IDS[0])) != cover_choice \
			or not _w196_surface("W196 opening") \
			or not _w196_audio_matches(false, "W196 opening"):
		_fail("W196 StoryMode did not open its exact localized receipt path")
		return false
	return true

func _w196_read_intro() -> bool:
	var current: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", current.get("description", "")))
	var untouched := _w196_applied_state()
	if int(_story.call("_story_source_paragraph_count")) != 3 \
			or not _m23_same_prose(pages, authored):
		_fail("W196 lost its W195 receipt plus two authored sources")
		return false
	for page in range(pages.size()):
		await _finish_page()
		if not _w196_surface("W196 intro") \
				or not _w196_state_matches(untouched, "W196 intro") \
				or not _w196_audio_matches(false, "W196 intro"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	return bool(_story.get("_showing_choices")) \
		and (_story.get("_choice_box") as Control).get_child_count() == 3 \
		and _w196_state_matches(untouched, "W196 choices") \
		and _w196_audio_matches(false, "W196 choices")

func _w196_cut_layout() -> bool:
	var pages: Array = _story.get("_paragraphs")
	var cut := int(_story.get("_result_location_cut_page"))
	var anchors: Dictionary = W196_VIBRATE_CUT.get_meta("vibration_anchors", {})
	var anchor := str(_story.call("_fmt", anchors.get(LocaleManager.language, "")))
	var authored := str(_story.call("_fmt", ((_story.get("_current") as Dictionary)
		.get("choices", []) as Array)[2].get("result_text", "")))
	return anchors.size() == LocaleManager.SUPPORTED_LANGUAGES.size() \
		and int(_story.call("_story_source_paragraph_count")) == 2 \
		and not pages.is_empty() and _m23_same_prose(pages, authored) \
		and cut > 0 and cut < pages.size() \
		and int(_story.call("_story_source_paragraph_index", cut - 1)) == 1 \
		and int(_story.call("_story_source_paragraph_index", cut)) == 1 \
		and not anchor.is_empty() and str(pages[cut]).begins_with(anchor)

func _w196_cut_structure(after_cut: bool) -> bool:
	var page := int(_story.get("_para_index"))
	var pages: Array = _story.get("_paragraphs")
	var cut := int(_story.get("_result_location_cut_page"))
	return _w196_cut_layout() and page >= 0 and page < pages.size() \
		and int(_story.call("_story_source_paragraph_index", page)) == 1 \
		and (page >= cut) == after_cut

func _w196_seek_before_cut(applied: Dictionary) -> bool:
	var cut := int(_story.get("_result_location_cut_page"))
	while int(_story.get("_para_index")) < cut - 1:
		await _finish_page()
		if not _w196_surface("W196 approach to alert") \
				or not _w196_state_matches(applied, "W196 approach to alert") \
				or not _w196_audio_matches(false, "W196 approach to alert"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		cut = int(_story.get("_result_location_cut_page"))
	if int(_story.get("_para_index")) != cut - 1 or not _w196_cut_structure(false):
		_fail("W196 did not settle on the physical page before the Friday alert")
		return false
	return true

func _w196_cold_boundary(after_cut: bool, applied: Dictionary) -> bool:
	var context: Dictionary = _story.call("build_save_resume_context")
	_w196_clear_tracked()
	if not await _reload_authored_result_context(
			context, LocaleManager.language, 2, 1) \
			or not _w196_cut_structure(after_cut) \
			or not _w196_surface("W196 cold boundary") \
			or not _w196_state_matches(applied, "W196 cold boundary") \
			or not _w196_audio_matches(false, "W196 cold boundary"):
		_fail("W196 cold result crossed or replayed the Friday alert")
		return false
	return true

func _w196_reflow_boundary(after_cut: bool, applied: Dictionary) -> bool:
	for level in ["large", "standard"]:
		_w196_clear_tracked()
		_story.call("_set_story_text_size", level)
		await _wait_stable()
		if not _w196_cut_structure(after_cut) \
				or not _w196_surface("W196 text-size reflow") \
				or not _w196_state_matches(applied, "W196 text-size reflow") \
				or not _w196_audio_matches(false, "W196 text-size reflow"):
			return false
	for language in ["en", "ko"]:
		_w196_clear_tracked()
		_story.call("_set_story_language", language)
		await _wait_stable()
		if LocaleManager.language != language or not _w196_cut_structure(after_cut) \
				or not _w196_surface("W196 locale reflow") \
				or not _w196_state_matches(applied, "W196 locale reflow") \
				or not _w196_audio_matches(false, "W196 locale reflow"):
			return false
	return true

func _w196_surface(label: String) -> bool:
	if str((_story.get("_current") as Dictionary).get("id", "")) != W196_DELIVERY \
			or str(_story.get("_event_background_id")) != "apartment" \
			or str(BGMPlayer.get("_current_ambience_key")) != "oneroom" \
			or not str(BGMPlayer.get("_current_key")).is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing:
		_fail("%s changed W196 current housing or opened music" % label)
		return false
	return true

func _w196_applied_state() -> Dictionary:
	var state := _w177_applied_state()
	state["chapter5_causal_state"] = _w177_json_state(GameState.chapter5_causal_state)
	state["deferred_events"] = _w177_json_state(GameState.deferred_events)
	state["meta"] = _w177_json_state(MetaProgression.data)
	return state

func _w196_state_matches(expected: Dictionary, label: String) -> bool:
	var actual := _w196_applied_state()
	if actual == expected:
		return true
	var changed: Array[String] = []
	for key: String in expected:
		if expected[key] != actual.get(key):
			changed.append(key)
	_fail("%s changed W196 state keys=%s" % [label, changed])
	return false

func _w196_clear_tracked() -> void:
	for sound_id in W196_TRACKED_SFX:
		AudioManager.stop_sound(sound_id)
		AudioManager._last_sfx_ms.erase(sound_id)

func _w196_audio_matches(expect_vibration: bool, label: String) -> bool:
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		if not str(key).begins_with(W196_DELIVERY + ":"):
			return false
		for sound_id in W196_TRACKED_SFX:
			if str(key).ends_with(":" + sound_id):
				return true
		return false)
	var invalid: Array[String] = []
	for sound_id in W196_TRACKED_SFX:
		var expected: bool = expect_vibration and sound_id == "phone_vibrate"
		if AudioManager._last_sfx_ms.has(sound_id) != expected \
				or _w197_sfx_stream_count(sound_id) != (1 if expected else 0):
			invalid.append(sound_id)
	if not invalid.is_empty() or not cue_keys.is_empty():
		_fail("%s W196 cue mismatch invalid=%s authored=%s" % [label, invalid, cue_keys])
		return false
	return true

func _check_w197_folder_audio() -> bool:
	var contract: Dictionary = BGMPlayer.scene_audio_contract(W197_PUSH)
	if contract.has("paragraph_cues") or contract.has("result_paragraph_cues") \
			or str(contract.get("ambience", "")) != "current_housing" \
			or contract.get("music", {}) != {"key": "reckoning", "start_paragraph": 1.0}:
		_fail("W197 retained an opening paper cue or changed its room/score contract")
		return false
	var paths := 0
	var restores := 0
	var live_cues := 0
	var locale_reflows := 0
	var text_size_reflows := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for receipt_choice in range(3):
			if not await _w197_open(language, receipt_choice):
				return false
			var current: Dictionary = _story.get("_current")
			var authored := str(_story.call("_fmt", current.get("description", "")))
			var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
			if int(_story.call("_story_source_paragraph_count")) != 3 \
					or not _m23_same_prose(pages, authored) \
					or not _w197_cut_layout():
				_fail("W197 %s receipt %d lost its exact three-source live prose" % [
					language, receipt_choice])
				return false
			var state_bytes := _w197_state_bytes()
			if not await _w197_seek_before_cut(state_bytes):
				return false
			await _finish_page()
			if not _w197_no_paper("W197 before folder"):
				return false
			var representative_reflow := language == "ko" and receipt_choice == 0
			if representative_reflow:
				if not await _reload_prechoice("prose", W197_PUSH, false) \
						or not _w197_cut_structure(false) \
						or not _w197_state_matches(state_bytes, "W197 before-folder cold restore") \
						or not _w197_no_paper("W197 before-folder cold restore"):
					_fail("W197 same-locale cold restore crossed or sounded before the folder sentence")
					return false
				restores += 1
				if not await _w197_reflow_boundary(false, state_bytes):
					return false
				locale_reflows += 2
				text_size_reflows += 2
				if not await _w197_seek_before_cut(state_bytes):
					return false
				await _finish_page()

			_w197_clear_paper()
			_story.call("_on_advance")
			var played_at := int(AudioManager._last_sfx_ms.get("paper_handle", -1))
			if played_at < 0 or _w197_sfx_stream_count("paper_handle") != 1 \
					or not _w197_cut_structure(true) \
					or not _w197_state_matches(state_bytes, "W197 live folder cut"):
				_fail("W197 folder sentence did not emit exactly one live paper_handle")
				return false
			await _wait_stable()
			await _finish_page()
			if int(AudioManager._last_sfx_ms.get("paper_handle", -1)) != played_at:
				_fail("W197 folder page replayed its paper cue while completing the same sentence")
				return false
			live_cues += 1
			# The foreground sample has now been observed and authenticated. Stop it
			# before proving that later redraws/pages do not dispatch another copy.
			_w197_clear_paper()

			if representative_reflow:
				if not await _reload_prechoice("prose", W197_PUSH, false) \
						or not _w197_cut_structure(true) \
						or not _w197_state_matches(state_bytes, "W197 after-folder cold restore") \
						or not _w197_no_paper("W197 after-folder cold restore"):
					_fail("W197 same-locale cold restore crossed or replayed the folder sentence")
					return false
				restores += 1
				if not await _w197_reflow_boundary(true, state_bytes):
					return false
				locale_reflows += 2
				text_size_reflows += 2

			while not bool(_story.get("_showing_choices")):
				await _finish_page()
				if not _w197_cut_structure(true) \
						or not _w197_state_matches(state_bytes, "W197 later prose") \
						or not _w197_no_paper("W197 later prose"):
					return false
				_story.call("_on_advance")
				await _wait_stable()
			if (_story.get("_choice_box") as Control).get_child_count() != 3 \
					or not _w197_state_matches(state_bytes, "W197 choices") \
					or not _w197_no_paper("W197 choices"):
				_fail("W197 did not reach its unchanged three choices without another paper cue")
				return false
			paths += 1
	print("W197_FOLDER_CUE_OK paths=%d v4=%d live_cues=%d locale_reflows=%d text_size_reflows=%d gallery_unchanged=1" % [
		paths, restores, live_cues, locale_reflows, text_size_reflows])
	return paths == 15 and restores == 2 and live_cues == 15 \
		and locale_reflows == 4 and text_size_reflows == 4

func _w197_open(language: String, receipt_choice: int) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W197/receipt%d" % [language, receipt_choice]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	SaveManager.set_setting("story_text_size", "standard")
	GameState.start_new_game("김민준", "지방_상경", "투자형")
	GameState.turn = 197
	GameState.age = 37
	GameState.month = 2
	GameState.week_of_month = 1
	GameState.housing = "oneroom"
	GameState.money = 2_100_000_000.0
	GameState.portfolio = {}
	GameState.loans = {"bank": 0.0, "second": 0.0}
	GameState.flags["route_invest"] = true
	for flag in [
		"arc_sangchul_met_seen", "arc_daeun_met", "daeun_romance_started",
		"arc_minseo_02_seen", "arc_jaehyuk_reunion_seen", "arc_jaehyuk_aftermath_seen",
	]:
		GameState.flags[flag] = true
	var locked: Dictionary = CHAPTER5_ROUTE.lock_entry(
		CHAPTER5_ROUTE.default_state(), 195, "투자형", true, true,
		GameState.get_total_asset_value())
	if not bool(locked.get("ok", false)):
		_fail("W197 fixture could not lock the actual Chapter 5 route")
		return false
	var state: Dictionary = locked["state"]
	for step in [[0, 2], [1, receipt_choice]]:
		var index := int(step[0])
		var committed: Dictionary = CHAPTER5_ROUTE.commit_choice(
			state, CHAPTER5_ROUTE.OWNED_EVENT_IDS[index], int(step[1]),
			CHAPTER5_ROUTE.OWNED_TURNS[index])
		if not bool(committed.get("ok", false)):
			_fail("W197 fixture could not commit predecessor %d/%d" % [index, step[1]])
			return false
		state = committed["state"]
	GameState.chapter5_causal_state = state
	if GameState.chapter5_causal_next_event_for_turn() != W197_PUSH:
		_fail("W197 exact predecessor receipts did not admit the deadline root")
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.pending_story_queue = [W197_PUSH]
	var raw_event: Dictionary = DataRegistry.find_event(W197_PUSH)
	var raw_sources := str(raw_event.get("description", "")).split("\n\n")
	var raw_anchor := str(W197_FOLDER_STARTS.get(language, ""))
	if raw_sources.size() != 2 or raw_anchor.is_empty() \
			or not str(raw_sources[1]).contains(raw_anchor):
		_fail("W197 %s raw/gallery source lost its unchanged two-paragraph body" % language)
		return false
	_w197_clear_paper()
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if str((_story.get("_current") as Dictionary).get("id", "")) != W197_PUSH \
			or int(GameState.chapter5_causal_selected_choice(
				CHAPTER5_ROUTE.OWNED_EVENT_IDS[1])) != receipt_choice \
			or not _w197_no_paper("W197 opening"):
		_fail("W197 StoryMode did not open the exact localized receipt path")
		return false
	return true

func _w197_cut_layout() -> bool:
	var pages: Array = _story.get("_paragraphs")
	var cut := int(_story.get("_result_location_cut_page"))
	var anchor := str(_story.call("_fmt", W197_FOLDER_STARTS.get(
		LocaleManager.language, "")))
	return cut > 0 and cut < pages.size() \
		and int(_story.call("_story_source_paragraph_count")) == 3 \
		and int(_story.call("_story_source_paragraph_index", cut - 1)) == 2 \
		and int(_story.call("_story_source_paragraph_index", cut)) == 2 \
		and not anchor.is_empty() and str(pages[cut]).begins_with(anchor)

func _w197_cut_structure(after_cut: bool) -> bool:
	var page := int(_story.get("_para_index"))
	var pages: Array = _story.get("_paragraphs")
	var cut := int(_story.get("_result_location_cut_page"))
	return _w197_cut_layout() and page >= 0 and page < pages.size() \
		and int(_story.call("_story_source_paragraph_index", page)) == 2 \
		and (page >= cut) == after_cut

func _w197_seek_before_cut(state_bytes: String) -> bool:
	var cut := int(_story.get("_result_location_cut_page"))
	while int(_story.get("_para_index")) < cut - 1:
		await _finish_page()
		if not _w197_no_paper("W197 approach to folder") \
				or not _w197_state_matches(state_bytes, "W197 approach to folder"):
			return false
		_story.call("_on_advance")
		await _wait_stable()
		cut = int(_story.get("_result_location_cut_page"))
	if int(_story.get("_para_index")) != cut - 1 or not _w197_cut_structure(false):
		_fail("W197 could not settle on the physical page before the folder sentence")
		return false
	return true

func _w197_reflow_boundary(after_cut: bool, state_bytes: String) -> bool:
	for level in ["large", "standard"]:
		_w197_clear_paper()
		_story.call("_set_story_text_size", level)
		await _wait_stable()
		if not _w197_cut_structure(after_cut) \
				or not _w197_state_matches(state_bytes, "W197 text-size reflow") \
				or not _w197_no_paper("W197 text-size reflow"):
			_fail("W197 %s text-size reflow crossed or replayed the folder sentence" % level)
			return false
	for language in ["en", "ko"]:
		_w197_clear_paper()
		_story.call("_set_story_language", language)
		await _wait_stable()
		if LocaleManager.language != language or not _w197_cut_structure(after_cut) \
				or not _w197_state_matches(state_bytes, "W197 locale reflow") \
				or not _w197_no_paper("W197 locale reflow"):
			_fail("W197 KO/EN reflow crossed or replayed the folder sentence")
			return false
	return true

func _w197_state_bytes() -> String:
	return JSON.stringify({
		"route": GameState.chapter5_causal_state,
		"turn": GameState.turn,
		"money": GameState.money,
		"ap": GameState.action_points,
		"health": GameState.health,
		"mental": GameState.mental,
		"intelligence": GameState.intelligence,
		"moral_tint": GameState.moral_tint,
		"flags": GameState.flags,
		"event_log": GameState.event_log,
		"deferred_events": GameState.deferred_events,
		"meta": MetaProgression.data,
	}, "", true)

func _w197_state_matches(expected: String, label: String) -> bool:
	if _w197_state_bytes() == expected:
		return true
	_fail("%s changed route, economy, story flags, receipts or gallery" % label)
	return false

func _w197_sfx_stream_count(sound_id: String) -> int:
	var expected: AudioStream = AudioManager._sounds.get(sound_id)
	if expected == null:
		return 0
	var count := 0
	for player: AudioStreamPlayer in AudioManager._pool:
		if player.playing and player.stream == expected:
			count += 1
	return count

func _w197_clear_paper() -> void:
	AudioManager.stop_sound("paper_handle")
	AudioManager._last_sfx_ms.erase("paper_handle")

func _w197_no_paper(label: String) -> bool:
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		return str(key).begins_with(W197_PUSH + ":") and str(key).ends_with(":paper_handle"))
	if AudioManager._last_sfx_ms.has("paper_handle") \
			or _w197_sfx_stream_count("paper_handle") != 0 or not cue_keys.is_empty():
		_fail("%s replayed or opened an early W197 paper cue: %s" % [label, cue_keys])
		return false
	return true

func _check_w192_year_close_wind() -> bool:
	var paths := 0
	var restores := 0
	var locale_reflows := 0
	for event_id in [W192_ROOT, W192_DEAD]:
		var anchors: Dictionary = W192_WIND_CUT.get_meta(event_id, {})
		if anchors.size() != LocaleManager.SUPPORTED_LANGUAGES.size():
			_fail("W192 wind cut lost a five-locale event map for %s" % event_id)
			return false
		for language: String in LocaleManager.SUPPORTED_LANGUAGES:
			if not anchors.has(language) or str(anchors[language]).strip_edges().is_empty():
				_fail("W192 wind cut lost %s/%s" % [event_id, language])
				return false
			if not await _w192_open(event_id, language):
				return false
			if not await _w192_read_intro("W192 %s/%s" % [event_id, language]):
				return false
			var current: Dictionary = _story.get("_current")
			var choices: Array = current.get("choices", [])
			if not bool(_story.get("_showing_choices")) or choices.size() != 3 \
					or not _expect_w192_surface(false, true, -1, "W192 choices"):
				_fail("W192 did not reach its exact three choices on the windy rooftop")
				return false
			var score_token := int(BGMPlayer._punctuation_token)
			var before_flags: Dictionary = GameState.flags.duplicate(true)
			var before_events := int(GameState.events_seen)
			var before_log: Array = GameState.event_log.duplicate(true)
			var before_deferred: Array = GameState.deferred_events.duplicate(true)
			var before_mental := float(GameState.mental)
			var before_meta: Dictionary = MetaProgression.data.duplicate(true)
			_story.call("_on_choice", 2)
			await _wait_stable()
			var applied_state := _w177_applied_state()
			if not _w192_choice_matches(before_flags, before_events, before_log,
					before_deferred, before_mental, event_id, 2):
				return false
			var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
			var cut := int(_story.get("_result_location_cut_page"))
			var authored := str(_story.call("_fmt", str(choices[2].get("result_text", ""))))
			if int(_story.call("_story_source_paragraph_count")) != 2 \
					or pages.is_empty() or not _m23_same_prose(pages, authored) \
					or cut <= 0 or cut >= pages.size() \
					or int(_story.call("_story_source_paragraph_index", cut - 1)) != 1 \
					or int(_story.call("_story_source_paragraph_index", cut)) != 1 \
					or not str(pages[cut]).begins_with(str(anchors[language])):
				_fail("W192 localized last-sentence cut no longer preserves source paragraph one")
				return false
			for page in range(pages.size()):
				await _finish_page()
				var closed := page >= cut
				var live_latch := 1 if page == cut else (0 if page < cut else -1)
				if int(_story.call("_story_source_paragraph_index", page)) not in [0, 1] \
						or not _w177_applied_state_matches(applied_state, "W192 live result") \
						or not _expect_w192_surface(
							closed, true, score_token, "W192 result", live_latch):
					return false
				if event_id == W192_ROOT and language == "ko" and page in [cut - 1, cut]:
					AudioManager._last_sfx_ms.erase("door_latch")
					for target_language in ["en", "ko"]:
						_story.call("_set_story_language", target_language)
						await _wait_stable()
						var rebound_cut := int(_story.get("_result_location_cut_page"))
						var rebound_page := int(_story.get("_para_index"))
						if LocaleManager.language != target_language \
								or str((_story.get("_current") as Dictionary).get("id", "")) != event_id \
								or rebound_cut <= 0 \
								or (rebound_page >= rebound_cut) != closed \
								or not _w177_applied_state_matches(applied_state, "W192 locale reflow") \
								or not _expect_w192_surface(
									closed, true, score_token, "W192 locale reflow", 0):
							_fail("W192 KO/EN reflow crossed the authored door boundary")
							return false
						locale_reflows += 1
				if page in [cut - 1, cut]:
					var context: Dictionary = _story.call("build_save_resume_context")
					AudioManager._last_sfx_ms.erase("door_latch")
					if not await _reload_authored_result_context(context, language, 2, 1, true):
						return false
					await _wait_stable()
					var cold_cut := int(_story.get("_result_location_cut_page"))
					var cold_page := int(_story.get("_para_index"))
					if str((_story.get("_current") as Dictionary).get("id", "")) != event_id \
							or cold_cut <= 0 or cold_page != page \
							or (cold_page >= cold_cut) != closed \
							or not _w177_applied_state_matches(applied_state, "W192 cold result") \
							or not _expect_w192_surface(closed, true, -1, "W192 cold result", 0):
						_fail("W192 v4 restore crossed the same-source door boundary")
						return false
					# Cold reconstruction intentionally resumes the sustained score with a
					# fresh player token. Continue live-cut continuity from that verified token.
					score_token = int(BGMPlayer._punctuation_token)
					await _finish_page()
					restores += 1
				if page + 1 < pages.size():
					_story.call("_on_advance")
					await _wait_stable()
			if not _w177_applied_state_matches(applied_state, "W192 final result") \
					or MetaProgression.data != before_meta:
				_fail("W192 result reading changed applied choice or gallery state")
				return false
			paths += 1
	# The two unaffected choices keep the original winter rooftop, score, prose,
	# effects and delayed reckoning on the canonical KO event.
	for choice in [0, 1]:
		if not await _w192_open(W192_ROOT, "ko") \
				or not await _w192_read_intro("W192 unaffected c%d" % choice):
			return false
		var current: Dictionary = _story.get("_current")
		var choices: Array = current.get("choices", [])
		var score_token := int(BGMPlayer._punctuation_token)
		var before_flags: Dictionary = GameState.flags.duplicate(true)
		var before_events := int(GameState.events_seen)
		var before_log: Array = GameState.event_log.duplicate(true)
		var before_deferred: Array = GameState.deferred_events.duplicate(true)
		var before_mental := float(GameState.mental)
		_story.call("_on_choice", choice)
		await _wait_stable()
		var applied_state := _w177_applied_state()
		var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
		var authored := str(_story.call("_fmt", str(choices[choice].get("result_text", ""))))
		if not _w192_choice_matches(before_flags, before_events, before_log,
				before_deferred, before_mental, W192_ROOT, choice) \
				or int(_story.get("_result_location_cut_page")) >= 0 \
				or int(_story.call("_story_source_paragraph_count")) != 2 \
				or pages.is_empty() or not _m23_same_prose(pages, authored):
			_fail("W192 unaffected choice c%d changed its source/effect contract" % choice)
			return false
		for page in range(pages.size()):
			await _finish_page()
			if not _w177_applied_state_matches(applied_state, "W192 unaffected result") \
					or not _expect_w192_surface(false, true, score_token,
						"W192 unaffected result"):
				return false
			if page + 1 < pages.size():
				_story.call("_on_advance")
				await _wait_stable()
	print("W192_YEAR_CLOSE_WIND_OK paths=%d v4=%d locale_reflows=%d guards=2" % [
		paths, restores, locale_reflows])
	return paths == 10 and restores == 20 and locale_reflows == 4

func _w192_open(event_id: String, language: String) -> bool:
	await _remove_story()
	await _stop_audio()
	_context = "%s/W192/%s" % [language, event_id]
	LocaleManager.set_language(language)
	SaveManager.clear_loaded_resume_context()
	GameState.start_new_game()
	GameState.turn = 192
	GameState.week_of_month = 4
	GameState.month = 12
	GameState.year = 2029
	GameState.age = 36
	GameState.housing = "oneroom"
	GameState.mental = 80.0
	for flag in [
		"prologue_done", "chapter_33_seen", "chapter_34_seen", "chapter_35_seen",
		"chapter_36_seen", "arc_year1_close_seen", "arc_year3_close_seen",
	]:
		GameState.flags[flag] = true
	var father_passed := event_id == W192_DEAD
	if father_passed:
		GameState.flags["father_passed"] = true
		GameState.flags["arc_father_passing_seen"] = true
		GameState.cast["father"]["stage"] = "passed"
	var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
	var selected := str(ingress.call("_next_arc_id", -1, true))
	ingress.free()
	if selected != W192_ROOT:
		_fail("W192 exact calendar did not select the canonical year-close root: %s" % selected)
		return false
	EventManager.pending_events.clear()
	EventManager.current_event = {}
	if EventManager.live_event_variant_id(W192_ROOT) != event_id:
		_fail("W192 father state did not resolve the expected live event %s" % event_id)
		return false
	EventManager.queue_event(DataRegistry.find_event(W192_ROOT))
	var live: Dictionary = EventManager.get_next_event()
	EventManager.current_event = {}
	EventManager.pending_events.clear()
	if str(live.get("id", "")) != event_id:
		_fail("W192 EventManager substitution did not yield %s" % event_id)
		return false
	GameState.story_return_scene = "res://scenes/MainGame.tscn"
	GameState.pending_story_queue = [event_id]
	AudioManager._last_sfx_ms.erase("door_latch")
	_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
	add_child(_story)
	_story.call("_set_auto_mode", false, false, false)
	await _wait_stable()
	if str((_story.get("_current") as Dictionary).get("id", "")) != event_id:
		_fail("W192 StoryMode did not open %s" % event_id)
		return false
	return true

func _w192_read_intro(label: String) -> bool:
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	if int(_story.call("_story_source_paragraph_count")) != 3 or pages.is_empty():
		_fail("%s lost its three-source intro" % label)
		return false
	for page in range(pages.size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		if source not in [0, 1, 2] \
				or not _expect_w192_surface(false, source >= 2, -1, "%s intro" % label):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	return true

func _expect_w192_surface(closed: bool, score_required: bool,
		score_token: int, label: String, latch_expected: int = -1) -> bool:
	if not _expect_surface(W192_INSIDE if closed else W192_BG,
			"" if closed else "winter", label):
		return false
	var portrait := _story.get("_portrait_frame") as Control
	var presentation: Dictionary = _story.get("_current_presentation")
	var badge := _story.get("_communication_badge") as Control
	var nameplate := _story.get("_name_panel") as Control
	if not is_instance_valid(portrait) or portrait.visible == closed \
			or (not closed \
				and str(_story.call("_resolved_story_surface_portrait_id")) != "player_cold_snap") \
			or bool(_story.get("_current_uses_cg")) \
			or not str(_story.get("_event_cg_id")).is_empty():
		_fail("%s changed the exterior/interior portrait or introduced a CG" % label)
		return false
	if closed:
		if str(presentation.get("scene_location", "")) != W192_INSIDE \
				or str(presentation.get("channel", "")) != "narration" \
				or str(presentation.get("portrait_role", "")) != "none" \
				or (is_instance_valid(nameplate) and nameplate.visible) \
				or (is_instance_valid(badge) and badge.visible) \
				or not _expect_no_ambience(label):
			_fail("%s retained exterior identity or communication info inside the door" % label)
			return false
	else:
		var generic := BGMPlayer._ambience_player as AudioStreamPlayer
		var human := BGMPlayer._human_ambience_player as AudioStreamPlayer
		var season := BGMPlayer._season_player as AudioStreamPlayer
		if not is_instance_valid(generic) or not generic.playing \
				or not is_instance_valid(human) or human.playing \
				or not str(BGMPlayer._current_human_ambience_key).is_empty() \
				or str(BGMPlayer._current_season_key) != "winter" \
				or not is_instance_valid(season) or not season.playing:
			_fail("%s did not keep the exact generic/season winter layers" % label)
			return false
	if score_required and (str(BGMPlayer._current_key) != "reckoning" \
			or (not BGMPlayer._player_a.playing and not BGMPlayer._player_b.playing)):
		_fail("%s lost the continuous reckoning score" % label)
		return false
	if score_token >= 0 and int(BGMPlayer._punctuation_token) != score_token:
		_fail("%s restarted the reckoning score at the wind cut" % label)
		return false
	if latch_expected >= 0 \
			and AudioManager._last_sfx_ms.has("door_latch") != (latch_expected == 1):
		_fail("%s door-latch cue did not match live-only cut expectation=%d" % [
			label, latch_expected])
		return false
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	var cues := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		return str(key).begins_with(event_id + ":"))
	if not cues.is_empty():
		_fail("%s introduced an authored one-shot cue: %s" % [label, cues])
		return false
	return true

func _w192_choice_matches(before_flags: Dictionary, before_events: int,
		before_log: Array, before_deferred: Array, before_mental: float,
		event_id: String, choice: int) -> bool:
	var expected_flags: Dictionary = before_flags.duplicate(true)
	expected_flags["arc_year4_close_seen"] = true
	if choice == 0:
		expected_flags["year4_final_resolve"] = true
	elif choice == 1:
		expected_flags["year4_self_known"] = true
	var expected_mental := minf(100.0, before_mental + [3.0, 1.0, 0.0][choice])
	var receipt: Dictionary = GameState.event_log.back() if not GameState.event_log.is_empty() else {}
	var new_deferred: Array = GameState.deferred_events.slice(before_deferred.size())
	var checks := {
		"flags": GameState.flags == expected_flags,
		"mental": is_equal_approx(GameState.mental, expected_mental),
		"events": GameState.events_seen == before_events + 1,
		"log_size": GameState.event_log.size() == before_log.size() + 1,
		"log_prefix": GameState.event_log.slice(0, before_log.size()) == before_log,
		"receipt": str(receipt.get("event_id", "")) == event_id \
			and int(receipt.get("choice_index", -1)) == choice \
			and int(receipt.get("turn", -1)) == 192,
		"deferred_prefix": GameState.deferred_events.slice(0, before_deferred.size()) == before_deferred,
		"deferred": new_deferred == [{"event_id": "arc_37_reckoning", "trigger_turn": 193}],
	}
	if checks.values().has(false):
		_fail("W192 choice c%d changed effects/receipt/deferred contract checks=%s receipt=%s deferred=%s" % [
			choice, checks, receipt, GameState.deferred_events])
		return false
	return true

func _check_w188_platform_silence() -> bool:
	var paths := 0
	var restores := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice in range(2):
			await _remove_story()
			await _stop_audio()
			_context = "%s/W188/platform/c%d" % [language, choice]
			LocaleManager.set_language(language)
			SaveManager.clear_loaded_resume_context()
			GameState.start_new_game()
			GameState.turn = 188
			GameState.week_of_month = 4
			GameState.month = 11
			GameState.year = 2029
			GameState.age = 36
			GameState.housing = "oneroom"
			GameState.money = 2_000_000.0
			GameState.mental = 80.0
			GameState.flags["arc_father_medication_seen"] = true
			GameState.flags["arc_father_03_seen"] = true
			GameState.flags["arc_y4_bill_night_seen"] = true
			GameState.flags["father_care_left_open"] = true
			GameState.flags["arc_y4_father_crisis_contact_seen"] = true
			GameState.flags["father_crisis_contact_missed"] = true
			GameState.cast["father"]["stage"] = "hospitalized"
			var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
			var selected := str(ingress.call(
				"_chapter_four_causal_arc_id", 188, GameState.flags, false))
			ingress.free()
			if selected != W188_ROOT:
				_fail("W188 exact medical receipts did not select the father-passing root")
				return false
			GameState.story_return_scene = "res://scenes/MainGame.tscn"
			GameState.pending_story_queue = [W188_ROOT]
			# A wrong platform contract must remain observable even when the call
			# starts from another public bed and a winter layer.
			BGMPlayer.set_ambience("subway")
			BGMPlayer.set_season_ambience("winter")
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			await _wait_stable()
			var root: Dictionary = _story.get("_current")
			if str(root.get("id", "")) != W188_ROOT:
				_fail("W188 did not open the actual father-passing root")
				return false
			var root_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
			for _page in range(root_pages.size()):
				await _finish_page()
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) \
					or (root.get("choices", []) as Array).size() != 2:
				_fail("W188 father-passing root did not expose its two decisions")
				return false
			_story.call("_on_choice", 0)
			await _wait_stable()
			var root_results: Array = (_story.get("_paragraphs") as Array).duplicate()
			var root_authored := str(_story.call(
				"_fmt", str((root.get("choices", []) as Array)[0].get("result_text", ""))))
			if str(_story.get("_pending_follow_up")) != W188_PLATFORM \
					or root_results.is_empty() or not _m23_same_prose(root_results, root_authored):
				_fail("W188 root choice zero lost its exact platform handoff or prose")
				return false
			for _page in range(root_results.size()):
				await _finish_page()
				_story.call("_on_advance")
				await _wait_stable()
			var platform: Dictionary = _story.get("_current")
			var intro: Array = (_story.get("_paragraphs") as Array).duplicate()
			var resolved_intro := str(_story.call("_resolved_story_description", platform))
			if str(platform.get("id", "")) != W188_PLATFORM \
					or int(_story.call("_story_source_paragraph_count")) != 4 \
					or intro.is_empty() or not _m23_same_prose(intro, resolved_intro):
				_fail("W188 root choice zero did not enter the exact localized platform")
				return false
			for _page in range(intro.size()):
				await _finish_page()
				if not _expect_w188_platform("W188 platform intro"):
					return false
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) \
					or (platform.get("choices", []) as Array).size() != 2 \
					or not _expect_w188_platform("W188 platform choices"):
				_fail("W188 platform did not retain its two decisions on the silent winter surface")
				return false
			var before_phenotype := _w177_phenotype_state()
			var before_flags: Dictionary = GameState.flags.duplicate(true)
			var before_events := int(GameState.events_seen)
			var before_log: Array = GameState.event_log.duplicate(true)
			_story.call("_on_choice", choice)
			await _wait_stable()
			var expected_flags: Dictionary = before_flags.duplicate(true)
			# This platform is a pure bridge. Its terminal follow-up owns the
			# father-passing route flags; the platform itself records only the event.
			var receipt: Dictionary = GameState.event_log.back() \
				if not GameState.event_log.is_empty() else {}
			var applied_state := _w177_applied_state()
			var result_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
			var authored_result := str(_story.call("_fmt", str(
				(platform.get("choices", []) as Array)[choice].get("result_text", ""))))
			var choice_checks := {
				"phenotype": _w177_phenotype_state() == before_phenotype,
				"flags": GameState.flags == expected_flags,
				"events": GameState.events_seen == before_events + 1,
				"log_size": GameState.event_log.size() == before_log.size() + 1,
				"log_prefix": GameState.event_log.slice(0, before_log.size()) == before_log,
				"receipt": str(receipt.get("event_id", "")) == W188_PLATFORM \
					and int(receipt.get("choice_index", -1)) == choice \
					and int(receipt.get("turn", -1)) == 188,
				"follow_up": str(_story.get("_pending_follow_up")) == W188_FOLLOW_UPS[choice],
				"source_count": int(_story.call("_story_source_paragraph_count")) == 1,
				"prose": not result_pages.is_empty() and _m23_same_prose(result_pages, authored_result),
			}
			if choice_checks.values().has(false):
				_fail("W188 platform choice changed effects, receipt, next source or localized prose checks=%s flags=%s receipt=%s followup=%s sources=%s" % [
					choice_checks, GameState.flags, receipt, _story.get("_pending_follow_up"),
					_story.call("_story_source_paragraph_count")])
				return false
			for page in range(result_pages.size()):
				await _finish_page()
				var onboard := choice == 0
				if not _w177_applied_state_matches(applied_state, "W188 platform result") \
						or not _expect_w188_result_surface(
							W188_PLATFORM, onboard, "W188 platform result"):
					return false
				if choice == 0 and page == 0:
					var context: Dictionary = _story.call("build_save_resume_context")
					if not await _reload_authored_result_context(context, language, 1, 0) \
							or str((_story.get("_current") as Dictionary).get("id", "")) != W188_PLATFORM \
							or int(_story.get("_para_index")) != page \
							or not _w177_applied_state_matches(applied_state, "W188 cold platform result") \
							or not _expect_w188_result_surface(
								W188_PLATFORM, true, "W188 cold platform result"):
						_fail("W188 v4 result restore lost the onboard KTX or applied choice")
						return false
					await _finish_page()
					restores += 1
				if page + 1 < result_pages.size():
					_story.call("_on_advance")
					await _wait_stable()
			if str(_story.get("_pending_follow_up")) != W188_FOLLOW_UPS[choice] \
					or not _w177_applied_state_matches(applied_state, "W188 final platform result"):
				_fail("W188 platform result changed before its authored follow-up")
				return false
			paths += 1
	print("W188_PLATFORM_SILENCE_OK paths=%d v4=%d" % [paths, restores])
	return paths == 10 and restores == 5

func _check_w188_deal_boarding() -> bool:
	var paths := 0
	var restores := 0
	var reflows := 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice in range(2):
			await _remove_story()
			await _stop_audio()
			_context = "%s/W188/deal/c%d" % [language, choice]
			LocaleManager.set_language(language)
			SaveManager.clear_loaded_resume_context()
			GameState.start_new_game()
			GameState.turn = 188
			GameState.week_of_month = 4
			GameState.month = 11
			GameState.year = 2029
			GameState.age = 36
			GameState.housing = "oneroom"
			GameState.money = 2_000_000.0
			GameState.mental = 80.0
			GameState.flags["arc_father_medication_seen"] = true
			GameState.flags["arc_father_03_seen"] = true
			GameState.flags["arc_y4_bill_night_seen"] = true
			GameState.flags["father_care_left_open"] = true
			GameState.flags["arc_y4_father_crisis_contact_seen"] = true
			GameState.flags["father_crisis_contact_missed"] = true
			GameState.cast["father"]["stage"] = "hospitalized"
			var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
			var selected := str(ingress.call(
				"_chapter_four_causal_arc_id", 188, GameState.flags, false))
			ingress.free()
			if selected != W188_ROOT:
				_fail("W188 exact medical receipts did not select the deal-room root")
				return false
			GameState.story_return_scene = "res://scenes/MainGame.tscn"
			GameState.pending_story_queue = [W188_ROOT]
			BGMPlayer.set_ambience("subway")
			BGMPlayer.set_season_ambience("winter")
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			await _wait_stable()
			var root: Dictionary = _story.get("_current")
			if str(root.get("id", "")) != W188_ROOT:
				_fail("W188 deal route did not open the actual father-passing root")
				return false
			var root_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
			for _page in range(root_pages.size()):
				await _finish_page()
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) \
					or (root.get("choices", []) as Array).size() != 2:
				_fail("W188 father-passing root did not expose its two deal decisions")
				return false
			_story.call("_on_choice", 1)
			await _wait_stable()
			var root_results: Array = (_story.get("_paragraphs") as Array).duplicate()
			var root_authored := str(_story.call(
				"_fmt", str((root.get("choices", []) as Array)[1].get("result_text", ""))))
			if str(_story.get("_pending_follow_up")) != W188_DEAL \
					or root_results.is_empty() or not _m23_same_prose(root_results, root_authored):
				_fail("W188 root choice one lost its exact deal-room handoff or prose")
				return false
			for _page in range(root_results.size()):
				await _finish_page()
				_story.call("_on_advance")
				await _wait_stable()
			var deal: Dictionary = _story.get("_current")
			var intro: Array = (_story.get("_paragraphs") as Array).duplicate()
			var resolved_intro := str(_story.call("_resolved_story_description", deal))
			if str(deal.get("id", "")) != W188_DEAL \
					or int(_story.call("_story_source_paragraph_count")) != 4 \
					or intro.is_empty() or not _m23_same_prose(intro, resolved_intro):
				_fail("W188 root choice one did not enter the exact localized deal room")
				return false
			for _page in range(intro.size()):
				await _finish_page()
				if not _expect_w188_deal("W188 deal intro"):
					return false
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")) \
					or (deal.get("choices", []) as Array).size() != 2 \
					or not _expect_w188_deal("W188 deal choices"):
				_fail("W188 deal room did not retain its two decisions on the meeting surface")
				return false
			var before_phenotype := _w177_phenotype_state()
			var before_flags: Dictionary = GameState.flags.duplicate(true)
			var before_events := int(GameState.events_seen)
			var before_log: Array = GameState.event_log.duplicate(true)
			_story.call("_on_choice", choice)
			await _wait_stable()
			var receipt: Dictionary = GameState.event_log.back() \
				if not GameState.event_log.is_empty() else {}
			var applied_state := _w177_applied_state()
			var result_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
			var authored_result := str(_story.call("_fmt", str(
				(deal.get("choices", []) as Array)[choice].get("result_text", ""))))
			var expected_sources := 2 if choice == 0 else 1
			var choice_checks := {
				"phenotype": _w177_phenotype_state() == before_phenotype,
				"flags": GameState.flags == before_flags,
				"events": GameState.events_seen == before_events + 1,
				"log_size": GameState.event_log.size() == before_log.size() + 1,
				"log_prefix": GameState.event_log.slice(0, before_log.size()) == before_log,
				"receipt": str(receipt.get("event_id", "")) == W188_DEAL \
					and int(receipt.get("choice_index", -1)) == choice \
					and int(receipt.get("turn", -1)) == 188,
				"follow_up": str(_story.get("_pending_follow_up")) == W188_FOLLOW_UPS[choice],
				"source_count": int(_story.call("_story_source_paragraph_count")) == expected_sources,
				"prose": not result_pages.is_empty() and _m23_same_prose(result_pages, authored_result),
			}
			if choice_checks.values().has(false):
				_fail("W188 deal choice changed effects, receipt, next source or localized prose checks=%s flags=%s receipt=%s followup=%s sources=%s" % [
					choice_checks, GameState.flags, receipt, _story.get("_pending_follow_up"),
					_story.call("_story_source_paragraph_count")])
				return false
			var restored_sources := {}
			for page in range(result_pages.size()):
				await _finish_page()
				var source := int(_story.call(
					"_story_source_paragraph_index", int(_story.get("_para_index"))))
				var onboard := choice == 0 and source == 1
				if not _w177_applied_state_matches(applied_state, "W188 deal result") \
						or not _expect_w188_result_surface(W188_DEAL, onboard, "W188 deal result"):
					return false
				if choice == 0 and source == 1 \
						and page == int(_story.call("_first_story_page_for_source", 1)) \
						and language == "ko":
					var targets := ["en", "ko"]
					for target: String in targets:
						_story.call("_set_story_language", target)
						await _wait_stable()
						if LocaleManager.language != target \
								or int(_story.call("_story_source_paragraph_index", int(
									_story.get("_para_index")))) != 1 \
								or not _w177_applied_state_matches(
									applied_state, "W188 locale-rebound deal result") \
								or not _expect_w188_onboard(
									W188_DEAL, "W188 locale-rebound deal result"):
							_fail("W188 onboard deal locale reflow lost source one or its runtime presentation")
							return false
						reflows += 1
				if choice == 0 and not restored_sources.has(source):
					var context: Dictionary = _story.call("build_save_resume_context")
					if not await _reload_authored_result_context(
							context, language, expected_sources, source) \
							or str((_story.get("_current") as Dictionary).get("id", "")) != W188_DEAL \
							or int(_story.call("_story_source_paragraph_index", int(
								_story.get("_para_index")))) != source \
							or not _w177_applied_state_matches(applied_state, "W188 cold deal result") \
							or not _expect_w188_result_surface(
								W188_DEAL, onboard, "W188 cold deal result"):
						_fail("W188 v4 deal restore lost source %d, its surface or applied choice" % source)
						return false
					await _finish_page()
					restored_sources[source] = true
					restores += 1
				if page + 1 < result_pages.size():
					_story.call("_on_advance")
					await _wait_stable()
			if str(_story.get("_pending_follow_up")) != W188_FOLLOW_UPS[choice] \
					or not _w177_applied_state_matches(applied_state, "W188 final deal result"):
				_fail("W188 deal result changed before its authored follow-up")
				return false
			if choice == 0 and restored_sources.size() != 2:
				_fail("W188 deal KTX route did not cold-restore both authored sources")
				return false
			paths += 1
	print("W188_DEAL_BOARDING_OK paths=%d v4=%d locale_reflows=%d" % [
		paths, restores, reflows])
	return paths == 10 and restores == 10 and reflows == 2

func _expect_w188_result_surface(event_id: String, onboard: bool, label: String) -> bool:
	if onboard:
		return _expect_w188_onboard(event_id, label)
	if event_id == W188_PLATFORM:
		return _expect_w188_platform(label)
	return _expect_w188_deal(label)

func _expect_w188_platform(label: String) -> bool:
	var presentation: Dictionary = _story.get("_current_presentation")
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		return str(key).begins_with(W188_PLATFORM + ":"))
	if not _expect_surface(W188_PLATFORM_BG, "", label) \
			or not _expect_no_ambience(label) \
			or str(BGMPlayer.get("_current_key")) != "grief" \
			or _score_playback_position("grief") < 0.0 \
			or str(presentation.get("channel", "")) != "narration" \
			or str(presentation.get("scene_location", "")) != "seoul_station_ktx_platform" \
			or (_story.get("_portrait_frame") as Control).visible \
			or (_story.get("_name_panel") as Control).visible \
			or (_story.get("_communication_badge") as Control).visible \
			or bool(_story.get("_current_uses_cg")) \
			or not str(_story.get("_event_cg_id")).is_empty() \
			or str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not cue_keys.is_empty():
		_fail("%s changed the winter KTX, silent beds or grief score presentation=%s cues=%s" % [
			label, presentation, cue_keys])
		return false
	return true

func _expect_w188_deal(label: String) -> bool:
	var presentation: Dictionary = _story.get("_current_presentation")
	var frame := _story.get("_portrait_frame") as Control
	var portrait := _story.get("_portrait") as TextureRect
	var badge := _story.get("_communication_badge") as Control
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		return str(key).begins_with(W188_DEAL + ":"))
	var ambience := str(BGMPlayer.get("_current_ambience_key"))
	var human_ambience := str(BGMPlayer.get("_current_human_ambience_key"))
	var ambience_ok := false
	if ambience == "office":
		ambience_ok = _expect_surface("meeting", "office", label) \
			and (BGMPlayer.get("_ambience_player") as AudioStreamPlayer).playing \
			and human_ambience == "public_interior" \
			and (BGMPlayer.get("_human_ambience_player") as AudioStreamPlayer).playing
	elif ambience.is_empty():
		# A cold result restores the existing authored meeting without replaying
		# the ducked office bed. It must remain fully quiet rather than inherit
		# the caller's subway, crowd or winter layers.
		ambience_ok = _expect_surface("meeting", "", label) and _expect_no_ambience(label)
	if not ambience_ok \
			or str(BGMPlayer.get("_current_season_key")) != "" \
			or (BGMPlayer.get("_season_player") as AudioStreamPlayer).playing \
			or str(BGMPlayer.get("_current_key")) != "grief" \
			or _score_playback_position("grief") < 0.0 \
			or str(presentation.get("channel", "")) != "in_person" \
			or str(presentation.get("scene_location", "")) != "seoul_investment_meeting_room" \
			or str(presentation.get("portrait_role", "")) != "local" \
			or str(presentation.get("expected_portrait", "")) != "player_suit" \
			or not is_instance_valid(frame) or not frame.visible \
			or not is_instance_valid(portrait) or portrait.texture == null \
			or portrait.texture.resource_path != ImageRegistry.get_portrait("player_suit") \
			or str(_story.call("_resolved_story_surface_portrait_id")) != "player_suit" \
			or not is_instance_valid(badge) or badge.visible \
			or bool(_story.get("_portrait_remote_inset")) \
			or bool(_story.get("_current_uses_cg")) \
			or not str(_story.get("_event_cg_id")).is_empty() \
			or str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not cue_keys.is_empty():
		_fail("%s changed the existing deal room, actor, layers or grief score presentation=%s cues=%s ambience=%s/%s" % [
			label, presentation, cue_keys, ambience, human_ambience])
		return false
	return true

func _expect_w188_onboard(event_id: String, label: String) -> bool:
	var presentation: Dictionary = _story.get("_current_presentation")
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		return str(key).begins_with(event_id + ":"))
	if not _expect_surface(W188_ONBOARD_BG, "", label) \
			or not _expect_no_ambience(label) \
			or str(BGMPlayer.get("_current_key")) != "grief" \
			or _score_playback_position("grief") < 0.0 \
			or str(presentation.get("channel", "")) != "narration" \
			or str(presentation.get("scene_location", "")) != W188_ONBOARD_BG \
			or str(presentation.get("portrait_role", "")) != "none" \
			or presentation.get("participants", []) != ["player"] \
			or presentation.has("expected_portrait") \
			or not str(presentation.get("state", "")).is_empty() \
			or not str(presentation.get("remote_actor", "")).is_empty() \
			or not str(presentation.get("remote_location", "")).is_empty() \
			or (_story.get("_portrait_frame") as Control).visible \
			or (_story.get("_name_panel") as Control).visible \
			or (_story.get("_communication_badge") as Control).visible \
			or bool(_story.get("_portrait_remote_inset")) \
			or bool(_story.get("_current_uses_cg")) \
			or not str(_story.get("_event_cg_id")).is_empty() \
			or str(_story.get_meta("living_scene_effect", "")) != "none" \
			or not cue_keys.is_empty():
		_fail("%s changed the quiet winter KTX, narration, actor or grief score presentation=%s cues=%s" % [
			label, presentation, cue_keys])
		return false
	return true

func _check_w185_father_departure() -> bool:
	var anchors: Dictionary = W185_DEPARTURE_CUT.get_meta("taxi_anchors", {})
	if anchors.size() != LocaleManager.SUPPORTED_LANGUAGES.size():
		_fail("W185 departure cut lost its five localized anchors")
		return false
	var paths := 0
	var restores := 0
	var memory_hits := {}
	for bill_flag: String in W185_BILL_FLAGS:
		for call_flag: String in W185_CALL_FLAGS:
			memory_hits["%s&%s" % [bill_flag, call_flag]] = 0
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		if not anchors.has(language) or str(anchors[language]).is_empty():
			_fail("W185 departure cut lacks the %s anchor" % language)
			return false
		for call_index in range(W185_CALL_FLAGS.size()):
			for choice in range(3):
				await _remove_story()
				await _stop_audio()
				_context = "%s/W185/call%d/c%d" % [language, call_index, choice]
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 185
				GameState.month = 11
				GameState.age = 36
				GameState.housing = "oneroom"
				GameState.money = 2_000_000.0
				GameState.mental = 80.0
				GameState.flags["arc_father_03_seen"] = true
				GameState.flags["arc_father_medication_seen"] = true
				GameState.flags["arc_y4_bill_night_seen"] = true
				var bill_flag: String = W185_BILL_FLAGS[choice]
				var call_flag: String = W185_CALL_FLAGS[call_index]
				GameState.flags[bill_flag] = true
				GameState.flags[
					"father_care_coordinated" if choice == 2 else "father_care_left_open"] = true
				GameState.flags["arc_father_call_on_ktx_seen"] = true
				GameState.flags[call_flag] = true
				var memory_key := "%s&%s" % [bill_flag, call_flag]
				memory_hits[memory_key] = int(memory_hits[memory_key]) + 1
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var selected := str(ingress.call(
					"_chapter_four_causal_arc_id", 185, GameState.flags, false))
				ingress.free()
				if selected != W185_CONTACT:
					_fail("W185 release ingress did not select the father crisis contact")
					return false
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [W185_CONTACT]
				# Start from unrelated public and seasonal beds. The authored home must
				# replace the former; the taxi boundary must clear every layer.
				BGMPlayer.set_ambience("cafe")
				BGMPlayer.set_season_ambience("rain")
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				var current: Dictionary = _story.get("_current")
				var resolved_intro := str(_story.call("_resolved_story_description", current))
				var intro_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
				var memory_map: Dictionary = current.get("description_memory_if_known", {})
				var expected_memory := str(_story.call(
					"_fmt", str(memory_map.get(memory_key, ""))))
				if str(current.get("id", "")) != W185_CONTACT \
						or int(_story.call("_story_source_paragraph_count")) != 4 \
						or not _m23_same_prose(intro_pages, resolved_intro) \
						or expected_memory.is_empty() \
						or not resolved_intro.contains(expected_memory):
					_fail("W185 did not open the exact localized root and combined memory")
					return false
				var home := ImageRegistry.resolve_contextual_background_id("current_housing")
				for page in range(intro_pages.size()):
					await _finish_page()
					if not _expect_w185_surface(home, false, "W185 intro") \
							or not _expect_w185_communication(-1, -1, false, "W185 intro"):
						return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")):
					_fail("W185 did not reach its three authored choices")
					return false
				if not _expect_w185_communication(-1, -1, false, "W185 choices"):
					return false
				var before_phenotype := _w177_phenotype_state()
				var expected_phenotype: Dictionary = before_phenotype.duplicate(true)
				if choice == 0:
					expected_phenotype["money"] = float(before_phenotype["money"]) - 58_000.0
				expected_phenotype["mental"] = float(before_phenotype["mental"]) - [5.0, 7.0, 12.0][choice]
				if choice == 2:
					expected_phenotype["moral_tint"] = float(before_phenotype["moral_tint"]) - 2.0
				var before_flags: Dictionary = GameState.flags.duplicate(true)
				var before_events := int(GameState.events_seen)
				var before_log: Array = GameState.event_log.duplicate(true)
				var before_action_points := int(GameState.action_points)
				var before_commitments: Array = GameState.weekly_commitments.duplicate(true)
				var before_meta: Dictionary = MetaProgression.data.duplicate(true)
				_story.call("_on_choice", choice)
				await _wait_stable()
				var applied_state := _w177_applied_state()
				var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
				var cut := int(_story.get("_result_location_cut_page"))
				var authored := str(_story.call(
					"_fmt", str((current.get("choices", []) as Array)[choice].get("result_text", ""))))
				if int(_story.call("_story_source_paragraph_count")) != 2 \
						or pages.is_empty() or not _m23_same_prose(pages, authored) \
						or int(_story.call("_story_source_paragraph_index", 0)) != 0 \
						or int(_story.call("_story_source_paragraph_index", pages.size() - 1)) != 1 \
						or (cut >= 0) != (choice == 0):
					_fail("W185 result lost its two-source choice-zero departure contract")
					return false
				if choice == 0:
					if cut <= 0 or cut >= pages.size() \
							or int(_story.call("_story_source_paragraph_index", cut - 1)) != 1 \
							or int(_story.call("_story_source_paragraph_index", cut)) != 1 \
							or not str(pages[cut]).begins_with(str(anchors[language])):
						_fail("W185 localized taxi departure did not begin at the exact final sentence")
						return false
				var phenotype_ok := _w177_phenotype_state() == expected_phenotype
				var flags_ok := _w185_outcome_flags_match(before_flags, choice)
				var receipt_ok := _w185_receipt_matches(before_log, choice)
				var commitment_ok := _w185_commitment_matches(
					before_commitments, choice, home)
				if not phenotype_ok or not flags_ok or not receipt_ok \
						or before_action_points <= 0 or not commitment_ok \
						or str(_story.get("_pending_follow_up")) != W185_FOLLOW_UPS[choice]:
					_fail("W185 choice lost its exact effects, flags, follow-up or commitment phenotype=%s flags=%s receipt=%s commitment=%s followup=%s" % [
						phenotype_ok, flags_ok, receipt_ok, commitment_ok,
						_story.get("_pending_follow_up")])
					return false
				var saw_source_one := false
				for page in range(pages.size()):
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					var first_source_one := source == 1 and not saw_source_one
					if source == 1:
						saw_source_one = true
					var departed := choice == 0 and page >= cut
					if source not in [0, 1] \
							or not _w177_applied_state_matches(applied_state, "W185 live result") \
							or not _expect_w185_surface(home, departed, "W185 result") \
							or not _expect_w185_communication(choice, source, departed, "W185 result"):
						return false
					var check_cold := choice == 0 and page in [cut - 1, cut] \
						or call_index == 0 and choice in [1, 2] and first_source_one
					if check_cold:
						var context: Dictionary = _story.call("build_save_resume_context")
						if not await _reload_authored_result_context(context, language, 2, 1, true) \
								or int(_story.get("_para_index")) != page \
								or int(_story.get("_result_location_cut_page")) != cut \
								or (choice == 0 and (int(_story.get("_para_index")) >= cut) != departed) \
								or str(_story.get("_pending_follow_up")) != W185_FOLLOW_UPS[choice] \
								or not _w177_applied_state_matches(applied_state, "W185 cold result") \
								or not _expect_w185_surface(home, departed, "W185 cold result") \
								or not _expect_w185_communication(choice, source, departed, "W185 cold result"):
							_fail("W185 v4 load changed the same-source contact or taxi boundary")
							return false
						await _finish_page()
						restores += 1
					if page + 1 < pages.size():
						_story.call("_on_advance")
						await _wait_stable()
				if not saw_source_one or GameState.events_seen != before_events + 1 \
						or str(_story.get("_pending_follow_up")) != W185_FOLLOW_UPS[choice] \
						or not _w177_applied_state_matches(applied_state, "W185 final result") \
						or MetaProgression.data != before_meta:
					_fail("W185 cut skipped the aftermath or changed applied state/gallery data")
					return false
				paths += 1
	for memory_key: String in memory_hits:
		if int(memory_hits[memory_key]) != 5:
			_fail("W185 combined memory coverage drifted for %s" % memory_key)
			return false
	print("W185_FATHER_DEPARTURE_OK paths=%d v4=%d memories=%d" % [
		paths, restores, memory_hits.size()])
	return paths == 30 and restores == 30 and memory_hits.size() == 6

func _expect_w185_surface(home: String, departed: bool, label: String) -> bool:
	var portrait := _story.get("_portrait_frame") as Control
	var background := _story.get("_bg_img") as TextureRect
	var cue_keys := AudioManager._story_audio_seen.keys().filter(func(key: Variant) -> bool:
		return str(key).begins_with(W185_CONTACT + ":"))
	if not is_instance_valid(portrait) or not portrait.visible \
			or str(_story.call("_resolved_story_surface_portrait_id")) != "player_shocked" \
			or bool(_story.get("_current_uses_cg")) \
			or not str(_story.get("_event_cg_id")).is_empty() \
			or not BGMPlayer._current_key.is_empty() \
			or BGMPlayer._player_a.playing or BGMPlayer._player_b.playing \
			or not cue_keys.is_empty():
		_fail("%s changed the shocked portrait, score, CG or authored cue" % label)
		return false
	if not departed:
		# The authored direction owns a hard audio cut while the actual room image
		# remains. Do not turn that established silence into a generic room bed.
		return _expect_surface(home, "", label)
	var badge := _story.get("_communication_badge") as Control
	var presentation: Dictionary = _story.get("_current_presentation")
	if not is_instance_valid(badge) or badge.visible \
			or str(presentation.get("channel", "")) != "narration" \
			or not str(presentation.get("state", "")).is_empty() \
			or not str(presentation.get("scene_location", "")).is_empty() \
			or not str(presentation.get("remote_location", "")).is_empty() \
			or not str(presentation.get("remote_actor", "")).is_empty():
		_fail("%s retained the incoming-call badge or remote-call metadata" % label)
		return false
	if str(_story.get("_event_background_id")) != "" \
			or not is_instance_valid(background) or background.texture != null \
			or not _expect_no_ambience(label):
		_fail("%s invented a taxi destination or retained a home ambience layer" % label)
		return false
	return true

func _expect_w185_communication(choice: int, source: int, departed: bool, label: String) -> bool:
	var expected_channel := "message"
	var expected_state := "received"
	var expected_remote_actor := "nurse"
	var expected_remote_location := "changwon_hospital"
	var expected_scene_location := "current_housing"
	if departed:
		expected_channel = "narration"
		expected_state = ""
		expected_remote_actor = ""
		expected_remote_location = ""
		expected_scene_location = ""
	elif choice == 1:
		expected_channel = "phone"
		expected_state = "connected"
		expected_remote_actor = "father" if source == 1 else "nurse"
	elif choice == 0 and source == 0:
		expected_state = "sent"
		expected_remote_actor = ""
		expected_remote_location = ""
	elif choice == 2 and source == 0:
		expected_state = "sent"
	var presentation: Dictionary = _story.get("_current_presentation")
	var badge := _story.get("_communication_badge") as Control
	var badge_label := _story.get("_communication_label") as Label
	var labels: Array = W108_CONTACT[LocaleManager.language]
	var expected_badge_label := ""
	if expected_channel == "message":
		expected_badge_label = str(labels[0])
	elif expected_channel == "phone":
		expected_badge_label = str(labels[1])
	var expected_badge_visible := not expected_badge_label.is_empty()
	if not is_instance_valid(badge) or not is_instance_valid(badge_label) \
			or str(presentation.get("channel", "")) != expected_channel \
			or str(presentation.get("state", "")) != expected_state \
			or str(presentation.get("remote_actor", "")) != expected_remote_actor \
			or str(presentation.get("remote_location", "")) != expected_remote_location \
			or str(presentation.get("scene_location", "")) != expected_scene_location \
			or str(presentation.get("portrait_role", "")) != "local" \
			or bool(_story.get("_portrait_remote_inset")) \
			or badge.visible != expected_badge_visible \
			or badge_label.text != expected_badge_label:
		_fail("%s communication mismatch c%d source%d expected=%s/%s/%s/%s/%s badge=%s actual=%s badge=%s/%s" % [
			label, choice, source, expected_channel, expected_state, expected_remote_actor,
			expected_remote_location, expected_scene_location, expected_badge_label,
			presentation, badge.visible if is_instance_valid(badge) else false,
			badge_label.text if is_instance_valid(badge_label) else "<missing>"])
		return false
	return true

func _w185_outcome_flags_match(before: Dictionary, choice: int) -> bool:
	var expected: Dictionary = before.duplicate(true)
	expected["arc_y4_father_crisis_contact_seen"] = true
	expected[W185_OUTCOME_FLAGS[choice]] = true
	return GameState.flags == expected

func _w185_receipt_matches(before: Array, choice: int) -> bool:
	var after: Array = GameState.event_log
	var receipt: Dictionary = after.back() if not after.is_empty() else {}
	return after.size() == before.size() + 1 \
		and after.slice(0, before.size()) == before \
		and str(receipt.get("event_id", "")) == W185_CONTACT \
		and int(receipt.get("choice_index", -1)) == choice \
		and int(receipt.get("turn", -1)) == 185

func _w185_commitment_matches(before: Array, choice: int, home: String) -> bool:
	var after: Array = GameState.weekly_commitments
	if GameState.action_points != 0 or after.size() != before.size() + 1 \
			or after.slice(0, before.size()) != before:
		return false
	var receipt: Dictionary = after.back() if not after.is_empty() else {}
	var event: Dictionary = DataRegistry.find_event(W185_CONTACT)
	var choices: Array = event.get("choices", [])
	var forgone: Array[int] = []
	for candidate in range(choices.size()):
		if candidate != choice and GameState.choice_available(event, choices[candidate]):
			forgone.append(candidate)
	var outcome := {"mental": -[5.0, 7.0, 12.0][choice]}
	if choice == 0:
		outcome["money"] = -58_000.0
		outcome["total_assets"] = -58_000.0
	return int(receipt.get("turn", -1)) == 185 \
		and str(receipt.get("source", "")) == "story_event" \
		and str(receipt.get("story_event_id", "")) == W185_CONTACT \
		and int(receipt.get("story_choice_index", -1)) == choice \
		and str(receipt.get("choice_id", "")) == "story:%s:%d" % [W185_CONTACT, choice] \
		and str(receipt.get("actual_action_id", "")) == "story_choice" \
		and str(receipt.get("axis", "")) == "human" \
		and str(receipt.get("week_kind", "")) == "decision" \
		and str(receipt.get("scene_background_id", "")) == home \
		and receipt.get("forgone_choice_indexes", []) == forgone \
		and receipt.get("outcome", {}) == outcome

func _check_w177_withdrawal() -> bool:
	if ImageRegistry.get_background(W177_CORRIDOR) != W177_CORRIDOR_PATH \
			or not FileAccess.file_exists(W177_CORRIDOR_PATH):
		_fail("W177 withdrawal corridor asset identity changed")
		return false
	var paths := 0
	var corridor_paths := 0
	var before_restores := 0
	var after_restores := 0
	var variants := [
		{"id": W177_DAEUN, "root": "meeting", "ambience": "office",
			"flags": ["daeun_romance_started", "arc_y4_family_partner_daeun"]},
		{"id": W177_SELF, "root": "meeting", "ambience": "office",
			"flags": ["arc_y4_family_no_partner"]},
		{"id": W177_DOCUMENT_GAP, "root": "current_housing", "ambience": "oneroom",
			"flags": ["arc_y4_family_no_partner", "arc_y4_three_promises_missed_deal"]},
	]
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for raw_variant: Dictionary in variants:
			for choice: int in range(3):
				await _remove_story()
				await _stop_audio()
				var event_id: String = str(raw_variant["id"])
				_context = "%s/W177/%s/c%d" % [language, event_id, choice]
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 177
				GameState.month = 8
				GameState.age = 36
				GameState.housing = "oneroom"
				for flag: String in [
					"arc_y4_three_promises_seen", "arc_y4_body_witness_seen",
					"arc_y4_family_table_seen", "arc_year_three_half_seen",
				]:
					GameState.flags[flag] = true
				for flag: String in raw_variant["flags"]:
					GameState.flags[flag] = true
				var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
				var selected: String = str(ingress.call(
					"_chapter_four_causal_arc_id", 177, GameState.flags, false))
				ingress.free()
				if selected != event_id:
					_fail("W177 release ingress resolved the wrong borrowed-name variant")
					return false
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [event_id]
				# The exact result cut must replace both a public room and stale weather,
				# while leaving independently authored score playback alone.
				BGMPlayer.set_ambience("cafe")
				BGMPlayer.set_season_ambience("rain")
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				var current: Dictionary = _story.get("_current")
				var resolved_intro := str(_story.call("_resolved_story_description", current))
				var resolved_intro_data: Dictionary = _story.call("_story_page_data", resolved_intro)
				var resolved_intro_count := int(_story.call(
					"_story_page_data_source_paragraph_count", resolved_intro_data))
				var intro_pages: Array = (_story.get("_paragraphs") as Array).duplicate()
				if str(current.get("id", "")) != event_id \
						or resolved_intro_count <= 0 \
						or int(_story.call("_story_source_paragraph_count")) != resolved_intro_count \
						or not _m23_same_prose(intro_pages, resolved_intro):
					_fail("W177 did not open the selected localized borrowed-name source")
					return false
				var home: String = ImageRegistry.resolve_contextual_background_id("current_housing")
				var root_background: String = home if str(raw_variant["root"]) == "current_housing" \
					else str(raw_variant["root"])
				var root_ambience: String = str(raw_variant["ambience"])
				for page in range(intro_pages.size()):
					await _finish_page()
					if not _w177_surface(root_background, root_ambience, false, "", "intro"):
						return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")):
					_fail("W177 did not reach its three authored choices")
					return false
				BGMPlayer.play_punctuation("reckoning")
				await get_tree().process_frame
				if BGMPlayer._current_key != "reckoning" \
						or (not BGMPlayer._player_a.playing and not BGMPlayer._player_b.playing):
					_fail("W177 fixture could not bind the score-preservation probe")
					return false
				var before_state: Dictionary = _w177_phenotype_state()
				var before_action_points: int = int(GameState.action_points)
				var before_commitments: Array = GameState.weekly_commitments.duplicate(true)
				var before_flags: Dictionary = GameState.flags.duplicate(true)
				var before_events: int = int(GameState.events_seen)
				var before_log: Array = GameState.event_log.duplicate(true)
				var before_meta: Dictionary = MetaProgression.data.duplicate(true)
				_story.call("_on_choice", choice)
				await _wait_stable()
				var applied_state: Dictionary = _w177_applied_state()
				var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
				var source_one_page: int = int(_story.call("_first_story_page_for_source", 1))
				var corridor: bool = event_id == W177_SELF and choice == 2
				if int(_story.call("_story_source_paragraph_count")) != 2 \
						or pages.is_empty() or source_one_page <= 0 or source_one_page >= pages.size() \
						or int(_story.call("_story_source_paragraph_index", 0)) != 0 \
						or int(_story.call("_story_source_paragraph_index", pages.size() - 1)) != 1:
					_fail("W177 result lost its exact two-source localized paragraph boundary")
					return false
				if corridor and not str(pages[source_one_page]).begins_with(
						str(W177_CORRIDOR_START[language])):
					_fail("W177 corridor cut no longer begins at the localized receipt sentence")
					return false
				var before_context: Dictionary = {}
				var after_context: Dictionary = {}
				for page in range(pages.size()):
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					var at_corridor := corridor and source == 1
					if source not in [0, 1] \
							or _w177_applied_state() != applied_state \
							or not _w177_surface(root_background, root_ambience,
								at_corridor, "reckoning", "result"):
						return false
					if corridor and source == 0:
						before_context = _story.call("build_save_resume_context")
					elif corridor and source == 1 and after_context.is_empty():
						after_context = _story.call("build_save_resume_context")
					if page + 1 < pages.size():
						_story.call("_on_advance")
						await _wait_stable()
				var after_state: Dictionary = _w177_phenotype_state()
				var phenotype_ok := after_state == before_state
				var events_ok := GameState.events_seen == before_events + 1
				var flags_ok := _w177_outcome_flags_match(before_flags, event_id, choice)
				var receipt_ok := _w177_receipt_matches(before_log, event_id, choice)
				var commitment_ok := before_action_points > 0 \
					and _w177_commitment_matches(
						before_commitments, event_id, choice, root_background)
				var meta_ok := MetaProgression.data == before_meta
				if not phenotype_ok or not events_ok or not flags_ok \
						or not receipt_ok or not commitment_ok or not meta_ok:
					var changed_state_keys: Array[String] = []
					for state_key: String in before_state:
						if before_state[state_key] != after_state.get(state_key):
							changed_state_keys.append(state_key)
					_fail("W177 visual cut changed state/receipt phenotype=%s keys=%s events=%s flags=%s receipt=%s commitment=%s meta=%s" % [
						phenotype_ok, changed_state_keys, events_ok, flags_ok, receipt_ok,
						commitment_ok, meta_ok])
					return false
				if corridor:
					if before_context.is_empty() or after_context.is_empty() \
							or not await _w177_reload_boundary(before_context, language, 0,
								root_background, root_ambience, false, applied_state) \
							or not await _w177_reload_boundary(after_context, language, 1,
								root_background, root_ambience, true, applied_state):
						_fail("W177 cold v4 boundary did not recover both sides of the corridor cut")
						return false
					before_restores += 1
					after_restores += 1
					corridor_paths += 1
				paths += 1
	print("W177_WITHDRAWAL_OK paths=%d corridor=%d before_v4=%d after_v4=%d" % [
		paths, corridor_paths, before_restores, after_restores])
	return paths == 45 and corridor_paths == 5 and before_restores == 5 and after_restores == 5

func _w177_surface(root_background: String, root_ambience: String, corridor: bool,
		expected_score: String, label: String) -> bool:
	if corridor:
		if not _expect_surface(W177_CORRIDOR, "", "W177 %s corridor" % label) \
				or not _expect_no_ambience("W177 %s corridor" % label):
			return false
	elif not _expect_surface(root_background, root_ambience, "W177 %s root" % label):
		return false
	var portrait := _story.get("_portrait_frame") as Control
	if not is_instance_valid(portrait) or portrait.visible == corridor \
			or bool(_story.get("_current_uses_cg")) \
			or not str(_story.get("_event_cg_id")).is_empty():
		_fail("W177 %s did not keep the player portrait exclusive to the non-corridor surface" % label)
		return false
	if not expected_score.is_empty() and (BGMPlayer._current_key != expected_score \
			or (not BGMPlayer._player_a.playing and not BGMPlayer._player_b.playing)):
		_fail("W177 %s interrupted its existing score at the location cut" % label)
		return false
	return true

func _w177_reload_boundary(context: Dictionary, language: String, source: int,
		root_background: String, root_ambience: String, corridor: bool,
		expected_state: Dictionary) -> bool:
	if not await _reload_authored_result_context(context, language, 2, source, true):
		return false
	if int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) != source:
		_fail("W177 cold result moved off source paragraph %d" % source)
		return false
	if not _w177_applied_state_matches(expected_state, "cold result"):
		return false
	if not _w177_surface(root_background, root_ambience, corridor, "", "cold result"):
		return false
	_story.call("_finish_story_scene_transition")
	await _wait_stable()
	return int(_story.call("_story_source_paragraph_index", int(_story.get("_para_index")))) == source \
		and _w177_applied_state_matches(expected_state, "settled cold result") \
		and _w177_surface(root_background, root_ambience, corridor, "", "settled cold result")

func _w177_applied_state() -> Dictionary:
	return {
		# SaveManager's JSON boundary legitimately normalizes numeric container
		# types. Compare the exact JSON-visible values rather than Variant widths.
		"phenotype": _w177_json_state(_w177_phenotype_state()),
		"action_points": int(GameState.action_points),
		"max_action_points": int(GameState.max_action_points),
		"flags": _w177_json_state(GameState.flags),
		"events_seen": int(GameState.events_seen),
		"event_log": _w177_json_state(GameState.event_log),
		"weekly_commitments": _w177_json_state(GameState.weekly_commitments),
		"pending_weekly_commitment": _w177_json_state(GameState.pending_weekly_commitment),
		"action_axis_this_week": _w177_json_state(GameState.action_axis_this_week),
	}

func _w177_json_state(value: Variant) -> Variant:
	return JSON.parse_string(JSON.stringify(value))

func _w177_applied_state_matches(expected: Dictionary, label: String) -> bool:
	var actual := _w177_applied_state()
	if actual == expected:
		return true
	var changed: Array[String] = []
	for key: String in expected:
		if expected[key] != actual.get(key):
			changed.append(key)
	_fail("W177 %s changed applied state keys=%s" % [label, changed])
	return false

func _w177_phenotype_state() -> Dictionary:
	var serialized: Dictionary = GameState.serialize()
	var result := {}
	for key: String in [
		"money", "health", "mental", "luck", "moral_tint", "route_orthodox",
		"route_unorthodox", "max_action_points", "housing",
		"current_job", "portfolio", "loans", "relationships", "cast", "inventory",
	]:
		var value: Variant = serialized.get(key)
		if value is Dictionary or value is Array:
			value = value.duplicate(true)
		result[key] = value
	return result

func _w177_commitment_matches(before: Array, event_id: String, choice: int,
		root_background: String) -> bool:
	var after: Array = GameState.weekly_commitments
	if GameState.action_points != 0 or after.size() != before.size() + 1 \
			or after.slice(0, before.size()) != before:
		return false
	var receipt: Dictionary = after.back() if not after.is_empty() else {}
	var forgone: Array[int] = []
	for candidate in range(3):
		if candidate != choice:
			forgone.append(candidate)
	return int(receipt.get("turn", -1)) == 177 \
		and str(receipt.get("source", "")) == "story_event" \
		and str(receipt.get("story_event_id", "")) == event_id \
		and int(receipt.get("story_choice_index", -1)) == choice \
		and str(receipt.get("choice_id", "")) == "story:%s:%d" % [event_id, choice] \
		and str(receipt.get("actual_action_id", "")) == "story_choice" \
		and str(receipt.get("axis", "")) == "money" \
		and str(receipt.get("week_kind", "")) == "decision" \
		and str(receipt.get("scene_background_id", "")) == root_background \
		and receipt.get("forgone_choice_indexes", []) == forgone \
		and receipt.get("outcome", {}) == {}

func _w177_outcome_flags_match(before: Dictionary, event_id: String, choice: int) -> bool:
	var expected: Dictionary = before.duplicate(true)
	expected["arc_y4_borrowed_name_seen"] = true
	var outcome := "arc_y4_borrowed_name_withdrew_request"
	if event_id == W177_DAEUN:
		outcome = [
			"arc_y4_borrowed_name_reduced_to_self",
			"arc_y4_borrowed_name_partner_review_only",
			"arc_y4_borrowed_name_withdrew_request",
		][choice]
	elif event_id == W177_SELF:
		outcome = [
			"arc_y4_borrowed_name_reduced_to_self",
			"arc_y4_borrowed_name_own_name_counteroffer",
			"arc_y4_borrowed_name_withdrew_request",
		][choice]
	elif event_id == W177_DOCUMENT_GAP:
		outcome = [
			"arc_y4_borrowed_name_requested_complete_terms",
			"arc_y4_borrowed_name_reduced_to_self",
			"arc_y4_borrowed_name_withdrew_request",
		][choice]
	expected[outcome] = true
	return GameState.flags == expected

func _w177_receipt_matches(before: Array, event_id: String, choice: int) -> bool:
	var after: Array = GameState.event_log
	var receipt: Dictionary = after.back() if not after.is_empty() else {}
	return after.size() == before.size() + 1 \
		and after.slice(0, before.size()) == before \
		and str(receipt.get("event_id", "")) == event_id \
		and int(receipt.get("choice_index", -1)) == choice \
		and int(receipt.get("turn", -1)) == 177

func _check_w174_father_call() -> bool:
	if ImageRegistry.get_background(W174_KTX) != W174_KTX_PATH \
			or not FileAccess.file_exists(W174_KTX_PATH) \
			or not FileAccess.file_exists(W174_PANE_PATH):
		_fail("W174 carriage or pane-overlay asset identity changed")
		return false
	var prepared: Dictionary = {}
	for artifact in [false, true]:
		await _remove_story()
		await _stop_audio()
		_context = "W174/prepare/artifact=%s" % artifact
		var history := _father_contact_history()
		history[0] = [14, "arc_father_01_call", 2 if artifact else 0]
		history.append([145, "chapter_card_36"])
		if not _prepare_full_owner_history(174, history) \
				or not _w174_selector(artifact):
			return false
		prepared["artifact" if artifact else "number"] = GameState.serialize().duplicate(true)
	var routes := [
		{"name": "remembered", "snapshot": "artifact", "root_choice": 0},
		{"name": "artifact_direct", "snapshot": "artifact", "root_choice": 1},
		{"name": "number_direct", "snapshot": "number", "root_choice": -1},
	]
	var paths := 0
	var remembered := 0
	var direct := 0
	var connected := 0
	var missed := 0
	var choice_v4 := 0
	var result_v4 := 0
	var ending_choices := 0
	for language_index in range(LocaleManager.SUPPORTED_LANGUAGES.size()):
		var language: String = LocaleManager.SUPPORTED_LANGUAGES[language_index]
		for route_index in range(routes.size()):
			var route: Dictionary = routes[route_index]
			for decision in range(2):
				await _remove_story()
				await _stop_audio()
				LocaleManager.set_language(language)
				GameState.call("_restore_serialized_snapshot_exact", prepared[route["snapshot"]])
				SaveManager.clear_loaded_resume_context()
				_context = "%s/W174/%s/decision%d" % [language, route["name"], decision]
				var root_id := W174_ROOT if int(route["root_choice"]) >= 0 else W174_NUMBER
				if not await _open_full_fixture_event(root_id, [], false, false):
					return false
				if int(route["root_choice"]) >= 0:
					if not await _w174_read_to_choices(W174_ROOT) \
							or not await _w174_expression_to(
								int(route["root_choice"]),
								W174_MEMORY if int(route["root_choice"]) == 0 else W174_NUMBER):
						return false
					if int(route["root_choice"]) == 0:
						remembered += 1
						if not await _w174_memory_to_number():
							return false
					else:
						direct += 1
				else:
					direct += 1
				if not await _w174_read_to_choices(W174_NUMBER):
					return false
				var cold_resume := int(route["root_choice"]) < 0 and decision == 0
				if cold_resume:
					if not await _reload_prechoice("choices", W174_NUMBER) \
							or not _w174_surface(W174_NUMBER, true, "cold choices"):
						return false
					choice_v4 += 1
				if not await _w174_decision_to(decision, cold_resume):
					return false
				if cold_resume:
					result_v4 += 1
				if decision == 0:
					connected += 1
				else:
					missed += 1
				var ending_id := W174_ANSWERED if decision == 0 else W174_MISSED
				if not await _w174_read_to_choices(ending_id):
					return false
				var ending_choice := (language_index + route_index + decision) % 3
				if not await _w174_expression_result(ending_choice):
					return false
				ending_choices += 1
				paths += 1
	await _remove_story()
	await _stop_audio()
	if _failures != 0:
		return false
	print("W174_FATHER_CALL_OK paths=%d remembered=%d direct=%d connected=%d missed=%d choice_v4=%d result_v4=%d ending_choices=%d" % [
		paths, remembered, direct, connected, missed, choice_v4, result_v4, ending_choices])
	return paths == 30 and remembered == 10 and direct == 20 \
		and connected == 15 and missed == 15 and choice_v4 == 5 \
		and result_v4 == 5 and ending_choices == 30

func _w174_selector(artifact: bool) -> bool:
	var expected := W174_ROOT if artifact else W174_NUMBER
	var ingress := load("res://scenes/MainGame.tscn").instantiate() as Control
	var flags: Dictionary = GameState.flags.duplicate(true)
	var selected := str(ingress.call("_chapter_four_causal_arc_id", 174, flags, false))
	var off_week := [
		str(ingress.call("_chapter_four_causal_arc_id", 173, flags, false)),
		str(ingress.call("_chapter_four_causal_arc_id", 175, flags, false)),
	]
	var passed := str(ingress.call("_chapter_four_causal_arc_id", 174, flags, true))
	flags["arc_father_call_on_ktx_seen"] = true
	var repeated := str(ingress.call("_chapter_four_causal_arc_id", 174, flags, false))
	ingress.free()
	var w174_ids := [W174_ROOT, W174_NUMBER]
	var off_week_hit := false
	for event_id: String in off_week:
		off_week_hit = off_week_hit or event_id in w174_ids
	if selected != expected or GameState.has_item("artifact_father_call") != artifact \
			or off_week_hit \
			or passed in w174_ids or repeated in w174_ids:
		_fail("W174 selector lost its artifact, exact-week, living-father or once-only gate")
		return false
	return true

func _w174_read_to_choices(event_id: String) -> bool:
	var event: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", _story.call("_resolved_story_description", event)))
	if str(event.get("id", "")) != event_id \
			or int(_story.call("_story_source_paragraph_count")) != int(W174_SOURCE_COUNTS[event_id]) \
			or not _m23_same_prose(pages, authored):
		_fail("%s lost exact localized intro prose or source paragraphs" % event_id)
		return false
	for page in range(pages.size()):
		await _finish_page()
		var source := int(_story.call("_story_source_paragraph_index", page))
		var panes := event_id == W174_NUMBER and source >= 2
		if int(_story.get("_para_index")) != page \
				or not _w174_surface(event_id, panes, "%s intro p%d" % [event_id, page]):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	var choices: Array = event.get("choices", [])
	if not bool(_story.get("_showing_choices")) \
			or (_story.get("_choice_box") as Control).get_child_count() != choices.size() \
			or not _w174_surface(event_id, event_id == W174_NUMBER, "%s choices" % event_id):
		_fail("%s did not reach its exact choice dock" % event_id)
		return false
	return true

func _w174_expression_to(choice_index: int, next_event: String) -> bool:
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	var before := _w174_public_state()
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	if _w174_public_state() != before or not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index:
		_fail("%s expression choice changed player state" % event_id)
		return false
	if not await _w174_result_to_next(choice_index, next_event, false, false):
		return false
	if _w174_public_state() != before:
		_fail("%s expression result changed player state" % event_id)
		return false
	return true

func _w174_memory_to_number() -> bool:
	var event: Dictionary = _story.get("_current")
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	var authored := str(_story.call("_fmt", _story.call("_resolved_story_description", event)))
	var before := _w174_public_state()
	if str(event.get("id", "")) != W174_MEMORY \
			or int(_story.call("_story_source_paragraph_count")) != int(W174_SOURCE_COUNTS[W174_MEMORY]) \
			or not _m23_same_prose(pages, authored):
		_fail("W174 memory lost exact localized prose or source paragraphs")
		return false
	for page in range(pages.size()):
		await _finish_page()
		if int(_story.get("_para_index")) != page \
				or not _w174_surface(W174_MEMORY, false, "W174 memory p%d" % page):
			return false
		_story.call("_on_advance")
		await _wait_stable()
	# This expression has one visible action, so StoryMode deliberately commits
	# it directly instead of opening a one-button choice dock.
	if _w174_public_state() != before or not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != 0:
		_fail("W174 memory did not auto-enter its sole expression result")
		return false
	if not await _w174_result_to_next(0, W174_NUMBER, false, false) \
			or _w174_public_state() != before:
		_fail("W174 memory expression changed player state")
		return false
	return true

func _w174_decision_to(choice_index: int, cold_resume: bool) -> bool:
	var before := _w174_public_state()
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	if not _w174_decision_state(before, choice_index):
		return false
	var next_event := W174_ANSWERED if choice_index == 0 else W174_MISSED
	if not await _w174_result_to_next(choice_index, next_event, true, cold_resume) \
			or not _w174_decision_state(before, choice_index):
		return false
	return true

func _w174_result_to_next(choice_index: int, next_event: String,
		overlay: bool, cold_resume: bool) -> bool:
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	if not _w174_result_matches(event_id, choice_index):
		return false
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	for page in range(pages.size()):
		await _finish_page()
		if int(_story.get("_para_index")) != page \
				or not _w174_surface(event_id, overlay, "%s result p%d" % [event_id, page]):
			return false
		if cold_resume and page == 0:
			if not await _reload_cut_result(choice_index, page, false) \
					or not _w174_surface(event_id, overlay, "%s cold result" % event_id):
				return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	_story.call("_on_advance")
	await _wait_stable()
	if str((_story.get("_current") as Dictionary).get("id", "")) != next_event \
			or not _w174_surface(next_event, false, "%s follow-on" % next_event):
		_fail("%s did not enter exact follow-on %s" % [event_id, next_event])
		return false
	return true

func _w174_expression_result(choice_index: int) -> bool:
	var event_id := str((_story.get("_current") as Dictionary).get("id", ""))
	var before := _w174_public_state()
	_story.call("_on_choice", choice_index)
	await _wait_stable()
	if _w174_public_state() != before or not _w174_result_matches(event_id, choice_index):
		_fail("%s ending expression changed player state" % event_id)
		return false
	var pages: Array = (_story.get("_paragraphs") as Array).duplicate()
	for page in range(pages.size()):
		await _finish_page()
		if int(_story.get("_para_index")) != page \
				or not _w174_surface(event_id, false, "%s ending p%d" % [event_id, page]):
			return false
		if page + 1 < pages.size():
			_story.call("_on_advance")
			await _wait_stable()
	return _w174_public_state() == before

func _w174_result_matches(event_id: String, choice_index: int) -> bool:
	var event: Dictionary = _story.get("_current")
	var choices: Array = event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size() \
			or not W174_RESULT_COUNTS.has(event_id):
		return false
	var expected_counts: Array = W174_RESULT_COUNTS[event_id]
	var pages: Array = _story.get("_paragraphs")
	var authored := str(_story.call("_fmt", str((choices[choice_index] as Dictionary).get("result_text", ""))))
	if not bool(_story.get("_pending_after_result")) \
			or int(_story.get("_pending_result_choice_index")) != choice_index \
			or int(_story.call("_story_source_paragraph_count")) != int(expected_counts[choice_index]) \
			or not _m23_same_prose(pages, authored):
		_fail("%s choice %d lost exact localized result prose" % [event_id, choice_index])
		return false
	return true

func _w174_surface(event_id: String, overlay: bool, label: String) -> bool:
	var background := _story.get("_bg_img") as TextureRect
	var material := _story.get("_story_bg_material") as ShaderMaterial
	var pane: Variant = material.get_shader_parameter("pane_overlay") if material != null else null
	var actual_overlay := false if material == null \
			else bool(material.get_shader_parameter("pane_overlay_enabled"))
	if str((_story.get("_current") as Dictionary).get("id", "")) != event_id \
			or str(_story.get("_event_background_id")) != W174_KTX \
			or not is_instance_valid(background) or background.texture == null \
			or background.texture.resource_path != W174_KTX_PATH \
			or str(BGMPlayer.get("_current_ambience_key")) != "train" \
			or not BGMPlayer._ambience_player.playing \
			or BGMPlayer._current_human_ambience_key != "transit" \
			or not BGMPlayer._human_ambience_player.playing \
			or not BGMPlayer._current_season_key.is_empty() \
			or BGMPlayer._season_player.playing or actual_overlay != overlay:
		_fail(("%s changed the KTX surface, train bed or pane state: " \
				+ "event=%s bg=%s/%s world=%s/%s human=%s/%s season=%s/%s " \
				+ "overlay=%s/%s pane=%s") % [
					label,
					str((_story.get("_current") as Dictionary).get("id", "")),
					str(_story.get("_event_background_id")),
					"" if not is_instance_valid(background) or background.texture == null \
						else background.texture.resource_path,
					str(BGMPlayer.get("_current_ambience_key")),
					str(BGMPlayer._ambience_player.playing),
					BGMPlayer._current_human_ambience_key,
					str(BGMPlayer._human_ambience_player.playing),
					BGMPlayer._current_season_key,
					str(BGMPlayer._season_player.playing),
					str(actual_overlay), str(overlay),
					"" if not (pane is Texture2D) else (pane as Texture2D).resource_path,
				])
		return false
	if overlay and (not (pane is Texture2D) \
			or (pane as Texture2D).resource_path != W174_PANE_PATH \
			or (pane as Texture2D).get_width() != 1280 \
			or (pane as Texture2D).get_height() != 800):
		_fail("%s did not bind the exact W174 pane overlay" % label)
		return false
	var presentation: Dictionary = _story.get("_current_presentation")
	var badge := _story.get("_communication_badge") as Control
	var portrait := _story.get("_portrait_frame") as Control
	match event_id:
		W174_ROOT:
			if presentation.get("channel") != "narration" or badge.visible or portrait.visible:
				return _w174_surface_fail(label, "root narration/actor contract")
		W174_MEMORY:
			if presentation.get("channel") != "memory" or not badge.visible \
					or not portrait.visible or not bool(_story.get("_portrait_remote_inset")):
				return _w174_surface_fail(label, "remote memory contract")
		W174_NUMBER:
			if presentation.get("channel") != "phone" or presentation.get("state") != "dialing" \
					or not badge.visible or portrait.visible:
				return _w174_surface_fail(label, "dialing contract")
		W174_ANSWERED:
			if presentation.get("channel") != "phone" or presentation.get("state") != "connected" \
					or not badge.visible or not portrait.visible or bool(_story.get("_portrait_remote_inset")):
				return _w174_surface_fail(label, "connected local-portrait contract")
		W174_MISSED:
			if badge.visible or not portrait.visible:
				return _w174_surface_fail(label, "missed-call narration contract")
	return true

func _w174_surface_fail(label: String, contract: String) -> bool:
	_fail("%s changed the existing %s" % [label, contract])
	return false

func _w174_public_state() -> Dictionary:
	var state: Dictionary = GameState.serialize().duplicate(true)
	var flags: Dictionary = state.get("flags", {}).duplicate(true)
	flags.erase(FULL_STORY_FLOW.STATE_KEY)
	# Scene visitation/read-series metadata is allowed to advance when the
	# follow-on opens. Expression choices must instead preserve the actual run:
	# economy/stats, authored flags and receipts, AP ownership, relationships,
	# inventory/portfolio, and deferred work.
	var public: Dictionary = {"flags": flags}
	for key in [
			"age", "year", "month", "week_of_month", "turn", "is_game_over",
			"housing", "money", "monthly_income", "fixed_expense",
			"health", "mental", "intelligence", "social_skill", "appearance",
			"investment_skill", "luck", "reputation", "action_points",
			"max_action_points", "route_orthodox", "route_unorthodox",
			"moral_tint", "moral_band_last", "action_axis_this_week",
			"action_places_this_week", "action_records_this_week",
			"recent_action_places", "recent_action_weeks",
			"pending_weekly_commitment", "weekly_commitments",
			"forgone_path_debts", "current_job", "job_tenure",
			"work_performance", "portfolio", "loans", "relationships", "cast",
			"player_route", "inventory", "event_log", "action_log", "clues",
			"thoughts_done", "active_thought", "deferred_events", "events_seen",
		]:
		public[key] = state[key]
	return public

func _w174_decision_state(before: Dictionary, choice_index: int) -> bool:
	var after := _w174_public_state()
	var expected_mental := clampi(
		int(before["mental"]) + (-5 if choice_index == 0 else -10), 0, 100)
	var expected_tint := clampf(
		float(before["moral_tint"]) + (15.0 if choice_index == 0 else 3.0), -100.0, 100.0)
	if not is_equal_approx(float(after["money"]), float(before["money"])) \
			or int(after["mental"]) != expected_mental \
			or not is_equal_approx(float(after["moral_tint"]), expected_tint) \
			or int(after["events_seen"]) != int(before["events_seen"]) + 1:
		_fail("W174 number choice changed its bounded effects: money=%s/%s mental=%s/%s tint=%s/%s events=%s/%s" % [
			after["money"], before["money"], after["mental"], expected_mental,
			after["moral_tint"], expected_tint, after["events_seen"],
			int(before["events_seen"]) + 1])
		return false
	var before_flags: Dictionary = before["flags"].duplicate(true)
	var after_flags: Dictionary = after["flags"].duplicate(true)
	for flag in ["arc_father_call_on_ktx_seen",
			"called_father_on_ktx" if choice_index == 0 else "did_not_call_father_on_ktx"]:
		if not bool(after_flags.get(flag, false)) or bool(before_flags.get(flag, false)):
			_fail("W174 number choice lost an authored receipt flag")
			return false
		after_flags.erase(flag)
	if after_flags != before_flags \
			or bool(GameState.flags.get(
				"did_not_call_father_on_ktx" if choice_index == 0 else "called_father_on_ktx", false)):
		_fail("W174 number choice changed an unrelated flag")
		return false
	var before_log: Array = before["event_log"]
	var after_log: Array = after["event_log"]
	var receipt: Dictionary = after_log.back() if not after_log.is_empty() else {}
	if after_log.size() != before_log.size() + 1 \
			or after_log.slice(0, before_log.size()) != before_log \
			or str(receipt.get("event_id", "")) != W174_NUMBER \
			or int(receipt.get("choice_index", -1)) != choice_index \
			or int(receipt.get("turn", -1)) != 174:
		_fail("W174 number choice lost its exact event receipt")
		return false
	return true

func _check_w161_body() -> bool:
	var paths := 0
	var restores := 0
	var stopped_reloads := 0
	var platform_reloads := 0
	var cashier_reloads := 0
	var meal_reloads := 0
	var empty_bowl_reloads := 0
	var shop_reloads := 0
	var shop_exit_reloads := 0
	var capture := OS.get_environment("GANGNAM_W161_CAPTURE_DIR")
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for flag: String in ["", "changed_routine", "maintained_routine", "restarted_exercise"]:
			for choice: int in range(3):
				await _remove_story()
				await _stop_audio()
				_context = "%s/W161/%s/c%d" % [language, flag, choice]
				LocaleManager.set_language(language)
				SaveManager.clear_loaded_resume_context()
				GameState.start_new_game()
				GameState.turn = 161
				GameState.age = 36
				GameState.health = 60
				GameState.mental = 60
				if not flag.is_empty():
					GameState.flags[flag] = true
				GameState.story_return_scene = "res://scenes/MainGame.tscn"
				GameState.pending_story_queue = [W161_BODY]
				BGMPlayer.set_ambience("cafe")
				_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
				add_child(_story)
				_story.call("_set_auto_mode", false, false, false)
				var intro_count := 6 if flag.is_empty() else 5
				if int(_story.call("_story_source_paragraph_count")) != intro_count:
					_fail("W161 did not select the intended remembered variant")
					return false
				for page in range((_story.get("_paragraphs") as Array).size()):
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					var moving := source != 5
					if not _expect_w161_surface(W57_CAR if moving else W161_STOPPED):
						return false
					if choice == 0 and flag.is_empty() and page == 0 and not capture.is_empty():
						if not await _save_viewport_frame(capture.path_join("%s_train.png" % language)):
							return false
					if choice == 0 and flag.is_empty() and not moving and not capture.is_empty():
						if not await _save_viewport_frame(capture.path_join("%s_stopped.png" % language)):
							return false
					_story.call("_on_advance")
					await _wait_stable()
				if not bool(_story.get("_showing_choices")):
					return false
				var count: int = GameState.events_seen
				var money: float = GameState.money
				_story.call("_on_choice", choice)
				await _wait_stable()
				if int(_story.call("_story_source_paragraph_count")) != 4:
					return false
				var result_pages := (_story.get("_paragraphs") as Array).size()
				var seen_clinic := false
				var seen_shop := false
				for page in range(result_pages):
					await _finish_page()
					var source := int(_story.call("_story_source_paragraph_index", page))
					var clinic := choice == 0 and source in [1, 2]
					var destination := "hospital_clinic_day" if clinic else ""
					if source == 0:
						if choice == 0:
							destination = W161_PLATFORM
						elif choice == 2:
							destination = W161_STOPPED
					elif choice == 0 and source == 3:
						destination = W161_CASHIER
					elif choice == 2 and source == 1:
						destination = W161_STATION_SHOP
					if choice == 1:
						destination = W161_BAEKBAN_EMPTY if source == 3 else W161_BAEKBAN_MEAL
					if not _expect_w161_surface(destination):
						return false
					var first_shop_page := destination == W161_STATION_SHOP and not seen_shop
					if first_shop_page:
						seen_shop = true
						if flag.is_empty() and not capture.is_empty():
							if not await _save_viewport_frame(capture.path_join("%s_station_shop.png" % language)):
								return false
					if destination == W161_PLATFORM and flag.is_empty() and page == 0 and not capture.is_empty():
						if not await _save_viewport_frame(capture.path_join("%s_platform.png" % language)):
							return false
					if destination == W161_CASHIER and flag.is_empty() and page == result_pages - 1 and not capture.is_empty():
						if not await _save_viewport_frame(capture.path_join("%s_cashier.png" % language)):
							return false
					if choice == 1 and flag.is_empty() and not capture.is_empty() \
							and (page == 0 or page == result_pages - 1):
						var meal_stage := "empty" if source == 3 else "served"
						if not await _save_viewport_frame(capture.path_join("%s_baekban_%s.png" % [language, meal_stage])):
							return false
					if clinic and not seen_clinic:
						seen_clinic = true
						if flag.is_empty() and not capture.is_empty():
							if not await _save_viewport_frame(capture.path_join("%s_clinic.png" % language)):
								return false
					if flag.is_empty() and (page == 0 or page == result_pages - 1 \
							or (source == 1 and clinic) or first_shop_page):
						var context: Dictionary = _story.call("build_save_resume_context")
						if not await _reload_authored_result_context(context, language, 4, source, true) \
								or not _expect_w161_surface(destination):
							_fail("W161 cold result did not recover its exact location")
							return false
						await _finish_page()
						restores += 1
						if destination == W161_STOPPED:
							stopped_reloads += 1
						elif destination == W161_PLATFORM:
							platform_reloads += 1
						elif destination == W161_CASHIER:
							cashier_reloads += 1
						elif destination == W161_BAEKBAN_MEAL:
							meal_reloads += 1
						elif destination == W161_BAEKBAN_EMPTY:
							empty_bowl_reloads += 1
						elif destination == W161_STATION_SHOP:
							shop_reloads += 1
						elif choice == 2 and source == 3:
							shop_exit_reloads += 1
					if page + 1 < result_pages:
						_story.call("_on_advance")
						await _wait_stable()
				var deltas: Array = [-50000, -30000, 0]
				var health: Array = [65, 63, 55]
				if GameState.events_seen != count + 1 or GameState.money != money + deltas[choice] \
						or GameState.health != health[choice] or not GameState.flags.get("arc_36_body_signal_seen", false):
					_fail("W161 changed the original health, price or receipt")
					return false
				paths += 1
	print(("W161_BODY_OK paths=%d v4=%d stopped_v4=%d platform_v4=%d cashier_v4=%d meal_v4=%d " \
		+ "empty_v4=%d shop_v4=%d shop_neutral_v4=%d") % [paths, restores, stopped_reloads, \
		platform_reloads, cashier_reloads, meal_reloads, empty_bowl_reloads, shop_reloads, shop_exit_reloads])
	return paths == 60 and restores >= 40 and stopped_reloads == 5 and platform_reloads == 5 \
		and cashier_reloads == 5 and meal_reloads == 5 and empty_bowl_reloads == 5 \
		and shop_reloads == 5 and shop_exit_reloads == 5

func _expect_w161_surface(background: String) -> bool:
	var image := _story.get("_bg_img") as TextureRect
	var audio_ok := not BGMPlayer._human_ambience_player.playing and not BGMPlayer._season_player.playing
	var moving := background == W57_CAR
	var bed := "seoul_subway_onboard" if moving else ""
	audio_ok = audio_ok and BGMPlayer._ambience_player.playing == moving
	var surface_ok := _expect_surface(background, bed, "W161") if not background.is_empty() \
		else image.texture == null and (_story.get("_bg_dim") as ColorRect).color == Color("#111216") \
		and str(_story.get_meta("living_scene_effect", "")) == "none"
	if not audio_ok or not surface_ok:
		_fail("W161 borrowed a place or sound: %s/expected %s" % [
			_story.get("_event_background_id"), background])
	return audio_ok and surface_ok

func _check_w132_stairs() -> bool:
	var paths := 0
	var cold := 0
	var capture := OS.get_environment("GANGNAM_W132_CAPTURE_DIR")
	for language: String in LocaleManager.SUPPORTED_LANGUAGES:
		for choice: int in range(4):
			await _remove_story()
			await _stop_audio()
			_context = "%s/W132/report-c%d" % [language, choice]
			LocaleManager.set_language(language)
			SaveManager.clear_loaded_resume_context()
			GameState.start_new_game()
			GameState.turn = 132
			GameState.age = 35
			GameState.story_return_scene = "res://scenes/MainGame.tscn"
			GameState.pending_story_queue = [W132_CAFE_ROOT, W132_REPORT]
			_story = load("res://scenes/StoryMode.tscn").instantiate() as Control
			add_child(_story)
			_story.call("_set_auto_mode", false, false, false)
			await _finish_page()
			if not _expect_w132_surface(false):
				return false
			_story.call("_load_next_event")
			await _wait_stable()
			if str((_story.get("_current") as Dictionary).get("id", "")) != W132_REPORT:
				_fail("W132 fixture did not advance to the reckoning")
				return false
			var intro: Array = _story.get("_paragraphs")
			for _i in range(intro.size()):
				await _finish_page()
				if not _expect_w132_surface(false):
					return false
				_story.call("_on_advance")
				await _wait_stable()
			if not bool(_story.get("_showing_choices")):
				return false
			var count: int = GameState.events_seen
			var money: float = GameState.money
			AudioManager._last_sfx_ms.erase("footsteps_hall")
			_story.call("_on_choice", choice)
			await _wait_stable()
			var result: Array = _story.get("_paragraphs")
			var cut := int(_story.get("_result_location_cut_page"))
			if (cut > 1) != (choice == 0):
				_fail("W132 exact five-locale stairs text boundary missing or applied to other choices")
				return false
			for page in range(result.size()):
				var at_stairs := cut >= 0 and page >= cut
				await _finish_page()
				if not _expect_w132_surface(at_stairs) \
						or AudioManager._last_sfx_ms.has("footsteps_hall") != at_stairs:
					_fail("W132 sound did not follow the authored descent")
					return false
				if choice == 0 and at_stairs and page == cut and not capture.is_empty():
					await get_tree().create_timer(0.5).timeout
					if not await _save_viewport_frame(capture.path_join("%s_stairs.png" % language)):
						return false
				if page + 1 < result.size():
					_story.call("_on_advance")
					await _wait_stable()
			if choice == 0:
				var context: Dictionary = _story.call("build_save_resume_context")
				AudioManager._last_sfx_ms.erase("footsteps_hall")
				if not await _reload_authored_result_context(context, language, 2, 1) \
						or not _expect_w132_surface(true) or AudioManager._last_sfx_ms.has("footsteps_hall"):
					_fail("W132 cold v4 replayed stairs cue or revealed the café")
					return false
				cold += 1
			if GameState.events_seen != count + 1 or GameState.money != money:
				_fail("W132 staging affected result receipt count or assets")
				return false
			paths += 1
	print("W132_STAIRS_OK choices=%d cold_v4=%d" % [paths, cold])
	return paths == 20 and cold == 5

func _expect_w132_surface(at_stairs: bool) -> bool:
	var frame := _story.get("_portrait_frame") as Control
	var presentation := _story.get("_current_presentation") as Dictionary
	var exact := _expect_surface(W132_STAIRS if at_stairs else "cafe", "", "W132") \
		and not BGMPlayer._ambience_player.playing and not BGMPlayer._human_ambience_player.playing \
		and not BGMPlayer._season_player.playing and frame.visible != at_stairs \
		and str(presentation.get("channel", "")) == ("narration" if at_stairs else "in_person")
	if not exact:
		_fail("W132 stairs/café presence did not match narration")
	return exact

func _expect_w126_w205_surface(river: bool, home: String, outside: bool, ended: bool) -> bool:
	if river:
		return _expect_surface("hangang_riverside" if outside else home, "" if outside else "oneroom", "W126") \
			and (not outside or (not BGMPlayer._ambience_player.playing and not BGMPlayer._human_ambience_player.playing \
				and not BGMPlayer._season_player.playing))
	var frame := _story.get("_portrait_frame") as Control
	var badge := _story.get("_communication_badge") as Control
	var portrait := _story.get("_portrait") as TextureRect
	var channel := str((_story.get("_current_presentation") as Dictionary).get("channel", ""))
	var valid := (_story.get("_bg_img") as TextureRect).texture == null \
		and (_story.get("_bg_dim") as ColorRect).color == Color("#111216") \
		and str(_story.get_meta("living_scene_effect", "")) == "none" \
		and channel == ("narration" if ended else "phone") and frame.visible != ended and badge.visible != ended \
		and (ended or (portrait.texture != null and portrait.texture.resource_path == ImageRegistry.get_portrait("minseo"))) \
		and bool(_story.get("_portrait_remote_inset")) != ended and not BGMPlayer._ambience_player.playing \
		and not BGMPlayer._human_ambience_player.playing and not BGMPlayer._season_player.playing
	if not valid:
		_fail("W205 invented a present-day room, sound or in-person meeting")
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

func _open_full_fixture_event(expected_id: String, expected_continuation: Array = [],
		presentation_only: bool = false, seed_ambience: bool = true) -> bool:
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
	if seed_ambience:
		# Most surface fixtures deliberately enter from a rain/street crowd and a
		# stale seasonal bed. W174 passes false because this fixture owns the KTX
		# pane contract, while its existing train audio uses authored fades.
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
