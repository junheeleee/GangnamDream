extends Control
## VisualCropQA — deterministic in-game composition screenshots for visual asset review.
##
## Run:
##   /Users/junheelee/Downloads/Godot.app/Contents/MacOS/Godot --headless res://tools/VisualCropQA.tscn
##
## The tool writes CPU-composited PNGs instead of relying on viewport screenshots,
## because Godot's headless dummy renderer returns empty SubViewport textures.

const OUT_DIR := "/tmp/gangnamdream_crop_qa"
const VIEW_SIZE := Vector2i(1280, 800)
const SHEET_TILE := Vector2i(480, 300)
const SHEET_COLS := 2

var _shots: Array[String] = []
var _failures: Array[String] = []

func _ready() -> void:
	await _run()

func _run() -> void:
	var err := DirAccess.make_dir_recursive_absolute(OUT_DIR)
	if err != OK:
		push_error("VISUAL_CROP_QA cannot create output dir: %s" % OUT_DIR)
		get_tree().quit(1)
		return

	_reset_runtime_state()

	var cases := [
		{
			"mode": "story",
			"name": "story_01_goshiwon_minjun_unemployed",
			"background": "res://assets/backgrounds/goshiwon_room.png",
			"portrait": "res://assets/characters/main_character_unemployed.png",
			"title": "고시원 / 무직 김민준",
			"body": "낮은 책상과 침대가 붙은 좁은 방. 초상화가 배경 구조를 가리지 않는지 확인한다."
		},
		{
			"mode": "story",
			"name": "story_02_late_night_minjun_tired",
			"background": "res://assets/backgrounds/late_night_room.png",
			"portrait": "res://assets/characters/main_character_tired.png",
			"title": "새벽 고시원 / 피로",
			"body": "late_night_room은 goshiwon_room과 같은 구조여야 한다. 조명과 침구 위치가 바뀌면 실패다."
		},
		{
			"mode": "story",
			"name": "story_03_convenience_daeun",
			"background": "res://assets/backgrounds/convenience_store_night.png",
			"portrait": "res://assets/characters/npc_romantic_interest.png",
			"title": "편의점 야간 / 다은",
			"body": "반복 배경에 카운터 직원이나 손님이 주연처럼 박혀 있지 않은지 확인한다."
		},
		{
			"mode": "story",
			"name": "story_04_gangnam_station_jiyeon",
			"background": "res://assets/backgrounds/gangnam_station_exit.png",
			"portrait": "res://assets/characters/npc_mentor.png",
			"title": "강남역 / 한지연",
			"body": "한지연은 배경과 분리된 위험하고 고혹적인 31세 히로인으로 읽혀야 한다."
		},
		{
			"mode": "story",
			"name": "story_04b_meeting_minseo",
			"background": "res://assets/backgrounds/investment_meeting.png",
			"portrait": "res://assets/characters/npc_minseo.png",
			"title": "투자 세미나 / 이민서",
			"body": "이민서는 한지연의 위험한 old-money 아우라와 달리, 강남에 먼저 도착한 38세 실무형 멘토로 읽혀야 한다."
		},
		{
			"mode": "story",
			"name": "story_05_family_father",
			"background": "res://assets/backgrounds/family_living_room.png",
			"portrait": "res://assets/characters/npc_father.png",
			"title": "창원 아버지 집 / 아버지",
			"body": "대가족 사진이나 부유한 서울집 신호가 보이면 정본 충돌이다."
		},
		{
			"mode": "story",
			"name": "story_06_office_team_lead",
			"background": "res://assets/backgrounds/office_desk.png",
			"portrait": "res://assets/characters/npc_team_lead.png",
			"title": "사무실 / 팀장",
			"body": "팀장은 성준과 다르게 압박형 상사 실루엣으로 읽혀야 한다."
		},
		{
			"mode": "story",
			"name": "story_07_library_hyunsu_review",
			"background": "res://assets/backgrounds/library.png",
			"portrait": "res://assets/characters/npc_close_friend.png",
			"title": "도서관 / 현수",
			"body": "공공장소 배경의 주변 인물이 초상화와 충돌하지 않는지 확인한다."
		},
		{
			"mode": "main",
			"name": "main_01_dashboard_goshiwon_unemployed",
			"background": "res://assets/backgrounds/goshiwon_room.png",
			"portrait": "res://assets/characters/main_character_unemployed.png",
			"title": "MainGame / 무직 김민준",
			"body": "좌측 대시보드 초상화 210px 영역에서 얼굴이 작거나 잘리지 않는지 확인한다."
		},
		{
			"mode": "main",
			"name": "main_02_dashboard_gangnam_corporate",
			"background": "res://assets/backgrounds/gangnam_day.png",
			"portrait": "res://assets/characters/main_character_corporate.png",
			"title": "MainGame / 대기업 정장",
			"body": "직업별 의상 초상화가 좌측 패널에서 같은 사람으로 유지되는지 확인한다."
		},
		{
			"mode": "main",
			"name": "main_03_dashboard_gangnam_jiyeon",
			"background": "res://assets/backgrounds/gangnam_night_street.png",
			"portrait": "res://assets/characters/npc_jiyeon_cold.png",
			"title": "MainGame / 한지연 이벤트",
			"body": "강남 야경 배경에 전경 주인공형 인물이 재등장하지 않는지 확인한다."
		},
		{
			"mode": "main",
			"name": "main_04_dashboard_late_night_tired",
			"background": "res://assets/backgrounds/late_night_room.png",
			"portrait": "res://assets/characters/main_character_tired.png",
			"title": "MainGame / 새벽 피로",
			"body": "대시보드 어두운 오버레이에서도 방 구조와 포트레이트가 읽히는지 확인한다."
		},
		{
			"mode": "cg",
			"name": "cg_01_start_goshiwon",
			"background": "res://assets/cg/start.png",
			"title": "CG / 시작 고시원",
			"body": "시작 CG가 고시원 정본 구조와 충돌하지 않는지 확인한다."
		},
		{
			"mode": "cg",
			"name": "cg_02_jiyeon_crash",
			"background": "res://assets/cg/jiyeon_crash.png",
			"title": "CG / 한지연 접촉 사고",
			"body": "벤츠급 차량, 운전석 방향, 자전거 두 바퀴, 한지연 인상이 모두 읽혀야 한다."
		},
		{
			"mode": "cg",
			"name": "cg_03_jaehyuk_reveal",
			"background": "res://assets/cg/jaehyuk_reveal.png",
			"title": "CG / 재혁 폭로",
			"body": "클라이맥스 CG가 1280x800 전체화면에서 핵심 정보가 잘리지 않는지 확인한다."
		},
		{
			"mode": "cg",
			"name": "cg_04_ending_father",
			"background": "res://assets/cg/ending_father.png",
			"title": "CG / 아버지 병실",
			"body": "손을 잡는 감정 초점이 화면 중앙에서 유지되는지 확인한다."
		},
		{
			"mode": "cg",
			"name": "cg_05_ending_gangnam_dream",
			"background": "res://assets/cg/ending_gangnam_dream.png",
			"title": "CG / 강남드림 엔딩",
			"body": "민준과 아버지가 강남 야경을 함께 보는 성공·화해 장면이 잘리지 않는지 확인한다."
		},
		{
			"mode": "cg",
			"name": "cg_06_ending_empty_house",
			"background": "res://assets/cg/ending_empty_house.png",
			"title": "CG / 빈 집 엔딩",
			"body": "같은 강남 성공 공간이지만 혼자 남은 공허함과 탁자 소품이 읽혀야 한다."
		},
		{
			"mode": "cg",
			"name": "cg_07_ending_crypto_ghost",
			"background": "res://assets/cg/ending_crypto_ghost.png",
			"title": "CG / 코인 망령 엔딩",
			"body": "차트광·좁은 방·중독 감정이 보이되 UI 텍스트나 브랜드로 오해될 요소가 없어야 한다."
		},
	]

	for item in cases:
		var shot := await _capture_case(item)
		if shot != "":
			_shots.append(shot)

	var sheet := _save_contact_sheet()
	_write_index(sheet)

	print("VISUAL_CROP_QA_OUT_DIR=%s" % OUT_DIR)
	print("VISUAL_CROP_QA_SHEET=%s" % sheet)
	print("VISUAL_CROP_QA_SHOTS=%d" % _shots.size())
	if _failures.is_empty():
		print("VISUAL_CROP_QA_OK")
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		get_tree().quit(1)

