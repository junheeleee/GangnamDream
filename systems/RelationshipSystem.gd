extends Node

signal relationship_added(rel: Dictionary)
signal relationship_changed(rel: Dictionary)

func process_monthly_relationships():
	for rel in GameState.relationships.duplicate():
		# 외모가 높으면 연애 관계의 호감도 감소를 완화
		var affection_decay = 1
		if str(rel.get("type", "")) == "romantic" and GameState.appearance >= 60:
			affection_decay = 0
		rel["affection"] = clamp(int(rel.get("affection", rel.get("affinity", 40))) - affection_decay, 0, 100)
		var trust_decay = 0
		if GameState.stress > 75:
			trust_decay = 1
		rel["trust"] = clamp(int(rel.get("trust", 40)) - trust_decay, 0, 100)
		_apply_passive(rel)
		if int(rel.get("affection", 0)) <= 0 and int(rel.get("trust", 0)) <= 10:
			GameState.relationships.erase(rel)
			GameState.add_log("%s와의 관계가 끊어졌다." % rel.get("name", "누군가"), "relationship")
		else:
			relationship_changed.emit(rel)

func add_relationship(rel_data):
	GameState.apply_relationship_effect(rel_data)
	relationship_added.emit(rel_data)

func get_affinity_label(value):
	if value >= 85: return "운명 공동체"
	if value >= 65: return "가까운 사이"
	if value >= 45: return "느슨한 인연"
	if value >= 25: return "불안한 관계"
	return "멀어진 관계"

func _apply_passive(rel):
	var affection = int(rel.get("affection", 40))
	var trust = int(rel.get("trust", 40))
	var name = rel.get("name", "인연")
	if affection < 45:
		return
	match str(rel.get("type", "friends")):
		"romantic":
			# 연인: 정신력 안정 + 스트레스 완화. 친밀도 높을수록 강함.
			if affection >= 80:
				GameState.modify_stat("mental", 2)
				GameState.modify_hidden_stat("stress", -4)
				if randf() < 0.15:
					# 생활비 분담 효과 (월 10만원)
					GameState.add_money(100_000.0)
					GameState.add_log("%s: 생활비 분담 효과 +10만원" % name, "relationship")
			elif affection >= 60:
				GameState.modify_stat("mental", 1)
				GameState.modify_hidden_stat("stress", -2)
			else:
				GameState.modify_hidden_stat("stress", -1)
		"mentor":
			# 멘토: 능력치 성장 + 투자 인사이트. 신뢰도 높을수록 투자 정보 제공.
			if affection >= 75 and trust >= 60:
				GameState.modify_stat("investment_skill", 1)
				GameState.modify_stat("intelligence", 1)
				if randf() < 0.20:
					# 멘토의 투자 팁: 월 20만원 가치의 인사이트
					GameState.add_money(200_000.0)
					GameState.add_log("%s 멘토: 투자 인사이트 +20만원 가치" % name, "relationship")
			elif affection >= 55:
				if randf() < 0.55:
					GameState.modify_stat("investment_skill", 1)
				if randf() < 0.40:
					GameState.modify_stat("intelligence", 1)
			else:
				if randf() < 0.35:
					GameState.modify_stat("intelligence", 1)
		"business":
			# 비즈니스: 평판 성장 + 고신뢰시 수익 공유
			if affection >= 75 and trust >= 70:
				GameState.modify_hidden_stat("reputation", 2)
				if randf() < 0.25:
					# 비즈니스 파트너 수익 공유
					var bonus = 150_000.0
					GameState.add_money(bonus)
					GameState.add_log("%s: 비즈니스 파트너 수익 공유 +15만원" % name, "relationship")
			elif affection >= 55:
				GameState.modify_hidden_stat("reputation", 1)
				if randf() < 0.15:
					GameState.add_money(80_000.0)
			else:
				if randf() < 0.45:
					GameState.modify_hidden_stat("reputation", 1)
		"family":
			# 가족: 정신적 안정. 어려울 때 지원금.
			if affection >= 70:
				GameState.modify_stat("mental", 2)
				GameState.modify_hidden_stat("stress", -2)
				if randf() < 0.10 and GameState.money < 500_000:
					# 용돈/지원
					GameState.add_money(300_000.0)
					GameState.add_log("%s: 가족 지원금 +30만원" % name, "relationship")
			elif affection >= 50:
				GameState.modify_stat("mental", 1)
				GameState.modify_hidden_stat("stress", -1)
		"friends":
			# 친구: 사회성 성장 + 스트레스 해소
			if affection >= 70:
				GameState.modify_hidden_stat("stress", -3)
				if randf() < 0.30:
					GameState.modify_stat("social_skill", 1)
			elif affection >= 50:
				GameState.modify_hidden_stat("stress", -1)
				if randf() < 0.20:
					GameState.modify_stat("social_skill", 1)
