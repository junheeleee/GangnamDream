extends Node
## ScreenshotQA — 실제 렌더러로 MainGame UI를 캡처해 폴리싱 연출을 눈으로 검증.
## 실행: xvfb-run -a godot --display-driver x11 --rendering-driver opengl3 \
##         --resolution 1280x800 res://tools/ScreenshotQA.tscn
## 헤드리스 더미 렌더러는 빈 텍스처를 주므로 x11+opengl3(xvfb) 필요.
## .tscn 으로 부팅해야 autoload(GameState 등)가 로드된다.

const OUT_DIR := "/tmp/gangnamdream_qa"
var _mg: Node = null

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_clear_output_dir()
	await _shot_start_menu()
	GameState.start_new_game()
	GameState.flags["prologue_done"] = true
	for c in ["chapter_33_seen","chapter_34_seen","chapter_35_seen","chapter_36_seen","chapter_37_seen"]:
		GameState.flags[c] = true
	GameState.age = 33
	GameState.turn = 14
	GameState.money = 3_500_000.0
	GameState.monthly_income = 2_240_000.0
	GameState.current_job = {"name":"사무직","base_salary":2_240_000.0,"tier":2}
	GameState.health = 62
	GameState.mental = 58
	GameState.investment_skill = 35
	GameState.flags["has_received_paycheck"] = true
	GameState.flags["arc_invest_guidance_seen"] = true
	_suppress_tutorial_overlays()
	_seed_portfolio()
	await _shot_story_event("arc_intro_01_meal", "00a_story_interview")

	# MainGame._ready 의 _begin_month 가 StoryMode 로 change_scene 하는 것을 막는다:
	# returning_from_story=true 로 진입점을 우회하고, 직후 전환 트윈을 매 프레임 죽인다.
	GameState.returning_from_story = true

	var packed: PackedScene = load("res://scenes/MainGame.tscn")
	_mg = packed.instantiate()
	get_tree().root.add_child.call_deferred(_mg)

	# 0.35s 전환 트윈이 change_scene 을 쏘기 전에 계속 죽인다 (현재 씬=QA 보호)
	for _i in range(40):
		_kill_transition()
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	_kill_transition()

	await _shot_event_gambling()
	await _shot_investment()
	await _shot_support_modals()
	await _shot_crisis_vignette()
	await _shot_ap_actions()
	await _shot_people()
	await _shot_minigame("holdem_club", "06_holdem_club")
	await _shot_minigame("racetrack", "07_racetrack")
	await _shot_minigame("jeongseon_casino", "08_jeongseon_casino")
	await _shot_casino_table("baccarat_table", "09_baccarat_table")
	await _shot_casino_table("blackjack_table", "10_blackjack_table")
	await _shot_casino_table("slot_machine_game", "11_slot_machine")
	await _shot_casino_table("roulette_table", "12_roulette_table")
	await _shot_ending("gangnam_dream", "13_ending_gangnam_win")
	await _shot_ending("bankruptcy", "14_ending_bankruptcy")
	await _shot_ending("stable_success", "15_ending_stable_success")
	await _shot_ending("crypto_ghost", "16_ending_crypto_ghost")
	await _shot_ending("orthodox_pinnacle", "17_ending_orthodox_pinnacle")

	print("SCREENSHOT_QA_DONE dir=%s" % OUT_DIR)
	get_tree().quit(0)