func _reset_runtime_state() -> void:
	GameState.age = 33
	GameState.turn = 1
	GameState.money = 500000
	GameState.health = 65
	GameState.mental = 60
	GameState.housing = "gosiwon"
	GameState.current_job = {}
	if not (GameState.flags is Dictionary):
		GameState.flags = {}
	GameState.flags.clear()

func _capture_case(item: Dictionary) -> String:
	var bg_path := str(item.get("background", ""))
	if not ResourceLoader.exists(bg_path):
		_failures.append("missing background/cg: %s" % bg_path)
		return ""
	var portrait_path := str(item.get("portrait", ""))
	if portrait_path != "" and not ResourceLoader.exists(portrait_path):
		_failures.append("missing portrait: %s" % portrait_path)
		return ""

	var img := _render_case_cpu(item)
	if img == null:
		return ""
	var out_path := "%s/%s.png" % [OUT_DIR, str(item.get("name", "case"))]
	var err := img.save_png(out_path)
	if err != OK:
		_failures.append("cannot save screenshot: %s" % out_path)
		out_path = ""
	return out_path

func _render_case_cpu(item: Dictionary) -> Image:
	var mode := str(item.get("mode", ""))
	match mode:
		"story":
			return _render_story_cpu(item)
		"main":
			return _render_main_cpu(item)
		"cg":
			return _render_cg_cpu(item)
		_:
			_failures.append("unknown visual crop mode: %s" % mode)
			return null

