extends Node

signal job_changed(new_job: Dictionary)
signal promoted(job: Dictionary, bonus: float)

func apply_for_job(job_id):
	var job = DataRegistry.get_job(job_id)
	if job.is_empty():
		return {"success": false, "message": "존재하지 않는 직업입니다."}
	if not _check_requirements(job.get("requirements", {})):
		return {"success": false, "message": "지원 조건이 부족합니다."}
	if not GameState.current_job.is_empty():
		quit_job(false)
	GameState.current_job = job.duplicate(true)
	GameState.job_tenure = 0
	GameState.work_performance = 50
	GameState.monthly_income += float(job.get("base_salary", 0.0))
	GameState.flags["has_job"] = true
	# 취업 준비 보너스: 이력서 완성 +10, 면접 연습 +7
	var prep_bonus = 0
	if GameState.flags.get("resume_polished", false):
		prep_bonus += 10
		GameState.flags.erase("resume_polished")
	if GameState.flags.get("interview_practiced", false):
		prep_bonus += 7
		GameState.flags.erase("interview_practiced")
	GameState.work_performance = clamp(GameState.work_performance + prep_bonus, 0, 100)
	# 최고 직업 티어 갱신 — 다음 티어 잠금 해제에 사용
	var job_tier: int = int(job.get("tier", 1))
	if job_tier > int(GameState.flags.get("max_job_tier", 0)):
		GameState.flags["max_job_tier"] = job_tier
	var prep_log = (" (준비 보너스 업무능력 +%d)" % prep_bonus) if prep_bonus > 0 else ""
	GameState.add_log("%s 취업. 월급 %s%s" % [job.get("name", "직장"), GameState.format_money(job.get("base_salary", 0.0)), prep_log], "job")
	job_changed.emit(job)
	return {"success": true, "message": "취업 완료"}

func quit_job(voluntary):
	if GameState.current_job.is_empty():
		return
	GameState.monthly_income -= float(GameState.current_job.get("base_salary", 0.0))
	GameState.add_log("%s 퇴사" % GameState.current_job.get("name", "직장"), "job")
	GameState.current_job = {}
	GameState.job_tenure = 0
	GameState.flags.erase("has_job")
	if voluntary:
		job_changed.emit({})

func process_monthly_job():
	if GameState.current_job.is_empty():
		# 무직 스트레스는 apply_monthly_pressure()에서 이미 처리됨 (+6/월)
		# 여기서 추가로 더하면 이중 계산이 됨 — 제거
		return
	var job = GameState.current_job
	GameState.job_tenure += 1
	GameState.modify_hidden_stat("stress", int(job.get("stress_per_month", 6)))
	for stat in job.get("stat_gains", {}):
		if randf() < 0.55:
			GameState.modify_stat(stat, int(job["stat_gains"][stat]))
	GameState.work_performance = clamp(GameState.work_performance + randi_range(-4, 8), 0, 100)
	var promo_count = int(GameState.current_job.get("promotion_count", 0))
	var max_promo = int(job.get("max_promotions", 3))
	if GameState.job_tenure >= int(job.get("promotion_threshold", 999)) and GameState.work_performance >= 60 and randf() < 0.35 and promo_count < max_promo:
		_promote(job)

func get_available_jobs():
	var rows: Array = []
	# 현재까지 도달한 최고 티어 + 1 까지 열람 가능
	# 예: max_job_tier=0(무직경험없음) → 티어1만 접근
	#     max_job_tier=1(티어1 경력) → 티어1·2 접근
	var max_accessible: int = int(GameState.flags.get("max_job_tier", 0)) + 1
	for job in DataRegistry.jobs:
		var row = job.duplicate(true)
		var tier: int = int(job.get("tier", 1))
		row["eligible"] = _check_requirements(job.get("requirements", {}))
		if tier > max_accessible:
			row["locked"] = true
			row["lock_reason"] = "🔒 Tier %d 경력 필요 — 낮은 직급에서 먼저 경험 쌓기" % (tier - 1)
		else:
			row["locked"] = false
			row["lock_reason"] = ""
		rows.append(row)
	return rows

func _promote(job):
	var bonus = float(job.get("promotion_bonus", 0.0))
	GameState.monthly_income += bonus
	GameState.add_money(bonus * 2.0)
	GameState.modify_hidden_stat("reputation", 6)
	GameState.job_tenure = 0
	var promo_count = int(GameState.current_job.get("promotion_count", 0)) + 1
	if not GameState.current_job.is_empty():
		GameState.current_job["promotion_count"] = promo_count
	var max_promo = int(job.get("max_promotions", 3))
	GameState.add_log("⬆ 승진 (%d/%d): 월급 +%s" % [promo_count, max_promo, GameState.format_money(bonus)], "job")
	promoted.emit(job, bonus)
	# 승진할 때마다 직장 내 암투 이벤트 트리거
	var drama_ev = DataRegistry.find_event("drama_office_politics")
	if not drama_ev.is_empty() and randf() < 0.6:
		EventManager.queue_event(drama_ev)

func _check_requirements(req):
	for key in req:
		var val = req[key]
		match key:
			"min_intelligence":
				if GameState.intelligence < int(val): return false
			"min_social", "min_social_skill":
				if GameState.social_skill < int(val): return false
			"min_appearance":
				if GameState.appearance < int(val): return false
			"min_investment_skill":
				if GameState.investment_skill < int(val): return false
			"min_money":
				if GameState.money < float(val): return false
			"flag":
				if not GameState.flags.get(str(val), false): return false
	return true