func _clear_output_dir() -> void:
	var dir := DirAccess.open(OUT_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func _shot_start_menu() -> void:
	var packed: PackedScene = load("res://scenes/StartMenu.tscn")
	var menu := packed.instantiate()
	get_tree().root.add_child.call_deferred(menu)
	await get_tree().process_frame
	await _settle(0.8)
	if menu.has_method("_dismiss_splash"):
		menu._dismiss_splash()
	await _settle(0.6)
	await _save("00_start_menu")
	if is_instance_valid(menu):
		var parent := menu.get_parent()
		if parent != null:
			parent.remove_child(menu)
		menu.free()
	_remove_start_menu_nodes()
	await _settle(0.4)

func _remove_start_menu_nodes() -> void:
	var targets: Array[Node] = []
	_collect_start_menu_nodes(get_tree().root, targets)
	for node in targets:
		var parent := node.get_parent()
		if parent != null:
			parent.remove_child(node)
		node.free()

func _collect_start_menu_nodes(node: Node, targets: Array[Node]) -> void:
	var script_path := "res://scenes/StartMenu.gd"
	for child in node.get_children():
		if child == self:
			continue
		var script: Script = child.get_script()
		var is_start_menu := child.name == "StartMenu" or (script != null and script.resource_path == script_path)
		if is_start_menu:
			targets.append(child)
		else:
			_collect_start_menu_nodes(child, targets)

func _shot_story_event(event_id: String, shot_name: String) -> void:
	GameState.pending_story_queue = [event_id]
	var packed: PackedScene = load("res://scenes/StoryMode.tscn")
	var story := packed.instantiate()
	get_tree().root.add_child.call_deferred(story)
	await get_tree().process_frame
	await _settle(1.1)
	await _save(shot_name)
	_remove_nodes_by_script("res://scenes/StoryMode.gd")
	GameState.pending_story_queue.clear()
	await _settle(0.3)

func _remove_nodes_by_script(script_path: String) -> void:
	var targets: Array[Node] = []
	_collect_nodes_by_script(get_tree().root, script_path, targets)
	for node in targets:
		var parent := node.get_parent()
		if parent != null:
			parent.remove_child(node)
		node.free()

func _collect_nodes_by_script(node: Node, script_path: String, targets: Array[Node]) -> void:
	for child in node.get_children():
		if child == self:
			continue
		var script: Script = child.get_script()
		if script != null and script.resource_path == script_path:
			targets.append(child)
		else:
			_collect_nodes_by_script(child, script_path, targets)

func _seed_portfolio() -> void:
	if not (GameState.portfolio is Dictionary):
		return
	GameState.portfolio["samsung"] = {"quantity": 30.0, "avg_price": 68000.0}
	GameState.portfolio["nvidia"] = {"quantity": 2.0, "avg_price": 820000.0}

func _suppress_tutorial_overlays() -> void:
	for id in ["main_game", "holdem", "racetrack", "baccarat", "blackjack",
			"slot", "roulette", "bigwheel", "scalping", "trading", "invest"]:
		TutorialOverlay._seen[id] = true

func _kill_transition() -> void:
	var st = get_tree().root.get_node_or_null("SceneTransition")
	if st and st.has_method("fade_in"):
		st.fade_in()

func _settle(t: float = 0.6) -> void:
	await get_tree().create_timer(t).timeout
	await get_tree().process_frame

func _save(shot_name: String) -> void:
	await _settle(0.3)
	RenderingServer.force_draw()
	await get_tree().process_frame
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		_fail("Viewport texture is unavailable. Run ScreenshotQA with a real rendering driver.")
		return
	var img: Image = viewport_texture.get_image()
	if img == null or img.is_empty():
		_fail("Viewport image is empty. Run ScreenshotQA with a real rendering driver.")
		return
	var path := "%s/%s.png" % [OUT_DIR, shot_name]
	img.save_png(path)
	print("SHOT %s" % path)

func _fail(msg: String) -> void:
	push_error("SCREENSHOT_QA_FAIL " + msg)
	get_tree().quit(1)

func _force_event(ev: Dictionary) -> void:
	_mg.current_event = ev
	_mg._render_event()
	await _settle(0.4)
	if _mg.has_method("_finish_typing"):
		_mg._finish_typing()
	await _settle(0.5)

func _shot_event_gambling() -> void:
	await _force_event({
		"id": "qa_gambling",
		"title": "도박장 뒷골목",
		"description": "상철이 어깨를 짚는다. \"딱 한 판이면 돼...\" 심장이 빠르게 뛴다. 카드가 눈앞에서 흔들린다...",
		"tags": ["gambling", "stress"],
		"choices": [
			{"text": "판에 들어간다", "effects": {"money": -500000, "stress": 8}, "result_text": "칩을 밀었다."},
			{"text": "돌아선다", "effects": {"mental": 4}, "result_text": "문을 나섰다."},
		],
	})
	await _save("01_event_gambling_wave")

func _shot_investment() -> void:
	if _mg.has_method("_open_investments"):
		_mg._open_investments()
		await _settle(0.8)
		await _save("02_investment_portfolio_chart")
		_close_modal()
		await _settle(0.4)

func _shot_support_modals() -> void:
	if _mg.has_method("_open_bank"):
		_mg._open_bank()
		await _settle(0.7)
		await _save("02a_bank_modal")
		_close_modal()
		await _settle(0.3)
	if _mg.has_method("_open_shop"):
		_mg._open_shop()
		await _settle(0.7)
		await _save("02b_shop_modal")
		_close_modal()
		await _settle(0.3)
	if _mg.has_method("_open_system_menu"):
		_mg._open_system_menu()
		await _settle(0.7)
		await _save("02c_system_menu")
		_close_modal()
		await _settle(0.3)

func _shot_crisis_vignette() -> void:
	GameState.mental = 9
	GameState.health = 22
	if _mg.has_method("_update_vignette"):
		_mg._update_vignette()
	await _force_event({
		"id": "qa_crisis",
		"title": "벼랑 끝",
		"description": "통장은 비었고, 잠이 오지 않는다. 천장만 본다... 이대로 무너지는 걸까...",
		"tags": ["stress", "anxiety"],
		"choices": [
			{"text": "버틴다", "effects": {"mental": 2}, "result_text": "버텼다."},
		],
	})
	await _save("03_crisis_vignette")
	GameState.mental = 58
	GameState.health = 62
	if _mg.has_method("_update_vignette"):
		_mg._update_vignette()

func _shot_ap_actions() -> void:
	_mg.current_event = {}
	if _mg.has_method("_render_ap_actions"):
		_mg._render_ap_actions()
	await _settle(0.8)
	await _save("04_ap_actions_dashboard")

func _close_modal() -> void:
	for m in ["_close_modal","_close_overlay","_dismiss_modal"]:
		if _mg.has_method(m):
			_mg.call(m)
			return

func _shot_people() -> void:
	# 인맥 카테고리 모달 — 캐스트 관계 상태
	GameState.flags["entered_network"] = true
	if _mg.has_method("_open_cat_people"):
		_mg._open_cat_people()
		await _settle(0.7)
		await _save("05_people_relationships")
		_close_modal()
		await _settle(0.4)

func _shot_minigame(node_name: String, shot_name: String) -> void:
	# 미니게임은 AP 우회하고 오버레이를 직접 open()
	GameState.flags["entered_network"] = true
	GameState.money = 5_000_000.0
	var node = _mg.get(node_name)
	if node == null or not node.has_method("open"):
		print("SKIP %s (no node)" % shot_name)
		return
	node.open()
	if node_name == "holdem_club" and node.has_method("_start_hand"):
		await _settle(0.4)
		node._buy_in = 100_000
		node._start_hand()
	await _settle(1.0)
	await _save(shot_name)
	# 오버레이 숨김 (다음 케이스 방해 방지)
	if "visible" in node:
		node.visible = false
	await _settle(0.3)

func _shot_casino_table(node_name: String, shot_name: String) -> void:
	GameState.money = 10_000_000.0
	var node = _mg.get(node_name)
	if node == null or not node.has_method("open"):
		print("SKIP %s (no node)" % shot_name)
		return
	node.open()
	await _settle(0.4)
	match node_name:
		"baccarat_table":
			await _save("09a_baccarat_betting")
			node._set_stake(10_000)
			node._add_bet("B")
			node._deal()
			await _settle(2.0)
		"blackjack_table":
			await _save("10a_blackjack_betting")
			node._set_stake_and_deal(10_000)
			await _settle(0.8)
		"slot_machine_game":
			node._start_spin()
			await _settle(1.8)
		"roulette_table":
			node._select_bet_type(1)
			node._select_stake(10_000)
			node._do_bet()
			node._do_spin()
			await _settle(1.6)
	await _save(shot_name)
	if "visible" in node:
		node.visible = false
	await _settle(0.3)

func _shot_ending(ending_id: String, shot_name: String) -> void:
	if _mg.has_method("_show_ending"):
		_mg._show_ending(ending_id)
		await _settle(1.0)
		await _save(shot_name)
		await _settle(0.3)