func _render_story_cpu(item: Dictionary) -> Image:
	var canvas := _new_canvas(Color("#0c0c10"))
	var bg := _load_image(str(item["background"]))
	if bg == null:
		return null
	_draw_scale(canvas, bg, Rect2i(0, 0, VIEW_SIZE.x, VIEW_SIZE.y), 1.0)
	_blend_rect_color(canvas, Rect2i(0, 0, VIEW_SIZE.x, VIEW_SIZE.y), Color(0.04, 0.04, 0.07, 0.62))

	var portrait_path := str(item.get("portrait", ""))
	if portrait_path != "":
		var portrait := _load_image(portrait_path)
		if portrait == null:
			return null
		var outer := Rect2i(964, 74, 268, 470)
		var inner := Rect2i(969, 79, 258, 460)
		_blend_rect_color(canvas, outer, Color(0.85, 0.70, 0.36, 0.9))
		_blend_rect_color(canvas, Rect2i(966, 76, 264, 466), Color(0.05, 0.06, 0.09, 0.92))
		_draw_cover(canvas, portrait, inner, 1.0)

	_blend_rect_color(canvas, Rect2i(50, 550, 1180, 210), Color(0.03, 0.03, 0.06, 0.90))
	_blend_rect_color(canvas, Rect2i(50, 550, 1180, 1), Color("#2a3450"))
	return canvas

func _render_main_cpu(item: Dictionary) -> Image:
	var canvas := _new_canvas(Color("#0c0c10"))
	var bg := _load_image(str(item["background"]))
	if bg == null:
		return null
	_draw_scale(canvas, bg, Rect2i(0, 0, VIEW_SIZE.x, VIEW_SIZE.y), 0.25)
	_blend_rect_color(canvas, Rect2i(0, 0, VIEW_SIZE.x, VIEW_SIZE.y), Color(0.05, 0.05, 0.07, 0.76))

	_blend_rect_color(canvas, Rect2i(0, 0, VIEW_SIZE.x, 48), Color("#0d0d14"))
	_blend_rect_color(canvas, Rect2i(0, 48, VIEW_SIZE.x, 38), Color(0.05, 0.05, 0.08, 0.92))
	_blend_rect_color(canvas, Rect2i(180, 62, 920, 10), Color("#151520"))
	_blend_rect_color(canvas, Rect2i(180, 62, 6, 10), Color("#3a6ea8"))
	_blend_rect_color(canvas, Rect2i(0, 86, 180, 654), Color("#0d0d14"))
	_blend_rect_color(canvas, Rect2i(12, 96, 156, 210), Color(0.02, 0.02, 0.04, 0.86))

	var portrait := _load_image(str(item.get("portrait", "")))
	if portrait == null:
		return null
	_draw_contain(canvas, portrait, Rect2i(12, 96, 156, 210), 1.0)

	_blend_rect_color(canvas, Rect2i(12, 306, 156, 44), Color(0, 0, 0, 0.72))
	_blend_rect_color(canvas, Rect2i(212, 110, 1024, 44), Color(0.06, 0.07, 0.12, 0.50))
	for i in range(3):
		_blend_rect_color(canvas, Rect2i(212, 324 + i * 62, 1024, 52), Color(0.06, 0.07, 0.12, 0.94))
		_blend_rect_color(canvas, Rect2i(212, 324 + i * 62, 3, 52), Color("#5b9cf6"))
	_blend_rect_color(canvas, Rect2i(0, 740, VIEW_SIZE.x, 60), Color("#0d0d14"))
	return canvas

func _render_cg_cpu(item: Dictionary) -> Image:
	var canvas := _new_canvas(Color("#0c0c10"))
	var bg := _load_image(str(item["background"]))
	if bg == null:
		return null
	_draw_scale(canvas, bg, Rect2i(0, 0, VIEW_SIZE.x, VIEW_SIZE.y), 1.0)
	_blend_rect_color(canvas, Rect2i(0, 0, VIEW_SIZE.x, VIEW_SIZE.y), Color(0.02, 0.02, 0.04, 0.16))
	_blend_rect_color(canvas, Rect2i(44, 712, 1192, 48), Color(0.02, 0.03, 0.05, 0.80))
	return canvas

func _new_canvas(color: Color) -> Image:
	var canvas := Image.create(VIEW_SIZE.x, VIEW_SIZE.y, false, Image.FORMAT_RGBA8)
	canvas.fill(color)
	return canvas

func _load_image(path: String) -> Image:
	if path == "":
		_failures.append("empty image path")
		return null
	var img := Image.new()
	var absolute := ProjectSettings.globalize_path(path)
	var err := img.load(absolute)
	if err != OK:
		_failures.append("cannot load image: %s" % path)
		return null
	img.convert(Image.FORMAT_RGBA8)
	return img

func _draw_scale(dst: Image, src: Image, rect: Rect2i, alpha: float) -> void:
	var scaled := src.duplicate()
	scaled.resize(rect.size.x, rect.size.y, Image.INTERPOLATE_LANCZOS)
	_apply_alpha(scaled, alpha)
	dst.blend_rect(scaled, Rect2i(Vector2i.ZERO, rect.size), rect.position)

func _draw_contain(dst: Image, src: Image, rect: Rect2i, alpha: float) -> void:
	var scale: float = min(float(rect.size.x) / float(src.get_width()), float(rect.size.y) / float(src.get_height()))
	var new_size := Vector2i(maxi(1, int(round(src.get_width() * scale))), maxi(1, int(round(src.get_height() * scale))))
	var scaled := src.duplicate()
	scaled.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
	_apply_alpha(scaled, alpha)
	var pos := rect.position + Vector2i(int((rect.size.x - new_size.x) / 2), int((rect.size.y - new_size.y) / 2))
	dst.blend_rect(scaled, Rect2i(Vector2i.ZERO, new_size), pos)

func _draw_cover(dst: Image, src: Image, rect: Rect2i, alpha: float) -> void:
	var scale: float = max(float(rect.size.x) / float(src.get_width()), float(rect.size.y) / float(src.get_height()))
	var new_size := Vector2i(maxi(1, int(ceil(src.get_width() * scale))), maxi(1, int(ceil(src.get_height() * scale))))
	var scaled := src.duplicate()
	scaled.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
	_apply_alpha(scaled, alpha)
	var crop_pos := Vector2i(maxi(0, int((new_size.x - rect.size.x) / 2)), maxi(0, int((new_size.y - rect.size.y) / 2)))
	var crop: Image = scaled.get_region(Rect2i(crop_pos, rect.size))
	dst.blend_rect(crop, Rect2i(Vector2i.ZERO, rect.size), rect.position)

func _blend_rect_color(dst: Image, rect: Rect2i, color: Color) -> void:
	if rect.size.x <= 0 or rect.size.y <= 0:
		return
	var overlay := Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
	overlay.fill(color)
	dst.blend_rect(overlay, Rect2i(Vector2i.ZERO, rect.size), rect.position)

func _apply_alpha(img: Image, alpha: float) -> void:
	if alpha >= 0.999:
		return
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			c.a *= alpha
			img.set_pixel(x, y, c)

func _save_contact_sheet() -> String:
	var rows := int(ceil(float(_shots.size()) / float(SHEET_COLS)))
	var sheet := Image.create(SHEET_TILE.x * SHEET_COLS, SHEET_TILE.y * rows, false, Image.FORMAT_RGB8)
	sheet.fill(Color("#101018"))
	for i in range(_shots.size()):
		var img := Image.new()
		var err := img.load(_shots[i])
		if err != OK:
			_failures.append("cannot load shot for sheet: %s" % _shots[i])
			continue
		img.convert(Image.FORMAT_RGB8)
		img.resize(SHEET_TILE.x, SHEET_TILE.y, Image.INTERPOLATE_LANCZOS)
		var dst := Vector2i((i % SHEET_COLS) * SHEET_TILE.x, int(i / SHEET_COLS) * SHEET_TILE.y)
		sheet.blit_rect(img, Rect2i(Vector2i.ZERO, SHEET_TILE), dst)
	var sheet_path := "%s/visual_crop_qa_sheet.png" % OUT_DIR
	var err := sheet.save_png(sheet_path)
	if err != OK:
		_failures.append("cannot save contact sheet: %s" % sheet_path)
		return ""
	return sheet_path

func _write_index(sheet_path: String) -> void:
	var index_path := "%s/README.txt" % OUT_DIR
	var file := FileAccess.open(index_path, FileAccess.WRITE)
	if file == null:
		_failures.append("cannot write index: %s" % index_path)
		return
	file.store_line("Gangnam Dream Visual Crop QA")
	file.store_line("Sheet: %s" % sheet_path)
	file.store_line("")
	for shot in _shots:
		file.store_line(shot)
	file.close()
